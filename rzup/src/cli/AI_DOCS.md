# CLI Module Documentation

## Overview
The CLI module provides the command-line interface for `rzup`, a component management tool for RISC Zero software components. It handles argument parsing, command execution, and user interface management.

## Architecture

### Core Components

#### `mod.rs` - Main CLI Entry Point
- **Main struct**: `Cli` - Main CLI parser with global flags
- **Commands enum**: Defines all available subcommands (Install, Check, Default, Show, Uninstall, Build, Publish)
- **UI Management**: Spawns appropriate UI (Terminal or Text) based on environment
- **Error Handling**: Centralized error handling with colored output

Key functions:
- `spawn_ui()` - Creates UI handler thread based on terminal detection
- `Cli::execute()` - Main execution flow with scoped threading
- `banner()` - Generates ASCII art banner with version

#### `commands.rs` - Command Implementations
Contains all command structures and their implementations:

**Install Command** (`InstallCommand`)
- Installs components or self-updates
- Supports force installation and version parsing
- Handles special cases for C++ date-based versions

**Show Command** (`ShowCommand`)
- Lists installed components and versions
- Displays default versions with markers
- Shows warnings for missing configured versions

**Default Command** (`DefaultCommand`)
- Sets default version for components
- Validates version existence before setting

**Check Command** (`CheckCommand`)
- Checks for component updates against GitHub
- Compares installed vs latest versions
- Displays update availability status

**Uninstall Command** (`UninstallCommand`)
- Removes specific component versions
- Updates default version if necessary

**Build Command** (`BuildCommand`)
- Builds components from source
- Currently only supports Rust toolchain
- Supports building from tag/commit or local path

**Publish Command** (`PublishCommand`)
- Publishes components to S3 (requires `publish` feature)
- Supports target-specific and target-agnostic uploads
- Can set latest version pointers

#### `ui.rs` - User Interface
Provides two UI implementations:

**TerminalUi**
- Rich terminal interface with progress bars
- Uses `indicatif` for spinners and progress tracking
- Multi-progress support for concurrent operations
- Handles all event types with visual feedback

**TextUi**
- Simple text-based interface for non-terminal environments
- Minimal output without progress bars
- Suitable for CI/CD and scripting

## Key Features

### Command Parsing
- Uses `clap` for robust argument parsing
- Dynamic value parsers based on command context
- Support for aliases and help text
- Global flags for verbosity control

### Event-Driven Architecture
- All operations emit `RzupEvent`s
- UI components subscribe to events
- Decoupled execution from presentation
- Thread-safe event handling

### Version Management
- Semantic version parsing with `semver`
- Special handling for date-based versions (C++ components)
- Version validation and error reporting
- Component-specific version logic

### Error Handling
- Centralized error handling in main execution
- Colored error output for better UX
- Detailed error messages with suggestions
- Graceful process termination

### Platform Support
- Terminal detection for appropriate UI selection
- Cross-platform compatibility
- Respects environment constraints

## Dependencies
- `clap` - Command line argument parsing
- `colored` - Terminal color support
- `indicatif` - Progress bars and spinners
- `semver` - Semantic version handling
- `is_terminal` - Terminal detection

## Integration Points
- Integrates with `Rzup` core for component management
- Uses event system for UI communication
- Connects to GitHub API for version checking
- Supports AWS S3 for component publishing

## Usage Patterns
Commands follow consistent patterns:
1. Parse and validate arguments
2. Execute operation through `Rzup` instance
3. Emit events for UI feedback
4. Handle errors gracefully

The CLI is designed to be user-friendly with helpful error messages, progress indication, and clear status reporting.