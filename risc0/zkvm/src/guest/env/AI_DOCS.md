# RISC Zero zkVM Guest Environment

## Overview
This module provides the core environment functions for interacting with the RISC Zero zkVM from guest programs. It serves as the primary interface between guest code and the host system, handling I/O operations, proof verification, and system control.

## Key Components

### System Control
- **Program State Management**: Functions to pause and exit the zkVM execution
- **Entropy Management**: Handles memory image entropy for security
- **Lifecycle**: Initialization and finalization of guest execution

### I/O Operations
The module provides comprehensive I/O capabilities through multiple file descriptors:

- **STDIN/STDOUT/STDERR**: Standard input/output operations
- **Journal**: Public output that becomes part of the proof receipt
- **Serialization Support**: Both high-level serde and low-level slice operations

Performance-optimized slice variants are available for raw data operations, offering better cycle efficiency at the cost of ergonomics.

### Proof Verification
- **Receipt Verification**: Ability to verify RISC Zero receipts within guest programs
- **Proof Composition**: Support for composing multiple proofs
- **Assumption Tracking**: Maintains digest of verification assumptions

### Utility Functions
- **Logging**: Debug console output
- **Cycle Counting**: Performance measurement
- **Syscall Interface**: Low-level system call abstractions

## File Structure

- `mod.rs` - Main module with public API and global state management
- `read.rs` - Input operations and FdReader implementation
- `write.rs` - Output operations and FdWriter implementation  
- `verify.rs` - Proof verification functionality
- `batcher.rs` - Keccak proof batching optimization

## Safety Considerations
This module manages static mutable state safely within the single-threaded, non-preemptive zkVM environment. Global state includes hasher instances, assumption digests, and entropy values.

## Performance Notes
- Slice-based operations (`_slice` variants) are more cycle-efficient
- Frame-based reading reduces syscall overhead
- Keccak operations are batched for optimization
- Memory allocation uses custom layouts for word alignment