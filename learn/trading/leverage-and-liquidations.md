---
icon: arrow-up-9-1
---

# Leverage and Liquidations

> **Tip:** If you’re new to margin trading, start with lower leverage. Watch your margin ratio closely and consider using stop-loss orders to manage downside risk.

***

## Leverage Overview

### What is Leverage?

Leverage is the ratio of your _position size_ to the _collateral_ you deposit.

* For example, depositing $100 to open a $500 position is `$500 / $100 = 5x leverage`.

**Key Points**

* **Higher Leverage = Higher Risk**: Even small price changes can cause large profits or losses.
* **Borrowing Fees**: With larger positions, borrowing fees accumulate faster.
* **Liquidation Threshold**: Higher leverage reduces the price cushion before forced liquidation.

**How to Set Leverage**

1. **Open a Trade**: Select your desired leverage (e.g., 3x, 5x, 100x) in the Sai UI.
2. **Review Position Size**: Confirm the total notional value of your trade.
3. **Check Liquidation Price**: The UI estimates your liquidation price; higher leverage brings the liquidation price closer to the current market price.
4. **Update Leverage Later**: By adding or removing collateral, you can increase or decrease your effective leverage.

> **Note**: Every increase in leverage comes with greater exposure to market swings and potentially higher borrowing fees.

### Leverage Examples

* **Example A (High Leverage)**
  * Collateral: $200
  * Leverage: 5x → Position Size = $1,000
  * A 10% price rise yields roughly a $100 profit (50% gain on collateral). A 10% price drop results in a $100 loss (50% loss on collateral).
* **Example B (Lower Leverage, More Cushion)**
  * Collateral: $200
  * Leverage: 2x → Position Size = $400
  * A 10% price drop is a $40 loss (20% of your collateral). Lower leverage means more room before liquidation.

### Adjusting Leverage Mid-Position

* **Add Collateral**: Lowers your effective leverage, providing a bigger buffer against liquidation.
* **Remove Collateral**: Increases leverage, exposing you to higher risk if the market continues to move against you.

***

## Liquidation Mechanics

### What is Liquidation?

A **liquidation** automatically closes your position when your collateral can’t cover potential losses. This protects both your remaining capital (if any) and the protocol from a negative balance.

### Liquidation Threshold

SAI uses a _maintenance margin_ requirement, typically a small portion of your initial margin (e.g., 10%).

* If your total equity (`PnL + Collateral`) falls below this maintenance margin, your position becomes eligible for liquidation.
* The SAI interface normally displays a **liquidation price** to show where you’d be at risk of forced closure.

**Example**:

* $100 collateral at 5x leverage = $500 position. If maintenance margin is $10, your position can only lose $90 before liquidation is triggered. A price drop beyond that threshold triggers forced closure.

### The Liquidation Process

1. **Trigger**: If your margin ratio dips below the safe threshold, a keeper (liquidator) can call `Trigger Trade` to forcibly close your position at the current market price.
2. **Close the Position**: The system sells (or covers) your position.
3. **Distribute Remaining Collateral**: After covering losses and fees, any leftover collateral is returned to you. If losses exceed your collateral, you lose most or all of your margin.

### Avoiding Liquidations

1. **Use Lower Leverage**: Lower leverage gives you a wider price cushion.
2. **Add Collateral**: If the market moves against you, extra funds reduce your liquidation risk.
3. **Set a Stop-Loss**: Stop-loss orders let you exit earlier, often preventing liquidation and limiting losses.
4. **Monitor Borrowing Fees**: Accumulated fees can reduce your available margin and move you closer to liquidation.

***

## Pro Tips

1. **Mind Volatility**: High volatility can cause rapid price swings—be extra cautious with high leverage.
2. **Watch Borrowing Fees**: Fees accumulate over time, gradually eating into your collateral.
3. **Act Preemptively**: If you see your margin ratio dropping, adding collateral or closing part of the position can prevent a forced liquidation.
4. **Track the “Est. Liquidation Price”**: If the market price moves close to this value, you’re at high risk.

***

### 5. FAQ

**Q: What is the maximum leverage I can use in SAI?**\
A: Each market (e.g., BTC-PERP, ETH-PERP) has its own max leverage, displayed in the UI. Values like 10x, 20x, or 50x depend on that market’s risk parameters.

**Q: How do I know if I’m near liquidation?**\
A: Check your margin ratio and the displayed liquidation price in the position details. If the market price is near or past the liquidation price, a forced close can happen any moment.

***

### 6. Next Steps

1. **Try a Test Market**: Practice opening a small leveraged trade to observe how price changes affect your margin and PnL.
2. **Read About Order Types**: Learn about limit orders, stop-losses, or advanced order types if SAI supports them, to manage risk.
3. **Join the Community**: Have more questions? Need live support? Join our Discord to connect with other traders and the SAI team.

> **Trade responsibly, and best of luck with Sai!**
