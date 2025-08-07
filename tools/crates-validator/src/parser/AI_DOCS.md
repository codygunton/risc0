# Parser Component

## Overview
The parser component is responsible for reading and parsing YAML configuration files that define crate validation profiles. It handles both batch configurations (multiple crates with shared settings) and individual crate configurations, merging them into a unified profile set.

## Architecture

### Core Components

- **`Parser`** (`mod.rs:35-66`): Main parser struct that orchestrates the parsing process
- **`Batches`** (`batch.rs:24-63`): Handles batch configurations where multiple crates share the same settings
- **`Individual`** (`individual.rs:18-26`): Handles individual crate configurations with specific settings
- **`utils`** (`utils.rs:19-22`): Utility functions for file I/O operations

### Key Relationships

```
Parser
├── Batches (batch configurations)
│   └── BatchConfig[] (name, crates[], settings)
└── Individual (individual configurations)
    └── Profiles (direct crate profiles)
```

## Functionality

### Configuration Parsing Flow

1. **File Reading** (`Parser::new` at `mod.rs:44-47`):
   - Reads YAML configuration file using `utils::read_profile`
   - Deserializes into `Parser` struct using serde_yaml

2. **Profile Generation** (`Parser::profiles` at `mod.rs:49-56`):
   - Converts batch configurations to profiles via `TryFrom<Batches>`
   - Merges with individual profiles
   - Reduces duplicate profiles to create final profile set

### Batch Configuration Processing

**Purpose**: Allows defining multiple crates with shared settings to avoid repetition.

**Process** (`batch.rs:35-63`):
- `BatchConfig` contains a name, list of crates, and optional settings
- Each crate in the batch inherits the batch's settings
- Multiple batches are flattened and merged into a single profile collection

**Example Configuration**:
```yaml
batch:
  - name: serde-crates
    settings:
      std: true
      fast-mode: true
    crates:
      - serde
      - serde_json
      - serde_derive
```

### Individual Configuration Processing

**Purpose**: Defines specific settings for individual crates that need unique configurations.

**Process** (`individual.rs:22-26`):
- Direct mapping from individual crate configurations to profiles
- No transformation needed, just type conversion

**Example Configuration**:
```yaml
crates:
  - name: special-crate
    std: false
    custom-main: |
      fn main() {
        println!("Custom implementation");
      }
```

## Data Flow

1. **Input**: YAML configuration file path
2. **Processing**: 
   - Parse YAML into `Parser` struct
   - Convert batches to individual profiles
   - Merge batch and individual profiles
   - Reduce duplicates
3. **Output**: `Profiles` collection ready for validation

## Configuration Schema

### Batch Configuration
- `name`: Identifier for the batch
- `crates`: List of crate names
- `settings`: Optional `ProfileSettings` applied to all crates in batch

### Individual Configuration  
- `crates`: Direct list of `Profile` objects with individual settings

### Supported Settings
- `std`: Enable/disable standard library
- `fast_mode`: Enable fast compilation mode
- `patch`: Cargo patch configuration
- `inject_cc_flags`: Inject C compiler flags
- `custom_main`: Custom main function implementation
- `run_prover`: Enable/disable prover execution
- `should_fail`: Mark crate as expected to fail

## Error Handling

- **File I/O Errors**: Handled in `utils::read_profile` with context
- **YAML Parsing Errors**: Propagated from serde_yaml deserialization
- **Profile Conversion Errors**: Handled through `TryFrom` implementations with anyhow::Error

## Testing

### Test Coverage
- **Integration Tests** (`mod.rs:74-78`): Full parsing pipeline with real config file
- **Batch Tests** (`batch.rs:77-178`): Batch configuration parsing and conversion
- **Individual Tests** (`individual.rs:41-123`): Individual configuration parsing

### Test Patterns
- Uses real configuration file (`PATH_YAML_CONFIG`) for integration testing
- Mock configurations for unit testing specific scenarios
- Validates both structure and content of parsed profiles

## Dependencies

- `serde`: Serialization/deserialization framework
- `serde_yaml`: YAML parsing support  
- `anyhow`: Error handling and context
- `tracing`: Instrumentation for debugging

## Usage Patterns

### Typical Usage
```rust
let parser = Parser::new("config.yaml")?;
let profiles = parser.profiles()?;
let config: ProfileConfig = parser.try_into()?;
```

### Configuration File Structure
```yaml
# Batch configurations
batch:
  - name: web-crates
    settings:
      std: true
    crates: [reqwest, tokio, hyper]

# Individual configurations  
crates:
  - name: custom-crate
    custom-main: |
      fn main() { custom_logic(); }
```

## Performance Considerations

- **Memory**: Profiles are collected and reduced to eliminate duplicates
- **I/O**: Single file read operation per parser instance
- **Processing**: Batch expansion creates multiple profiles from single configuration

## Future Considerations

- **Validation**: Could add schema validation for configuration files
- **Caching**: File content could be cached for repeated parsing
- **Streaming**: Large configuration files could benefit from streaming parsing