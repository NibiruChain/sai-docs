---
description: >-
  Discover how traders execute orders to go long on various digital assets.
  These traders, called "takers", use liquidity provided by the protocol to open
  and close perpetual positions.
icon: up-right-from-square
---

# Executing Trades

## Order types

| Order Type                              | Description                                                                                                                                                                                |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Market Order**                        | Executes at the current market price (from the oracle + potential slippage). It’s the fastest way to enter a position.                                                                     |
| **Limit Order**                         | Executes only if the market crosses a specific “better” price. Example: “Go long at 50k” (the price is 51k now, so if it dips to 50k, it triggers a buy).                                  |
| **Stop Order**                          | Executes if the market crosses a specific “worse” price.  Example: "Go long at 70k” (the price is 60k now; you want to catch momentum going upward).                                       |
| Trigger Order (Stop Loss / Take Profit) | Separate from entry orders—these are conditions to **close** a position automatically if price hits a threshold. A network “keeper” must send the final transaction to trigger your order. |

> **Tip**: Market, Limit, and Stop are used for **opening** a position. A Stop Loss or Take Profit is used for **closing** a position once conditions are met.

## Open a Position

1. **Choose Market & Collateral**
   * E.g., BTC/USD with “USDC” as collateral.
2. **Select a side**
   * E.g., long/short
3. **Select Leverage**
   * Type your desired multiple (1x–150x, subject to max).
4. **Enter Order Type**
   * Market or set a limit/stop price.
5. **Confirm**
   * The contract checks your collateral, calculates fees, and _if valid_, opens your position.

**Step-by-Step Example (Market Order, Long)**

1. **Collateral**: 500 USDC (You deposit 500 tokens into the vault).
2. **Leverage**: 5x => Position Notional = 2,500 UUSD.
3. **Click “Open Long”**
   * The protocol takes your 500 collateral, checks everything, and opens a 2,500 notional BTC/USD position at the current price (minus any slippage).
4. **Fees**: Suppose 0.1% open fee => 2.5 USDC is deducted from your margin.

## Close a Position

You can fully or partially close.

* **Market Close**: Sells (or buys back) instantly at the current price.
* **Partial Close**: Specify how much leverage/collateral to remove.
* **Trigger Close** (Stop Loss / Take Profit): If price crosses your chosen threshold, a keeper can finalize the close.

**Closing Fees** apply, so plan for that. If your trade was profitable, leftover profits are credited from the vault to your wallet. If the trade was a loss, your collateral will be reduced accordingly.

## Stop Loss & Take Profit

After opening a trade, you may set or update:

* **SL**: The price to close if the market moves against you.
* **TP**: The price to close if the market moves in your favor.

Once triggered, an external call to “TriggerTrade” finalizes it. If no one triggers it, the position remains open.
