# ABABIL Orbit — Asset Registry Role Model v1.0

## 1. Purpose

This document defines the authorization boundaries of the ABABIL Orbit
Asset Registry.

The goal is least-privilege administration without giving any role
custody over user assets.

## 2. Registration Authority

Responsible for:

- registering supported assets
- enforcing registration policy
- initiating deterministic asset validation

Must not:

- transfer user assets
- mark an asset Verified without the verification process
- modify AMM balances
- modify order-book balances

## 3. Verification Authority

Responsible for:

- processing verification submissions
- recording verification evidence
- updating verification state

Verification must never guarantee:

- token safety
- profitability
- liquidity
- price performance

Verification is an informational protocol status.

## 4. Emergency Authority

Responsible only for narrowly scoped emergency actions.

Permitted actions may include:

- suspending an affected asset
- restoring operation after a documented incident

Emergency authority must not:

- transfer user funds
- confiscate user assets
- modify user balances
- arbitrarily change asset identity

## 5. Governance Authority

Governance is responsible for protocol-level administrative decisions.

Potential responsibilities:

- role administration
- protocol configuration
- controlled upgrades if upgradeability is introduced
- emergency policy changes

Governance must not bypass core safety invariants.

## 6. Separation of Duties

The implementation should avoid giving one operational role every
privileged capability.

At minimum:

Registration
    != Verification
    != Emergency

Governance controls role administration.

## 7. Role Administration

Role changes must:

- be access controlled
- emit events
- be auditable
- follow the final governance policy

No hidden administrator.

## 8. Zero-Address Protection

Critical roles must never be assigned to the zero address.

Role removal must ensure that the protocol cannot accidentally become
permanently unusable.

## 9. Non-Custodial Boundary

No role may obtain implicit authority to:

- transfer user ERC-20 tokens
- transfer user native assets
- modify trading balances
- withdraw AMM liquidity
- modify order-book balances

## 10. Emergency Principle

Emergency authority is a circuit breaker, not a custody mechanism.

Any emergency action must be:

- narrowly scoped
- explicitly authorized
- event logged
- auditable

## 11. Implementation Gate

Before implementing roles:

1. Finalize exact role identifiers.
2. Finalize role-admin relationships.
3. Finalize initialization rules.
4. Write authorization tests.
5. Write privilege-separation tests.
6. Test zero-address protections.
7. Test emergency boundaries.

Status:

Role Model v1.0
Implementation: Not started

## 12. Permissionless Registration Boundary

Asset registration is permissionless at the protocol entry point.

Any caller may submit a valid supported asset for registration.

Permissionless registration does not automatically provide:

- verification
- trading activation
- liquidity
- routing eligibility
- endorsement
- guaranteed safety

The registry must still enforce all deterministic validation rules.

## 13. Verification Separation

Verification is an independent process.

A registered asset may remain:

    REGISTERED + UNVERIFIED

or:

    VALIDATED + UNVERIFIED

Verification authority must not control asset identity.

## 14. Trading Separation

Asset registration and verification do not automatically enable trading.

Pair-level eligibility and trading activation belong to the Pair Registry
and related trading modules.

This prevents the Asset Registry from becoming a centralized token
listing authority.

## 15. Recommended Authority Model

Permissionless:
    Asset registration

Restricted:
    Verification status changes
    Emergency suspension
    Governance configuration
    Role administration

Separate module:
    Pair creation
    Pair trading activation
    AMM configuration
    Order-book configuration
