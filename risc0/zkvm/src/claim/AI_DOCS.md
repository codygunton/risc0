# RISC Zero zkVM Claim Module

## Overview

The `claim` module is a core component of the RISC Zero zkVM that defines the structures and utilities for representing claims about zkVM execution. It provides the fundamental types for creating, manipulating, and verifying claims that assert properties about guest program execution.

## Purpose and Functionality

This module implements a "Merkle-ized struct" system where claims can be partially revealed or "pruned" while maintaining cryptographic commitments to the complete data. This enables efficient proof composition and verification while preserving privacy and reducing computational overhead.

### Key Components

#### Core Types

- **`ReceiptClaim`** - The primary claim type containing public assertions about zkVM execution
  - Pre/post system states
  - Exit code and execution status
  - Input/output commitments
  - Journal data and assumptions

- **`WorkClaim<T>`** - Wrapper for claims that includes Proof of Verifiable Work (PoVW) metadata
  - Contains the underlying claim and associated work proof
  - Tracks nonce ranges and computational work performed

- **`MaybePruned<T>`** - Generic type for values that can be either:
  - `Value(T)` - Full unpruned value
  - `Pruned(Digest)` - Hash commitment to the value

#### Specialized Types

- **`Unknown`** - Uninhabited type for type-erased claims
- **`Input`** - Currently uninhabited type for future input commitments
- **`Output`** - Contains journal and assumptions list
- **`Assumption`** - Represents recursive verification claims
- **`Assumptions`** - Ordered list of assumption commitments
- **`Work`** - PoVW metadata with nonce ranges and work values

## Architecture

```
ReceiptClaim
├── pre: MaybePruned<SystemState>       # Initial state
├── post: MaybePruned<SystemState>      # Final state  
├── exit_code: ExitCode                 # Execution result
├── input: MaybePruned<Option<Input>>   # Input commitment
└── output: MaybePruned<Option<Output>> # Output commitment
    ├── journal: MaybePruned<Vec<u8>>   # Program output
    └── assumptions: MaybePruned<Assumptions> # Recursive claims
```

## Key Features

### Merkle-ized Structures
- Selective field revelation through `MaybePruned<T>`
- Cryptographic commitments preserve integrity
- Efficient proof composition and verification

### Proof Composition
- **Join operations** - Combine sequential execution claims
- **Assumption resolution** - Resolve recursive verification calls
- **Merge operations** - Combine claims with overlapping data

### Work Integration
- Proof of Verifiable Work (PoVW) support
- Nonce range tracking for work validation
- Work value accumulation and verification

## Usage Patterns

### Creating Claims

```rust
// Simple successful execution claim
let claim = ReceiptClaim::ok(image_id, journal_data);

// Paused execution claim  
let claim = ReceiptClaim::paused(image_id, journal_data);
```

### Claim Composition

```rust
// Join sequential executions
let combined_claim = first_claim.join(&second_claim);

// Resolve recursive assumptions
let resolved_claim = conditional_claim.resolve(&assumption_claim)?;
```

### Work Claims

```rust
// Wrap claim with work proof
let work_claim = WorkClaim {
    claim: receipt_claim.into(),
    work: work_proof.into(),
};

// Join work claims with contiguous nonce ranges
let combined_work = work_claim1.join(&work_claim2)?;
```

## File Organization

- **`mod.rs`** - Module declarations and `Unknown` type
- **`receipt.rs`** - `ReceiptClaim` and related output types
- **`work.rs`** - `WorkClaim` and PoVW-related functionality  
- **`maybe_pruned.rs`** - Generic pruning/commitment infrastructure
- **`merge.rs`** - Trait and implementations for merging claims

## Integration Points

### Dependencies
- `risc0_binfmt` - Binary format utilities and system state
- `risc0_zkp` - Core cryptographic primitives and digest types
- `risc0_circuit_rv32im` - Circuit-specific claim decoding

### Used By
- Receipt types in `../receipt/` - Wrap claims with proofs
- Host API in `../host/api/` - Claim creation and manipulation
- Verification systems - Claim validation and composition

## Security Considerations

- All claim operations preserve cryptographic integrity
- Pruned values maintain commitment security
- Work claim nonce ranges prevent double-spending
- Assumption resolution validates claim compatibility

## Testing

The module includes comprehensive tests for:
- Encoding/decoding round-trips
- Claim composition operations
- Merge functionality with random pruning
- Work claim validation and joining

This module forms the foundation for the RISC Zero zkVM's claim system, enabling secure and efficient representation of execution assertions with flexible privacy and composition capabilities.