# Hardware Abstraction Layer (HAL) - AI Documentation

## Overview

The HAL (Hardware Abstraction Layer) module provides a unified interface for accelerating the RISC Zero ZKP (Zero Knowledge Proof) system across different computing platforms. This abstraction allows the same ZKP operations to run efficiently on CPU, GPU (CUDA), and Apple Silicon (Metal) hardware.

## Core Components

### 1. Main Traits (`mod.rs`)

#### `Buffer<T>` Trait
```rust
pub trait Buffer<T>: Clone {
    fn name(&self) -> &'static str;
    fn size(&self) -> usize;
    fn slice(&self, offset: usize, size: usize) -> Self;
    fn get_at(&self, idx: usize) -> T;
    fn view<F: FnOnce(&[T])>(&self, f: F);
    fn view_mut<F: FnOnce(&mut [T])>(&self, f: F);
    fn to_vec(&self) -> Vec<T>;
}
```

The `Buffer` trait provides memory management abstraction across different hardware platforms. It supports:
- Named buffers for debugging (`name()`)
- Size querying and slicing operations
- Safe read/write access through view functions
- Element access and conversion to Vec

#### `Hal` Trait
The main Hardware Abstraction Layer trait that defines the interface for ZKP operations:

**Key Associated Types:**
- `Field`: The finite field implementation
- `Elem`: Field elements 
- `ExtElem`: Extension field elements
- `Buffer<T>`: Platform-specific buffer implementation

**Core Operations:**
- **Memory Management**: `alloc_*`, `copy_from_*` methods for different data types
- **NTT Operations**: Number Theoretic Transform batch operations
- **Polynomial Operations**: Evaluation, mixing, and arithmetic
- **Cryptographic Operations**: Hashing, folding, zero-knowledge shifts
- **Memory Operations**: Element-wise operations, copying, gathering

#### `CircuitHal<H: Hal>` Trait
Circuit-specific operations for proof generation:
- `accumulate()`: Accumulates circuit execution
- `eval_check()`: Evaluates constraint polynomial

### 2. CPU Implementation (`cpu.rs`)

The `CpuHal<F: Field>` provides a CPU-based implementation using:
- **Parallel Processing**: Rayon for multi-threaded operations
- **Memory Management**: `TrackedVec` with automatic memory tracking
- **Thread Safety**: `SyncSlice` for safe concurrent access
- **Buffer Implementation**: `CpuBuffer<T>` with reference counting

**Key Features:**
- Unified memory model (`has_unified_memory() -> true`)
- Parallel NTT operations using CPU cores
- Memory tracking for debugging and optimization
- Safe slicing and region-based access

### 3. CUDA Implementation (`cuda.rs`)

The `CudaHal<CH: CudaHash>` provides GPU acceleration using NVIDIA CUDA:

**Hash Implementations:**
- `CudaHashSha256`: SHA-256 based hashing
- `CudaHashPoseidon2`: Poseidon2 hash function
- `CudaHashPoseidon254`: Poseidon254 hash function

**Key Features:**
- **GPU Memory Management**: Device buffers with automatic tracking
- **Kernel Dispatch**: External C functions for GPU kernels
- **Polynomial Division**: Hardware-accelerated polynomial operations
- **Non-unified Memory**: Explicit host-device transfers
- **Singleton Pattern**: Thread-safe GPU access

**External Dependencies:**
- CUDA runtime and device management
- Custom kernels for ZKP-specific operations
- SPPARK library integration for cryptographic primitives

### 4. Metal Implementation (`metal.rs`)

The `MetalHal<MH: MetalHash>` provides Apple Silicon GPU acceleration:

**Hash Implementations:**
- `MetalHashSha256`: SHA-256 with Metal compute shaders
- `MetalHashPoseidon2`: Poseidon2 with precomputed constants

**Key Features:**
- **Metal Compute Pipeline**: Precompiled shader library
- **Argument Buffers**: Tier 2 support for efficient parameter passing
- **Shared Memory**: StorageModeShared for unified memory access
- **Compute Kernels**: 19 specialized kernels for ZKP operations
- **Thread Group Management**: Optimized launch parameters

**Kernel Functions:**
```
batch_expand, eltwise_add_fp, eltwise_copy_fp, eltwise_mul_factor_fp,
eltwise_sum_fpext, eltwise_zeroize_fp, fri_fold, gather_sample,
mix_poly_coeffs, multi_bit_reverse, multi_ntt_fwd_step, multi_ntt_rev_step,
multi_poly_eval, poseidon2_fold, poseidon2_rows, sha_fold, sha_rows, zk_shift
```

