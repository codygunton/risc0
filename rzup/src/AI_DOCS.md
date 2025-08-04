# Rzup - RISC Zero Toolchain Manager

## Overview

Rzup is a comprehensive toolchain management system for RISC Zero that provides installation, version management, and configuration of various components including Rust toolchains, C++ toolchains, and RISC Zero-specific tools. It follows a modular, event-driven architecture with cross-platform support and robust error handling.

## Architecture

### Core Design Principles

- **Modular Architecture**: Clear separation between core logic, CLI interface, and distribution mechanisms
- **Event-Driven**: Real-time progress feedback through a comprehensive event system
- **Cross-Platform**: Support for multiple OS/architecture combinations with platform-specific handling
- **Version Management**: Semantic versioning with support for multiple versioning schemes
- **Backward Compatibility**: Legacy format support and forward-compatible configuration

### Main Components

#### Core Library (`lib.rs`)
The main `Rzup` struct serves as the primary interface for all toolchain management operations:

```rust
pub struct Rzup {
    env: Environment,
    registry: Registry,
    settings: Settings,
}
```

**Key Public APIs:**
- `Rzup::new()` - Creates instance with default environment
- `install_component()` - Installs specific component versions with dependency resolution
- `get_default_version()` - Retrieves currently active component version
- `set_default_version()` - Sets default version for a component
- `self_update()` - Updates rzup itself to latest version

#### Component Management System (`components.rs`)

**Supported Components:**
1. **CargoRiscZero** - The cargo-risczero CLI tool for RISC Zero development
2. **CppToolchain** - C++ cross-compilation toolchain for RISC-V targets
3. **Gdb** - RISC-V debugger for development and debugging
4. **R0Vm** - RISC Zero virtual machine runtime
5. **RustToolchain** - Rust compiler toolchain with RISC-V support
6. **Risc0Groth16** - Groth16 proving system for zero-knowledge proofs

**Component Features:**
- **Hierarchical Dependencies**: R0Vm automatically depends on CargoRiscZero as parent component
- **Platform-Specific Assets**: Different binary archives per OS/architecture combination
- **Flexible Versioning**: Handles semantic versioning and date-based version schemes
- **Organized Installation**: Components installed into `toolchains/` and `extensions/` directories
- **Default Components**: CargoRiscZero, CppToolchain, R0Vm, and RustToolchain install by default

**Installation Process:**
1. Component validation and parent dependency resolution
2. File locking mechanism to prevent concurrent installations
3. Archive download from configured distribution platform
4. Extraction to version-specific directory structure
5. Symlink creation for default version management

#### Registry and Version Management

**Registry (`registry.rs`):**
- **Version Tracking**: Comprehensive listing and management of installed component versions
- **Default Version Management**: Maintains active version state per component
- **Installation Orchestration**: Coordinates complex component installation workflows
- **Component Discovery**: Automated scanning of directories to find installed versions
- **Dependency Resolution**: Handles component dependencies and installation order

**Settings (`settings.rs`):**
- **TOML Configuration**: Persistent settings stored in `~/.risc0/settings.toml`
- **Default Version Persistence**: Remembers user-selected component versions across sessions
- **Forward Compatibility**: Gracefully ignores unknown configuration sections for future versions
- **Version Validation**: Warns about invalid semantic version specifications

#### Error Handling System (`error.rs`)

**Comprehensive Error Types:**
- `ComponentNotFound` - Invalid or unsupported component names
- `InstallationFailed` - Installation process errors with detailed context
- `InvalidVersion` - Malformed version strings and parsing errors
- `VersionNotFound` - Requested version not available or installed
- `UnsupportedPlatform` - Unsupported OS/architecture combinations
- `RateLimited` - GitHub API rate limiting with retry suggestions
- `Environment` - Configuration and path-related errors

**Error Handling Features:**
- Automatic conversion from standard library errors (`std::io::Error`, `semver::Error`)
- Consistent error messaging with actionable suggestions
- Context preservation throughout error propagation chain

#### Event System Architecture (`events.rs`)

**Event Categories:**
- **Transfer Events**: Download/upload progress tracking with byte-level granularity
- **Installation Events**: Start, progress, completion, and failure state notifications
- **Build Events**: Rust toolchain compilation progress for source builds
- **Debug/Print Events**: Detailed logging and user feedback mechanisms

**Event Flow Pattern:**
- Events emitted throughout all operations for real-time user feedback
- UI components consume event streams for progress visualization
- Debug events provide comprehensive operation tracing for troubleshooting

#### Environment Management (`env.rs`)

**Path Configuration:**
- `RISC0_HOME` - Main rzup directory (`~/.risc0` by default)
- `RUSTUP_HOME` - Rustup toolchain directory (`~/.rustup`)
- `CARGO_HOME` - Cargo installation directory (`~/.cargo`)
- Automatic platform detection for OS and architecture

**Credential Management:**
- GitHub authentication token from `GITHUB_TOKEN` environment variable or `~/.config/gh/hosts.yml`
- AWS credentials for S3 publishing when publish feature is enabled
- Secure credential handling with environment variable precedence

**Directory Structure:**
```
~/.risc0/
├── .rzup              # Sentinel file for legacy version compatibility
├── settings.toml      # User configuration and default versions
├── tmp/               # Temporary files and installation locks
├── toolchains/        # Rust and C++ toolchain installations
└── extensions/        # Additional components and tools
```

#### Path Management (`paths.rs`)

**Version Directory Resolution:**
- **Legacy Format Support**: Handles multiple historical directory naming conventions
- **Platform-Specific Paths**: Includes architecture and OS identifiers in directory names
- **Version Parsing**: Extracts semantic versions from various directory naming schemes
- **Cleanup Operations**: Removes version directories and prunes empty parent directories

