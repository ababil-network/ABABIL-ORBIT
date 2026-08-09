# ABABIL Orbit — Asset Registry Implementation Gate v1.0

## 1. Canonical Asset Key

The registry primary key is:

    bytes32 assetKey

Native ABABIL:

    keccak256("ABABIL_ORBIT_NATIVE_ABABIL_V1")

ERC-20 asset:

    keccak256(
        abi.encode(
            "ABABIL_ORBIT_ERC20_V1",
            block.chainid,
            tokenAddress
        )
    )

The asset key is generated internally.

Callers must never supply an arbitrary assetKey.

## 2. Asset Record

Initial production storage model:

    struct AssetRecord {
        AssetType assetType;
        AssetStatus assetStatus;
        VerificationStatus verificationStatus;
        uint64 registrationTimestamp;
        uint32 registryVersion;
        bytes32 metadataReference;
    }

The canonical assetKey is the mapping key and therefore does not need
to be duplicated inside the record.

The original token contract address is stored separately for ERC-20
assets so that the registry can resolve the canonical key back to the
contract.

## 3. Primary Storage

Conceptual:

    mapping(bytes32 => AssetRecord) _assets

ERC-20 resolution:

    mapping(bytes32 => address) _assetContracts

Contract-to-key lookup:

    mapping(address => bytes32) _contractToAssetKey

The implementation must ensure these mappings cannot become
inconsistent.

## 4. Native Asset

The native asset has no ERC-20 contract address.

Therefore:

    _assetContracts[nativeAssetKey]

must remain unset.

The native asset is identified only by its canonical native key and
AssetType.NATIVE.

## 5. Verification Evidence

Verification evidence is represented by a compact reference.

Conceptual:

    mapping(bytes32 => bytes32) _verificationEvidence

Large documents remain off-chain.

## 6. Role Identifiers

Roles must use domain-separated keccak256 identifiers.

Conceptual:

    REGISTRATION_ROLE
    VERIFICATION_ROLE
    EMERGENCY_ROLE
    GOVERNANCE_ROLE

Registration is permissionless at the public registration entry point.

Therefore REGISTRATION_ROLE must not be required for ordinary asset
registration.

It may be retained for future restricted administrative operations if
the final design requires it.

## 7. Verification Authority

Only the verification authority may change verification state.

The authority must not:

- change asset identity
- change token contract address
- transfer user funds
- enable arbitrary trading pairs

## 8. Emergency Authority

Emergency authority may suspend an asset within the registry.

It must not:

- transfer user funds
- alter canonical identity
- bypass verification invariants
- modify AMM balances
- modify order-book balances

## 9. Governance

Governance controls role administration and protocol-level configuration.

Governance must not bypass:

- canonical identity invariants
- authorization checks
- non-custodial boundaries
- valid state transitions

## 10. Native Initialization

Native ABABIL must be initialized exactly once.

Initialization must:

- derive the canonical native key
- create the native AssetRecord
- set AssetType.NATIVE
- set the defined initial state
- emit AssetRegistered

A second initialization must revert.

## 11. External Token Validation

ERC-20 registration may inspect the target contract.

Validation must:

- reject zero address
- require deployed contract code
- verify supported ERC-20 behavior
- safely handle malformed/reverting contracts
- avoid storing arbitrary external data

Registration must not assume that ERC-20 compatibility means safety.

## 12. State Separation

Asset status and verification status are independent.

Asset registration does not:

- verify the token
- enable trading
- create a pair
- create liquidity
- create an order book

## 13. Pair Boundary

Pair creation and pair trading activation belong to the Pair Registry.

The Asset Registry only establishes canonical asset identity and
asset-level protocol state.

## 14. Non-Custodial Invariant

The Asset Registry must never:

- hold user ERC-20 balances
- hold user native balances
- transfer user assets
- modify user trading balances

## 15. Implementation Requirements

Before implementation is accepted:

1. Unit tests pass.
2. Fuzz tests pass.
3. Invariant tests pass.
4. Authorization tests pass.
5. State-transition tests pass.
6. Identity derivation tests pass.
7. ERC-20 validation failure tests pass.
8. Reentrancy-sensitive paths are reviewed.
9. Gas/storage behavior is reviewed.
10. Full Foundry build succeeds with the pinned compiler.

Status:

Implementation Gate v1.0
AssetRegistry.sol: Not started
