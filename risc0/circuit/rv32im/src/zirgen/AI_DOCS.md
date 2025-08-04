# Zirgen Circuit Implementation

## Overview
This directory contains the automatically generated Rust code for the RV32IM circuit implementation using the Zirgen framework. The circuit is designed to prove RISC-V RV32IM instruction execution in zero-knowledge.

## Component Structure

### Core Files
- **`mod.rs`** - Main module defining `CircuitImpl` struct and core circuit infrastructure
- **`info.rs`** - Circuit information and protocol constants for RV32IM version 2 revision 2
- **`taps.rs`** - Generated tap definitions for circuit constraints (very large file with tap data)
- **`poly_ext.rs`** - Polynomial extension operations and step definitions

### Generated Include Files
- **`types.rs.inc`** - Type definitions and constants
- **`defs.rs.inc`** - Circuit definition macros and structures  
- **`layout.rs.inc`** - Memory layout and register group definitions
- **`steps.rs.inc`** - Step-by-step circuit execution logic

## Key Components

### CircuitImpl
The main circuit implementation struct that provides:
- `CircuitCoreDef<BabyBear>` - Core circuit definition using Baby Bear field
- `TapsProvider` - Provides access to constraint taps via `TAPSET`

### Circuit Information
- **Protocol**: RV32IM version 2 revision 2 (`*b"RV32IM:v2rev2___"`)
- **Output Size**: 90 elements
- **Mix Size**: 36 elements  
- **Polynomial Mix Powers**: 458 distinct powers used in constraints

### Field Configuration
Uses Baby Bear finite field (`BabyBear`) for:
- Base field elements (`Val`)
- Extension field elements (`ExtVal`) 
- Polynomial mixing operations (`PolyMix`)
- Mix state management (`MixState`)

### Macro System
Defines several macros for circuit generation:
- `set_field!` - Configure field types
- `define_buffer_list!` - Define buffer categories (rows, taps, globals)
- `define_tap_buffer!` - Create tap-specific buffers with register groups
- `define_global_buffer!` - Create global buffers
- `define_buffer!` - Generic buffer definition

## Architecture Notes

### Generated Code
All implementation files are automatically generated from Zirgen specifications and should not be manually edited. The generated code includes:
- Constraint definitions via taps
- Polynomial step operations
- Register layouts and memory organization
- Circuit-specific constants and parameters

### Integration Points
The circuit integrates with the broader RISC Zero zkVM system through:
- `risc0_zkp` crate for zero-knowledge proof infrastructure
- `risc0_core` for field arithmetic and core utilities
- Standard circuit adapter interfaces (`CircuitCoreDef`, `TapsProvider`)

### Performance Considerations
- Large tap set (thousands of entries) for comprehensive constraint coverage
- Optimized polynomial operations for Baby Bear field
- Register grouping for efficient memory access patterns
- Pre-computed polynomial mix powers for constraint evaluation

## Usage Context
This circuit implementation is used by the RISC Zero zkVM to generate zero-knowledge proofs of RISC-V RV32IM program execution, providing cryptographic verification that a program ran correctly without revealing its inputs or intermediate states.