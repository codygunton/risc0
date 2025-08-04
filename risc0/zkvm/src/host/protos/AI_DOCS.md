# Protocol Buffer Definitions for RISC Zero zkVM Host API

## Overview
This directory contains Protocol Buffer (protobuf) definitions that define the API interface for the RISC Zero zkVM host system. These definitions are used for communication between different components of the zkVM infrastructure and provide a structured way to handle proving, execution, and verification operations.

## Files

### Core Protocol Definitions
- **`api.proto`** - Main API definitions for the zkVM server including:
  - Server request/response types for proving, execution, verification
  - Asset management and storage (inline, file path, Redis)
  - Execution environment configuration
  - Prover options and receipt types (Composite, Succinct, Groth16)
  - Callback interfaces for streaming operations

- **`base.proto`** - Fundamental data types:
  - `SemanticVersion` for version management
  - `Digest` for cryptographic hashes
  - `ExitCode` for execution status handling

- **`core.proto`** - Core zkVM data structures:
  - Receipt types (Composite, Succinct, Groth16, Fake)
  - Claims and proofs
  - Session statistics and metadata
  - Merkle proof structures

### Generated Rust Code
- **`api.rs`**, **`base.rs`**, **`core.rs`** - Generated Rust bindings from protobuf definitions
- **`mod.rs`** - Module declarations and custom `Debug` implementations for API types

## Key Concepts

### Asset Management
The API supports multiple asset storage backends:
- **Inline**: Data embedded directly in messages
- **File Path**: Assets stored on local filesystem
- **Redis**: Assets stored in Redis with TTL support

### Receipt Types
- **Composite**: Multi-segment receipts for large computations
- **Succinct**: Compressed proofs for efficient verification
- **Groth16**: Zero-knowledge proofs using Groth16 protocol

### Execution Flow
1. **Execute**: Run zkVM programs with specified environment
2. **Prove**: Generate cryptographic proofs of execution
3. **Verify**: Validate proofs against expected outputs
4. **Lift/Join/Compress**: Transform and combine receipts

## Service Interfaces

### Server Service
Main proving and execution service with methods:
- `hello()` - Version negotiation
- `prove()` - Generate proofs (streaming)
- `execute()` - Run programs (streaming)
- `prove_segment()` - Prove individual segments
- `lift()`, `join()`, `resolve()`, `compress()` - Receipt operations
- `verify()` - Proof verification

### Callback Services
- **ExecuteCallback**: Handle I/O and execution events
- **ProveCallback**: Handle proving completion events

## Usage Context
These protobuf definitions are central to the RISC Zero zkVM's distributed architecture, enabling:
- Remote proving services
- Scalable execution across multiple hosts
- Standardized communication protocols
- Asset caching and storage optimization

The generated Rust code integrates with the broader zkVM codebase to provide type-safe, efficient serialization for all host-level operations.