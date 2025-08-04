# RISC Zero Website API Documentation Component

## Purpose
This component contains the API documentation and guides for the RISC Zero ecosystem. It serves as the primary documentation hub covering zero-knowledge virtual machine (zkVM) technology, blockchain integration, proof generation, and security best practices.

## Key Concepts
- **Zero-Knowledge Proofs**: Cryptographic proofs that verify computation without revealing private data
- **zkVM (Zero-Knowledge Virtual Machine)**: Core technology for proving correct execution of Rust programs
- **Bonsai**: Remote proving service for cloud-based proof generation
- **Receipts**: Cryptographic proofs containing public outputs and verification data
- **Guest/Host Architecture**: Separation between proven code (guest) and orchestration code (host)

## Documentation Structure

### Getting Started
- `getting-started.md` - Entry point for new users to RISC Zero
- `introduction.md` - High-level overview of RISC Zero technology
- `use-cases.md` - Real-world applications and use cases

### Core zkVM Documentation (`zkvm/`)
- Complete documentation for the zero-knowledge virtual machine
- Tutorials, examples, and technical specifications
- Development tools and optimization guides
- See `zkvm/AI_DOCS.md` for detailed breakdown

### Proof Generation (`generating-proofs/`)
- `dev-mode.md` - Fast development without proof generation
- `local-proving.md` - Running proofs on local hardware
- `remote-proving.md` - Using Bonsai for cloud proving
- `proving-options.md` - Comparison of different proving methods

### Blockchain Integration (`blockchain-integration/`)
- `risc-zero-on-eth.md` - Ethereum integration guide
- `contracts/verifier.md` - Smart contract verification patterns

### Security & Trust
- `security-model.md` - Security assumptions and guarantees
- `secure-sdlc.md` - Secure software development lifecycle practices
- `trusted-setup-ceremony.md` - Cryptographic ceremony documentation

### Advanced Topics
- `recursion.md` - Recursive proof composition
- Performance optimization and profiling guides

## Target Audience
- **Developers**: Building zero-knowledge applications with RISC Zero
- **Blockchain Teams**: Integrating verifiable computation into dApps
- **Security Engineers**: Understanding cryptographic guarantees
- **Researchers**: Working with zero-knowledge proof systems
- **Product Teams**: Evaluating RISC Zero for use cases

## Key Features Documented
- **Rust-First Development**: Native Rust support for guest programs
- **Flexible Proving**: Local, remote, and development mode options
- **Blockchain Ready**: Smart contract integration patterns
- **Performance Tools**: Profiling, optimization, and benchmarking
- **Security Focus**: Comprehensive security model and best practices

## Workflow Coverage
1. **Setup**: Installation and environment configuration
2. **Development**: Writing and testing guest/host programs
3. **Proving**: Generating cryptographic proofs
4. **Integration**: Deploying to blockchain and other systems
5. **Verification**: Validating proofs and reading public outputs

## Development Tools
- `rzup` - RISC Zero toolchain installer and manager
- `cargo-risczero` - Cargo extension for zkVM project management
- Bonsai integration for remote proving
- Development mode for fast iteration

## Related Ecosystems
- Ethereum and other blockchain networks
- Rust ecosystem and crates
- Zero-knowledge proof research community
- Verifiable computation applications