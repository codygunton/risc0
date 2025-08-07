# RISC Zero zkVM Core Library

## Overview

The RISC Zero zkVM is a RISC-V virtual machine that produces zero-knowledge proofs of code execution. This library provides the core functionality for running programs in the zkVM and generating cryptographic receipts that prove correct execution without revealing private inputs.

## Key Concepts

### Host vs Guest Architecture

The zkVM operates on a **host-guest** model:

- **Host**: The untrusted environment where proving occurs. Provides inputs, executes the zkVM, and generates proofs.
- **Guest**: The trusted environment inside the zkVM where your program runs. Has access to private inputs and can commit public outputs.

### Receipts and Proofs

A **Receipt** is a cryptographic proof that a specific program executed correctly with specific inputs/outputs:
- Contains a **journal** (public outputs committed by the guest)
- Includes an **inner receipt** (the actual cryptographic proof)
- Can be verified independently without re-running the computation

### Sessions and Segments

Execution is tracked in **sessions** which are divided into **segments**:
- Long computations are split into provable segments
- Each segment can be proven independently  
- Segments can be composed into larger proofs

## Core Components

### Guest Environment (`guest/`)

**Purpose**: Runtime API for code executing inside the zkVM

**Key Functions**:
- `env::read<T>()` - Read private input from host
- `env::commit<T>()` - Write public output to journal
- `env::verify()` - Verify nested proofs for composition
- `env::write<T>()` - Send private output to host

**Example**:
```rust
use risc0_zkvm::guest::env;

// Read private input
let secret: u32 = env::read();

// Perform computation
let result = secret * secret;

// Commit public output
env::commit(&result);
```

### Host Client API (`host/client/`)

**Purpose**: Host-side interface for execution and proving

**Key Types**:
- `ExecutorEnv` - Configures execution environment and inputs
- `Prover` - Generates proofs (Local, External, Bonsai)
- `ProverOpts` - Proof configuration (Groth16, Succinct, etc.)

**Example**:
```rust
use risc0_zkvm::{default_prover, ExecutorEnv};

// Set up execution environment with inputs
let env = ExecutorEnv::builder()
    .write(&secret_input)
    .unwrap()
    .build()
    .unwrap();

// Generate proof
let receipt = default_prover()
    .prove(env, GUEST_CODE_ELF)
    .unwrap()
    .receipt;

// Verify proof
receipt.verify(GUEST_CODE_ID).unwrap();
```

### Receipts (`receipt.rs`)

**Purpose**: Cryptographic proofs of computation

**Key Types**:
- `Receipt` - Main proof container with journal and metadata
- `InnerReceipt` - Actual proof (Composite, Succinct, Groth16, Fake)
- `Journal` - Public outputs committed by guest
- `ReceiptClaim` - Statement being proven (pre/post state, I/O)

**Verification**:
```rust
// Verify receipt and extract journal data
receipt.verify(expected_image_id)?;
let output: MyOutput = receipt.journal.decode()?;
```

### Claims (`claim/`)

**Purpose**: Defines what statements receipts prove

**Key Types**:
- `ReceiptClaim` - Core claim (system state, I/O, exit code)
- `WorkClaim` - Claim with Proof of Verifiable Work (PoVW)
- `Assumptions` - Unresolved claims from nested verification

**Components**:
- `pre`/`post` - System state before/after execution
- `input`/`output` - Private inputs and public outputs
- `exit_code` - How execution terminated (Halted, Paused, etc.)

### Serialization (`serde/`)

**Purpose**: Efficient binary serialization for host-guest communication

**Features**:
- Word-aligned binary format
- Optimized for minimal guest cycles
- Custom serializer/deserializer implementation

## Proof Types

### Composite Receipts
- Multi-segment proofs (one proof per segment)
- Good for debugging and development
- Larger proof size but faster generation

### Succinct Receipts  
- Single STARK proof for arbitrary-length computation
- Constant-size proofs regardless of computation length
- Slower generation but smaller proofs

### Groth16 Receipts
- Single Groth16 SNARK proof
- Smallest proofs (~260 bytes) with fastest verification
- Requires trusted setup, longer generation time

### Fake Receipts
- Development-only receipts for testing
- No cryptographic security
- Enabled with `RISC0_DEV_MODE=1`

