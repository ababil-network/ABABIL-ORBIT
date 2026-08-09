# ABABIL DEX — Canonical Asset Identity Key v1.0

## 1. Purpose

ABABIL DEX uses a single bytes32 canonical asset key for registry
identity.

The key must uniquely represent the asset within the protocol.

## 2. Canonical Key

Conceptual representation:

    bytes32 assetKey

The Asset Registry uses assetKey as the primary mapping key.

## 3. Native ABABIL

Native ABABIL uses:

    keccak256("ABABIL_ORBIT_NATIVE_ABABIL_V1")

The domain separator is protocol-defined and immutable.

## 4. ERC-20 Assets

ERC-20 assets use a domain-separated derivation containing:

- protocol domain
- supported EVM chain ID
- contract address

Conceptual:

    keccak256(
        abi.encode(
            "ABABIL_ORBIT_ERC20_V1",
            chainId,
            tokenAddress
        )
    )

The exact encoding must be used consistently by contracts, indexers
and clients.

## 5. Why Chain ID Is Included

The same contract address can exist on different EVM networks.

Including chain ID prevents those deployments from sharing the same
canonical asset identity.

## 6. Identity vs Metadata

The following must never define canonical identity:

- token name
- token symbol
- logo
- website
- decimals
- project description

These are metadata or token properties only.

## 7. Zero Address

A zero contract address is invalid for ERC-20 registration.

The native asset does not use the zero address.

## 8. Immutability

Once an assetKey is associated with an asset, the association cannot
be replaced.

Metadata and verification state may change according to protocol rules,
but canonical identity cannot change.

## 9. Collision Requirements

The implementation must test:

- native/erc20 namespace separation
- chain-id separation
- address uniqueness
- duplicate registration
- deterministic key generation

No user-supplied arbitrary bytes32 value may be accepted as the
canonical assetKey.

## 10. Implementation Gate

Before AssetRegistry.sol:

1. Finalize exact hash domains.
2. Finalize ABI encoding.
3. Finalize chain ID source.
4. Add deterministic identity tests.
5. Add collision/namespace tests.
6. Add duplicate-registration tests.

Status:

Canonical Asset Identity Key v1.0
Implementation: Not started
