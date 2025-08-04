# Host Server Component

This module provides the server-side implementation for RISC Zero's zkVM host environment, handling both execution and proving phases of zkVM programs.

## Overview

The host server is responsible for:
- **Execution**: Running guest programs and capturing execution traces in sessions and segments
- **Proving**: Generating zero-knowledge proofs for executed sessions using various proving backends
- **Session Management**: Tracking program execution state, assumptions, and cycle metrics

## Key Components

### Session & Segment Management (`session.rs`)
- **Session**: Complete execution trace of a program containing multiple segments
- **Segment**: Individual chunk of execution work proven separately
- **SegmentRef**: Reference implementations for storing segments (in-memory, file-based, null)

Key session data:
- Input/output digests and journal data
- Exit codes and system state transitions
- Assumption tracking for composable proofs
- Cycle metrics (user, paging, reserved, total)
- Syscall and ecall performance metrics

### Execution Engine (`exec/`)
- **Executor**: Main execution engine for running guest programs
- **Syscalls**: System call implementations (I/O, crypto, environment)
- **Profiler**: Performance profiling and debugging support
- **GDB Integration**: Debugging interface for guest programs

### Proving System (`prove/`)
- **ProverServer Trait**: Unified interface for different proving backends
- **ProverImpl**: Production prover using STARK/SNARK systems
- **DevModeProver**: Development mode with fake proofs for testing
- **Receipt Types**: Composite, Succinct, and Groth16 proof formats
- **Recursion**: Lift, join, resolve operations for proof composition

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌───────────────────┐
│   Guest ELF     │───▶│   Execution      │───▶│   Session         │
│   Binary        │    │   Engine         │    │   (Segments)      │
└─────────────────┘    └──────────────────┘    └───────────────────┘
                                                         │
                                                         ▼
┌─────────────────┐    ┌──────────────────┐    ┌───────────────────┐
│   Receipt       │◀───│   ProverServer   │◀───│   Segment         │
│   (ZK Proof)    │    │   Implementation │    │   References      │
└─────────────────┘    └──────────────────┘    └───────────────────┘
```

## Usage Patterns

### Basic Execution & Proving
```rust
// Execute guest program
let session = execute_guest_program(env, elf)?;

// Generate proof
let prover = get_prover_server(&opts)?;
let proof_info = prover.prove_session(&ctx, &session)?;
```

### Custom Proving Pipeline
```rust
// Prove individual segments
let segment_receipts: Vec<SegmentReceipt> = session.segments
    .iter()
    .map(|seg| prover.prove_segment(&ctx, &seg.resolve()?))
    .collect::<Result<Vec<_>>>()?;

// Compose into succinct receipt
let receipt = prover.composite_to_succinct(&composite_receipt)?;
```

## Performance & Monitoring

- **Cycle Tracking**: User, paging, and reserved cycle metrics
- **Syscall Profiling**: Performance breakdown by system call type
- **Memory Management**: Page fault tracking and optimization
- **Session Statistics**: Comprehensive execution and proving metrics

## Security Considerations

- All guest code runs in isolated execution environment
- Cryptographic assumptions tracked and verified
- Proof composition maintains security properties
- Multiple receipt formats support different trust models

## Integration Points

- **Client API**: Interfaces with host client for execution requests
- **Circuit Backend**: Integrates with RISC-V and recursion circuits
- **Storage**: Supports various segment storage strategies
- **Debugging**: GDB protocol support for guest program debugging