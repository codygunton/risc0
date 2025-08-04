# RISC0 Benchmarks - Benchmark Suite Component

## Overview
This component contains the core benchmarking suite for RISC0, featuring various cryptographic and computational benchmarks to measure zkVM performance. The benchmarks are organized into individual modules, each testing specific operations and algorithms.

## Component Structure
- **Location**: `/risc0/benchmarks/src/benches/`
- **Purpose**: Performance benchmarking and testing of RISC0 zkVM capabilities
- **Architecture**: Modular benchmark system with individual test modules

## Key Files and Modules

### Core Module Files
- `mod.rs`: Main module declaration file listing all available benchmarks
- Individual benchmark modules:
  - `big_blake2b.rs`, `big_blake3.rs`, `big_keccak.rs`, `big_sha2.rs`: Large-scale hash function benchmarks
  - `iter_blake2b.rs`, `iter_blake3.rs`, `iter_keccak.rs`, `iter_sha2.rs`: Iterative hash function benchmarks
  - `ecdsa_verify.rs`, `ed25519_verify.rs`: Digital signature verification benchmarks
  - `fibonacci.rs`: Mathematical computation benchmark
  - `membership.rs`: Membership proof benchmarks
  - `sudoku.rs`: Constraint satisfaction problem benchmark

### Integration Points
- **Parent Component**: Main benchmarking application (`/risc0/benchmarks/src/main.rs`)
- **Dependencies**: 
  - `risc0-zkvm`: Core zkVM functionality
  - Various cryptographic libraries (k256, ed25519-dalek)
  - `risc0-benchmark-methods`: Guest program implementations

## Functionality
Each benchmark module provides:
- `new_jobs()` function: Returns a vector of benchmark jobs to execute
- Performance measurements for specific cryptographic/computational operations
- Integration with the zkVM proving system

## Usage Context
This component is used by:
- Performance testing and regression analysis
- zkVM capability demonstrations
- Comparative benchmarking against other systems
- Development workflow optimization

## Key Dependencies
- `risc0-zkvm`: Core proving system
- Cryptographic libraries for algorithm implementations
- CSV output handling for benchmark results
- Command-line interface integration

## Testing and Benchmarking
The benchmarks can be executed individually or as a complete suite through the parent CLI application, with results output to CSV format for analysis.