# RISC0 Circuit Recursion Prover Component

This component implements the proving functionality for RISC0's recursion circuit, which enables proof composition and recursive proof verification within the RISC0 zkVM ecosystem.

## Overview

The recursion prover is a specialized virtual machine with limited instruction sets designed to execute recursion programs like lift and join operations. It operates on a write-once memory tape and generates zero-knowledge proofs for recursion circuit execution.

## Core Components

### Main Prover (`mod.rs`)
- **`Prover`**: Main interface for recursion proving with input management and proof generation
- **`RecursionReceipt`**: Contains the seal (proof) and output data from recursion execution  
- **`RecursionProver` trait**: Abstraction for different hardware backends (CPU, CUDA)
- **`recursion_prover()`**: Factory function to create appropriate prover implementation based on available features

### Program Management (`program.rs`)
- **`Program`**: Contains encoded recursion circuit code and execution parameters
- **Control ID computation**: Uses FRI Merkle root to uniquely identify recursion programs
- **Code layout management**: Handles program code organization in circuit columns

### Witness Generation (`witgen.rs`)
- **`WitnessGenerator`**: Creates witness data for the recursion circuit
- **Buffer management**: Handles control, data, accumulator, and global buffers
- **Noise addition**: Adds randomness to unused circuit cycles for zero-knowledge properties
- **Parallelized witness generation**: Supports parallel witness computation for performance

### Preflight Execution (`preflight.rs`)
- **`Preflight`**: Executes recursion programs to generate execution traces
- **Instruction processing**: Handles macro operations, micro operations, hash functions, and byte checking
- **State management**: Maintains Poseidon2 and SHA-256 hash states
- **Memory simulation**: Implements write-once memory (WOM) semantics

### Hardware Abstraction Layer (`hal/`)
- **CPU implementation**: Reference implementation for CPU-based proving
- **CUDA support**: GPU-accelerated proving when available
- **`CircuitWitnessGenerator`**: Interface for witness generation across backends
- **`CircuitAccumulator`**: Interface for accumulation phase across backends

### ZKR Program Loading (`zkr.rs`)
- **Program loading**: Extracts recursion programs from embedded ZIP archives
- **Format handling**: Manages binary program format and encoding
- **Program catalog**: Provides access to all available recursion programs

## Key Features

### Cryptographic Operations
- **Poseidon2 hashing**: Native support for Poseidon2 hash function operations
- **SHA-256 hashing**: Support for SHA-256 hash computations within recursion
- **Field arithmetic**: Baby Bear field operations with Montgomery form support
- **Polynomial operations**: FRI polynomial commitments and evaluations

### Memory Management
- **Write-once memory**: Ensures memory locations can only be written once
- **Buffer organization**: Separates control, data, accumulator and global state
- **Address management**: Handles memory addressing and bounds checking

### Proof Generation
- **Multi-phase proving**: Implements commit-challenge-response protocol
- **Fiat-Shamir transformation**: Uses transcript for non-interactive proofs
- **Circuit-specific optimizations**: Leverages recursion circuit structure
- **Hardware acceleration**: Supports both CPU and GPU proving backends

## Usage Patterns

The recursion prover is typically used to:
1. **Proof composition**: Combine multiple proofs into a single proof
2. **Proof aggregation**: Aggregate many proofs for batch verification
3. **Recursive verification**: Verify proofs within the zkVM itself
4. **Circuit lifting**: Convert proofs between different circuit formats

## Integration Points

- **RISC0 zkVM**: Used for recursive proof verification within the zkVM
- **Circuit system**: Integrates with the broader RISC0 circuit infrastructure
- **Hash functions**: Supports multiple hash functions for different proof systems
- **Hardware backends**: Abstracts over CPU and GPU implementations

## Performance Considerations

- **Parallel execution**: Supports parallel witness generation
- **Memory optimization**: Uses buffer pooling and efficient memory layouts
- **Hardware acceleration**: Leverages GPU when available for compute-intensive operations
- **Caching**: Caches evaluation points and other frequently used values