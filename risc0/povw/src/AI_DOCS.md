# Proof of Verifiable Work (PoVW) Module

## Overview

The PoVW module implements a Merkle tree-based system for tracking and proving computational work performed during zero-knowledge proof generation. It provides cryptographic data structures and verification mechanisms to ensure that work (measured in nonces consumed during proof generation) cannot be double-counted or fraudulently claimed, enabling fair compensation and resource accounting in distributed proving networks.

## Architecture

### Core Design Principles

- **Merkle Tree Based**: Efficient inclusion/exclusion proofs for nonce usage
- **Bitmap Optimization**: 256-bit bitmaps as tree leaves for space efficiency  
- **Incremental Updates**: Support for continuous work log updates with continuations
- **Verifiable Commitments**: Cryptographic proofs of work performed
- **Double-Spend Prevention**: Ensures nonces cannot be reused across jobs

### Main Components

#### Bitmap Structure (`Bitmap`)
Fundamental unit for tracking nonce usage:

```rust
pub struct Bitmap(U256);
```

**Key Features:**
- **256-bit Capacity**: Each bitmap tracks 256 consecutive nonce indices
- **Bit Operations**: Efficient get/set/clear operations
- **Range Support**: Can mark ranges of bits for batch operations
- **Merkle Leaf**: Serves as leaves in the work tracking tree

**Core Operations:**
```rust
impl Bitmap {
    pub const EMPTY: Self = Self(U256::ZERO);
    pub const FULL: Self = Self(U256::MAX);
    
    pub fn bit(&self, index: usize) -> bool;
    pub fn set_bit(&mut self, index: usize);
    pub fn from_bit_range(min: usize, max: usize) -> Self;
}
```

#### Job Representation (`Job`)
Represents a contiguous range of work performed:

```rust
pub struct Job {
    pub start: U96,  // Starting nonce index
    pub end: U96,    // Ending nonce index (exclusive)
}
```

**Properties:**
- **Contiguous Ranges**: Jobs represent continuous nonce sequences
- **Non-Overlapping**: Jobs within a work log cannot overlap
- **Efficient Storage**: Compact representation of potentially large ranges

#### Work Log (`WorkLog`)
Collection of jobs within a single prover's work history:

```rust
pub struct WorkLog {
    jobs: BTreeMap<U96, Job>,
    root: Digest,
}
```

**Key Features:**
- **Ordered Jobs**: BTreeMap ensures jobs are sorted by start index
- **Merkle Root**: Cryptographic commitment to all jobs in the log
- **Incremental Updates**: Support for adding new jobs efficiently
- **Proof Generation**: Can generate proofs of inclusion/exclusion

**Core Operations:**
- `add_job()`: Add a new job ensuring no overlaps
- `get_proof()`: Generate Merkle proof for a specific nonce
- `verify_inclusion()`: Verify a nonce is used in the log
- `merge()`: Combine multiple work logs

#### Work Set (`WorkSet`)
Top-level container managing multiple work logs:

```rust
pub struct WorkSet {
    logs: BTreeMap<PovwLogId, WorkLog>,
}
```

**Responsibilities:**
- **Multi-Log Management**: Track work across multiple provers
- **Global Deduplication**: Ensure no nonce reuse across logs
- **Aggregation**: Combine work from distributed provers

#### Merkle Tree Implementation

The system uses a binary Merkle tree with optimizations:

**Tree Structure:**
- **Height**: Fixed at 97 levels (96 for U96 nonce space + 1 for bitmap)
- **Leaves**: 256-bit bitmaps at the bottom level
- **Internal Nodes**: SHA-256 hashes of child nodes

**Optimizations:**
- **Sparse Tree**: Only materializes necessary nodes
- **Subtree Caching**: Precomputed roots for empty/full subtrees
- **Path Compression**: Efficient representation of sparse regions

#### Subtree Opening (`SubtreeOpening`)
Proof structure for Merkle tree operations:

```rust
pub struct SubtreeOpening<const N: usize> {
    pub left: ArrayVec<Digest, N>,
    pub right: ArrayVec<Digest, N>,
}
```

**Usage:**
- **Inclusion Proofs**: Prove a nonce was used
- **Exclusion Proofs**: Prove a nonce was not used
- **Range Proofs**: Prove properties about nonce ranges

### Guest Program Architecture (`guest/`)

#### State Management
```rust
pub enum State {
    Initial { work_log_id: U160 },
    Continuation { journal: Journal },
}
```

**State Types:**
- **Initial**: Starting a new work log
- **Continuation**: Resuming from previous execution

#### Journal Structure
```rust
pub struct Journal {
    pub work_log_id: U160,
    pub work_log: WorkLog,
    pub opening: SubtreeOpening<96>,
}
```

**Contents:**
- Work log identifier
- Current work log state
- Merkle opening for verification

#### Work Log Updates
```rust
pub struct WorkLogUpdate {
    pub prev: Option<WorkLog>,
    pub add: Vec<Job>,
    pub next: WorkLog,
}
```

**Update Process:**
1. Verify previous state (if continuation)
2. Validate new jobs don't overlap
3. Update Merkle tree incrementally
4. Produce new root and opening

### Prover Implementation (`prover/`)

#### Work Log Update Prover
Stateful prover for generating update proofs:

```rust
pub struct WorkLogUpdateProver<P> {
    pub prover: P,
    pub log_id: PovwLogId,
    pub work_log: WorkLog,
    pub continuation: Option<(Journal, Receipt)>,
}
```

**Workflow:**
1. Initialize with log ID and optional continuation
2. Add new jobs to the work log
3. Generate proof of valid update
4. Update internal state for next continuation

**Key Methods:**
- `prove_update()`: Generate proof for work log update
- `add_jobs()`: Add new jobs with validation
- `get_continuation()`: Retrieve state for next update

### Cryptographic Properties

#### Security Guarantees
- **Collision Resistance**: SHA-256 prevents forged Merkle proofs
- **Binding**: Work logs cryptographically commit to all jobs
- **Non-Repudiation**: Proofs demonstrate specific work performed

#### Verification Properties
- **Soundness**: Cannot prove inclusion of unused nonces
- **Completeness**: Can always prove inclusion of used nonces
- **Succinctness**: Proof size logarithmic in total nonces

### Integration Points

- **ZKVM**: Guest programs run in zkVM for verification
- **Proof System**: Generates STARK proofs of work log updates
- **Bonsai**: Integration with proof aggregation system
- **Receipt Chain**: Continuations enable unbounded work logs

### Performance Considerations

- **Bitmap Efficiency**: 256x compression vs bit arrays
- **Sparse Tree**: Only O(log n) nodes for sparse logs
- **Incremental Updates**: O(log n) per job addition
- **Proof Size**: ~3KB for typical inclusion proofs

### Usage Patterns

**Creating a Work Log:**
```rust
let mut log = WorkLog::new();
log.add_job(Job::new(1000, 2000)?)?;
let root = log.root();
```

**Generating Proofs:**
```rust
let prover = WorkLogUpdateProverBuilder::default()
    .log_id(log_id)
    .build()?;
let receipt = prover.prove_update(new_jobs)?;
```

**Verifying Work:**
```rust
let proof = work_log.get_proof(nonce_index)?;
verify_inclusion(root, nonce_index, proof)?;
```

### Constants and Precomputation (`consts.rs`)

Pre-computed values for efficiency:
- `EMPTY_SUBTREE_ROOTS`: Roots of empty subtrees at each level
- `FULL_SUBTREE_ROOTS`: Roots of full subtrees at each level

These enable O(1) operations for common subtree patterns.