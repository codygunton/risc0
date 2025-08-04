# SHA-256 Hash Implementation

## Overview
This component provides SHA-256 cryptographic hash implementations for the RISC Zero ZKP system. It includes both CPU-based and zero-knowledge virtual machine (zkVM) guest implementations, along with compatibility wrappers for the Rust Crypto ecosystem.

## Architecture

### Core Components

#### `mod.rs` - Main Interface
- **`Sha256` trait**: Core interface defining SHA-256 operations
  - `hash_bytes()`: Standard SHA-256 with padding and trailer
  - `hash_words()`: Hash from word arrays
  - `hash_pair()`: Hash two digests using compression function
  - `compress()`: Low-level SHA-256 compression function
  - `compress_slice()`: Compress multiple blocks
  - `hash_raw_data_slice()`: Hash without standard padding

- **`Block` struct**: 512-bit input blocks for SHA-256
  - Size: 64 bytes (16 words)
  - Provides conversion methods and accessor functions
  - Supports alignment-aware operations

- **Constants**:
  - `SHA256_INIT`: Standard SHA-256 initialization vector
  - `BLOCK_WORDS`: 16 (words per block)
  - `BLOCK_BYTES`: 64 (bytes per block)

#### `cpu.rs` - Host Implementation
CPU-based SHA-256 implementation using the `sha2` crate:
- Uses standard `sha2::Sha256` for basic operations
- Implements compression function via `sha2::compress256`
- Handles byte/word alignment and endianness conversion
- Returns `Box<Digest>` for memory management

#### `guest.rs` - zkVM Implementation
Zero-knowledge VM guest implementation:
- Uses system calls (`sys_sha_compress`, `sys_sha_buffer`) for operations
- Implements custom padding logic with trailer support
- Memory management through direct allocation
- Returns `&'static mut Digest` pointers
- Optimized for alignment and block-level processing

#### `rust_crypto.rs` - Compatibility Layer
Rust Crypto ecosystem compatibility:
- `Sha256VarCore`: Variable output core implementation
- Implements standard `digest` traits
- Block-level processing with alignment optimization
- Compatible with `digest::Digest` interface

#### `rng.rs` - Cryptographic RNG
SHA-256 based cryptographically secure random number generator:
- Two-pool design for security
- Implements `RngCore` trait from `rand_core`
- Fiat-Shamir transform support
- Field element generation for cryptographic operations

## Implementation Details

### Platform Selection
The module automatically selects the appropriate implementation:
```rust
cfg_if::cfg_if! {
    if #[cfg(target_os = "zkvm")] {
        pub use crate::core::hash::sha::guest::Impl;
    } else {
        pub use crate::core::hash::sha::cpu::Impl;
    }
}
```

### Memory Management
- **CPU**: Uses `Box<Digest>` for heap allocation
- **Guest**: Uses raw pointers with custom allocation for zkVM constraints

### Performance Optimizations
- Alignment-aware block processing
- Zero-copy operations when alignment permits
- Efficient endianness handling
- Block-level system calls in guest environment

## Key Functions

### Hash Operations
- `hash_bytes()`: Standard compliant SHA-256 hash
- `hash_words()`: Word-aligned input hashing
- `hash_pair()`: Merkle tree node hashing

### Low-level Operations
- `compress()`: Single block compression
- `compress_slice()`: Multi-block compression
- `hash_raw_data_slice()`: Non-standard padding

## Usage Patterns

### Basic Hashing
```rust
let digest = Impl::hash_bytes(b"hello world");
```

### Merkle Tree Construction
```rust
let parent = Impl::hash_pair(&left_child, &right_child);
```

### Raw Data Processing
```rust
let hash = Impl::hash_raw_data_slice(&data_slice);
```

## Testing
Comprehensive test suite includes:
- Standard SHA-256 test vectors
- Cross-implementation consistency
- Alignment and endianness edge cases
- Random number generator conformance
- Rust Crypto compatibility

## Dependencies
- `sha2`: Standard SHA-256 implementation
- `bytemuck`: Safe byte/type casting
- `digest`: Rust Crypto traits
- `risc0_zkvm_platform`: zkVM system calls
- `rand_core`: RNG traits

This component is critical for cryptographic operations in the RISC Zero proof system, providing both performance and security guarantees across different execution environments.