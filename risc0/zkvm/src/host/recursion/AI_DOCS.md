# RISC Zero zkVM Host Recursion Component

## Overview

The recursion component is a critical part of the RISC Zero zkVM host that implements proof compression and manipulation using recursive zero-knowledge proof circuits. This module provides the infrastructure for transforming and combining STARK proofs through recursion programs.

## Core Functionality

### Proof Transformation Programs

The recursion system provides several key programs for proof manipulation:

1. **Lift** - Transforms rv32im segment receipts into recursion receipts with constant verification time
2. **Join** - Compresses multiple receipts from the same session into a single receipt  
3. **Resolve** - Removes assumptions from conditional receipts by verifying assumption proofs
4. **Identity** - Transforms receipts (e.g., changing hash functions) without modifying claims
5. **Union** - Compresses multiple succinct receipts into one
6. **Unwrap** - Converts work claim receipts to regular receipt claims

### Proof-of-Verifiable-Work (PoVW) Support

The module includes specialized PoVW variants that track verifiable work:

- `lift_povw` - Lift with work tracking
- `join_povw` - Join with work value combination
- `resolve_povw` - Resolve while preserving work values
- Combined operations like `join_unwrap_povw` and `resolve_unwrap_povw`

## Key Components

### Files and Structure

- **`mod.rs`** - Main module interface with public APIs for recursion operations
- **`prove/mod.rs`** - Core prover implementation and recursion program infrastructure  
- **`prove/zkr.rs`** - Program loading utilities and control ID management
- **`tests.rs`** - Comprehensive test suite covering all recursion operations

### Core Types

- **`Prover`** - Main prover struct for recursion circuit execution
- **`RecursionReceipt`** - Output from recursion circuit proving
- **`SuccinctReceipt<T>`** - Typed succinct receipts with claims
- **`WorkClaim<T>`** - Wrapper for tracking verifiable work

## Architecture Details

### Control Flow

1. **Initialization** - Programs are loaded from embedded zkr files based on hash function and operation type
2. **Input Setup** - Receipts, digests, and other data are added to the prover input tape
3. **Execution** - The recursion circuit processes inputs and generates proofs
4. **Output Processing** - Claims are decoded and verified against expected values

### Hash Function Support

The recursion system supports multiple hash functions:
- **poseidon2** - Default hash function for most operations
- **sha-256** - Alternative hash function option
- **poseidon_254** - Used for BN254 field operations (identity_p254)

### Merkle Tree Integration

Control IDs are organized in Merkle trees to enable:
- Proof inclusion verification
- Control root computation  
- Batch verification of multiple programs

## Usage Patterns

### Basic Receipt Compression

```rust
// Lift segment receipts to recursion receipts
let lifted_a = lift(&segment_receipt_a)?;
let lifted_b = lift(&segment_receipt_b)?;

// Join multiple receipts from same session
let joined = join(&lifted_a, &lifted_b)?;
```

### Conditional Proof Resolution

```rust
// Resolve conditional receipt with assumption
let resolved = resolve(&conditional_receipt, &assumption_receipt)?;
```

### PoVW Workflows

```rust
// Track work through lift and join operations
let work_receipt_a = lift_povw(&segment_a)?;
let work_receipt_b = lift_povw(&segment_b)?;
let combined_work = join_povw(&work_receipt_a, &work_receipt_b)?;

// Convert back to regular receipt
let final_receipt = unwrap_povw(&combined_work)?;
```

## Testing

The module includes extensive tests covering:
- Basic recursion circuit functionality
- All proof transformation operations
- PoVW workflows and work value tracking
- Hash function compatibility
- Error conditions and edge cases

## Dependencies

- **risc0_circuit_recursion** - Core recursion circuit implementation
- **risc0_zkp** - Zero-knowledge proof primitives
- **risc0_binfmt** - Binary format handling
- **risc0_zkvm_methods** - Test methods and utilities

## Integration

This component integrates with:
- **Host Prover** - Provides recursion capabilities to main prover
- **Receipt System** - Produces and consumes various receipt types
- **Circuit Layer** - Uses recursion circuits for proof generation
- **Verification** - Supports verification of recursion proofs

The recursion component is essential for scalable proof compression in the RISC Zero zkVM, enabling efficient verification of complex computations through recursive proof composition.