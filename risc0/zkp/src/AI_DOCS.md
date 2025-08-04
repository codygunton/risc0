# ZKP Core Module

## Overview
This module contains the core zero-knowledge proof (ZK-STARK) algorithms for the RISC Zero proving system. It provides the fundamental cryptographic primitives and protocols for generating and verifying proofs of computation.

## Key Components

### Core Cryptography (`core/`)
- **Hashing**: Multiple hash function implementations including Poseidon2, Poseidon_254, SHA, and Blake2b
- **Polynomials**: Polynomial operations and Number Theoretic Transform (NTT) support
- **Field Operations**: Finite field arithmetic operations

### Hardware Abstraction Layer (`hal/`)
- Provides abstraction over different compute backends (CPU, CUDA, Metal)
- Enables acceleration through GPU computing when available
- Dual-mode operation for testing and verification

### Proving System (`prove/`)
- **FRI Protocol**: Fast Reed-Solomon Interactive Oracle Proofs
- **Merkle Trees**: Cryptographic commitment schemes
- **Polynomial Groups**: Efficient polynomial commitment and evaluation
- **Prover Logic**: Main proving algorithm implementation
- **Soundness Analysis**: Security parameter calculations

### Verification (`verify/`)
- **FRI Verification**: Verifies FRI proofs efficiently
- **Merkle Verification**: Validates Merkle tree commitments
- **Read IOP**: Interactive Oracle Proof reading interface

## Key Constants
- `MIN_CYCLES_PO2 = 13` (8K minimum cycles)
- `MAX_CYCLES_PO2 = 24` (16M maximum cycles)
- `QUERIES = 50` (FRI queries for 97-bit security)
- `ZK_CYCLES = 1024` (Zero-knowledge overhead)
- `INV_RATE = 4` (Reed-Solomon expansion rate)
- `FRI_FOLD = 16` (FRI folding factor)

## Security Properties
- Achieves 97 bits of conjectured security
- Uses zk-STARK protocol for zero-knowledge proofs
- Reed-Solomon codes for error correction and soundness
- Interactive Oracle Proofs (IOPs) for efficient verification

## Module Structure
- `adapter.rs`: Interface adapters for different backends
- `layout.rs`: Memory layout and circuit organization
- `merkle.rs`: Merkle tree implementations
- `taps.rs`: Constraint system taps and evaluations

## Feature Flags
- `prove`: Enables proving functionality (disabled in guest code)
- `std`: Standard library support
- `cuda`: CUDA GPU acceleration
- `metal`: Metal GPU acceleration (macOS)

## Dependencies
- `risc0_core::field`: Core field arithmetic operations
- External cryptographic libraries for hash functions
- GPU compute libraries when acceleration is enabled