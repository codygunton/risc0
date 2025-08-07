# zkVM Host API

## Overview
This component provides the host API layer for RISC Zero's zkVM, implementing client-server communication protocols and connection management for zero-knowledge proof generation and verification.

## Architecture

### Core Components

#### Connection Management (`mod.rs`)
- **ConnectionWrapper**: Thread-safe wrapper around client-server connections
- **Connector trait**: Abstraction for establishing connections
- **ParentProcessConnector**: Spawns zkVM server as child process
- **TcpConnector**: Direct TCP connection to existing server (prove feature)

#### Client Implementation (`client.rs`)
- **Client**: Main client interface for interacting with zkVM server
- Supports both narrow and wide compatibility modes
- Handles proof generation, execution, and receipt management
- Version compatibility checking between client and server

#### Server Implementation (`server.rs`)
- **Server**: Server-side request handler
- Processes execution, proving, and verification requests
- Integrates with executor and prover components
- Supports various proof types (segments, Keccak, recursion)

### Key Features

#### Protocol Communication
- **Protobuf-based messaging**: Uses generated protobuf types for structured communication
- **Message framing**: Length-prefixed message protocol over TCP
- **Thread-safe operations**: Concurrent access support with Arc<Mutex>

#### Asset Management
- **Asset enum**: Supports inline bytes, file paths, and Redis storage
- **AssetRequest**: Configurable asset storage backends
- **RedisParams**: Redis-specific configuration for distributed storage

#### Session Information
- **SessionInfo**: Execution metadata including cycles, journal, exit codes
- **SegmentInfo**: Per-segment execution statistics
- **Receipt handling**: Management of various receipt types

## Dependencies
- **anyhow**: Error handling and context
- **bytes**: Efficient byte buffer management  
- **prost**: Protocol buffer serialization
- **semver**: Version compatibility checking
- **risc0-zkp**: Core ZKP functionality
- **risc0-binfmt**: Binary format handling

## Usage Patterns

### Client Connection
```rust
let client = Client::new()?;
let session_info = client.execute(&env, binary)?;
let receipt = client.prove(&session, &opts)?;
```

### Server Deployment
```rust
let server = Server::new(connector)?;
server.run()?; // Handles incoming requests
```

### Asset Management
```rust
let asset = Asset::Path(path_to_binary);
let request = AssetRequest::Redis(redis_params);
```

## Integration Points
- **Executor**: Executes guest programs and generates execution traces
- **Prover**: Generates zero-knowledge proofs from execution traces  
- **Verifier**: Validates receipts and proofs
- **Session Management**: Tracks execution state and metadata

## Performance Considerations
- Connection pooling and reuse
- Efficient message serialization/deserialization
- Thread-local buffer management for reduced allocations
- Timeout handling for network operations