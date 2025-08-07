# RISC Zero zkVM Serde Component

## Overview

The `risc0_zkvm::serde` module provides specialized serialization and deserialization functionality for the RISC Zero zero-knowledge virtual machine (zkVM). This module enables efficient data transmission between the zkVM host and guest environments using a custom binary format optimized for 32-bit word-aligned operations.

## Core Purpose

- **Host-Guest Communication**: Serializes data for transmission from host to guest and vice versa
- **Word-Aligned Format**: Optimized for 32-bit word boundaries to match zkVM architecture
- **Compact Binary Encoding**: Non-human-readable binary format for minimal overhead
- **Cross-Environment Compatibility**: Ensures consistent data representation across host and guest

## Architecture

### Main Components

1. **Serializer** (`serializer.rs`) - Converts Rust types to binary format
2. **Deserializer** (`deserializer.rs`) - Converts binary format back to Rust types  
3. **Error Handling** (`err.rs`) - Custom error types for serialization operations
4. **Module Interface** (`mod.rs`) - Public API and convenience functions

### Key Traits

- `WordWrite`: Abstract interface for writing word-aligned data streams
- `WordRead`: Abstract interface for reading word-aligned data streams

## Public API

### High-Level Functions

```rust
// Serialize any serde-compatible type to Vec<u32>
pub fn to_vec<T: serde::Serialize>(value: &T) -> Result<Vec<u32>>

// Serialize with capacity hint for better performance
pub fn to_vec_with_capacity<T: serde::Serialize>(value: &T, cap: usize) -> Result<Vec<u32>>

// Deserialize from slice of any Pod type (usually u32)
pub fn from_slice<T: DeserializeOwned, P: Pod>(slice: &[P]) -> Result<T>
```

### Core Types

- `Serializer<W: WordWrite>`: Main serialization engine
- `Deserializer<R: WordRead>`: Main deserialization engine
- `Error`: Comprehensive error enum for all operations
- `Result<T>`: Alias for `core::result::Result<T, Error>`

## Data Format Specification

### Basic Types

- **Integers**: All integers (i8, u8, i16, u16, i32, u32) are serialized as single u32 words
- **64-bit values**: Serialized as two u32 words (low, high)
- **128-bit values**: Serialized as padded byte arrays (16 bytes)
- **Floats**: f32 stored as single word (bits), f64 as two words
- **Booleans**: 0 for false, 1 for true
- **Characters**: Stored as u32 unicode codepoint

### Complex Types

- **Strings/Bytes**: Length prefix (u32) + padded byte data
- **Sequences**: Length prefix (u32) + serialized elements
- **Maps**: Length prefix (u32) + serialized key-value pairs
- **Options**: Discriminant (0/1) + optional value
- **Enums**: Variant index + variant data
- **Structs/Tuples**: Direct field serialization (no metadata)

### Padding Behavior

All byte data is padded to 32-bit word boundaries:
- Bytes are grouped into 4-byte chunks
- Final partial chunk is zero-padded
- Ensures word-aligned memory access

## Usage Examples

### Basic Serialization
```rust
use risc0_zkvm::serde::{to_vec, from_slice};

let data = 42u32;
let serialized = to_vec(&data)?;
let deserialized: u32 = from_slice(&serialized)?;
```

### Complex Data Structures
```rust
use std::collections::BTreeMap;

let map: BTreeMap<String, u32> = BTreeMap::from([
    ("foo".into(), 1),
    ("bar".into(), 2)
]);
let serialized = to_vec(&map)?;
let deserialized: BTreeMap<String, u32> = from_slice(&serialized)?;
```

### Performance Optimization
```rust
// Pre-allocate capacity for better performance
let estimated_size = std::mem::size_of_val(&large_data) / 4;
let serialized = to_vec_with_capacity(&large_data, estimated_size)?;
```

## Error Handling

### Error Types

- `Custom(String)`: User-defined error messages
- `DeserializeBadBool`: Invalid boolean value (not 0 or 1)
- `DeserializeBadChar`: Invalid Unicode character
- `DeserializeBadOption`: Invalid Option discriminant
- `DeserializeBadUtf8`: Invalid UTF-8 sequence
- `DeserializeUnexpectedEnd`: Premature end of data
- `NotSupported`: Unsupported operation
- `SerializeBufferFull`: Buffer overflow during serialization

### Error Recovery

The serializer/deserializer does not support partial recovery from errors. Any error during operation should be treated as fatal for that serialization session.

## Performance Characteristics

### Optimizations

- **Word Alignment**: All data aligned to 32-bit boundaries for efficient access
- **Zero-Copy Reading**: Slice-based reading avoids unnecessary allocations
- **Capacity Hints**: Pre-allocation reduces reallocation overhead
- **Streaming Interface**: Supports large data without full buffering

### Memory Usage

- Serialized data typically 100-125% of original size due to padding
- Temporary allocations for string/byte processing
- Vec<u32> storage for final serialized output

## Integration Points

### Host Side Usage
- Used by zkVM execution environment to send inputs to guest
- Receives outputs from guest programs
- Integrates with proof generation pipeline

### Guest Side Usage
- Typically accessed through `env::read()` and `env::commit()` functions
- Direct usage rare in guest code
- Automatic integration with guest runtime

## Limitations

### Unsupported Features

- `deserialize_any()`: Dynamic type discovery not supported
- `deserialize_identifier()`: Field name resolution not supported  
- `deserialize_ignored_any()`: Skipping unknown fields not supported
- Infinite sequences: All sequences must have known length

### Format Constraints

- Non-human-readable binary format only
- No schema evolution support
- No compression built-in
- Fixed endianness (little-endian)

## Security Considerations

### Input Validation

- UTF-8 validation for strings
- Unicode codepoint validation for chars
- Length bounds checking for collections
- Memory allocation limits implicit through available memory

### Attack Vectors

- **Length Amplification**: Malicious length prefixes could cause excessive allocation
- **Invalid Data**: Corrupted input could cause parsing failures
- **Resource Exhaustion**: Large nested structures could exhaust stack/heap

### Mitigations

- Rust's memory safety prevents buffer overflows
- Length validation prevents most amplification attacks
- Error propagation prevents silent corruption

## Testing Coverage

### Unit Tests

- Round-trip testing for all basic types
- Complex data structure serialization
- Error condition validation
- Edge case handling (empty collections, max values)

### Integration Tests

- Host-guest communication scenarios
- Large data structure handling
- Performance benchmarking
- Cross-platform compatibility

## Dependencies

### External Crates

- `serde`: Core serialization framework
- `bytemuck`: Safe byte casting operations
- `risc0_zkvm_platform`: Platform-specific constants (WORD_SIZE)

### Internal Dependencies

- `crate::align_up`: Utility for alignment calculations
- Standard library alternatives for no_std compatibility

## Future Considerations

### Potential Improvements

- **Compression**: Optional compression for large payloads
- **Schema Evolution**: Version-aware deserialization
- **Streaming**: Support for infinite/large sequences
- **Optimization**: SIMD-optimized word operations

### Compatibility

- Current format should remain stable for existing proofs
- New features should be additive and optional
- Consider versioning for major format changes