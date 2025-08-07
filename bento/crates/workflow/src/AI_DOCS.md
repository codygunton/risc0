# RISC Zero Workflow Agent

## Overview

The RISC Zero Workflow Agent is a distributed task processing system designed for scalable zero-knowledge proof generation. It provides a robust, fault-tolerant architecture for executing complex cryptographic workflows involving RISC Zero proving operations, from initial ELF execution through final proof aggregation and storage.

## Architecture

### Core Components

**Agent (`lib.rs`)**
- Central orchestrator for distributed task processing
- Manages connection pools (PostgreSQL, Redis, S3)
- Implements task polling, dispatching, and error handling
- Provides signal handling for graceful shutdown
- Coordinates between taskdb, Redis cache, and persistent storage

**Redis Integration (`redis.rs`)**
- High-performance caching layer for intermediate results
- Connection pooling with deadpool-redis
- TTL-based automatic cleanup of temporary data
- Efficient key scanning and batch deletion operations
- Pipeline operations for optimal Redis performance

**Task Processing (`tasks/`)**
- Modular task execution system supporting multiple proof operations
- Async processing with configurable concurrency limits
- Comprehensive error handling and retry mechanisms
- Integration with RISC Zero prover infrastructure

**Binary Entry Point (`bin/agent.rs`)**
- Command-line interface for agent deployment
- Database migration management
- Tracing and logging configuration
- Environment-based configuration loading

### Key Features

**Distributed Processing**
- Multi-agent deployment support with stream-based task partitioning
- Configurable worker specialization (cpu, prove, join, snark, etc.)
- Load balancing through taskdb queue management
- Horizontal scaling capabilities

**Fault Tolerance**
- Automatic task retry with configurable limits
- Timeout detection and recovery
- Background monitoring for stuck tasks
- Graceful degradation on component failures

**Resource Management**
- Connection pooling for all external services
- Memory-efficient streaming operations
- TTL-based cleanup of temporary resources
- Configurable resource limits and timeouts

**Security & Monitoring**
- Comprehensive logging with structured tracing
- Error context preservation for debugging
- Signal handling for operational control
- Database migration management

## Task Types & Processing Pipeline

### Execution Tasks (`TaskType::Executor`)
- ELF binary validation and image ID computation
- Guest program execution with segment generation
- Coprocessor callback handling
- Assumption receipt validation
- Planning and dependency graph creation

### Proving Tasks (`TaskType::Prove`)
- Individual segment proof generation
- STARK proof lifting to succinct form
- Redis-based result caching with TTL
- Integration with RISC Zero prover server

### Aggregation Tasks
- **Join** (`TaskType::Join`): Binary tree proof aggregation
- **Resolve** (`TaskType::Resolve`): Assumption resolution into conditional receipts
- **Finalize** (`TaskType::Finalize`): Final rollup receipt creation and S3 upload
- **Union** (`TaskType::Union`): Coprocessor proof combination

### Specialized Tasks
- **Keccak** (`TaskType::Keccak`): Hash function proving for coprocessor operations
- **SNARK** (`TaskType::Snark`): STARK to Groth16 conversion for proof compression

## Configuration & Deployment

### Command Line Interface

```bash
# Basic agent deployment
cargo run --bin agent -- --task-stream cpu --database-url $DATABASE_URL --redis-url $REDIS_URL

# Specialized prover agent
cargo run --bin agent -- --task-stream prove --segment-po2 20 --prove-retries 3

# Background monitoring agent
cargo run --bin agent -- --task-stream aux --monitor-requeue
```

### Environment Variables

**Required**
- `DATABASE_URL`: PostgreSQL connection string
- `REDIS_URL`: Redis connection string  
- `S3_BUCKET`, `S3_ACCESS_KEY`, `S3_SECRET_KEY`, `S3_URL`: S3/MinIO configuration

**Optional**
- `S3_REGION`: AWS region (default: us-west-2)
- Logging configuration through `RUST_LOG`

### Configuration Parameters

**Performance Tuning**
- `--poll-time`: Task polling interval (default: 1s)
- `--segment-po2`: RISC Zero segment size (default: 20)
- `--db-max-connections`: Database pool size (default: 1)
- `--exec-cycle-limit`: Execution cycle limit (default: 100M)

**Fault Tolerance**
- `--prove-retries/timeout`: Prove task retry/timeout settings
- `--join-retries/timeout`: Join task retry/timeout settings  
- `--resolve-retries/timeout`: Resolve task retry/timeout settings
- `--finalize-retries/timeout`: Finalize task retry/timeout settings
- `--snark-retries/timeout`: SNARK task retry/timeout settings

**Storage Management**
- `--redis-ttl`: Redis key expiration time (default: 8 hours)

## Data Flow Architecture

### Storage Layers

**Hot Storage (Redis)**
- Execution segments: `job:{job_id}:segments:{index}`
- Intermediate receipts: `job:{job_id}:recursion_receipts:{task_id}` 
- Assumption receipts: `job:{job_id}:receipts:{claim}`
- Coprocessor data: `job:{job_id}:coproc:{digest}`
- Keccak receipts: `job:{job_id}:keccak_receipts:{task_id}`

**Cold Storage (S3)**
- ELF binaries and input data
- Final STARK and Groth16 receipts
- Execution logs and metadata
- Assumption receipt archives

**Metadata Storage (PostgreSQL)**
- Task queue and dependency management
- Job status and progress tracking
- Agent stream assignments
- Retry and failure tracking

### Processing Workflow

1. **Task Ingestion**: Agent polls taskdb for available work on assigned stream
2. **Task Dispatch**: Work distributed to appropriate task handler based on type
3. **Execution**: Task-specific processing with resource management
4. **Result Storage**: Intermediate results cached in Redis, finals in S3
5. **Completion**: Task marked complete in taskdb, dependencies updated
6. **Error Handling**: Failures trigger retry logic or permanent failure marking

## Integration Points

### RISC Zero Ecosystem
- **risc0-zkvm**: Core proving infrastructure integration
- **ProverServer**: Hardware-optimized proving backends
- **VerifierContext**: Receipt validation and verification
- **Coprocessor**: Specialized circuit integration (Keccak, etc.)

### External Dependencies
- **taskdb**: Distributed task queue and dependency management
- **workflow-common**: Shared types and utilities
- **Redis**: High-performance caching and pub/sub
- **PostgreSQL**: Persistent metadata and queue state
- **S3/MinIO**: Object storage for large artifacts

### Operational Integration
- **Docker/Kubernetes**: Containerized deployment support
- **Metrics/Monitoring**: Structured logging with tracing integration
- **CI/CD**: Database migration automation
- **Load Balancing**: Stream-based work distribution

## Development & Operations

### Build Features
- Default: Standard CPU-based proving
- `cuda`: GPU acceleration support for compatible hardware

### Monitoring & Debugging
- Structured tracing with configurable log levels
- Error context preservation throughout async pipeline
- Performance metrics through task timing
- Resource utilization tracking

### Operational Considerations
- Database migrations handled automatically on startup
- Graceful shutdown with SIGTERM handling
- Background task monitoring for operational health
- Redis TTL management prevents memory leaks
- S3 cleanup policies for cost management

This workflow agent serves as the computational backbone of the RISC Zero distributed proving system, enabling scalable, fault-tolerant zero-knowledge proof generation across heterogeneous infrastructure deployments.