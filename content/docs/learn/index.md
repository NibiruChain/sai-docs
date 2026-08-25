---
title: About Sai
description: "Understand Sai’s perpetual markets, trading tools, liquidity, and onchain execution."
---

<!-- ![About Sai](/assets/sai-docs/sai-docs-banner.png) -->
![About Sai](/assets/sai-docs/sai-twitter-banner-1500x500.jpg)

## What is Sai?

Sai is a perpetual futures trading platform built on Nibiru. Trade long or short
with leveraged positions, low-impact execution, limit orders, stop-losses, and
take-profit triggers in a self-custodied, onchain experience.

## Why Sai?

- **Oracle settlement:** Sai uses oracle prices to settle positions and calculate
  profit and loss, providing a transparent reference price for each market.
- **Market-specific leverage:** Each market has its own leverage limits.
  Scheduled markets can apply a lower effective leverage cap to positions held
  across a market close.
- **Trading controls:** Use market and limit orders, along with stop-loss and
  take-profit triggers, to manage entries and exits.
- **One trading experience:** Manage positions, collateral, and order triggers
  in one self-custodied interface.

## Learn about Sai

Master the fundamentals of trading on Sai and understand how the platform works.

- **[Trading on Sai](/docs/learn/trading/)** — Learn the essentials of
  execution, leverage, fees, and price impact.
- **[Sai Liquidity Positions (SLP)](/docs/learn/slp/)** — Understand how SLP
  vaults provide liquidity to Sai’s perpetual markets.

### Trading fundamentals

- **[Executing Trades](/docs/learn/trading/executing-trades/)** — Learn how
  market, limit, stop-loss, and take-profit orders work.
- **[Leverage and Liquidations](/docs/learn/trading/leverage-and-liquidations/)** —
  Understand leverage, after-hours caps, and liquidation risk.
- **[After-Hours Leverage](/docs/learn/trading/after-hours-leverage/)** — Learn
  how Sai reduces carried leverage on scheduled markets after a market close.
- **[Fees](/docs/learn/trading/fees/)** — Review trading fees, funding rates,
  discounts, and gas-free actions on Nibiru.
- **[Price Impact](/docs/learn/trading/price-impact/)** — Understand how trade
  size affects execution price.
- **[Trading FAQ](/docs/learn/trading/faq/)** — Find answers to common trading
  questions.

Use the sidebar to browse topics or search for terms such as "leverage," "limit
order," or "price impact."

## User guides

Step-by-step walkthroughs cover the common tasks involved in using Sai.

- **[Using Sai](/docs/guides/)** — Browse the full collection of trading guides.
- **[Onboarding](/docs/guides/onboarding/)** — Connect to Sai and prepare an
  account for trading.
- **[Wallet Setup](/docs/guides/wallet-setup/)** — Connect a wallet and complete
  account onboarding.
- **[Sai Referral Program](/docs/guides/referral/)** — Learn how referrals and
  trading-fee discounts work.
- **[Acquiring Collateral](/docs/guides/acquiring-collateral/)** — Obtain USDC
  for trading on Sai.
- **[Choosing a Market](/docs/guides/choosing-market/)** — Select a perpetual
  market that fits your strategy.

## For developers

Build on Sai with API references, integration guides, and contract documentation.

- **[Developer documentation](/docs/dev/)** — Start building with Sai’s EVM and
  WASM integration guides.
- **[Sai Core](/docs/dev/sai-core/)** — Explore the perpetual contract, borrowing
  module, state variables, and contract integrations.
- **[Sai Keeper](/docs/dev/sai-keeper/)** — Query positions, liquidity, oracles,
  trades, and fees through the GraphQL API.
- **[Use Cases](/docs/dev/use-cases/)** — Review practical integration examples.

### Developer resources

- **[EVM Integration Guide](/docs/dev/evm-guide/)** — Connect to Sai from
  EVM-compatible applications.
- **[WASM Integration Guide](/docs/dev/wasm-guide/)** — Integrate with Sai using
  CosmWasm smart contracts.
- **[Contract Addresses](/docs/dev/sai-core/contracts/)** — Look up deployed
  contract addresses on mainnet and testnet.
- **[Perp API](/docs/dev/sai-keeper/api-perp/)** — Query and subscribe to
  perpetual-market data.

## Resources

- **[Community](/docs/community/)** — Find Sai’s official social channels and
  community links.
- **[Sai Blog](/blog/)** — Read product updates, announcements, and insights.
- **[Legal](/docs/legal/)** — Review Sai’s terms and disclosures.

## Stay connected

| Channel | Link |
| --- | --- |
| X | [@SaiDotFun](https://x.com/SaiDotFun) |
| Telegram news channel | [t.me/saidotfun](https://t.me/saidotfun) |
| Instagram | [instagram.com/saidotfun](https://instagram.com/saidotfun) |
| TikTok | [@saidotfun](https://www.tiktok.com/@saidotfun) |
| Blog | [Sai Blog](/blog/) |

## Technical overview

Sai pairs independent oracle price feeds with an automated market maker (AMM),
which provides liquidity without requiring a counterparty for every trade.
Nibiru provides the performance foundation for low-latency execution while
retaining self-custody.

Sai Liquidity Positions (SLPs) seed the pools that power each market. SLPs choose
where to allocate liquidity, which helps determine the markets that can grow on
Sai.

Sai supports more than major crypto assets, with a focus on bringing equities,
commodities, and real-world assets (RWAs) onchain while keeping trading simple,
fast, and transparent.

## Wallet setup and collateral

You can trade on Sai using an EVM-compatible wallet such as MetaMask, Coinbase
Wallet, WalletConnect, or Rabby Wallet.

| EVM-compatible wallets | |
| --- | --- |
| MetaMask | <https://metamask.io/> |
| Coinbase Wallet | <https://www.coinbase.com/wallet> |
| WalletConnect | <https://walletguide.walletconnect.network/> |
| Rabby | <https://rabby.io/> |

Sai accepts USDC from any EVM chain and stNIBI as collateral. Trading on Sai is
gasless, so you do not need NIBI to sign or submit transactions.

- Bridged USDC address (Stargate): `0x0829F361A05D993d5CEb035cA6DF3446b060970b`
- Bridge to Nibiru EVM:
  - [Nibiru Bridge (LayerZero)](https://app.nibiru.fi/bridge)
  - [Hyperlane](https://nexus.hyperlane.xyz/?token=0xa582e9e96F5D58A1202ad216E89926283a5dD056&destination=nibiru)
    (Nexus Bridge)

If you transfer funds from a centralized exchange (CEX), first send USDC or ETH
to a self-custodied wallet where you control the private keys. Then use the
Nibiru Bridge or Hyperlane to bridge assets to Nibiru EVM.
