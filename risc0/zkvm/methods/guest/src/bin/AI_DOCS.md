# RISC Zero zkVM Guest Program Binaries

This directory contains guest program binaries for the RISC Zero zkVM (Zero-Knowledge Virtual Machine). These programs are designed to run inside the zkVM environment and demonstrate various functionality and testing scenarios.

## Purpose

These guest programs serve as:
- Test cases for zkVM functionality
- Examples of zkVM guest program development
- Validation tools for various zkVM features and system calls

## Core Files

### hello_commit.rs
- **Purpose**: Simple "Hello World" example for zkVM
- **Functionality**: Commits the string "hello world" to the zkVM journal
- **Key Features**:
  - Uses `#![no_std]` and `#![no_main]` for bare-metal execution
  - Demonstrates basic `env::commit_slice()` usage
  - Entry point defined with `risc0_zkvm::entry!(main)`

### multi_test.rs
- **Purpose**: Comprehensive test suite for zkVM functionality
- **Functionality**: Executes different test scenarios based on `MultiTestSpec` input
- **Key Test Categories**:
  - **Cryptographic Operations**: SHA-256, Keccak, Poseidon2 hashing
  - **System Calls**: Memory management, I/O operations, verification
  - **Performance Testing**: Cycle counting, busy loops, profiling
  - **Error Conditions**: Out-of-bounds access, memory exhaustion, panics
  - **Advanced Features**: Fork operations, unconstrained execution, BigInt arithmetic

### heap_limits.rs
- **Purpose**: Tests memory allocation limits and heap overflow behavior
- **Functionality**: Validates that excessive memory allocation crashes gracefully
- **Test Scenarios**:
  - Heap overflow via standard allocator
  - Heap overflow via system allocator calls
  - Ensures deterministic failure behavior

### slice_io.rs
- **Purpose**: Demonstrates basic I/O operations with byte slices
- **Functionality**: Reads length-prefixed data from stdin and commits to journal
- **Key Operations**:
  - Dynamic memory allocation based on input size
  - Stream-based reading from zkVM environment
  - Journal commitment of processed data

### multi_test/profiler.rs
- **Purpose**: Profiling test functions for performance analysis
- **Functionality**: Provides functions with different inlining characteristics
- **Features**:
  - Mix of inlined and non-inlined functions
  - Assembly instruction testing
  - Function call boundary testing for profiler accuracy

## Architecture

### zkVM Environment
- Programs use `#![no_std]` for minimal runtime overhead
- Entry points defined with `risc0_zkvm::entry!(main)`
- Access to zkVM-specific functionality through `risc0_zkvm::guest::env`

### Key Dependencies
- `risc0_zkvm`: Core zkVM guest runtime and utilities
- `risc0_zkvm_methods`: Method definitions and specifications
- `risc0_zkvm_platform`: Low-level platform abstractions and system calls
- `risc0_circuit_*`: Circuit-specific implementations for cryptographic operations

### System Call Interface
Programs interact with the zkVM host through system calls:
- Memory management (`sys_alloc_aligned`)
- Cryptographic operations (`sys_sha`, `sys_keccak`, `sys_poseidon2`)
- I/O operations (`sys_read`, `sys_write`)
- Process management (`sys_fork`, `sys_exit`)

## Testing Framework

The `multi_test.rs` file implements a comprehensive testing framework driven by `MultiTestSpec` enum values:

### Cryptographic Tests
- SHA-256 conformance and performance
- Keccak-256 state updates and validation
- Poseidon2 hash function testing

### System Tests
- Memory allocation and limits
- File descriptor operations
- Process forking and communication
- Input/output validation

### Performance Tests
- Cycle counting accuracy
- Busy loop benchmarking
- Unconstrained execution timing

### Error Condition Tests
- Out-of-bounds memory access
- Invalid system call parameters
- Memory exhaustion scenarios

## Security Considerations

These programs are designed for testing and demonstration purposes within the controlled zkVM environment. They include:
- Deliberate error condition testing (out-of-bounds access, memory exhaustion)
- Low-level assembly operations for specific test scenarios
- Direct system call usage for validation purposes

All programs operate within the zkVM's security model and cannot affect the host system directly.

## Build and Execution

These programs are built as part of the RISC Zero zkVM methods system and executed within the zkVM environment. They cannot be run as standalone programs outside the zkVM context.