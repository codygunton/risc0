# RISC Zero Crates Validator - Types Module

## Overview

The `types` module provides core data structures and type definitions for the RISC Zero crates validator tool. This module defines the fundamental types used throughout the validation system for managing Rust crate profiles, versioning, and repository configurations.

## Core Components

### Profile Management (`profile.rs`)
- **Profile**: Main struct representing a crate validation profile with name, settings, and version constraints
- Includes validation, serialization/deserialization, and merging capabilities
- Supports creation from strings and tuples for flexible initialization

### Configuration Settings (`profile_settings.rs`)
- **ProfileSettings**: Configuration options for validation behavior including:
  - `run_prover`: Whether to execute the prover during validation
  - `should_fail`: Expected failure flag for testing error conditions
  - `inject_cc_flags`: C compiler flag injection for builds
  - `std`: Standard library usage flag
  - `fast_mode`: Optimization flag (default: true)
  - `skip`: Skip validation flag
  - Optional fields: `patch`, `import_str`, `custom_main`

### Repository Configuration (`repo.rs`)
- **Repo**: Enum supporting three repository source types:
  - `Tag`: Specific git tag reference
  - `Branch`: Git branch reference (default: "main")
  - `Path`: Local filesystem path
- **RepoCargoString**: Trait for generating Cargo.toml dependency strings
- Supports RISC Zero specific build and zkvm paths

### Version Management (`version.rs`)
- **Version**: Enum for version specifications:
  - `Latest`: Use latest available version
  - `Specific(semver::Version)`: Pin to specific semantic version
- **Versions**: Collection type (BTreeSet) with merge and filtering capabilities
- Integration with semver for proper version comparison

### Type Aliases (`aliases.rs`)
- **Profiles**: Collection of Profile objects (BTreeSet)
- **CrateName**: String type for crate names
- **GroupedProfiles**: Map of crate names to profile collections
- Implements collection operations: merge, exclude, reduce, validation

### Common Traits (`traits.rs`)
Core behavioral traits used across the module:
- **Group**: Group profiles by name
- **Merge**: Combine configurations with conflict resolution
- **Reduce**: Consolidate duplicate profiles
- **Exclude**: Filter out specified profiles
- **GetVersions**: Extract version lists
- **IsValid**: Validation support

## Key Features

- **Serialization Support**: All types implement serde for YAML/JSON configuration files
- **Validation**: Built-in validation using serde_valid for configuration correctness
- **Merging Logic**: Sophisticated merging of profiles and settings with logical OR operations
- **Version Management**: Flexible version constraints with semantic versioning support
- **Repository Abstraction**: Unified interface for different source types (git tags, branches, local paths)

## Usage Patterns

1. **Profile Creation**: Parse crate names into Profile objects with default or custom settings
2. **Configuration Merging**: Combine multiple profile sources with conflict resolution
3. **Version Resolution**: Handle both pinned versions and "latest" requirements
4. **Repository Resolution**: Generate appropriate Cargo.toml dependency entries based on source type

## Testing

The module includes comprehensive unit tests using rstest for:
- Profile merging behavior
- Version ordering and conversion
- Settings customization detection
- Collection operations (merge, exclude, reduce)

This types module serves as the foundation for the RISC Zero crates validator, providing type-safe, validated data structures for managing complex validation workflows across different crate configurations and repository sources.