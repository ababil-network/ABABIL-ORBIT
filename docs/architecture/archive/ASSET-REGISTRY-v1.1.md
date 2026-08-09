# ABABIL Orbit — Asset Registry Specification v1.1

## 1. Purpose

The Asset Registry is the canonical registry for assets supported by
ABABIL Orbit.

It provides deterministic asset identity and controlled metadata for
the Pair Registry, AMM, Order Book, Router, Risk Engine, Verification
System and Settlement layer.

The blockchain asset address is the canonical identity.

Token name, symbol, logo, website and submitted documents are metadata
or verification evidence only. They never define asset identity.

The Asset Registry is non-custodial.

## 2. Design Principles

- Non-custodial
- Deterministic asset identity
- Permissionless asset registration where protocol rules permit
- Registration, validation, verification and trading are separate
  operations
- Security-first design
- Least-privilege administration
- Explicit state transitions
- Auditable events
- No hidden registration fee
- No verification submission fee
- No guaranteed investment outcome

## 3. Supported Asset Types

Initial supported types:

1. ABABIL native asset
2. ERC-20 compatible contract assets on the supported ABABIL EVM
   network

Future asset types require a separate specification and security review.

## 4. Canonical Identity

For contract assets:

    assetId = contract address

The contract address is the authoritative identity.

The following must never be used as the canonical identity:

- token name
- token symbol
- logo
- website
- social media account
- project name
- submitted documentation

For the ABABIL native asset, the implementation must use one immutable
protocol-defined native asset identifier.

## 5. Asset Registration

Registration creates a registry record but does not enable trading.

A registration request must satisfy:

- valid asset identifier
- supported asset type
- contract code existence for contract assets
- required interface compatibility
- duplicate prevention
- protocol validation rules

Registration must not:

- transfer user funds
- grant trading permission automatically
- grant verification automatically
- imply protocol endorsement

Registration is free.

## 6. Asset Lifecycle

Asset lifecycle is independent from verification status.

### Asset status

    REGISTERED
        |
        v
    VALIDATED
        |
        v
    TRADING_ENABLED
        |
        +------> SUSPENDED
        |
        +------> DELISTED

A suspended asset may be restored only through the documented
authorization path.

A delisted asset must not be silently re-enabled.

## 7. Verification Lifecycle

Verification is a separate process.

Initial state:

    UNVERIFIED

Verification workflow:

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

Automated scanning may evaluate:

- submitted project information
- contract metadata
- contract behavior indicators
- ownership/control characteristics
- token transfer characteristics
- liquidity information
- known risk indicators
- document consistency

Automated scanning must not claim perfect security.

A token can remain Unverified even when it is tradeable.

## 8. Verification Meaning

Verified means that the token passed the ABABIL Orbit verification
criteria at the time of review.

Verified does NOT mean:

- guaranteed safe
- guaranteed profitable
- guaranteed liquid
- guaranteed price stability
- investment recommendation
- permanent approval

Verification may be revoked when new material risk is identified.

All verification changes must be auditable.

## 9. Registration vs Validation vs Verification vs Trading

These are independent concepts.

### Registration

Creates the canonical asset record.

### Validation

Determines whether the asset meets technical compatibility and protocol
requirements.

### Verification

Evaluates project information and risk evidence.

### Trading enablement

Determines whether a particular asset/pair is permitted to execute
trades.

Therefore:

    Registered != Validated != Verified != Trading Enabled

An asset may be:

    Registered + Validated + Unverified + Trading Enabled

if protocol policy permits that configuration.

## 10. Asset Record

The implementation should maintain minimal canonical state.

Conceptual fields:

- asset identifier
- asset type
- asset status
- verification status
- metadata reference
- registration timestamp
- registry version

Verification-specific information should not unnecessarily duplicate
the core asset record.

Large documents must not be stored directly in contract storage.

Use content references/hashes where appropriate.

## 11. Metadata

Metadata may include:

- name
- symbol
- decimals
- project information reference
- logo reference
- documentation reference

Metadata is untrusted input.

Metadata must never override the canonical contract address.

Metadata changes must emit an event.

## 12. Token Compatibility Validation

For contract assets, validation should consider:

- address validity
- contract code existence
- ERC-20 interface compatibility
- decimals availability
- balance/transfer behavior where safely testable
- return-value compatibility
- protocol-supported token behavior

The registry must not assume that ERC-20 compatibility means economic
or security safety.

## 13. Risky Token Behaviors

The system must detect or classify supported risks such as:

- transfer fees
- rebasing
- blacklist controls
- pause controls
- transfer restrictions
- unusual decimals
- unusual transfer return behavior
- balance-changing mechanics

Registration may succeed while trading remains disabled.

Unsupported behavior must be rejected or explicitly classified before
trading enablement.

## 14. Trading Enablement

Trading permission belongs to the trading/pair layer.

Registering an asset does not automatically create or activate a pair.

Lifecycle:

    Asset Registry
          |
          v
    Pair Registry
          |
          v
    Pair Validation
          |
          v
    Trading Enabled

