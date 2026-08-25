---
title: After-Hours Leverage
description: "How Sai reduces carried leverage on scheduled markets when a position remains open across a market close."
---

Some Sai markets follow scheduled trading sessions. Stocks and other real-world
assets can close for the day, over a weekend, or during holidays. When those
markets are closed, ordinary opens and voluntary closes are blocked because Sai
cannot rely on the same continuous pricing and liquidation flow.

For configured markets, Sai also applies an **after-hours effective leverage
cap** to live positions that were carried through the latest market close.

## What changes for traders?

If you hold a live position through a scheduled close, the contract may treat
that position as if it has lower leverage than the leverage originally stored on
the trade.

For example:

```text
Stored trade:       100 USDC collateral at 50x leverage
After-hours cap:    5x
Effective exposure: 100 USDC collateral at 5x leverage
```

The cap reduces position size. It does not add collateral to the trade. The
stored leverage can continue to appear on the position until the contract
normalizes the trade, but risk and PnL calculations use the lower effective
leverage once the after-hours rule applies.

## When does the cap apply?

The cap applies only when all of these are true:

* The market is configured for after-hours leverage controls.
* The trade is a live position, not a pending limit or stop order.
* The trade was opened or last risk-modified before the latest market reopen.
* The stored leverage is higher than the configured after-hours cap.

Pending limit and stop orders are not capped because they are not live exposure
until they trigger into an open position.

## Normalization

Anyone can call the normal trigger path for a position that needs after-hours
normalization. Keepers usually handle this.

When normalization runs, the contract:

1. Checks whether the trade should be liquidated at the returned oracle price.
2. If liquidation is not needed, reduces stored leverage to the after-hours cap.
3. Applies the after-hours risk-trigger fee path to the position size that is
   removed.
4. Updates open interest so the market reflects the smaller exposure.

This action does not reopen the market and does not let traders voluntarily exit
while the market is closed. It is a risk maintenance action.

Normalization can reduce collateral because fees are charged on the exposure
that is removed. If fees consume the remaining collateral, the position can be
closed by the contract.


## What should I watch in the UI?

Check the market's displayed leverage limits before opening a trade. For
scheduled markets, treat high leverage near market close as temporary exposure:
if the position is carried across the close, the protocol can reduce the
effective leverage to the configured after-hours cap.

The safest approach is to manage leverage before scheduled closes, especially on
markets where price gaps can occur between sessions.