### 5. Dual HAL Implementation (`dual.rs`)

The `DualHal<F, L, R>` runs operations on two HAL implementations simultaneously for:
- **Testing**: Verifying GPU implementations against CPU reference
- **Debugging**: Comparing results between different backends
- **Validation**: Ensuring correctness across platforms

**Key Features:**
- Automatic result comparison with assertions
- Dual buffer management
- Circuit HAL support for proof validation

## Memory Management

### Memory Tracking
All HAL implementations include memory tracking through a global `MemoryTracker`:
```rust
pub struct MemoryTracker {
    pub total: isize,
    pub peak: isize,
}
```

This enables:
- Runtime memory usage monitoring
- Peak memory consumption tracking
- Memory leak detection
- Performance optimization

### Buffer Lifecycle
1. **Allocation**: Platform-specific buffer creation
2. **Data Transfer**: Host-to-device copying (GPU implementations)
3. **Processing**: Kernel execution or CPU computation
4. **Access**: Safe view-based reading/writing
5. **Cleanup**: Automatic memory deallocation

## ZKP Operations

### Number Theoretic Transforms (NTT)
- **Forward NTT**: Coefficient to evaluation domain conversion
- **Inverse NTT**: Evaluation to coefficient domain conversion
- **Batch Processing**: Multiple polynomials simultaneously
- **Bit Reversal**: Memory layout optimization

### Polynomial Operations
- **Evaluation**: Horner's method for polynomial evaluation
- **Mixing**: Linear combinations with random coefficients
- **Division**: Polynomial remainder computation
- **Zero-Knowledge Shifts**: Randomization for soundness

### Cryptographic Primitives
- **Hash Functions**: SHA-256, Poseidon2, Poseidon254
- **Merkle Operations**: Tree building and proof generation
- **Fiat-Shamir**: Random challenge generation
- **Commitment Schemes**: Polynomial commitment operations

## Platform-Specific Optimizations

### CPU (`cpu.rs`)
- Rayon-based parallelization
- SIMD-friendly memory layouts
- Cache-aware algorithms
- Thread-local storage for temporary data

### CUDA (`cuda.rs`)
- Warp-level primitives
- Shared memory utilization
- Coalesced memory access
- Kernel fusion optimizations

### Metal (`metal.rs`)
- Threadgroup memory usage
- SIMD-group operations
- Metal Performance Shaders integration
- Argument buffer optimization

## Error Handling and Safety

### Memory Safety
- RAII patterns for automatic cleanup
- Bounds checking on buffer operations
- Safe slicing with assertions
- Reference counting for shared buffers

### Error Propagation
- Panic-based error handling for irrecoverable errors
- Assertion-based validation in debug builds
- FFI error code checking for external libraries
- Graceful degradation where possible

## Testing and Validation

### Test Utilities (`testutil` module)
Comprehensive test suite covering:
- Element-wise operations validation
- NTT correctness verification
- Hash function compliance
- Memory management testing
- Cross-platform consistency

### Dual HAL Testing
The `DualHal` enables automated testing by:
- Running operations on both CPU and GPU
- Comparing results with exact equality
- Identifying platform-specific bugs
- Validating optimization correctness

## Integration Points

### Field Arithmetic
- Tight integration with `risc0_core::field`
- Support for multiple finite fields
- Extension field operations
- Roots of unity computation

### Hash Suite Integration
- Pluggable hash function architecture
- Consistent interface across implementations
- Support for different security levels
- Proof system compatibility

### Circuit Integration
- Direct support for constraint evaluation
- Witness computation acceleration
- Proof generation pipeline integration
- Verification operation support

## Performance Considerations

### Batch Operations
All operations are designed for batch processing to:
- Amortize kernel launch overhead (GPU)
- Maximize parallelization opportunities
- Improve memory bandwidth utilization
- Reduce API call overhead

### Memory Layout
- Structure of Arrays (SoA) for vectorization
- Coalesced access patterns for GPU
- Cache-friendly ordering for CPU
- Minimal data structure overhead

### Async Operations
- Non-blocking GPU kernel launches
- Pipelined memory transfers
- Overlapped computation and communication
- Resource pooling for efficiency

This HAL architecture enables RISC Zero's ZKP system to achieve high performance across diverse hardware platforms while maintaining code clarity and correctness through unified abstractions.