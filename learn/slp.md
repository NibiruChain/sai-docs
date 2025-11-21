---
description: >-
  Sai Liquidity Provision (SLP) vaults create a passive and automatic way to
  earn trading fees on Sai. By depositing into an SLP vault, liquidity providers
  support the perpetual markets on Sai.
icon: fire
---

# Sai Liquidity Provision (SLP)

## SLP Vault Mechanics

Sai employs a single-collaeral model, where each SLP vault supports liquidity for a specific **deposit asset**. By pooling liquidity in this way, Sai helps ensure efficient capital utilization and deep market liquidity, benefitting both traders and liquidity providers.

For instance, markets like BTC:USD, ETH:USD, and SOL:USD that all have USDC as the deposit asset share the same SLP vault, a vault for USDC, while markets that have a deposit asset like stNIBI would have a separate SLP vault.&#x20;

**SLP shares** represent your portion of the liquidity in a vault. These are regular, fungible tokens on Nibiru that can be redeemed at any time for your proportional share of the vault's assets and accrued fees.

## Risks

**Price Delta Risk**: SLPs are the counterparty to trades on each market. When traders profit, their winnings are received from Sai Liquidity Providers (SLPs). And when traders incur losses, the losses are sent to SLPs.

**Smart Contract Risk**: Collateral coming from bridged tokens has an inherent risk depending on the security of the bridge. Similarly, liquid staking tokens come from external smart contract applications. While this has not been any reason for concern thus far, we include it here for completeness.
