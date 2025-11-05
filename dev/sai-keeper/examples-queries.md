# Query Examples

Practical examples for common query patterns using the Sai Keeper API.

## Table of Contents

- [Setup](#setup)
- [Perp Queries](#perp-queries)
- [LP Queries](#lp-queries)
- [Oracle Queries](#oracle-queries)
- [Fee Queries](#fee-queries)
- [Advanced Patterns](#advanced-patterns)

## Setup

These examples use Apollo Client, but the queries work with any GraphQL client.

```javascript
import { ApolloClient, InMemoryCache, gql } from '@apollo/client'

const client = new ApolloClient({
  uri: 'https://sai-keeper.testnet-2.nibiru.fi/graphql',
  cache: new InMemoryCache()
})
```

---

## Perp Queries

### Example 1: Get All Open Positions for a Trader

```javascript
const GET_OPEN_POSITIONS = gql`
  query GetOpenPositions($trader: String!) {
    perp {
      trades(
        where: {
          trader: $trader
          isOpen: true
        }
        order_desc: true
      ) {
        id
        isLong
        leverage
        collateralAmount
        openPrice
        sl
        tp
        perpBorrowing {
          baseToken {
            symbol
            name
            logoUrl
          }
          collateralToken {
            symbol
            decimals
          }
          marketId
        }
        openBlock {
          block_ts
        }
        state {
          pnlCollateral
          pnlPct
          pnlCollateralAfterFees
          liquidationPrice
          positionValue
          borrowingFeeCollateral
        }
      }
    }
  }
`

// Usage
const { data } = await client.query({
  query: GET_OPEN_POSITIONS,
  variables: { trader: 'nibi1abc...' }
})

// Process results
data.perp.trades.forEach(trade => {
  const token = trade.perpBorrowing.baseToken
  const decimals = trade.perpBorrowing.collateralToken.decimals
  
  console.log(`${token.symbol} ${trade.isLong ? 'LONG' : 'SHORT'}`)
  console.log(`Leverage: ${trade.leverage}x`)
  console.log(`PnL: ${(trade.state.pnlPct * 100).toFixed(2)}%`)
  console.log(`Liquidation: $${trade.state.liquidationPrice.toFixed(2)}`)
})
```

### Example 2: Get Trade History with Realized PnL

```javascript
const GET_TRADE_HISTORY = gql`
  query GetTradeHistory($trader: String!, $limit: Int!) {
    perp {
      tradeHistory(
        where: { trader: $trader }
        limit: $limit
        order_by: sequence
        order_desc: true
      ) {
        id
        tradeChangeType
        realizedPnlCollateral
        realizedPnlPct
        block {
          block
          block_ts
        }
        trade {
          id
          isLong
          leverage
          openPrice
          closePrice
          perpBorrowing {
            baseToken {
              symbol
            }
            collateralToken {
              symbol
              decimals
            }
          }
        }
      }
    }
  }
`

// Usage
const { data } = await client.query({
  query: GET_TRADE_HISTORY,
  variables: { trader: 'nibi1abc...', limit: 50 }
})

// Calculate total realized PnL
const totalPnL = data.perp.tradeHistory
  .filter(h => h.realizedPnlCollateral !== null)
  .reduce((sum, h) => sum + h.realizedPnlCollateral, 0)

console.log(`Total Realized PnL: ${totalPnL}`)
```

### Example 3: Get Market Information and Funding Rates

```javascript
const GET_MARKET_INFO = gql`
  query GetMarketInfo($collateralId: Int!, $marketId: Int!) {
    perp {
      borrowing(collateralId: $collateralId, marketId: $marketId) {
        marketId
        baseToken {
          symbol
          name
          logoUrl
        }
        quoteToken {
          symbol
        }
        collateralToken {
          symbol
          decimals
        }
        price
        oiLong
        oiShort
        oiMax
        feesPerHourLong
        feesPerHourShort
        openFeePct
        closeFeePct
        maxLeverage
        minLeverage
        minPositionSizeUSD
      }
    }
  }
`

// Usage
const { data } = await client.query({
  query: GET_MARKET_INFO,
  variables: { collateralId: 1, marketId: 1 }
})

const market = data.perp.borrowing

// Calculate funding rate APR
const hourlyRateLong = market.feesPerHourLong
const aprLong = hourlyRateLong * 24 * 365 * 100

console.log(`${market.baseToken.symbol} Market`)
console.log(`Price: $${market.price}`)
console.log(`OI Long: ${market.oiLong} | Short: ${market.oiShort}`)
console.log(`Max Leverage: ${market.maxLeverage}x`)
console.log(`Funding APR Long: ${aprLong.toFixed(2)}%`)
```

### Example 4: List All Available Markets

```javascript
const GET_ALL_MARKETS = gql`
  query GetAllMarkets {
    perp {
      borrowings(order_by: base_token_name) {
        marketId
        baseToken {
          symbol
          name
          logoUrl
          tradingViewSymbol
        }
        collateralToken {
          symbol
        }
        visible
      }
    }
  }
`

// Usage
const { data } = await client.query({
  query: GET_ALL_MARKETS
})

// Filter only visible markets
const visibleMarkets = data.perp.borrowings.filter(m => m.visible)

console.log(`Available markets: ${visibleMarkets.length}`)
visibleMarkets.forEach(m => {
  console.log(`${m.baseToken.symbol}-${m.collateralToken.symbol} (ID: ${m.marketId})`)
})
```

---

## LP Queries

### Example 5: Get All Vaults with Metrics

```javascript
const GET_ALL_VAULTS = gql`
  query GetAllVaults {
    lp {
      vaults {
        address
        collateralToken {
          symbol
          name
          logoUrl
          decimals
        }
        tvl
        sharePrice
        apy
        availableAssets
        currentEpoch
        epochStart
        sharesDenom
        collateralERC20
        sharesERC20
        revenueInfo {
          RevenueCumulative
          NetProfit
          TraderLosses
          CurrentEpochPositiveOpenPnl
          Liabilities
        }
      }
      epochDurationDays
    }
  }
`

// Usage
const { data } = await client.query({
  query: GET_ALL_VAULTS
})

data.lp.vaults.forEach(vault => {
  const decimals = vault.collateralToken.decimals
  const tvlFormatted = vault.tvl / (10 ** decimals)
  
  console.log(`${vault.collateralToken.symbol} Vault`)
  console.log(`TVL: ${tvlFormatted.toLocaleString()} ${vault.collateralToken.symbol}`)
  console.log(`APY: ${vault.apy?.toFixed(2) || 'N/A'}%`)
  console.log(`Share Price: ${vault.sharePrice}`)
  console.log(`Epoch: ${vault.currentEpoch}`)
})
```

### Example 6: Get User LP Positions

```javascript
const GET_USER_LP_POSITIONS = gql`
  query GetUserLPPositions($user: String!) {
    lp {
      deposits(where: { depositor: $user }) {
        depositor
        shares
        vault {
          address
          collateralToken {
            symbol
            decimals
          }
          sharePrice
          apy
          currentEpoch
        }
      }
      withdrawRequests(where: { depositor: $user }) {
        depositor
        shares
        status
        unlockEpoch
        autoRedeem
        vault {
          address
          collateralToken {
            symbol
            decimals
          }
          sharePrice
          currentEpoch
        }
      }
    }
  }
`

// Usage
const { data } = await client.query({
  query: GET_USER_LP_POSITIONS,
  variables: { user: 'nibi1abc...' }
})

// Calculate total portfolio value
let totalValue = 0

data.lp.deposits.forEach(deposit => {
  const decimals = deposit.vault.collateralToken.decimals
  const value = (deposit.shares * deposit.vault.sharePrice) / (10 ** decimals)
  totalValue += value
  
  console.log(`${deposit.vault.collateralToken.symbol} Vault`)
  console.log(`Shares: ${deposit.shares}`)
  console.log(`Value: ${value.toFixed(2)}`)
  console.log(`APY: ${deposit.vault.apy?.toFixed(2) || 'N/A'}%`)
})

// Check pending withdrawals
data.lp.withdrawRequests.forEach(request => {
  const isReady = request.vault.currentEpoch >= request.unlockEpoch
  const epochsRemaining = Math.max(0, request.unlockEpoch - request.vault.currentEpoch)
  
  console.log(`\nPending Withdrawal: ${request.vault.collateralToken.symbol}`)
  console.log(`Status: ${isReady ? 'Ready' : `${epochsRemaining} epochs remaining`}`)
  console.log(`Auto-redeem: ${request.autoRedeem}`)
})

console.log(`\nTotal LP Value: ${totalValue.toFixed(2)}`)
```

### Example 7: Get Vault Deposit/Withdrawal History

```javascript
const GET_VAULT_HISTORY = gql`
  query GetVaultHistory($vaultAddress: String!, $limit: Int!) {
    lp {
      depositHistory(
        where: { vault: $vaultAddress }
        limit: $limit
        order_by: sequence
        order_desc: true
      ) {
        id
        depositor
        amount
        shares
        isWithdraw
        block {
          block
          block_ts
        }
        vault {
          collateralToken {
            symbol
            decimals
          }
        }
      }
    }
  }
`

// Usage
const { data } = await client.query({
  query: GET_VAULT_HISTORY,
  variables: { vaultAddress: 'nibi1vault...', limit: 100 }
})

data.lp.depositHistory.forEach(event => {
  const decimals = event.vault.collateralToken.decimals
  const amount = event.amount / (10 ** decimals)
  const action = event.isWithdraw ? 'Withdrew' : 'Deposited'
  const date = new Date(event.block.block_ts).toLocaleDateString()
  
  console.log(`${date}: ${event.depositor} ${action} ${amount.toFixed(2)}`)
})
```

---

## Oracle Queries

### Example 8: Get Current Token Prices

```javascript
const GET_TOKEN_PRICES = gql`
  query GetTokenPrices {
    oracle {
      tokenPricesUsd(limit: 100) {
        token {
          id
          symbol
          name
          logoUrl
        }
        priceUsd
        lastUpdatedBlock {
          block
          block_ts
        }
      }
    }
  }
`

// Usage
const { data } = await client.query({
  query: GET_TOKEN_PRICES
})

// Create price map
const priceMap = {}
data.oracle.tokenPricesUsd.forEach(item => {
  priceMap[item.token.symbol] = {
    price: item.priceUsd,
    lastUpdate: item.lastUpdatedBlock.block_ts
  }
})

console.log(`BTC: $${priceMap['BTC'].price.toFixed(2)}`)
console.log(`ETH: $${priceMap['ETH'].price.toFixed(2)}`)
```

### Example 9: Get Specific Token Price with Freshness Check

```javascript
const GET_TOKEN_PRICE = gql`
  query GetTokenPrice($tokenId: Int!) {
    oracle {
      tokenPricesUsd(where: { tokenId: $tokenId }) {
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
`

// Usage
const { data } = await client.query({
  query: GET_TOKEN_PRICE,
  variables: { tokenId: 1 }
})

const priceData = data.oracle.tokenPricesUsd[0]
const lastUpdate = new Date(priceData.lastUpdatedBlock.block_ts)
const ageSeconds = (Date.now() - lastUpdate.getTime()) / 1000

console.log(`${priceData.token.symbol}: $${priceData.priceUsd}`)
console.log(`Last updated: ${ageSeconds.toFixed(0)}s ago`)

if (ageSeconds > 60) {
  console.warn('⚠️  Price may be stale')
}
```

---

## Fee Queries

### Example 10: Get User Fee History

```javascript
const GET_USER_FEES = gql`
  query GetUserFees($trader: String!, $limit: Int!) {
    fee {
      feeTransactions(
        filter: { traderAddress: $trader }
        limit: $limit
      ) {
        id
        feeType
        totalFeeCharged
        govFee
        vaultFee
        referrerAllocation
        triggerFee
        collateralDenom
        feeMultiplier
        blockTime
        tradeId
      }
    }
  }
`

// Usage
const { data } = await client.query({
  query: GET_USER_FEES,
  variables: { trader: 'nibi1abc...', limit: 50 }
})

// Calculate total fees paid
const totalFees = data.fee.feeTransactions.reduce((sum, fee) => {
  return sum + fee.totalFeeCharged
}, 0)

console.log(`Total fees paid: ${totalFees}`)
console.log(`Number of transactions: ${data.fee.feeTransactions.length}`)
```

### Example 11: Get Protocol Fee Summary

```javascript
const GET_PROTOCOL_SUMMARY = gql`
  query GetProtocolSummary($fromDate: Time, $toDate: Time) {
    fee {
      protocolFeeSummary(fromDate: $fromDate, toDate: $toDate) {
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
`

// Usage - Get last 30 days
const thirtyDaysAgo = new Date()
thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30)

const { data } = await client.query({
  query: GET_PROTOCOL_SUMMARY,
  variables: {
    fromDate: thirtyDaysAgo.toISOString(),
    toDate: new Date().toISOString()
  }
})

const summary = data.fee.protocolFeeSummary

console.log('Protocol Summary (Last 30 Days)')
console.log(`Total Fees: ${summary.totalFees}`)
console.log(`Gov Fees: ${summary.totalGovFees}`)
console.log(`Vault Fees: ${summary.totalVaultFees}`)
console.log(`Unique Traders: ${summary.uniqueTraders}`)
console.log(`Avg Fee Multiplier: ${summary.avgFeeMultiplier.toFixed(2)}x`)
```

### Example 12: Get Daily Fee Statistics

```javascript
const GET_DAILY_STATS = gql`
  query GetDailyStats($limit: Int!) {
    fee {
      feeDailyStats(
        filter: { protocolWide: true }
        limit: $limit
      ) {
        date
        collateralDenom
        openingFeeTotal
        closingFeeTotal
        openingFeeCount
        closingFeeCount
        totalBadDebt
      }
    }
  }
`

// Usage
const { data } = await client.query({
  query: GET_DAILY_STATS,
  variables: { limit: 30 }
})

// Create time series for charting
const chartData = data.fee.feeDailyStats.map(stat => ({
  date: new Date(stat.date).toLocaleDateString(),
  totalFees: stat.openingFeeTotal + stat.closingFeeTotal,
  transactions: stat.openingFeeCount + stat.closingFeeCount
}))

console.log('Daily Fee Data:', chartData)
```

---

## Advanced Patterns

### Example 13: Combine Multiple Queries

```javascript
const GET_DASHBOARD_DATA = gql`
  query GetDashboardData($trader: String!) {
    perp {
      trades(where: { trader: $trader, isOpen: true }) {
        id
        isLong
        leverage
        state {
          pnlCollateral
          pnlPct
        }
        perpBorrowing {
          baseToken { symbol }
        }
      }
    }
    lp {
      deposits(where: { depositor: $trader }) {
        shares
        vault {
          sharePrice
          collateralToken {
            symbol
            decimals
          }
        }
      }
    }
    fee {
      traderFeeSummary(traderAddress: $trader) {
        totalFees
        openingCount
        closingCount
      }
    }
  }
`

// Usage - Get all user data in one query
const { data } = await client.query({
  query: GET_DASHBOARD_DATA,
  variables: { trader: 'nibi1abc...' }
})

console.log('Open Positions:', data.perp.trades.length)
console.log('LP Deposits:', data.lp.deposits.length)
console.log('Total Trades:', data.fee.traderFeeSummary.openingCount + data.fee.traderFeeSummary.closingCount)
```

### Example 14: Pagination Pattern

```javascript
// Fetch all trades with pagination
async function fetchAllTrades(trader) {
  const QUERY = gql`
    query GetTrades($trader: String!, $limit: Int!, $offset: Int!) {
      perp {
        trades(
          where: { trader: $trader }
          limit: $limit
          offset: $offset
        ) {
          id
          isOpen
          isLong
        }
      }
    }
  `
  
  let allTrades = []
  let offset = 0
  const limit = 100
  let hasMore = true
  
  while (hasMore) {
    const { data } = await client.query({
      query: QUERY,
      variables: { trader, limit, offset }
    })
    
    const trades = data.perp.trades
    allTrades = allTrades.concat(trades)
    
    hasMore = trades.length === limit
    offset += limit
    
    console.log(`Fetched ${allTrades.length} trades...`)
  }
  
  return allTrades
}

// Usage
const allTrades = await fetchAllTrades('nibi1abc...')
console.log(`Total trades: ${allTrades.length}`)
```

### Example 15: Error Handling Pattern

```javascript
async function queryWithRetry(query, variables, maxRetries = 3) {
  let lastError
  
  for (let i = 0; i < maxRetries; i++) {
    try {
      const { data, errors } = await client.query({
        query,
        variables
      })
      
      if (errors && errors.length > 0) {
        throw new Error(errors[0].message)
      }
      
      return data
    } catch (error) {
      lastError = error
      console.warn(`Query attempt ${i + 1} failed:`, error.message)
      
      if (i < maxRetries - 1) {
        // Exponential backoff
        await new Promise(resolve => setTimeout(resolve, 1000 * Math.pow(2, i)))
      }
    }
  }
  
  throw new Error(`Query failed after ${maxRetries} attempts: ${lastError.message}`)
}

// Usage
try {
  const data = await queryWithRetry(GET_OPEN_POSITIONS, { trader: 'nibi1abc...' })
  console.log('Success:', data)
} catch (error) {
  console.error('Failed:', error.message)
}
```

---

**Next**: [Subscription Examples](./examples-subscriptions.md) | [Previous](./api-fees.md) | [Back to Introduction](./README.md)