## Common Patterns

### Basic Proving Workflow

```rust
use risc0_zkvm::{default_prover, ExecutorEnv, Receipt};

// 1. Prepare execution environment
let env = ExecutorEnv::builder()
    .write(&input_data)
    .unwrap()
    .build()
    .unwrap();

// 2. Generate proof
let session_info = default_prover()
    .prove(env, GUEST_ELF)
    .unwrap();

// 3. Extract and verify receipt
let receipt = session_info.receipt;
receipt.verify(GUEST_ID).unwrap();

// 4. Extract public outputs
let result: OutputType = receipt.journal.decode().unwrap();
```

### Proof Composition

Guest code can verify other receipts to create composable proofs:

```rust
// In guest code
use risc0_zkvm::guest::env;

// Verify a sub-proof
let sub_receipt: Receipt = env::read();
sub_receipt.verify(SUB_PROGRAM_ID).unwrap();

// Use verified results in computation
let sub_result: SubOutput = sub_receipt.journal.decode().unwrap();
```

### Handling Assumptions

When guests verify receipts, they create assumptions that must be resolved:

```rust
// Check if receipt has unresolved assumptions
if !receipt.inner.composite().unwrap().assumptions.is_empty() {
    // Need to resolve assumptions with actual proofs
    let resolved_receipt = resolve_assumptions(receipt, assumption_receipts)?;
}
```

## Configuration

### Environment Variables
- `RISC0_DEV_MODE=1` - Enable development mode (fake proofs)
- `RISC0_PROVER=local|external|bonsai` - Choose proving backend

### Feature Flags
- `prove` - Enable proving capability
- `cuda` - Enable GPU acceleration  
- `client` - Enable client API
- `std` - Standard library support

### Prover Options

```rust
use risc0_zkvm::{ProverOpts, ReceiptKind};

let opts = ProverOpts {
    receipt_kind: ReceiptKind::Groth16,  // Choose proof type
    ..Default::default()
};
```

## Error Handling

Common error scenarios:
- **Verification Failures**: Invalid proofs or mismatched image IDs
- **Serialization Errors**: Type mismatches in host-guest communication  
- **Execution Errors**: Guest panics, resource limits, invalid syscalls
- **Prover Errors**: Hardware issues, configuration problems

All operations return `Result<T, E>` types for proper error handling.

## Performance Considerations

### Guest Code Optimization
- Minimize allocations and complex operations
- Use efficient algorithms (cycle count matters)
- Prefer batch operations over many small ones
- Consider using `risc0_zkvm::serde` for optimal serialization

### Proving Performance
- **Local proving**: Uses all available CPU cores
- **GPU acceleration**: Enable `cuda` feature for NVIDIA GPUs
- **External proving**: Offload to separate process
- **Bonsai**: Cloud proving service for production

### Memory Usage
- Guest memory is limited (default: 1GB)
- Host memory usage scales with computation complexity
- Consider using streaming for large datasets

## Security Notes

- **Guest code isolation**: Guest cannot access host memory directly
- **Input validation**: Always validate inputs in guest code
- **Public vs private data**: Only journal data is public; inputs remain private
- **Trusted setup**: Groth16 requires trusted setup ceremony
- **Dev mode warning**: Never use `RISC0_DEV_MODE` in production

## Integration Examples

### With Web Applications
```rust
// Generate proof server-side
let receipt = prove_computation(user_input)?;

// Send compact proof to client
let groth16_proof = receipt.inner.groth16().unwrap();
send_to_client(&groth16_proof.seal)?;
```

### Blockchain Integration
```rust
// Create receipt for on-chain verification
let receipt = prover.prove(env, CONTRACT_ELF)?.receipt;

// Extract verification data
let (journal, seal) = receipt.into_parts();
submit_to_blockchain(journal, seal)?;
```

### Batch Processing
```rust
// Process multiple inputs in single proof
let inputs = vec![input1, input2, input3];
let env = ExecutorEnv::builder()
    .write(&inputs)
    .unwrap()
    .build()
    .unwrap();

let receipt = prover.prove(env, BATCH_ELF)?.receipt;
```

This library provides the foundational components for building zero-knowledge applications with the RISC Zero zkVM. The modular architecture supports various use cases from simple computations to complex multi-party protocols.