---
title: "Getting Started"
description: "Build on Sai with comprehensive technical documentation, API references, and integration guides."
---

![Getting Started](/assets/sai-docs/sai-twitter-banner-1500x500.jpg)

Build powerful applications on top of Sai's perpetual futures protocol. Whether you're creating trading bots, analytics dashboards, or custom integrations, this documentation will guide you through the process.

## Quick Start

Choose your integration path based on your development environment:

- **[EVM Integration Guide](/docs/dev/evm-guide/)** — Start here if you're building on EVM chains. Covers environment setup, contract connections, and basic operations like opening positions and managing collateral
- **[WASM Integration Guide](/docs/dev/wasm-guide/)** — For WASM-based chains and clients. Learn integration patterns with language-specific examples and deployment guidance

***

## Sai Core

Comprehensive documentation of the Sai smart contracts, modules, and architecture.

### Core Modules

- **[Perp Contract](/docs/dev/sai-core/perp-contract/)** — Main perpetual futures contract handling position management, collateral, and settlement
- **[Borrowing Module](/docs/dev/sai-core/perp-borrowing/)** — Borrowed funds management, interest rates, and liquidation mechanics
- **[Price Impact Module](/docs/dev/sai-core/perp-price-impact/)** — How large trades affect pricing, slippage calculation, and execution costs

### Reference Documentation

- **[State Variables](/docs/dev/sai-core/perp-state/)** — Complete reference of all smart contract state variables and their purposes
- **[Contract Addresses Reference](/docs/dev/sai-core/contracts/)** — Mainnet and testnet deployment addresses for all Sai contracts
- **[WASM &#x26; EVM Integration](/docs/dev/sai-core/contract-integration/)** — Platform-specific details for direct smart contract integration

***

## Sai Keeper

Query and subscribe to real-time data from the Sai protocol. Perfect for dashboards, bots, and analytics tools.

### Getting Started

- **[Core Concepts](/docs/dev/sai-keeper/core-concepts/)** — Understand indexing, subscriptions, and how Keeper structures protocol data
- **[Client Setup](/docs/dev/sai-keeper/client-setup/)** — Get your GraphQL client configured and authenticated in minutes

### API Reference

- **[Perp API](/docs/dev/sai-keeper/api-perp/)** — Query positions, orders, trades, and perpetual-specific data
- **[Liquidity Provider (LP) API](/docs/dev/sai-keeper/api-lp/)** — Access liquidity pool data, provider positions, and performance metrics
- **[Oracle API](/docs/dev/sai-keeper/api-oracle/)** — Get price feeds and oracle data used throughout the protocol
- **[Fees API](/docs/dev/sai-keeper/api-fees/)** — Query fee structures, accruals, and historical fee data

### Examples & Advanced Usage

- **[Examples: Queries](/docs/dev/sai-keeper/examples-queries/)** — Copy-paste ready GraphQL queries for common use cases
- **[Examples: Subscriptions](/docs/dev/sai-keeper/examples-subscriptions/)** — See how to subscribe to real-time updates and build event-driven applications
- **[Filters &#x26; Pagination](/docs/dev/sai-keeper/filters-pagination/)** — Master filtering, sorting, and pagination for efficient large-scale data retrieval

***

## Use Cases

Practical integration examples and real-world applications built on Sai.

- **[Telegram Bot Integration](/docs/dev/use-cases/tg-guide/)** — Build a Telegram trading bot with position monitoring, alerts, and order execution

***

## Developer Resources

**Need help or want to connect with other builders?**

* 🐦 [X / Twitter](https://x.com/SaiDotFun) - @SaiDotFun
* 📢 [Telegram News Channel](https://t.me/saidotfun) - t.me/saidotfun
* 📸 [Instagram](https://instagram.com/saidotfun) - instagram.com/saidotfun
* 🎵 [TikTok](https://www.tiktok.com/@saidotfun) - @saidotfun
* ▶️ [YouTube](https://www.youtube.com/@saidotfun) - @saidotfun

**Additional Resources:**

* [Contract Addresses](/docs/dev/sai-core/contracts/) - Quick reference for all deployed contracts
* [GraphQL Playground](https://sai-keeper.nibiru.fi/) - Test queries interactively

***

**Ready to build?** Start with the [EVM Integration Guide](/docs/dev/evm-guide/) or [WASM Integration Guide](/docs/dev/wasm-guide/) based on your development stack.
