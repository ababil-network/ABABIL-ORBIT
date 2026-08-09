# ABABIL Orbit — Asset Registry Interface Design v1.0

## 1. Scope

This document defines the storage model, external interface,
custom errors and events for the Asset Registry.

This document does not implement business logic.

## 2. Canonical Asset Identity

Contract assets are identified by their EVM contract address.

The native ABABIL asset uses a protocol-defined immutable identifier.

No metadata field may be used as canonical identity.

## 3. Asset Types

Conceptual enum:

- NATIVE
- ERC20

Future asset types require a new specification.

## 4. Asset Status

Conceptual states:

- REGISTERED
- VALIDATED
- TRADING_ENABLED
- SUSPENDED
- DELISTED

Status transitions must be explicitly validated.

## 5. Verification Status

Conceptual states:

- UNVERIFIED
- SUBMITTED
- SCANNING
- VERIFIED
- REJECTED
- SUSPENDED

Verification state is independent from asset trading state.

## 6. Core Storage

The implementation should maintain:

    mapping(assetId => AssetRecord)

AssetRecord conceptually contains:

- asset identifier
- asset type
- asset status
- verification status
- metadata reference
- registration timestamp
- registry version

The final Solidity types will be selected during implementation review.

## 7. Registration Interface

Conceptual external operation:

    registerAsset(assetIdentifier, assetType, metadataReference)

Requirements:

- validate identifier
- reject duplicate assets
- validate supported asset type
- perform required compatibility checks
- create initial asset state
- emit AssetRegistered

Registration must not enable trading automatically.

## 8. Read Interface

The registry should expose read operations for:

    isRegistered(assetId)

    getAsset(assetId)

    getAssetStatus(assetId)

    getVerificationStatus(assetId)

    getMetadataReference(assetId)

Read functions must not modify state.

## 9. Validation Interface

Conceptual operation:

    validateAsset(assetId)

Validation must be deterministic and must not imply that the asset is
safe as an investment.

Successful validation changes only the defined asset state.

## 10. Verification Interface

Conceptual operations:

    submitVerification(assetId, evidenceReference)

    updateVerificationStatus(assetId, status)

Verification submission must not require a fee.

Only authorized verification logic may update verification status.

Large documents must remain off-chain; only suitable references or
cryptographic commitments should be stored on-chain.

## 11. Status Interface

Conceptual operations:

    enableTrading(assetId)

    suspendAsset(assetId, reasonReference)

    delistAsset(assetId, reasonReference)

Trading enablement must require the asset to satisfy all required
protocol conditions.

Suspension must block the affected normal execution paths.

## 12. Metadata Interface

Conceptual operation:

    updateMetadata(assetId, metadataReference)

Metadata changes must not alter asset identity.

Metadata updates require appropriate authorization or immutable
registration policy.

## 13. Custom Errors

The implementation should use custom errors such as:

    InvalidAsset
    AssetAlreadyRegistered
    AssetNotRegistered
    UnsupportedAssetType
    InvalidTokenInterface
    InvalidAssetState
    InvalidVerificationState
    TradingNotAllowed
    Unauthorized
    ZeroAddress
    MetadataInvalid

Exact parameters will be finalized during implementation.

## 14. Events

Conceptual events:

    AssetRegistered(
        assetId,
        assetType,
        timestamp
    )

    AssetValidated(
        assetId,
        timestamp
    )

    AssetStatusUpdated(
        assetId,
        previousStatus,
        newStatus,
        reasonReference
    )

    VerificationSubmitted(
        assetId,
        evidenceReference,
        timestamp
    )

    VerificationStatusUpdated(
        assetId,
        previousStatus,
        newStatus,
        timestamp
    )

    AssetMetadataUpdated(
        assetId,
        metadataReference,
        timestamp
    )

Events must be sufficient for off-chain indexers to reconstruct
important state transitions.

## 15. Access-Control Boundary

Protected operations must not be publicly writable.

At minimum, authorization must distinguish between:

- registration policy
- verification authority
- emergency authority
- governance/administration

Exact role design will be finalized after reviewing the ABABIL Orbit
governance model.

## 16. Non-Custodial Requirement

No Asset Registry operation may:

- transfer user tokens
- transfer native assets from users
- take custody of user balances
- modify AMM balances
- modify order-book balances

The registry is an identity/state component only.

## 17. Security Requirements

Implementation must verify:

- canonical identity uniqueness
- valid state transitions
- role authorization
- event correctness
- no unexpected external fund movement
- no unbounded storage growth
- safe handling of external token calls
- reentrancy safety where external calls are required

## 18. Test Interface

The test suite must cover:

### Registration

- valid asset
- duplicate asset
- invalid address
- unsupported type
- unauthorized registration where applicable

### State

- valid transition
- invalid transition
- suspension
- delisting
- re-enable restrictions

### Verification

- valid submission
- invalid state transition
- unauthorized status update
- verification revocation

### Security

- unauthorized calls
- reentrancy attempts where applicable
- malicious token behavior
- unexpected external call failure
- storage growth abuse

## 19. Implementation Gate

Before Solidity implementation:

- review storage packing
- review external calls
- review access control
- review upgrade implications
- review gas costs
- finalize interface
- finalize errors
- finalize events
- write tests

Status:

Interface Design v1.0
Implementation: Not started
