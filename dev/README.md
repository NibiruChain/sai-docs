# Quick Start

Choose your integration path:
{% content-ref url="evm-guide.md" %}
[EVM Integration Guide](__evm-guide.md__)
{% endcontent-ref %}
Start here if you're building on EVM chains. This guide covers setting up your environment, connecting to Sai contracts, and executing basic operations like opening positions and managing collateral.

{% content-ref url="wasm-guide.md" %}
[WASM Integration Guide](__wasm-guide.md__)
{% endcontent-ref %}
For developers working with WASM-based chains or clients. Learn how to integrate Sai into your WASM applications with language-specific examples and deployment patterns.

## Sai Core

Comprehensive documentation of the Sai smart contracts, modules, and architecture. Start here if you need to understand the protocol's internal mechanics or are building custom integrations.

### Core Modules

Dive into the key functional components of Sai:

{% content-ref url="sai-core/perp-contract.md" %}
[Perp Contract](__sai-core/____perp-contract.md__)
{% endcontent-ref %}
The main perpetual futures contract handling position management, collateral, and settlement.

{% content-ref url="sai-core/perp-borrowing.md" %}
[Borrowing Module](__sai-core/____perp-borrowing.md__)
{% endcontent-ref %}
Understand how Sai manages borrowed funds, interest rates, and liquidation mechanics.

{% content-ref url="sai-core/perp-price-impact.md" %}
[Price Impact Module](__sai-core/____perp-price-impact.md__)
{% endcontent-ref %}
Learn how large trades affect pricing and how the protocol calculates slippage and execution costs.

### Reference

Quick lookup for deployment info and integration details:

{% content-ref url="sai-core/perp-state.md" %}
[State Variables](__sai-core/____perp-state.md__)
{% endcontent-ref %}
A complete reference of all smart contract state variables and their purposes.

{% content-ref url="sai-core/contracts.md" %}
[Contract Addresses Reference](__sai-core/____contracts.md__)
{% endcontent-ref %}
Mainnet and testnet contract addresses for all Sai deployments.

{% content-ref url="sai-core/contract-integration.md" %}
[WASM & EVM Integration](__sai-core/____contract-integration.md__)
{% endcontent-ref %}
Platform-specific details for integrating directly with Sai smart contracts.

## Sai Keeper

Query and subscribe to real-time data from the Sai protocol with the Keeper API. Perfect for building dashboards, bots, and analytics tools without managing blockchain data yourself.

### Getting Started

Set up and learn the fundamentals:

{% content-ref url="sai-keeper/core-concepts.md" %}
[Core Concepts](__sai-keeper/____core-concepts.md__)
{% endcontent-ref %}
Understand indexing, subscriptions, and how the Keeper API structures protocol data.

{% content-ref url="sai-keeper/client-setup.md" %}
[Client Setup](__sai-keeper/____client-setup.md__)
{% endcontent-ref %}
Get your GraphQL client configured and authenticated in minutes.

### API Reference

Explore what data you can query:

{% content-ref url="sai-keeper/api-perp.md" %}
[Perp API](__sai-keeper/____api-perp.md__)
{% endcontent-ref %}
Query positions, orders, trades, and perpetual-specific data.

{% content-ref url="sai-keeper/api-lp.md" %}
[Liquidity Provider (LP) API](__sai-keeper/____api-lp.md__)
{% endcontent-ref %}
Access liquidity pool data, provider positions, and performance metrics.

{% content-ref url="sai-keeper/api-oracle.md" %}
[Oracle API](__sai-keeper/____api-oracle.md__)
{% endcontent-ref %}
Get price feeds and oracle data used throughout the protocol.

{% content-ref url="sai-keeper/api-fees.md" %}
[Fees API](__sai-keeper/____api-fees.md__)
{% endcontent-ref %}
Query fee structures, accruals, and historical fee data.

### Examples

Learn by doing:

{% content-ref url="sai-keeper/examples-queries.md" %}
[Examples: Queries](__sai-keeper/____examples-queries.md__)
{% endcontent-ref %}
Copy-paste ready GraphQL queries for common use cases.

{% content-ref url="sai-keeper/examples-subscriptions.md" %}
[Examples: Subscriptions](__sai-keeper/____examples-subscriptions.md__)
{% endcontent-ref %}
See how to subscribe to real-time updates and build event-driven applications.

### Advanced

Go deeper with powerful features:

{% content-ref url="sai-keeper/filters-pagination.md" %}
[Filters & Pagination](__sai-keeper/____filters-pagination.md__)
{% endcontent-ref %}
Master filtering, sorting, and pagination for efficient large-scale data retrieval.
