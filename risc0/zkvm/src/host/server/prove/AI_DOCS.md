# zkVM Prover Server Module

## Overview
This module provides the core proving functionality for the RISC Zero zkVM. It contains implementations for generating zero-knowledge proofs of computation, managing proof lifecycles, and converting between different proof formats.

## Architecture

### Core Components

#### ProverServer Trait (`mod.rs:53-255`)
The main abstraction for proof generation with methods for:
- **Execution Proving**: `prove()` and `prove_with_ctx()` - Generate proofs from ELF binaries
- **Session Proving**: `prove_session()` - Prove execution sessions 
- **Segment Proving**: `prove_segment()` - Prove individual execution segments
- **Receipt Operations**: `lift()`, `join()`, `union()`, `resolve()` - Manipulate proof receipts
- **Proof Compression**: `composite_to_succinct()`, `succinct_to_groth16()` - Convert between proof formats
- **Proof of Verifiable Work (PoVW)**: `lift_povw()`, `join_povw()`, etc. - Handle work-based proofs

#### ProverImpl (`prover_impl.rs`)
Production implementation of `ProverServer` that:
- Runs locally with full cryptographic security
- Handles all proof types (Composite, Succinct, Groth16)
- Manages execution environments and verification contexts
- Implements efficient proof compression and recursion

#### DevModeProver (`dev_mode.rs`) 
Development implementation that:
- Generates fake proofs for testing/development
- Provides fast iteration without cryptographic overhead
- Issues warnings about insecure proof generation
- Maintains API compatibility with production prover

### Specialized Modules

#### Keccak Proving (`keccak.rs`)
- Specialized proving for Keccak cryptographic operations
- Optimized for hash function verification scenarios

#### Union Peak (`union_peak.rs`)
- Handles union operations on proof receipts
- Manages proof composition and aggregation

### Key Data Flows

1. **ELF → Proof**: `prove()` → execution → segments → receipts → compression
2. **Receipt Lifecycle**: Segment → Succinct → Groth16 (optional compression)
3. **Proof Composition**: Multiple receipts → `join()`/`union()` → single proof
4. **Assumption Resolution**: Conditional proofs + assumptions → resolved proofs

### Proof Types Supported

- **SegmentReceipt**: Base proof of segment execution
- **SuccinctReceipt**: Compressed recursive proof  
- **Groth16Receipt**: Ultra-compact SNARK proof
- **CompositeReceipt**: Collection of related proofs
- **FakeReceipt**: Development-only placeholder

### Configuration

Prover selection via `get_prover_server()` based on `ProverOpts`:
- Development mode → `DevModeProver` (fast, insecure)
- Production mode → `ProverImpl` (secure, slower)

## Usage Patterns

### Basic Proving
```rust
let prover = get_prover_server(&opts)?;
let proof_info = prover.prove(env, elf_bytes)?;
```

### Proof Compression
```rust
let succinct = prover.composite_to_succinct(&composite)?;
let groth16 = prover.succinct_to_groth16(&succinct)?;
```

### Proof Composition  
```rust
let joined = prover.join(&receipt_a, &receipt_b)?;
let resolved = prover.resolve(&conditional, &assumption)?;
```

## Security Considerations

- Production provers generate cryptographically secure proofs
- Development mode issues clear warnings about insecurity
- Proof verification maintains integrity across all transformations
- Assumptions must be properly resolved for proof validity