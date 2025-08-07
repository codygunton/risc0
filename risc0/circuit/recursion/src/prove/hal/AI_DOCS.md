# HAL (Hardware Abstraction Layer) for RISC Zero Recursion Circuit

## Overview

This module provides hardware abstraction layer implementations for the RISC Zero recursion circuit prover. It enables the same recursion proving logic to run efficiently across different hardware backends including CPU, CUDA (GPU), and Metal (Apple Silicon).

## Core Architecture

### Main Traits

The module defines two core traits that abstract circuit operations:

#### `CircuitWitnessGenerator<H: Hal>` (mod.rs:28)
Generates witness data for circuit execution:
- `generate_witness()` - Creates witness data from preflight traces using specified step mode and cycle count

#### `CircuitAccumulator<H: Hal>` (mod.rs:40) 
Accumulates circuit computations across multiple steps:
- `accumulate()` - Performs accumulation operations on circuit buffers with work/total cycle tracking

## Hardware Backend Implementations

### CPU Backend (cpu.rs)

**Primary Structure**: `CpuCircuitHal` (cpu.rs:49)

**Key Features**:
- Uses Baby Bear finite field arithmetic
- Direct memory access through CPU buffers
- FFI calls to native C implementations:
  - `risc0_circuit_recursion_cpu_witgen` for witness generation
  - `risc0_circuit_recursion_cpu_accum` for accumulation
  - `risc0_circuit_recursion_cpu_eval_check` for constraint evaluation

**Hash Function Support**: Poseidon2, Poseidon254, SHA-256

**Factory Function**: `recursion_prover(hashfn: &str)` creates configured CPU prover instances

### CUDA Backend (cuda.rs)

**Primary Structure**: `CudaCircuitHal<CH: CudaHash>` (cuda.rs:51)

**Key Features**:
- GPU-accelerated computation using CUDA
- Device memory management through CUDA buffers
- Type-safe hash function specializations:
  - `CudaCircuitHalSha256`
  - `CudaCircuitHalPoseidon2` 
  - `CudaCircuitHalPoseidon254`
- FFI calls to CUDA kernels for performance-critical operations

**Memory Management**: Converts between host and device pointers for GPU computation

**Factory Function**: `recursion_prover(hashfn: &str)` creates configured CUDA prover instances

### Metal Backend (metal.rs)

**Primary Structure**: `MetalCircuitHal<MH: MetalHash>` (metal.rs:41)

**Key Features**:
- Apple Silicon GPU acceleration using Metal
- Compiled kernel library loaded at runtime from `RECURSION_METAL_PATH`
- Kernel management system with pipeline descriptors
- Optimized for Apple hardware (macOS/iOS)

**Kernel Operations**:
- `eval_check` - Constraint evaluation
- `step_compute_accum` - Accumulation computation  
- `step_verify_accum` - Accumulation verification

**Memory Operations**: Uses Metal buffers with command queue-based execution

## Integration Points

### Buffer Management
Each backend manages its own buffer types:
- CPU: `CpuBuffer<BabyBearElem>` - Host memory
- CUDA: `CudaBuffer<BabyBearElem>` - GPU device memory  
- Metal: `MetalBuffer<BabyBearElem>` - Metal compute buffers

### Circuit Register Groups
All backends operate on standardized register groups:
- `REGISTER_GROUP_CTRL` - Control flow registers
- `REGISTER_GROUP_DATA` - Data registers
- `REGISTER_GROUP_ACCUM` - Accumulation registers

### Global State Buffers
- `GLOBAL_MIX` - Mixing parameters
- `GLOBAL_OUT` - Output values

## Performance Characteristics

- **CPU**: Good for development/debugging, universal compatibility
- **CUDA**: High throughput for large circuits, requires NVIDIA GPUs
- **Metal**: Optimized for Apple Silicon, energy efficient

## Safety Considerations

All backends use `unsafe` FFI calls wrapped in `ffi_wrap()` for proper error handling. Device memory management is abstracted through the HAL buffer interfaces to prevent memory leaks and access violations.

## Testing

Each backend includes comprehensive tests comparing results against CPU reference implementation to ensure correctness across all hardware platforms.