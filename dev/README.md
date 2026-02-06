---
description: Build on Sai with comprehensive technical documentation, API references, and integration guides.
cover: ../../.gitbook/assets/sai-twitter-banner-1500x500.jpg
icon: code
---

# Getting Started

Build powerful applications on top of Sai's perpetual futures protocol. Whether you're creating trading bots, analytics dashboards, or custom integrations, this documentation will guide you through the process.

## Quick Start

Choose your integration path based on your development environment:

<table data-view="cards">
  <thead>
    <tr>
      <th></th>
      <th></th>
      <th data-hidden data-card-target data-type="content-ref"></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>EVM Integration Guide</strong></td>
      <td>Start here if you're building on EVM chains. Covers environment setup, contract connections, and basic operations like opening positions and managing collateral</td>
      <td><a href="evm-guide.md">evm-guide.md</a></td>
    </tr>
    <tr>
      <td><strong>WASM Integration Guide</strong></td>
      <td>For WASM-based chains and clients. Learn integration patterns with language-specific examples and deployment guidance</td>
      <td><a href="wasm-guide.md">wasm-guide.md</a></td>
    </tr>
  </tbody>
</table>

---

## Sai Core

Comprehensive documentation of the Sai smart contracts, modules, and architecture.

### Core Modules

<table data-view="cards">
  <thead>
    <tr>
      <th></th>
      <th></th>
      <th data-hidden data-card-target data-type="content-ref"></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Perp Contract</strong></td>
      <td>Main perpetual futures contract handling position management, collateral, and settlement</td>
      <td><a href="sai-core/perp-contract.md">perp-contract.md</a></td>
    </tr>
    <tr>
      <td><strong>Borrowing Module</strong></td>
      <td>Borrowed funds management, interest rates, and liquidation mechanics</td>
      <td><a href="sai-core/perp-borrowing.md">perp-borrowing.md</a></td>
    </tr>
    <tr>
      <td><strong>Price Impact Module</strong></td>
      <td>How large trades affect pricing, slippage calculation, and execution costs</td>
      <td><a href="sai-core/perp-price-impact.md">perp-price-impact.md</a></td>
    </tr>
  </tbody>
</table>

### Reference Documentation

<table data-view="cards">
  <thead>
    <tr>
      <th></th>
      <th></th>
      <th data-hidden data-card-target data-type="content-ref"></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>State Variables</strong></td>
      <td>Complete reference of all smart contract state variables and their purposes</td>
      <td><a href="sai-core/perp-state.md">perp-state.md</a></td>
    </tr>
    <tr>
      <td><strong>Contract Addresses Reference</strong></td>
      <td>Mainnet and testnet deployment addresses for all Sai contracts</td>
      <td><a href="sai-core/contracts.md">contracts.md</a></td>
    </tr>
    <tr>
      <td><strong>WASM & EVM Integration</strong></td>
      <td>Platform-specific details for direct smart contract integration</td>
      <td><a href="sai-core/contract-integration.md">contract-integration.md</a></td>
    </tr>
  </tbody>
</table>

---

## Sai Keeper

Query and subscribe to real-time data from the Sai protocol. Perfect for dashboards, bots, and analytics tools.

### Getting Started

<table data-view="cards">
  <thead>
    <tr>
      <th></th>
      <th></th>
      <th data-hidden data-card-target data-type="content-ref"></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Core Concepts</strong></td>
      <td>Understand indexing, subscriptions, and how Keeper structures protocol data</td>
      <td><a href="sai-keeper/core-concepts.md">core-concepts.md</a></td>
    </tr>
    <tr>
      <td><strong>Client Setup</strong></td>
      <td>Get your GraphQL client configured and authenticated in minutes</td>
      <td><a href="sai-keeper/client-setup.md">client-setup.md</a></td>
    </tr>
  </tbody>
</table>

### API Reference

<table data-view="cards">
  <thead>
    <tr>
      <th></th>
      <th></th>
      <th data-hidden data-card-target data-type="content-ref"></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Perp API</strong></td>
      <td>Query positions, orders, trades, and perpetual-specific data</td>
      <td><a href="sai-keeper/api-perp.md">api-perp.md</a></td>
    </tr>
    <tr>
      <td><strong>Liquidity Provider (LP) API</strong></td>
      <td>Access liquidity pool data, provider positions, and performance metrics</td>
      <td><a href="sai-keeper/api-lp.md">api-lp.md</a></td>
    </tr>
    <tr>
      <td><strong>Oracle API</strong></td>
      <td>Get price feeds and oracle data used throughout the protocol</td>
      <td><a href="sai-keeper/api-oracle.md">api-oracle.md</a></td>
    </tr>
    <tr>
      <td><strong>Fees API</strong></td>
      <td>Query fee structures, accruals, and historical fee data</td>
      <td><a href="sai-keeper/api-fees.md">api-fees.md</a></td>
    </tr>
  </tbody>
</table>

### Examples & Advanced Usage

<table data-view="cards">
  <thead>
    <tr>
      <th></th>
      <th></th>
      <th data-hidden data-card-target data-type="content-ref"></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Examples: Queries</strong></td>
      <td>Copy-paste ready GraphQL queries for common use cases</td>
      <td><a href="sai-keeper/examples-queries.md">examples-queries.md</a></td>
    </tr>
    <tr>
      <td><strong>Examples: Subscriptions</strong></td>
      <td>See how to subscribe to real-time updates and build event-driven applications</td>
      <td><a href="sai-keeper/examples-subscriptions.md">examples-subscriptions.md</a></td>
    </tr>
    <tr>
      <td><strong>Filters & Pagination</strong></td>
      <td>Master filtering, sorting, and pagination for efficient large-scale data retrieval</td>
      <td><a href="sai-keeper/filters-pagination.md">filters-pagination.md</a></td>
    </tr>
  </tbody>
</table>

---

## Use Cases

Practical integration examples and real-world applications built on Sai.

<table data-view="cards">
  <thead>
    <tr>
      <th></th>
      <th></th>
      <th data-hidden data-card-target data-type="content-ref"></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Telegram Bot Integration</strong></td>
      <td>Build a Telegram trading bot with position monitoring, alerts, and order execution</td>
      <td><a href="use-cases/tg-guide.md">tg-guide.md</a></td>
    </tr>
  </tbody>
</table>

---

## Developer Resources

**Need help or want to connect with other builders?**

- 🐦 [X / Twitter](https://x.com/SaiDotFun) - @SaiDotFun
- 📢 [Telegram News Channel](https://t.me/saidotfun) - t.me/saidotfun

**Additional Resources:**

- [Contract Addresses](sai-core/contracts.md) - Quick reference for all deployed contracts
- [GraphQL Playground](https://sai-keeper.nibiru.fi/) - Test queries interactively

---

{% hint style="success" %}
**Ready to build?** Start with the [EVM Integration Guide](evm-guide.md) or [WASM Integration Guide](wasm-guide.md) based on your development stack.
{% endhint %}
