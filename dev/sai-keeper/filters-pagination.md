# Filters and Pagination

Master advanced querying patterns including filtering, pagination, and ordering.

## Table of Contents

- [Filter Types](#filter-types)
- [Pagination](#pagination)
- [Ordering](#ordering)
- [Advanced Patterns](#advanced-patterns)
- [Best Practices](#best-practices)

---

## Filter Types

Sai Keeper supports various filter types for different data types.

### String Filters

**StringFilter** supports equality and pattern matching.

```graphql
input StringFilter {
  eq: String      # Exact match
  like: String    # Pattern match
}
```

**Example - Exact Match:**

```graphql
query SearchToken {
  oracle {
    tokens(where: { name: { eq: "Bitcoin" } }) {
      id
      symbol
      name
    }
  }
}
```

**Example - Pattern Match:**

```graphql
query SearchByPattern {
  oracle {
    tokens(where: { name: { like: "%coin%" } }) {
      symbol
      name
    }
  }
}
```

**Usage in JavaScript:**

```javascript
// Exact match
const { data } = await client.query({
  query: gql`
    query SearchToken($name: String!) {
      oracle {
        tokens(where: { name: $name }) {
          symbol
          name
        }
      }
    }
  `,
  variables: { name: "Bitcoin" }
})

// Pattern search
const searchResults = await client.query({
  query: gql`
    query SearchTokens($pattern: String!) {
      oracle {
        tokens(where: { name: $pattern }) {
          symbol
          name
        }
      }
    }
  `,
  variables: { pattern: "%BTC%" }
})
```

---

### Integer Filters

**IntFilter** supports comparison operations.

```graphql
input IntFilter {
  eq: Int   # Equal to
  gt: Int   # Greater than
  gte: Int  # Greater than or equal
  lt: Int   # Less than
  lte: Int  # Less than or equal
}
```

**Example - Fee Amount Range:**

```graphql
query GetLargeFees {
  fee {
    feeTransactions(
      filter: {
        minAmount: 1000000    # >= 1,000,000
        maxAmount: 10000000   # <= 10,000,000
      }
    ) {
      id
      totalFeeCharged
      traderAddress
    }
  }
}
```

**Usage in JavaScript:**

```javascript
const { data } = await client.query({
  query: gql`
    query GetFeesInRange($min: Int!, $max: Int!) {
      fee {
        feeTransactions(
          filter: {
            minAmount: $min
            maxAmount: $max
          }
        ) {
          id
          totalFeeCharged
        }
      }
    }
  `,
  variables: {
    min: 1000000,
    max: 10000000
  }
})
```

---

### Float Filters

**FloatFilter** for floating-point comparisons.

```graphql
input FloatFilter {
  eq: Float   # Equal to
  gt: Float   # Greater than
  gte: Float  # Greater than or equal
  lt: Float   # Less than
  lte: Float  # Less than or equal
}
```

**Example - Filter by Leverage:**

```javascript
// Note: Direct float filters not used in current schema,
// but filter objects use similar patterns
const highLeverageTrades = await client.query({
  query: gql`
    query GetHighLeverageTrades($trader: String!) {
      perp {
        trades(where: { trader: $trader }) {
          id
          leverage
          isOpen
        }
      }
    }
  `,
  variables: { trader: "nibi1abc..." }
})

// Filter client-side
const filtered = highLeverageTrades.data.perp.trades.filter(
  trade => trade.leverage > 10
)
```

---

### Time Filters

**TimeFilter** for date/time range queries.

```graphql
input TimeFilter {
  eq: Time   # Exact time
  gt: Time   # After
  gte: Time  # After or at
  lt: Time   # Before
  lte: Time  # Before or at
}
```

**Example - Filter by Date Range:**

```graphql
query GetFeesLastMonth {
  fee {
    feeTransactions(
      filter: {
        fromDate: "2024-10-01T00:00:00Z"
        toDate: "2024-10-31T23:59:59Z"
      }
      limit: 100
    ) {
      id
      totalFeeCharged
      blockTime
    }
  }
}
```

**Usage in JavaScript:**

```javascript
// Get fees for last 30 days
const thirtyDaysAgo = new Date()
thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30)

const { data } = await client.query({
  query: gql`
    query GetRecentFees($fromDate: Time!, $toDate: Time!) {
      fee {
        feeTransactions(
          filter: {
            fromDate: $fromDate
            toDate: $toDate
          }
          limit: 100
        ) {
          id
          totalFeeCharged
          blockTime
        }
      }
    }
  `,
  variables: {
    fromDate: thirtyDaysAgo.toISOString(),
    toDate: new Date().toISOString()
  }
})
```

**Helper Function:**

```javascript
function getDateRange(days) {
  const toDate = new Date()
  const fromDate = new Date()
  fromDate.setDate(fromDate.getDate() - days)
  
  return {
    fromDate: fromDate.toISOString(),
    toDate: toDate.toISOString()
  }
}

// Usage
const last7Days = getDateRange(7)
const last30Days = getDateRange(30)
const last90Days = getDateRange(90)
```

---

### Enum Filters

Filter by enum values.

**Example - Fee Type Filter:**

```graphql
query GetOpeningFees($trader: String!) {
  fee {
    feeTransactions(
      filter: {
        traderAddress: $trader
        feeType: OPENING
      }
      limit: 50
    ) {
      id
      feeType
      totalFeeCharged
    }
  }
}
```

**Example - Trade Type Filter:**

```javascript
// Get only limit orders
const { data } = await client.query({
  query: gql`
    query GetLimitOrders($trader: String!) {
      perp {
        tradeHistory(where: { trader: $trader }, limit: 100) {
          id
          tradeChangeType
          trade {
            id
            tradeType
          }
        }
      }
    }
  `,
  variables: { trader: "nibi1abc..." }
})

// Filter for limit_order_created events
const limitOrders = data.perp.tradeHistory.filter(
  h => h.tradeChangeType === 'limit_order_created'
)
```

---

## Pagination

### Basic Pagination

Use `limit` and `offset` for pagination.

```graphql
query GetTradesPaginated($trader: String!, $limit: Int!, $offset: Int!) {
  perp {
    trades(
      where: { trader: $trader }
      limit: $limit
      offset: $offset
    ) {
      id
      isOpen
      leverage
    }
  }
}
```

**JavaScript Implementation:**

```javascript
async function fetchPage(trader, page = 0, pageSize = 20) {
  const { data } = await client.query({
    query: GET_TRADES_PAGINATED,
    variables: {
      trader,
      limit: pageSize,
      offset: page * pageSize
    }
  })
  
  return data.perp.trades
}

// Get first page
const firstPage = await fetchPage("nibi1abc...", 0, 20)

// Get second page
const secondPage = await fetchPage("nibi1abc...", 1, 20)

// Get third page
const thirdPage = await fetchPage("nibi1abc...", 2, 20)
```

---

### Fetch All Pattern

Fetch all results across multiple pages.

```javascript
async function fetchAllTrades(trader, pageSize = 100) {
  let allTrades = []
  let page = 0
  let hasMore = true
  
  while (hasMore) {
    const { data } = await client.query({
      query: gql`
        query GetTrades($trader: String!, $limit: Int!, $offset: Int!) {
          perp {
            trades(
              where: { trader: $trader }
              limit: $limit
              offset: $offset
            ) {
              id
              isOpen
              leverage
            }
          }
        }
      `,
      variables: {
        trader,
        limit: pageSize,
        offset: page * pageSize
      }
    })
    
    const trades = data.perp.trades
    allTrades = allTrades.concat(trades)
    
    hasMore = trades.length === pageSize
    page++
    
    console.log(`Fetched page ${page}, total: ${allTrades.length}`)
  }
  
  return allTrades
}

// Usage
const allTrades = await fetchAllTrades("nibi1abc...")
console.log(`Total trades: ${allTrades.length}`)
```

---

### Cursor-Based Pagination Alternative

While Sai Keeper uses offset pagination, you can implement cursor-based logic:

```javascript
async function fetchTradesAfterBlock(trader, afterBlock = 0, limit = 100) {
  const { data } = await client.query({
    query: gql`
      query GetTrades($trader: String!, $limit: Int!) {
        perp {
          trades(
            where: { trader: $trader }
            limit: $limit
            order_desc: false
          ) {
            id
            openBlock {
              block
            }
          }
        }
      }
    `,
    variables: { trader, limit }
  })
  
  // Filter trades after cursor block
  const filtered = data.perp.trades.filter(
    trade => trade.openBlock.block > afterBlock
  )
  
  return filtered
}

// Get first batch
const firstBatch = await fetchTradesAfterBlock("nibi1abc...", 0)
const lastBlock = firstBatch[firstBatch.length - 1].openBlock.block

// Get next batch
const nextBatch = await fetchTradesAfterBlock("nibi1abc...", lastBlock)
```

---

### Infinite Scroll Pattern

Implement infinite scroll for UI:

```javascript
class TradesPaginator {
  constructor(client, trader, pageSize = 20) {
    this.client = client
    this.trader = trader
    this.pageSize = pageSize
    this.currentPage = 0
    this.allTrades = []
    this.hasMore = true
  }
  
  async loadMore() {
    if (!this.hasMore) {
      return []
    }
    
    const { data } = await this.client.query({
      query: gql`
        query GetTrades($trader: String!, $limit: Int!, $offset: Int!) {
          perp {
            trades(
              where: { trader: $trader }
              limit: $limit
              offset: $offset
              order_desc: true
            ) {
              id
              isOpen
              leverage
            }
          }
        }
      `,
      variables: {
        trader: this.trader,
        limit: this.pageSize,
        offset: this.currentPage * this.pageSize
      }
    })
    
    const trades = data.perp.trades
    this.allTrades = this.allTrades.concat(trades)
    this.hasMore = trades.length === this.pageSize
    this.currentPage++
    
    return trades
  }
  
  reset() {
    this.currentPage = 0
    this.allTrades = []
    this.hasMore = true
  }
  
  getAll() {
    return this.allTrades
  }
}

// Usage
const paginator = new TradesPaginator(client, "nibi1abc...", 20)

// Load first page
const firstPage = await paginator.loadMore()

// Load more on scroll
window.addEventListener('scroll', async () => {
  if (isNearBottom() && paginator.hasMore) {
    const nextPage = await paginator.loadMore()
    appendToUI(nextPage)
  }
})
```

---

## Ordering

### Order Direction

Most queries support `order_by` and `order_desc` parameters.

```graphql
query GetTradesOrdered($trader: String!) {
  perp {
    trades(
      where: { trader: $trader }
      order_by: sequence
      order_desc: true  # Descending (newest first)
    ) {
      id
      openBlock { block_ts }
    }
  }
}
```

**Order Options by Domain:**

**Perp Trades:**

- `sequence` - Order by sequence number

**Trade History:**

- `sequence` - Order by sequence
- `trade_id` - Order by trade ID

**LP Deposits:**

- `depositor` - Order by depositor address
- `vault` - Order by vault address

**LP Deposit History:**

- `depositor` - Order by depositor
- `sequence` - Order by sequence
- `vault` - Order by vault

**LP Withdraw Requests:**

- `depositor` - Order by depositor
- `unlock_epoch` - Order by unlock epoch
- `vault` - Order by vault

**Oracle Tokens:**

- `id` - Order by token ID
- `name` - Order by token name
- `permission_group` - Order by permission group

**Fee Transactions:**

- No explicit ordering parameter, results ordered by ID

---

### Sorting Examples

**Newest First:**

```javascript
const { data } = await client.query({
  query: gql`
    query GetRecentTrades($trader: String!) {
      perp {
        trades(
          where: { trader: $trader }
          order_desc: true
          limit: 20
        ) {
          id
          openBlock { block_ts }
        }
      }
    }
  `,
  variables: { trader: "nibi1abc..." }
})
```

**Oldest First:**

```javascript
const { data } = await client.query({
  query: gql`
    query GetOldestTrades($trader: String!) {
      perp {
        trades(
          where: { trader: $trader }
          order_desc: false
          limit: 20
        ) {
          id
          openBlock { block_ts }
        }
      }
    }
  `,
  variables: { trader: "nibi1abc..." }
})
```

**By Token Name:**

```javascript
const { data } = await client.query({
  query: gql`
    query GetTokensAlphabetically {
      oracle {
        tokens(
          order_by: name
          order_desc: false
        ) {
          symbol
          name
        }
      }
    }
  `
})
```

---

## Advanced Patterns

### Combined Filters

Combine multiple filters for precise queries.

```javascript
const { data } = await client.query({
  query: gql`
    query GetFilteredFees(
      $trader: String!
      $feeType: FeeType!
      $fromDate: Time!
      $toDate: Time!
      $minAmount: Int!
    ) {
      fee {
        feeTransactions(
          filter: {
            traderAddress: $trader
            feeType: $feeType
            fromDate: $fromDate
            toDate: $toDate
            minAmount: $minAmount
          }
          limit: 100
        ) {
          id
          totalFeeCharged
          blockTime
        }
      }
    }
  `,
  variables: {
    trader: "nibi1abc...",
    feeType: "OPENING",
    fromDate: "2024-01-01T00:00:00Z",
    toDate: "2024-12-31T23:59:59Z",
    minAmount: 1000000
  }
})
```

---

### Client-Side Post-Filtering

When server-side filters aren't available, filter client-side:

```javascript
// Fetch all trades
const { data } = await client.query({
  query: gql`
    query GetAllTrades($trader: String!) {
      perp {
        trades(where: { trader: $trader }, limit: 1000) {
          id
          leverage
          isLong
          isOpen
          collateralAmount
          state {
            pnlPct
          }
          perpBorrowing {
            baseToken { symbol }
          }
        }
      }
    }
  `,
  variables: { trader: "nibi1abc..." }
})

// Filter for high-leverage profitable longs
const filtered = data.perp.trades.filter(trade => 
  trade.isLong &&
  trade.leverage > 10 &&
  trade.state.pnlPct > 0.1 && // 10% profit
  trade.isOpen
)

// Group by token
const byToken = filtered.reduce((acc, trade) => {
  const symbol = trade.perpBorrowing.baseToken.symbol
  if (!acc[symbol]) acc[symbol] = []
  acc[symbol].push(trade)
  return acc
}, {})

console.log('Profitable high-leverage longs by token:', byToken)
```

---

### Search Implementation

Build a search feature:

```javascript
async function searchTrades(trader, searchTerm) {
  // Fetch all trades
  const { data } = await client.query({
    query: gql`
      query GetTrades($trader: String!) {
        perp {
          trades(where: { trader: $trader }) {
            id
            isLong
            leverage
            perpBorrowing {
              baseToken {
                symbol
                name
              }
              marketId
            }
          }
        }
      }
    `,
    variables: { trader }
  })
  
  // Search by token symbol or name
  const searchLower = searchTerm.toLowerCase()
  return data.perp.trades.filter(trade => {
    const symbol = trade.perpBorrowing.baseToken.symbol.toLowerCase()
    const name = trade.perpBorrowing.baseToken.name.toLowerCase()
    return symbol.includes(searchLower) || name.includes(searchLower)
  })
}

// Usage
const btcTrades = await searchTrades("nibi1abc...", "bitcoin")
const ethTrades = await searchTrades("nibi1abc...", "eth")
```

---

## Best Practices

### 1. Use Appropriate Page Sizes

```javascript
// Good: Reasonable page size
const PAGE_SIZE = 50

// Bad: Too large, slow queries
const PAGE_SIZE = 10000

// Bad: Too small, too many requests
const PAGE_SIZE = 5
```

**Recommended page sizes:**

- Trades: 20-100
- Fee transactions: 50-100
- Trade history: 50-200
- Tokens: 100-500

---

### 2. Cache Paginated Results

```javascript
class CachedPaginator {
  constructor(client, query, variables) {
    this.client = client
    this.query = query
    this.variables = variables
    this.cache = new Map()
  }
  
  async getPage(page, pageSize = 20) {
    const cacheKey = `${page}-${pageSize}`
    
    if (this.cache.has(cacheKey)) {
      return this.cache.get(cacheKey)
    }
    
    const { data } = await this.client.query({
      query: this.query,
      variables: {
        ...this.variables,
        limit: pageSize,
        offset: page * pageSize
      }
    })
    
    this.cache.set(cacheKey, data)
    return data
  }
  
  clearCache() {
    this.cache.clear()
  }
}
```

---

### 3. Handle Empty Results

```javascript
async function fetchTradesWithEmptyCheck(trader, page = 0) {
  const { data } = await client.query({
    query: GET_TRADES,
    variables: {
      trader,
      limit: 20,
      offset: page * 20
    }
  })
  
  const trades = data.perp.trades
  
  if (trades.length === 0) {
    if (page === 0) {
      console.log('No trades found for this trader')
    } else {
      console.log('No more trades to load')
    }
  }
  
  return trades
}
```

---

### 4. Debounce Filter Changes

```javascript
import { debounce } from 'lodash'

const debouncedSearch = debounce(async (searchTerm) => {
  const results = await searchTrades(trader, searchTerm)
  updateUI(results)
}, 300) // Wait 300ms after user stops typing

// Usage in React
function SearchInput() {
  const handleChange = (e) => {
    debouncedSearch(e.target.value)
  }
  
  return <input onChange={handleChange} />
}
```

---

### 5. Show Loading States

```javascript
async function loadTradesWithUI(trader, page) {
  try {
    showLoadingSpinner()
    
    const trades = await fetchPage(trader, page)
    
    if (trades.length === 0) {
      showEmptyState()
    } else {
      renderTrades(trades)
    }
  } catch (error) {
    showErrorState(error)
  } finally {
    hideLoadingSpinner()
  }
}
```

---

### 6. Validate Filter Inputs

```javascript
function validateDateRange(fromDate, toDate) {
  const from = new Date(fromDate)
  const to = new Date(toDate)
  
  if (isNaN(from.getTime()) || isNaN(to.getTime())) {
    throw new Error('Invalid date format')
  }
  
  if (from > to) {
    throw new Error('From date must be before to date')
  }
  
  const maxRange = 90 * 24 * 60 * 60 * 1000 // 90 days
  if (to - from > maxRange) {
    throw new Error('Date range too large (max 90 days)')
  }
  
  return { fromDate, toDate }
}

// Usage
try {
  const { fromDate, toDate } = validateDateRange(
    userInputFrom,
    userInputTo
  )
  
  const { data } = await client.query({
    query: GET_FEES,
    variables: { fromDate, toDate }
  })
} catch (error) {
  showError(error.message)
}
```
