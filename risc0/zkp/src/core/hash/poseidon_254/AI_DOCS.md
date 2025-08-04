# Poseidon 254 Hash Component

## Overview

This component implements the Poseidon hash function optimized for SNARK-friendly cryptographic operations in the context of RISC Zero's zero-knowledge proof system. It operates on the BN254 elliptic curve's scalar field with 254-bit prime modulus and provides 127 bits of security.

## Architecture

### Core Components

#### Field Definition (`consts.rs:19-23`)
- **Prime Field**: BN254 scalar field with modulus `21888242871839275222246405745257275088548364400416034343698204186575808495617`
- **Generator**: 7
- **Representation**: Little-endian 4×64-bit limbs

#### Poseidon Parameters (`consts.rs:25-28`)
- **Cells**: 3 (state size)
- **Full Rounds**: 8 (4 at beginning + 4 at end)
- **Partial Rounds**: 42 (middle rounds)
- **Total Rounds**: 50
- **Alpha**: 8 (S-box exponent: x^8)

### Core Functions

#### Permutation Operations

**S-box Function** (`mod.rs:39-43`)
```rust
fn sbox(x: Fr) -> Fr {
    let x2 = x * x;    // x^2
    let x4 = x2 * x2;  // x^4
    x4 * x4            // x^8
}
```
- Implements x^8 S-box for non-linearity
- Applied to all cells in full rounds, only first cell in partial rounds

**MDS Matrix Multiplication** (`mod.rs:55-64`)
- Applies Maximum Distance Separable matrix for diffusion
- 3×3 matrix hardcoded in `consts.rs:185-195`
- Ensures optimal branch number for security

**Round Functions** (`mod.rs:66-76`)
- **Full Round**: Add constants → S-box all cells → MDS
- **Partial Round**: Add constants → S-box first cell only → MDS

#### Main Permutation (`mod.rs:78-92`)
```
Initial: [a, b, c]
├── 4 Full Rounds
├── 42 Partial Rounds  
└── 4 Full Rounds
Final: [hash, -, -]
```

### Hash Function Implementation

#### `Poseidon254HashFn` Struct (`mod.rs:95`)

**Pair Hashing** (`mod.rs:141-147`)
- Input: Two 32-byte digests
- Process: Place in cells[1] and cells[2], run permutation
- Output: cells[0] as digest

**Element Array Hashing** (`mod.rs:109-138`)
- Packs BabyBear elements (27-bit) efficiently into field elements
- Processes 8 elements per field element using base p = 15×2^27 + 1
- Supports variable-length inputs with proper padding

**Extension Element Hashing** (`mod.rs:153-157`)
- Flattens extension elements to base elements
- Uses same unpadded hash algorithm

### Random Number Generator

#### `Poseidon254Rng` Struct (`mod.rs:161-173`)

**State**: 3-cell sponge using same permutation

**Operations**:
- **Mix** (`mod.rs:175-178`): Add value to cells[1], permute
- **Extract Bits** (`mod.rs:180-192`): Extract specified bits from cells[2], permute
- **Extract Element** (`mod.rs:194-209`): Extract 160 bits as BabyBear element
- **Extract Extension** (`mod.rs:211-213`): Generate 4 base elements

### Public Interface

#### `Poseidon254HashSuite` (`mod.rs:225-236`)
- Factory for creating hash suite with Poseidon254 hash and RNG
- Integrates with RISC Zero's hash framework
- Name: "poseidon254"

## Security Properties

### Cryptographic Security
- **Preimage Resistance**: 254-bit security (full field size)
- **Collision Resistance**: 127-bit security (birthday bound)
- **Second Preimage**: 254-bit security

### SNARK Efficiency
- Low multiplicative complexity for zero-knowledge circuits
- S-box: x^8 requires only 3 multiplications (x^2, x^4, x^8)
- Optimized round structure balances security vs efficiency

### Round Security Analysis
- Full rounds provide global non-linearity
- Partial rounds maintain security with lower cost
- 42 partial rounds exceed security margin for 3-cell state

## Usage Patterns

### Direct Hash Operations
```rust
let hasher = Poseidon254HashFn{};
let digest = hasher.hash_elem_slice(&elements);
let pair_hash = hasher.hash_pair(&digest1, &digest2);
```

### RNG Operations
```rust
let mut rng = Poseidon254Rng::new();
rng.mix(&seed_digest);
let random_value = rng.random_elem();
```

### Hash Suite Integration
```rust
let suite = Poseidon254HashSuite::new_suite();
// Use with RISC Zero's proof system
```

## Performance Characteristics

### Circuit Costs (estimated)
- **Full Round**: ~15 constraints per cell (45 total)
- **Partial Round**: ~5 constraints (S-box on one cell)
- **Total per Hash**: ~650 constraints
- **Memory**: 3 field elements (96 bytes) working state

### Software Performance
- Optimized for 64-bit platforms
- Benefits from Montgomery arithmetic
- Parallel-friendly S-box operations

## Testing and Validation

### Test Vectors (`mod.rs:244-268`)
- Validates against known good outputs
- Tests hash function determinism
- Verifies RNG consistency
- Expected outputs:
  - `random_bits(7)`: 5
  - First `random_elem()`: 328085114
  - After mixing: 726238606

## Dependencies

### External Crates
- `ff`: Field arithmetic traits and macros
- `risc0_core::field`: BabyBear field implementation

### Internal Dependencies
- `super::{HashFn, HashSuite, Rng, RngFactory}`: Hash framework traits
- `crate::core::digest::Digest`: 32-byte digest type

## Constants Source

Parameters sourced from [IAIK Poseidon Reference](https://extgit.iaik.tugraz.at/krypto/hadeshash):
- File: `poseidon_params_n254_t3_alpha8_M128.txt`
- Optimized for 128-bit security, 3-cell state, alpha=8

## Integration Points

### RISC Zero Integration
- Primary hash function for BN254-based circuits
- Used in proof verification and generation
- Compatible with circuit constraint systems

### Field Compatibility
- Converts between BabyBear elements and BN254 field
- Handles both base and extension field elements
- Maintains security across field boundaries