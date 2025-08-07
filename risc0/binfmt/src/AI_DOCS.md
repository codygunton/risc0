# risc0-binfmt AI Documentation

## Component Overview

The `risc0-binfmt` crate manages formatted binaries used by the RISC Zero zkVM. It provides essential functionality for handling ELF binaries, memory management, program execution, and cryptographic operations within the zero-knowledge virtual machine environment.

## Key Responsibilities

- **ELF Binary Processing**: Parsing and loading RISC-V ELF executables for zkVM execution
- **Memory Management**: Sophisticated paged memory system with Merkle tree-based integrity verification
- **Binary Format Handling**: Custom RISC Zero binary format for packaging user and kernel ELFs
- **Address Translation**: Safe address handling between byte and word addressing schemes
- **Cryptographic Hashing**: Structured hashing for program verification and integrity
- **Proof of Verifiable Work (PoVW)**: Support for verifiable work tracking and nonce management

## Core Components

### Memory Management (`image.rs`)
- **MemoryImage**: Central memory abstraction with 4GB address space (2^32 bytes)
- **Page**: 1KB memory pages with copy-on-write semantics and integrity hashing
- **Merkle Tree**: Binary tree structure for efficient memory integrity verification
- **Memory Modes**: Support for both user-mode and kernel-mode program execution
- Key constants: `USER_START_ADDR` (0x0001_0000), `KERNEL_START_ADDR` (0xc000_0000)

### ELF Processing (`elf.rs`)
- **Program**: Represents a loaded RISC-V program with entry point and memory image
- **ProgramBinary**: Container for combined user and kernel ELF binaries
- **ProgramBinaryHeader**: Metadata including ABI version and compatibility information
- **ELF Validation**: Strict validation of 32-bit RISC-V executable format
- **Binary Format**: Custom format with magic bytes "R0BF" and versioning

### Address Management (`addr.rs`)
- **ByteAddr**: Byte-level memory addressing with alignment checking
- **WordAddr**: Word-aligned (4-byte) addressing for RISC-V architecture
- **Page Organization**: 256-word pages (1024 bytes each) for memory management
- **Address Translation**: Safe conversion between byte and word addressing modes

### Cryptographic Operations (`hash.rs`)
- **Digestible Trait**: Collision-resistant hashing for structured data
- **Tagged Hashing**: Domain-separated hashing for different data types
- **Merkle Tree Support**: Efficient hashing for tree-based data structures
- **SHA-256 Integration**: Uses RISC Zero's optimized SHA implementation

### Proof of Verifiable Work (`povw.rs`)
- **PovwNonce**: 256-bit unique identifiers for segment proofs
- **PovwJobId**: Globally unique job identifiers combining log and job numbers
- **PovwLogId**: 160-bit work log identifiers for tracking proof work
- **Work Tracking**: Prevents double-counting of computational work

## System Integration

### Memory Architecture
```rust
// Memory layout with 4GB address space
const MEMORY_BYTES: u64 = 1 << 32;        // 4GB total
const PAGE_BYTES: usize = 1024;            // 1KB pages
const PAGE_WORDS: usize = PAGE_BYTES / 4;  // 256 words per page
```

### Binary Format Structure
```
[Magic: "R0BF"] [Version: u32] [Header Length: u32] [Header Data] [User ELF Length: u32] [User ELF] [Kernel ELF]
```

### Address Translation
- **ByteAddr → WordAddr**: Division by 4 (word size), truncates unaligned addresses
- **WordAddr → ByteAddr**: Multiplication by 4, always produces aligned addresses
- **Page Addressing**: Pages indexed by word address divided by 256

## Security Considerations

### Memory Integrity
- All memory pages are cryptographically hashed using Poseidon2
- Merkle tree structure enables efficient integrity verification
- Zero pages are handled specially to avoid unnecessary storage

### ELF Validation
- Strict validation of ELF format and RISC-V architecture
- Memory bounds checking prevents buffer overflows
- Entry point validation ensures proper program initialization

### Address Safety
- Type-safe address handling prevents addressing errors
- Alignment checking prevents unaligned memory access
- Page boundaries are strictly enforced

## Performance Optimizations

### Memory Management
- Copy-on-write semantics for shared zero pages
- Lazy expansion of zero regions in Merkle tree
- Efficient page-based memory organization

### Hashing
- Incremental hashing for large data structures
- Optimized Poseidon2 implementation for page hashing
- Tagged hashing prevents collision attacks

### Binary Loading
- Stream-based ELF parsing for memory efficiency
- Validation during loading prevents invalid programs
- Efficient memory image construction

## API Usage Patterns

### Loading Programs
```rust
// Load ELF into memory image
let program = Program::load_elf(elf_bytes, max_memory)?;
let memory_image = MemoryImage::new_user(program);

// Combined user/kernel loading
let combined_image = MemoryImage::with_kernel(user_program, kernel_program);
```

### Binary Format Operations
```rust
// Create and encode binary
let binary = ProgramBinary::new(user_elf, kernel_elf);
let encoded = binary.encode();

// Decode and extract
let decoded = ProgramBinary::decode(&encoded)?;
let memory_image = decoded.to_image()?;
let image_id = decoded.compute_image_id()?;
```

### Memory Access
```rust
// Safe address handling
let byte_addr = ByteAddr(0x1000);
let word_addr = byte_addr.waddr();  // Convert to word address
let page_idx = word_addr.page_idx(); // Get containing page

// Memory operations
let page = memory_image.get_page(page_idx)?;
let data = page.load(word_addr);
```

## Dependencies and Integration

### External Dependencies
- **elf**: ELF file parsing and validation
- **risc0-zkp**: Cryptographic primitives and hash functions
- **risc0-zkvm-platform**: Platform constants and definitions
- **serde**: Serialization for binary format handling
- **anyhow**: Error handling throughout the crate

### Internal Integration
- Provides memory abstraction for zkVM execution
- Supplies binary format for program distribution
- Enables integrity verification for proof generation
- Supports work tracking for verifiable computation

This crate forms the foundation for program execution in the RISC Zero zkVM, providing secure, efficient, and verifiable binary handling capabilities.