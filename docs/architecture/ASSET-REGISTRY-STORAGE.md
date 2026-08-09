# ABABIL Orbit — Asset Registry Storage Layout v1.0

## 1. Purpose

This document defines the initial storage architecture for the
ABABIL Orbit Asset Registry.

The registry is non-custodial and must never store user trading
balances.

## 2. Canonical Asset Mapping

Primary storage:

    mapping(address => AssetRecord) _assets

The mapping key is the canonical EVM contract address.

A dedicated immutable identifier is used for the native ABABIL asset.

## 3. Registration Tracking

The implementation must provide deterministic registration lookup.

Conceptual state:

    mapping(address => bool) _registered

The implementation may derive registration state from AssetRecord where
that is safer and more gas-efficient.

There must be only one authoritative registration source.

## 4. Asset Record

Conceptual fields:

    address assetId
    AssetType assetType
    AssetStatus assetStatus
    VerificationStatus verificationStatus
    bytes32 metadataReference
    uint64 registrationTimestamp
    uint32 registryVersion

Storage packing should be evaluated during implementation.

Gas optimization must not reduce clarity or safety.

## 5. Native Asset

The native ABABIL asset must have a protocol-defined immutable identity.

The implementation must not rely on an ambiguous zero-address convention
for canonical identity.

The native asset must be initialized exactly once.

## 6. Registry Version

The registry version identifies the schema/protocol version associated
with an asset record.

Version changes require explicit protocol review.

## 7. Metadata

Metadata is represented by a compact reference:

    bytes32 metadataReference

Large metadata and documents must remain off-chain.

The reference may represent a content hash, commitment or other
protocol-defined identifier.

## 8. Verification Evidence

Verification evidence must not be stored as large on-chain documents.

Only compact references/commitments should be stored.

Conceptual:

    mapping(address => bytes32) _verificationEvidence

The final implementation may integrate this value into the AssetRecord
if doing so provides a cleaner single source of truth.

## 9. Verification Authority

Verification status changes require controlled authorization.

The registry must not allow arbitrary callers to mark assets Verified.

## 10. Asset State

Asset state and verification state are independent.

Example:

    VALIDATED + UNVERIFIED
    VALIDATED + VERIFIED
    SUSPENDED + VERIFIED
    ELIGIBLE + UNVERIFIED

The implementation must enforce valid combinations and transitions.

## 11. Trading Boundary

The Asset Registry does not store pair-specific trading state.

It must not store:

- AMM liquidity
- order-book balances
- user balances
- swap state
- order state
- router state

Pair-level trading status belongs to the Pair Registry.

## 12. Access Control State

Protected operations require explicit authorization.

The implementation should use role-based permissions rather than one
unrestricted administrator.

Roles will be finalized before implementation.

## 13. Emergency State

Emergency suspension must be scoped to the asset registry state.

It must not provide arbitrary token transfer authority.

## 14. Storage Safety

The implementation must avoid:

- unbounded arrays
- unbounded strings
- user-controlled dynamic storage growth
- duplicated canonical identity
- duplicated metadata
- unnecessary storage writes

## 15. External Calls

External token calls must be minimized.

Any required external call must be:

- bounded
- failure-safe
- explicitly handled
- reviewed for reentrancy

## 16. Upgrade Considerations

The first implementation should prefer a simple architecture.

If upgradeability is introduced later, storage compatibility must be
specified before deployment.

No storage migration may silently change asset identity or state.

## 17. Storage Invariants

The implementation must guarantee:

1. One contract address has at most one canonical asset record.
2. Registration cannot overwrite an existing asset.
3. Metadata cannot change asset identity.
4. Verification cannot change asset identity.
5. Registry storage cannot contain user trading balances.
6. Pair-specific trading state is not stored here.
7. Unauthorized state changes fail.
8. Invalid lifecycle transitions fail.
9. Storage growth remains bounded by registered assets and defined
   protocol state.

## 18. Implementation Gate

Before writing production AssetRegistry.sol:

1. Review this storage design.
2. Finalize role model.
3. Finalize native asset identifier.
4. Finalize exact Solidity storage types.
5. Write unit tests.
6. Write invariant tests.
7. Review external calls.
8. Implement.
9. Compile with the pinned Solidity version.
10. Run the full test suite.

Status:

Storage Layout v1.0
Implementation: Not started
