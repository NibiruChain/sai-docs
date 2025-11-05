# Client Setup Guides

Set up GraphQL clients in various languages to interact with Sai Keeper API.

## Table of Contents

- [JavaScript/TypeScript](#javascripttypescript)
  - [Apollo Client](#apollo-client)
  - [urql](#urql)
  - [GraphQL Request](#graphql-request)
- [Python](#python)
- [Rust](#rust)
- [Go](#go)

---

## JavaScript/TypeScript

### Apollo Client

Apollo Client is the most popular GraphQL client for JavaScript applications.

#### Installation

```bash
npm install @apollo/client graphql
# For subscriptions
npm install graphql-ws
```

#### Basic Setup (Queries Only)

```typescript
import { ApolloClient, InMemoryCache, HttpLink, gql } from '@apollo/client'

const client = new ApolloClient({
  link: new HttpLink({
    uri: 'https://sai-keeper.testnet-2.nibiru.fi/graphql'
  }),
  cache: new InMemoryCache()
})

// Example query
const GET_PRICES = gql`
  query GetPrices {
    oracle {
      tokenPricesUsd(limit: 10) {
        token { symbol }
        priceUsd
      }
    }
  }
`

async function fetchPrices() {
  const { data, error } = await client.query({
    query: GET_PRICES
  })
  
  if (error) {
    console.error('Error:', error)
    return
  }
  
  console.log('Prices:', data.oracle.tokenPricesUsd)
}

fetchPrices()
```

#### Full Setup (With Subscriptions)

```typescript
import {
  ApolloClient,
  InMemoryCache,
  HttpLink,
  split,
  gql
} from '@apollo/client'
import { GraphQLWsLink } from '@apollo/client/link/subscriptions'
import { getMainDefinition } from '@apollo/client/utilities'
import { createClient } from 'graphql-ws'

// HTTP link for queries and mutations
const httpLink = new HttpLink({
  uri: 'https://sai-keeper.testnet-2.nibiru.fi/graphql'
})

// WebSocket link for subscriptions
const wsLink = new GraphQLWsLink(
  createClient({
    url: 'wss://sai-keeper.testnet-2.nibiru.fi/graphql',
    connectionParams: {
      // Add authentication if needed
      // authToken: 'your-auth-token'
    },
    retryAttempts: 5,
    shouldRetry: () => true,
    on: {
      connected: () => console.log('WebSocket connected'),
      closed: () => console.log('WebSocket closed'),
      error: (error) => console.error('WebSocket error:', error)
    }
  })
)

// Split traffic between HTTP and WebSocket
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
  cache: new InMemoryCache(),
  defaultOptions: {
    watchQuery: {
      fetchPolicy: 'cache-and-network'
    }
  }
})

// Example subscription
const WATCH_PRICES = gql`
  subscription WatchPrices {
    tokenPricesUsd {
      token { symbol }
      priceUsd
    }
  }
`

const subscription = client.subscribe({
  query: WATCH_PRICES
}).subscribe({
  next: ({ data }) => {
    console.log('Price update:', data.tokenPricesUsd)
  },
  error: (error) => {
    console.error('Subscription error:', error)
  }
})

// Clean up
// subscription.unsubscribe()

export default client
```

#### React Integration

```typescript
import { ApolloProvider, useQuery, useSubscription, gql } from '@apollo/client'
import client from './apollo-client'

// Wrap your app
function App() {
  return (
    <ApolloProvider client={client}>
      <Dashboard />
    </ApolloProvider>
  )
}

// Use queries in components
function Dashboard() {
  const GET_TRADES = gql`
    query GetTrades($trader: String!) {
      perp {
        trades(where: { trader: $trader, isOpen: true }) {
          id
          isLong
          leverage
          state { pnlPct }
        }
      }
    }
  `
  
  const { loading, error, data } = useQuery(GET_TRADES, {
    variables: { trader: 'nibi1abc...' }
  })
  
  if (loading) return <div>Loading...</div>
  if (error) return <div>Error: {error.message}</div>
  
  return (
    <div>
      {data.perp.trades.map(trade => (
        <div key={trade.id}>
          Trade #{trade.id} - PnL: {(trade.state.pnlPct * 100).toFixed(2)}%
        </div>
      ))}
    </div>
  )
}

// Use subscriptions in components
function PriceTicker() {
  const WATCH_PRICES = gql`
    subscription {
      tokenPricesUsd {
        token { symbol }
        priceUsd
      }
    }
  `
  
  const { data, loading } = useSubscription(WATCH_PRICES)
  
  if (loading) return <div>Connecting...</div>
  
  return (
    <div>
      {data.tokenPricesUsd.map(item => (
        <div key={item.token.symbol}>
          {item.token.symbol}: ${item.priceUsd.toFixed(2)}
        </div>
      ))}
    </div>
  )
}
```

---

### urql

urql is a lightweight alternative to Apollo Client.

#### Installation

```bash
npm install urql graphql
# For subscriptions
npm install graphql-ws
```

#### Setup

```typescript
import { createClient, fetchExchange, subscriptionExchange } from 'urql'
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

export default client
```

#### React Integration

```typescript
import { Provider, useQuery, useSubscription } from 'urql'
import client from './urql-client'

function App() {
  return (
    <Provider value={client}>
      <Dashboard />
    </Provider>
  )
}

function Dashboard() {
  const QUERY = `
    query GetTrades($trader: String!) {
      perp {
        trades(where: { trader: $trader, isOpen: true }) {
          id
          isLong
          leverage
        }
      }
    }
  `
  
  const [result] = useQuery({
    query: QUERY,
    variables: { trader: 'nibi1abc...' }
  })
  
  const { data, fetching, error } = result
  
  if (fetching) return <div>Loading...</div>
  if (error) return <div>Error: {error.message}</div>
  
  return (
    <div>
      {data.perp.trades.map(trade => (
        <div key={trade.id}>Trade #{trade.id}</div>
      ))}
    </div>
  )
}
```

---

### GraphQL Request

Lightweight library for simple queries (no caching or subscriptions).

#### Installation

```bash
npm install graphql-request graphql
```

#### Usage

```typescript
import { GraphQLClient, gql } from 'graphql-request'

const client = new GraphQLClient(
  'https://sai-keeper.testnet-2.nibiru.fi/graphql'
)

const GET_TRADES = gql`
  query GetTrades($trader: String!) {
    perp {
      trades(where: { trader: $trader, isOpen: true }) {
        id
        isLong
        leverage
      }
    }
  }
`

async function fetchTrades(trader: string) {
  try {
    const data = await client.request(GET_TRADES, { trader })
    console.log('Trades:', data.perp.trades)
    return data.perp.trades
  } catch (error) {
    console.error('Error fetching trades:', error)
    throw error
  }
}

fetchTrades('nibi1abc...')
```

---

## Python

### gql Library

Full-featured GraphQL client for Python.

#### Installation

```bash
pip install gql[all]
```

#### Setup

```python
from gql import gql, Client
from gql.transport.aiohttp import AIOHTTPTransport
from gql.transport.websockets import WebsocketsTransport
import asyncio

# HTTP Transport for queries
http_transport = AIOHTTPTransport(
    url="https://sai-keeper.testnet-2.nibiru.fi/graphql"
)

# Create client
client = Client(
    transport=http_transport,
    fetch_schema_from_transport=True
)

# Example query
async def get_trades(trader_address):
    query = gql("""
        query GetTrades($trader: String!) {
            perp {
                trades(where: { trader: $trader, isOpen: true }) {
                    id
                    isLong
                    leverage
                    state {
                        pnlPct
                        liquidationPrice
                    }
                    perpBorrowing {
                        baseToken {
                            symbol
                        }
                    }
                }
            }
        }
    """)
    
    params = {"trader": trader_address}
    
    async with Client(transport=http_transport) as session:
        result = await session.execute(query, variable_values=params)
        return result['perp']['trades']

# Run the query
trades = asyncio.run(get_trades("nibi1abc..."))
for trade in trades:
    pnl_pct = trade['state']['pnlPct'] * 100
    print(f"Trade #{trade['id']}: {trade['perpBorrowing']['baseToken']['symbol']} {trade['leverage']}x - PnL: {pnl_pct:.2f}%")
```

#### With Subscriptions

```python
from gql import gql, Client
from gql.transport.websockets import WebsocketsTransport
import asyncio

# WebSocket transport for subscriptions
ws_transport = WebsocketsTransport(
    url="wss://sai-keeper.testnet-2.nibiru.fi/graphql"
)

async def watch_prices():
    subscription = gql("""
        subscription WatchPrices {
            tokenPricesUsd {
                token {
                    symbol
                }
                priceUsd
            }
        }
    """)
    
    async with Client(transport=ws_transport) as session:
        async for result in session.subscribe(subscription):
            prices = result['tokenPricesUsd']
            for item in prices:
                print(f"{item['token']['symbol']}: ${item['priceUsd']:.2f}")

# Run subscription
asyncio.run(watch_prices())
```

#### Synchronous Version

```python
from gql import gql, Client
from gql.transport.requests import RequestsHTTPTransport

# Synchronous transport
transport = RequestsHTTPTransport(
    url="https://sai-keeper.testnet-2.nibiru.fi/graphql",
    verify=True,
    retries=3
)

client = Client(transport=transport, fetch_schema_from_transport=True)

# Synchronous query
def get_token_prices():
    query = gql("""
        query GetPrices {
            oracle {
                tokenPricesUsd(limit: 10) {
                    token {
                        symbol
                    }
                    priceUsd
                }
            }
        }
    """)
    
    result = client.execute(query)
    return result['oracle']['tokenPricesUsd']

prices = get_token_prices()
for item in prices:
    print(f"{item['token']['symbol']}: ${item['priceUsd']:.2f}")
```

---

## Rust

### graphql_client

Type-safe GraphQL client for Rust.

#### Installation

Add to `Cargo.toml`:

```toml
[dependencies]
graphql_client = "0.13"
reqwest = { version = "0.11", features = ["json"] }
tokio = { version = "1", features = ["full"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
```

#### Setup

```rust
use graphql_client::{GraphQLQuery, Response};
use reqwest;

// Define the query
#[derive(GraphQLQuery)]
#[graphql(
    schema_path = "schema.graphql",
    query_path = "queries/get_trades.graphql",
    response_derives = "Debug"
)]
pub struct GetTrades;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let client = reqwest::Client::new();
    
    let variables = get_trades::Variables {
        trader: "nibi1abc...".to_string(),
    };
    
    let request_body = GetTrades::build_query(variables);
    
    let res = client
        .post("https://sai-keeper.testnet-2.nibiru.fi/graphql")
        .json(&request_body)
        .send()
        .await?;
    
    let response_body: Response<get_trades::ResponseData> = res.json().await?;
    
    if let Some(data) = response_body.data {
        for trade in data.perp.trades {
            println!("Trade #{}: {}x leverage", trade.id, trade.leverage);
        }
    }
    
    if let Some(errors) = response_body.errors {
        for error in errors {
            eprintln!("Error: {}", error.message);
        }
    }
    
    Ok(())
}
```

#### Without Code Generation

```rust
use reqwest;
use serde::{Deserialize, Serialize};
use serde_json::json;

#[derive(Debug, Serialize, Deserialize)]
struct GraphQLRequest {
    query: String,
    variables: serde_json::Value,
}

#[derive(Debug, Deserialize)]
struct GraphQLResponse<T> {
    data: Option<T>,
    errors: Option<Vec<GraphQLError>>,
}

#[derive(Debug, Deserialize)]
struct GraphQLError {
    message: String,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let client = reqwest::Client::new();
    
    let query = r#"
        query GetTrades($trader: String!) {
            perp {
                trades(where: { trader: $trader, isOpen: true }) {
                    id
                    isLong
                    leverage
                }
            }
        }
    "#;
    
    let variables = json!({
        "trader": "nibi1abc..."
    });
    
    let request = GraphQLRequest {
        query: query.to_string(),
        variables,
    };
    
    let response = client
        .post("https://sai-keeper.testnet-2.nibiru.fi/graphql")
        .json(&request)
        .send()
        .await?
        .json::<serde_json::Value>()
        .await?;
    
    println!("Response: {:#?}", response);
    
    Ok(())
}
```

---

## Go

### graphql Package

#### Installation

```bash
go get github.com/machinebox/graphql
```

#### Setup

```go
package main

import (
    "context"
    "fmt"
    "log"
    
    "github.com/machinebox/graphql"
)

type Trade struct {
    ID       int     `json:"id"`
    IsLong   bool    `json:"isLong"`
    Leverage float64 `json:"leverage"`
}

type PerpResponse struct {
    Trades []Trade `json:"trades"`
}

type Response struct {
    Perp PerpResponse `json:"perp"`
}

func main() {
    // Create client
    client := graphql.NewClient("https://sai-keeper.testnet-2.nibiru.fi/graphql")
    
    // Define query
    req := graphql.NewRequest(`
        query GetTrades($trader: String!) {
            perp {
                trades(where: { trader: $trader, isOpen: true }) {
                    id
                    isLong
                    leverage
                }
            }
        }
    `)
    
    // Set variables
    req.Var("trader", "nibi1abc...")
    
    // Execute query
    ctx := context.Background()
    var response Response
    
    if err := client.Run(ctx, req, &response); err != nil {
        log.Fatal(err)
    }
    
    // Process response
    for _, trade := range response.Perp.Trades {
        fmt.Printf("Trade #%d: %fx leverage\n", trade.ID, trade.Leverage)
    }
}
```

#### With Error Handling

```go
package main

import (
    "context"
    "fmt"
    "log"
    "time"
    
    "github.com/machinebox/graphql"
)

func fetchTrades(trader string) error {
    client := graphql.NewClient("https://sai-keeper.testnet-2.nibiru.fi/graphql")
    
    req := graphql.NewRequest(`
        query GetTrades($trader: String!) {
            perp {
                trades(where: { trader: $trader, isOpen: true }) {
                    id
                    isLong
                    leverage
                }
            }
        }
    `)
    
    req.Var("trader", trader)
    
    // Add timeout
    ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
    defer cancel()
    
    var response map[string]interface{}
    
    if err := client.Run(ctx, req, &response); err != nil {
        return fmt.Errorf("query failed: %w", err)
    }
    
    // Check for data
    perp, ok := response["perp"].(map[string]interface{})
    if !ok {
        return fmt.Errorf("invalid response structure")
    }
    
    trades, ok := perp["trades"].([]interface{})
    if !ok {
        return fmt.Errorf("invalid trades structure")
    }
    
    fmt.Printf("Found %d open trades\n", len(trades))
    
    return nil
}

func main() {
    if err := fetchTrades("nibi1abc..."); err != nil {
        log.Fatal(err)
    }
}
```

---

## Environment Variables

For all languages, consider using environment variables for configuration:

```bash
# .env file
SAI_KEEPER_HTTP_URL=https://sai-keeper.testnet-2.nibiru.fi/graphql
SAI_KEEPER_WS_URL=wss://sai-keeper.testnet-2.nibiru.fi/graphql
```

**JavaScript:**

```javascript
const httpUrl = process.env.SAI_KEEPER_HTTP_URL
const wsUrl = process.env.SAI_KEEPER_WS_URL
```

**Python:**

```python
import os
http_url = os.getenv('SAI_KEEPER_HTTP_URL')
ws_url = os.getenv('SAI_KEEPER_WS_URL')
```

**Rust:**

```rust
use std::env;
let http_url = env::var("SAI_KEEPER_HTTP_URL").unwrap();
```

**Go:**

```go
import "os"
httpUrl := os.Getenv("SAI_KEEPER_HTTP_URL")
```

