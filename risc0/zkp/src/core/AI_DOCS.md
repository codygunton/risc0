# ZKP Core Module

## Overview

The ZKP core module provides the fundamental cryptographic primitives and mathematical operations that underpin RISC Zero's zero-knowledge proof system. It implements essential components including hash functions, polynomial arithmetic, number-theoretic transforms (NTT), and digest management, forming the mathematical foundation for both proof generation and verification.

## Architecture

### Core Design Principles

- **Modular Cryptography**: Pluggable hash functions with consistent interfaces
- **Hardware Acceleration**: Optimized implementations for GPU and specialized hardware
- **Constant-Time Operations**: Cryptographic operations resistant to timing attacks
- **Field Arithmetic**: Efficient operations in finite fields for ZK computations
- **Memory Efficiency**: Optimized data structures for large polynomial operations

### Main Components

#### Digest Management (`digest.rs`)
Universal 256-bit digest representation used throughout the system:

```rust
#[repr(transparent)]
pub struct Digest([u32; DIGEST_WORDS]);

pub const DIGEST_WORDS: usize = 8;
pub const DIGEST_BYTES: usize = DIGEST_WORDS * WORD_SIZE;
```

**Key Features:**
- **Fixed Size**: Always 256 bits (8 x 32-bit words)
- **Cross-Hash Compatibility**: Uniform interface across different hash functions
- **Efficient Storage**: Word-aligned for zkVM optimization
- **Type Safety**: Strong typing prevents digest confusion
- **Serialization**: Support for various encoding formats

**Core Operations:**
- Construction from bytes/words with endianness handling
- Conversion to/from hex strings
- Comparison and ordering for Merkle trees
- Zero-copy byte/word access

#### Hash Function Suite (`hash/`)
Comprehensive cryptographic hash implementations:

**SHA-256 (`sha/`)**
- Standard SHA-256 with multiple backends
- CPU, GPU, and guest implementations
- Optimized for Merkle tree construction
- Hardware acceleration support

**Poseidon2 (`poseidon2/`)**
- Algebraic hash function optimized for ZK circuits
- Designed for efficient in-circuit verification
- Sponge construction with configurable parameters
- Native field element operations

**Poseidon-254 (`poseidon_254/`)**
- Variant optimized for 254-bit prime fields
- Used in Groth16 proof composition
- Efficient scalar field hashing

**Blake2b (`blake2b.rs`)**
- High-performance cryptographic hash
- Variable output length support
- Used for non-circuit hashing needs

#### Number Theoretic Transform (`ntt.rs`)
Fast polynomial multiplication in finite fields:

```rust
pub trait Ntt {
    fn evaluate_ntt(&self, coeffs: &mut [Self], count: usize);
    fn interpolate_ntt(&self, coeffs: &mut [Self], count: usize);
}
```

**Key Algorithms:**
- **Cooley-Tukey FFT**: Recursive decimation-in-time
- **Bit-Reversal**: Efficient coefficient reordering
- **Twiddle Factors**: Precomputed roots of unity
- **In-Place Operation**: Memory-efficient transforms

**Applications:**
- Polynomial multiplication for proof generation
- Reed-Solomon encoding/decoding
- Fast polynomial evaluation/interpolation

#### Polynomial Arithmetic (`poly.rs`)
Core polynomial operations over finite fields:

**Polynomial Representations:**
- **Coefficient Form**: Standard polynomial representation
- **Evaluation Form**: Values at specific points
- **Sparse Polynomials**: Optimized for few non-zero terms

**Core Operations:**
- Addition, subtraction, multiplication
- Division with remainder
- Multi-point evaluation
- Lagrange interpolation
- Polynomial commitment schemes

### Mathematical Foundations

#### Field Arithmetic
All operations occur in finite fields with specific properties:
- **Baby Bear Field**: Primary field with p = 2^31 - 2^27 + 1
- **Extension Fields**: Quadratic and quartic extensions
- **Montgomery Form**: Efficient modular arithmetic

#### Hash Function Design

**SHA-256 Properties:**
- Collision resistance for Merkle trees
- Standard cryptographic security
- Hardware acceleration availability

**Poseidon2 Properties:**
- Algebraic structure for efficient proving
- Optimized round constants
- Minimal multiplicative complexity

### Integration Architecture

The core module integrates with:

1. **Proof System** (`risc0_zkp::prove`)
   - Provides hash functions for Fiat-Shamir
   - NTT for polynomial operations
   - Digest management for commitments

2. **Verification** (`risc0_zkp::verify`)
   - Hash verification primitives
   - Polynomial evaluation checks
   - Merkle proof verification

3. **HAL Layer** (`risc0_zkp::hal`)
   - Hardware-specific implementations
   - GPU acceleration interfaces
   - Platform optimization

### Performance Optimizations

#### Memory Layout
- **Cache-Friendly**: Data structures optimized for CPU cache
- **Alignment**: Proper alignment for SIMD operations
- **Zero-Copy**: Minimal data movement between operations

#### Algorithmic Optimizations
- **Batch Operations**: Process multiple elements together
- **Precomputation**: Twiddle factors and constants
- **Parallelization**: Thread-safe operations for concurrency

#### Hardware Acceleration
- **GPU Support**: CUDA/Metal implementations
- **SIMD Instructions**: AVX2/AVX512 optimizations
- **Custom Hardware**: FPGA/ASIC considerations

### Security Considerations

- **Constant Time**: No data-dependent branches in crypto code
- **Side Channels**: Protection against timing/power analysis
- **Randomness**: Secure RNG integration for nonces
- **Parameter Selection**: Cryptographically secure constants

### Utility Functions

```rust
pub fn to_po2(x: usize) -> usize;      // Find power of 2
pub fn log2_ceil(value: usize) -> usize; // Ceiling log base 2
```

These utilities support:
- Polynomial size calculations
- NTT parameter determination
- Memory allocation sizing

### Usage Patterns

**Creating Digests:**
```rust
let digest = Digest::from(&data[..]);
let hex_digest = digest.to_hex();
```

**Hash Function Selection:**
```rust
use risc0_zkp::core::hash::{sha::Sha256, HashFn};
let hasher = Sha256::new();
let digest = hasher.hash_bytes(&data);
```

**Polynomial Operations:**
```rust
let mut coeffs = vec![field_elem; size];
ntt.evaluate_ntt(&mut coeffs, size);
```

### Design Rationale

- **Modularity**: Easy to add new hash functions
- **Performance**: Optimized for proof generation workloads
- **Compatibility**: Standard interfaces across implementations
- **Flexibility**: Support various proof system requirements