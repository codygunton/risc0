# Task Planner Component

## Overview

The planner component is responsible for creating and managing execution plans for cryptographic proof generation tasks. It orchestrates the scheduling and dependency management of different types of tasks including segments, joins, keccak operations, unions, and finalization.

## Core Concepts

### Task Types
- **Segment**: Base computation units with height 0
- **Keccak**: Cryptographic hash operations with height 0
- **Join**: Combines two regular tasks with height = max(left, right) + 1
- **Union**: Combines two keccak tasks with height = max(left, right) + 1
- **Finalize**: Final task that depends on both regular and keccak task trees

### Task Scheduling Algorithm
The planner uses a binary tree-like structure to maintain balanced execution:
1. **Peaks Management**: Tracks current "peaks" (incomplete task chains) sorted by decreasing height
2. **Auto-balancing**: When tasks of equal height are added, they are automatically joined/unioned
3. **Height Calculation**: Each join/union increases height by 1 from the maximum of its dependencies

## Key Components

### Planner Struct (`mod.rs:20-40`)
- `tasks`: Vector storing all planned tasks
- `peaks`: Current peaks for regular tasks (segments/joins)  
- `keccak_peaks`: Current peaks for keccak tasks (keccak/unions)
- `consumer_position`: Iterator position for task consumption
- `last_task`: Final task ID after planning is complete

### Task Struct (`task.rs:17-23`)
- `task_number`: Unique identifier
- `task_height`: Depth in the execution tree
- `command`: Type of operation to perform
- `depends_on`: Dependencies for regular tasks
- `keccak_depends_on`: Dependencies for keccak tasks

## Public API

### Planning Operations
- `enqueue_segment()` - Add a new segment task
- `enqueue_keccak()` - Add a new keccak task  
- `finish()` - Complete planning and create final task

### Task Access
- `get_task(task_number)` - Get task by number
- `next_task()` - Get next task for execution
- `task_count()` - Total number of tasks

## Error Handling

- `PlanNotStartedString`: Trying to finish before adding any tasks
- `PlanFinalized`: Trying to add tasks after calling finish()

## Usage Pattern

```rust
let mut planner = Planner::default();

// Add computation tasks
planner.enqueue_segment()?;
planner.enqueue_segment()?;
planner.enqueue_keccak()?;

// Finalize the plan
let final_task = planner.finish()?;

// Execute tasks
while let Some(task) = planner.next_task() {
    // Process task based on command type
}
```

## Implementation Details

### Balancing Strategy
- Regular tasks use a stack-based approach with `peaks` vector
- Keccak tasks use a queue-based approach with `keccak_peaks` deque
- Equal-height tasks are automatically combined during insertion

### Task Dependencies
- Join tasks depend on two regular tasks
- Union tasks depend on two keccak tasks via `keccak_depends_on`
- Finalize task depends on the final regular task and optional keccak tree

### Memory Management
The planner pre-allocates task storage and uses indices for dependencies rather than pointers, ensuring memory safety and efficient access patterns.