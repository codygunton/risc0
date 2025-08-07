# Field Component Documentation

## Overview

The field component implements finite field arithmetic for the RISC Zero zkVM architecture, specifically the Baby Bear field (`F_p` where `p = 15 * 2^27 + 1 = 2013265921`) and its degree-4 extension field.

## Key Components

### Core Traits

#### `Field` Trait
Defines a pair of fields where one is an extension of the other:
- `Elem`: Base field element type implementing `RootsOfUnity`
- `ExtElem`: Extension field element type

#### `Elem` Trait (`mod.rs:35-161`)
Core trait for finite field elements with:
- **Constants**: `INVALID`, `ZERO`, `ONE`, `WORDS`
- **Operations**: Arithmetic (`+`, `-`, `*`), multiplicative inverse (`inv`), exponentiation (`pow`)
- **Conversion**: `from_u64`, `to_u32_words`, `from_u32_words`
- **Validation**: `is_valid`, `is_reduced`, `valid_or_zero`
- **Memory Layout**: Support for bytemuck zero-copy serialization

#### `ExtElem` Trait (`mod.rs:168-219`)
Extension field elements supporting:
- Construction from base field elements
- Vector space representation over base field
- All `Elem` operations plus interop with base field

#### `RootsOfUnity` Trait (`mod.rs:223-238`)
Provides precomputed roots of unity for efficient NTT operations:
- `MAX_ROU_PO2`: Maximum power-of-2 root
- `ROU_FWD`/`ROU_REV`: Forward/reverse root arrays

### Baby Bear Implementation

#### Base Field (`Elem`)
**Modulus**: `P = 15 * 2^27 + 1 = 2013265921`
- 31-bit prime allowing 32-bit addition without overflow
- Montgomery form representation for efficient multiplication
- Maximum 27 powers of 2 in `P-1` for NTT support

**Key Features**:
- Montgomery multiplication with constants `M = 0x88000001`, `R2 = 1172168163`
- Optimized random sampling using 192-bit arithmetic mod P
- Comprehensive arithmetic operations with overflow protection

#### Extension Field (`ExtElem`)
**Structure**: 4-element vector over base field (`F_p^4`)
- Represented as `F_p[X] / (X^4 + 11)` where 11 is `BETA`
- Irreducible polynomial chosen for simplicity and efficiency
- ~128-bit security from large field size

**Operations**:
- Component-wise addition/subtraction
- Polynomial multiplication with reduction modulo `X^4 + 11`
- Composite field inversion using norm-based algorithm

## File Structure

```
field/
├── mod.rs           # Core traits and shared functionality
│   ├── Field trait
│   ├── Elem trait (35-161)
│   ├── ExtElem trait (168-219)
│   ├── RootsOfUnity trait (223-238)
│   ├── map_pow optimization (243-269)
│   └── Test utilities (271-411)
└── baby_bear.rs     # Baby Bear field implementation
    ├── BabyBear struct (33-38)
    ├── Elem implementation (64-161, 200-372)
    ├── ExtElem implementation (385-800)
    └── Comprehensive tests (802-956)
```

## Usage Patterns

### Basic Arithmetic
```rust
use risc0_core::field::baby_bear::{BabyBear, Elem, ExtElem};

let a = Elem::new(42);
let b = Elem::new(123);
let sum = a + b;
let product = a * b;
let inverse = a.inv();
```

### Extension Field Operations
```rust
let base = Elem::new(5);
let ext = ExtElem::from(base);
let random_ext = ExtElem::random(&mut rng);
let result = ext * random_ext + base;
```

### NTT Operations
```rust
// Access precomputed roots of unity
let forward_roots = Elem::ROU_FWD;
let reverse_roots = Elem::ROU_REV;
```

## Security Properties

1. **Field Choice**: 31-bit prime with maximal 2-power factor for NTT efficiency
2. **Montgomery Form**: Constant-time multiplication resistant to timing attacks
3. **Extension Field**: ~128-bit security for cryptographic operations
4. **Validation**: Comprehensive bounds checking and invalid element handling

## Performance Optimizations

1. **Montgomery Arithmetic**: Efficient modular multiplication
2. **Precomputed Roots**: Static arrays for NTT operations
3. **SIMD-Friendly Layout**: Aligned memory layout for vectorization
4. **Optimized Sampling**: 192-bit reduction for uniform random generation
5. **Hand-Optimized Multiplication**: Unrolled extension field multiplication

## Integration Points

- **ZKP Circuits**: Foundation for all circuit arithmetic
- **NTT Operations**: Roots of unity for fast polynomial operations  
- **Serialization**: Bytemuck support for zero-copy I/O
- **Testing**: Comprehensive property-based test suite

This field implementation provides the arithmetic foundation for RISC Zero's zero-knowledge proof system, balancing security, performance, and ease of use.