The same asset may be registered while some pairs are enabled and
others remain disabled.

## 15. Pair-Level Risk

Risk is not always an asset-level property.

The Risk Engine must also consider:

- pair liquidity
- price impact
- volatility
- abnormal volume
- spread
- concentration
- market depth

Therefore an asset may be valid while a specific pair receives a warning
or is temporarily disabled.

## 16. Buyer Warning System

The frontend/API may display warnings such as:

- Unverified token
- Low liquidity
- High price impact
- Extreme price movement
- Abnormal volume
- Wide spread
- Unusual trading activity
- Suspended asset
- Suspended pair

Warnings are informational risk controls.

Warnings must not be represented as guarantees.

## 17. Access Control

Protected operations must use explicit least-privilege authorization.

Potential roles:

- Registry Administrator
- Verification Authority
- Emergency Authority
- Governance Authority

Roles must be separated where separation materially improves security.

No role should receive unnecessary permissions.

Administrative actions must emit events.

## 18. Emergency Controls

Emergency suspension may be used when a material protocol or asset risk
is identified.

Emergency controls must be:

- narrowly scoped
- access controlled
- auditable
- event-producing
- reversible through a documented process where appropriate

Emergency suspension must not confiscate user assets.

Emergency controls should disable affected execution paths rather than
introduce arbitrary asset transfers.

## 19. Events

At minimum, conceptual events include:

- AssetRegistered
- AssetValidated
- AssetStatusUpdated
- VerificationSubmitted
- VerificationStatusUpdated
- AssetMetadataUpdated

Events must contain enough information for an indexer to reconstruct
state transitions.

## 20. Errors

The implementation should use explicit custom errors rather than
ambiguous string-based failures.

Conceptual errors:

- InvalidAsset
- AssetAlreadyRegistered
- AssetNotRegistered
- UnsupportedAssetType
- InvalidTokenInterface
- InvalidAssetState
- Unauthorized
- VerificationStateInvalid
- TradingNotEnabled

Exact names are finalized during interface design.

## 21. Security Invariants

The implementation must preserve at least:

1. A contract address maps to at most one canonical asset.
2. Invalid contract addresses cannot become registered contract assets.
3. Metadata cannot create a second asset identity.
4. Verification cannot create a second asset identity.
5. Registration cannot transfer user funds.
6. Registration cannot silently enable trading.
7. Suspended assets cannot execute through normal enabled paths.
8. Unauthorized accounts cannot modify protected state.
9. State transitions must follow the defined lifecycle.
10. Critical state transitions must be observable through events.
11. Unbounded user-controlled data must not create unbounded contract
    storage growth.
12. Administrative functions must not bypass core accounting invariants.

## 22. Testing Requirements

### Unit tests

- native asset registration
- valid contract registration
- invalid address
- duplicate registration
- unsupported asset type
- invalid token interface
- metadata handling
- verification transitions
- suspension
- delisting
- access control
- trading enablement separation

### Property tests

- identity uniqueness
- state transition validity
- authorization invariants
- metadata isolation
- registration cannot move funds

### Fuzz tests

Fuzz:

- addresses
- metadata references
- registration sequences
- verification sequences
- suspension sequences
- unauthorized calls
- repeated state transitions

### Integration tests

Test interaction with:

- Pair Registry
- AMM
- Order Book
- Router
- Risk Engine
- Indexer

## 23. Gas and Storage Rules

The registry should minimize permanent storage.

Rules:

- avoid unbounded strings in contract storage
- avoid loops over unbounded asset collections
- avoid duplicated metadata
- prefer references/hashes for large external documents
- keep state transitions predictable
- use compact representations only when they do not reduce safety or
  readability

## 24. Non-Custodial Boundary

The Asset Registry must never hold user trading balances.

Trading and liquidity contracts are responsible for their own accounting
and settlement.

The registry only records asset identity and protocol state.

## 25. Fee Policy

Asset registration:

    FREE

Verification submission:

    FREE

Trading fees:

    Defined separately by the Fee System.

Any reduced fee for verified assets must be transparent, deterministic
and explicitly documented.

## 26. Governance and Upgrades

Any upgradeable registry implementation must define:

- upgrade authority
- authorization rules
- upgrade events
- review process
- timelock where appropriate
- emergency limitations

No silent upgrade is permitted.

The final upgrade architecture must be defined before deployment.

## 27. Implementation Gate

Before production implementation:

1. Review this specification.
2. Finalize storage layout.
3. Finalize public/external interfaces.
4. Finalize custom errors.
5. Finalize events.
6. Finalize access-control model.
7. Define state-transition tests.
8. Define fuzz/invariant tests.
9. Review gas/storage behavior.
10. Implement.
11. Run automated tests.
12. Perform integration testing.

## 28. Original Implementation Policy

ABABIL Orbit will not copy source code from other DEX protocols.

High-level protocol concepts may be studied, but implementation,
interfaces and security logic must be independently designed for
ABABIL Orbit.

## 29. Status

Specification: v1.1

Implementation: Not started

Next stage:

    Interface + Storage Layout + Error Model
