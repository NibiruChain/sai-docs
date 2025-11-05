# Fee API Reference

Query fee data including transaction-level fees, daily statistics, and protocol/trader summaries.

## Table of Contents

- [Queries](#queries)
  - [feeTransaction](#feetransaction)
  - [feeTransactions](#feetransactions)
  - [feeDailyStats](#feedailystats)
  - [feeAnalytics](#feeanalytics)
  - [protocolFeeSummary](#protocolfeesummary)
  - [traderFeeSummary](#traderfeesummary)
- [Types Reference](#types-reference)

## Queries

### feeTransaction

Get a specific fee transaction by ID.

**Signature:**

```graphql
feeTransaction(id: ID!): FeeTransaction
```

**Parameters:**

- `id`: Transaction ID (string)

**Returns:** `FeeTransaction` object or null

**Example:**

```graphql
query GetFeeTransaction {
  fee {
    feeTransaction(id: "abc123") {
      id
      traderAddress
      feeType
      totalFeeCharged
      govFee
      vaultFee
      referrerAllocation
      triggerFee
      collateralDenom
      blockHeight
      blockTime
    }
  }
}
```

---

### feeTransactions

List fee transactions with filtering and pagination.

**Signature:**

```graphql
feeTransactions(
  filter: FeeTransactionFilter
  limit: Int = 100
  offset: Int = 0
): [FeeTransaction!]!
```

**Parameters:**

- `filter`: Filter object (optional)
  - `traderAddress`: Filter by trader
  - `collateralDenom`: Filter by collateral token
  - `feeType`: Filter by `OPENING` or `CLOSING`
  - `fromDate`: Start date (RFC3339)
  - `toDate`: End date (RFC3339)
  - `minAmount`: Minimum fee amount
  - `maxAmount`: Maximum fee amount
- `limit`: Max results (default: 100)
- `offset`: Skip results (default: 0)

**Returns:** Array of `FeeTransaction` objects

**Example - Get User Fees:**

```graphql
query GetUserFees($trader: String!) {
  fee {
    feeTransactions(
      filter: { traderAddress: $trader }
      limit: 50
    ) {
      id
      feeType
      totalFeeCharged
      govFee
      vaultFee
      referrerAllocation
      triggerFee
      blockTime
      tradeId
      orderType
    }
  }
}
```

**Example - Filter by Date Range:**

```graphql
query GetFeesInRange {
  fee {
    feeTransactions(
      filter: {
        fromDate: "2024-01-01T00:00:00Z"
        toDate: "2024-01-31T23:59:59Z"
        feeType: OPENING
      }
      limit: 100
    ) {
      id
      traderAddress
      totalFeeCharged
      blockTime
    }
  }
}
```

**Example - Large Fees Only:**

```graphql
query GetLargeFees {
  fee {
    feeTransactions(
      filter: {
        minAmount: 1000000  # Filter fees > 1,000,000
      }
      limit: 20
    ) {
      id
      traderAddress
      totalFeeCharged
      feeType
    }
  }
}
```

**Use Cases:**

- User fee history
- Protocol fee monitoring
- Large transaction tracking
- Fee analysis by period

---

### feeDailyStats

Get aggregated daily fee statistics.

**Signature:**

```graphql
feeDailyStats(
  filter: FeeDailyStatsFilter
  limit: Int = 30
  offset: Int = 0
): [FeeDailyStats!]!
```

**Parameters:**

- `filter`: Filter object (optional)
  - `traderAddress`: Filter by specific trader
  - `collateralDenom`: Filter by collateral token
  - `fromDate`: Start date
  - `toDate`: End date
  - `protocolWide`: If true, get protocol-wide stats
- `limit`: Max results (default: 30)
- `offset`: Skip results (default: 0)

**Returns:** Array of `FeeDailyStats` objects

**Example - Protocol Daily Stats:**

```graphql
query GetProtocolDailyStats {
  fee {
    feeDailyStats(
      filter: { protocolWide: true }
      limit: 30
    ) {
      date
      collateralDenom
      openingFeeCount
      openingFeeTotal
      openingGovFee
      openingReferrerFee
      openingVaultFee
      closingFeeCount
      closingFeeTotal
      closingGovFee
      closingReferrerFee
      closingVaultFee
      closingTriggerFee
      totalBadDebt
      updatedAt
    }
  }
}
```

**Example - Trader Daily Stats:**

```graphql
query GetTraderDailyStats($trader: String!) {
  fee {
    feeDailyStats(
      filter: {
        traderAddress: $trader
        fromDate: "2024-01-01T00:00:00Z"
      }
      limit: 90
    ) {
      date
      openingFeeTotal
      closingFeeTotal
      totalBadDebt
    }
  }
}
```

**Use Cases:**

- Daily fee charts
- Historical fee analysis
- Revenue tracking
- Trader fee breakdown

---

### feeAnalytics

Get enhanced fee analytics with additional metrics.

**Signature:**

```graphql
feeAnalytics(
  filter: FeeDailyStatsFilter
  limit: Int = 30
  offset: Int = 0
): [FeeAnalytics!]!
```

**Parameters:** Same as `feeDailyStats`

**Returns:** Array of `FeeAnalytics` objects

**Example:**

```graphql
query GetFeeAnalytics {
  fee {
    feeAnalytics(
      filter: { protocolWide: true }
      limit: 30
    ) {
      date
      collateralDenom
      openingCount
      openingTotal
      openingGov
      openingReferrer
      openingVault
      openingTrigger
      closingCount
      closingTotal
      closingGov
      closingReferrer
      closingVault
      closingTrigger
      totalFeesAll
      avgFeeMultiplier
      totalBadDebt
      traderAddress
    }
  }
}
```

**Key Differences from feeDailyStats:**

- Includes `avgFeeMultiplier`
- Includes `totalFeesAll` (sum of opening + closing)
- More granular trigger fee breakdown

**Use Cases:**

- Advanced analytics dashboards
- Fee multiplier tracking
- Comprehensive fee reports

---

### protocolFeeSummary

Get protocol-wide fee summary for a time period.

**Signature:**

```graphql
protocolFeeSummary(
  collateralDenom: String
  fromDate: Time
  toDate: Time
): ProtocolFeeSummary!
```

**Parameters:**

- `collateralDenom`: Optional collateral filter
- `fromDate`: Start date (optional)
- `toDate`: End date (optional)

**Returns:** `ProtocolFeeSummary` object

**Example - All-Time Protocol Summary:**

```graphql
query GetProtocolSummary {
  fee {
    protocolFeeSummary {
      period {
        fromDate
        toDate
      }
      totalFees
      totalOpeningFees
      totalClosingFees
      totalGovFees
      totalVaultFees
      totalReferrerFees
      totalTriggerFees
      totalBadDebt
      openingCount
      closingCount
      uniqueTraders
      avgFeeMultiplier
    }
  }
}
```

**Example - Monthly Summary:**

```graphql
query GetMonthlySummary {
  fee {
    protocolFeeSummary(
      fromDate: "2024-01-01T00:00:00Z"
      toDate: "2024-01-31T23:59:59Z"
    ) {
      totalFees
      totalOpeningFees
      totalClosingFees
      uniqueTraders
      openingCount
      closingCount
    }
  }
}
```

**Example - Per-Collateral Summary:**

```graphql
query GetCollateralSummary {
  fee {
    protocolFeeSummary(
      collateralDenom: "uusdc"
      fromDate: "2024-01-01T00:00:00Z"
    ) {
      totalFees
      totalVaultFees
      totalGovFees
      uniqueTraders
    }
  }
}
```

**Use Cases:**

- Protocol revenue reports
- KPI tracking
- Performance metrics
- Time-period comparisons

---

### traderFeeSummary

Get fee summary for a specific trader.

**Signature:**

```graphql
traderFeeSummary(
  traderAddress: String!
  collateralDenom: String
  fromDate: Time
  toDate: Time
): TraderFeeSummary!
```

**Parameters:**

- `traderAddress`: Trader's address (required)
- `collateralDenom`: Optional collateral filter
- `fromDate`: Start date (optional)
- `toDate`: End date (optional)

**Returns:** `TraderFeeSummary` object

**Example - All-Time Trader Summary:**

```graphql
query GetTraderSummary($trader: String!) {
  fee {
    traderFeeSummary(traderAddress: $trader) {
      traderAddress
      period {
        fromDate
        toDate
      }
      totalFees
      totalOpeningFees
      totalClosingFees
      totalReferrerAllocation
      totalBadDebt
      openingCount
      closingCount
      avgFeeMultiplier
    }
  }
}
```

**Example - Monthly Trader Summary:**

```graphql
query GetTraderMonthlySummary($trader: String!) {
  fee {
    traderFeeSummary(
      traderAddress: $trader
      fromDate: "2024-01-01T00:00:00Z"
      toDate: "2024-01-31T23:59:59Z"
    ) {
      totalFees
      openingCount
      closingCount
      avgFeeMultiplier
    }
  }
}
```

**Use Cases:**

- User dashboards
- Trading cost analysis
- Fee optimization insights
- Referral tracking

---

## Types Reference

### FeeTransaction

Complete fee transaction details.

```graphql
type FeeTransaction {
  id: ID!
  traderAddress: String!
  tradeId: Int!
  tradeIndex: Int!
  feeType: FeeType!
  collateralDenom: String!
  totalFeeCharged: Int!
  govFee: Int!
  netGovFee: Int!
  vaultFee: Int!
  referrerAllocation: Int!
  triggerFee: Int!
  openFeeComponent: Int
  triggerFeeComponent: Int
  triggererReward: Int
  collateralLeft: Int
  badDebt: Int!
  feeMultiplier: Float!
  orderType: String
  catalystAddress: String
  blockHeight: Int!
  blockTime: Time!
  createdAt: Time!
}
```

**Key Fields:**

- `totalFeeCharged`: Total fee paid by trader
- `govFee`: Fee to protocol governance
- `vaultFee`: Fee to LP vault
- `referrerAllocation`: Fee to referrer (if any)
- `triggerFee`: Fee paid to order trigger executor
- `badDebt`: Bad debt if position liquidated with insufficient collateral
- `feeMultiplier`: Dynamic fee multiplier applied

---

### FeeDailyStats

Daily aggregated fee statistics.

```graphql
type FeeDailyStats {
  date: Time!
  collateralDenom: String!
  traderAddress: String
  openingFeeCount: Int!
  openingFeeTotal: Int!
  openingGovFee: Int!
  openingReferrerFee: Int!
  openingTriggerFee: Int!
  openingVaultFee: Int!
  closingFeeCount: Int!
  closingFeeTotal: Int!
  closingGovFee: Int!
  closingReferrerFee: Int!
  closingTriggerFee: Int!
  closingVaultFee: Int!
  totalBadDebt: Int!
  updatedAt: Time!
}
```

---

### FeeAnalytics

Enhanced analytics with additional metrics.

```graphql
type FeeAnalytics {
  date: Time!
  collateralDenom: String!
  traderAddress: String
  openingCount: Int!
  openingTotal: Int!
  openingGov: Int!
  openingReferrer: Int!
  openingTrigger: Int!
  openingVault: Int!
  closingCount: Int!
  closingTotal: Int!
  closingGov: Int!
  closingReferrer: Int!
  closingTrigger: Int!
  closingVault: Int!
  totalFeesAll: Int!
  avgFeeMultiplier: Float!
  totalBadDebt: Int!
}
```

---

### ProtocolFeeSummary

Protocol-wide fee summary.

```graphql
type ProtocolFeeSummary {
  period: TimePeriod!
  totalFees: Int!
  totalOpeningFees: Int!
  totalClosingFees: Int!
  totalGovFees: Int!
  totalVaultFees: Int!
  totalReferrerFees: Int!
  totalTriggerFees: Int!
  totalBadDebt: Int!
  openingCount: Int!
  closingCount: Int!
  uniqueTraders: Int!
  avgFeeMultiplier: Float!
}
```

---

### TraderFeeSummary

Per-trader fee summary.

```graphql
type TraderFeeSummary {
  traderAddress: String!
  period: TimePeriod!
  totalFees: Int!
  totalOpeningFees: Int!
  totalClosingFees: Int!
  totalReferrerAllocation: Int!
  totalBadDebt: Int!
  openingCount: Int!
  closingCount: Int!
  avgFeeMultiplier: Float!
}
```

---

### Enums

**FeeType:**

- `OPENING`: Fees charged when opening positions
- `CLOSING`: Fees charged when closing positions

---

## Fee Calculations

### Total Protocol Revenue

```javascript
const totalRevenue = protocolFeeSummary.totalGovFees + 
                     protocolFeeSummary.totalVaultFees
```

### Average Fee Per Trade

```javascript
const avgOpeningFee = protocolFeeSummary.totalOpeningFees / 
                      protocolFeeSummary.openingCount

const avgClosingFee = protocolFeeSummary.totalClosingFees / 
                      protocolFeeSummary.closingCount
```

### Fee Breakdown Percentages

```javascript
const calculateBreakdown = (summary) => {
  const total = summary.totalFees
  return {
    govPct: (summary.totalGovFees / total) * 100,
    vaultPct: (summary.totalVaultFees / total) * 100,
    referrerPct: (summary.totalReferrerFees / total) * 100,
    triggerPct: (summary.totalTriggerFees / total) * 100
  }
}
```

### Convert Fee Amounts

```javascript
// Fees are in smallest unit, convert to decimal
const convertFee = (feeAmount, decimals) => {
  return feeAmount / (10 ** decimals)
}

// Example: USDC fees (6 decimals)
const feeUSDC = convertFee(1000000, 6) // = 1.0 USDC
```

---

## Best Practices

### Date Range Queries

```javascript
// Get current month stats
const now = new Date()
const firstDay = new Date(now.getFullYear(), now.getMonth(), 1)
const lastDay = new Date(now.getFullYear(), now.getMonth() + 1, 0)

const query = `
  query GetMonthlyStats {
    fee {
      protocolFeeSummary(
        fromDate: "${firstDay.toISOString()}"
        toDate: "${lastDay.toISOString()}"
      ) {
        totalFees
        uniqueTraders
      }
    }
  }
`
```

### Pagination for Large Datasets

```javascript
// Fetch all fee transactions in batches
const fetchAllFees = async (trader, limit = 100) => {
  let allFees = []
  let offset = 0
  let hasMore = true
  
  while (hasMore) {
    const { data } = await client.query({
      query: FEE_TRANSACTIONS_QUERY,
      variables: { trader, limit, offset }
    })
    
    const fees = data.fee.feeTransactions
    allFees = allFees.concat(fees)
    
    hasMore = fees.length === limit
    offset += limit
  }
  
  return allFees
}
```

### Caching Daily Stats

```javascript
// Cache daily stats (they don't change)
const cacheDailyStats = new Map()

const getDailyStats = async (date) => {
  const dateKey = date.toISOString().split('T')[0]
  
  if (cacheDailyStats.has(dateKey)) {
    return cacheDailyStats.get(dateKey)
  }
  
  const stats = await fetchDailyStats(date)
  cacheDailyStats.set(dateKey, stats)
  return stats
}
```

---

**Next**: [Query Examples](./examples-queries.md) | [Previous](./api-oracle.md) | [Back to Introduction](./README.md)
