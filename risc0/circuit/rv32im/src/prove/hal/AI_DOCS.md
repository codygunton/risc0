# HAL (Hardware Abstraction Layer) Module

## Overview
This module provides hardware abstraction layer implementations for the RISC Zero RV32IM circuit proving system. It contains CPU and CUDA implementations for witness generation and proof computation.

## Architecture

### Core Components

#### `mod.rs` - Main Module Interface
- **`MetaBuffer<H>`**: Generic buffer abstraction over different HAL implementations
  - Manages rows, columns, and checked access for circuit data
  - Used for global, data, and accumulation buffers
- **`StepMode`**: Execution mode enumeration (Parallel, SeqForward, SeqReverse)
- **`CircuitWitnessGenerator<H>`**: Trait for generating circuit witnesses
- **`CircuitAccumulator<H>`**: Trait for accumulating circuit data
- **`SegmentProverImpl<H, C, F>`**: Generic segment prover implementation

#### `cpu.rs` - CPU Implementation
- **`CpuCircuitHal`**: CPU-specific circuit HAL implementation
- Implements witness generation using FFI calls to `risc0_circuit_rv32im_cpu_witgen`
- Handles accumulation via `risc0_circuit_rv32im_cpu_accum`
- Uses parallel iteration with `rayon` for polynomial evaluation
- Provides `segment_prover()` factory function for CPU proving

#### `cuda.rs` - CUDA Implementation
- **`CudaCircuitHal<CH>`**: CUDA-specific circuit HAL implementation
- Generic over CUDA hash implementations
- Uses device memory pointers for GPU computation
- Implements witness generation via `risc0_circuit_rv32im_cuda_witgen`
- Handles GPU-specific memory management and kernel calls
- Includes comprehensive test suite comparing CPU and GPU results

## Key Features

### Hardware Abstraction
- Unified interface for CPU and CUDA implementations
- Generic over field types and hash functions
- Automatic memory management and buffer allocation

### Proving Pipeline
1. **Preflight**: Initialize proving parameters and random values
2. **Witness Generation**: Generate circuit witness data
3. **Accumulation**: Compute polynomial accumulations
4. **Proof Generation**: Create final zero-knowledge proof

### Performance Optimizations
- Parallel execution on CPU using `rayon`
- GPU acceleration via CUDA kernels
- Memory-efficient buffer management
- FFI integration with optimized C/CUDA implementations

## Usage

### CPU Proving
```rust
let segment_prover = cpu::segment_prover()?;
let proof = segment_prover.prove_segment(&segment)?;
```

### CUDA Proving (when available)
```rust
let segment_prover = cuda::segment_prover()?;
let proof = segment_prover.prove_segment(&segment)?;
```

## Dependencies
- `risc0_circuit_rv32im_sys`: FFI bindings to C/CUDA implementations
- `risc0_zkp`: Core zero-knowledge proof primitives
- `risc0_core`: Field arithmetic and utility functions
- `rayon`: CPU parallelization
- CUDA runtime (for GPU implementation)

## Testing
The module includes comprehensive tests that verify correctness by comparing CPU and CUDA implementations of polynomial evaluation functions.