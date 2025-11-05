# Perp API Reference

Query and subscribe to perpetual trading data including positions, trade history, market borrowing rates, and referrals.

## Table of Contents

- [Perp API Reference](#perp-api-reference)
  - [Table of Contents](#table-of-contents)
  - [Queries](#queries)
    - [trade](#trade)
    - [trades](#trades)
    - [tradeHistory](#tradehistory)
    - [borrowing](#borrowing)
    - [borrowings](#borrowings)
  - [Subscriptions](#subscriptions)
    - [perpTrades](#perptrades)
    - [perpTradeHistory](#perptradehistory)
    - [perpBorrowing](#perpborrowing)
    - [perpBorrowings](#perpborrowings)
  - [Types Reference](#types-reference)
    - [PerpTrade](#perptrade)
    - [PerpTradeState](#perptradestate)
    - [PerpBorrowing](#perpborrowing-1)
    - [Enums](#enums)

## Queries

### trade

Get a specific trade by ID and trader address.

**Signature:**

```graphql
trade(id: Int!, trader: String!): PerpTrade
```

**Parameters:**

- `id`: Trade ID (integer)
- `trader`: Trader's wallet address (required)

**Returns:** `PerpTrade` object or null if not found

**Example:**

```graphql
query GetTrade {
  perp {
    trade(id: 42, trader: "nibi1abc...") {
      id
      isOpen
      isLong
      leverage
      collateralAmount
      openPrice
      closePrice
      perpBorrowing {
        baseToken { symbol }
        collateralToken { symbol }
        marketId
      }
      openBlock {
        block
        block_ts
      }
      closeBlock {
        block
        block_ts
      }
      state {
        pnlCollateral
        pnlPct
        liquidationPrice
        positionValue
      }
    }
  }
}
```

**Use Cases:**

- Display single trade details
- Track specific position status
- Calculate current PnL

---

### trades

List trades with filtering, pagination, and ordering.

**Signature:**

```graphql
trades(
  where: PerpTradesFilter!
  limit: Int
  offset: Int
  order_by: PerpTradesOrder
  order_desc: Boolean
): [PerpTrade!]!
```

**Parameters:**

- `where`: Filter object (required)
  - `trader`: Trader address (required)
  - `isOpen`: Filter by open/closed status
  - `perpMarketId`: Filter by market ID
  - `perpCollateralId`: Filter by collateral token ID
- `limit`: Max results (default: 100)
- `offset`: Skip results for pagination
- `order_by`: Sort field (`sequence` only)
- `order_desc`: Sort descending (default: false)

**Returns:** Array of `PerpTrade` objects

**Example - Get Open Positions:**

```graphql
query GetOpenPositions($trader: String!) {
  perp {
    trades(
      where: {
        trader: $trader
        isOpen: true
      }
      limit: 50
      order_desc: true
    ) {
      id
      isLong
      leverage
      collateralAmount
      openPrice
      perpBorrowing {
        baseToken { symbol }
        marketId
      }
      state {
        pnlCollateral
        pnlPct
        liquidationPrice
      }
    }
  }
}
```

**Example - Filter by Market:**

```graphql
query GetBTCTrades($trader: String!) {
  perp {
    trades(
      where: {
        trader: $trader
        perpMarketId: 1  # BTC market
      }
      limit: 20
    ) {
      id
      isOpen
      openPrice
      closePrice
    }
  }
}
```

**Use Cases:**

- List user's open positions
- Display trading history
- Filter by specific markets
- Build position dashboard

---

### tradeHistory

Get trade events and position changes.

**Signature:**

```graphql
tradeHistory(
  where: PerpTradeHistoryFilter!
  limit: Int
  offset: Int
  order_by: PerpTradeHistoryOrder
  order_desc: Boolean
): [PerpTradeHistoryItem!]!
```

**Parameters:**

- `where`: Filter object (required)
  - `trader`: Trader address (required)
- `limit`: Max results (default: 100)
- `offset`: Skip results
- `order_by`: Sort by `sequence` or `trade_id`
- `order_desc`: Sort descending

**Returns:** Array of `PerpTradeHistoryItem` objects

**Trade Change Types:**

- `position_opened`: New position created
- `position_closed_user`: User closed position
- `position_closed_sl`: Stop loss triggered
- `position_closed_tp`: Take profit triggered
- `position_liquidated`: Position liquidated
- `sl_updated`: Stop loss updated
- `tp_updated`: Take profit updated
- `limit_order_created`: Limit order placed
- `stop_order_created`: Stop order placed
- `order_triggered`: Order executed
- `order_closed_user`: Order cancelled

**Example:**

```graphql
query GetTradeHistory($trader: String!) {
  perp {
    tradeHistory(
      where: { trader: $trader }
      limit: 50
      order_by: sequence
      order_desc: true
    ) {
      id
      tradeChangeType
      block {
        block
        block_ts
      }
      trade {
        id
        isLong
        leverage
      }
      realizedPnlCollateral
      realizedPnlPct
    }
  }
}
```

**Use Cases:**

- Build activity feed
- Track position modifications
- Calculate realized PnL history
- Audit trade actions

---

### borrowing

Get detailed borrowing information for a specific market and collateral.

**Signature:**

```graphql
borrowing(collateralId: Int!, marketId: Int!): PerpBorrowing
```

**Parameters:**

- `collateralId`: Collateral token ID
- `marketId`: Market ID

**Returns:** `PerpBorrowing` object or null

**Example:**

```graphql
query GetMarketInfo {
  perp {
    borrowing(collateralId: 1, marketId: 1) {
      marketId
      baseToken { symbol name }
      quoteToken { symbol }
      collateralToken { symbol }
      price
      oiLong
      oiShort
      oiMax
      feesPerHourLong
      feesPerHourShort
      openFeePct
      closeFeePct
      triggerOrderFeePct
      maxLeverage
      minLeverage
      minPositionSizeUSD
      visible
    }
  }
}
```

**Key Fields Explained:**

- `oiLong` / `oiShort`: Open interest for longs/shorts
- `oiMax`: Maximum allowed open interest
- `feesPerHourLong` / `feesPerHourShort`: Borrowing rate (per hour)
- `openFeePct` / `closeFeePct`: Opening/closing fee percentages
- `maxLeverage` / `minLeverage`: Leverage limits
- `minPositionSizeUSD`: Minimum position size in USD

**Use Cases:**

- Display market information
- Calculate funding rates
- Show available leverage
- Check market capacity (OI limits)

---

### borrowings

List all available markets with basic information.

**Signature:**

```graphql
borrowings(
  where: PerpBorrowingsFilter
  limit: Int
  offset: Int
  order_by: PerpBorrowingsOrder
  order_desc: Boolean
): [PerpBorrowingShortInfo!]!
```

**Parameters:**

- `where`: Filter object (optional)
  - `marketId`: Filter by market ID
  - `collateralId`: Filter by collateral ID
- `limit`: Max results
- `offset`: Skip results
- `order_by`: Sort by `base_token_name`
- `order_desc`: Sort descending

**Returns:** Array of `PerpBorrowingShortInfo` objects

**Example:**

```graphql
query ListMarkets {
  perp {
    borrowings(
      order_by: base_token_name
      limit: 20
    ) {
      marketId
      baseToken { symbol name logoUrl }
      quoteToken { symbol }
      collateralToken { symbol }
      visible
    }
  }
}
```

**Use Cases:**

- List all tradeable markets
- Build market selector
- Filter visible markets

---

## Subscriptions

Subscribe to real-time updates for perpetual trading data.

### perpTrades

Subscribe to trade updates for a specific trader.

**Signature:**

```graphql
subscription {
  perpTrades(where: SubPerpTradesFilter!): [PerpTrade!]!
}
```

**Example:**

```graphql
subscription WatchTrades($trader: String!) {
  perpTrades(where: { trader: $trader }) {
    id
    isOpen
    leverage
    state {
      pnlCollateral
      pnlPct
    }
  }
}
```

---

### perpTradeHistory

Subscribe to trade events for a specific trader.

**Signature:**

```graphql
subscription {
  perpTradeHistory(where: SubPerpTradeHistoryFilter!): [PerpTradeHistoryItem!]!
}
```

**Example:**

```graphql
subscription WatchTradeEvents($trader: String!) {
  perpTradeHistory(where: { trader: $trader }) {
    id
    tradeChangeType
    realizedPnlCollateral
    block { block_ts }
  }
}
```

---

### perpBorrowing

Subscribe to borrowing rate updates for a specific market.

**Signature:**

```graphql
subscription {
  perpBorrowing(collateralId: Int!, marketId: Int!): PerpBorrowing
}
```

**Example:**

```graphql
subscription WatchMarket($collateralId: Int!, $marketId: Int!) {
  perpBorrowing(collateralId: $collateralId, marketId: $marketId) {
    price
    oiLong
    oiShort
    feesPerHourLong
    feesPerHourShort
  }
}
```

---

### perpBorrowings

Subscribe to updates for all markets.

**Signature:**

```graphql
subscription {
  perpBorrowings: [PerpBorrowingShortInfo!]!
}
```

**Example:**

```graphql
subscription WatchAllMarkets {
  perpBorrowings {
    marketId
    baseToken { symbol }
    visible
  }
}
```

---

## Types Reference

### PerpTrade

```graphql
type PerpTrade {
  id: Int!
  trader: String!
  isOpen: Boolean!
  isLong: Boolean!
  tradeType: PerpTradeType!
  leverage: Float!
  collateralAmount: Int!
  openCollateralAmount: Int!
  openPrice: Float!
  closePrice: Float
  sl: Float                      # Stop loss price
  tp: Float                      # Take profit price
  perpBorrowing: PerpBorrowingShortInfo!
  openBlock: Block
  closeBlock: Block
  state: PerpTradeState
}
```

### PerpTradeState

Real-time position state with PnL and fees.

```graphql
type PerpTradeState {
  pnlCollateral: Float!
  pnlPct: Float!
  pnlCollateralAfterFees: Float!
  positionValue: Float!
  liquidationPrice: Float!
  borrowingFeeCollateral: Float!
  borrowingFeePct: Float!
  closingFeeCollateral: Float!
  closingFeePct: Float!
  remainingCollateralAfterFees: Float!
}
```

### PerpBorrowing

Complete market information.

```graphql
type PerpBorrowing {
  marketId: Int!
  baseToken: Token!
  quoteToken: Token!
  collateralToken: Token!
  price: Float!
  oiLong: Int!
  oiShort: Int!
  oiMax: Int!
  feesPerHourLong: Float!
  feesPerHourShort: Float!
  openFeePct: Float!
  closeFeePct: Float!
  triggerOrderFeePct: Float!
  maxLeverage: Float!
  minLeverage: Float!
  minPositionSizeUSD: Int!
  visible: Boolean!
}
```

### Enums

**PerpTradeType:**

- `trade`: Market trade
- `limit`: Limit order
- `stop`: Stop order

**PerpTradeChangeType:**

- `position_opened`
- `position_closed_user`
- `position_closed_sl`
- `position_closed_tp`
- `position_liquidated`
- `sl_updated`
- `tp_updated`
- `limit_order_created`
- `stop_order_created`
- `order_triggered`
- `order_closed_user`

---
