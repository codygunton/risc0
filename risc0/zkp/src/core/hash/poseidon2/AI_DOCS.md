# Poseidon2 Hash Implementation

## Overview

This module implements the Poseidon2 cryptographic hash function optimized for the Baby Bear finite field. Poseidon2 is a zero-knowledge-friendly hash function designed for efficient use in SNARK/STARK proof systems.

## Key Components

### Core Files

- **`mod.rs`** - Main implementation with hash functions and mixing operations
- **`consts.rs`** - Constants including round constants and matrix parameters
- **`rng.rs`** - Poseidon2-based random number generator for Fiat-Shamir

### Constants

- `CELLS = 24` - Width of the Poseidon2 state (24 field elements)
- `CELLS_RATE = 16` - Sponge rate (safe input/output per mixing)
- `CELLS_OUT = 8` - Hash output size (~248 bits)
- `ROUNDS_HALF_FULL = 4` - Full S-box rounds (first and last)
- `ROUNDS_PARTIAL = 21` - Partial S-box rounds (middle)

## Core Functions

### Hash Functions

- **`hash_pair(a, b)`** - Hashes two digests together
- **`hash_elem_slice(slice)`** - Hashes a slice of Baby Bear elements
- **`hash_ext_elem_slice(slice)`** - Hashes extension field elements
- **`unpadded_hash(iter)`** - Low-level unpadded hash (collision-resistant for same-size inputs)

### Mixing Operations

- **`poseidon2_mix(cells)`** - Core sponge mixing function implementing the Poseidon2 permutation
- **`full_round(cells, round)`** - Full round with S-box applied to all cells
- **`partial_round(cells, round)`** - Partial round with S-box applied to first cell only

### Matrix Operations

- **`multiply_by_m_ext(cells)`** - External matrix multiplication (optimized with 4x4 circulant)
- **`multiply_by_m_int(cells)`** - Internal matrix multiplication (diagonal + ones)
- **`multiply_by_4x4_circulant(x)`** - Efficient 4x4 circulant matrix multiplication

## Security Features

- **S-box**: x^7 power function for nonlinearity
- **Round Constants**: Cryptographically secure constants for each round
- **Matrix Design**: Optimized external and internal matrices for security and efficiency
- **Sponge Construction**: Secure absorption and squeezing phases

## Usage

The module provides a complete hash suite through `Poseidon2HashSuite::new_suite()` which includes:
- Hash function implementation
- Random number generator factory
- Consistent API for zero-knowledge applications

## Performance Optimizations

- **Optimized Matrix Multiplication**: Uses diagonal structure and circulant decomposition
- **Efficient S-box**: Single x^7 computation
- **Batch Processing**: Processes multiple elements efficiently in sponge mode
- **Montgomery Form**: Field elements stored in Montgomery representation

## Test Coverage

Comprehensive tests include:
- Comparison with naive implementation
- Golden test vectors for hash outputs
- Cross-verification with reference implementations
- Edge cases for aligned and unaligned inputs

## Dependencies

- `risc0_core::field::baby_bear` - Baby Bear field arithmetic
- Standard library collections for data structures
- Test framework for verification

This implementation is optimized for zero-knowledge proof systems where hash function efficiency is critical for proving performance.