# Introducing Sai: Nibiru’s Perpetuals DEX

<figure>
  <picture>
    <source
      srcset="
        .gitbook/assets/blog_1/sai-is-coming.png
      "
      media="(prefers-color-scheme: dark)"
    />
    <img
      src=".gitbook/assets/blog_1/sai-is-coming.png"
      alt="Sai is Coming"
    />
  </picture>
  <figcaption>Trading made simple. Perps without limits.</figcaption>
</figure>

Over the last few years, crypto trading has moved from spot markets to derivatives. Perpetual futures, or perps, now drive most activity, and a new wave of perpetual DEX apps has proven that crypto perpetual futures are the product many traders care about most.

Crypto trading has evolved, but the user experience hasn't kept up. Traders are still forced to choose: the performance of a CEX, or the security of a DEX.

Sai is a decentralized perpetuals platform built to deliver CEX-level performance with an intuitive UX and reliable settlement. The system provides easy access to yield, reinforces collateral and features protection within the trading experience. Traders get a familiar, streamlined workflow, while liquidity providers gain a transparent path to earning from real activity.

<figure>
  <picture>
    <source
      srcset="
        .gitbook/assets/blog_1/why-sai-slide.png
      "
      media="(prefers-color-scheme: dark)"
    />
    <img
      src=".gitbook/assets/blog_1/why-sai-slide.png"
      alt="Sai is Coming"
    />
  </picture>
  <figcaption>Trading made simple. Perps without limits.</figcaption>
</figure>

<figure>
  <picture>
    <source
      srcset="
        .gitbook/assets/blog_1/sai-trading.png
      "
      media="(prefers-color-scheme: dark)"
    />
    <img
      src=".gitbook/assets/blog_1/sai-trading.png"
      alt="Sai is Coming"
    />
  </picture>
  <figcaption>Sai’s Trading Interface</figcaption>
</figure>

## What Traders Get with Sai

<figure>
  <picture>
    <source
      srcset="
        .gitbook/assets/blog_1/sai-fair-pricing-concept.png.png
      "
      media="(prefers-color-scheme: dark)"
    />
    <img
      src=".gitbook/assets/blog_1/sai-fair-pricing-concept.png.png"
      alt="Sai is Coming"
    />
  </picture>
  <figcaption>Fair Pricing Concept</figcaption>
</figure>

<figure>
  <picture>
    <source
      srcset="
        .gitbook/assets/blog_1/sai-trading.png
      "
      media="(prefers-color-scheme: dark)"
    />
    <img
      src=".gitbook/assets/blog_1/sai-trading.png"
      alt="Sai is Coming"
    />
  </picture>
  <figcaption>Sai’s Trading Interface</figcaption>
</figure>

## How Does Sai Handle Liquidations?

Liquidations are where most perp platforms break during liquidity crunches. [The Oct 10 flash crash](https://www.coindesk.com/opinion/2025/12/02/why-the-market-crashed-on-october-10-and-why-it-s-struggling-to-bounce) showed how a sharp move on one venue can trigger a chain of forced closes, even when the broader market never truly traded there.

Sai liquidates using onchain rules and a global oracle price, not a thin local order book. Validator feeders pull prices from multiple venues using a commit then reveal flow. The chain only accepts updates when participation clears a threshold, then publishes a weighted median price. If data is stale or participation is low, Sai uses the last good price and caps large moves so a single bad update does not snowball into unfair liquidations.

Liquidation is meant to be a last resort. Sai uses a deep buffer, with liquidations only triggering once losses and fees have consumed roughly 90 percent of posted collateral. Your liquidation price is deterministic and includes fees, so it is predictable. If you set a stop loss that would exit earlier than liquidation, Sai prioritizes the stop loss instead of forcing a liquidation. Any remaining collateral after closing costs is returned to the trader.

### Built for stress

- Oracle guardrails (multi source median, participation checks, last good price fallback, capped large moves)
- Exposure limits so single markets do not get dangerously crowded
- Stop loss checks so orders cannot be set in a way that only triggers after liquidation
- Onchain enforcement with permissionless triggering, so execution stays fast and transparent when markets move quickly
