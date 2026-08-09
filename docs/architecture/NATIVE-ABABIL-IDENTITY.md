# ABABIL DEX — Native ABABIL Asset Identity v1.0

## 1. Purpose

This document defines the canonical identity of the native ABABIL
asset inside ABABIL DEX.

The native asset is not an ERC-20 contract and therefore must not rely
on an ERC-20 contract address as its canonical identity.

## 2. Identity Requirements

The native ABABIL identity must be:

- deterministic
- unique
- immutable after deployment
- distinguishable from ERC-20 assets
- compatible with off-chain indexing
- impossible to confuse with a real ERC-20 contract

## 3. Zero Address

The zero address must not be treated as a generic native-asset
identifier.

The implementation must explicitly distinguish:

- native ABABIL
- ERC-20 contract assets
- invalid zero address

## 4. Recommended Internal Representation

The implementation may use a dedicated immutable identifier derived
from a protocol-defined domain separator.

Conceptual domain:

    ABABIL_ORBIT_NATIVE_ABABIL_V1

The exact Solidity representation must be finalized before implementation.

## 5. Asset Type

The native asset must always use:

    AssetType.NATIVE

It must never be classified as:

    AssetType.ERC20

## 6. Initialization

The native ABABIL asset must be initialized exactly once.

Initialization must:

- create the canonical native asset record
- set AssetType to NATIVE
- set the initial asset state
- set the initial verification state
- emit the appropriate registration event

A second native-asset initialization attempt must fail.

## 7. Immutability

The canonical native identifier must never be changed after deployment.

No administrative role may replace the native asset identity.

Metadata may change according to the metadata policy, but metadata must
never modify canonical identity.

## 8. Non-Custodial Boundary

The identity mechanism must not:

- hold ABABIL balances
- transfer ABABIL
- modify user balances
- control AMM liquidity
- control order-book balances

## 9. ERC-20 Separation

ERC-20 assets are identified by their supported EVM contract address.

The registry must prevent the native identity from colliding with an
ERC-20 contract identity.

## 10. Testing Requirements

Tests must verify:

1. Native identity is deterministic.
2. Native identity is unique.
3. Native identity cannot be replaced.
4. Native initialization can occur only once.
5. Zero address cannot become a generic ERC-20 asset identity.
6. Native asset is always classified as NATIVE.
7. ERC-20 assets cannot be registered as the native asset.
8. Native identity does not create user asset custody.

## 11. Implementation Gate

Before implementation:

1. Finalize the exact domain separator.
2. Finalize the Solidity representation.
3. Confirm collision resistance.
4. Add initialization tests.
5. Add identity uniqueness tests.
6. Add zero-address tests.

Status:

Native ABABIL Identity v1.0
Implementation: Not started

## 12. Final Identity Representation

The canonical native ABABIL identifier is a bytes32 value derived from
a protocol-defined domain separator.

Conceptual derivation:

    keccak256("ABABIL_ORBIT_NATIVE_ABABIL_V1")

The domain separator is part of the protocol specification and must not
be user supplied.

The resulting bytes32 identifier is immutable for the deployed registry.

## 13. Namespace Separation

The native identifier and ERC-20 contract addresses belong to separate
logical identity domains.

An ERC-20 asset is identified by:

    AssetType.ERC20 + contract address

The native asset is identified by:

    AssetType.NATIVE + nativeAssetId

The implementation must validate both fields together.

## 14. Collision Rule

A native identifier collision with an ERC-20 address must not create
identity ambiguity because asset type is part of the canonical identity.

The implementation must nevertheless reject invalid or ambiguous
registration inputs.

## 15. Finalization

Before mainnet deployment:

1. Freeze the domain separator.
2. Freeze the resulting native identifier.
3. Add a test asserting the expected identifier.
4. Add namespace separation tests.
5. Document the identifier in deployment metadata.

Status:

Native ABABIL Identity v1.1 FINAL
Implementation: Not started
