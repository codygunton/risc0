# Keccak Circuit HAL (Hardware Abstraction Layer)

## Overview

This module provides a hardware abstraction layer for the RISC Zero Keccak circuit, enabling efficient zero-knowledge proof generation for Keccak-256 hash operations across different computational backends (CPU and CUDA). The HAL abstracts the complexity of witness generation and circuit evaluation while optimizing performance for each backend.

## Architecture

### Core Components

#### MetaBuffer (`mod.rs:27-47`)
```rust
pub(crate) struct MetaBuffer<H: Hal> {
    pub buf: H::Buffer<H::Elem>,  // Backend-specific buffer
    pub rows: usize,              // Matrix dimensions  
    pub cols: usize,
    pub checked_reads: bool,      // Debug validation flag
}
```

**Purpose**: Provides a unified interface for managing circuit matrices across different HAL implementations. Acts as a wrapper around backend-specific buffers with metadata about matrix dimensions and validation settings.

**Usage**: Used for global state, witness data, and accumulator matrices during circuit evaluation.

#### CircuitWitnessGenerator Trait (`mod.rs:57-74`)

**Purpose**: Defines the interface that all HAL backends must implement for witness generation.

**Key Methods**:
- `scatter_preflight()`: Distributes preflight trace data into circuit matrices using ScatterInfo descriptors
- `generate_witness()`: Performs the actual witness computation by calling backend-specific FFI functions
- `PreferredPreflightOrder`: Type alias allowing backends to specify optimal data ordering

#### StepMode Enum (`mod.rs:49-55`)

**Purpose**: Controls execution strategy for witness generation.

**Modes**:
- `Parallel`: Concurrent execution (optimal for CPU multi-threading)
- `SeqForward`: Sequential forward processing
- `SeqReverse`: Sequential reverse processing

## Backend Implementations

### CPU Backend (`cpu.rs`)

**Key Features**:
- Uses Rayon for multi-threaded parallel processing
- Direct memory access through Rust slicing
- Calls `risc0_circuit_keccak_cpu_witgen()` FFI function
- Uses `ForwardPreflightOrder` for simple sequential processing

**Performance Characteristics**:
- Leverages all available CPU cores
- Memory bandwidth dependent
- Thread-safe raw pointer access in `eval_check()`

**Witness Generation Flow** (`cpu.rs:78-128`):
1. Validates preflight trace dimensions
2. Creates `RawExecBuffers` with pointers to global and data matrices
3. Extracts execution order and preimage indices from preflight trace
4. Calls C++ witness generation function via FFI

### CUDA Backend (`cuda.rs`)

**Key Features**:
- GPU-accelerated computation using CUDA kernels
- Device memory management with automatic cleanup
- Uses `CudaPreflightOrder` to minimize warp divergence
- Optimized for SIMD execution patterns on GPU

**Optimizations**:
- **Warp Optimization** (`cuda.rs:68-79`): Groups cycles by `(cycle_type, sub_type)` to reduce divergent execution paths
- **Memory Coalescing**: Backend-specific preflight ordering improves GPU memory access patterns
- **Resource Management**: Automatic CUDA context cleanup on drop

**Performance Characteristics**:
- High throughput for large batch sizes
- Lower latency for small operations compared to CPU
- Memory bandwidth and compute unit utilization dependent

## Witness Generation Process

### 1. Preflight Preparation
- Input: Array of `KeccakState` (25 64-bit words each)
- Creates execution trace modeling complete Keccak-f[1600] computation
- Generates `ScatterInfo` structures describing data distribution

### 2. Matrix Setup
- Allocates global and data matrices using `MetaBuffer::new()`
- Sets up checked reads for debug builds, unchecked for production

### 3. Data Scattering (`scatter_preflight`)
- Distributes preflight trace data into circuit matrices
- Uses backend-specific optimizations (bit packing, memory layout)
- CPU: Direct slice manipulation
- CUDA: Device memory copies with kernel calls

### 4. Witness Generation (`generate_witness`)
- Executes circuit constraints using backend-specific implementations
- CPU: Multi-threaded processing with shared memory
- CUDA: Parallel kernel execution on GPU

### 5. Constraint Evaluation (`eval_check`)
- Verifies all circuit constraints are satisfied
- Computes polynomial evaluations for zk-STARK protocol
- Uses mixed radix representation and roots of unity

## Circuit Integration

### zkVM Precompile Integration
- Guest programs use `tiny-keccak` crate (patched for RISC Zero)
- Precompile intercepts Keccak calls and routes to circuit prover
- Generates zero-knowledge proofs of correct hash computation

### Proof System Integration
- **Circuit Layer**: Generates STARK proofs for Keccak operations
- **Recursion Layer**: Can aggregate multiple proofs
- **Groth16 Layer**: Optional SNARK conversion for blockchain deployment

## Performance Characteristics

### Circuit Sizing
- **Default**: 2^17 cycles (131,072 cycles)
- **Range**: 2^14 to 2^18 cycles (configurable)
- **Throughput**: ~200 cycles per Keccak operation
- **Batch Capacity**: ~650 hashes per proof at default size

### Backend Selection Strategy
1. Check for CUDA availability and feature flag
2. Fall back to CPU if CUDA unavailable
3. Automatic context management and resource cleanup

### Memory Usage
- **Global Matrix**: Circuit-wide constants and mixing polynomials
- **Data Matrix**: Per-cycle witness data and state transitions
- **Debug Mode**: Additional validation with checked reads
- **Production**: Unchecked reads for maximum performance

## Security Considerations

### Witness Integrity
- Uses SHA-256 commitment of state transitions
- Validates preflight trace consistency
- Checked reads in debug builds prevent buffer overruns

### Side-Channel Resistance
- Constant-time operations in circuit evaluation
- No data-dependent branching in critical paths
- Uniform memory access patterns

## Example Usage

```rust
// Create CPU-based prover
let cpu_prover = cpu::keccak_prover()?;

// Create CUDA-based prover (if available)
#[cfg(feature = "cuda")]
let cuda_prover = cuda::keccak_prover()?;

// Prove multiple Keccak operations
let states = vec![KeccakState::default(); batch_size];
let receipt = prover.prove_keccak(&states)?;
```

## File Structure

- `mod.rs`: Core abstractions and traits
- `cpu.rs`: CPU backend implementation with multi-threading
- `cuda.rs`: CUDA backend implementation with GPU acceleration

## Related Components

- `../preflight.rs`: Trace generation and execution modeling
- `../../zirgen/`: Circuit definition and constraint generation  
- `../zkr.rs`: ZKR (Zero-Knowledge RISC-V) integration
- `../testutil.rs`: Testing utilities for HAL verification

## Dependencies

### External Crates
- `risc0_circuit_keccak_sys`: FFI bindings to C++/CUDA implementations
- `risc0_zkp`: Core zero-knowledge proof system
- `risc0_core`: Finite field arithmetic and utilities
- `rayon`: CPU parallelization (CPU backend)

### Internal Dependencies
- Circuit field arithmetic (`CircuitField`, `Val`, `ExtVal`)
- Buffer management and memory abstraction
- Polynomial evaluation and constraint checking