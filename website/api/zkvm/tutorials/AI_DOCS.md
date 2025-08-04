# AI Documentation: zkVM Tutorials

## Overview
This directory contains comprehensive tutorials for the RISC Zero zkVM (Zero-Knowledge Virtual Machine), providing step-by-step guidance for developers learning to build zero-knowledge applications.

## Purpose
The tutorials serve as educational resources that teach fundamental concepts of zero-knowledge programming, including:
- Creating zkVM applications with cargo-risczero
- Understanding the host/guest architecture
- Managing private and public data flows
- Implementing I/O operations in zero-knowledge environments

## Files

### overview.md
Tutorial index that lists available learning resources, currently featuring the Hello World tutorial as the recommended starting point.

### hello-world.md
Complete walkthrough tutorial that teaches:
- Project setup using cargo-risczero
- Host program configuration with ExecutorEnv
- Guest program implementation for zkVM execution
- Private input handling and public output commitment
- Receipt generation and verification
- Journal content extraction

Key concepts covered:
- Host-guest data communication via ExecutorEnv.write()
- Guest input reading with env::read()
- Public output commitment using env::commit()
- Receipt verification and journal decoding

### io.md
In-depth guide to I/O operations in the zkVM, covering:
- zkVM data model (public vs private data)
- File descriptor system (stdin, stdout, stderr, journal)
- Host-to-guest data transmission via ExecutorEnv
- Guest-to-host private data communication
- Public data commitment to journal
- Performance considerations (standard vs _slice variants)
- Data structure sharing patterns between host and guest

## Architecture Concepts

### Host Program
- Runs in standard computing environment
- Creates ExecutorEnv for guest configuration
- Manages prover execution and receipt generation
- Handles private data exchange with guest

### Guest Program
- Executes in zero-knowledge environment
- Limited to specific I/O operations via file descriptors
- Can read private inputs and commit public outputs
- Code execution is proven cryptographically

### Data Flow
1. Host prepares private inputs via ExecutorEnv.write()
2. Guest reads inputs using env::read()
3. Guest processes data and commits public results via env::commit()
4. Host receives receipt with verifiable journal containing public outputs

## Security Model
- Private data: Host inputs, guest stdout/stderr output (not in proof)
- Public data: Journal commitments (included in proof, verifiable by anyone)
- Sensitive data should never be committed to journal unless intended to be public

## Development Patterns
- Use common core modules for shared data structures
- Leverage standard read/write functions for convenience
- Switch to _slice variants for performance optimization
- Implement proof composition for handling sensitive data

## Integration
These tutorials integrate with the broader RISC Zero ecosystem including:
- cargo-risczero toolchain
- Prover infrastructure (local and Bonsai remote proving)
- Receipt verification systems
- Example applications (voting machine, JWT validator, chess)