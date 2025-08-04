# ZKP Prove Module

## Overview

The `risc0_zkp::prove` module implements the core cryptographic algorithms for generating zero-knowledge proofs of computation in the RISC Zero system. This is a STARK (Scalable Transparent ARgument of Knowledge) proof system implementation that proves the correct execution of RISC-V programs without revealing computation details.

## Key Components

### Core Files

- **`prover.rs`** - Main STARK proving algorithm orchestrator with `Prover<H: Hal>` struct
- **`fri.rs`** - Fast Reed-Solomon Interactive Oracle Proof (FRI) protocol implementation  
- **`merkle.rs`** - Merkle tree construction and proof generation for polynomial commitments
- **`poly_group.rs`** - Polynomial group management for organizing trace data sections
- **`write_iop.rs`** - Interactive Oracle Proof (IOP) writer for constructing proof transcripts
- **`soundness.rs`** - Security analysis and soundness error calculations

### Main Data Structures

#### `Prover<'a, H: Hal>`
```rust
pub struct Prover<'a, H: Hal> {
    hal: &'a H,                         // Hardware abstraction layer
    taps: &'a TapSet<'a>,              // Circuit constraint definitions  
    iop: WriteIOP<H::Field>,           // Interactive Oracle Proof writer
    groups: Vec<Option<PolyGroup<H>>>, // Polynomial groups for trace sections
    cycles: usize,                     // Execution cycles (power of 2)
    po2: usize,                        // Log2 of cycles
}
```

#### `PolyGroup<H: Hal>`
- **`coeffs`** - Polynomial coefficients via NTT interpolation
- **`evaluated`** - Evaluations over extended Reed-Solomon domain
- **`merkle`** - Cryptographic commitment to evaluations
- **`count`** - Number of polynomials in the group

## Core Algorithms

### STARK Protocol Flow

1. **Trace Commitment** (`commit_group`)
   - Converts witness data to polynomial coefficients via NTT
   - Applies zero-knowledge shifts: `f(x) → f(3x)`
   - Creates Merkle tree commitments to polynomial evaluations
   - Records commitments in IOP transcript

2. **Constraint Evaluation** (`finalize`)
   - Generates constraint check polynomial from circuit constraints
   - Evaluates constraints over execution trace
   - Compresses multiple constraints using random mixing

3. **DEEP-ALI Protocol**
   - Samples random evaluation point `z`
   - Evaluates all polynomials at shifted powers of `z`
   - Proves constraint satisfaction via polynomial relationships

4. **FRI Proving**
   - Proves low-degree property of constraint polynomial
   - Iterative folding reduces degree by factor of 16 per round
   - Responds to 50 random queries with Merkle proofs

### FRI Protocol (`fri.rs`)

The Fast Reed-Solomon Interactive Oracle Proof provides proximity testing for low-degree polynomials:

- **Folding Rounds**: Each round reduces polynomial degree by `FRI_FOLD = 16`
- **Domain Reduction**: Evaluation domain shrinks while maintaining security
- **Query Phase**: Responds to `QUERIES = 50` challenges for soundness
- **Terminal Polynomial**: Continues until degree ≤ `FRI_MIN_DEGREE = 256`

### Merkle Trees (`merkle.rs`)

Optimized binary Merkle trees provide cryptographic commitments:

- **Column-wise Organization**: Efficient for proving multiple related values
- **Batch Proofs**: Proves entire "columns" of trace data simultaneously  
- **Row-major Layout**: Memory-efficient organization for hardware acceleration

## Security Properties

### Soundness
- **Conjectured Security**: ~97 bits based on toy model analysis
- **FRI Queries**: 50 random challenges provide strong soundness guarantees
- **Reed-Solomon Distance**: 4x blowup factor ensures robust error detection

### Zero-Knowledge
- **Coefficient Shifts**: `f(x) → f(3x)` transformation hides witness values
- **Random Evaluation Points**: Fiat-Shamir sampling prevents selective attacks
- **Constraint Masking**: Random mixing coefficients hide individual constraint values

## Key Constants

- **`INV_RATE = 4`** - Reed-Solomon expansion factor (4x domain blowup)
- **`FRI_FOLD = 16`** - Degree reduction factor per FRI round
- **`QUERIES = 50`** - Number of verification queries for security
- **`FRI_MIN_DEGREE = 256`** - Terminal polynomial degree threshold

## API Usage

### Basic Proving Workflow

```rust
// Initialize prover
let mut prover = Prover::new(hal, taps);
prover.set_po2(log2_cycles);

// Commit execution trace data
prover.commit_group(group_idx, witness_data);

// Generate complete proof
let proof = prover.finalize(globals, circuit_hal);
```

### Hardware Abstraction

The module supports multiple hardware backends through the `Hal` trait:
- **CPU**: Standard polynomial operations with optimized NTT
- **GPU**: Accelerated operations for large-scale proving
- **Custom Hardware**: FPGA and ASIC implementations via HAL interface

## Implementation Notes

- **Memory Efficiency**: In-place NTT operations and bit-reversal minimize memory usage
- **Batch Operations**: Vectorized operations across polynomial groups
- **Debug Support**: Optional constraint verification in debug builds
- **Error Handling**: Comprehensive soundness error analysis and reporting

This module serves as the foundation for RISC Zero's zkVM proving system, enabling private and verifiable computation at scale.