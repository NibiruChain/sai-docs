# State Variables

This document describes the state variables in the perpetual futures trading smart contract. Variables are organized by functional module for clarity and ease of reference.

## Borrowing

| Variable           | Type                                                           | Description                                              |
| ------------------ | -------------------------------------------------------------- | -------------------------------------------------------- |
| `PAIRS`            | `Map<(TokenIndex, MarketIndex), BorrowingData>`                | Stores borrowing data for trading pairs                  |
| `PAIR_GROUPS`      | `Map<(TokenIndex, MarketIndex), Vec<BorrowingPairGroup>>`      | Tracks historical group associations for borrowing pairs |
| `PAIR_OIS`         | `Map<(TokenIndex, MarketIndex), OpenInterest>`                 | Stores open interest data for pairs                      |
| `GROUPS`           | `Map<(TokenIndex, GroupIndex), BorrowingData>`                 | Stores borrowing data for groups                         |
| `GROUP_OIS`        | `Map<(TokenIndex, GroupIndex), OpenInterest>`                  | Stores open interest data for groups                     |
| `INITIAL_ACC_FEES` | `Map<(TokenIndex, Addr, UserTradeIndex), BorrowingInitialAccFees>` | Tracks initial accumulated fees for trades               |

The borrowing module manages leveraged trading fees and risk exposure:

- **`PAIRS` and `GROUPS`**: Store borrowing-specific parameters including fee rates and accumulated fees for calculating trading costs. Note: This borrowing `GROUPS` contains `BorrowingData` and is distinct from the trading pairs `GROUPS` which contains general group information.
- **`PAIR_GROUPS`**: Maintains historical group associations for each pair. When pairs change groups, this ensures accurate fee calculations across different fee structures during a trade's lifetime.
- **`PAIR_OIS` and `GROUP_OIS`**: Track open interest for pairs and groups to enforce exposure limits and calculate dynamic borrowing rates based on market imbalances.
- **`INITIAL_ACC_FEES`**: Records accumulated fees when a trade opens, providing a reference point for calculating total borrowing fees at closure.

## Fees

| Variable                  | Type                                       | Description                                  |
| ------------------------- | ------------------------------------------ | -------------------------------------------- |
| `FEE_TIERS`               | `Item<[FeeTier; 8]>`                       | Stores the fee tier structure                |
| `PENDING_GOV_FEES`        | `Map<TokenIndex, Uint128>`                 | Tracks pending governance fees               |
| `VAULT_CLOSING_FEE_P`     | `Item<Decimal>`                            | Stores the vault closing fee percentage      |
| `TRADER_DAILY_INFOS`      | `Map<Addr, HashMap<u64, TraderDailyInfo>>` | Stores daily trading information for traders |
| `PAIR_VOLUME_MULTIPLIERS` | `Map<MarketIndex, Decimal>`                | Stores volume multipliers for pairs          |
| `TRADER_INFOS`            | `Map<Addr, TraderInfo>`                    | Stores general information about traders     |

### Referrer System

| Variable                        | Type                                       | Description                                  |
| ------------------------------- | ------------------------------------------ | -------------------------------------------- |
| `REFERRER_CODES`                | `Map<String, Addr>`                        | Maps referrer codes to referrer addresses   |
| `REFERRER_CODES_REVERSE`        | `Map<Addr, String>`                        | Maps referrer addresses to their codes      |
| `USER_REFERRERS`                | `Map<&Addr, Addr>`                         | Maps users to their referrers               |
| `REFERRER_FEES`                 | `Map<(TokenIndex, &Addr), Uint128>`        | Tracks fees earned by referrers             |
| `REFERRER_FEE_PERCENTAGE`       | `Item<[Decimal; 4]>`                       | Fee percentages for different referrer tiers |
| `REFERRER_FEE_TIER`             | `Map<Addr, u8>`                            | Maps referrers to their fee tier levels     |
| `REFERREE_BASE_FEE_MULTIPLIER`  | `Item<Decimal>`                            | Base fee multiplier for referees            |

The fees module implements dynamic tiered fee structures and referral programs:

**Core Fee Management:**
- **`FEE_TIERS`**: Defines fee levels based on trading activity to attract high-volume traders.
- **`PENDING_GOV_FEES`**: Accumulates governance fees for transparent distribution.
- **`VAULT_CLOSING_FEE_P`**: Sets the percentage of closing fees allocated to vault insurance/liquidity.
- **`TRADER_DAILY_INFOS` and `TRADER_INFOS`**: Track daily and cumulative trading data to calculate fee tiers over rolling periods.
- **`PAIR_VOLUME_MULTIPLIERS`**: Weight trading volume differently across markets to incentivize specific pairs or balance liquidity.

**Referral System:**
The referral system rewards users for platform growth through a comprehensive affiliate program:
- **`REFERRER_CODES` and `REFERRER_CODES_REVERSE`**: Enable bidirectional mapping between referrer codes and addresses.
- **`USER_REFERRERS`**: Maps users to their referring addresses.
- **`REFERRER_FEES`**: Accumulates earnings for each referrer across token types.
- **`REFERRER_FEE_PERCENTAGE` and `REFERRER_FEE_TIER`**: Support multi-tier referrer levels with different fee percentages.
- **`REFERREE_BASE_FEE_MULTIPLIER`**: Provides base discounts for referred users.

