# LP API Reference

Query and subscribe to liquidity pool data including vaults, deposits, withdrawals, and revenue tracking.

## Table of Contents

- [LP API Reference](#lp-api-reference)
  - [Table of Contents](#table-of-contents)
  - [Queries](#queries)
    - [vaults](#vaults)
    - [deposits](#deposits)
    - [depositHistory](#deposithistory)
    - [withdrawRequests](#withdrawrequests)
    - [epochDurationDays](#epochdurationdays)
    - [epochDurationHours](#epochdurationhours)
  - [Subscriptions](#subscriptions)
    - [lpVaults](#lpvaults)
    - [lpDeposits](#lpdeposits)
    - [lpDepositHistory](#lpdeposithistory)
    - [lpWithdrawRequests](#lpwithdrawrequests)
  - [Types Reference](#types-reference)
    - [LpVault](#lpvault)
    - [LpDeposit](#lpdeposit)
    - [LpDepositHistoryItem](#lpdeposithistoryitem)
    - [LpWithdrawRequest](#lpwithdrawrequest)
    - [RevenueInfo](#revenueinfo)
  - [Calculations](#calculations)
    - [Deposit Value](#deposit-value)
    - [Estimated Withdrawal Value](#estimated-withdrawal-value)
    - [Time Until Withdrawal](#time-until-withdrawal)
    - [APY Calculation](#apy-calculation)

## Queries

### vaults

List all liquidity vaults with their metrics.

**Signature:**

```graphql
vaults(
  where: LpVaultsFilter
  limit: Int
  offset: Int
  order_by: LpVaultsOrder
  order_desc: Boolean
): [LpVault!]!
```

**Parameters:**

- `where`: Filter object (optional)
  - `address`: Filter by vault address
- `limit`: Max results
- `offset`: Skip results
- `order_by`: Sort by `address`
- `order_desc`: Sort descending

**Returns:** Array of `LpVault` objects

**Example - Get All Vaults:**

```graphql
query GetAllVaults {
  lp {
    vaults {
      address
      collateralDenom
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
      sharesERC20
      collateralERC20
      revenueInfo {
        RevenueCumulative
        NetProfit
        TraderLosses
        ClosedPnl
        CurrentEpochPositiveOpenPnl
        Liabilities
        Rewards
      }
    }
  }
}
```

**Example - Get Specific Vault:**

```graphql
query GetVault($address: String!) {
  lp {
    vaults(where: { address: $address }) {
      address
      tvl
      sharePrice
      apy
      availableAssets
    }
  }
}
```

**Key Fields Explained:**

- `tvl`: Total value locked in the vault
- `sharePrice`: Current value of one vault share
- `apy`: Annual percentage yield (annualized return)
- `availableAssets`: Assets not currently in open positions
- `currentEpoch`: Current epoch number
- `epochStart`: Unix timestamp when current epoch started

**Use Cases:**

- Display vault list with metrics
- Compare vault performance
- Show available liquidity
- Calculate potential returns

---

### deposits

Get user deposits in vaults.

**Signature:**

```graphql
deposits(
  where: LpDepositsFilter
  limit: Int
  offset: Int
  order_by: LpDepositsOrder
  order_desc: Boolean
): [LpDeposit!]!
```

**Parameters:**

- `where`: Filter object (optional)
  - `depositor`: Filter by depositor address
  - `vault`: Filter by vault address
- `limit`: Max results
- `offset`: Skip results
- `order_by`: Sort by `depositor` or `vault`
- `order_desc`: Sort descending

**Returns:** Array of `LpDeposit` objects

**Example - Get User Deposits:**

```graphql
query GetUserDeposits($user: String!) {
  lp {
    deposits(where: { depositor: $user }) {
      depositor
      shares
      vault {
        address
        collateralToken { symbol }
        sharePrice
        tvl
        apy
      }
    }
  }
}
```

**Example - Calculate Deposit Value:**

```graphql
query CalculateDepositValue($user: String!) {
  lp {
    deposits(where: { depositor: $user }) {
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
}
```

To calculate value:

```javascript
const value = (shares * sharePrice) / (10 ** decimals)
```

**Use Cases:**

- Display user's LP positions
- Calculate total deposited value
- Track share ownership
- Portfolio management

---

### depositHistory

Get historical deposit and withdrawal events.

**Signature:**

```graphql
depositHistory(
  where: LpDepositHistoryFilter
  limit: Int
  offset: Int
  order_by: LpDepositHistoryOrder
  order_desc: Boolean
): [LpDepositHistoryItem!]!
```

**Parameters:**

- `where`: Filter object (optional)
  - `depositor`: Filter by depositor address
  - `vault`: Filter by vault address
- `limit`: Max results
- `offset`: Skip results
- `order_by`: Sort by `depositor`, `sequence`, or `vault`
- `order_desc`: Sort descending

**Returns:** Array of `LpDepositHistoryItem` objects

**Example - Get Deposit History:**

```graphql
query GetDepositHistory($user: String!) {
  lp {
    depositHistory(
      where: { depositor: $user }
      order_by: sequence
      order_desc: true
      limit: 50
    ) {
      id
      depositor
      amount
      shares
      isWithdraw
      vault {
        address
        collateralToken { symbol }
      }
      block {
        block
        block_ts
      }
    }
  }
}
```

**Example - Filter Vault History:**

```graphql
query GetVaultHistory($vaultAddress: String!) {
  lp {
    depositHistory(
      where: { vault: $vaultAddress }
      order_by: sequence
      order_desc: true
      limit: 100
    ) {
      depositor
      amount
      shares
      isWithdraw
      block { block_ts }
    }
  }
}
```

**Key Fields:**

- `isWithdraw`: `true` for withdrawals, `false` for deposits
- `amount`: Amount of collateral deposited/withdrawn
- `shares`: Shares minted (deposit) or burned (withdrawal)

**Use Cases:**

- Build activity timeline
- Track deposit/withdrawal events
- Audit vault operations
- Calculate historical returns

---

### withdrawRequests

Get pending withdrawal requests.

**Signature:**

```graphql
withdrawRequests(
  where: LpWithdrawRequestsFilter
  limit: Int
  offset: Int
  order_by: LpWithdrawRequestsOrder
  order_desc: Boolean
): [LpWithdrawRequest!]!
```

**Parameters:**

- `where`: Filter object (optional)
  - `depositor`: Filter by depositor address
  - `vault`: Filter by vault address
- `limit`: Max results
- `offset`: Skip results
- `order_by`: Sort by `depositor`, `unlock_epoch`, or `vault`
- `order_desc`: Sort descending

**Returns:** Array of `LpWithdrawRequest` objects

**Example - Get User Withdrawals:**

```graphql
query GetWithdrawRequests($user: String!) {
  lp {
    withdrawRequests(where: { depositor: $user }) {
      depositor
      shares
      status
      unlockEpoch
      autoRedeem
      vault {
        address
        collateralToken { symbol }
        currentEpoch
        sharePrice
      }
    }
  }
}
```

**Example - Check Withdrawal Status:**

```graphql
query CheckWithdrawalReady($user: String!) {
  lp {
    withdrawRequests(where: { depositor: $user }) {
      shares
      unlockEpoch
      autoRedeem
      vault {
        currentEpoch
        sharePrice
      }
    }
  }
}
```

To check if ready:

```javascript
const isReady = vault.currentEpoch >= unlockEpoch
const estimatedValue = (shares * vault.sharePrice) / (10 ** decimals)
```

**Key Fields:**

- `status`: Withdrawal request status
- `unlockEpoch`: Epoch when withdrawal becomes available
- `autoRedeem`: If `true`, automatically redeemed when unlocked

**Use Cases:**

- Display pending withdrawals
- Calculate withdrawal timing
- Show estimated withdrawal value
- Notify when ready

---

### epochDurationDays

Get epoch duration in days.

**Signature:**

```graphql
epochDurationDays: Int!
```

**Example:**

```graphql
query GetEpochDuration {
  lp {
    epochDurationDays
    epochDurationHours
  }
}
```

---

### epochDurationHours

Get epoch duration in hours.

**Signature:**

```graphql
epochDurationHours: Int!
```

---

## Subscriptions

Subscribe to real-time LP data updates.

### lpVaults

Subscribe to all vault updates.

**Signature:**

```graphql
subscription {
  lpVaults: [LpVault!]!
}
```

**Example:**

```graphql
subscription WatchVaults {
  lpVaults {
    address
    tvl
    sharePrice
    apy
    availableAssets
    currentEpoch
  }
}
```

**Use Cases:**

- Real-time TVL tracking
- Live APY updates
- Monitor available liquidity
- Track epoch changes

---

### lpDeposits

Subscribe to user deposit updates.

**Signature:**

```graphql
subscription {
  lpDeposits(where: SubLpDepositsFilter!): [LpDeposit!]!
}
```

**Example:**

```graphql
subscription WatchUserDeposits($user: String!) {
  lpDeposits(where: { depositor: $user }) {
    depositor
    shares
    vault {
      address
      sharePrice
    }
  }
}
```

**Use Cases:**

- Update user portfolio in real-time
- Track share balance changes
- Monitor position value

---

### lpDepositHistory

Subscribe to deposit/withdrawal events.

**Signature:**

```graphql
subscription {
  lpDepositHistory(where: SubLpDepositHistoryFilter!): [LpDepositHistoryItem!]!
}
```

**Example:**

```graphql
subscription WatchDepositEvents($user: String!, $vault: String!) {
  lpDepositHistory(where: { depositor: $user, vault: $vault }) {
    id
    amount
    shares
    isWithdraw
    block { block_ts }
  }
}
```

**Use Cases:**

- Real-time activity feed
- Instant transaction notifications
- Live history updates

---

### lpWithdrawRequests

Subscribe to withdrawal request updates.

**Signature:**

```graphql
subscription {
  lpWithdrawRequests(where: SubLpWithdrawRequestsFilter!): [LpWithdrawRequest!]!
}
```

**Example:**

```graphql
subscription WatchWithdrawals($user: String!, $vault: String!) {
  lpWithdrawRequests(where: { depositor: $user, vault: $vault }) {
    shares
    status
    unlockEpoch
    vault {
      currentEpoch
    }
  }
}
```

**Use Cases:**

- Notify when withdrawal ready
- Track withdrawal status
- Update UI when unlocked

---

## Types Reference

### LpVault

```graphql
type LpVault {
  address: String!
  collateralDenom: String!
  collateralToken: Token!
  collateralERC20: String!
  sharesDenom: String!
  sharesERC20: String!
  tvl: Int!
  sharePrice: Float!
  apy: Float
  availableAssets: Int!
  currentEpoch: Int!
  epochStart: Int!
  revenueInfo: RevenueInfo!
}
```

### LpDeposit

```graphql
type LpDeposit {
  depositor: String!
  shares: Int!
  vault: LpVault!
}
```

### LpDepositHistoryItem

```graphql
type LpDepositHistoryItem {
  id: Int!
  depositor: String!
  amount: Int!
  shares: Int!
  isWithdraw: Boolean!
  vault: LpVault!
  block: Block!
}
```

### LpWithdrawRequest

```graphql
type LpWithdrawRequest {
  depositor: String!
  shares: Int!
  status: String!
  unlockEpoch: Int!
  autoRedeem: Boolean!
  vault: LpVault!
}
```

### RevenueInfo

Tracks vault revenue and performance.

```graphql
type RevenueInfo {
  RevenueCumulative: Int!              # Total revenue earned
  NetProfit: Int!                       # Current net profit
  TraderLosses: Int!                    # Profits from trader losses
  ClosedPnl: Int!                       # Realized PnL from closed positions
  CurrentEpochPositiveOpenPnl: Int!     # Current epoch unrealized gains
  Liabilities: Int!                     # Current liabilities (trader profits)
  Rewards: Int!                         # Rewards received
}
```

---

## Calculations

### Deposit Value

```javascript
// Calculate current value of deposit
const depositValue = (shares * sharePrice) / (10 ** decimals)
```

### Estimated Withdrawal Value

```javascript
// For pending withdrawal
const estimatedValue = (shares * currentSharePrice) / (10 ** decimals)
```

### Time Until Withdrawal

```javascript
// Calculate epochs remaining
const epochsRemaining = unlockEpoch - currentEpoch

// Calculate time remaining (assuming epoch duration)
const hoursRemaining = epochsRemaining * epochDurationHours
```

### APY Calculation

APY is calculated from historical revenue:

```javascript
// Simplified APY calculation
const apy = (revenueInfo.NetProfit / tvl) * (365 / epochDurationDays)
```

---

**Next**: [Oracle API Reference](./api-oracle.md) | [Previous](./api-perp.md) | [Back to Introduction](./README.md)
