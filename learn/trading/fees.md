---
icon: comment-dollar
---

# Fees

This guide explains how fees are structured, calculated, and distributed across the system.

* **Dynamic Fee Calculation**: Adjust fees based on trade type (open/close) and user activity.
* **Volume-Based Discounts**: Reward active traders with reduced fees through tiered multipliers.
* **Fee Distribution**: Allocate fees to protocol vaults, governance stakers, and optional third-party services.

***

### How Fees Are Calculated

#### Base Fee Rates

Every trade type has a base fee percentage:

* **Opening Fee**: Charged when initiating a position.
* **Closing Fee**: Charged when closing a position.
* **Trigger Fee**: Applied to conditional orders (e.g., limit or stop orders).

**Example Base Rates**:

* Open Fee: 0.1%
* Close Fee: 0.1%
* Trigger Fee: 0.02%

#### Volume-Based Adjustments

Traders earn **points** proportional to their trading volume (in USD). Over time, these points unlock **fee tiers**, which reduce fees by a multiplier. For example:

* Tier 1: 97.5% of base fees (2.5% discount) at 6,000,000 points.
* Tier 2: 95% of base fees (5% discount) at 20,000,000 points.

Points decay over a trailing period (e.g., 30 days), ensuring only recent activity affects tiers.

***

### Fee Distribution

Fees are split between three parties:

1. **Protocol Vault**\
   Receives a portion of closing fees (e.g., 80%) to support platform stability.
2. **Governance Stakers**\
   Earn rewards from open fees and most closing/trigger fees. These accumulate in a pool claimable by future stakers. **TBD**
3. **Trigger Service Providers** (Optional)\
   Receive 20% of trigger fees if they provide order execution services (e.g., oracle nodes).

***

### Step-by-Step Fee Lifecycle

#### Opening a Trade

1. **Calculate Base Fee**:\
   $$\text{Open Fee} = \text{Position Size} \times \text{Open Fee Rate}$$
2. **Apply Multiplier**: Reduce the fee using the trader’s tier.
3. **Distribute**:
   * LPs and stakers receive the adjusted open fee.
   * If a trigger order, 20% of the trigger fee goes to the service provider; 80% to LPs and stakers.

#### Closing a Trade

1. **Calculate Base Fee**:\
   $$\text{Close Fee} = \text{Position Size} \times \text{Close Fee Rate}$$
2. **Apply Multiplier** (if not a liquidation).
3. **Split Fees**:
   * Vault receives a fixed percentage (e.g., 80% of the close fee).
   * Remaining close fee and trigger fees go to governance stakers.

#### Liquidations

Liquidation fees are typically higher (e.g., 5% of collateral) and bypass tier discounts. These are split between the vault and stakers.

***

### Example Scenario

#### Trader A Opens a Limit Order

* **Position Size**: $10,000
* **Base Fees**:
  * Open Fee: $10 (0.1%)
  * Trigger Fee: $2 (0.02%)
* **Fee Tier**: 0.95 multiplier (Tier 2)
* **Adjusted Fees**:
  * Open: $10 × 0.95 = $9.50
  * Trigger: $2 × 0.95 = $1.90
* **Distribution**:
  * $9.50 to LPs.
  * $0.38 (20% of trigger fee) to the trigger service; $1.52 to stakers.

#### Trader A Closes the Position

* **Close Fee**: $10 × 0.95 = $9.50
* **Stakers Portion**: $9.50 × 20% = $1.90
* **Vault Receive**: $7.60 ($9.50 – $1.90) + $1.52 (trigger remainder) = $9.12

***

### Key Concepts

* **Trailing Points**: Only recent trading activity (e.g., last 30 days) counts toward fee tiers.
* **Minimum Fees**: Small positions below a threshold (e.g., $100) may bypass fees to reduce spam.
* **Governance Pool**: Unclaimed staking rewards accumulate until users withdraw them.

***

### Why It Matters

* **Fair Pricing**: Active traders pay lower fees, encouraging liquidity.
* **Protocol Sustainability**: Fees fund the vault (for risk management) and reward governance participants.
* **Flexible Configuration**: Admins can adjust pair multipliers, tiers, and fee splits to align with platform goals.

By balancing incentives for traders, stakers, and service providers, the Fees Module creates a sustainable ecosystem for perpetual trading.
