# Distribution Module

This module handles the distribution and downloading of RISC Zero components across different platforms and sources.

## Overview

The distribution module provides a unified interface for downloading and managing RISC Zero toolchain components from various sources including GitHub releases and S3 buckets. It abstracts platform-specific details and provides progress tracking for downloads and uploads.

## Key Components

### Core Types

- **`Platform`** (`mod.rs:56-100`): Represents target platforms (architecture + OS combinations)
  - Supports x86, x86_64, arm, aarch64 architectures
  - Supports macOS and Linux operating systems
  - Handles target triple conversion and detection

- **`Os`** (`mod.rs:29-51`): Operating system enumeration
  - MacOs and Linux variants
  - Maps to target triple components

### Distribution Platforms

#### GitHub Releases (`github.rs`)
- Downloads components from GitHub releases
- Handles version parsing from git tags (different formats per component)
- Supports bearer token authentication
- Validates release existence before download

#### S3 Bucket (`s3.rs`)
- Content-addressed storage using SHA256 hashes
- Distribution manifest management
- Upload functionality with AWS signature v4
- Target-specific and target-agnostic releases
- Progress tracking for uploads/downloads

### HTTP Utilities (`http.rs`)
- Low-level HTTP client functionality
- Bearer token authentication support
- JSON/text/binary download capabilities
- Upload functionality with custom request signing
- Error handling and status code validation

## Key Features

### Platform Detection
- Automatic platform detection from environment
- Target triple parsing and generation
- Architecture and OS validation

### Version Management
- Component-specific version string parsing
- Support for different versioning schemes (semantic, date-based)
- Latest version resolution

### Progress Tracking
- Real-time download/upload progress events
- Transfer start/completion notifications
- Byte-level progress reporting via `ProgressWriter` and `ProgressReader`

### Error Handling
- Comprehensive error types for network, platform, and version issues
- 404 detection for missing releases
- Validation of archive formats (tar.xz)

## Usage Patterns

### Download Flow
1. Detect or specify target platform
2. Query latest version or specify version
3. Check version availability
4. Download archive to temporary location
5. Extract and install component

### Upload Flow (S3)
1. Validate archive format
2. Calculate SHA256 hash
3. Check for existing artifacts (unless force flag)
4. Upload artifact to content-addressed storage
5. Update distribution manifest
6. Optionally set as latest version

## Security Considerations

- AWS request signing for S3 operations
- Bearer token support for private GitHub repositories
- Archive validation before processing
- Content-addressed storage prevents tampering

## Testing

The module includes comprehensive unit tests for:
- Platform target triple parsing
- Version string parsing
- C++ version format validation
- Component-specific version handling