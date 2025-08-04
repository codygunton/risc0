# BigInt2 Guest Methods - AI Documentation

## Overview

This directory contains guest method implementations for RISC Zero's BigInt2 accelerator, providing optimized cryptographic and mathematical operations that run inside the zkVM. These are the guest programs that execute the actual computations using hardware-accelerated big integer operations.

## Directory Structure

```
/home/cody/risc0/risc0/bigint2/methods/guest/src/bin/
├── Cargo.toml                    # Guest methods package configuration
├── build.rs                     # Build script for generating test data
└── src/bin/                     # Individual guest method executables
    ├── ec_*.rs                  # Elliptic curve operations
    ├── extfield_*.rs            # Extension field operations  
    ├── mod*.rs                  # Modular arithmetic operations
    ├── ecdsa.rs                 # ECDSA signature verification
    ├── rsa.rs                   # RSA operations
    └── raw_test.rs              # Raw testing utilities
```

## Component Purpose

This component provides **guest methods** - programs that run inside the RISC Zero zkVM to perform hardware-accelerated cryptographic operations. The key purposes are:

1. **Cryptographic Verification**: ECDSA and RSA signature verification within zero-knowledge proofs
2. **Modular Arithmetic**: Optimized big integer operations (addition, multiplication, inversion, subtraction)
3. **Elliptic Curve Operations**: Point operations on secp256k1 and secp384r1 curves
4. **Extension Field Arithmetic**: Operations on extension fields for advanced cryptographic protocols

## Key Components

### Modular Arithmetic Operations
- **`modmul_256.rs`/`modmul_384.rs`**: Modular multiplication for 256-bit and 384-bit integers
- **`modadd_256.rs`/`modadd_384.rs`**: Modular addition operations
- **`modsub_256.rs`/`modsub_384.rs`**: Modular subtraction operations  
- **`modinv_256.rs`/`modinv_384.rs`**: Modular inverse computation

### Elliptic Curve Operations
- **`ec_add_256.rs`**: Point addition on 256-bit elliptic curves
- **`ec_double_256.rs`**: Point doubling on 256-bit elliptic curves
- **`ec_mul_256.rs`**: Scalar multiplication on 256-bit elliptic curves
- **`ec_384.rs`**: Operations on 384-bit elliptic curves

### Extension Field Operations
- **`extfield_deg2_*.rs`**: Degree-2 extension field operations (add, subtract, multiply)
- **`extfield_deg4_mul.rs`**: Degree-4 extension field multiplication
- **`extfield_xxone_mul_*.rs`**: Specialized multiplication operations

### Cryptographic Protocols
- **`ecdsa.rs`**: ECDSA signature verification using k256 library
- **`rsa.rs`**: RSA operations with 65537 exponent (common public exponent)

## Technical Architecture

### Guest Method Pattern
All guest methods follow a consistent pattern:
```rust
fn main() {
    // 1. Read input from zkVM environment
    let input: InputType = env::read();
    
    // 2. Convert to internal format
    let data = input.to_u32_array();
    
    // 3. Call accelerated operation
    risc0_bigint2::operation(&data, &mut result);
    
    // 4. Commit result back to zkVM
    env::commit(&result);
}
```

### BigInt Integration
- Uses `num-bigint` or `num-bigint-dig` for high-level big integer operations
- Implements `ToBigInt2Buffer` trait for efficient conversion to internal u32 arrays
- Supports both 256-bit and 384-bit operations with compile-time width selection

### Hardware Acceleration
- Methods are compiled as separate zkVM guest programs
- Each method targets specific hardware acceleration features in the RISC Zero zkVM
- Operations are optimized for zero-knowledge proof generation

## Key Files Analysis

### `ecdsa.rs` (Line 18-31)
```rust
use k256::ecdsa::{signature::Verifier as _, Signature, VerifyingKey};

fn main() {
    let vk = VerifyingKey::from_sec1_bytes(&VERIFYING_KEY[..]).unwrap();
    for (sig, payload) in SIGNATURES.iter().zip(PAYLOADS.iter()) {
        let sig = Signature::from_bytes(sig.into()).unwrap();
        core::hint::black_box(vk.verify(&payload[..], &sig)).unwrap();
    }
}
```
- Verifies multiple ECDSA signatures in batch
- Uses secp256k1 curve via k256 library
- Test data generated at build time

### `modmul_256.rs` (Line 22-37)
```rust
fn main() {
    let (lhs, rhs, modulus): (BigUint, BigUint, BigUint) = env::read();
    let lhs = lhs.to_u32_array();
    let rhs = rhs.to_u32_array();
    let modulus = modulus.to_u32_array();

    let mut result = [0u32; risc0_bigint2::field::FIELD_256_WIDTH_WORDS];
    risc0_bigint2::field::modmul_256(&lhs, &rhs, &modulus, &mut result);

    let result = BigUint::from_slice(&result);
    env::commit(&result);
}
```
- Performs modular multiplication: `(lhs * rhs) mod modulus`
- Uses 256-bit fixed-width operations
- Direct hardware acceleration via `risc0_bigint2::field`

## Dependencies

### Core Dependencies
- **`risc0-zkvm`**: RISC Zero zkVM runtime and guest environment
- **`risc0-bigint2`**: Big integer acceleration library (parent crate)
- **`k256`**: secp256k1 elliptic curve operations
- **`num-bigint`/`num-bigint-dig`**: High-level big integer arithmetic

### Build Dependencies
- **`k256`**: Used in build script for generating test vectors
- Custom patches for RISC Zero compatibility via Git dependencies

## Usage Patterns

### From Host Code
```rust
// Host code executes guest method
let (receipt, output) = prover.prove(&ELF, &input)?;

// Verify the computation was done correctly
receipt.verify(&METHOD_ID)?;
```

### Input/Output Format
- **Input**: Serialized via `env::read()` from host
- **Output**: Committed via `env::commit()` to receipt
- **Data Types**: Typically `BigUint` or tuples of `BigUint`

## Security Considerations

### Cryptographic Security
- All operations are constant-time to prevent side-channel attacks
- Uses well-established cryptographic libraries (k256, num-bigint)
- Hardware acceleration maintains cryptographic correctness

### zkVM Security
- Methods run in isolated zkVM environment
- All computations are verifiable via zero-knowledge proofs
- No direct access to host system resources

## Performance Characteristics

### Acceleration Benefits
- **10-100x** speedup over pure software implementations
- Hardware-optimized for common cryptographic operations
- Batch processing support for multiple operations

### Memory Usage
- Fixed-width arrays minimize memory allocation
- Compile-time width selection (256-bit, 384-bit, 4096-bit)
- Efficient conversion between BigUint and internal formats

## Integration Points

### Parent Library Integration
- Methods call operations from `risc0_bigint2::field`, `risc0_bigint2::ec`, `risc0_bigint2::rsa`
- Shared constants and utilities from parent crate
- Consistent error handling and validation

### Build System Integration
- Generated via `risc0-build` in parent `build.rs`
- Automatic ELF generation for zkVM execution
- Feature flag coordination with parent crate

## Testing Strategy

### Unit Testing
- Each method includes basic functionality tests
- Test vectors generated at build time
- Integration with parent crate test suite

### Verification Testing
- All operations verified against reference implementations
- Cryptographic correctness validated
- Performance benchmarks included

This component is essential for providing high-performance cryptographic operations within RISC Zero's zero-knowledge virtual machine, enabling efficient verification of complex cryptographic protocols.