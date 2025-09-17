---
icon: barcode-scan
---

# Price Impact

### Overview

The Price Impact Module is a key component of Sai, responsible for calculating and applying price impact to trades based on their size and market depth. It ensures that larger trades have a more significant effect on the execution price, reflecting real-world market dynamics and promoting fairness in the trading system. It is applied on all position open.

### Key Features

1. **Dynamic Price Impact Calculation:** Computes price impact based on trade size and market depth.
2. **Open Interest Tracking:** Maintains a record of open interest across multiple time windows.
3. **Market Depth Management:** Allows configuration of market depth parameters for each trading pair.
4. **Time-Weighted Open Interest:** Uses a time-windowed approach to calculate cumulative open interest.
5. **Separate Handling for Long and Short Positions:** Calculates price impact differently for long and short trades.

### Price Impact Calculation

The price impact is calculated using the following general formula:

```
Price Impact = (Start OI + Trade Size / 2) / One Percent Depth
```

Where:

* **Start OI:** The starting open interest for the relevant direction (long/short)
* **Trade Size:** The size of the trade being executed
* **One Percent Depth:** The amount of trading volume required to move the price by 1%

#### Example

Let's consider a long trade with the following parameters:

* Open Price: $1000
* Trade Size: $100,000
* Current Open Interest: $500,000
* One Percent Depth: $1,000,000

1.  Calculate price impact percentage:

    ```
    Price Impact % = (500,000 + 100,000 / 2) / 1,000,000 / 100 = 0.55%
    ```
2.  Calculate price impact:

    ```
    Price Impact = $1000 * 0.55% = $5.50
    ```
3.  Apply price impact:

    ```
    Price After Impact = $1000 + $5.50 = $1005.50
    ```

