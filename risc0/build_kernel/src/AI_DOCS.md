# RISC Zero Build Kernel

## Overview

The `risc0-build-kernel` crate provides a build system for compiling GPU kernels (CUDA, Metal) and C++ code within the RISC Zero ecosystem. It offers a unified interface for building different types of kernels with caching, dependency tracking, and cross-platform support.

## Key Components

### KernelType Enum
- `Cpp`: C++ kernel compilation
- `Cuda`: NVIDIA CUDA kernel compilation  
- `Metal`: Apple Metal kernel compilation

### KernelBuild Struct
Main builder interface providing methods for:
- **File Management**: `file()`, `files()`, `file_opt()`, `files_opt()`
- **Include Paths**: `include()` - adds directories to compiler include path
- **Compiler Flags**: `flag()` - adds arbitrary compiler flags
- **Dependencies**: `dep()`, `deps()` - tracks build dependencies
- **Compilation**: `compile()` - executes the build process

## Compilation Strategies

### C++ Compilation (`compile_cpp`)
- Uses `cc` crate for cross-platform C++ compilation
- Enables C++17 standard
- Optimized for debug builds with tracking disabled
- Supports `sccache` for faster rebuilds

### CUDA Compilation (`compile_cuda`)
- Handles NVIDIA CUDA kernel compilation
- Supports environment variables:
  - `NVCC_APPEND_FLAGS` / `NVCC_PREPEND_FLAGS`: Custom compiler flags
  - `RISC0_CUDART_LINKAGE`: Runtime linkage mode (static/dynamic)
  - `NVCC_CCBIN`: Custom C++ compiler path
- Uses native architecture by default (`-arch=native`)
- Includes diagnostic suppressions for common warnings

### Metal Compilation (`compile_metal`)
- Compiles Apple Metal shaders for iOS/macOS
- Multi-stage process: `.metal` → `.air` → `.metallib`
- Platform detection for appropriate SDK selection
- Parallel compilation of individual shader files
- Built-in system headers (`fp.h`, `fpext.h`)

## Caching System

### Features
- **Content-based Hashing**: Uses SHA256 of source files, flags, and dependencies
- **Cache Directory**: Platform-specific cache location via `directories` crate
- **Atomic Operations**: Uses temporary directories to prevent corruption
- **Skip Mode**: `RISC0_SKIP_BUILD_KERNELS` environment variable bypasses compilation

### Cache Key Components
- Compiler flags and tags
- Source file contents
- System include files
- Build dependencies

## Build Integration

### Cargo Integration
- Emits `cargo:rerun-if-changed` for proper incremental builds
- Supports `cargo:rerun-if-env-changed` for environment variables
- Outputs library paths via `cargo:LIB_NAME=path`

### Environment Variables
- `RISC0_SKIP_BUILD_KERNELS`: Skip kernel compilation entirely
- `OUT_DIR`: Cargo build output directory
- `TARGET`: Target platform specification

## File Structure
```
lib.rs - Main implementation with KernelBuild API and compilation logic
kernels/metal/ - Built-in Metal headers (fp.h, fpext.h)
```

## Usage Patterns

The crate is typically used in `build.rs` scripts:

```rust
KernelBuild::new(KernelType::Cuda)
    .include("path/to/headers")
    .flag("-O3")
    .file("kernel.cu")
    .compile("mykernel");
```

## Dependencies
- `cc`: Cross-platform C/C++ compilation
- `rayon`: Parallel processing for Metal compilation
- `sha2`: Content hashing for cache keys
- `tempfile`: Atomic file operations
- `directories`: Platform-specific cache directories