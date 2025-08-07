# RISC Zero Benchmarks - AI Documentation

## Overview
This component provides a comprehensive benchmarking framework for RISC Zero zkVM operations. It measures performance metrics including execution time, proof generation time, verification time, and cycle counts across various cryptographic and computational workloads.

## Purpose
- Performance benchmarking of RISC Zero zkVM operations
- Standardized measurement of execution, proving, and verification times
- Comparison of different cryptographic algorithms and computational tasks
- Output generation in CSV format and human-readable tables

## Key Components

### Core Types

#### `Metrics` (lib.rs:34-59)
Primary data structure for storing benchmark results:
- `name`: Benchmark identifier
- `size`: Input size parameter
- `speed`: Operations per second
- `exec_duration`: Execution time
- `proof_duration`: Proof generation time  
- `total_duration`: Combined execution + proof time
- `verify_duration`: Verification time
- `total_cycles`/`user_cycles`: Cycle counts
- `output_bytes`/`proof_bytes`: Size measurements

#### `Job` (lib.rs:95-101)
Represents a single benchmark task:
- `name`: Job identifier
- `elf`: Compiled RISC Zero program
- `input`: Input data as Vec<u32>
- `image_id`: Program digest for verification
- `size`: Size parameter for metrics

### Core Functions

#### `Job::run()` (lib.rs:126-152)
Main benchmark execution function that:
1. Executes the RISC Zero program and measures time
2. Generates a proof using the prover server
3. Verifies the proof
4. Collects comprehensive metrics

#### `run_jobs()` (lib.rs:155-186)
Orchestrates multiple benchmark runs:
- Executes a collection of jobs sequentially
- Outputs results to CSV file
- Displays formatted table of results
- Returns collected metrics

### Available Benchmarks

The framework includes various benchmark categories defined in `benches/mod.rs`:

#### Cryptographic Hash Functions
- **Blake2b**: `big_blake2b`, `iter_blake2b` - BLAKE2b hashing
- **Blake3**: `big_blake3`, `iter_blake3` - BLAKE3 hashing  
- **Keccak**: `big_keccak`, `iter_keccak` - Keccak-256 hashing
- **SHA-2**: `big_sha2`, `iter_sha2` - SHA-256 hashing

#### Digital Signatures
- **ECDSA**: `ecdsa_verify` - ECDSA signature verification
- **Ed25519**: `ed25519_verify` - Ed25519 signature verification

#### Computational Algorithms
- **Fibonacci**: `fibonacci` - Fibonacci sequence computation
- **Sudoku**: `sudoku` - Sudoku puzzle solving
- **Membership**: `membership` - Set membership proofs

### Command Line Interface

The main executable (`main.rs`) provides a CLI with subcommands for each benchmark:
- `--out`: Specify CSV output file (default: metrics.csv)
- Individual benchmark commands or `All` to run everything

## Usage Patterns

### Running Benchmarks
```rust
// Create jobs for a specific benchmark
let jobs = fibonacci::new_jobs();

// Run benchmarks and collect metrics
let metrics = run_jobs(&output_path, jobs);
```

### Adding New Benchmarks
1. Create new module in `benches/` directory
2. Implement `new_jobs() -> Vec<Job>` function
3. Add module to `benches/mod.rs`
4. Add command variant to CLI enum

## Performance Considerations
- Benchmarks are CPU and memory intensive
- Sequential execution prevents resource contention
- Metrics include both computational and cryptographic overhead
- Results are platform and hardware dependent

## Dependencies
- `risc0_zkvm`: Core zkVM functionality
- `human_repr`: Human-readable metric formatting
- `tabled`: Table display formatting
- `serde`: Serialization for CSV output