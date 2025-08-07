# RISC Zero Execute Module

## Overview

The execute module is the **core execution engine** for RISC-V programs within the RISC Zero zero-knowledge proof system. It implements a complete RISC-V RV32IM virtual machine that executes guest programs while generating execution traces that can be proven in zero-knowledge.

## Key Responsibilities

- **RISC-V Instruction Execution**: Complete RV32IM (32-bit RISC-V with Integer and Multiplication extensions) instruction set implementation
- **Execution Trace Generation**: Produces detailed execution traces for zero-knowledge proof generation
- **Paged Virtual Memory**: Manages a 4GB virtual address space with Merkle tree authentication
- **System Call Interface**: Provides host-guest communication through environment calls (ecalls)
- **Segmented Execution**: Breaks long programs into provable segments that fit within circuit constraints
- **Specialized Acceleration**: Hardware-accelerated operations for cryptographic computations

## Core Components

### Executor (`executor.rs`)
The main orchestrator that manages the complete execution lifecycle:
- **Segmented execution**: Breaks programs into bounded segments (typically 2^20 cycles)
- **Multithreaded segment generation**: Parallelizes segment creation for performance
- **Cycle tracking**: Monitors user cycles, paging cycles, and reserved cycles
- **I/O recording**: Captures all host interactions for deterministic replay
- **Memory state management**: Coordinates between segments and maintains memory consistency

Key types:
- `Executor`: Main execution coordinator
- `ExecutorResult`: Contains execution summary and final state
- `SimpleSession`: Basic execution session implementation
- `CycleLimit`: Configurable execution limits

### RISC-V Emulator (`rv32im.rs`)
A complete RISC-V RV32IM instruction emulator:
- **Instruction decode and execution**: All RV32IM instructions including arithmetic, logic, memory access, control flow, and multiplication/division
- **RISC-V semantics compliance**: Proper register behavior (x0 hardwired to zero), memory alignment, trap handling
- **Disassembly support**: Human-readable instruction formatting for debugging
- **Exception handling**: Illegal instructions, misaligned memory access, privilege violations

Key types:
- `Emulator`: Core instruction execution engine  
- `DecodedInstruction`: Parsed instruction representation
- `InsnKind`: Instruction category enumeration
- `EmuContext`: Interface between emulator and execution context

### Paged Memory System (`pager.rs`)
Sophisticated virtual memory management with cryptographic authentication:
- **4GB virtual address space**: Organized in 1KB pages for efficient access
- **Merkle tree authentication**: Each memory state has cryptographic digest for integrity
- **Copy-on-write semantics**: Efficient memory sharing with page state tracking (Unloaded/Loaded/Dirty)
- **Partial image generation**: Creates minimal memory representations for segment proofs
- **Cycle accounting**: Tracks memory operation costs

Key types:
- `PagedMemory`: Main memory interface
- `MemoryImage`: Complete authenticated memory state
- `WorkingImage`: Sparse representation of modified pages
- `PageTraceEvent`: Memory access event for trace generation

### System Call Interface (`syscall.rs`)
Enables communication between guest programs and the host environment:
- **Syscall trait**: Host-side system call handler interface
- **SyscallContext trait**: Provides guest memory access to syscall handlers
- **Memory inspection**: Non-side-effecting memory and register access for syscall processing

Key types:
- `Syscall`: System call handler trait
- `SyscallContext`: Guest context access interface

### RISC-V Machine (`r0vm.rs`)
Bridges the emulator with RISC Zero's execution context:
- **Privilege mode management**: Machine/user mode separation and transitions
- **Ecall dispatch**: Routes environment calls to appropriate handlers:
  - **Terminate**: Program termination with exit codes
  - **Host I/O**: Read/write operations with the host
  - **Cryptographic**: SHA2 and Poseidon2 hash acceleration
  - **BigInt**: Large integer arithmetic acceleration
- **Trap handling**: Exception processing and recovery
- **Register/memory abstraction**: Provides unified access interface

Key types:
- `Risc0Machine`: Main machine implementation
- `Risc0Context`: Execution context interface
- `EcallKind`: Environment call type enumeration

### Segments (`segment.rs`)
Bounded execution units that represent provable computation:
- **Execution bounds**: Typically 2^20 cycles to fit within circuit constraints
- **State capture**: Initial memory state, I/O records, and execution claims
- **Independent proving**: Each segment can be proven and verified separately
- **Deterministic replay**: Recorded I/O enables exact execution reproduction

Key types:
- `Segment`: Execution unit with state and claim
- `Rv32imV2Claim`: Cryptographic claim about segment execution

