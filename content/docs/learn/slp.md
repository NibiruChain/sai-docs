---
title: Sai Liquidity Positions (SLP)
description: "Sai Liquidity Positions (SLP) vaults create a passive and automatic way to earn trading fees on Sai. By depositing into an SLP vault, liquidity providers support the perpetual markets on Sai."
---

## SLP Vault Mechanics

Sai employs a single-collateral model, where each SLP vault supports liquidity for a specific **deposit asset**. By pooling liquidity in this way, Sai helps ensure efficient capital utilization and deep market liquidity, benefitting both traders and liquidity providers.

For instance, markets like BTC:USD, ETH:USD, and SOL:USD that all have USDC as the deposit asset share the same SLP vault, a vault for USDC, while markets that have a deposit asset like stNIBI would have a separate SLP vault.&#x20;

**SLP shares** represent your portion of the liquidity in a vault. These are regular, fungible tokens on Nibiru that can be redeemed for your proportional share of the vault's assets and accrued fees, subject to a withdrawal lock period.

## Why is there a Withdrawal Lock?

In the Sai protocol, SLP vaults, which stand as the foundational liquidity source for the platform, require a withdrawal lock to ensure the entire ecosystem remains fair, stable, and secure for everyone involved.

Think of these SLP vaults as the "house" or the collective pot of capital that enables traders to open positions on the Sai exchange app. Because they play such a vital role, the withdrawal lock acts as a necessary "safety buffer" for the following reasons:

### Preventing "Front-Running" (Fairness)

In a decentralized system, some information takes a moment to be officially recorded on the blockchain. Without a lock, a savvy user might see a large trader about to win a massive payout and try to withdraw their funds from the SLP vaults at the very last second to avoid "sharing" in that payout. The withdrawal lock ensures that everyone in the vault is on a level playing field and that no one can "game the system" by jumping out right before the vault has to fulfill its obligations to traders.

### Maintaining "House" Stability

SLP vaults are designed to always have enough "fuel" (liquidity) to support the traders on the platform. If everyone could pull their money out instantly during a period of market volatility, it could cause a "bank run" effect. The lock creates a predictable schedule, allowing the protocol to manage its reserves effectively and ensure there is always enough liquidity to keep the Sai exchange app running smoothly.

### Accurate Health Checks (Epochs)

The protocol calculates the "health" of the SLP vaults (how much they have versus how much they owe traders) in specific time chunks called Epochs. Because checking the status of every single open trade in real-time is incredibly complex, the protocol takes "snapshots" at the end of these periods. The withdrawal lock aligns your exit with these snapshots so the vault can accurately calculate exactly how much your share is worth based on the most recent, verified data.

Sai prioritizes the long-term safety of all depositors over the convenience of an instant exit.

## Risks

**Price Delta Risk**: SLPs are the counterparty to trades on each market. When traders profit, their winnings are received from Sai Liquidity Providers (SLPs). And when traders incur losses, the losses are sent to SLPs.

**Smart Contract Risk**: Collateral coming from bridged tokens has an inherent risk depending on the security of the bridge. Similarly, liquid staking tokens come from external smart contract applications. While this has not been any reason for concern thus far, we include it here for completeness.
