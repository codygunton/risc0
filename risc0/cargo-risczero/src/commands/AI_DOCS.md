# AI Documentation: cargo-risczero Commands Module

## Overview
This module contains the command implementations for the `cargo-risczero` CLI tool. The `cargo-risczero` crate provides CLI tools for RISC Zero development, enabling developers to create, build, verify, and manage RISC Zero projects and zero-knowledge proofs.

## Module Structure

### Core Commands (`mod.rs`)
- **Location**: `mod.rs:15-22`
- **Purpose**: Module declarations for all available commands
- **Available Commands**:
  - `bake` - Bake guest programs with optional Docker support
  - `build` - Build guest programs using Docker
  - `build_toolchain` - Build toolchain utilities
  - `guest` - Guest-related operations (experimental feature)
  - `install` - Installation command (deprecated, redirects to `rzup`)
  - `new` - Create new RISC Zero projects
  - `verify` - Verify zero-knowledge proofs

## Command Implementations

### 1. NewCommand (`new.rs`)
**Purpose**: Creates new RISC Zero projects from templates

**Key Features**:
- Project scaffolding with configurable templates
- Template variable substitution
- Support for different dependency sources (git, path, version)
- Guest method naming and configuration
- Optional `no_std` support

**Main Struct**: `NewCommand:88-133`
- `name: String` - Project name
- `tag: String` - Template git tag (default: current version)
- `branch: String` - Template git branch (overrides tag)
- `dest: Option<PathBuf>` - Destination directory
- `use_git_branch: Option<String>` - Use git dependencies
- `no_std: bool` - Enable no_std mode for guest
- `path: Option<PathBuf>` - Use path dependencies
- `guest_name: Option<String>` - Guest method name

**Entry Point**: `NewCommand::run():137-226`

### 2. BuildCommand (`build.rs`)
**Purpose**: Builds guest programs using Docker for reproducible builds

**Key Features**:
- Docker-based compilation
- Workspace and feature support
- ELF generation with ImageID tracking
- Package filtering and building

**Main Struct**: `BuildCommand:23-32`
- `manifest: clap_cargo::Manifest` - Cargo manifest options
- `workspace: clap_cargo::Workspace` - Workspace configuration
- `features: clap_cargo::Features` - Feature flags

**Entry Point**: `BuildCommand::run():35-62`

### 3. VerifyCommand (`verify.rs`)
**Purpose**: Verifies zero-knowledge proof receipts against image IDs

**Key Features**:
- Receipt verification from file or Bonsai ID
- Hex-encoded image ID validation
- Support for local files and remote receipts
- Binary receipt parsing

**Main Struct**: `VerifyCommand:24-35`
- `source: Source` - Receipt source (file path or Bonsai ID)
- `image_id: String` - Hex-encoded image ID to verify against
- `client: ClientEnvs` - Client environment variables

**Entry Point**: `VerifyCommand::run():56-70`

### 4. BakeCommand (`bake.rs`)
**Purpose**: Bakes guest programs and copies ELFs to project directories

**Key Features**:
- Guest program compilation
- ELF file management and copying
- Image ID file generation
- Optional Docker support
- Package metadata filtering

**Main Struct**: `BakeCommand:24-37`
- `manifest: clap_cargo::Manifest` - Cargo manifest options
- `workspace: clap_cargo::Workspace` - Workspace configuration
- `features: clap_cargo::Features` - Feature flags
- `docker: bool` - Use Docker for compilation

**Entry Point**: `BakeCommand::run():40-56`

### 5. InstallCommand (`install.rs`)
**Purpose**: Deprecated installation command

**Key Features**:
- Redirects users to use `rzup install` instead
- Simple deprecation notice

**Main Struct**: `InstallCommand:20-23`
- `version: Option<String>` - Version parameter (unused)

**Entry Point**: `InstallCommand::run():26-28`

## Dependencies and Integration

### Key Dependencies
- `risc0-build` - Guest program building functionality
- `risc0-zkvm` - RISC Zero virtual machine and receipt handling
- `bonsai-sdk` - Bonsai platform integration for remote receipts
- `clap` - Command-line argument parsing
- `cargo_metadata` - Cargo workspace and package metadata

### Template System (`new.rs`)
- **Template Files**: Located in `../../templates/rust-starter/`
- **Variable Substitution**: Regex-based template variable replacement
- **Supported Variables**: 
  - `{{ risc0_build }}` - risc0-build dependency specification
  - `{{ risc0_zkvm }}` - risc0-zkvm dependency specification
  - `{{ guest_package_name }}` - Guest package name
  - `{{ guest_id }}` - Guest method ID constant
  - `{{ guest_elf }}` - Guest ELF constant
  - `{{ risc0_feature_std }}` - std feature configuration
  - `{{ no_std_preamble }}` - no_std preamble code

## Error Handling
All commands implement `Result<()>` return types with comprehensive error handling using the `anyhow` crate for error propagation and context.

## Testing
The module includes comprehensive unit tests for:
- Template generation (`new.rs:259-388`)
- Project scaffolding validation
- Dependency version handling
- Feature flag processing

## Configuration Files
- `config.toml` - Configuration file for command defaults and settings