### Specialized Accelerators

#### BigInt Operations (`bigint/`)
Hardware-accelerated large integer arithmetic:
- **Montgomery multiplication**: Efficient modular multiplication
- **Multi-precision arithmetic**: Operations on arbitrary-precision integers
- **Cryptographic primitives**: RSA, elliptic curve operations

#### Hash Functions (`sha2.rs`, `poseidon2.rs`)
Optimized hash implementations:
- **SHA2**: Standard cryptographic hash with hardware acceleration
- **Poseidon2**: ZK-friendly hash function optimized for proof systems

#### Debugging Support (`gdb.rs`)
Full debugging capabilities:
- **GDB protocol**: Remote debugging interface
- **Breakpoints**: Code and data breakpoints
- **Step execution**: Single-step and continue operations
- **State inspection**: Register and memory examination

## Architecture Flow

### Execution Pipeline

1. **Initialization**
   - Load initial memory image into paged memory system
   - Set up execution context and register state
   - Initialize syscall handlers

2. **Segment Execution Loop**
   - Execute instructions until segment limit reached
   - Track all memory accesses and state changes
   - Record I/O operations for replay
   - Generate partial memory images

3. **Instruction Processing**
   - Fetch instruction from virtual memory
   - Decode using pattern matching
   - Execute with proper RISC-V semantics
   - Update program counter and registers

4. **System Call Handling**
   - Ecalls trigger privilege mode transition
   - Dispatch to appropriate handler based on call number
   - Handler accesses guest state through context interface
   - Results recorded for deterministic replay

5. **Segment Completion**
   - Suspend execution state for resumption
   - Commit dirty memory pages to segment image
   - Generate cryptographic claim about execution
   - Package segment with I/O records

6. **Session Termination**
   - Generate final segment with remaining cycles
   - Produce complete execution result
   - Return final memory state and claims

### Memory Management Flow

1. **Page Access**
   - Virtual address translation to page and offset
   - Check page state (Unloaded/Loaded/Dirty)
   - Load page from base image if needed
   - Mark page dirty on writes

2. **Merkle Tree Updates**
   - Recompute tree path for modified pages
   - Update parent nodes up to root
   - Generate new memory digest

3. **Partial Image Generation**
   - Collect only dirty pages for segment
   - Compute minimal Merkle tree representation
   - Include necessary authentication paths

### System Integration

The execute module integrates with other RISC Zero components:
- **Circuit system**: Provides execution traces for constraint generation
- **Proof system**: Segments become individual proof units
- **Host environment**: Syscalls enable host-guest communication
- **Memory system**: Authenticated memory enables state verification

## Usage Patterns

### Basic Execution
```rust
let mut executor = Executor::new(memory_image)?;
let result = executor.run()?;
```

### Segmented Execution
```rust
let mut executor = Executor::new(memory_image)?;
while !executor.is_terminated() {
    let segment = executor.step()?;
    // Process segment for proving
}
```

### Custom Syscalls
```rust
struct MySyscall;
impl Syscall for MySyscall {
    fn syscall(&mut self, ctx: &mut dyn SyscallContext) -> Result<bool> {
        // Handle custom syscall
    }
}
```

## Performance Characteristics

- **Instruction throughput**: ~1M instructions/second per core
- **Memory efficiency**: Copy-on-write minimizes memory usage
- **Parallel segment generation**: Scales with available CPU cores
- **Deterministic execution**: Identical results across runs and platforms

## Security Model

- **Memory isolation**: Guest programs cannot access host memory directly
- **Privilege separation**: Machine/user mode prevents privilege escalation
- **Cryptographic integrity**: Merkle trees authenticate all memory state
- **Deterministic execution**: No sources of non-determinism in guest execution

## File Structure

```
execute/
├── mod.rs              # Module exports and utilities
├── executor.rs         # Main execution coordinator
├── rv32im.rs          # RISC-V instruction emulator
├── pager.rs           # Paged virtual memory system
├── syscall.rs         # System call interface
├── r0vm.rs            # RISC-V machine implementation
├── segment.rs         # Execution segment management
├── platform.rs        # Platform constants and definitions
├── bigint.rs          # BigInt acceleration entry point
├── bigint/            # BigInt implementation details
├── sha2.rs            # SHA2 hash acceleration
├── poseidon2.rs       # Poseidon2 hash acceleration
├── gdb.rs             # GDB debugging interface
├── tests.rs           # Unit tests
└── testutil.rs        # Testing utilities
```

This module forms the foundation of RISC Zero's ability to execute arbitrary RISC-V programs while generating the cryptographic proofs that enable verifiable computation.