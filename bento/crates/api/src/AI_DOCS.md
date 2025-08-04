# Bento API Component

## Overview

The Bento API is a REST API service for RISC Zero's zero-knowledge proof system. It provides endpoints for uploading images and inputs, creating proof sessions, and managing STARK and Groth16 proof workflows. The API interfaces with a PostgreSQL database and S3-compatible object storage.

## Architecture

The API is built using Axum web framework and follows a modular design:

- **lib.rs**: Main API implementation with route handlers and application state
- **helpers.rs**: Utility functions for stream management and database operations  
- **bin/rest_api.rs**: Main entry point that starts the server

## Core Components

### Application State (`AppState`)
- Database connection pool (PostgreSQL)
- S3 client for object storage
- Configuration for timeouts and retries

### Error Handling (`AppError`)
Custom error types for:
- Image validation errors
- Resource conflicts (already exists)
- Missing resources
- Database errors
- Internal errors

### API Key Extraction (`ExtractApiKey`)
Middleware for extracting API keys from `x-api-key` header. Falls back to default user if no key provided.

## API Endpoints

### Image Management
- `POST /images/upload/:image_id` - Get upload URL for ELF image
- `PUT /images/upload/:image_id` - Upload ELF image with validation

### Input Management  
- `GET /inputs/upload` - Generate upload URL for proof inputs
- `PUT /inputs/upload/:input_id` - Upload proof input data

### Receipt Management
- `GET /receipts/upload` - Generate upload URL for receipts
- `PUT /receipts/upload/:receipt_id` - Upload receipt data
- `GET /receipts/:job_id` - Get receipt download URL

### STARK Proving
- `POST /sessions/create` - Create STARK proof session
- `GET /sessions/status/:job_id` - Check proof session status
- `GET /receipts/stark/receipt/:job_id` - Download STARK receipt
- `GET /sessions/exec_only_journal/:job_id` - Download execution journal

### Groth16 Proving
- `POST /snark/create` - Create Groth16 proof from STARK receipt
- `GET /snark/status/:job_id` - Check Groth16 proof status  
- `GET /receipts/groth16/receipt/:job_id` - Download Groth16 proof

## Key Features

### Image Validation
- Computes and validates image IDs using `risc0_zkvm::compute_image_id`
- Prevents duplicate uploads by checking S3 existence
- Ensures image integrity by comparing computed vs provided IDs

### Stream Management
Creates and manages task streams for different work types:
- Auxiliary work
- Execution
- GPU proving
- GPU coprocessing
- GPU joining
- SNARK generation

### Job Lifecycle
1. **Creation**: Jobs created in database with task definitions
2. **Execution**: Tasks processed by appropriate workers
3. **Monitoring**: Status tracked via database state
4. **Completion**: Results stored in S3, accessible via download URLs

## Configuration

The API accepts configuration via command-line arguments and environment variables:

- Database connection settings
- S3/MinIO credentials and endpoints
- Timeout and retry settings for execution and SNARK generation
- Bind address for the server

## Dependencies

- **axum**: Web framework for HTTP server
- **sqlx**: PostgreSQL database driver
- **bonsai-sdk**: Response types for API compatibility
- **risc0-zkvm**: Image ID computation and validation
- **workflow-common**: Task types and S3 client
- **taskdb**: Database operations for job management

## Security Considerations

- No authentication/authorization implemented (uses default user)
- API key extraction present but falls back to default
- Image validation prevents malicious image uploads
- Error responses sanitized to prevent information leakage

## File Organization

```
src/
├── lib.rs           # Main API implementation
├── helpers.rs       # Utility functions
└── bin/
    └── rest_api.rs  # Server entry point
```

The API serves as the HTTP interface to RISC Zero's distributed proving system, handling uploads, job creation, and result retrieval for both STARK and Groth16 proof generation workflows.