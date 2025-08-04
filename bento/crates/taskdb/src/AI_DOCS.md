# TaskDB - Distributed Task Queue and Management System

## Overview

TaskDB is a PostgreSQL-based distributed task queue and management system designed for RISC Zero's computation infrastructure. It provides robust task scheduling, dependency management, and worker allocation with support for different worker types and priority streams.

## Core Architecture

### Database Schema

The system is built around four main PostgreSQL tables:

1. **streams** - Task prioritization and worker allocation rules
2. **jobs** - High-level workflows containing multiple tasks
3. **tasks** - Individual units of work with dependencies
4. **task_deps** - Task dependency relationships

### Data Flow

```
User → create_stream() → create_job() → create_task() → request_work() → update_task_*()
```

## Key Components

### 1. Streams (`streams` table)
- **Purpose**: Define worker allocation and prioritization policies
- **Key Fields**:
  - `worker_type`: Type of worker (e.g., "CPU", "GPU")
  - `reserved`: Number of reserved workers for this stream
  - `be_mult`: Best-effort multiplier for priority calculation
  - `priority`: Auto-calculated priority based on current load
- **Priority Algorithm**: Streams with reserved capacity get negative priority (higher priority), best-effort streams get positive priority proportional to load

### 2. Jobs (`jobs` table)
- **Purpose**: Represent complete workflows owned by users
- **States**: `running`, `done`, `failed`
- **Key Features**:
  - User ownership via `user_id`
  - Error tracking for failed jobs
  - Automatic state management based on task completion

### 3. Tasks (`tasks` table)
- **Purpose**: Individual units of work within jobs
- **States**: `pending`, `ready`, `running`, `done`, `failed`
- **Key Features**:
  - JSON-based task definitions and outputs
  - Dependency management via `waiting_on` counter
  - Retry logic with configurable limits
  - Progress tracking (0.0 to 1.0)
  - Timeout handling

### 4. Task Dependencies (`task_deps` table)
- **Purpose**: Define prerequisite relationships between tasks
- **Automatic Management**: Updates task states when dependencies complete

## Core API Functions

### Stream Management
- `create_stream(worker_type, reserved, be_mult, user_id)` - Create new worker stream
- `get_stream(user_id, worker_type)` - Find existing stream

### Job Management
- `create_job(stream_id, task_def, max_retries, timeout_secs, user_id)` - Create job with initial task
- `get_job_state(job_id, user_id)` - Get current job status
- `delete_job(job_id)` - Remove job and all associated tasks

### Task Management
- `create_task(job_id, task_id, stream_id, task_def, prereqs, max_retries, timeout_secs)` - Add task to job
- `request_work(worker_type)` - Get next available task for worker
- `update_task_done(job_id, task_id, output)` - Mark task complete
- `update_task_failed(job_id, task_id, error)` - Mark task failed
- `update_task_progress(job_id, task_id, progress)` - Update task progress
- `update_task_retry(job_id, task_id)` - Retry failed/timed-out task

### Utility Functions
- `requeue_tasks(limit)` - Requeue timed-out tasks
- `get_task_output<T>(job_id, task_id)` - Retrieve task results
- `get_job_time(job_id)` - Calculate job execution time

## Planner Module

The planner module (`src/planner/`) provides task scheduling logic for parallel computation:

### Task Types
- **Segment**: Base computation unit
- **Keccak**: Cryptographic hash computation
- **Join**: Combines two segment results
- **Union**: Combines two keccak results  
- **Finalize**: Final task combining all results

### Features
- Automatic load balancing through peak management
- Height-based task prioritization
- Separate handling of segment and keccak task trees
- Iterator-based task consumption

## Error Handling

### TaskDbErr Enum
- `SqlError`: Database operation failures
- `InternalErr`: System-level errors
- `MigrateErr`: Database migration failures
- `JsonErr`: JSON serialization/deserialization errors
- `InvalidBeMult`: Invalid best-effort multiplier (0.0)

## Configuration

### Environment
- PostgreSQL database with UUID extension
- SQLx for database operations
- Serde for JSON handling
- Tokio for async runtime

### Dependencies
- `sqlx` - Database driver and migrations
- `serde/serde_json` - JSON serialization
- `thiserror` - Error handling
- `tokio` - Async runtime

## Usage Patterns

### Basic Workflow
1. Create stream for worker type
2. Create job with initial task
3. Workers request work via `request_work()`
4. Tasks can create additional tasks during execution
5. Update task status as work progresses
6. System automatically manages dependencies and job completion

### Worker Implementation
```rust
loop {
    if let Some(task) = request_work(&pool, "CPU").await? {
        // Process task
        let result = process_task(task).await;
        
        // Update status
        match result {
            Ok(output) => update_task_done(&pool, &task.job_id, &task.task_id, output).await?,
            Err(error) => update_task_failed(&pool, &task.job_id, &task.task_id, &error).await?,
        }
    }
}
```

## Testing

Comprehensive test suite covers:
- Stream creation and priority management
- Job lifecycle management
- Task state transitions
- Dependency resolution
- Retry logic and timeout handling
- Concurrent worker scenarios
- Error conditions and edge cases

## Integration Points

- **Database**: PostgreSQL with custom functions and triggers
- **Monitoring**: Progress tracking and job timing
- **Scaling**: Stream-based worker allocation
- **Reliability**: Automatic retry and timeout handling