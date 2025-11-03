# Subscription Examples

Real-time data updates using GraphQL subscriptions over WebSockets.

## Table of Contents

- [Setup](#setup)
- [Perp Subscriptions](#perp-subscriptions)
- [LP Subscriptions](#lp-subscriptions)
- [Oracle Subscriptions](#oracle-subscriptions)
- [Advanced Patterns](#advanced-patterns)
- [Best Practices](#best-practices)

## Setup

### Apollo Client with Subscriptions

```javascript
import { ApolloClient, InMemoryCache, split, HttpLink } from '@apollo/client'
import { GraphQLWsLink } from '@apollo/client/link/subscriptions'
import { getMainDefinition } from '@apollo/client/utilities'
import { createClient } from 'graphql-ws'

const httpLink = new HttpLink({
  uri: 'https://sai-keeper.testnet-2.nibiru.fi/graphql'
})

const wsLink = new GraphQLWsLink(
  createClient({
    url: 'wss://sai-keeper.testnet-2.nibiru.fi/graphql',
    connectionParams: {
      // Add auth headers if needed
    },
    retryAttempts: 5,
    shouldRetry: () => true
  })
)

// Split link based on operation type
const splitLink = split(
  ({ query }) => {
    const definition = getMainDefinition(query)
    return (
      definition.kind === 'OperationDefinition' &&
      definition.operation === 'subscription'
    )
  },
  wsLink,
  httpLink
)

const client = new ApolloClient({
  link: splitLink,
  cache: new InMemoryCache()
})
```

### urql with Subscriptions

```javascript
import { createClient, subscriptionExchange, fetchExchange } from 'urql'
import { createClient as createWSClient } from 'graphql-ws'

const wsClient = createWSClient({
  url: 'wss://sai-keeper.testnet-2.nibiru.fi/graphql'
})

const client = createClient({
  url: 'https://sai-keeper.testnet-2.nibiru.fi/graphql',
  exchanges: [
    fetchExchange,
    subscriptionExchange({
      forwardSubscription: (operation) => ({
        subscribe: (sink) => ({
          unsubscribe: wsClient.subscribe(operation, sink)
        })
      })
    })
  ]
})
```

---

## Perp Subscriptions

### Example 1: Watch User Trades

Subscribe to all trade updates for a specific user.

```javascript
import { gql } from '@apollo/client'

const WATCH_TRADES = gql`
  subscription WatchTrades($trader: String!) {
    perpTrades(where: { trader: $trader }) {
      id
      isOpen
      isLong
      leverage
      collateralAmount
      openPrice
      closePrice
      sl
      tp
      perpBorrowing {
        baseToken {
          symbol
          logoUrl
        }
        marketId
      }
      state {
        pnlCollateral
        pnlPct
        liquidationPrice
        positionValue
        borrowingFeeCollateral
      }
      openBlock {
        block_ts
      }
    }
  }
`

// Apollo Client usage
const subscription = client.subscribe({
  query: WATCH_TRADES,
  variables: { trader: 'nibi1abc...' }
}).subscribe({
  next: ({ data }) => {
    console.log('Trades updated:', data.perpTrades)
    
    data.perpTrades.forEach(trade => {
      const pnlPct = (trade.state.pnlPct * 100).toFixed(2)
      const status = trade.isOpen ? 'OPEN' : 'CLOSED'
      
      console.log(`[${status}] ${trade.perpBorrowing.baseToken.symbol} ${trade.isLong ? 'LONG' : 'SHORT'} ${trade.leverage}x`)
      console.log(`  PnL: ${pnlPct}%`)
      console.log(`  Liquidation: $${trade.state.liquidationPrice.toFixed(2)}`)
    })
  },
  error: (error) => {
    console.error('Subscription error:', error)
  }
})

// Cleanup
// subscription.unsubscribe()
```

### Example 2: Watch Trade Events

Subscribe to trade history events (opens, closes, liquidations, etc).

```javascript
const WATCH_TRADE_EVENTS = gql`
  subscription WatchTradeEvents($trader: String!) {
    perpTradeHistory(where: { trader: $trader }) {
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
        perpBorrowing {
          baseToken {
            symbol
          }
          collateralToken {
            symbol
            decimals
          }
        }
        isLong
        leverage
        openPrice
        closePrice
      }
    }
  }
`

// Usage
const subscription = client.subscribe({
  query: WATCH_TRADE_EVENTS,
  variables: { trader: 'nibi1abc...' }
}).subscribe({
  next: ({ data }) => {
    const events = data.perpTradeHistory
    
    events.forEach(event => {
      const timestamp = new Date(event.block.block_ts).toLocaleTimeString()
      const token = event.trade?.perpBorrowing.baseToken.symbol
      
      console.log(`[${timestamp}] ${event.tradeChangeType}`)
      
      if (event.realizedPnlPct !== null) {
        const pnlPct = (event.realizedPnlPct * 100).toFixed(2)
        const decimals = event.trade.perpBorrowing.collateralToken.decimals
        const pnl = event.realizedPnlCollateral / (10 ** decimals)
        
        console.log(`  ${token} - Realized PnL: ${pnl.toFixed(2)} (${pnlPct}%)`)
      }
    })
    
    // Show notification for important events
    events.forEach(event => {
      if (event.tradeChangeType === 'position_liquidated') {
        showNotification('⚠️ Position Liquidated!', {
          body: `Your ${event.trade?.perpBorrowing.baseToken.symbol} position was liquidated`
        })
      }
      
      if (event.tradeChangeType === 'position_closed_tp') {
        showNotification('✅ Take Profit Hit!', {
          body: `TP triggered on ${event.trade?.perpBorrowing.baseToken.symbol}`
        })
      }
    })
  }
})
```

### Example 3: Watch Market Borrowing Rates

Subscribe to real-time borrowing rate updates for a specific market.

```javascript
const WATCH_MARKET = gql`
  subscription WatchMarket($collateralId: Int!, $marketId: Int!) {
    perpBorrowing(collateralId: $collateralId, marketId: $marketId) {
      marketId
      baseToken {
        symbol
      }
      price
      oiLong
      oiShort
      oiMax
      feesPerHourLong
      feesPerHourShort
      openFeePct
      closeFeePct
    }
  }
`

// Usage
const subscription = client.subscribe({
  query: WATCH_MARKET,
  variables: { collateralId: 1, marketId: 1 }
}).subscribe({
  next: ({ data }) => {
    const market = data.perpBorrowing
    
    // Calculate funding rate APR
    const fundingAprLong = market.feesPerHourLong * 24 * 365 * 100
    const fundingAprShort = market.feesPerHourShort * 24 * 365 * 100
    
    // Calculate OI utilization
    const oiTotal = market.oiLong + market.oiShort
    const utilization = (oiTotal / market.oiMax) * 100
    
    console.log(`${market.baseToken.symbol} Market Update`)
    console.log(`Price: $${market.price.toFixed(2)}`)
    console.log(`OI: ${market.oiLong} L / ${market.oiShort} S`)
    console.log(`Utilization: ${utilization.toFixed(1)}%`)
    console.log(`Funding APR - Long: ${fundingAprLong.toFixed(2)}% | Short: ${fundingAprShort.toFixed(2)}%`)
    
    // Alert on high utilization
    if (utilization > 90) {
      console.warn('⚠️  High OI utilization!')
    }
  }
})
```

### Example 4: Watch All Markets

Subscribe to updates for all available markets.

```javascript
const WATCH_ALL_MARKETS = gql`
  subscription WatchAllMarkets {
    perpBorrowings {
      marketId
      baseToken {
        symbol
        name
      }
      collateralToken {
        symbol
      }
      visible
    }
  }
`

// Usage
const subscription = client.subscribe({
  query: WATCH_ALL_MARKETS
}).subscribe({
  next: ({ data }) => {
    const markets = data.perpBorrowings.filter(m => m.visible)
    console.log(`Active markets: ${markets.length}`)
    
    // Update market selector UI
    updateMarketList(markets)
  }
})
```

---

## LP Subscriptions

### Example 5: Watch Vault Metrics

Subscribe to real-time vault updates (TVL, APY, share price).

```javascript
const WATCH_VAULTS = gql`
  subscription WatchVaults {
    lpVaults {
      address
      collateralToken {
        symbol
        name
        decimals
      }
      tvl
      sharePrice
      apy
      availableAssets
      currentEpoch
      revenueInfo {
        NetProfit
        TraderLosses
        Liabilities
      }
    }
  }
`

// Usage
const subscription = client.subscribe({
  query: WATCH_VAULTS
}).subscribe({
  next: ({ data }) => {
    data.lpVaults.forEach(vault => {
      const decimals = vault.collateralToken.decimals
      const tvl = vault.tvl / (10 ** decimals)
      const available = vault.availableAssets / (10 ** decimals)
      const utilization = ((tvl - available) / tvl) * 100
      
      console.log(`${vault.collateralToken.symbol} Vault`)
      console.log(`  TVL: ${tvl.toLocaleString()}`)
      console.log(`  APY: ${vault.apy?.toFixed(2) || 'N/A'}%`)
      console.log(`  Share Price: ${vault.sharePrice.toFixed(6)}`)
      console.log(`  Utilization: ${utilization.toFixed(1)}%`)
      console.log(`  Net Profit: ${vault.revenueInfo.NetProfit}`)
    })
    
    // Update dashboard
    updateVaultDashboard(data.lpVaults)
  }
})
```

### Example 6: Watch User LP Positions

Subscribe to user's LP deposit updates.

```javascript
const WATCH_USER_LP = gql`
  subscription WatchUserLP($user: String!) {
    lpDeposits(where: { depositor: $user }) {
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
      }
    }
  }
`

// Usage
const subscription = client.subscribe({
  query: WATCH_USER_LP,
  variables: { user: 'nibi1abc...' }
}).subscribe({
  next: ({ data }) => {
    let totalValue = 0
    
    data.lpDeposits.forEach(deposit => {
      const decimals = deposit.vault.collateralToken.decimals
      const value = (deposit.shares * deposit.vault.sharePrice) / (10 ** decimals)
      totalValue += value
      
      console.log(`${deposit.vault.collateralToken.symbol}: ${value.toFixed(2)}`)
    })
    
    console.log(`Total LP Value: ${totalValue.toFixed(2)}`)
    
    // Update portfolio UI
    updatePortfolioValue(totalValue)
  }
})
```

### Example 7: Watch Deposit Events

Subscribe to deposit/withdrawal events.

```javascript
const WATCH_DEPOSIT_EVENTS = gql`
  subscription WatchDepositEvents($user: String!, $vault: String!) {
    lpDepositHistory(where: { depositor: $user, vault: $vault }) {
      id
      amount
      shares
      isWithdraw
      block {
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
`

// Usage
const subscription = client.subscribe({
  query: WATCH_DEPOSIT_EVENTS,
  variables: { 
    user: 'nibi1abc...',
    vault: 'nibi1vault...'
  }
}).subscribe({
  next: ({ data }) => {
    data.lpDepositHistory.forEach(event => {
      const decimals = event.vault.collateralToken.decimals
      const amount = event.amount / (10 ** decimals)
      const action = event.isWithdraw ? 'Withdrew' : 'Deposited'
      const timestamp = new Date(event.block.block_ts).toLocaleString()
      
      console.log(`[${timestamp}] ${action} ${amount.toFixed(2)} ${event.vault.collateralToken.symbol}`)
      
      // Show notification
      showNotification(`LP ${action}`, {
        body: `${amount.toFixed(2)} ${event.vault.collateralToken.symbol}`,
        timestamp: event.block.block_ts
      })
    })
  }
})
```

### Example 8: Watch Withdrawal Requests

Subscribe to withdrawal request updates.

```javascript
const WATCH_WITHDRAWALS = gql`
  subscription WatchWithdrawals($user: String!, $vault: String!) {
    lpWithdrawRequests(where: { depositor: $user, vault: $vault }) {
      shares
      status
      unlockEpoch
      autoRedeem
      vault {
        currentEpoch
        sharePrice
        collateralToken {
          symbol
          decimals
        }
      }
    }
  }
`

// Usage
const subscription = client.subscribe({
  query: WATCH_WITHDRAWALS,
  variables: {
    user: 'nibi1abc...',
    vault: 'nibi1vault...'
  }
}).subscribe({
  next: ({ data }) => {
    data.lpWithdrawRequests.forEach(request => {
      const isReady = request.vault.currentEpoch >= request.unlockEpoch
      const epochsRemaining = Math.max(0, request.unlockEpoch - request.vault.currentEpoch)
      
      const decimals = request.vault.collateralToken.decimals
      const estimatedValue = (request.shares * request.vault.sharePrice) / (10 ** decimals)
      
      console.log(`Withdrawal Request`)
      console.log(`  Status: ${isReady ? 'Ready ✅' : `${epochsRemaining} epochs remaining`}`)
      console.log(`  Estimated Value: ${estimatedValue.toFixed(2)} ${request.vault.collateralToken.symbol}`)
      console.log(`  Auto-redeem: ${request.autoRedeem}`)
      
      // Notify when ready
      if (isReady && !notifiedAlready) {
        showNotification('✅ Withdrawal Ready!', {
          body: `Your withdrawal of ${estimatedValue.toFixed(2)} ${request.vault.collateralToken.symbol} is ready`
        })
        notifiedAlready = true
      }
    })
  }
})
```

---

## Oracle Subscriptions

### Example 9: Watch Token Prices

Subscribe to real-time price updates.

```javascript
const WATCH_PRICES = gql`
  subscription WatchPrices {
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
`

// Usage
const priceCache = new Map()

const subscription = client.subscribe({
  query: WATCH_PRICES
}).subscribe({
  next: ({ data }) => {
    data.tokenPricesUsd.forEach(item => {
      const oldPrice = priceCache.get(item.token.symbol)
      const newPrice = item.priceUsd
      
      // Calculate price change
      if (oldPrice) {
        const change = ((newPrice - oldPrice) / oldPrice) * 100
        const arrow = change > 0 ? '↑' : '↓'
        console.log(`${item.token.symbol}: $${newPrice.toFixed(2)} ${arrow} ${Math.abs(change).toFixed(2)}%`)
      } else {
        console.log(`${item.token.symbol}: $${newPrice.toFixed(2)}`)
      }
      
      priceCache.set(item.token.symbol, newPrice)
    })
    
    // Update price ticker UI
    updatePriceTicker(data.tokenPricesUsd)
  }
})
```

### Example 10: Watch Specific Token Price

```javascript
const WATCH_TOKEN_PRICE = gql`
  subscription WatchTokenPrice($tokenId: Int!) {
    tokenPricesUsd(where: { tokenId: $tokenId }) {
      token {
        symbol
      }
      priceUsd
      lastUpdatedBlock {
        block_ts
      }
    }
  }
`

// Usage with price alerts
const subscription = client.subscribe({
  query: WATCH_TOKEN_PRICE,
  variables: { tokenId: 1 } // BTC
}).subscribe({
  next: ({ data }) => {
    const priceData = data.tokenPricesUsd[0]
    const price = priceData.priceUsd
    
    console.log(`BTC: $${price.toFixed(2)}`)
    
    // Price alerts
    if (price > 50000) {
      showNotification('🚀 BTC Above $50k!', {
        body: `Current price: $${price.toFixed(2)}`
      })
    }
    
    if (price < 45000) {
      showNotification('📉 BTC Below $45k', {
        body: `Current price: $${price.toFixed(2)}`
      })
    }
  }
})
```

### Example 11: Watch User Balances

```javascript
const WATCH_BALANCES = gql`
  subscription WatchBalances($user: String!) {
    userBalances(where: { user: $user }) {
      amount
      token_info {
        symbol
        name
        decimals
        type
        logo
      }
    }
  }
`

// Usage
const subscription = client.subscribe({
  query: WATCH_BALANCES,
  variables: { user: 'nibi1abc...' }
}).subscribe({
  next: ({ data }) => {
    console.log('Balance Update:')
    
    data.userBalances.forEach(balance => {
      const amount = parseFloat(balance.amount) / (10 ** balance.token_info.decimals)
      console.log(`  ${balance.token_info.symbol}: ${amount.toFixed(4)}`)
    })
    
    // Update wallet UI
    updateWalletBalances(data.userBalances)
  }
})
```

---

## Advanced Patterns

### Example 12: Multiple Subscriptions Manager

```javascript
class SubscriptionManager {
  constructor(client) {
    this.client = client
    this.subscriptions = new Map()
  }
  
  subscribe(name, query, variables, callback) {
    // Unsubscribe existing if any
    this.unsubscribe(name)
    
    const subscription = this.client.subscribe({
      query,
      variables
    }).subscribe({
      next: callback,
      error: (error) => {
        console.error(`Subscription ${name} error:`, error)
        // Attempt reconnection
        setTimeout(() => {
          this.subscribe(name, query, variables, callback)
        }, 5000)
      }
    })
    
    this.subscriptions.set(name, subscription)
  }
  
  unsubscribe(name) {
    const sub = this.subscriptions.get(name)
    if (sub) {
      sub.unsubscribe()
      this.subscriptions.delete(name)
    }
  }
  
  unsubscribeAll() {
    this.subscriptions.forEach(sub => sub.unsubscribe())
    this.subscriptions.clear()
  }
}

// Usage
const manager = new SubscriptionManager(client)

manager.subscribe('trades', WATCH_TRADES, { trader: 'nibi1abc...' }, (data) => {
  updateTradesUI(data.perpTrades)
})

manager.subscribe('prices', WATCH_PRICES, {}, (data) => {
  updatePricesUI(data.tokenPricesUsd)
})

// Cleanup on component unmount
// manager.unsubscribeAll()
```

### Example 13: Subscription with Reconnection Logic

```javascript
function createResilientSubscription(query, variables, onData) {
  let subscription = null
  let reconnectAttempts = 0
  const maxReconnectAttempts = 10
  
  function connect() {
    subscription = client.subscribe({
      query,
      variables
    }).subscribe({
      next: (data) => {
        reconnectAttempts = 0 // Reset on successful data
        onData(data)
      },
      error: (error) => {
        console.error('Subscription error:', error)
        
        if (reconnectAttempts < maxReconnectAttempts) {
          reconnectAttempts++
          const delay = Math.min(1000 * Math.pow(2, reconnectAttempts), 30000)
          console.log(`Reconnecting in ${delay}ms (attempt ${reconnectAttempts})...`)
          
          setTimeout(connect, delay)
        } else {
          console.error('Max reconnection attempts reached')
        }
      },
      complete: () => {
        console.log('Subscription completed')
      }
    })
  }
  
  connect()
  
  return {
    unsubscribe: () => {
      if (subscription) {
        subscription.unsubscribe()
      }
    }
  }
}

// Usage
const sub = createResilientSubscription(
  WATCH_TRADES,
  { trader: 'nibi1abc...' },
  (data) => {
    console.log('Received trade update:', data.perpTrades)
  }
)

// Cleanup
// sub.unsubscribe()
```

---

## Best Practices

### 1. Always Clean Up Subscriptions

```javascript
useEffect(() => {
  const subscription = client.subscribe({
    query: WATCH_TRADES,
    variables: { trader }
  }).subscribe({
    next: (data) => setTrades(data.perpTrades)
  })
  
  // Cleanup function
  return () => {
    subscription.unsubscribe()
  }
}, [trader])
```

### 2. Handle Connection States

```javascript
const [connectionState, setConnectionState] = useState('connecting')

const subscription = client.subscribe({
  query: WATCH_PRICES
}).subscribe({
  next: (data) => {
    setConnectionState('connected')
    updatePrices(data)
  },
  error: (error) => {
    setConnectionState('error')
    console.error(error)
  }
})

// Show connection status in UI
if (connectionState === 'connecting') {
  return <div>Connecting to real-time feed...</div>
}
```

### 3. Debounce Rapid Updates

```javascript
import { debounce } from 'lodash'

const debouncedUpdate = debounce((data) => {
  updateUI(data)
}, 100)

const subscription = client.subscribe({
  query: WATCH_PRICES
}).subscribe({
  next: (data) => {
    debouncedUpdate(data.tokenPricesUsd)
  }
})
```

### 4. Combine with Queries for Initial Data

```javascript
// Fetch initial data with query
const { data: initialData } = await client.query({
  query: GET_TRADES,
  variables: { trader }
})

setTrades(initialData.perp.trades)

// Then subscribe to updates
const subscription = client.subscribe({
  query: WATCH_TRADES,
  variables: { trader }
}).subscribe({
  next: (data) => {
    setTrades(data.perpTrades)
  }
})
```

---

**Next**: [Client Setup Guide](./client-setup.md) | [Previous](./examples-queries.md) | [Back to Introduction](./README.md)
