# RISC Zero zkVM Documentation Component

## Purpose
This component contains documentation for the RISC Zero zero-knowledge virtual machine (zkVM). The zkVM enables developers to prove correct execution of arbitrary Rust code, making it possible to build powerful verifiable software applications using existing Rust packages.

## Key Concepts
- **zkVM (Zero-Knowledge Virtual Machine)**: The core technology that proves correct execution of Rust programs
- **Guest Program**: Code that runs inside the zkVM and gets proven
- **Host Program**: Code that launches the zkVM and manages the proving process
- **Receipt**: Proof of execution containing a journal (public outputs) and seal (cryptographic proof)
- **Journal**: Public outputs from the guest program
- **Executor**: Runs the ELF binary and records the session
- **Prover**: Validates and proves the session

## Documentation Structure

### Core Documentation Files
- `zkvm-overview.md` - Main introduction to zkVM concepts and architecture
- `quickstart.md` - Step-by-step guide to create first zkVM application
- `guest-code-101.md` - Guide to writing guest programs that run in the zkVM
- `host-code-101.md` - Guide to writing host programs that manage proving
- `receipts.md` - Documentation on proof receipts and verification

### Application Development
- `examples.md` - Collection of example zkVM applications
- `tutorials/` - Detailed tutorials including Hello World walkthrough
- `install.md` - Installation guide for RISC Zero toolchain
- `optimization.md` - Performance optimization strategies
- `profiling.md` - Performance analysis and debugging tools

### Advanced Topics
- `composition.md` - Composing multiple zkVM proofs
- `precompiles.md` - Cryptographic acceleration features
- `benchmarks.md` - Performance benchmarks and metrics
- `zkvm-specification.md` - Technical specification of the zkVM

### Integration & Deployment
- `rust-crates-with-cpp.md` - Using C++ libraries in Rust guest code
- `rust-resources.md` - Rust-specific resources and best practices

## Workflow Overview
1. **Development**: Write guest program in Rust
2. **Compilation**: Guest program compiled to ELF binary
3. **Execution**: Executor runs ELF binary and records session
4. **Proving**: Prover generates cryptographic proof (receipt)
5. **Verification**: Anyone can verify the receipt and read public outputs

## Key Features
- **Rust Integration**: Full support for existing Rust packages and libraries
- **Zero-Knowledge Proofs**: Cryptographic proofs without revealing private data
- **Remote Proving**: Integration with Bonsai for cloud-based proof generation
- **Development Mode**: Fast iteration during development without proof generation
- **Performance Tools**: Profiling and optimization capabilities

## Development Tools
- `rzup` - RISC Zero toolchain installer
- `cargo-risczero` - Cargo extension for zkVM projects
- Dev mode (`RISC0_DEV_MODE=1`) - Fast development without proof generation
- Logging and statistics for performance analysis

## Target Audience
- Developers building zero-knowledge applications
- Teams integrating verifiable computation into existing systems
- Researchers working with zero-knowledge proofs
- Blockchain developers building trustless applications

## Related Components
- Bonsai (remote proving service)
- Blockchain integration tools
- RISC Zero core libraries and circuits