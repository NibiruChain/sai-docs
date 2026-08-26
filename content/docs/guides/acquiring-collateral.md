---
title: "Acquiring Collateral"
description: "Obtain USDC for trading on Sai."
---

Sai accepts **USDC** as collateral.

Trading on Sai is gasless. You do not need NIBI to sign or
submit transactions.

***

## Getting USDC

USDC on Sai is ERC20-standard USDC bridged to Nibiru.

### Bridge from Other Chains

Use these bridging protocols to get USDC:

| Source        | Bridge               | Link                                                                                                                                                                                       |
| ------------- | -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Base USDC     | Stargate (LayerZero) | [Bridge Base USDC](https://stargate.finance/?srcChain=base\&srcToken=0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913\&dstChain=nibiru\&dstToken=0x0829F361A05D993d5CEb035cA6DF3446b060970b)    |
| Arbitrum USDC | Stargate (LayerZero) | [Bridge ARB USDC](https://stargate.finance/?srcChain=arbitrum\&srcToken=0xaf88d065e77c8cC2239327C5EDb3A432268e5831\&dstChain=nibiru\&dstToken=0x0829F361A05D993d5CEb035cA6DF3446b060970b)  |
| Avalache USDC | Stargate (LayerZero) | [Bridge AVAX USDC](https://stargate.finance/?srcChain=arbitrum\&srcToken=0xaf88d065e77c8cC2239327C5EDb3A432268e5831\&dstChain=nibiru\&dstToken=0x0829F361A05D993d5CEb035cA6DF3446b060970b) |

### Cross-Chain Asset Conversion (Optional)

If you need to move USDC between EVM and WasmVM networks:

1. Go to [app.nibiru.fi/portfolio](https://app.nibiru.fi/portfolio)
2. Select the USDC asset from your table
3. Use the **FunToken** conversion to:
   * Convert USDC ERC20 (EVM) → USDC bank coin (WasmVM)
   * Convert USDC bank coin (WasmVM) → USDC ERC20 (EVM)

***

## Quick Reference

| Asset  | Acquisition   | Used as collateral | Cross-Chain Support |
| ------ | ------------- | ------------------ | ------------------- |
| USDC   | Bridge or CEX | Yes                | Yes (via FunToken)  |

***

## Need Help?

* Issues with bridging? Check [Wallet Setup](/docs/guides/wallet-setup/)
* Having trouble? Visit [FAQ](/docs/learn/trading/faq/)

***

## Appendix: stNIBI

stNIBI is Nibiru's liquid staking token. It is not part of
the USDC collateral path above. Use this section only if you
already hold NIBI or stNIBI and want to move it onto Nibiru.

### Getting NIBI

You can acquire NIBI through:

#### Centralized Exchanges (CEX)

| Exchange | Link                                  |
| -------- | ------------------------------------- |
| ByBit    | [Buy NIBI](https://www.bybit.com/en/) |
| Kucoin   | [Buy NIBI](https://www.kucoin.com)    |
| Gate.io  | [Buy NIBI](https://www.gate.io)       |
| MEXC     | [Buy NIBI](https://www.mexc.com/)     |

#### Decentralized Exchanges (DEX)

| DEX        | Network | Link                                                                                                                                                              |
| ---------- | ------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Oku        | EVM     | [Trade on Oku](https://oku.trade/swap?inputChain=nibiru\&inToken=0x0829F361A05D993d5CEb035cA6DF3446b060970b\&outToken=0x0CaCF669f8446BeCA826913a3c6B96aCD4b02a97) |
| Osmosis    | WasmVM  | [Trade on Osmosis](https://app.osmosis.zone)                                                                                                                      |
| Astrovault | WasmVM  | [Trade on Astrovault](https://astrovault.io/)                                                                                                                     |

#### Bridging

| Bridge   | Link                                                                                                                                                                             |
| -------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Nibiru   | [Bridge](https://app.nibiru.fi/bridge)                                                                                                                                           |
| Stargate | [Bridge](https://stargate.finance/?srcChain=ethereum\&srcToken=0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48\&dstChain=nibiru\&dstToken=0x0829F361A05D993d5CEb035cA6DF3446b060970b) |

### Getting stNIBI

#### Step 1: Acquire NIBI

Follow the steps above to get NIBI tokens.

#### Step 2: Liquid Stake NIBI

1. Go to [app.nibiru.fi/stake](https://app.nibiru.fi/stake)
2. Connect your wallet (works with both EVM and WasmVM wallets)
3. Stake your NIBI to receive stNIBI

#### Step 3: Cross-Chain Asset Conversion (Optional)

If you need to move stNIBI between EVM and WasmVM networks:

1. Go to [app.nibiru.fi/portfolio](https://app.nibiru.fi/portfolio)
2. Select the stNIBI asset from your table
3. Use the **FunToken** conversion to:
   * Convert stNIBI ERC20 (EVM) → stNIBI Bank Coin (WasmVM)
   * Convert stNIBI Bank Coin (WasmVM) → stNIBI ERC20 (EVM)

#### Alternative: Trade stNIBI on DEX

Acquire stNIBI directly from decentralized exchanges:

| DEX        | Network | Link                                                                                                                                                              |
| ---------- | ------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Oku        | EVM     | [Trade stNIBI](https://oku.trade/swap?inputChain=nibiru\&inToken=0x0829F361A05D993d5CEb035cA6DF3446b060970b\&outToken=0xcA0a9Fb5FBF692fa12fD13c0A900EC56Bb3f0a7b) |
| Stargate   | EVM     | [Trade stNIBI](https://stargate.finance)                                                                                                                          |
| Astrovault | WasmVM  | [Trade stNIBI](https://astrovault.io/)                                                                                                                            |
| Skip Swap  | WasmVM  | [Trade stNIBI](https://app.skip.money)                                                                                                                            |
