# Keccak Circuit Prover Component

## Overview

This directory contains the proving system for Keccak hash function verification within the RISC Zero zero-knowledge proof system. The component provides a complete proving stack that can generate cryptographic proofs for Keccak computations, supporting both CPU and CUDA execution backends.

## Architecture

### Core Components

- **`mod.rs`**: Main prover interface and orchestration
  - Defines `KeccakProver` trait for proof generation and verification
  - Implements `KeccakProverImpl` with hardware abstraction layer (HAL) support
  - Provides factory function `keccak_prover()` for backend selection
  - Handles proof system initialization and Fiat-Shamir transcript management

- **`preflight.rs`**: Execution trace preprocessing and witness generation
  - Implements `PreflightTrace` for organizing computation cycles
  - Handles SHA-256 and Keccak state transformations
  - Manages control flow state machine with cycle types (Read, Expand, Keccak0-4, Write, etc.)
  - Generates scatter information for efficient memory layout

- **`zkr.rs`**: Zero-knowledge record (ZKR) file management
  - Loads compressed recursion programs for different proof sizes
  - Handles XZ decompression of precompiled circuit programs
  - Maps power-of-2 sizes to appropriate ZKR files

- **`testutil.rs`**: Testing utilities and evaluation framework
  - Provides `EvalCheckParams` for circuit validation
  - Implements cross-backend evaluation consistency checking
  - Generates deterministic test inputs for various proof sizes

### Hardware Abstraction Layer (HAL)

- **`hal/mod.rs`**: Common HAL interfaces and abstractions
  - Defines `MetaBuffer` for memory management across backends
  - Specifies `CircuitWitnessGenerator` trait for witness computation
  - Supports different execution modes (Parallel, Sequential Forward/Reverse)

- **`hal/cpu.rs`**: CPU backend implementation
- **`hal/cuda.rs`**: GPU/CUDA backend implementation (feature-gated)

## Key Data Structures

### KeccakState
- 25-element array of u64 values representing Keccak sponge state
- Used throughout the computation pipeline for state tracking

### Seal
- `Vec<u32>` containing the final cryptographic proof
- Verifiable using the `verify()` method with Poseidon2 hash suite

### PreflightTrace
- Organizes computation into cycles with associated control states
- Contains preimages, witness data, and memory scatter information
- Supports different cycle ordering strategies via `PreflightCycleOrder` trait

## Proving Process

1. **Initialization**: Set up global parameters and circuit state
2. **Preflight**: Generate execution trace with all intermediate states
3. **Witness Generation**: Populate circuit registers using HAL backend
4. **Proof Generation**: Run the proving algorithm with Fiat-Shamir transcript
5. **Verification**: Validate proof using Poseidon2 hash verification

## Backend Selection

The system automatically selects the appropriate backend:
- CUDA backend when `cuda` feature is enabled
- CPU backend as fallback
- Future Metal backend support planned for Apple platforms

## Integration Points

- Integrates with `risc0_zkp` for core proving primitives
- Uses `risc0_circuit_keccak_sys` for system-level scatter operations  
- Connects to zirgen-generated circuit definitions in `../zirgen/`
- Supports recursion through ZKR program loading

## Usage Patterns

```rust
// Create prover instance
let prover = keccak_prover()?;

// Generate proof for Keccak states
let inputs = vec![keccak_state]; // KeccakState inputs
let po2 = 14; // Power of 2 for circuit size
let seal = prover.prove(&inputs, po2)?;

// Verify the proof
prover.verify(&seal)?;
```

## Performance Considerations

- Circuit size determined by `po2` parameter (power of 2)
- Supports parallel witness generation for improved performance
- Memory-efficient scatter/gather operations for large traces
- ZKR caching reduces compilation overhead for repeated proofs

## Security Properties

- Uses Poseidon2 hash suite for cryptographic security
- Implements proper Fiat-Shamir transcript construction
- Includes circuit info commitment for proof system binding
- Supports checked memory reads for additional validation