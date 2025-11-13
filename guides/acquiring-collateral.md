# Acquiring Collateral

Sai accepts two types of collateral:

- **USDC.e** (bridged USDC)
- **stNIBI** (staked Nibiru tokens)

You'll also need **NIBI** for gas fees to perform transactions on Sai.

---

## Getting NIBI (Gas Token)

NIBI is required for all transactions on Sai. You can acquire it through:

### Centralized Exchanges (CEX)

| Exchange | Link |
|----------|------|
| Binance | [Buy NIBI](https://www.binance.com) |
| Kucoin | [Buy NIBI](https://www.kucoin.com) |
| Gate.io | [Buy NIBI](https://www.gate.io) |

### Decentralized Exchanges (DEX)

| DEX | Network | Link |
|-----|---------|------|
| Osmosis | WasmVM | [Trade on Osmosis](https://app.osmosis.zone) |
| Astrovault | WasmVM | [Trade on Astrovault](https://astrovault.io/) |
| Ichi | EVM | [Trade on Ichi](https://app.ichi.org) |

### Bridging

Limited bridge options available at [app.nibiru.fi/bridge](https://app.nibiru.fi/bridge)

---

## Getting stNIBI (Staked Collateral)

stNIBI is Nibiru's liquid staking token and serves as collateral on Sai.

### Step 1: Acquire NIBI

Follow the steps above to get NIBI tokens.

### Step 2: Liquid Stake NIBI

1. Go to [app.nibiru.fi/stake](https://app.nibiru.fi/stake)
2. Connect your wallet (works with both EVM and WasmVM wallets)
3. Stake your NIBI to receive stNIBI

### Step 3: Cross-Chain Asset Conversion (Optional)

If you need to move stNIBI between EVM and WasmVM networks:

1. Go to [app.nibiru.fi/portfolio](https://app.nibiru.fi/portfolio)
2. Select the stNIBI asset from your table
3. Use the **FunToken** conversion to:
   - Convert stNIBI ERC20 (EVM) → stNIBI bank coin (WasmVM)
   - Convert stNIBI bank coin (WasmVM) → stNIBI ERC20 (EVM)

### Alternative: Trade stNIBI on DEX

Acquire stNIBI directly from decentralized exchanges:

| DEX | Network | Link |
|-----|---------|------|
| Astrovault | WasmVM | [Trade stNIBI](https://astrovault.io/) |
| Skip Swap | WasmVM | [Trade stNIBI](https://app.skip.money) |
| Ichi | EVM | [Trade stNIBI](https://app.ichi.org) |
| Stargate | EVM | [Trade stNIBI](https://stargate.finance) |

---

## Getting USDC.e (Bridged USDC)

USDC.e is ERC20-standard USDC bridged to Nibiru.

### Bridge from Other Chains

Use these bridging protocols to get USDC.e:

| Source | Bridge | Link |
|--------|--------|------|
| Base USDC | Stargate (LayerZero) | [Bridge Base USDC](hhttps://stargate.finance/?srcChain=base&srcToken=0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913&dstChain=nibiru&dstToken=0x0829F361A05D993d5CEb035cA6DF3446b060970b) |
| Arbitrum USDC | Stargate (LayerZero) | [Bridge ARB USDC](https://stargate.finance/?srcChain=arbitrum&srcToken=0xaf88d065e77c8cC2239327C5EDb3A432268e5831&dstChain=nibiru&dstToken=0x0829F361A05D993d5CEb035cA6DF3446b060970b) |
| Avalache USDC | Stargate (LayerZero) | [Bridge AVAX USDC](https://stargate.finance/?srcChain=arbitrum&srcToken=0xaf88d065e77c8cC2239327C5EDb3A432268e5831&dstChain=nibiru&dstToken=0x0829F361A05D993d5CEb035cA6DF3446b060970b) |

### Cross-Chain Asset Conversion (Optional)

If you need to move USDC.e between EVM and WasmVM networks:

1. Go to [app.nibiru.fi/portfolio](https://app.nibiru.fi/portfolio)
2. Select the USDC.e asset from your table
3. Use the **FunToken** conversion to:
   - Convert USDC.e ERC20 (EVM) → USDC bank coin (WasmVM)
   - Convert USDC bank coin (WasmVM) → USDC.e ERC20 (EVM)

---

## Quick Reference

| Collateral | Acquisition | Staking Required | Cross-Chain Support |
|------------|-------------|------------------|---------------------|
| NIBI | CEX, DEX, Bridge | No | Yes (via FunToken) |
| stNIBI | Stake NIBI or DEX | Yes | Yes (via FunToken) |
| USDC.e | Bridge or CEX | No | Yes (via FunToken) |

---

## Need Help?

- Issues with bridging? Check [Wallet Setup](wallet-setup.md)
- Questions about staking? See [Nibiru Docs](https://nibiru.fi/docs)
- Having trouble? Visit [FAQ](../learn/trading/faq.md)
