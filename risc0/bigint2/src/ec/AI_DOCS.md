# RISC0 BigInt2 Elliptic Curve Component

## Overview

This component provides elliptic curve cryptography operations for the RISC0 BigInt2 library. It implements efficient elliptic curve point arithmetic for cryptographic curves using precompiled operations in the RISC0 zkVM.

## Architecture

The component is organized into several key modules:

- **`mod.rs`** - Core elliptic curve types and operations
- **`secp256k1.rs`** - secp256k1 curve implementation  
- **`secp384r1.rs`** - secp384r1 curve implementation
- **`tests.rs`** - Comprehensive test suite
- **Binary blobs** - Precompiled curve operations (`.blob` files)

## Core Types

### `WeierstrassCurve<WIDTH>`
Generic elliptic curve in short Weierstrass form `y² = x³ + ax + b`:
- Supports curves up to 384 bits (12 × 32-bit words)
- Stores prime field, coefficient `a`, and coefficient `b`
- Parameterized by `WIDTH` (number of 32-bit words)

### `AffinePoint<WIDTH, C>`
Affine point representation on an elliptic curve:
- Stores (x, y) coordinates as 32-bit word arrays
- Handles point-at-infinity via `identity` flag
- Type-safe curve association via phantom type `C`

### `Curve` Trait
Trait for static curve configurations:
- Associates curve parameters with a type
- Enables compile-time curve validation

## Supported Curves

### secp256k1 (`Secp256k1Curve`)
- **Width**: 8 words (256 bits)
- **Prime**: 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
- **Parameters**: a=0, b=7
- **Use case**: Bitcoin, Ethereum

### secp384r1 (`Secp384r1Curve`) 
- **Width**: 12 words (384 bits)
- **Prime**: 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFF0000000000000000FFFFFFFF
- **Parameters**: a=-3, b=complex coefficient
- **Use case**: NIST P-384, high-security applications

## Key Operations

### Point Addition (`add`)
- Adds two elliptic curve points: P + Q = R
- Handles special cases (identity elements, point negation)
- Uses precompiled operations for performance
- Validates results are within field bounds

### Point Doubling (`double`)
- Computes 2P efficiently using tangent line method
- Optimized for repeated doubling in scalar multiplication
- Handles edge cases (y=0, identity point)

### Scalar Multiplication (`mul`)
- Computes k×P using double-and-add algorithm
- Core operation for ECDSA, ECDH protocols
- Implements sliding window optimization
- Constant-time execution considerations

## Performance Features

### Precompiled Operations
- Uses binary blobs (`.blob` files) for core field arithmetic
- Optimized implementations for 256-bit and 384-bit operations
- System calls to RISC0 zkVM for hardware acceleration

### Memory Management
- Efficient buffer reuse to minimize allocations
- In-place operations where possible
- Careful handling of intermediate values

## Security Considerations

### Field Validation
- All results validated to be within field bounds
- Protection against malicious host providing invalid points
- Assertions ensure cryptographic correctness

### Side-Channel Resistance
- Constant-time bit scanning in scalar multiplication
- Uniform handling of special cases
- Minimal branching on secret data

## Usage Example

```rust
use risc0_bigint2::ec::{AffinePoint, Secp256k1Curve};

// Create points
let p1 = AffinePoint::<8, Secp256k1Curve>::new_unchecked([...], [...]);
let p2 = AffinePoint::<8, Secp256k1Curve>::new_unchecked([...], [...]);

// Point addition
let mut result = AffinePoint::IDENTITY;
p1.add(&p2, &mut result);

// Scalar multiplication
let scalar = [...];
p1.mul(&scalar, &mut result);
```

## Implementation Details

### Bit Manipulation
- **`bit()`** - Tests if specific bit is set in scalar
- **`bits()`** - Finds minimum bits needed to represent scalar
- Little-endian word ordering throughout

### Raw Operations
- **`add_raw()`** - Low-level point addition via system calls
- **`double_raw()`** - Low-level point doubling via system calls
- Direct interface to precompiled operations

### Error Handling
- Panics on unsupported bit widths (>384 bits)
- Assertions for field bound violations
- Clear error messages for debugging

## Testing

Comprehensive test suite covers:
- Basic arithmetic operations (add, double, multiply)
- Edge cases (identity elements, point negation)
- Cross-validation with known test vectors
- Performance benchmarking
- Both 256-bit and 384-bit curve operations

## Dependencies

- `include_bytes_aligned` - Aligned blob inclusion
- `risc0_bigint2_methods` - Precompiled method binaries
- `risc0_zkvm` - RISC0 zkVM system interface
- Parent `ffi` module - Foreign function interface

## Future Enhancements

- Support for additional curves (P-256, Curve25519)
- Projective coordinate representations
- Batch operation optimizations
- Hardware acceleration hooks