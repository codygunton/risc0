# RISC Zero zkVM Syscall System AI Documentation

## Component Overview

The syscall component provides secure two-way communication between the host environment and guest programs executing within RISC Zero's Zero-Knowledge Virtual Machine (zkVM). It implements a comprehensive system call interface that enables controlled interaction while maintaining the security guarantees required for zero-knowledge proof generation.

## Architecture

### Core Components

1. **Syscall Trait (`mod.rs`)** - Defines the fundamental interface for all system calls:
   - Standardized `syscall()` method signature for consistent handling
   - Receives syscall name, context, and guest communication buffers
   - Returns status codes and response data to the guest

2. **SyscallContext Trait (`mod.rs`)** - Provides secure access to guest state:
   - Memory access through controlled `load_*` methods
   - Register access for parameter passing (following RISC-V ABI)
   - Program counter and cycle tracking for execution monitoring
   - Access to the syscall table and execution environment

3. **SyscallTable (`mod.rs`)** - Central registry and execution coordinator:
   - Maps syscall names to handler implementations
   - Manages shared resources (I/O, assumptions, metrics)
   - Coordinates with coprocessors and external proof systems
   - Tracks syscall usage metrics for analysis

### Key Data Structures

- **`SyscallTable`** - Central registry containing:
  - `inner`: HashMap of syscall name → handler mappings
  - `posix_io`: POSIX-style I/O abstraction layer
  - `assumptions`: Zero-knowledge proof assumptions management
  - `coprocessor`: Optional external proof generation callbacks
  - `metrics`: Performance and usage tracking per syscall type

- **`SyscallContext`** - Security boundary interface providing:
  - Controlled memory access with bounds checking
  - Register access following RISC-V calling conventions
  - Execution state monitoring (PC, cycles)

- **`AssumptionReceipts`** - Zero-knowledge proof management:
  - Stores cryptographic receipts for proof verification
  - Manages proof dependencies and resolution chains
  - Validates control roots for specific recursion programs

## Functionality

### Security Model

The syscall system implements multiple layers of defensive security:

1. **Memory Isolation**: All guest memory access goes through controlled `load_*` methods that perform bounds checking and validate addresses
2. **Input Validation**: Each syscall validates input parameters and buffer sizes before processing
3. **Resource Limits**: Enforces maximum sizes for I/O operations and data structures
4. **Assumption Tracking**: Cryptographically tracks all zero-knowledge assumptions used during execution

### Syscall Categories

#### 1. **Verification Syscalls** (`verify.rs`, `verify2.rs`)
- **Purpose**: Validate zero-knowledge proof assumptions
- **Security**: Enforces cryptographic integrity through digest verification
- **Process**: 
  - Extracts claim digest and control root from guest memory
  - Searches assumption cache for matching receipts
  - Validates proof compatibility and control root requirements
  - Tracks assumption usage for audit trails

#### 2. **Cryptographic Operations** (`keccak.rs`)
- **Purpose**: Provides accelerated Keccak hash operations
- **Security**: Batches operations to prevent resource exhaustion
- **Features**:
  - Permute mode: Individual Keccak permutations
  - Prove mode: Generates zero-knowledge proofs of hash computations
  - Resource management: Enforces maximum batch sizes and power-of-2 limits

#### 3. **I/O Operations** (`posix_io.rs`, `slice_io.rs`)
- **Purpose**: Controlled data exchange with host environment
- **Security**: File descriptor isolation and buffer management
- **Types**:
  - POSIX I/O: Standard file operations with FD abstraction
  - Slice I/O: Custom data handlers with two-phase protocol
  - Pipe operations: Inter-process communication within zkVM

#### 4. **Environment Access** (`args.rs`, `getenv.rs`)
- **Purpose**: Controlled access to execution environment
- **Security**: Read-only access with size limits
- **Features**: Command-line arguments and environment variable access

#### 5. **System Services** (`random.rs`, `log.rs`, `panic.rs`)
- **Purpose**: Essential system functionality
- **Security**: Controlled resource allocation and error handling
- **Services**: Cryptographically secure randomness, logging, panic handling

### Memory Safety

All syscalls implement strict memory safety through:
- **Bounds Checking**: All memory accesses validate address ranges
- **Buffer Validation**: Input/output buffers are validated before use
- **Size Limits**: Maximum transfer sizes prevent resource exhaustion
- **Alignment Requirements**: Word-aligned operations for performance and safety

## Integration Points

### zkVM Executor Integration
- Integrated via `SyscallTable::from_env()` during executor initialization
- Receives execution environment containing I/O handles, assumptions, and configuration
- Provides syscall context implementation that bridges to RISC-V execution state

### Zero-Knowledge Proof System
- **Assumption Management**: Tracks and validates all cryptographic assumptions
- **Proof Dependencies**: Manages receipt chains and control root requirements
- **Coprocessor Integration**: Delegates complex proofs to specialized hardware/software
- **Metric Collection**: Provides performance data for proof optimization

### RISC-V ABI Compliance
- **Register Usage**: Follows standard RISC-V calling conventions (a0-a7 registers)
- **Memory Layout**: Respects standard RISC-V memory organization
- **Calling Convention**: Compatible with standard C library expectations

## Security Guarantees

### Host-Guest Isolation
- **Controlled Interface**: All communication goes through validated syscall interface
- **Memory Protection**: Guest cannot directly access host memory structures
- **Resource Limits**: Prevents guest programs from exhausting host resources
- **Cryptographic Validation**: All assumptions are cryptographically verified

### Zero-Knowledge Properties
- **Deterministic Execution**: Syscalls maintain deterministic behavior for proof generation
- **Assumption Tracking**: All external dependencies are explicitly tracked
- **Proof Integrity**: Validates all cryptographic assumptions before acceptance
- **Audit Trail**: Complete record of all syscall invocations and assumptions used

## Usage Context

This syscall system is designed for:
- **zkVM Guest Programs**: Providing system services to programs running in the zkVM
- **Zero-Knowledge Applications**: Supporting complex applications requiring external data or computation
- **Proof Composition**: Enabling modular proof systems through assumption management
- **Security-Critical Systems**: Maintaining isolation and validation in trustless environments

## Technical Notes

- **Thread Safety**: Uses `Rc<RefCell<>>` for interior mutability within single-threaded executor
- **Error Handling**: Comprehensive error propagation with detailed context information
- **Performance Optimization**: Batched operations and efficient memory management
- **Extensibility**: Plugin architecture allows custom syscall handlers via `SliceIo` interface
- **Metrics Collection**: Detailed performance tracking for optimization and debugging
- **RISC-V Compliance**: Full compatibility with standard RISC-V system call interface