## Trading Pairs and Groups

| Variable                   | Type                        | Description                              |
| -------------------------- | --------------------------- | ---------------------------------------- |
| `PERP_MARKETS`             | `Map<MarketIndex, MarketInfo>` | Stores information about trading pairs   |
| `GROUPS`                   | `Map<GroupIndex, Group>`    | Stores information about trading groups  |
| `FEES`                     | `Map<FeeIndex, Fee>`        | Stores fee information for trading pairs |
| `PAIR_CUSTOM_MAX_LEVERAGE` | `Map<MarketIndex, Decimal>` | Stores custom maximum leverage for pairs |
| `ORACLE_ADDRESS`           | `Item<Addr>`                | Stores the address of the oracle contract |
| `VAULT_ADDRESSES`          | `Map<(GroupIndex, TokenIndex), Addr>` | Stores vault addresses for each group/token combination |

This module defines the core trading infrastructure:

- **`PERP_MARKETS`**: Stores trading pair information including base/quote assets, oracle indices, and associated group/fee indices.
- **`GROUPS`**: Defines leverage limits and group-wide parameters for categorizing pairs with similar risk profiles. Note: This differs from the borrowing `GROUPS` which contains `BorrowingData`.
- **`FEES`**: Contains fee structures (open/close/trigger fees) for each pair, enabling market-specific fee adjustments.
- **`PAIR_CUSTOM_MAX_LEVERAGE`**: Provides pair-specific leverage limits that override group settings for volatile or illiquid markets.
- **`ORACLE_ADDRESS`**: Points to the oracle contract for price feeds used in trade execution and liquidations.
- **`VAULT_ADDRESSES`**: Maps vault contract addresses to group/token combinations for multi-vault asset management.


## Price Impact and Open Interest

| Variable               | Type                                                      | Description                                       |
| ---------------------- | --------------------------------------------------------- | ------------------------------------------------- |
| `OI_WINDOWS_SETTINGS`  | `Item<OiWindowsSettings>`                                 | Stores settings for open interest windows         |
| `WINDOWS`              | `Map<(WindowDuration, MarketIndex, WindowIndex), PairOi>` | Stores open interest data for specific windows    |
| `PAIR_DEPTHS`          | `Map<MarketIndex, PairDepth>`                             | Stores market depth information for pairs         |
| `TRADE_LAST_WINDOW_OI` | `Map<(Addr, TradeInfoIndex), Uint128>`                    | Tracks the last window's open interest for trades |

This module manages market dynamics and prevents excessive price impact:

- **`OI_WINDOWS_SETTINGS`**: Defines parameters for tracking open interest over time windows to calculate dynamic market impact.
- **`WINDOWS`**: Stores historical open interest data for calculating cumulative trade impact over specific time periods. This time-windowed approach prevents market manipulation.
- **`PAIR_DEPTHS`**: Contains market liquidity information used to calculate price impact for large trades, protecting against sudden price movements.
- **`TRADE_LAST_WINDOW_OI`**: Tracks each trade's contribution to open interest in its last active window for accurate updates when trades close or modify.

## Trading

| Variable                 | Type                                     | Description                                     |
| ------------------------ | ---------------------------------------- | ----------------------------------------------- |
| `COLLATERALS`            | `Map<TokenIndex, CollateralInfo>`        | Stores information about collateral types       |
| `USER_TRADE_INDEX`       | `Map<Addr, UserTradeIndex>`              | Tracks the next trade index for each user       |
| `TRADES`                 | `Map<(User, UserTradeIndex), Trade>`     | Stores individual trade information             |
| `TRADE_INFOS`            | `Map<(User, TradeInfoIndex), TradeInfo>` | Stores additional information about trades      |
| `TRADER_STORED`          | `Map<User, bool>`                        | Tracks whether a trader's information is stored |
| `USER_LIVE_TRADE_COUNTS` | `Map<User, u64>`                         | Tracks trade counts for users                   |
| `MINIMUM_POSITION_SIZE_USD` | `Item<Decimal>`                       | Stores the minimum position size in USD         |
| `TRADING_ACTIVATED`      | `Item<TradingActivated>`                 | Stores the current trading activation status    |

The trading module forms the protocol's core functionality:

**Trade Management:**
- **`COLLATERALS`**: Defines accepted collateral types with name, active status, and denomination for multi-asset support.
- **`USER_TRADE_INDEX`**: Tracks the next available trade index per user for unique identification and prevents index collisions.
- **`TRADES` and `TRADE_INFOS`**: Store comprehensive trade data including position sizes, leverage, prices, and timestamps for fee calculations.

**Optimization and Controls:**
- **`TRADER_STORED` and `USER_LIVE_TRADE_COUNTS`**: Optimization mechanisms that reduce gas costs and enable efficient trade ID assignment.
- **`MINIMUM_POSITION_SIZE_USD`**: Sets minimum position thresholds to ensure economic viability and prevent dust trades.
- **`TRADING_ACTIVATED`**: Critical safety feature supporting multiple activation levels (fully active, close-only, paused) for emergency control.
