# Recursion Prove Module

## Overview
This module provides a high-level interface for proving computations using RISC Zero's recursion circuit. It enables transforming and compressing zero-knowledge proofs through various recursion programs while maintaining security guarantees.

## Core Components

### Public API Functions

#### Receipt Transformation
- **`lift()`** - Transforms RV32IM segment receipts into recursion receipts with constant-time verification
- **`lift_povw()`** - Similar to lift but produces work claim receipts tracking verifiable work
- **`identity_p254()`** - Converts receipts to use Poseidon254 hash for efficient Groth16 verification

#### Receipt Compression
- **`join()`** - Compresses two receipts from the same session into one
- **`join_povw()`** - Joins work claim receipts, combining work values with disjoint nonce ranges
- **`join_unwrap_povw()`** - Combines join and unwrap operations for reduced latency
- **`union()`** - Compresses any two succinct receipts into a single union receipt

#### Assumption Resolution
- **`resolve()`** - Removes assumptions from conditional receipts by verifying proof of assumptions
- **`resolve_povw()`** - Resolves assumptions in work claim receipts while preserving work values
- **`resolve_unwrap_povw()`** - Combines resolve and unwrap for work claim receipts

#### Work Claim Utilities
- **`unwrap_povw()`** - Converts work claim receipts to standard receipt claims

#### ZKR Programs
- **`prove_zkr()`** - Proves arbitrary recursion programs with specified control IDs and inputs
- **`prove_registered_zkr()`** - Proves using pre-registered recursion programs
- **`register_zkr()`** / **`get_registered_zkr()`** - Registry for recursion programs by control ID

### Core Types

#### Prover
Main proving interface with constructors for different recursion programs:
- `new_lift()` / `new_lift_povw()` - RV32IM segment receipt transformation
- `new_join()` / `new_join_povw()` - Receipt compression within sessions  
- `new_resolve()` / `new_resolve_povw()` - Assumption resolution
- `new_identity()` - Receipt transformation preserving claims
- `new_union()` - General receipt compression
- `new_unwrap_povw()` - Work claim unwrapping

#### Registry
- **`ZkrRegistry`** - Maps control IDs to program retrieval functions
- **`ZKR_REGISTRY`** - Global static registry instance

### Constants
- **`RECURSION_PO2`** - Circuit witness rows as power of 2 (18, i.e., 262,144 rows)

## Key Features

### Security
- All functions validate input receipts use poseidon2 hash function
- Control root verification ensures receipt authenticity
- Merkle inclusion proofs validate control IDs against allowed sets

### Efficiency
- Constant-time verification regardless of original segment length
- Receipt compression reduces proof sizes for complex computations
- Specialized PoVW (Proof of Verifiable Work) variants track computational work

### Flexibility
- Supports arbitrary recursion programs through ZKR registry
- Multiple hash functions (poseidon2, sha-256, poseidon_254)
- Conditional receipts with assumption resolution

## Usage Patterns

1. **Basic Workflow**: Segment → lift → join/resolve → identity_p254 → Groth16
2. **Work Tracking**: Use `*_povw` variants to maintain verifiable work claims
3. **Conditional Proofs**: Use resolve functions to eliminate assumptions
4. **Custom Programs**: Register ZKR programs for domain-specific recursion

## Dependencies
- `risc0_circuit_recursion` - Core recursion circuit implementation
- `risc0_zkp` - Zero-knowledge proof system primitives
- `risc0_binfmt` - Binary format utilities for digest operations

## Error Handling
Functions return `anyhow::Result` with context-rich error messages for:
- Hash function mismatches
- Control root verification failures  
- Assumption resolution conflicts
- Pruned claim access attempts