# zkVM Platform

The zkVM platform provides core platform definitions and low-level runtime functions for the RISC Zero zkVM, implementing the RISC-V rv32im ISA for zero-knowledge proof generation.

## Purpose

This component defines the foundational abstractions and system interfaces for guest programs running within the zkVM environment, including memory management, system calls, and runtime support.

## Key Components

### lib.rs
Core platform constants and utilities:
- `WORD_SIZE`: 4 bytes (32-bit architecture)  
- `PAGE_SIZE`: 1024 bytes
- Standard file descriptors (STDIN, STDOUT, STDERR, JOURNAL)
- Memory alignment utilities

### memory.rs
Memory layout and bounds checking:
- `GUEST_MIN_MEM`: 0x0000_4000 - Minimum guest memory address
- `GUEST_MAX_MEM`: 0xC000_0000 - Maximum guest memory address  
- `STACK_TOP`: 0x0020_0400 - Top of stack (grows down)
- `TEXT_START`: 0x0020_0800 - Program load address
- Guest memory validation functions

### syscall.rs
System call interface and implementations:
- **ECalls**: HALT, INPUT, SOFTWARE, SHA, BIGINT, POSEIDON2, etc.
- **System calls**: File I/O, memory allocation, cryptographic operations
- **Register ABI**: RISC-V register definitions and calling conventions
- **Cryptographic accelerators**: SHA compression, Poseidon2 hashing, BigInt operations
- **Process management**: fork, pipe, exit system calls

### heap/
Memory allocation subsystem:
- **mod.rs**: Heap management interface with embedded and bump allocator support
- **bump.rs**: Simple bump allocator implementation
- **embedded.rs**: Embedded-alloc based allocator

### rust_rt.rs
Rust runtime support for the zkVM environment including panic handlers and runtime initialization.

### getrandom.rs
Random number generation interface compatible with the `getrandom` crate.

### libm_extern.rs
External math library function declarations for libm compatibility.

## Security Features

- Memory bounds checking for guest programs
- Controlled system call interface
- Environment variable access restrictions
- Safe cryptographic primitive implementations

## Usage Context

This platform layer enables Rust programs to run within the zkVM by providing:
1. Low-level system abstractions
2. Cryptographic accelerator access
3. Memory management primitives
4. Standard I/O operations
5. Process control mechanisms

The component is designed for no_std environments and provides the foundation for higher-level zkVM guest program development.