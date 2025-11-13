---
description: >-
  This section is a primer to help you understand the benefits of Sai and how it
  works.
icon: fire
cover: ../.gitbook/assets/sai-banner-learn-1500x500 (1).png
coverY: 0
---

# Learn | About Sai

## What is Sai?

Sai is a perpetuals exchange powered by Nibiru. It lets anyone trade perpetual futures on a decentralized exchange (DEX) that feels as fast and smooth as a centralized exchange. The goal is simple: give traders a clean, reliable place to get exposure while keeping everything transparent and onchain.

## Technical Overview

Sai pairs two building blocks to keep markets fair and responsive: oracles (independent price feeds that track real-world markets) and an automated market maker (AMM) (liquidity you can always trade against instead of waiting for a counterparty). Running on Nibiru provides the performance backbone needed for low-latency, CEX-like trading while retaining self-custody.

Liquidity is community directed. Sai Liquidity Positions (SLPs) seed the pools that power every market. Because SLPs choose where to allocate their liquidity, they also have decisive influence over which markets launch and grow on Sai. If SLPs back a market, it can be traded on Sai.

Passive capital can earn through the protocol’s highly capital-efficient design, giving users the flexibility to allocate when they want or stay idle, without friction.

Sai will list more than just major crypto assets, with a focus on bringing equities, commodities, and real-world assets (RWAs) onchain. The aim is to expand market access while keeping the trading experience simple, fast, and transparent.

## Wallet Setup & Collateral

You can trade on Sai using an EVM-wallet such as MetaMask, Coinbase Wallet, WalletConnect, and Rabby Wallet.

| EVM-Compatible Wallets | |
|--------|------|
| MetaMask | <https://metamask.io/> |
| Coinbase Wallet | <https://www.coinbase.com/wallet> |
| WalletConnect | <https://walletguide.walletconnect.network/> |
| Rabby | <https://rabby.io/> |

**Collateral:**

Sai accepts USDC from any EVM-chain as well as stNIBI (Nibiru)

- Bridged USDC Address (Stargate): 0x0829F361A05D993d5CEb035cA6DF3446b060970b
- Transactions on Sai require NIBI for gas (**WNIBI**: 0x0CaCF669f8446BeCA826913a3c6B96aCD4b02a97). You can obtain WNIBI using the following options:
  - [Stargate](https://stargate.finance/?srcChain=ethereum&srcToken=0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE&dstChain=nibiru&dstToken=0xcdA5b77E2E2268D9E09c874c1b9A4c3F07b37555) (Powered by LayerZero)
  - [Hyperlane](https://nexus.hyperlane.xyz/?token=0xa582e9e96F5D58A1202ad216E89926283a5dD056&destination=nibiru) (Nexus Bridge)

    **If you’re transferring from a Centralized Exchange (CEX):**

    Purchase ETH, USDC, or NIBI on a CEX, then send the funds to a self-custodied wallet (e.g., Rabby, MetaMask) where you control the private keys. You can then use Stargate or Hyperlane to bridge the funds to Nibiru EVM.

    *Sai will soon offer a gasless experience, soon users will not need gas to sign or run transactions on Sai.*

{% content-ref url="trading/" %}
[Trading on Sai](trading/)
{% endcontent-ref %}

{% content-ref url="slp.md" %}
[Sai Liquidity Provision (SLP)](slp.md)
{% endcontent-ref %}

## User Guides

{% content-ref url="../guides/" %}
[Using Sai](../guides/README.m)
{% endcontent-ref %}

## Why Build on Sai?

Sai gives builders easy to use APIs and real time streams for prices, positions, and funding, so you can ship quickly. Multiple SDKs in common languages let your team work in JavaScript or TypeScript, Python, and more. Because Sai is EVM compatible, you can reuse familiar Solidity tooling, connect standard wallets, and compose with other EVM apps without custom logic.

Nibiru provides a high performance base layer. Transactions confirm quickly, liquidations execute promptly, and oracle reads are responsive. Oracles are available out of the box to settle PnL, manage risk, and inform any app that needs reliable market data.

Liquidity is community directed through SLPs, or Sai Liquidity Positions.

Sai features strong bridge partners such as LayerZero, Stargate, and Hyperlane, making it simple to bring assets in, reach users across chains, and onboard liquidity.

{% content-ref url="../dev/README.md" %}
[Developer Documentation](../dev/README.md)
{% endcontent-ref %}

---

## Sai Updates

**Stay up to date on Sai’s socials:**

- X: <https://x.com/saidotfun>
- Telegram: <https://t.me/saidotfun>
- [Sai Blog](https://docs.sai.fun/blogs)
