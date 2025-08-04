# ZKOS V1 Compatibility Layer

## Overview

The ZKOS V1 compatibility layer provides backward compatibility support for legacy RISC Zero zkVM programs that were built against the V1 system interface. It implements a lightweight kernel that bridges V1 system calls to the current zkVM infrastructure, ensuring older programs can run unmodified while maintaining cryptographic integrity and performance characteristics.

## Architecture

### Core Design Principles

- **Binary Compatibility**: Preserve V1 ABI and system call interface exactly
- **Minimal Overhead**: Thin translation layer with negligible performance impact
- **Security Preservation**: Maintain all V1 security guarantees and isolation
- **Transparent Operation**: V1 programs run without modification or awareness of compatibility layer
- **Deterministic Execution**: Ensure identical execution traces for proof generation

### Main Components

#### Compatibility Kernel (`kernel.s`)
Assembly language kernel implementing V1 system interface:

**Memory Layout:**
```assembly
.equ USER_START_ADDR, 0x00010000    # User program entry point
.equ STACK_TOP, 0xfff00000          # Stack grows down from here
.equ USER_REGS_ADDR, 0xffff0080     # Saved user registers
.equ MEPC_ADDR, 0xffff0200          # Machine exception PC
.equ ECALL_DISPATCH_ADDR, 0xffff1000 # System call dispatch table
```

**System Call Interface:**
- `HOST_ECALL_TERMINATE (0)` - Program termination with exit code
- `HOST_ECALL_READ (1)` - Read data from host
- `HOST_ECALL_WRITE (2)` - Write data to host/journal
- `HOST_ECALL_POSEIDON2 (3)` - Poseidon2 hash acceleration
- `HOST_ECALL_SHA (4)` - SHA-256 hash acceleration
- `HOST_ECALL_BIGINT (5)` - Big integer arithmetic acceleration

**Exception Handling:**
- Trap handler for ECALL instructions
- Machine mode privilege separation
- User register save/restore on context switch

#### V1 Runtime Implementation (`main.rs`)
Core runtime services for V1 compatibility:

**SHA-256 Implementation:**
```rust
unsafe extern "C" fn ecall_sha_v1compat(
    state: *mut [u32; DIGEST_WORDS],
    msg_bytes: *const u8,
    digest_bytes: usize,
    msg_len: u32,
)
```
- Hardware-accelerated SHA-256 with V1 interface
- Supports incremental hashing with state management
- Block-aligned processing for efficiency

**BigInt Arithmetic:**
```rust
unsafe extern "C" fn ecall_bigint_v1compat(
    result: *mut [u32; BIGINT_WIDTH_WORDS],
    op: u32,
    x: *const [u32; BIGINT_WIDTH_WORDS],
    y: *const [u32; BIGINT_WIDTH_WORDS],
    modulus: *const [u32; BIGINT_WIDTH_WORDS],
)
```
- 256-bit modular arithmetic operations
- Multiplication and modular multiplication support
- Pre-compiled bigint programs for verification

**I/O Operations:**
```rust
unsafe extern "C" fn ecall_read_v1compat(
    channel: u32,
    addr: *mut u8,
    len: u32,
) -> u32

unsafe extern "C" fn ecall_write_v1compat(
    channel: u32,
    addr: *const u8,
    len: u32,
) -> u32
```
- Channel-based I/O matching V1 semantics
- Support for stdin, stdout, stderr, journal channels
- Bounds checking and memory safety validation

#### Library Interface (`lib.rs`)
Minimal no_std library exposing V1 compatibility ELF:

```rust
#![no_std]
pub const V1COMPAT_ELF: &[u8] = include_bytes!("../elfs/v1compat.elf");
```

### System Call Translation

The compatibility layer translates V1 system calls to current zkVM interfaces:

1. **ECALL Interception**
   - V1 program executes ECALL instruction
   - Kernel trap handler saves user context
   - Dispatch based on system call number

2. **Parameter Translation**
   - V1 calling convention preserved
   - Pointer validation against user memory bounds
   - Endianness and alignment handling

3. **Service Invocation**
   - Map to current zkVM host services
   - Handle interface differences transparently
   - Maintain V1 error semantics

4. **Result Marshaling**
   - Convert results to V1 format
   - Update user registers appropriately
   - Resume user execution

### Memory Management

**Address Space Layout:**
- `0x00010000 - 0xC0000000`: User program space
- `0xC0000000 - 0xFFF00000`: Reserved
- `0xFFF00000 - 0xFFFF0000`: Stack space
- `0xFFFF0000 - 0xFFFFFFFF`: Kernel/system space

**Protection Mechanisms:**
- User pointer validation on all system calls
- Stack overflow detection
- Illegal memory access trapping

### BigInt Acceleration

The V1 bigint interface supports accelerated cryptographic operations:

**Supported Operations:**
- 256-bit multiplication
- 256-bit modular multiplication
- Pre-compiled verification programs

**Implementation Details:**
- Embedded bigint program blobs
- Header structure with program metadata
- Temporary memory allocation for computation

### Security Considerations

- **Memory Isolation**: Strict boundary checking prevents kernel access
- **Privilege Separation**: User/machine mode enforcement
- **Input Validation**: All system call parameters validated
- **Deterministic Execution**: No timing variations or side channels
- **Resource Limits**: Bounded memory and cycle usage

### Integration Points

- **Current zkVM**: Translates to modern zkVM system calls
- **Proof System**: Generates compatible execution traces
- **Host Interface**: Maps V1 channels to current I/O system
- **Acceleration**: Leverages current hardware acceleration

### Performance Characteristics

- **Minimal Overhead**: Direct system call translation
- **Hardware Acceleration**: SHA and bigint operations accelerated
- **Memory Efficiency**: No additional memory copies
- **Cycle Count**: Negligible overhead vs native V1

### Usage

V1 programs run transparently through the compatibility layer:
1. Load V1COMPAT_ELF as the boot kernel
2. Load V1 program at USER_START_ADDR
3. Execute normally - compatibility is automatic

### Limitations

- **Fixed Memory Layout**: V1 memory map must be preserved
- **System Call Set**: Only V1 system calls supported
- **No Extensions**: Cannot use modern zkVM features
- **Binary Only**: Source-level changes require migration