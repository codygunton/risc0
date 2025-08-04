# R0VM Actor System

## Overview

The R0VM actors module implements a distributed, actor-based execution and proving system for RISC Zero. It provides a scalable architecture for managing proof generation workloads across multiple workers, supporting both local and remote execution environments. The system uses the Kameo actor framework to orchestrate complex proving pipelines with concurrent task execution and resource management.

## Architecture

### Core Design Principles

- **Actor-Based Concurrency**: Leverages the actor model for safe concurrent execution and message passing
- **Distributed Workload Management**: Supports both local and remote worker pools for horizontal scaling
- **Task Specialization**: Workers can be configured to handle specific types of proving tasks
- **Resource-Aware Scheduling**: Intelligent task distribution based on worker capabilities and availability
- **Fault Tolerance**: Graceful handling of worker failures with task redistribution

### Main Components

#### Manager Actor (`manager.rs`)
The central coordinator that manages jobs and orchestrates the proving pipeline:

```rust
pub struct ManagerActor {
    factory: ActorRef<FactoryActor>,
    jobs: HashMap<JobId, JobEntry>,
    join_set: JoinSet<()>,
    storage_root: Option<PathBuf>,
}
```

**Key Responsibilities:**
- **Job Lifecycle Management**: Create, track, and finalize proving jobs
- **Storage Coordination**: Manage persistent storage of job artifacts
- **Status Tracking**: Provide real-time job status updates
- **Resource Allocation**: Coordinate with factory for worker assignment

#### Factory System (`factory.rs`)
The factory subsystem manages worker pools and task distribution:

**Core Components:**
- `FactoryActor` - Main factory coordinating local workers
- `FactoryRouterActor` - Routes tasks between local and remote factories
- `RemoteFactoryActor` - Manages connections to remote worker pools

**Factory Architecture:**
```rust
pub struct FactoryActor {
    pool_id: usize,
    ready_workers: Vec<ActorRef<Worker>>,
    pending_tasks: VecDeque<TaskId>,
    task_registry: HashMap<TaskId, TaskInfo>,
}
```

#### Worker Implementation (`worker.rs`)
Workers execute individual proving tasks with GPU acceleration support:

**Worker Capabilities:**
- **Execute Tasks**: Run RISC-V programs and generate execution traces
- **Prove Segments**: Generate proofs for execution segments
- **Prove Keccak**: Accelerated Keccak proof generation
- **Lift/Join/Union**: Recursive proof composition operations
- **Resolve**: Final proof resolution and verification

**GPU Task Pipeline:**
```rust
enum GpuTask {
    ProveSegmentCore(ProveSegmentCoreTask),
    ProveKeccak(Arc<ProveKeccakTask>),
    Lift(Arc<LiftTask>),
    Join(Arc<JoinTask>),
    Union(Arc<UnionTask>),
    Resolve(Arc<ResolveTask>),
}
```

#### RPC System (`rpc.rs`)
Provides remote procedure call infrastructure for distributed communication:

**RPC Features:**
- **Bidirectional Messaging**: Request-response pattern with correlation IDs
- **Streaming Support**: Efficient large data transfers
- **Connection Management**: Automatic reconnection and failover
- **Protocol Versioning**: Forward/backward compatibility

**RPC Architecture:**
```rust
pub struct RpcSender<Req, Reply> {
    sender: mpsc::UnboundedSender<RpcMessage>,
    pending: Arc<Mutex<HashMap<RpcMessageId, oneshot::Sender<Reply>>>>,
}
```

#### Job Management (`job.rs`)
Individual job actors that track proving pipeline progress:

**Job Lifecycle:**
1. **Creation**: Initialize with proof request parameters
2. **Task Generation**: Break down proof into executable tasks
3. **Execution**: Distribute tasks to available workers
4. **Aggregation**: Collect and compose intermediate results
5. **Completion**: Generate final proof output

#### Metrics Collection (`metrics.rs`)
Comprehensive telemetry and performance monitoring:

**Metrics Categories:**
- **Task Metrics**: Execution times, success/failure rates
- **Worker Metrics**: Utilization, throughput, GPU statistics
- **System Metrics**: Queue depths, memory usage, network latency
- **Job Metrics**: End-to-end latency, resource consumption

#### Protocol Definitions (`protocol/`)
Shared message types and communication protocols:

**Core Message Types:**
- `ProofRequest` - High-level proving request specification
- `Task` - Atomic unit of proving work
- `TaskUpdate` - Progress notifications during execution
- `JobInfo` - Comprehensive job status and metadata

### Task Execution Flow

1. **Job Submission**
   - Client submits `ProofRequest` to manager
   - Manager creates `JobActor` to handle request
   - Job generates task dependency graph

2. **Task Distribution**
   - Tasks submitted to factory for scheduling
   - Factory matches tasks to available workers
   - Workers pull tasks based on capabilities

3. **Parallel Execution**
   - Workers execute tasks concurrently
   - Progress updates streamed to job actor
   - Failed tasks automatically retried

4. **Result Aggregation**
   - Completed task results collected by job
   - Recursive composition of partial proofs
   - Final proof assembly and verification

### Worker Pool Configuration

Workers can be configured with specific capabilities:

```rust
pub struct PoolConfig {
    pub count: usize,                    // Number of workers
    pub profile: Option<DevModeDelay>,   // Development mode settings
    pub task_kinds: Vec<TaskKind>,       // Supported task types
}
```

**Task Specialization:**
- **CPU Workers**: Execute, basic prove operations
- **GPU Workers**: Accelerated proving, Keccak, recursion
- **Memory Workers**: Large working set operations

### Integration Points

- **ZKVM Core**: Interfaces with core proving infrastructure
- **ProverServer**: Leverages GPU-accelerated proving backend
- **Storage Layer**: Persistent storage for job artifacts
- **Telemetry**: OpenTelemetry integration for observability

### Performance Optimizations

- **Work Stealing**: Idle workers can steal tasks from busy queues
- **Batch Processing**: Group similar tasks for GPU efficiency
- **Pipeline Parallelism**: Overlap execution and proving phases
- **Connection Pooling**: Reuse network connections for RPC

### Fault Tolerance

- **Worker Heartbeats**: Detect and handle worker failures
- **Task Checkpointing**: Resume partially completed tasks
- **Automatic Retry**: Configurable retry policies
- **Circuit Breakers**: Prevent cascading failures

### Security Considerations

- **Authentication**: Mutual TLS for remote connections
- **Authorization**: Task-level access control
- **Isolation**: Process isolation between workers
- **Resource Limits**: Prevent resource exhaustion attacks