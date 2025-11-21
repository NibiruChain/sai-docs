# Core Concepts

Understanding these core concepts will help you effectively use the Sai Keeper API.

## Table of Contents

- [Protocol Overview](#protocol-overview)
- [Data Models](#data-models)
- [Perpetual Trading](#perpetual-trading)
- [Liquidity Pools](#liquidity-pools)
- [Oracle System](#oracle-system)
- [Fee Structure](#fee-structure)
- [Blocks and Timestamps](#blocks-and-timestamps)

## Protocol Overview

Sai Protocol is a decentralized perpetual trading platform on Nibiru Chain. The protocol is implemented in Rust and compiled into WebAssembly (Wasm) bytecode, with 5 key contracts managing all operations fully on-chain.

**Key components:**

- **Perpetual Markets**: Trade with leverage without expiration dates
- **Liquidity Vaults**: Users provide liquidity to earn yield
- **Oracle Prices**: Reliable price feeds for all tradeable assets
- **Fee System**: Transparent fee structure for all operations

## Data Models

### Hierarchy

```txt
Query/Subscription
├── perp (Perpetuals)
│   ├── trades
│   ├── tradeHistory
│   └── borrowings
├── lp (Liquidity Pools)
│   ├── vaults
│   ├── deposits
│   └── withdrawRequests
├── oracle (Price Feeds)
│   ├── tokens
│   └── tokenPricesUsd
└── fee (Fee Analytics)
    ├── feeTransactions
    ├── feeDailyStats
    └── summaries
```

## Perpetual Trading

### What is a Perpetual?

A perpetual contract (perp) is a derivative that lets you trade an asset with leverage without an expiration date. Unlike futures, perpetuals use a funding rate mechanism (called borrowing fees in Sai) to keep prices anchored to spot prices.

### Trade Lifecycle

1. **Opening**: Trader opens a position (long or short)
2. **Active**: Position accumulates borrowing fees based on market conditions
3. **Closing**: Position closed by:
   - User action
   - Take Profit (TP) trigger
   - Stop Loss (SL) trigger
   - Liquidation (if losses exceed threshold)

### Key Concepts

**Leverage**: Multiply your position size

```txt
Position Value = Collateral × Leverage
```

**Long vs Short**:

- **Long**: Profit when price increases
- **Short**: Profit when price decreases

**Open Interest (OI)**: Total value of open positions

- `oiLong`: Long positions open interest
- `oiShort`: Short positions open interest
- `oiMax`: Maximum allowed open interest

**Borrowing Fees**: Charged per hour based on OI imbalance

- Higher fees on the side with more open interest
- Helps balance long/short positions
- Converted to APR: `feesPerHour × 24 × 365 × 100`

### Trade Types

- **Market Trade** (`trade`): Instant execution at current price
- **Limit Order** (`limit`): Execute when price reaches target
- **Stop Order** (`stop`): Trigger when price hits stop level

### PnL Calculation

```txt
Unrealized PnL = Position Value × (Current Price - Open Price) / Open Price

For Long:  PnL = positive when price increases
For Short: PnL = positive when price decreases
```

**Example:**

- Long 10x position with $1,000 collateral = $10,000 position value
- Entry: $50,000 | Current: $55,000
- PnL = $10,000 × ($55,000 - $50,000) / $50,000 = $1,000 (10%)

### Liquidation

A position gets liquidated when losses approach the collateral amount:

```txt
Liquidation Price (Long) = Entry Price × (1 - 1/Leverage + Maintenance Margin)
Liquidation Price (Short) = Entry Price × (1 + 1/Leverage - Maintenance Margin)
```

**Example (10x leverage, 5% maintenance margin):**

- Long entry at $50,000 → Liquidation at ~$47,500
- Short entry at $50,000 → Liquidation at ~$52,500

## Liquidity Pools

### How LP Works

Liquidity Providers (LPs) deposit assets into vaults. These vaults:

- Serve as counterparty to traders
- Earn fees from trading activity
- Share profits when traders lose
- Cover losses when traders profit

**Risk/Reward:**

- LPs earn trading fees and a share of trader losses
- LPs bear the risk when traders are profitable
- Net profit tracked in `revenueInfo`

### Vault Metrics

**TVL (Total Value Locked)**: Total assets in the vault

```txt
TVL = Available Assets + Assets in Open Positions
```

**Share Price**: Value of one vault share

```txt
Share Price = Total Vault Value / Total Shares Outstanding
```

- Increases when vault is profitable
- Decreases when vault incurs losses
- Initial share price typically starts at 1.0

**APY (Annual Percentage Yield)**: Annualized return

```txt
APY = (Net Profit / TVL) × (365 / Epoch Duration Days) × 100
```

- Calculated from historical revenue
- Updates based on vault performance
- Can fluctuate with market conditions

### Deposit/Withdrawal Flow

1. **Deposit**: User deposits → receives shares

   ```txt
   Shares Received = Deposit Amount / Current Share Price
   ```

2. **Withdrawal Request**: User requests withdrawal
   - Shares locked until next epoch
   - `unlockEpoch` indicates when withdrawal available
   - Can set `autoRedeem: true` for automatic redemption

3. **Withdrawal Execution**: After epoch ends
   - User redeems shares for assets
   - Value = `Shares × Current Share Price`

### Epochs

Time periods for LP operations:

- **Duration**: Check `epochDurationDays` or `epochDurationHours`
- **Current Epoch**: Track with `currentEpoch`
- **Epoch Start**: Unix timestamp of epoch start
- **Purpose**: Prevents instant withdrawal attacks, ensures fair pricing

### Revenue Info

Each vault tracks detailed revenue metrics:

- `RevenueCumulative`: Total revenue earned all-time
- `NetProfit`: Current net profit (revenue - liabilities)
- `TraderLosses`: Profits from trader losses
- `ClosedPnl`: Realized PnL from closed positions
- `CurrentEpochPositiveOpenPnl`: Current unrealized gains
- `Liabilities`: Current liabilities (trader unrealized profits)
- `Rewards`: Additional rewards received

## Oracle System

### Price Feeds

Oracle provides reliable, up-to-date prices for all tokens:

**Update Mechanism**:

- Prices updated on-chain via oracle validators
- Each update recorded with block number and timestamp
- Multiple price sources aggregated for accuracy
- Updates occur every few blocks (varies by token)

**Token Types**:

- **Bank tokens** (`TokenType.bank`): Native Cosmos SDK tokens
- **ERC20 tokens** (`TokenType.erc20`): Ethereum-compatible tokens

### Using Prices

Always check `lastUpdatedBlock` to ensure price freshness:

```graphql
{
  oracle {
    tokenPricesUsd(where: { tokenId: 1 }) {
      priceUsd
      lastUpdatedBlock {
        block
        block_ts
      }
    }
  }
}
```

**Best Practice:**

```javascript
const ageSeconds = (Date.now() - new Date(lastUpdatedBlock.block_ts).getTime()) / 1000
if (ageSeconds > 60) {
  console.warn('Price may be stale')
}
```

## Fee Structure

### Fee Types

**Opening Fees** (`FeeType.OPENING`):

- Charged when opening a position
- Based on position size
- Components: vault fee, gov fee

**Closing Fees** (`FeeType.CLOSING`):

- Charged when closing a position
- Based on position size
- Components: vault fee, gov fee, trigger fee (if triggered by keeper)

### Fee Components

Every fee transaction breaks down into:

```txt
Total Fee = Vault Fee + Gov Fee + Trigger Fee
```

- **Vault Fee**: Goes to LP vault (largest portion, typically 80-90%)
- **Gov Fee**: Protocol governance fee (typically 10-20%)
- **Trigger Fee**: Reward for triggering stop/limit orders (if applicable)

**Example Fee Breakdown:**

```txt
Position Size: $10,000
Opening Fee: 0.1% = $10
├─ Vault Fee: $8 (80%)
├─ Gov Fee: $2 (20%)
└─ Total: $10
```

### Fee Multiplier

Dynamic multiplier based on market conditions:

```txt
Actual Fee = Base Fee × Fee Multiplier
```

- Higher multipliers during high volatility or risk periods
- Typical range: 1.0x to 2.0x
- Protects LP vaults during risky conditions
- Tracked in `avgFeeMultiplier` for analytics

### Bad Debt

When a position is liquidated but collateral is insufficient:

```txt
Bad Debt = Total Loss - Collateral Available
```

- Bad debt is tracked per transaction
- Absorbed by the protocol/vault
- Monitored in fee analytics
- Rare occurrence with proper risk management

## Blocks and Timestamps

### Block Structure

```graphql
type Block {
  block: Int!         # Block height/number
  block_ts: Time!     # Block timestamp (RFC3339 format)
}
```

**Usage:**

- `block`: Sequential number, increases monotonically
- `block_ts`: Human-readable timestamp
- Every important event (trade open/close, deposit, etc.) includes block info

### Time Type

The `Time` scalar represents timestamps in RFC3339 format:

```txt
2024-11-03T10:30:00Z
```

### Filtering by Time

Use `TimeFilter` for date ranges:

```graphql
{
  fee {
    feeTransactions(
      filter: {
        fromDate: "2024-01-01T00:00:00Z"
        toDate: "2024-01-31T23:59:59Z"
      }
    ) {
      id
    }
  }
}
```

### Block vs Timestamp

- **Block height**: Sequential, deterministic, never changes
- **Timestamp**: Human-readable, approximate (block times can vary)
- Most queries support both

**Best Practice**: Use timestamps for date ranges, blocks for precise event ordering.

## Key Terminology

### Trading Terms

- **Collateral**: Asset deposited to open positions
- **Margin**: Same as collateral in perpetuals context
- **Liquidation**: Forced position closure when losses exceed threshold
- **Funding Rate**: Periodic payment between longs and shorts (borrowing fees in Sai)
- **Mark Price**: Oracle price used for PnL calculations
- **Index Price**: Spot price from oracle

### LP Terms

- **TVL**: Total Value Locked in a vault
- **Share Price**: Value of one vault share token
- **Epoch**: Time period for LP operations
- **APY**: Annual Percentage Yield
- **Revenue**: Earnings from trading fees and trader losses

### Fee Terms

- **Opening Fee**: Fee charged when opening a position
- **Closing Fee**: Fee charged when closing a position
- **Fee Multiplier**: Dynamic multiplier applied to base fees
- **Bad Debt**: Losses exceeding available collateral

## Data Freshness

- **Real-time**: Subscriptions provide live updates as events occur
- **Query Latency**: Typically <100ms for queries
- **Block Time**: ~1-2 seconds on Nibiru Chain
- **Oracle Updates**: Varies by token, typically every few blocks
- **Cache**: Some data cached briefly for performance

## Smart Contract Architecture

Sai Protocol consists of 5 key Wasm contracts:

1. **Perp Manager**: Handles perpetual trading operations
2. **LP Vault**: Manages positions and withdrawals
3. **Oracle**: Provides price feeds
4. **Fee Manager**: Processes and distributes fees
5. **Governance**: Protocol parameter management

All contracts are fully on-chain and written in Rust for security and performance.

## Next Steps

- Learn about [Perp API](./api-perp.md) for trading data
- Explore [LP API](./api-lp.md) for liquidity pool data
- Check [Oracle API](./api-oracle.md) for price feeds
- Understand [Fee API](./api-fees.md) for fee analytics
