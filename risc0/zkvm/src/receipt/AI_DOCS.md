# RISC Zero Receipt Component AI Documentation

## Component Overview

The receipt component provides cryptographic receipts that prove execution of zkVM programs. These receipts serve as verifiable proof that code was executed correctly according to the RISC Zero virtual machine specification. The component implements multiple receipt types optimized for different use cases, from individual segment proofs to compressed succinct proofs.

## Core Concepts

### Receipt Types
- **SegmentReceipt**: Proves execution of individual program segments
- **CompositeReceipt**: Aggregates multiple segment receipts for complex executions with continuations
- **SuccinctReceipt**: Compressed proof via recursion for constant-size verification
- **Groth16Receipt**: SNARK-based receipt using Groth16 over BN254 curve for minimal verification cost

### Verification Context
All receipts verify against a `VerifierContext` containing trusted parameters like control IDs, circuit info, and proof system specifications that ensure receipts match expected execution environments.

## File Structure

### composite.rs
**Purpose**: Implements composite receipts for multi-segment zkVM executions

**Key Components**:
- `CompositeReceipt`: Main structure aggregating segment receipts and assumption receipts
- `CompositeReceiptVerifierParameters`: Verification parameters supporting all receipt types
- Verification logic for segment chaining and assumption resolution

**Main Functions**:
- `verify_integrity_with_context()`: Verifies entire composite receipt including segment ordering and assumptions
- `claim()`: Extracts unified claim from first/last segments
- `assumptions()`: Retrieves assumptions from final segment output

### groth16.rs  
**Purpose**: Implements Groth16 SNARK receipts for efficient verification

**Key Components**:
- `Groth16Receipt<Claim>`: Generic receipt structure with cryptographic seal
- `Groth16ReceiptVerifierParameters`: BN254 curve parameters and control roots
- Integration with risc0_groth16 backend for SNARK operations

**Main Functions**:
- `verify_integrity_with_context()`: Validates Groth16 proof against claim digest
- `into_unknown()`: Type erasure for uniform receipt handling
- `seal_size()`: Memory footprint calculation

### segment.rs
**Purpose**: Implements basic segment-level receipt verification

**Key Components**:
- `SegmentReceipt`: Fundamental receipt for individual execution segments  
- `SegmentReceiptVerifierParameters`: Control ID sets and circuit verification parameters
- POVW (Proof of Valid Work) nonce extraction

**Main Functions**:
- `verify_integrity_with_context()`: Validates segment seal against rv32im circuit
- `get_seal_bytes()`: Serializes seal data to bytes
- `povw_nonce()`: Extracts proof-of-work nonce for validation

### succinct.rs
**Purpose**: Implements recursive compression of receipts via STARK recursion

**Key Components**:
- `SuccinctReceipt<Claim>`: Recursively compressed receipt with merkle inclusion proofs
- `SuccinctReceiptVerifierParameters`: Control root and circuit parameters for recursion verification
- `MerkleProof`: Inclusion proof for control ID validation

**Main Functions**:
- `verify_integrity_with_context()`: Validates recursive STARK and control inclusion
- `allowed_control_ids()`: Generates valid control ID sets for different cycle counts
- `allowed_control_root()`: Computes merkle root of allowed control IDs

### merkle.rs
**Purpose**: Minimal merkle tree implementation for control ID commitment

**Key Components**:
- `MerkleGroup`: Tree structure for committing to control ID sets
- `MerkleProof`: Inclusion proof with sibling digests
- Fixed depth tree optimized for recursion circuit constraints

**Main Functions**:
- `calc_root()`: Computes merkle root from leaves
- `get_proof()`: Generates inclusion proof for specific control ID
- `verify()`: Validates inclusion proof against root

## Security Properties

### Cryptographic Guarantees
- **Completeness**: Valid executions always produce verifiable receipts
- **Soundness**: Invalid executions cannot produce valid receipts  
- **Zero-Knowledge**: Receipts reveal only execution claims, not private inputs
- **Succinctness**: Proof size remains constant regardless of execution length

### Verification Safeguards
- Control ID validation ensures only approved programs can generate receipts
- Circuit info matching prevents version confusion attacks
- Claim digest verification prevents tampering with execution results
- Hash function binding prevents proof malleability

## Performance Characteristics

### Receipt Size Comparison
- SegmentReceipt: ~200KB (full STARK proof)
- SuccinctReceipt: ~200KB (recursive STARK)  
- Groth16Receipt: ~192 bytes (SNARK proof)
- CompositeReceipt: Sum of constituent receipts

### Verification Time
- Segment verification: ~10ms (native STARK)
- Succinct verification: ~10ms (recursive STARK)
- Groth16 verification: ~2ms (elliptic curve operations)
- Composite verification: Sum of constituent verifications

## Usage Patterns

### Typical Workflow
1. Execute zkVM program generating segment receipts
2. Optionally aggregate segments into composite receipt  
3. Compress to succinct receipt via recursion
4. Further compress to Groth16 for minimal verification overhead
5. Verify final receipt against expected claim

### Integration Points
- Host proving system generates initial segment receipts
- Recursion circuit produces succinct receipts from segments/composites
- Groth16 circuit converts succinct receipts to SNARKs
- Verifier applications check receipts against known parameters

## Error Handling

### Common Verification Failures
- `VerifierParametersMismatch`: Receipt/verifier version incompatibility
- `InvalidProof`: Cryptographic proof validation failure
- `ClaimDigestMismatch`: Receipt claim doesn't match expected result
- `ControlVerificationError`: Control ID not in allowed set

### Debugging Support
- Detailed tracing for verification steps
- Claim comparison logging for mismatch diagnosis  
- Control root validation with inclusion proof details
- Hash function and circuit version checking

## Dependencies

### Internal Dependencies
- `risc0_binfmt`: Binary format definitions and claim structures
- `risc0_zkp`: Core ZKP verification primitives
- `risc0_circuit_*`: Circuit-specific verification logic
- `risc0_groth16`: SNARK proving/verification backend

### External Dependencies  
- `borsh`: Efficient binary serialization
- `serde`: JSON/text serialization
- `anyhow`: Error handling
- `derive_more`: Derive macro utilities

## Testing Strategy

### Unit Tests
- Receipt verification against known good/bad inputs
- Verifier parameter digest stability checking
- Merkle proof generation and validation
- Error condition coverage

### Integration Tests
- End-to-end receipt generation and verification
- Cross-receipt type conversions
- Performance benchmarking
- Compatibility testing across versions

## Future Considerations

### Planned Enhancements
- Additional SNARK backends beyond Groth16
- Batch verification optimizations
- Receipt aggregation improvements
- Hardware acceleration support

### Upgrade Paths
- Versioned verifier parameters for backward compatibility
- Gradual migration support for new cryptographic primitives
- Circuit upgrade mechanisms with parameter translation