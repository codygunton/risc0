# RISC-V zkVM Profiler AI Documentation

## Component Overview

The profiler component provides comprehensive performance analysis for RISC Zero's Zero-Knowledge Virtual Machine (zkVM). It tracks execution cycles, manages call stacks, and generates profiling data compatible with pprof for flame graph visualization.

## Architecture

### Core Components

1. **Profiler (`profiler.rs`)** - Main profiling engine that:
   - Tracks program counter (PC) and instruction execution
   - Manages function call stacks using RISC-V calling conventions
   - Counts cycles spent in each function/location
   - Generates pprof-compatible protobuf output

2. **Inline Function Handler (`inline.rs`)** - DWARF debug information processor that:
   - Extracts inline function metadata from DWARF debug sections
   - Builds lookup tables for inline function resolution
   - Maps program counter ranges to abstract function origins

### Key Data Structures

- **`CallNode`** - Tree structure representing unique call stacks with cycle counts
- **`Frame`** - Function frame information (name, line, filename)
- **`InlineFunctionTable`** - Maps program counters to inline function metadata
- **`ProfileBuilder`** - Constructs pprof protobuf format output

## Functionality

### Call Stack Tracking
- Monitors JAL/JALR instructions to detect function calls/returns
- Maintains return address stack for proper call stack unwinding
- Supports inline function tracking via DWARF debug information
- Handles zkVM-specific operations (PageIn/PageOut)

### Cycle Attribution
- Tracks "user cycles" (excludes paging and padding overhead)
- Attributes cycles to specific call stack contexts
- Accumulates execution time per function and call path

### Debug Information Processing
- Parses ELF binaries and DWARF debug sections
- Resolves function names, source locations, and inline functions
- Builds symbol tables from ELF function symbols
- Supports both DWARF-based and symbol-table-based function resolution

## Integration Points

### TraceCallback Interface
Implements `TraceCallback` to process execution trace events:
- `InstructionStart` - Updates PC, handles call/return operations
- `PageIn`/`PageOut` - Tracks zkVM memory paging cycles
- Other events are ignored

### Environment Variables
- `RISC0_PPROF_ENABLE_INLINE_FUNCTIONS` - Enables/disables inline function tracking

## Output Format

Generates pprof-compatible protobuf containing:
- Sample data with call stack location IDs and cycle counts
- Function metadata (names, filenames, line numbers)
- Memory mapping information for the executable
- String table for efficient storage

## Usage Context

This profiler is designed for:
- Performance analysis of zkVM guest programs
- Identifying computational bottlenecks in zero-knowledge proof generation
- Understanding cycle allocation across different program sections
- Generating flame graphs for visual performance analysis

## Technical Notes

- Supports both little-endian and big-endian RISC-V binaries
- Uses addr2line crate for DWARF processing
- Employs gimli for low-level DWARF parsing
- Implements demangling for Rust function names
- Handles cross-compilation scenarios with proper endianness detection