# Quick Start

Choose your integration path:

{% content-ref url="evm-guide.md" %}
[EVM Integration Guide](__evm-guide.md__)
{% endcontent-ref %}
{% hint style="info" %}
Start here if you're building on EVM chains. Covers environment setup, contract connections, and basic operations like opening positions and managing collateral.
{% endhint %}

{% content-ref url="wasm-guide.md" %}
[WASM Integration Guide](__wasm-guide.md__)
{% endcontent-ref %}
{% hint style="info" %}
For WASM-based chains and clients. Learn integration patterns with language-specific examples and deployment guidance.
{% endhint %}

## Sai Core

Comprehensive documentation of the Sai smart contracts, modules, and architecture.

### Core Modules

{% content-ref url="sai-core/perp-contract.md" %}
[Perp Contract](__sai-core/____perp-contract.md__)
{% endcontent-ref %}
{% hint style="info" %}
Main perpetual futures contract handling position management, collateral, and settlement.
{% endhint %}

{% content-ref url="sai-core/perp-borrowing.md" %}
[Borrowing Module](__sai-core/____perp-borrowing.md__)
{% endcontent-ref %}
{% hint style="info" %}
Borrowed funds management, interest rates, and liquidation mechanics.
{% endhint %}

{% content-ref url="sai-core/perp-price-impact.md" %}
[Price Impact Module](__sai-core/____perp-price-impact.md__)
{% endcontent-ref %}
{% hint style="info" %}
How large trades affect pricing, slippage calculation, and execution costs.
{% endhint %}

### Reference

{% content-ref url="sai-core/perp-state.md" %}
[State Variables](__sai-core/____perp-state.md__)
{% endcontent-ref %}
{% hint style="info" %}
Complete reference of all smart contract state variables and their purposes.
{% endhint %}

{% content-ref url="sai-core/contracts.md" %}
[Contract Addresses Reference](__sai-core/____contracts.md__)
{% endcontent-ref %}
{% hint style="info" %}
Mainnet and testnet deployment addresses for all Sai contracts.
{% endhint %}

{% content-ref url="sai-core/contract-integration.md" %}
[WASM & EVM Integration](__sai-core/____contract-integration.md__)
{% endcontent-ref %}
{% hint style="info" %}
Platform-specific details for direct smart contract integration.
{% endhint %}

## Sai Keeper

Query and subscribe to real-time data from the Sai protocol. Perfect for dashboards, bots, and analytics tools.

### Getting Started

{% content-ref url="sai-keeper/core-concepts.md" %}
[Core Concepts](__sai-keeper/____core-concepts.md__)
{% endcontent-ref %}
{% hint style="info" %}
Understand indexing, subscriptions, and how Keeper structures protocol data.
{% endhint %}

{% content-ref url="sai-keeper/client-setup.md" %}
[Client Setup](__sai-keeper/____client-setup.md__)
{% endcontent-ref %}
{% hint style="info" %}
Get your GraphQL client configured and authenticated in minutes.
{% endhint %}

### API Reference

{% content-ref url="sai-keeper/api-perp.md" %}
[Perp API](__sai-keeper/____api-perp.md__)
{% endcontent-ref %}
{% hint style="info" %}
Query positions, orders, trades, and perpetual-specific data.
{% endhint %}

{% content-ref url="sai-keeper/api-lp.md" %}
[Liquidity Provider (LP) API](__sai-keeper/____api-lp.md__)
{% endcontent-ref %}
{% hint style="info" %}
Access liquidity pool data, provider positions, and performance metrics.
{% endhint %}

{% content-ref url="sai-keeper/api-oracle.md" %}
[Oracle API](__sai-keeper/____api-oracle.md__)
{% endcontent-ref %}
{% hint style="info" %}
Get price feeds and oracle data used throughout the protocol.
{% endhint %}

{% content-ref url="sai-keeper/api-fees.md" %}
[Fees API](__sai-keeper/____api-fees.md__)
{% endcontent-ref %}
{% hint style="info" %}
Query fee structures, accruals, and historical fee data.
{% endhint %}

### Examples

{% content-ref url="sai-keeper/examples-queries.md" %}
[Examples: Queries](__sai-keeper/____examples-queries.md__)
{% endcontent-ref %}
{% hint style="info" %}
Copy-paste ready GraphQL queries for common use cases.
{% endhint %}

{% content-ref url="sai-keeper/examples-subscriptions.md" %}
[Examples: Subscriptions](__sai-keeper/____examples-subscriptions.md__)
{% endcontent-ref %}
{% hint style="info" %}
See how to subscribe to real-time updates and build event-driven applications.
{% endhint %}

### Advanced

{% content-ref url="sai-keeper/filters-pagination.md" %}
[Filters & Pagination](__sai-keeper/____filters-pagination.md__)
{% endcontent-ref %}
{% hint style="info" %}
Master filtering, sorting, and pagination for efficient large-scale data retrieval.
{% endhint %}
