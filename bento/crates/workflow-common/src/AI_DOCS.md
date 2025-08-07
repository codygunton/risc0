# workflow-common

## Overview
The `workflow-common` crate provides shared data structures and utilities for the RISC Zero Bento workflow system. It serves as a common foundation for distributed zero-knowledge proof generation workflows, defining task types, request/response structures, and S3 object storage integration.

## Core Components

### Task Types and Workflow Definitions
- **Task Types**: Comprehensive enum (`TaskType`) covering all workflow stages:
  - `Executor`: Initial program execution with image and input
  - `Prove`: rv32im proof generation and lifting
  - `Join`: Proof joining operations for parallelization
  - `Union`: Union operations for proof aggregation
  - `Resolve`: Final resolution of joined proofs
  - `Finalize`: Workflow finalization
  - `Snark`: STARK to SNARK compression (Groth16)
  - `Keccak`: Keccak coprocessor operations

### Request/Response Structures
- **ExecutorReq/ExecutorResp**: Program execution with cycle counting and assumptions support
- **ProveReq**: Segment-based proof generation
- **JoinReq/UnionReq**: Tree-based proof aggregation with left/right indexing
- **ResolveReq/FinalizeReq**: Workflow completion handling
- **SnarkReq/SnarkResp**: STARK-to-SNARK compression with configurable types
- **KeccakReq**: Keccak coprocessor integration with claim digests

### S3 Object Storage Client
Comprehensive S3-compatible storage interface with:
- **Minio Integration**: Direct support for local/development MinIO instances
- **Bucket Management**: Automatic bucket provisioning and configuration
- **Serialization Support**: Built-in bincode serialization for Rust objects
- **File Operations**: Direct file uploads and byte buffer handling
- **Object Existence**: Efficient object existence checking

## Architecture

### Worker Stream Identifiers
The crate defines constants for different worker types:
- `AUX_WORK_TYPE`: Auxiliary worker operations
- `EXEC_WORK_TYPE`: Execution workers
- `PROVE_WORK_TYPE`: Proof generation workers
- `COPROC_WORK_TYPE`: Coprocessor workers (Keccak)
- `JOIN_WORK_TYPE`: Proof joining workers
- `SNARK_WORK_TYPE`: SNARK compression workers

### Storage Organization
S3 bucket directories are well-defined:
- `elfs/`: Compiled ELF binaries
- `inputs/`: Execution inputs
- `receipts/`: Proof receipts
- `stark/`: STARK proofs
- `groth16/`: Groth16 SNARK proofs
- `exec_logs/`: Execution logs
- `preflight_journals/`: Pre-execution journals
- `keccak_receipts/`: Keccak coprocessor receipts

## Key Features

### Compression Support
- **CompressType Enum**: Configurable compression (None, Groth16)
- **SNARK Integration**: Full STARK-to-SNARK conversion pipeline
- **Timeout Configuration**: Configurable SNARK generation timeouts

### Execution Control
- **Cycle Limits**: Configurable execution limits in mega-cycles
- **Assumption Handling**: Support for proof assumptions and dependencies
- **Execute-Only Mode**: Option to run execution without proof generation

### Distributed Processing
- **Segment-Based Proving**: Parallel proof generation via segment indexing
- **Tree-Based Joining**: Hierarchical proof aggregation
- **User Isolation**: User-based work stream partitioning

## Usage Context
This crate is primarily used by:
- Workflow orchestration systems
- Distributed proof generation workers
- S3-based artifact storage systems
- RISC Zero Bento infrastructure components

The design enables scalable, distributed zero-knowledge proof generation with proper task isolation, artifact management, and workflow coordination.