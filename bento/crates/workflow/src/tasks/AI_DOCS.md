# Workflow Tasks Module

## Overview

The `tasks` module contains the core task execution logic for the RISC Zero workflow system. This module handles various types of cryptographic proof operations, including segment proving, joining receipts, resolving assumptions, and finalizing proofs. It serves as the computational backbone for distributed zero-knowledge proof generation.

## Core Components

### Module Structure
- **mod.rs**: Main module declarations and utility functions for serialization/deserialization
- **executor.rs**: Primary execution engine that runs ELF binaries and manages proof generation workflow
- **prove.rs**: Individual segment proving operations
- **join.rs**: Combines multiple receipts into hierarchical proof structures
- **resolve.rs**: Resolves assumptions and dependencies in conditional receipts
- **finalize.rs**: Creates final rollup receipts and uploads to persistent storage
- **keccak.rs**: Specialized Keccak hash proving operations
- **snark.rs**: STARK to SNARK conversion for proof compression
- **union.rs**: Combines Keccak receipts for coprocessor operations

## Key Functionality

### Execution Pipeline (`executor.rs`)
The executor serves as the orchestrator for the entire proof generation workflow:

1. **ELF Validation**: Validates ELF binaries and computes image IDs
2. **Segment Generation**: Executes guest programs and produces execution segments
3. **Task Planning**: Uses a planner to create dependency graphs for proof operations
4. **Parallel Processing**: Manages concurrent segment writing and task creation
5. **Resource Management**: Handles Redis storage, S3 operations, and database interactions

Key features:
- Async segment flushing with configurable concurrency limits
- Support for execution-only mode (no proving)
- Coprocessor callback integration for specialized operations
- Assumption receipt validation and management

### Proof Operations

#### Segment Proving (`prove.rs`)
- Proves individual execution segments using the RISC Zero prover
- Lifts segment receipts to succinct form
- Stores results in Redis with TTL management

#### Join Operations (`join.rs`)
- Combines pairs of receipts into hierarchical structures
- Implements binary tree reduction for scalable proof aggregation
- Maintains proof integrity across join operations

#### Resolution (`resolve.rs`)
- Resolves conditional receipts with their assumptions
- Handles both standard assumptions and union (Keccak) receipts
- Supports multi-assumption resolution workflows

#### Finalization (`finalize.rs`)
- Creates final rollup receipts from resolved proofs
- Verifies receipt integrity against original image ID
- Uploads final receipts to S3 storage
- Cleans up Redis keys after completion

#### Specialized Operations

**Keccak Proving (`keccak.rs`)**
- Handles Keccak hash function proving for coprocessor callbacks
- Converts input data to proper Keccak state format
- Integrates with the main proof pipeline

**SNARK Conversion (`snark.rs`)**
- Converts STARK proofs to Groth16 SNARKs for compression
- Uses external proving tools (stark_verify, gnark prover)
- Manages temporary file operations and process coordination

**Union Operations (`union.rs`)**
- Combines multiple Keccak receipts
- Supports coprocessor proof aggregation
- Maintains receipt provenance through union operations

## Data Flow

1. **Input**: ELF binary, input data, and optional assumptions
2. **Execution**: Guest program runs, producing segments and coprocessor calls
3. **Proving**: Segments are proven in parallel, creating a proof tree
4. **Aggregation**: Proofs are joined hierarchically using binary tree reduction
5. **Resolution**: Assumptions are resolved into the final conditional receipt
6. **Finalization**: Final receipt is created, verified, and stored

## Storage Architecture

### Redis Keys
- `job:{job_id}:segments:{index}`: Execution segments
- `job:{job_id}:recursion_receipts:{task_id}`: Intermediate proof receipts
- `job:{job_id}:receipts:{claim}`: Assumption receipts
- `job:{job_id}:coproc:{digest}`: Coprocessor callback data
- `job:{job_id}:keccak_receipts:{task_id}`: Keccak proof receipts

### S3 Storage
- ELF binaries, input data, execution logs
- Final receipts (STARK and Groth16)
- Assumption receipt storage

## Error Handling

The module implements comprehensive error handling with:
- Context-rich error messages for debugging
- Graceful failure handling in concurrent operations
- Resource cleanup on failures
- Proper error propagation through the async pipeline

## Performance Considerations

- **Concurrency**: Configurable limits for segment processing and task creation
- **Memory Management**: Streaming operations for large data
- **Resource Pooling**: Redis connection pooling and S3 client reuse
- **TTL Management**: Automatic cleanup of temporary Redis data

## Integration Points

- **TaskDB**: Task queue management and dependency tracking
- **Redis**: Hot storage for intermediate results
- **S3**: Cold storage for persistent data
- **RISC Zero Prover**: Core proving engine integration
- **Database**: Job metadata and stream management

This module forms the core computational engine of the RISC Zero workflow system, enabling scalable and efficient zero-knowledge proof generation through distributed task execution.