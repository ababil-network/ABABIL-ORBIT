# ABABIL Orbit — Asset Registry v1.2 Final Specification

## 1. Purpose

The Asset Registry is the canonical identity and protocol-state
registry for assets supported by ABABIL Orbit.

It is non-custodial.

It does not hold user trading balances and does not perform swaps,
order matching or liquidity settlement.

Its responsibilities are limited to:

- canonical asset identity
- asset registration
- technical validation state
- verification state reference
- asset lifecycle state
- metadata reference
- controlled administrative state transitions

Trading logic belongs to the Pair Registry and trading modules.

## 2. Canonical Identity

### Contract assets

The canonical identity is the EVM contract address.

No other field can replace it.

The following are metadata only:

- name
- symbol
- logo
- website
- social media
- project name
- documentation
- verification documents

### Native ABABIL

ABABIL native currency uses one immutable protocol-defined native
asset identifier.

The native identifier must not collide with a contract address.

## 3. Asset Types

Initial types:

    NATIVE
    ERC20

Future asset types require a separate specification and security review.

## 4. Registration Policy

Registration and trading are separate.

A registration request must satisfy:

- valid asset identifier
- supported asset type
- no duplicate identity
- contract code existence for ERC20
- minimum technical compatibility checks
- protocol registration rules

Registration creates an asset record only.

Registration does NOT:

- create a trading pair
- enable trading
- mark an asset Verified
- guarantee safety
- guarantee liquidity
- guarantee price performance

Registration is free.

## 5. Registration Model

The initial design supports permissionless registration subject to
protocol validation rules.

Anyone may submit an eligible asset.

However:

    Registration != Validation
    Registration != Verification
    Registration != Trading Enabled

This preserves permissionless listing while keeping trading controls
separate.

## 6. Asset Lifecycle

The canonical asset lifecycle is:

    REGISTERED
        |
        v
    VALIDATED
        |
        v
    ELIGIBLE

Additional states:

    SUSPENDED
    DELISTED

Important distinction:

ELIGIBLE means the asset satisfies the registry's technical and
protocol requirements.

It does not automatically create a trading pair.

## 7. Verification Lifecycle

Verification is independent from technical validation.

Initial state:

    UNVERIFIED

Workflow:

    UNVERIFIED
        |
        v
    SUBMITTED
        |
        v
    SCANNING
       / \
      /   \
 VERIFIED  REJECTED
    |
    v
 SUSPENDED

Verification submission is free.

The verification system may use:

- submitted documents
- project information
- contract analysis
- ownership/control analysis
- token behavior analysis
- liquidity information
- risk indicators
- consistency checks

Automated scanning must not claim perfect security.

## 8. Verification Architecture

Document and project analysis should primarily occur off-chain.

The off-chain verification service may:

- receive documents
- scan documents
- inspect contracts
- run automated checks
- generate a verification result

The blockchain should store only appropriate:

- status
- timestamps
- verifier identity/reference
- evidence hash or cryptographic commitment

Large documents must not be stored directly in contract storage.

## 9. Verification Meaning

Verified means the asset passed the defined verification criteria at the
time of review.

Verified does not mean:

- guaranteed safe
- guaranteed profitable
- guaranteed liquid
- guaranteed price stability
- investment recommendation
- permanent approval

Verification may be revoked.

All status changes must be auditable.

## 10. Technical Validation

Technical validation determines whether an asset can participate in the
ABABIL Orbit trading ecosystem.

Validation may examine:

- contract existence
- ERC20 compatibility
- decimals
- transfer behavior
- return behavior
- token mechanics
- unsupported restrictions
- compatibility with settlement logic

ERC20 compatibility alone is not a security guarantee.

## 11. Risky Token Behaviors

The system must detect or classify, where technically possible:

- transfer fees
- rebasing
- blacklist controls
- pause controls
- transfer restrictions
- unusual decimals
- unusual return behavior
- balance-changing mechanics

An asset may be:

    REGISTERED + UNVERIFIED + NOT ELIGIBLE

or:

    REGISTERED + VALIDATED + UNVERIFIED + ELIGIBLE

The protocol must not assume every ERC20 is safe.

## 12. Trading Boundary

The Asset Registry does not own the final trading switch.

Trading eligibility belongs to the Pair Registry and trading policy.

Example:

    Asset Registry
          |
          v
    Asset Eligible
          |
          v
    Pair Registry
          |
          v
    Pair Created
          |
          v
    Pair Risk Check
          |
          v
    Trading Enabled

This allows:

- one asset with multiple pairs
- different risk settings per pair
- pair-specific suspension
- pair-specific warnings

## 13. Buyer Warning System

Warnings may be generated from:

### Asset-level signals

- Unverified
- verification revoked
- suspicious token behavior
- unsupported mechanics

### Pair-level signals

- low liquidity
- high price impact
- abnormal volume
- extreme price movement
- wide spread
- unusual trading activity

Warnings are informational safeguards.

They are not investment guarantees.

## 14. Asset Record

Conceptual record:

    AssetRecord {
        assetId
        assetType
        assetStatus
        verificationStatus
        metadataReference
        registrationTimestamp
        registryVersion
    }

The implementation must minimize mutable state.

## 15. Storage Rules

The registry must:

