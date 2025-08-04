# RISC Zero Groth16 Component

## Overview
The `risc0-groth16` component implements a verifier for the Groth16 zero-knowledge proof protocol over the BN_254 elliptic curve. It provides functionality to verify Groth16 proofs and convert RISC Zero STARK proofs to Groth16 proofs via Docker.

## Key Features
- **Groth16 Verification**: Efficient verification of Groth16 proofs using the arkworks cryptography library
- **STARK to SNARK Conversion**: Transform RISC Zero STARK proofs into Groth16 proofs using Docker-based proving
- **JSON Serialization**: Support for JSON-based proof, public input, and verifying key formats
- **Cross-platform**: Works in both `std` and `no_std` environments

## Core Components

### Verifier (`verifier.rs`)
- **`Verifier`**: Main struct for verifying Groth16 proofs
  - `new()`: Creates verifier from seal, public inputs, and verifying key
  - `from_json()`: Creates verifier from JSON representations
  - `verify()`: Performs the actual proof verification
- **`VerifyingKey`**: Wrapper around arkworks verifying key with digest support
- **`Fr`**: Field element wrapper for BN254 scalar field

### Data Structures (`data_structures.rs`) 
- **`Seal`**: Binary representation of Groth16 proof components (a, b, c)
  - `to_vec()`: Serializes seal to bytes
  - `from_vec()`: Deserializes seal from bytes
- **`ProofJson`**: JSON representation of Groth16 proof
- **`VerifyingKeyJson`**: JSON representation of verifying key with curve parameters
- **`PublicInputsJson`**: JSON representation of public witness values

### Docker Integration (`docker.rs`)
- **`stark_to_snark()`**: Converts RISC Zero STARK proofs to Groth16 proofs using Docker
  - Requires x86 architecture and Docker installation
  - Uses `risczero/risc0-groth16-prover` Docker image
  - Handles temporary file management and JSON conversion

## Key Functions

### Verification Flow
1. **`Verifier::from_json()`** - Parse JSON proof, inputs, and verifying key
2. **`Verifier::verify()`** - Execute Groth16 verification algorithm
3. Returns `Ok(())` for valid proofs, `Err` for invalid proofs

### STARK to SNARK Conversion
1. **`stark_to_snark()`** - Takes STARK seal bytes as input
2. Converts to JSON format using `to_json()`
3. Runs Docker container with Groth16 prover
4. Returns Groth16 `Seal` object

### Utility Functions
- **`split_digest()`** - Splits RISC Zero digest into two field elements
- **`fr_from_hex_string()`** - Creates field element from hex string
- **`g1_from_bytes()`/`g2_from_bytes()`** - Deserialize elliptic curve points

## Feature Flags
- **`std`**: Standard library support (default)
- **`prove`**: Enables Docker-based proving functionality
- **`unstable`**: Experimental features

## Dependencies
- **arkworks**: Cryptographic primitives for BN254 curve and Groth16
- **risc0-zkp**: Core ZKP functionality and digest types
- **serde**: JSON serialization support
- **anyhow**: Error handling

## Usage Example
```rust
use risc0_groth16::{ProofJson, PublicInputsJson, Verifier, VerifyingKeyJson};

// Load proof components from JSON
let verifying_key: VerifyingKeyJson = serde_json::from_str(vk_json)?;
let proof: ProofJson = serde_json::from_str(proof_json)?;
let public_inputs = PublicInputsJson { values: inputs };

// Create and run verifier
let verifier = Verifier::from_json(proof, public_inputs, verifying_key)?;
verifier.verify()?;
```

## Integration Points
- Used by `risc0-zkvm` for Groth16 proof generation
- Connects to Ethereum smart contracts for on-chain verification
- Integrates with RISC Zero's broader ZKP ecosystem