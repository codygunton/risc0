# r0vm - RISC Zero VM Executable

## Overview
The r0vm component is a comprehensive command-line interface and distributed execution system for the RISC Zero zero-knowledge virtual machine (ZKVM). It provides multiple execution modes for running RISC-V ELF binaries within the RISC Zero ZKVM environment, supporting both standalone execution and distributed processing through an actor-based architecture.

## Core Architecture

### Main Execution Modes
The r0vm binary supports several distinct operational modes:

1. **Direct ELF/Image Execution**: Run RISC-V binaries directly with proof generation
2. **RPC Mode**: High-performance mode using multiple GPU workers 
3. **Manager Mode**: Distributed task coordination
4. **Worker Mode**: Distributed task execution
5. **Server Mode**: HTTP API server for external integrations

### Key Components

#### Command Line Interface (`lib.rs`)
- Comprehensive CLI built with clap for configuration management
- Support for multiple hash functions (SHA-256, Poseidon2)
- Configurable receipt types (Composite, Succinct, Groth16)
- Environment variable injection and input handling
- Profiling and debugging capabilities

#### Actor System (`actors/`)
- **ManagerActor**: Orchestrates job distribution and coordination
- **FactoryActor**: Creates and manages task instances
- **Worker**: Executes specific task types (Execute, ProveSegment, ProveKeccak, Lift, Join, Union, Resolve)
- **RPC System**: High-performance communication between distributed components

#### REST API (`api.rs`)
- Bonsai SDK-compatible HTTP interface
- Image, input, and receipt upload/download
- STARK and Groth16 proving endpoints
- Job status tracking and result retrieval

## Task Types and Distribution

### Task Categories
- **Execute**: Run RISC-V programs and generate execution traces
- **ProveSegment**: Generate proofs for execution segments
- **ProveKeccak**: Generate Keccak hash proofs
- **Lift**: Recursion lifting operations
- **Join**: Combine multiple proofs
- **Union**: Proof union operations  
- **Resolve**: Final proof resolution

### GPU Acceleration
- Automatic GPU detection via NVML
- Multi-GPU support for parallel proving
- CUDA device management and allocation

## Key Features

### Proof Generation
- Support for multiple receipt kinds (Composite, Succinct, Groth16)
- Configurable hash functions for security/performance trade-offs
- Error state proving capabilities
- Segment limit configuration

### Distributed Processing
- Manager/worker architecture for horizontal scaling
- Network-based task distribution
- Fault tolerance and retry mechanisms
- Load balancing across worker pools

### Integration Capabilities
- Bonsai SDK compatibility for existing workflows
- File-based storage for images, inputs, and receipts
- OpenTelemetry integration for monitoring and observability
- Configurable storage backends

## Security Considerations

### Input Validation
- Path traversal protection in file operations
- Image ID verification against computed hashes
- Size limits on uploads (250MB default)
- Secure handling of execution environments

### Network Security
- Optional API key authentication framework
- Isolated worker processes
- Secure inter-process communication

## Performance Optimization

### Resource Management
- Configurable worker pool sizes
- GPU memory monitoring and allocation
- Efficient binary serialization with bincode
- Streaming I/O for large data transfers

### Telemetry and Monitoring
- Comprehensive metrics collection
- Distributed tracing support
- Performance profiling capabilities
- Resource utilization tracking

## Usage Patterns

### Development Workflow
```bash
# Direct execution with proof generation
r0vm --elf program.elf --receipt proof.bin

# Distributed execution
r0vm --manager --addr 0.0.0.0:8080 --api 0.0.0.0:8081
r0vm --worker execute,prove-segment --addr manager_address:8080
```

### Integration Scenarios
- CI/CD pipelines for automatic proof generation
- Research environments for ZK experimentation  
- Production deployments with horizontal scaling
- Development tooling for RISC-V applications

## Dependencies and Ecosystem

### Core Dependencies
- `risc0-zkvm`: Core ZKVM functionality and proving
- `risc0-circuit-rv32im`: RISC-V circuit implementations
- `kameo`: Actor framework for distributed coordination
- `axum`: HTTP server framework for REST API

### Integration Points
- Bonsai SDK for cloud proving services
- OpenTelemetry for observability infrastructure
- CUDA runtime for GPU acceleration
- Standard RISC-V toolchain compatibility

This component serves as the primary interface for RISC Zero ZKVM operations, bridging the gap between developer tooling and production proving infrastructure while maintaining compatibility with the broader Bonsai ecosystem.