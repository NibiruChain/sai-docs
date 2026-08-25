---
title: "Perp: After-Hours Leverage"
description: "Contract behavior for scheduled-market after-hours effective leverage controls."
---

Sai Perp supports an after-hours risk control for scheduled markets. It reduces
effective exposure for live positions carried through a market close, where
ordinary trading, continuous liquidation, and fresh exit pricing are not
available in the same way as during open market hours.

This page reflects the behavior merged in `sai-perps` main through the
after-hours leverage rollout and follow-up fixes.

## Product Rule

Markets enabled in `AFTER_HOURS_MARKETS` use the global cap stored in
`AFTER_HOURS_LEVERAGE` for live trades that were carried through the latest
scheduled close.

```text
effective_leverage = min(Trade.leverage, AFTER_HOURS_LEVERAGE)
```

The cap applies to filled `TradeType::Trade` positions only. Pending limit or
stop orders are not clamped because they are not live exposure until triggered.

Ordinary user opens and voluntary closes remain blocked while a market is
closed. The after-hours trigger path is a maintenance action: it can liquidate
or normalize risk, but it does not reopen the market for discretionary exits.

## State

The relevant storage is:

| State | Type | Purpose |
| --- | --- | --- |
| `AFTER_HOURS_LEVERAGE` | `Item<Decimal>` | Global effective leverage cap for configured after-hours markets |
| `AFTER_HOURS_MARKETS` | `Map<MarketIndex, bool>` | Markets where the after-hours cap applies |
| `MarketInfo.block_last_closed` | `Option<u64>` | Block where the market last entered `Closed` |
| `MarketInfo.block_last_opened` | `Option<u64>` | Block where the market last re-entered `Open` |
| `MarketInfo.last_close_price` | `Option<Decimal>` | Best-effort close snapshot kept as market metadata |

`last_close_price` is not the settlement price for after-hours risk checks.
After-hours liquidation and normalization use the oracle price returned by the
normal price query.

## Eligibility

`get_effective_leverage` returns stored `Trade.leverage` unless all of these are
true:

* The trade is open and has `trade_type == TradeType::Trade`.
* The market is enabled in `AFTER_HOURS_MARKETS`.
* `block_last_closed` and `block_last_opened` are initialized.
* The trade was not opened or risk-modified in the latest reopen block or later.
* `Trade.leverage` is above `AFTER_HOURS_LEVERAGE`.

The reopen-block boundary is inclusive: a trade with
`TradeInfo.created_block >= MarketInfo.block_last_opened` keeps its stored
leverage.

## Trigger Behavior

The contract can route `TriggerTrade` to after-hours risk handling. The
after-hours path:

1. Loads the returned oracle price from the normal price query.
2. Checks liquidation first at the stored-leverage liquidation price.
3. If liquidation is required, follows the liquidation close path.
4. If liquidation is not required, reduces stored leverage to the effective cap.
5. Calls `process_closing_fees` on the removed position-size delta with order
   type `after_hours_risk_trigger`.
6. Updates open interest and emits `sai/perp/trigger_trade/after_hours`.

No catalyst reward is paid on normalization. The caller is helping synchronize
risk, not executing a trader's TP/SL order.

If the normalization fee consumes the remaining collateral, the contract closes
the trade after the fee and risk updates.

## Oracle Freshness

After-hours liquidation and normalization intentionally use the returned oracle
price even when the market has been closed long enough for the normal freshness
window to expire. The narrow exception exists so high-leverage carried exposure
can still be reduced while scheduled markets are closed.

Ordinary opens, voluntary closes, and normal TP/SL trigger paths still use the
normal market-state and freshness guards. They do not fall back to
`last_close_price`.

## Query Semantics

Contract queries preserve stored state and expose derived risk state:

* `get_trade` returns stored `Trade`, including stored `Trade.leverage`.
* `get_trade_data` returns `needs_after_hours_trigger: true` when the trade is
  eligible for after-hours normalization.
* `get_trade_pnl` evaluates carried trades using effective leverage.
* `GetAfterHoursLeverage`, `IsAfterHoursMarket`, and
  `ListAfterHoursMarkets` expose the active cap and enabled markets.

Clients should not infer after-hours state from stored leverage alone. Use the
derived query fields when deciding whether a keeper or UI refresh should submit
`TriggerTrade`.

## Lazy Cleanup Before Mutations

When a user later mutates a carried trade whose stored leverage is above the
after-hours effective cap, the contract first materializes the after-hours
normalization. The requested mutation then operates on the normalized trade.

This guard runs before leverage updates, TP/SL updates, and position-size
increases. Position-size decreases still prioritize liquidation checks before
the resize proceeds.