**Directory Naming Patterns:**
- Modern format: `v{version}-{component}-{platform}`
- Legacy format compatibility for smooth upgrades
- Special handling for C++ toolchain subdirectory structures

### Distribution Platform Architecture (`distribution/`)

#### Platform Support (`mod.rs`)
- **Platform Detection**: Automatic detection of current platform (OS + architecture)
- **Supported Platforms**: Linux x86_64, macOS aarch64 (Apple Silicon), limited macOS x86_64
- **Target Triple Generation**: Standard Rust target triple format for platform identification
- **Platform-Specific Asset Naming**: Different binary archives per supported platform

#### Distribution Sources

**GitHub Releases (`github.rs`):**
- Legacy distribution method for existing components
- Component-specific version parsing from git tags
- Bearer token authentication for private repositories
- Release validation before download attempts

**S3 Bucket (`s3.rs`):**
- Modern content-addressed storage using SHA256 hashing
- Distribution manifest management for version tracking
- Upload functionality with AWS Signature V4 authentication
- Support for both target-specific and target-agnostic releases
- Comprehensive progress tracking for uploads and downloads

**HTTP Utilities (`http.rs`):**
- Low-level HTTP client abstraction layer
- Bearer token authentication support for secured endpoints
- Multi-format download capabilities (JSON, text, binary)
- Upload functionality with custom request signing
- Robust error handling and HTTP status code validation

### CLI Interface (`cli/`)

#### Command Structure (`commands.rs`)
- **install/update** - Component installation and version updates with dependency resolution
- **show** - Comprehensive listing of installed components and their versions
- **default** - Set and manage default component versions
- **check** - Check for available component updates against remote repositories
- **uninstall** - Remove specific component versions with cleanup
- **build** - Build components from source code (currently supports Rust toolchain)
- **publish** - Publish components to S3 distribution (requires publish feature flag)

#### User Interface (`ui.rs`)
- **TerminalUi** - Rich terminal interface with progress bars, spinners, and colored output
- **TextUi** - Plain text output suitable for non-terminal environments and CI/CD
- **Event-Driven Updates** - Real-time progress feedback through event consumption

## Key Features

### Version Management
- **Semantic Versioning**: Full semver support with proper parsing and comparison
- **Multiple Version Schemes**: Support for date-based versions (C++ components) and semantic versions
- **Default Version Tracking**: Per-component default version management
- **Version Validation**: Comprehensive validation with helpful error messages

### Cross-Platform Support
- **Multi-Architecture**: Support for x86_64 and aarch64 architectures
- **Operating System Support**: Linux and macOS with platform-specific optimizations
- **Conditional Compilation**: Platform-specific feature compilation for optimal performance
- **Graceful Degradation**: Informative error messages for unsupported platforms

### Security and Reliability
- **Content-Addressed Storage**: SHA256-based verification for downloaded artifacts
- **Atomic Operations**: File locking prevents concurrent installation conflicts
- **Secure Authentication**: Proper handling of GitHub tokens and AWS credentials
- **Archive Validation**: Verification of archive formats before processing

### User Experience
- **Real-Time Progress**: Live progress bars and status updates during operations
- **Helpful Error Messages**: Clear, actionable error messages with suggested solutions
- **Automatic Detection**: Smart detection of platform and environment configuration
- **Legacy Compatibility**: Seamless upgrades from older rzup versions

## Usage Patterns

### Basic Component Management
```bash
# Install latest version of all default components
rzup install

# Install specific component version
rzup install rust-toolchain@1.82.0

# Set default version
rzup default rust-toolchain 1.82.0

# Check for updates
rzup check

# Show installed components
rzup show
```

### Advanced Operations
```bash
# Build from source
rzup build rust-toolchain --tag v1.82.0

# Force reinstall
rzup install --force

# Self-update rzup
rzup install rzup

# Publish component (requires publish feature)
rzup publish component.tar.xz --component rust-toolchain --version 1.82.0
```

## Integration Points

### External Systems
- **GitHub API** - Version checking and release downloads from GitHub repositories
- **AWS S3** - Modern component distribution and publishing platform
- **Rustup Integration** - Coordinates with existing Rustup installations
- **Cargo Integration** - Works alongside Cargo for Rust development workflows

### Development Workflow
- **RISC Zero Development** - Provides essential toolchain components for RISC Zero projects
- **Cross-Compilation** - Enables C++ cross-compilation for RISC-V targets
- **Debugging Support** - Installs and manages RISC-V debugger tools
- **Proof Generation** - Manages Groth16 proving system components

## Dependencies

### Core Dependencies
- **semver** - Semantic version parsing and comparison
- **serde** - Configuration serialization/deserialization
- **strum** - Enum string conversion utilities
- **thiserror** - Error handling and propagation
- **tempfile** - Temporary file management
- **toml** - Configuration file parsing

### Optional Feature Dependencies
- **clap** - Command line argument parsing (cli feature)
- **indicatif** - Progress bars and spinners (cli feature)
- **colored** - Terminal color support (cli feature)
- **reqwest** - HTTP client (install feature)
- **tar/xz/flate2** - Archive extraction (install feature)
- **aws-** crates - AWS S3 integration (publish feature)

## Testing and Quality

### Test Coverage
- Comprehensive unit tests for version parsing and platform detection
- Integration tests for component installation workflows
- Error handling validation across all error types
- CLI command testing with mock environments

### Code Quality
- Consistent error handling patterns throughout codebase
- Comprehensive documentation with examples
- Modular design enabling easy testing and maintenance
- Feature flags for optional functionality to minimize binary size

This architecture provides a robust, extensible foundation for managing complex toolchain installations while maintaining excellent backward compatibility and user experience through comprehensive progress feedback and detailed error handling.