# xtask/src - RISC Zero Build Tasks

## Overview
This directory contains the source code for RISC Zero's xtask build automation tool. The xtask crate provides various build and maintenance commands for the RISC Zero project, including bootstrapping circuits, generating receipts, and managing project dependencies.

## Key Components

### Main Entry Point
- `main.rs` - CLI application entry point using clap for command parsing

### Core Commands
- `bootstrap.rs` - Bootstraps ZKVM circuits and dependencies
- `bootstrap_groth16.rs` - Groth16-specific bootstrapping functionality
- `bootstrap_poseidon.rs` - Poseidon hash function bootstrapping
- `bootstrap_protos.rs` - Protocol buffer generation and bootstrapping
- `gen_receipt.rs` - Generates test receipts for verification
- `install.rs` - Installation and setup utilities
- `extract_elf.rs` - ELF file extraction utilities
- `semver_checks.rs` - Semantic versioning compatibility checks
- `update_crate_version.rs` - Automated crate version management
- `update_lock_files.rs` - Cargo.lock file maintenance

### Templates
- `templates/` - Contains template files for various circuit control IDs:
  - `control_id_keccak.rs` - Keccak hash circuit control ID template
  - `control_id_rv32im.rs` - RISC-V 32-bit instruction set control ID template
  - `control_id_zkr.rs` - Zero-knowledge recursion control ID template

## Architecture
The xtask follows a command pattern where each major operation is implemented as a separate module with its own command structure. The main.rs file orchestrates these commands through a clap-based CLI interface.

## Features
- **zkvm** (default) - Enables zero-knowledge virtual machine features
- **cuda** - Enables CUDA acceleration for proof generation

## Dependencies
Key dependencies include:
- RISC Zero core libraries (risc0-core, risc0-zkvm, risc0-circuit-*)
- Build tools (cargo_metadata, prost-build)
- CLI utilities (clap, xshell)
- Cryptographic libraries for circuit operations

## Usage Context
This xtask is typically invoked during RISC Zero's build process to:
1. Bootstrap necessary circuit files and proofs
2. Generate control IDs for different circuit types
3. Maintain project consistency through version and lock file updates
4. Perform compatibility checks between releases