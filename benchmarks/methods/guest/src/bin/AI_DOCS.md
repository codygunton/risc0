# RISC Zero Benchmark Guest Programs

## Overview

This directory contains the guest program implementations for RISC Zero's zkVM benchmarking suite. These programs are designed to measure the performance of various cryptographic operations, mathematical computations, and verification tasks when executed within the RISC Zero zero-knowledge virtual machine.

## Architecture

The guest programs in this directory are compiled to run inside the RISC Zero zkVM, where they:
1. Read input data using `risc0_zkvm::guest::env::read()`
2. Perform specific computational tasks (hashing, signature verification, etc.)
3. Commit results to the journal using `risc0_zkvm::guest::env::commit()`

Each program is designed as a standalone binary that can be executed independently for benchmarking purposes.

## Benchmark Categories

### Cryptographic Hash Functions

**Big Hash Benchmarks** (`big_*.rs`):
- `big_sha2.rs` - SHA2-256 hashing of large random buffers
- `big_keccak.rs` - Keccak hashing of large random buffers  
- `big_blake2b.rs` - Blake2b hashing of large random buffers
- `big_blake3.rs` - Blake3 hashing of large random buffers

**Iterative Hash Benchmarks** (`iter_*.rs`):
- `iter_sha2.rs` - Repeated SHA2-256 hashing iterations
- `iter_keccak.rs` - Repeated Keccak hashing iterations
- `iter_blake2b.rs` - Repeated Blake2b hashing iterations
- `iter_blake3.rs` - Repeated Blake3 hashing iterations
- `iter_pedersen.rs` - Repeated Pedersen hashing iterations

### Digital Signature Verification

- `ecdsa_verify.rs` - ECDSA signature verification on secp256k1 curve using k256 crate
- `ed25519_verify.rs` - Ed25519 signature verification using ed25519-dalek

### Mathematical Computations

- `fibonacci.rs` - Fibonacci sequence calculation using matrix exponentiation with nalgebra

### Cryptographic Proofs and Verification

- `membership.rs` - Merkle tree membership proof verification using SHA2-256
- `sudoku.rs` - Sudoku puzzle solution validation

## Key Dependencies

- `risc0_zkvm` - Core zkVM runtime and guest environment
- `risc0_benchmark_lib` - Shared data structures and utilities
- Cryptographic libraries: `k256`, `ed25519-dalek`, `sha2`, `keccak`, `blake2`, `blake3`
- Mathematical libraries: `nalgebra` for matrix operations

## Performance Characteristics

These benchmarks are designed to stress test different aspects of zkVM execution:

- **Memory intensity**: Big hash functions test large data processing
- **Computational intensity**: Iterative functions test repeated operations
- **Cryptographic operations**: Signature verification tests elliptic curve operations
- **Algorithm complexity**: Sudoku and membership proofs test logical operations

## Usage Context

These guest programs are invoked by the benchmark host code located in the parent `risc0-benchmark` crate, which:
- Generates appropriate test inputs
- Measures execution time and resource usage
- Compares performance across different proving backends (CPU, Metal, CUDA)
- Generates reports for performance analysis

## Security Model

All programs follow RISC Zero's security model:
- Input validation where appropriate (e.g., sudoku solution verification)
- Deterministic execution for reproducible benchmarks
- Commitment of results to the journal for verification
- No external dependencies that could compromise determinism

This benchmark suite serves as both a performance testing framework and a demonstration of various computational patterns that can be efficiently proven using RISC Zero's zkVM technology.