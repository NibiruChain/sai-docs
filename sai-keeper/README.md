---
icon: fire
cover: .gitbook/assets/sai-twitter-banner-1500x500.jpg
description: >-
  Sai Keeper is a GraphQL API that indexes Sai Protocol's on-chain data,
  enabling developers to query trades, liquidity pools, prices, and fees
  without directly accessing the blockchain.
---

# Introduction to Sai Keeper

Sai Keeper is a GraphQL API that provides real-time and historical data for the Sai protocol on Nibiru Chain. It enables developers to query perpetual trades, liquidity pool data, oracle prices, and fee analytics.

## What is Sai Keeper?

Sai Keeper is the data indexing and query layer for Sai Protocol. It processes on-chain events and makes them accessible through a fast, flexible GraphQL API.

**Key capabilities:**

- Query perpetual trading positions and history
- Access liquidity pool data and APY metrics
- Retrieve oracle price feeds
- Analyze fee structures and protocol revenue
- Subscribe to real-time updates via WebSockets

## Environments

### Testnet

- **GraphQL Endpoint**: `https://sai-keeper.testnet-2.nibiru.fi/graphql`
- **Interactive Playground**: `https://sai-keeper.testnet-2.nibiru.fi/`
- **Purpose**: Development and testing with test data
- Use for development and testing

### Mainnet

- **GraphQL Endpoint**: `https://sai-keeper.nibiru.fi/graphql`
- **Interactive Playground**: `https://sai-keeper.nibiru.fi/`
- **Purpose**: Production applications with real data
- Use for production applications

### Interactive User Interface

Both Testnet and Mainnet endpoints provide an **interactive GraphQL Playground** where you can:

- **Test all queries** with live data
- **Test subscriptions** with real-time updates
- **Explore the schema** with built-in documentation
- **View query history** and save queries
- **Debug responses** with formatted JSON

Simply visit the endpoint URLs in your browser to access the playground!

## Quick Start

### 1. Explore the API

Visit the GraphQL Playground to explore the schema interactively:

- **Testnet**: <https://sai-keeper.testnet-2.nibiru.fi/>
- **Mainnet**: <https://sai-keeper.nibiru.fi/>

### 2. Make Your First Query

Try this simple query in the playground:

```graphql
query GetTokenPrices {
  oracle {
    tokenPricesUsd(limit: 5) {
      token {
        symbol
        name
      }
      priceUsd
      lastUpdatedBlock {
        block
        block_ts
      }
    }
  }
}
```

### 3. Set Up Your Client

Install a GraphQL client library:

**JavaScript/TypeScript:**

```bash
npm install @apollo/client graphql
# or
npm install urql graphql
```

**Python:**

```bash
pip install gql[all]
```

**Rust:**

```toml
[dependencies]
graphql_client = "0.13"
```

## Core Data Domains

Sai Keeper organizes data into four main domains:

### 1. Perp (Perpetuals)

Query and subscribe to perpetual trading data:

- Open and closed positions
- Trade history and events
- Market borrowing rates

### 2. LP (Liquidity Pools)

Access liquidity provider information:

- Vault metrics (TVL, APY, share price)
- User deposits and shares
- Withdrawal requests
- Revenue tracking

### 3. Oracle

Get token price data:

- Real-time token prices in USD
- Token metadata
- Price update timestamps

### 4. Fee

Analyze fee data:

- Transaction-level fees
- Daily fee statistics
- Protocol and trader fee summaries
- Fee type breakdowns (opening/closing)

## GraphQL Basics

If you're new to GraphQL, here are the essentials:

### Queries

Request specific data:

```graphql
query {
  perp {
    trades(where: { trader: "nibi1abc..." }, limit: 10) {
      id
      isOpen
      leverage
    }
  }
}
```

### Subscriptions

Get real-time updates:

```graphql
subscription {
  perpTrades(where: { trader: "nibi1abc..." }) {
    id
    isOpen
    leverage
  }
}
```

### Variables

Parameterize your queries:

```graphql
query GetTrades($trader: String!, $limit: Int) {
  perp {
    trades(where: { trader: $trader }, limit: $limit) {
      id
    }
  }
}
```

Variables:

```json
{
  "trader": "nibi1abc...",
  "limit": 10
}
```

## Architecture Overview

```text
┌─────────────────┐
│   Your App      │
│  (Frontend/     │
│   Backend)      │
└────────┬────────┘
         │
         │ GraphQL
         │ Query/Subscribe
         │
┌────────▼────────┐
│  Sai Keeper     │
│  GraphQL API    │
└────────┬────────┘
         │
         │ Indexes
         │
┌────────▼────────┐
│  Nibiru Chain   │
│  (Blockchain)   │
└─────────────────┘
```

Sai Keeper indexes blockchain data and provides it through a fast, queryable GraphQL interface. This means you don't need to query the blockchain directly or maintain your own indexer.

## What You Can Build

- **Trading Platforms**: Full-featured perpetual trading interfaces
- **Portfolio Trackers**: Monitor positions, PnL, and performance
- **Analytics Dashboards**: Visualize protocol metrics and user activity
- **Automated Bots**: Build trading algorithms with real-time data
- **LP Management Tools**: Optimize liquidity provision strategies
- **Price Oracles**: Integrate reliable price feeds into your dApps

## Next Steps

- **New to GraphQL?** → Read [Core Concepts](./core-concepts.md)
- **Ready to code?** → Check out [Client Setup](./client-setup.md)
- **Want examples?** → See [Query Examples](./examples-queries.md)
- **Need API details?** → Browse the API references:
  - [Perp API](./api-perp.md)
  - [LP API](./api-lp.md)
  - [Oracle API](./api-oracle.md)
  - [Fee API](./api-fees.md)
