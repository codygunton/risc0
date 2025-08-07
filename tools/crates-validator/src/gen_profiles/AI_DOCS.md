# Gen Profiles Module

## Overview
The `gen_profiles` module implements a state machine-based system for generating crate validation profiles by downloading and processing the crates.io database dump. It creates YAML configuration files that specify how to validate specific Rust crates.

## Architecture

### State Machine Pattern
The module uses a type-safe state machine with the following states:
- `Initialize` - Initial state for setup
- `ReadProfilesConfig` - Loads existing profile configurations
- `DownloadDatabase` - Downloads crates.io database dump
- `ProcessDatabase` - Extracts and processes database contents
- `FilterSelectedCrates` - Applies filtering criteria to select crates
- `WriteProfile` - Outputs final YAML profile configuration

### Key Components

#### `StateMachine<S>`
Generic state machine struct that ensures type-safe state transitions and prevents invalid operations.

#### Database Processing
- Downloads compressed database dump from `https://static.crates.io/db-dump.tar.gz`
- Extracts crate metadata, versions, categories, and download statistics
- Processes relationships between crates and categories

#### Crate Selection Logic
The module supports multiple crate selection strategies:
- **By popularity**: Select top N crates by download count
- **By category**: Select crates from specific categories
- **Single crate mode**: Generate profile for one specific crate
- **Custom profiles**: Load existing profile configurations

#### Filtering and Deduplication
- Removes duplicate crates across selection methods
- Filters out prerelease versions, selecting stable releases
- Merges custom profiles with auto-generated selections

## Usage Patterns

### Profile Generation Workflow
```rust
let profiles = GenProfiles::new(args)
    .read_profiles_config()?
    .download_database().await?
    .process_database()?
    .filter_selected_crates()?
    .write_profile()?;
```

### Command Line Options
- `--crate-count N`: Select top N crates by downloads
- `--categories`: Filter by specific categories
- `--name`: Single crate mode
- `--profiles-file`: Load custom profile configurations
- `--output-path`: Specify output YAML file location

## Implementation Details

### Database Schema Handling
Processes multiple database tables:
- `crates`: Basic crate information
- `versions`: Version history and metadata
- `categories`: Category definitions
- `crates_categories`: Crate-to-category relationships
- `crate_downloads`: Download statistics

### Version Selection Strategy
- Prioritizes non-prerelease versions
- Selects most recent stable version per crate
- Falls back to latest version if no stable releases exist

### Output Format
Generates YAML configuration compatible with the crates-validator tool, containing:
- Crate names and version specifications
- Custom validation settings per crate
- Profile-specific configuration options

## Dependencies
- `db_dump`: Database extraction and parsing
- `reqwest`: HTTP client for database download
- `serde_yaml`: YAML serialization
- `indicatif`: Progress bar display
- `tokio`: Async runtime support

## Testing
Includes unit tests for:
- Category filtering logic
- Configuration parsing
- State transitions
- Data structure validation