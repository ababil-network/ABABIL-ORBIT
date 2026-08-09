# ABABIL Orbit — Architecture Specification v1.0

## 1. Project

ABABIL Orbit is a non-custodial hybrid decentralized exchange
designed for ABABIL Network.

Core trading model:

- AMM liquidity
- Spot order book
- Matching engine
- Smart order routing
- On-chain settlement

The implementation is original and will not copy source code from
other DEX protocols.

## 2. Core Principles

- Non-custodial
- Permissionless trading
- Contract-address-based token identity
- Transparent on-chain settlement
- Security-first architecture
- Modular design
- Audit-friendly code
- Deterministic execution
- No guaranteed returns
- No staking-based trading rewards
- No interest-based lending mechanism

## 3. Initial Assets

Initial stable asset:

- USDT

ABABIL native asset:

- ABABIL

Future stable asset:

- USD-A

Future assets must be integrated through the Asset Registry.

## 4. High-Level Architecture

Asset Registry
    |
Pair Registry
    |
+---+----------------+
|                    |
AMM              Order Book
|                    |
+--------+-----------+
         |
 Matching / Execution Engine
         |
 Smart Router
         |
 Risk & Warning Engine
         |
 Settlement
         |
 ABABIL Network

## 5. Asset Registry

Every supported asset must have a canonical identity.

The primary identity is the blockchain address.

The registry must prevent:

- duplicate asset identities
- invalid addresses
- unsupported asset types
- accidental token impersonation

Token name, symbol and logo are metadata only.
They are never treated as proof of identity.

## 6. Pair Registry

Trading pairs must be explicitly represented.

Example:

ABABIL/USDT
ABC/USDT

Each pair has:

- base asset
- quote asset
- trading status
- fee configuration
- risk configuration
- liquidity configuration
- order-book configuration

## 7. Token Verification

New tokens are initially Unverified.

Verification is optional and does not change the token's
blockchain identity.

Verified status must never be based only on:

- token name
- ticker
- logo

Verification uses submitted project information and automated
validation.

A verification result must be auditable.

Verification itself does not guarantee:

- price
- liquidity
- profitability
- safety from every possible risk

## 8. Buyer Warning System

The interface must warn users about meaningful risk indicators.

Possible indicators include:

- Unverified token
- extreme price movement
- abnormal volume
- low liquidity
- large price impact
- concentrated liquidity
- unusual trading activity

Warnings are informational risk controls, not investment guarantees.

## 9. AMM

The AMM module manages permissionless liquidity pools.

The AMM must define:

- pool accounting
- liquidity deposits
- liquidity withdrawals
- swap execution
- fee accounting
- invariant rules
- slippage calculation
- minimum output protection

All arithmetic must use safe fixed-precision methods where required.

## 10. Order Book

The order-book system supports spot trading.

Core components:

- order submission
- order cancellation
- order validation
- price-time priority
- matching
- partial fills
- settlement

Unsupported order types must be rejected explicitly.

## 11. Matching Engine

The matching engine must be deterministic.

It must guarantee:

- deterministic order priority
- deterministic matching
- deterministic settlement
- protection against invalid state transitions

Matching logic must have extensive unit, integration and invariant tests.

## 12. Smart Router

The router searches supported execution paths.

Possible routes:

- direct AMM
- multi-hop AMM
- order book
- hybrid route

The router must consider:

- expected execution price
- liquidity
- price impact
- fees
- slippage
- execution risk

The router must never promise a profitable trade.

## 13. Risk Engine

The risk engine evaluates market conditions and generates warnings.

It must not secretly block legitimate users without an explicit
protocol rule.

Risk controls must be:

- documented
- deterministic where possible
- auditable
- configurable through controlled governance

## 14. Fees

Fees must be transparent.

There must be no hidden fee.

Initial fee parameters will be defined separately after benchmarking.

Verification must not require a verification charge.

Verified status may receive a lower trading fee only if the final
fee policy explicitly defines the rule.

## 15. Emergency System

Security-critical emergency controls may include:

- pause affected module
- disable affected pair
- disable affected route
- emergency settlement procedures

Emergency authority must be minimized and protected by strict
access control.

## 16. Security

Required testing stages:

1. Unit testing
2. Integration testing
3. Property testing
4. Fuzz testing
5. Invariant testing
6. Failure testing
7. Testnet stress testing
8. External security review
9. Bug bounty before mainnet

Private keys must never be stored in source code.

## 17. Upgrade Policy

Upgradeable components must have:

- explicit upgrade authority
- documented upgrade procedure
- access control
- timelock where appropriate
- event logging
- emergency limitations

No silent protocol changes.

## 18. Development Order

1. Architecture specification
2. Asset Registry
3. Pair Registry
4. Core accounting
5. AMM
6. Order Book
7. Matching Engine
8. Smart Router
9. Token Verification
10. Risk & Warning Engine
11. Fee system
12. Emergency controls
13. API/Indexer
14. Frontend
15. Full testnet integration
16. Security review
17. Bug bounty
18. Mainnet preparation

## 19. Original Implementation Policy

ABABIL Orbit will not copy source code from Uniswap, Raydium,
Jupiter, dYdX, Curve or other protocols.

Only high-level protocol concepts may be studied.

All implementation decisions must be independently designed,
documented and tested for ABABIL Orbit.

## 20. Status

Architecture Specification: v1.0

Implementation status: Foundation stage.
