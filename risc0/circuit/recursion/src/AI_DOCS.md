# RISC Zero Recursion Circuit

## Overview
The recursion circuit is a specialized virtual machine optimized for algebraic constraint checking, particularly for verifying STARKs (Scalable Transparent Arguments of Knowledge). It's a core component of the RISC Zero zero-knowledge proof system.

## Purpose
- **STARK Verification**: Specialized VM for verifying STARK proofs efficiently
- **Proof Compression**: Compresses collections of STARK receipts into single succinct receipts
- **Non-Turing Complete**: Designed specifically for constraint checking rather than general computation
- **Recursion Programs**: Executes specialized programs like `lift`, `join`, and `resolve`

## Key Components

### Core Files
- **lib.rs**: Main module defining the CircuitImpl and core constants
- **control_id.rs**: Defines allowed control IDs for recursion programs
- **layout.rs**: Circuit layout definitions (generated code)
- **taps.rs**: Tap set definitions for the circuit
- **poly_ext.rs**: Polynomial extension utilities

### Proving System (prove/)
- **mod.rs**: Main prover implementation
- **program.rs**: Program execution logic
- **witgen.rs**: Witness generation
- **preflight.rs**: Pre-execution validation
- **zkr.rs**: ZKR (zero-knowledge recursion) program handling
- **hal/**: Hardware abstraction layer for different backends (CPU, CUDA, Metal)

## Architecture

### Register Groups
```rust
pub const REGISTER_GROUP_ACCUM: usize = 0;  // Accumulator registers
pub const REGISTER_GROUP_CODE: usize = 1;   // Code registers  
pub const REGISTER_GROUP_CTRL: usize = 1;   // Control registers
pub const REGISTER_GROUP_DATA: usize = 2;   // Data registers
```

### Circuit Implementation
- **CircuitImpl**: Main struct implementing circuit traits
- **TapsProvider**: Provides tap set for constraint verification
- **CircuitCoreDef**: Core circuit definition for BabyBear field

### Supported Operations
- **Identity**: Basic recursion operation
- **Join**: Combines multiple proofs
- **Join with PoVW**: Join with Proof of Valid Winding
- **Lift**: Lifts RV32IM circuit proofs to recursion proofs
- **Resolve**: Resolves proof compositions

## Dependencies
- **risc0-zkp**: Core zero-knowledge proof system
- **risc0-core**: Core RISC Zero utilities
- **BabyBear Field**: Finite field arithmetic
- **Hardware Backends**: CPU, CUDA, Metal support

## Usage Context
This is a low-level interface primarily used internally by the `risc0_zkvm` crate. Users typically interact with the higher-level ZkVM interface rather than this recursion circuit directly.

## Testing
Includes comprehensive test utilities for evaluating circuit constraints across different hardware backends, ensuring consistency between CPU, CUDA, and Metal implementations.