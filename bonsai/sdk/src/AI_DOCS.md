# Bonsai SDK Component Documentation

## Overview
The Bonsai SDK is a Rust library that provides a comprehensive HTTP REST client for interacting with the Bonsai-alpha prover interface. This SDK enables developers to submit zero-knowledge proof requests to the Bonsai proving service and manage the entire proof generation lifecycle.

## Core Functionality
This component handles HTTP REST requests to the Bonsai proving service, providing both blocking and non-blocking (async) APIs for:

- **Image Management**: Upload and manage ELF files or bincode encoded MemoryImages
- **Input Data Handling**: Upload input data for proof generation
- **Session Management**: Create, monitor, and control proof generation sessions
- **Receipt Management**: Download and verify generated proofs
- **SNARK Conversion**: Convert STARK proofs to SNARK proofs for blockchain compatibility
- **Resource Management**: Monitor quotas, cycle budgets, and delete unused resources

## Key Components

### Client Architecture
- **Dual API Support**: Both blocking (`bonsai_sdk::blocking::Client`) and async (`bonsai_sdk::non_blocking::Client`) versions
- **Environment Configuration**: Configurable via `BONSAI_API_URL` and `BONSAI_API_KEY` environment variables
- **Connection Pooling**: Built-in HTTP client with optimized connection management
- **Timeout Control**: Configurable timeouts via `BONSAI_TIMEOUT_MS` environment variable

### Session Management
- **SessionId**: Represents active proof generation sessions with status monitoring
- **Proof States**: Tracks progression through Setup → Executor → ProveSegments → Planner → Recursion → Finalize
- **Execute-Only Mode**: Support for execution-only sessions that don't generate proofs
- **Cycle Limits**: Configurable execution cycle limits for resource management

### Error Handling
- **Comprehensive Error Types**: Server errors, HTTP errors, missing credentials, file not found
- **Status Code Handling**: Proper HTTP status code interpretation and error propagation
- **Retry Logic**: Built-in handling for transient failures

## API Capabilities

### Image Operations
- `upload_img()`: Upload ELF files or memory images with deduplication
- `upload_img_file()`: Upload images directly from file paths
- `has_img()`: Check if an image already exists
- `image_delete()`: Remove unused images

### Input/Receipt Operations
- `upload_input()`: Upload input data for proof generation
- `upload_receipt()`: Upload existing receipts for assumptions
- `receipt_download()`: Download completed proofs
- `input_delete()`: Clean up unused inputs

### Session Operations
- `create_session()`: Start new proof generation sessions
- `create_session_with_limit()`: Start sessions with custom cycle limits
- Session status monitoring with detailed state information
- `logs()`: Retrieve guest program execution logs
- `stop()`: Terminate running sessions
- `exec_only_journal()`: Fetch execution results without proofs

### SNARK Operations
- `create_snark()`: Convert STARK proofs to SNARK format
- SNARK session monitoring and status tracking
- Blockchain-compatible proof generation

### Utility Operations
- `version()`: Check supported RISC0 versions
- `quotas()`: Monitor cycle budgets and limits
- `download()`: Generic file download functionality

## Configuration

### Environment Variables
- `BONSAI_API_URL`: Bonsai service endpoint URL
- `BONSAI_API_KEY`: Authentication key for API access
- `BONSAI_TIMEOUT_MS`: Request timeout in milliseconds (default: 30000)

### Features
- `non_blocking`: Enables async/await support (optional)
- Default feature set provides blocking API only

## Dependencies
- **reqwest**: HTTP client with TLS support
- **serde**: JSON serialization/deserialization
- **tokio**: Async runtime (when non_blocking feature enabled)
- **thiserror**: Error handling
- **maybe-async**: Dual sync/async API generation

## Integration Points
This SDK integrates with:
- **RISC0 ZKVM**: Provides the execution environment and proof generation
- **Bonsai Service**: Cloud-based proving infrastructure
- **Blockchain Networks**: Via SNARK proof compatibility

## Usage Patterns
1. **Environment Setup**: Configure API credentials and endpoints
2. **Image Upload**: Upload guest program ELF files
3. **Input Preparation**: Serialize and upload input data
4. **Session Creation**: Start proof generation with optional assumptions
5. **Status Monitoring**: Poll session status until completion
6. **Receipt Download**: Retrieve and verify generated proofs
7. **Optional SNARK Conversion**: Convert proofs for blockchain use

## Security Considerations
- **API Key Management**: Secure storage and handling of authentication credentials
- **TLS Communication**: All API communication uses HTTPS with rustls
- **Input Validation**: Proper validation of user inputs and API responses
- **Error Information**: Careful handling of error messages to prevent information leakage

## Testing
Comprehensive test suite covering:
- Client construction and configuration
- Image upload/download operations
- Session lifecycle management
- SNARK conversion workflows
- Error handling scenarios
- Both blocking and async API variants

## Performance Characteristics
- **Connection Pooling**: Efficient HTTP connection reuse
- **Timeout Management**: Configurable timeouts prevent hanging requests
- **Deduplication**: Automatic detection of duplicate image uploads
- **Streaming Support**: Efficient handling of large file uploads/downloads