- avoid unbounded arrays
- avoid unbounded strings
- avoid storing large documents
- avoid duplicated metadata
- avoid unnecessary external calls
- keep state transitions predictable

External documents should use references or cryptographic commitments.

## 16. Public Read Interface

Conceptual read methods:

    isRegistered(assetId)
    getAsset(assetId)
    getAssetStatus(assetId)
    getVerificationStatus(assetId)
    getMetadataReference(assetId)

All read methods are view/pure operations.

## 17. Registration Interface

Conceptual operation:

    registerAsset(assetId, assetType, metadataReference)

The function must:

1. validate asset identity
2. validate asset type
3. reject duplicates
4. perform required technical checks
5. create the initial record
6. emit AssetRegistered

It must not enable trading.

## 18. Validation Interface

Technical validation is controlled by the protocol's validation policy.

Conceptual operation:

    validateAsset(assetId)

The implementation must prevent arbitrary users from falsely changing
validation state.

Validation results must be observable.

## 19. Verification Interface

Conceptual operations:

    submitVerification(assetId, evidenceHash)

    updateVerificationStatus(assetId, status, evidenceHash)

Submission may be permissionless.

Status updates require authorized verification authority.

Verification must never transfer user assets.

## 20. Asset Suspension

Conceptual operation:

    suspendAsset(assetId, reasonHash)

Suspension must prevent affected normal execution paths from treating
the asset as eligible.

Suspension must not confiscate user funds.

Any withdrawal behavior belongs to the relevant settlement/liquidity
module.

## 21. Delisting

Delisting is a stronger lifecycle action than suspension.

A delisted asset cannot normally become active again without an explicit
documented reactivation process.

Delisting must not silently transfer user funds.

## 22. Access Control

The design separates responsibilities where appropriate:

- Registration Policy
- Validation Authority
- Verification Authority
- Emergency Authority
- Governance Authority

The minimum required privilege must be granted to each role.

No role should have unrestricted access by default.

## 23. Events

Conceptual events:

    AssetRegistered
    AssetValidated
    AssetStatusUpdated
    VerificationSubmitted
    VerificationStatusUpdated
    AssetMetadataUpdated

Events must provide enough information for indexers to reconstruct
important state transitions.

## 24. Custom Errors

Conceptual errors:

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

Exact parameters are finalized during implementation.

## 25. Security Invariants

The implementation must guarantee:

1. One contract address maps to one canonical asset.
2. Invalid contract addresses cannot become valid asset records.
3. Metadata cannot create asset identity.
4. Verification cannot create asset identity.
5. Registration cannot transfer user funds.
6. Registration cannot enable trading.
7. Suspended assets cannot bypass normal eligibility checks.
8. Unauthorized state changes must fail.
9. Invalid lifecycle transitions must fail.
10. Important state transitions emit events.
11. User-controlled data cannot create unbounded storage growth.
12. Registry functions cannot alter AMM or order-book balances.
13. External token calls must fail safely.
14. Reentrancy protections must be used wherever applicable.

## 26. Testing Requirements

### Unit tests

- native registration
- ERC20 registration
- duplicate registration
- invalid address
- unsupported asset type
- technical validation
- suspension
- delisting
- metadata
- verification states
- authorization

### Property tests

- identity uniqueness
- lifecycle validity
- authorization
- metadata isolation
- non-custody

### Fuzz tests

- random addresses
- registration sequences
- verification sequences
- state transitions
- malicious token behaviors
- unauthorized callers
- repeated calls

### Integration tests

The registry must be tested with:

- Pair Registry
- AMM
- Order Book
- Router
- Risk Engine
- Settlement
- Indexer

## 27. Upgrade Policy

The final implementation should prefer the simplest secure architecture.

If upgradeability is introduced, it requires a separate security design
covering:

- upgrade authority
- storage compatibility
- access control
- timelock
- upgrade events
- emergency behavior

No silent upgrades.

## 28. Gas and Security Principles

Optimization must never reduce correctness or security.

The implementation should:

- minimize storage writes
- avoid unbounded loops
- minimize unnecessary external calls
- use explicit state transitions
- use custom errors
- avoid arbitrary external callbacks

Gas optimization will be measured after correctness is established.

## 29. Non-Custodial Boundary

The Asset Registry never holds:

- user token balances
- user native balances
- liquidity positions
- order-book funds

Those responsibilities belong to dedicated trading and settlement
modules.

## 30. Fee Policy

Registration:

    FREE

Verification submission:

    FREE

Trading fees:

    Defined by the separate Fee System.

Any verified-token fee benefit must be transparent and deterministic.

## 31. Implementation Gate

Before implementation:

1. Freeze this specification.
2. Finalize Solidity types.
3. Finalize storage layout.
4. Finalize interface.
5. Finalize custom errors.
6. Finalize events.
7. Finalize access-control roles.
8. Write tests.
9. Review external calls.
10. Implement.
11. Run unit tests.
12. Run fuzz/invariant tests.
13. Run integration tests.

## 32. Original Implementation Policy

ABABIL Orbit implementation must be original.

High-level concepts from existing protocols may be studied.

Source code, proprietary implementations or copied contract logic must
not be reused.

## 33. Status

Specification: v1.2 FINAL

Implementation: Not started

Next stage:

    Solidity Interface
    Storage Layout
    Custom Errors
    Events
    Test Plan
