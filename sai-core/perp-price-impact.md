---
description: The Price Impact Module calculates and applies price impact to trades based on their size and market depth. This module ensures that larger trades more significantly affect the execution price, reflecting real-world market dynamics.
---

# Perp: Price Impact Module

## Key Features

  * **Dynamic Calculation:** Computes price impact based on trade size and market depth.
  * **Open Interest Tracking:** Records open interest across multiple time windows.
  * **Market Depth Management:** Allows configuration of market depth parameters per trading pair.
  * **Time-Weighted Open Interest:** Uses a time-windowed approach to calculate cumulative open interest.
  * **Long/Short Handling:** Calculates price impact differently for long and short trades.

## Components

### State

  * `OI_WINDOWS_SETTINGS`: Settings for open interest windows.
  * `WINDOWS`: Stores open interest data for specific time windows.
  * `PAIR_DEPTHS`: Market depth information for trading pairs.
  * `TRADE_LAST_WINDOW_OI`: Tracks the last window's open interest for trades.

### Functions

  * `get_trade_price_impact`: Calculates price impact for a trade.
  * `add_price_impact_open_interest`: Updates open interest when a trade is opened.
  * `remove_price_impact_open_interest`: Updates open interest when a trade is closed.
  * `get_price_impact_oi`: Retrieves current price impact open interest.

## Price Impact Calculation

The price impact is calculated using this formula:

$$Price\ Impact\ \% = \frac{(Start\ OI + \frac{Trade\ Size}{2})}{One\ Percent\ Depth}$$

  * **Start OI**: Starting open interest for the relevant direction (long/short).
  * **Trade Size**: Size of the trade.
  * **One Percent Depth**: Trading volume needed to move the price by 1%.

### Calculation Process

1.  **Fetch Market Depth**: The module retrieves the market depth from `PAIR_DEPTHS`.
2.  **Calculate Current Open Interest**: It sums open interest across multiple time windows, giving more weight to recent windows.
3.  **Compute Price Impact Percentage**:
    ```rust
    let price_impact_p = Decimal::from_ratio(
        start_open_interest_usd + trade_open_interest_usd.checked_div(2_u64.into())?,
        one_percent_depth_usd
    ).checked_div(Decimal::from_atomics(100_u64, 0)?)?;
    ```
4.  **Apply Price Impact**: The calculated impact is applied to the trade's execution price:
    ```rust
    let price_after_impact = if long {
        open_price + price_impact
    } else {
        open_price - price_impact
    };
    ```

### Example

Let's look at a long trade with these values:

  * **Open Price**: $1000
  * **Trade Size**: $100,000
  * **Current Open Interest**: $500,000
  * **One Percent Depth**: $1,000,000

<!-- end list -->

1.  **Calculate price impact percentage**:
    ```
    Price Impact % = (500,000 + 100,000 / 2) / 1,000,000 / 100 = 0.55%
    ```
2.  **Calculate price impact**:
    ```
    Price Impact = $1000 * 0.55% = $5.50
    ```
3.  **Apply price impact**:
    ```
    Price After Impact = $1000 + $5.50 = $1005.50
    ```

## Open Interest Management

The module uses a time-windowed approach for open interest.

1.  **Window Configuration**: `OI_WINDOWS_SETTINGS` defines the duration and count of windows.
2.  **Adding OI**: `add_price_impact_open_interest` updates the current window's open interest when a trade is opened.
3.  **Removing OI**: `remove_price_impact_open_interest` adjusts open interest when a trade is closed.
4.  **Time-Weighted Calculation**: Open interest from multiple recent windows is used for a more stable metric.

## Usage

1.  Initialize `PAIR_DEPTHS` with market depth values.
2.  Configure `OI_WINDOWS_SETTINGS`.
3.  Call `get_trade_price_impact` to calculate price impact for a trade.
4.  After execution, call `add_price_impact_open_interest` or `remove_price_impact_open_interest` to update open interest.

## Configuration

Fine-tune the module by adjusting these parameters:

  * `one_percent_depth_above_usd` and `one_percent_depth_below_usd` in `PAIR_DEPTHS`.
  * `windows_count` and `windows_duration` in `OI_WINDOWS_SETTINGS`.

## Future Improvements

  * Implement dynamic adjustment of market depth.
  * Add support for asymmetric price impact.
  * Introduce more advanced time-weighting algorithms.
