---
description: Trade, earn, burn.
icon: fire
cover: .gitbook/assets/sai-docs-banner.png
coverY: 0
---

# Intro to Sai

Welcome to **Sai.fun**—a perpetual futures trading platform built on Nibiru. With Sai, you can open leveraged positions (long or short) with low fees and low impact trades, set limit orders, stop-losses and take-profits, or earn yield in a fully onchain trading experience.

{% hint style="info" %}
Sai is in active development with an expected launch in early 2026. The team has finalized a smart contract audit on the core protocol logic, and the web application is under active development.

In the meantime, please [follow Sai on X](https://x.com/saidotfun) to help support us.
{% endhint %}

---

## Learn About Sai

Master the fundamentals of trading on Sai and understand how the platform works.

<table data-view="cards">
  <thead>
    <tr>
      <th></th>
      <th></th>
      <th data-hidden data-card-target data-type="content-ref"></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>About Sai</strong></td>
      <td>Discover how Sai works, its architecture, and what makes it unique in the DeFi trading landscape</td>
      <td><a href="learn/">learn</a></td>
    </tr>
    <tr>
      <td><strong>Trading on Sai</strong></td>
      <td>Learn the essentials of perpetual futures trading including execution, leverage, fees, and price impact</td>
      <td><a href="learn/trading/">trading</a></td>
    </tr>
    <tr>
      <td><strong>Sai Liquidity Positions (SLP)</strong></td>
      <td>Understand Sai Liquidity Positions and how to earn yield by providing liquidity to the platform</td>
      <td><a href="learn/slp.md">slp.md</a></td>
    </tr>
  </tbody>
</table>

## SKILL: Gitbook Preview

Use this when editing Markdown docs and you need a quick local preview without adding package scripts or dependency files to the repo.

**Command**

- Run `bunx --bun docsify-cli@4.4.4 serve . -p 4000 -i README.md` from the repo root.
- Open `http://localhost:4000/`.

**Notes**

- `docsify-cli@4.4.4` is the version confirmed to serve this repo's `README.md` preview.
- The `-i README.md` flag is required because this repo does not have a checked-in `index.html`.
- This is a lightweight preview for Markdown editing. GitBook-specific blocks and production rendering are still handled by GitBook.

### Trading Fundamentals

<table data-view="cards">
  <thead>
    <tr>
      <th></th>
      <th></th>
      <th data-hidden data-card-target data-type="content-ref"></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Executing Trades</strong></td>
      <td>Master market orders, limit orders, stop-losses, and take-profit strategies</td>
      <td><a href="learn/trading/executing-trades.md">executing-trades.md</a></td>
    </tr>
    <tr>
      <td><strong>Leverage and Liquidations</strong></td>
      <td>Understand how leverage works and how to manage liquidation risks effectively</td>
      <td><a href="learn/trading/leverage-and-liquidations.md">leverage-and-liquidations.md</a></td>
    </tr>
    <tr>
      <td><strong>Fees</strong></td>
      <td>Learn about trading fees, funding rates, and how to optimize your trading costs</td>
      <td><a href="learn/trading/fees.md">fees.md</a></td>
    </tr>
    <tr>
      <td><strong>Price Impact</strong></td>
      <td>Understand how your trade size affects execution price and how to minimize slippage</td>
      <td><a href="learn/trading/price-impact.md">price-impact.md</a></td>
    </tr>
    <tr>
      <td><strong>Trading FAQ</strong></td>
      <td>Find answers to common questions about trading on Sai</td>
      <td><a href="learn/trading/faq.md">faq.md</a></td>
    </tr>
  </tbody>
</table>

---

## User Guides

Step-by-step walkthroughs to help you get started and maximize your Sai experience.

<table data-view="cards">
  <thead>
    <tr>
      <th></th>
      <th></th>
      <th data-hidden data-card-target data-type="content-ref"></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Getting Started</strong></td>
      <td>Complete collection of guides for onboarding, wallet setup, acquiring collateral, and more</td>
      <td><a href="guides/">guides</a></td>
    </tr>
    <tr>
      <td><strong>Onboarding</strong></td>
      <td>Your first steps to accessing and using the Sai platform</td>
      <td><a href="guides/onboarding.md">onboarding.md</a></td>
    </tr>
    <tr>
      <td><strong>Wallet Setup</strong></td>
      <td>Learn how to connect your wallet and prepare for trading</td>
      <td><a href="guides/wallet-setup.md">wallet-setup.md</a></td>
    </tr>
    <tr>
      <td><strong>Sai Referral Program</strong></td>
      <td>Earn rewards by referring traders and save on trading fees</td>
      <td><a href="guides/referral.md">referral.md</a></td>
    </tr>
    <tr>
      <td><strong>Acquiring Collateral</strong></td>
      <td>How to obtain the necessary collateral to start trading</td>
      <td><a href="guides/acquiring-collateral.md">acquiring-collateral.md</a></td>
    </tr>
    <tr>
      <td><strong>Choosing a Market</strong></td>
      <td>Select the right trading market for your strategy</td>
      <td><a href="guides/choosing-market.md">choosing-market.md</a></td>
    </tr>
  </tbody>
</table>

---

## For Developers

Build on Sai with comprehensive technical documentation, API references, and integration guides.

<table data-view="cards">
  <thead>
    <tr>
      <th></th>
      <th></th>
      <th data-hidden data-card-target data-type="content-ref"></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Getting Started</strong></td>
      <td>Begin integrating with Sai - includes EVM and WASM integration guides</td>
      <td><a href="dev/">dev</a></td>
    </tr>
    <tr>
      <td><strong>Sai Core</strong></td>
      <td>Deep dive into the core contracts including perp contract, borrowing module, and state variables</td>
      <td><a href="dev/sai-core/">sai-core</a></td>
    </tr>
    <tr>
      <td><strong>Sai Keeper</strong></td>
      <td>Complete GraphQL API documentation for querying positions, liquidity, oracles, fees, and more</td>
      <td><a href="dev/sai-keeper/">sai-keeper</a></td>
    </tr>
    <tr>
      <td><strong>Use Cases</strong></td>
      <td>Practical integration examples including Telegram bot development</td>
      <td><a href="dev/use-cases/">use-cases</a></td>
    </tr>
  </tbody>
</table>

### Developer Resources

<table data-view="cards">
  <thead>
    <tr>
      <th></th>
      <th></th>
      <th data-hidden data-card-target data-type="content-ref"></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>EVM Integration Guide</strong></td>
      <td>Connect to Sai from EVM-compatible chains and applications</td>
      <td><a href="dev/evm-guide.md">evm-guide.md</a></td>
    </tr>
    <tr>
      <td><strong>WASM Integration Guide</strong></td>
      <td>Integrate with Sai using CosmWasm smart contracts</td>
      <td><a href="dev/wasm-guide.md">wasm-guide.md</a></td>
    </tr>
    <tr>
      <td><strong>Contract Addresses</strong></td>
      <td>Reference for all deployed contract addresses on mainnet and testnet</td>
      <td><a href="dev/sai-core/contracts.md">contracts.md</a></td>
    </tr>
    <tr>
      <td><strong>Perp API</strong></td>
      <td>Query and subscribe to perpetual futures data including positions and markets</td>
      <td><a href="dev/sai-keeper/api-perp.md">api-perp.md</a></td>
    </tr>
  </tbody>
</table>

---

## Why Sai?

- **Oracle settlement**: Simple and easy price behavior so there's no internal surprises. We rely on a combination of Nibiru's Oracle, which aggregates prices from leading exchanges like Binance, Bybit, and OKX through Nibiru's decentralized validator network, and custom feeds for certain markets.

- **Leverage**: Amplify your exposure with up to 100x leverage (exact max set by each market and pairs).

- **Simple On-Chain Experience**: Manage everything in one intuitive UI, leveraging one click trading, automated order triggering, etc.

- **Custom Orders**: Market, limit, stop, and advanced triggers for Take Profits and Stop Losses.

Use the sidebar navigation to jump to any topic or type a keyword (e.g. "leverage," "limit order") in the search bar.

---

## Resources

<table data-view="cards">
  <thead>
    <tr>
      <th></th>
      <th></th>
      <th data-hidden data-card-target data-type="content-ref"></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Community</strong></td>
      <td>Join the Sai community on social channels and stay connected</td>
      <td><a href="community.md">community.md</a></td>
    </tr>
    <tr>
      <td><strong>Blog</strong></td>
      <td>Read the latest updates, announcements, and insights from the Sai team</td>
      <td><a href="blogs/">blogs</a></td>
    </tr>
    <tr>
      <td><strong>Legal</strong></td>
      <td>Terms of use, disclosures, and legal documentation</td>
      <td><a href="legal/">legal</a></td>
    </tr>
  </tbody>
</table>

---

## Stay Connected

**Follow Sai for the latest updates:**

<table data-header-hidden>
  <thead>
    <tr>
      <th width="244"></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>X / Twitter</td>
      <td><a href="https://x.com/SaiDotFun">@SaiDotFun</a></td>
    </tr>
    <tr>
      <td>Telegram News Channel</td>
      <td><a href="https://t.me/saidotfun">t.me/saidotfun</a></td>
    </tr>
    <tr>
      <td>Instagram</td>
      <td><a href="https://instagram.com/saidotfun">instagram.com/saidotfun</a></td>
    </tr>
    <tr>
      <td>TikTok</td>
      <td><a href="https://www.tiktok.com/@saidotfun">@saidotfun</a></td>
    </tr>
    <tr>
      <td>Blog</td>
      <td><a href="https://docs.sai.fun/blogs">Sai Blog</a></td>
    </tr>
  </tbody>
</table>
