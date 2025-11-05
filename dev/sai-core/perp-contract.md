---
description: An in-depth look at the Sai Perp (perpetual futures) contract implementation.
---

# Perp Contract

- **Events** are not covered in this guide.
- **Borrowing logic** is described thoroughly here in the [Perp: Borrowing Module](./perp-borrowing.md) specification.
- **Fees logic** is described thoroughly in [./fees/README.md](./src/fees/README.md).
- **Price impact** logic is described thoroughly in [Perp: Price Impact Module](./perp-price-impact.md).

---

## Table of Contents

- [Developer Documentation: Perpetual Futures Contract](#developer-documentation-perpetual-futures-contract)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Repository Layout](#repository-layout)
  - [Key Concepts](#key-concepts)
    - [Trade Lifecycle](#trade-lifecycle)
    - [Contract Entry Points](#contract-entry-points)
    - [Index Types](#index-types)
    - [Inter-Contract Interactions](#inter-contract-interactions)
  - [Messages (`ExecuteMsg` and `AdminExecuteMsg`)](#messages-executemsg-and-adminexecutemsg)
  - [Trade Flow in Detail](#trade-flow-in-detail)
    - [Open a Trade](#open-a-trade)
    - [Close a Trade](#close-a-trade)
    - [Modify a Trade (Stop/Limit/SL/TP/Leverage)](#modify-a-trade-stoplimitsltpleverage)
  - [Additional Modules](#additional-modules)
    - [Borrowing Reference](#borrowing-reference)
    - [Fees Reference](#fees-reference)
    - [Price Impact Reference](#price-impact-reference)
  - [Further Notes](#further-notes)

---

## Overview

This contract implements **perpetual futures** trading features in CosmWasm. It allows:

- **Opening** and **closing** of leveraged positions (long/short).
- **Limit** and **stop** orders for trade entry.
- Dynamic **stop-loss (SL)** and **take-profit (TP)** updates.
- **Partial** position modifications (increase or decrease collateral/leverage).
- Automatic **borrowing fee** accrual (see [Borrowing Reference](#borrowing-reference)).
- Dynamic **fee** calculations (see [Fees Reference](#fees-reference)).
- **Price impact** adjustments based on open interest (see [Price Impact Reference](#price-impact-reference)).

---

## Repository Layout

Key files and folders relevant to this contract:

- **`./contract.rs`**
  - High-level instantiation, migration, and execution entry points.
  - Handles top-level dispatch for `ExecuteMsg::Admin { .. }`.
- **`./msgs.rs`**
  - Defines public `ExecuteMsg` messages for external users.
  - Defines admin messages (`AdminExecuteMsg`) for privileged ops.
- **`./trade.rs`**, **`./update_position_size.rs`**, **`./exec_update_leverage.rs`**
  - Main **trade** management logic: open/close trades, partial close, update SL/TP, etc.
- **`./borrowing/`**
  - [**Reference** here](./src/borrowing/README.md).
  - Borrowing data structures, open-interest tracking, and fee accrual.
- **`./fees/`**
  - [**Reference** here](./src/fees/README.md).
  - Fee calculations, tier logic, distribution of fees to vaults.
- **`./price_impact/`**
  - [**Reference** here](./src/price_impact/README.md).
  - Logic to handle large trades moving the market price (slippage).
- **`./trading/state.rs`**, **`./trading/utils.rs`**
  - Core state definitions for trades (like `Trade`, `TradeInfo`, `TradingActivated`).
  - Helper methods for trade validation, order type checks, slippage logic, and exposure-limiting.

You will see references to modules such as:

- `borrowing`, `fees`, `price_impact`, `pairs`, `trading` - each in its own folder.
- `keys.rs` - containing typed indexes (e.g., `MarketIndex`, `TokenIndex`, etc.).
- `entry.rs` - collects logic for certain "entry-level" operations like opening/closing trades.

---

## Key Concepts

### Trade Lifecycle

1. **Open**
   - Create a `Trade` struct with details on leverage, collateral, direction (long/short).
   - Fees are charged on open.
2. **Position Live**
   - Accrues **borrowing fees** over time (borrowed from `borrowing` module).
   - Market can move: position PnL is conceptual, realized only on close.
3. **Close**
   - Reverse the open interest effect, finalize fees, distribute collateral to user or vault if loss.
4. **Stop/Limit/TP/SL**
   - The contract allows storing limit orders or setting stop-loss/take-profit boundaries.
   - Typically triggered by an off-chain or keeper system calling `TriggerTrade`.

### Contract Entry Points

- **`instantiate`**  
  Initializes ownership, oracle references, default settings for `OI_WINDOWS_SETTINGS`.
- **`execute`**  
  Dispatches user calls to `ExecuteMsg`. Distinguishes between normal user ops vs. admin messages.
- **`migrate`**  
  For contract upgrade logic.

### Index Types

`./keys.rs` defines typed indexes used throughout storage:

- **`MarketIndex(u16)`**: Unique ID for a trading market/pair.
- **`GroupIndex(u16)`**: Group of markets for borrowing fee grouping.
- **`TokenIndex(u16)`**: Represents a collateral token.
- **`UserTradeIndex(u64)`**: Uniquely identifies a trade for a given user.
- **`TradeInfoIndex(u64)`**: Additional info index for the same trade (like creation block, slippage settings, etc.).

These typed indexes help ensure type safety and consistent 2-byte or 8-byte key usage in storage.

### Inter-Contract Interactions

Key interactions are:

- **Oracle** (`oracle_address`)
  - Queried for `GetExchangeRate` to determine the price of base vs. quote assets.
  - Also used for collateral price in USD.
- **Vault** (`VAULT_ADDRESSES`)
  - Receives or sends collateral during partial close, liquidation, or exit.
  - Manages user margin deposits (collateral).

No direct "execute calls" are done to other modules like borrowing/fees; these modules are integrated inside this contract's logic. However, certain distributions are done via `BankMsg::Send` or calling the vault's `ExecuteMsg::ReceiveAssets`.

---

## Messages (`ExecuteMsg` and `AdminExecuteMsg`)

User commands are in [`./msgs.rs`](./src/msgs.rs). Notable fields (you can see the file for all arguments):

- **`OpenTrade { market_index: MarketIndex, leverage: Decimal, long: bool, ... }`**  
  Opens a brand new position with specific parameters.
- **`CloseTrade { trade_index: UserTradeIndex }`**  
  Closes a currently open trade at market price.
- **`UpdateOpenLimitOrder { trade_index, price, tp, sl, slippage_p }`**  
  Edits the price or SL/TP for a limit order that hasn't become a live position yet.
- **`TriggerTrade { trader: String, trade_index: UserTradeIndex, order_type: PendingOrderType }`**  
  Activates a limit/stop/TP/SL/liq order if conditions are met.
- **`UpdateLeverage { trade_index, new_leverage }`**  
  Adjusts leverage on an existing position (increasing or decreasing collateral).
- **`IncreasePositionSize`** / **`DecreasePositionSize`**  
  Allows partial modifications in position size or adding/removing collateral.

**Admin** operations (`AdminExecuteMsg`) revolve around:

- Setting markets (`SetMarkets`)
- Updating Oracle or Vault addresses
- Configuring fees or borrowing groups
- Withdrawing protocol funds
- Pausing/trading activation toggles

These admin messages **reference** logic from:

- [Borrowing Admin Ops](./src/borrowing/README.md#key-components)
- [Fees Admin Ops](./src/fees/README.md#key-components)
- [Price Impact Admin Ops](./src/price_impact/README.md#open-interest-management)

---

## Trade Flow in Detail

### Open a Trade

1. **User** calls **`ExecuteMsg::OpenTrade`** with parameters like:
   ```rust
   OpenTrade {
       market_index: MarketIndex(0),
       leverage: Decimal::from_str("5.0")?,
       long: true,
       collateral_index: TokenIndex(1),
       trade_type: TradeType::Trade,
       open_price: Decimal::from_str("1000")?,
       tp: Some(...),
       sl: Some(...),
       slippage_p: Decimal::from_str("0.03")?,
   }
   ```
2. **Funds** must be included in the message for the specified `collateral_index`.
3. The contract:
   - **Fetches** the user's deposit from `info.funds`.
   - **Validates** leverage, min collateral, exposure limits, slippage, etc.
   - **Charges** open fees (see [Fees module](#fees-reference)).
   - **Applies** borrowing logic to keep track of open interest (see [Borrowing module](#borrowing-reference)).
   - **Stores** the new trade in `TRADES[(User, UserTradeIndex)]`.

### Close a Trade

1. **User** calls **`CloseTrade { trade_index }`** to close an open position.
2. The contract:
   - Updates the position's final fees (borrowing + close fees).
   - Returns leftover collateral or collects more from user if losing more than stored.
   - Removes open interest from Borrowing storage.
   - Deletes or marks the trade as closed in `TRADES`.

### Modify a Trade (Stop/Limit/SL/TP/Leverage)

Several helper messages exist to alter the trade during its lifetime:

- **`TriggerTrade { order_type: PendingOrderType }`**  
  Usually invoked by keepers. This makes a limit/stop order active or triggers SL/TP closure.
- **`UpdateOpenLimitOrder`**  
  Edits a not-yet-triggered limit or stop order's parameters (price, SL, TP, etc.).
- **`UpdateTp` / `UpdateSl`**  
  Adjust the take-profit or stop-loss boundaries for an already open "live" trade.
- **`UpdateLeverage { new_leverage }`**  
  Increases or decreases the position's leverage.  
  If you reduce leverage, you must send additional collateral.  
  If you increase leverage, the system returns collateral to you.

> Under the hood, these modifications recalculate fees, re-check liquidation price, update Borrowing open interest if necessary, and more.

---

## Additional Modules

Below are references to the specialized submodules for advanced logic:

### Borrowing Reference

See **`./borrowing/README.md`** for how:

- Borrowing fees accumulate over time.
- The system enforces maximum open interest (OI) constraints on a **Group** or **Pair** basis.
- Each trade references a **BorrowingPairGroup** for historical group changes.

### Fees Reference

See **`./fees/README.md`** for how:

- Fees are computed on open, close, partial close, trigger orders, and liquidation.
- Fees are distributed among governance, trigger reward, and vault.
- Fee tiers reduce fees for high-volume traders.

### Price Impact Reference

See **`./price_impact/README.md`** for how:

- `PAIR_DEPTHS` sets the "1% market depth" for each pair (above/below).
- Large trades face an execution price penalty or improvement.
- Time-windowed open interest approach is used to smooth out short-term spikes.

---

## Further Notes

- **Contract Ownership**:  
  Updated via nibiru-ownable's `UpdateOwnership` admin message.
- **Validation**:  
  Full validations across multiple modules ensure no negative exposure or insufficient collateral.
- **Extensibility**:  
  Additional messages or fee logic can be integrated by referencing the same approach for typed storage, slippage checks, and Borrowing/Fees hooks.

That covers the **core** perpetual futures logic in this repository. For further details on borrowing, fees, or price impact calculations, please **reference** their dedicated READMEs in `./borrowing`, `./fees`, and `./price_impact`.

