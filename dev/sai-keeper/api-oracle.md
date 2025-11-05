# Oracle API Reference

Query and subscribe to token price feeds and metadata.

## Table of Contents

- [Queries](#queries)
  - [token](#token)
  - [tokens](#tokens)
  - [tokenPricesUsd](#tokenpricesusd)
- [Subscriptions](#subscriptions)
- [Types Reference](#types-reference)

## Queries

### token

Get details for a specific token by ID.

**Signature:**

```graphql
token(id: Int!): Token!
```

**Parameters:**

- `id`: Token ID (integer)

**Returns:** `Token` object

**Example:**

```graphql
query GetToken {
  oracle {
    token(id: 1) {
      id
      symbol
      name
      logoUrl
      tradingViewSymbol
      permissionGroup
    }
  }
}
```

**Use Cases:**

- Get token metadata
- Display token information
- Resolve token ID to symbol

---

### tokens

List all available tokens with filtering and ordering.

**Signature:**

```graphql
tokens(
  where: TokensFilter
  limit: Int
  order_by: TokensOrder
  order_desc: Boolean
): [Token!]!
```

**Parameters:**

- `where`: Filter object (optional)
  - `name`: Filter by token name (string match)
  - `permissionGroup`: Filter by permission group
- `limit`: Max results
- `order_by`: Sort by `id`, `name`, or `permission_group`
- `order_desc`: Sort descending

**Returns:** Array of `Token` objects

**Example - List All Tokens:**

```graphql
query ListAllTokens {
  oracle {
    tokens(order_by: name) {
      id
      symbol
      name
      logoUrl
      tradingViewSymbol
    }
  }
}
```

**Example - Search by Name:**

```graphql
query SearchToken($searchTerm: String!) {
  oracle {
    tokens(where: { name: $searchTerm }) {
      id
      symbol
      name
    }
  }
}
```

**Example - Filter by Permission Group:**

```graphql
query GetPermittedTokens {
  oracle {
    tokens(where: { permissionGroup: 1 }) {
      id
      symbol
      name
    }
  }
}
```

**Use Cases:**

- Build token selector dropdown
- Search tokens by name
- List tradeable assets
- Filter by permissions

---

### tokenPricesUsd query

Get current USD prices for tokens.

**Signature:**

```graphql
tokenPricesUsd(
  where: TokenPriceUsdFilter
  limit: Int
  order_by: TokenPriceUsdOrder
  order_desc: Boolean
): [TokenPricesUsd!]!
```

**Parameters:**

- `where`: Filter object (optional)
  - `tokenId`: Filter by specific token ID
- `limit`: Max results
- `order_by`: Sort by `token_id`
- `order_desc`: Sort descending

**Returns:** Array of `TokenPricesUsd` objects

**Example - Get All Prices:**

```graphql
query GetAllPrices {
  oracle {
    tokenPricesUsd {
      token {
        id
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

**Example - Get Specific Token Price:**

```graphql
query GetBTCPrice {
  oracle {
    tokenPricesUsd(where: { tokenId: 1 }) {
      token {
        symbol
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

**Example - Get Multiple Prices:**

```graphql
query GetPrices {
  btc: oracle {
    tokenPricesUsd(where: { tokenId: 1 }) {
      priceUsd
      lastUpdatedBlock { block_ts }
    }
  }
  eth: oracle {
    tokenPricesUsd(where: { tokenId: 2 }) {
      priceUsd
      lastUpdatedBlock { block_ts }
    }
  }
}
```

**Key Fields:**

- `priceUsd`: Current price in USD (float)
- `lastUpdatedBlock`: Block info for last price update

**Use Cases:**

- Display token prices
- Calculate position values
- Monitor price changes
- Verify price freshness

---

## Subscriptions

Subscribe to real-time price updates.

### tokenPricesUsd

Subscribe to price updates for specific or all tokens.

**Signature:**

```graphql
subscription {
  tokenPricesUsd(where: SubTokenPriceUsdFilter): [TokenPricesUsd!]!
}
```

**Example - Subscribe to All Prices:**

```graphql
subscription WatchAllPrices {
  tokenPricesUsd {
    token {
      id
      symbol
    }
    priceUsd
    lastUpdatedBlock {
      block
      block_ts
    }
  }
}
```

**Example - Subscribe to Specific Token:**

```graphql
subscription WatchBTCPrice {
  tokenPricesUsd(where: { tokenId: 1 }) {
    token {
      symbol
    }
    priceUsd
    lastUpdatedBlock {
      block_ts
    }
  }
}
```

**Use Cases:**

- Real-time price tickers
- Live trading dashboards
- Price alert systems
- Chart updates

---

### userBalances

Subscribe to user balance updates across all tokens.

**Signature:**

```graphql
subscription {
  userBalances(where: SubUserBalancesFilter!): [Balance!]!
}
```

**Example:**

```graphql
subscription WatchUserBalances($user: String!) {
  userBalances(where: { user: $user }) {
    amount
    token_info {
      symbol
      decimals
      bank_denom
      erc20_contract_address
      logo
      name
      type
    }
  }
}
```

**Use Cases:**

- Track wallet balances
- Monitor account changes
- Real-time portfolio updates
- Display available funds

---

## Types Reference

### Token

```graphql
type Token {
  id: Int!
  symbol: String!
  name: String!
  logoUrl: String
  tradingViewSymbol: String
  permissionGroup: Int!
}
```

**Field Details:**

- `id`: Unique token identifier
- `symbol`: Token ticker (e.g., "BTC", "ETH")
- `name`: Full token name (e.g., "Bitcoin", "Ethereum")
- `logoUrl`: URL to token logo image
- `tradingViewSymbol`: Symbol for TradingView charts
- `permissionGroup`: Access/trading permission level

---

### TokenPricesUsd

```graphql
type TokenPricesUsd {
  token: Token
  priceUsd: Float!
  lastUpdatedBlock: Block!
}
```

**Field Details:**

- `token`: Associated token metadata
- `priceUsd`: Current USD price
- `lastUpdatedBlock`: Last price update info
  - `block`: Block height
  - `block_ts`: Timestamp (RFC3339 format)

---

### Balance

```graphql
type Balance {
  amount: String!
  token_info: TokenInfo!
}
```

---

### TokenInfo

Detailed token information for balances.

```graphql
type TokenInfo {
  bank_denom: String!
  symbol: String!
  name: String!
  decimals: Int!
  logo: String
  type: TokenType!
  erc20_contract_address: String!
}
```

**TokenType Enum:**

- `bank`: Native Cosmos SDK token
- `erc20`: ERC20 token on EVM

---

## Working with Prices

### Price Freshness

Always check when price was last updated:

```javascript
const now = Date.now()
const lastUpdate = new Date(lastUpdatedBlock.block_ts).getTime()
const ageSeconds = (now - lastUpdate) / 1000

if (ageSeconds > 60) {
  console.warn('Price may be stale')
}
```

### Price Formatting

```javascript
// Format price with appropriate decimals
const formatPrice = (priceUsd) => {
  if (priceUsd >= 1000) {
    return priceUsd.toFixed(2)
  } else if (priceUsd >= 1) {
    return priceUsd.toFixed(4)
  } else {
    return priceUsd.toFixed(6)
  }
}
```

### Calculate Position Value

```javascript
// Calculate position value in USD
const positionValueUsd = (collateralAmount, priceUsd, decimals) => {
  const actualAmount = collateralAmount / (10 ** decimals)
  return actualAmount * priceUsd
}
```

### Balance Conversion

```javascript
// Convert balance amount string to number
const getBalanceValue = (balance) => {
  const amount = parseFloat(balance.amount)
  return amount / (10 ** balance.token_info.decimals)
}
```

---

## Best Practices

### Caching Prices

```javascript
// Cache prices for short periods to reduce queries
const priceCache = new Map()
const CACHE_TTL = 5000 // 5 seconds

const getCachedPrice = async (tokenId) => {
  const cached = priceCache.get(tokenId)
  if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
    return cached.price
  }
  
  const price = await fetchPrice(tokenId)
  priceCache.set(tokenId, { price, timestamp: Date.now() })
  return price
}
```

### Handling Multiple Tokens

```javascript
// Batch query multiple prices efficiently
const query = `
  query GetMultiplePrices($tokenIds: [Int!]!) {
    oracle {
      prices: tokenPricesUsd(limit: 100) {
        token { id symbol }
        priceUsd
      }
    }
  }
`

// Filter client-side for needed tokens
const relevantPrices = data.oracle.prices.filter(p => 
  tokenIds.includes(p.token.id)
)
```

### Subscription Management

```javascript
// Manage price subscription lifecycle
let priceSubscription

const subscribeToPrices = (tokenIds) => {
  // Unsubscribe from previous
  if (priceSubscription) {
    priceSubscription.unsubscribe()
  }
  
  // Subscribe to new set
  priceSubscription = client.subscribe({
    query: PRICE_SUBSCRIPTION,
    variables: { tokenIds }
  }).subscribe({
    next: (data) => updatePrices(data),
    error: (err) => console.error(err)
  })
}
```

