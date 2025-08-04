# RISC Zero ZKvm Host Client Prove Module

## Overview
This module provides the proving infrastructure for RISC Zero's zero-knowledge virtual machine (zkVM). It contains multiple prover implementations that can generate cryptographic proofs of program execution, supporting different backends and optimization strategies.

## Core Architecture

### Key Components

#### `mod.rs` - Core Traits and Factory Functions
- **`Prover` trait**: Main interface for proof generation with methods:
  - `prove()`: Basic proof generation with default options
  - `prove_with_opts()`: Proof generation with custom `ProverOpts`
  - `prove_with_ctx()`: Full control with custom `VerifierContext` and options
  - `compress()`: Compress receipts to smaller formats (Succinct/Groth16)
- **`Executor` trait**: Interface for ELF execution without proof generation
- **`default_prover()`**: Factory function that selects prover based on:
  - `RISC0_PROVER` environment variable
  - Available features (`bonsai`, `prove`)
  - API credentials (`BONSAI_API_URL`, `BONSAI_API_KEY`)
- **`default_executor()`**: Factory function for executor selection

#### Prover Implementations

##### `bonsai.rs` - BonsaiProver
**Purpose**: Cloud-based proving service integration
- Uploads ELF binaries and input data to Bonsai service
- Polls for completion and downloads receipts
- Supports both Succinct and Groth16 receipt generation
- Requires `BONSAI_API_URL` and `BONSAI_API_KEY` environment variables
- **Key Features**:
  - Automatic image ID computation and ELF upload
  - Assumption receipt handling (requires succinct format)
  - Configurable polling intervals via `BONSAI_POLL_INTERVAL_MS`
  - Automatic receipt verification

##### `local.rs` - LocalProver
**Purpose**: In-process proving using local hardware
- Uses `get_prover_server()` to obtain prover backend
- Supports full proof generation and compression pipeline
- Requires `prove` feature flag
- **Key Features**:
  - Direct integration with local proving infrastructure
  - Full segment execution with callback support
  - Receipt claim generation for session info

##### `external.rs` - ExternalProver  
**Purpose**: Sub-process proving via `r0vm` executable
- Communicates with external `r0vm` process via API
- Fallback when local proving not available
- **Key Features**:
  - Process spawning and lifecycle management
  - API-based communication with `r0vm`
  - Receipt compression support
  - Configurable via `RISC0_SERVER_PATH`

##### `default.rs` - DefaultProver
**Purpose**: Actor-based distributed proving (experimental)
- Uses Unix domain sockets for RPC communication
- Spawns `r0vm` cluster with `--rpc` flag
- **Key Features**:
  - RPC-based job submission and status polling
  - GPU support via `RISC0_DEFAULT_PROVER_NUM_GPUS`
  - Binary job serialization/deserialization

#### `opts.rs` - ProverOpts Configuration
**Purpose**: Comprehensive prover configuration options
- **Receipt Types**:
  - `Composite`: Linear size, fastest generation
  - `Succinct`: Constant size via recursion
  - `Groth16`: Smallest size, blockchain-ready
- **Key Configuration**:
  - Hash function selection (`poseidon2` default)
  - Guest error proving control
  - Control ID lists for recursion
  - Maximum segment power-of-2 limits
  - Development mode toggles

## Environment Configuration

### Prover Selection (`RISC0_PROVER`)
- `bonsai`: Use Bonsai cloud service
- `local`: Use local in-process proving  
- `ipc`: Use external `r0vm` process
- `actor`: Use DefaultProver with RPC (experimental)

### Executor Selection (`RISC0_EXECUTOR`)
- `local`: Local in-process execution
- `ipc`: External `r0vm` process execution

### Additional Environment Variables
- `BONSAI_API_URL` / `BONSAI_API_KEY`: Bonsai service credentials
- `RISC0_SERVER_PATH`: Custom path to `r0vm` executable
- `RISC0_DEV_MODE`: Enable development mode features
- `BONSAI_POLL_INTERVAL_MS`: Bonsai polling frequency
- `RISC0_DEFAULT_PROVER_NUM_GPUS`: GPU count for DefaultProver

## Usage Patterns

### Basic Proving
```rust
let env = ExecutorEnv::builder().write(&input).build()?;
let receipt = default_prover().prove(env, ELF_BINARY)?;
```

### Succinct Receipt Generation
```rust
let opts = ProverOpts::succinct();
let receipt = default_prover().prove_with_opts(env, ELF_BINARY, &opts)?;
```

### Receipt Compression
```rust
let composite_receipt = default_prover().prove(env, ELF_BINARY)?;
let succinct_receipt = default_prover().compress(&ProverOpts::succinct(), &composite_receipt.receipt)?;
```

## Security Considerations
- All provers verify receipt integrity before returning
- Assumption receipts must be in succinct format for Bonsai
- Development mode enables fake receipts (disabled in production builds)
- Groth16 receipts require Docker for STARK-to-SNARK conversion

## Performance Characteristics
- **Composite**: Fastest proving, linear size growth
- **Succinct**: Moderate proving time, constant size 
- **Groth16**: Longest proving time, smallest size (~few hundred bytes)
- **BonsaiProver**: Offloads computation but adds network latency
- **LocalProver**: Fastest for small proofs, limited by local hardware

## Integration Points
- **Circuit Layer**: Interfaces with recursion and base circuits
- **Session Management**: Integrates with executor and session tracking  
- **Receipt System**: Produces various receipt formats for verification
- **API Layer**: Provides RPC interfaces for external process communication