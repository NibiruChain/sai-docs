---
icon: code
cover: ../.gitbook/assets/sai-banner-guides-1500x500.png
coverY: 0
---

# Sai – EVM Integration Guide

How to drive Sai using an **EVM signer** through the EVM Interface contract. You pass a JSON‑encoded WASM message (`wasmMsgBytes`) along with token amounts/addresses.

---

## 0. Getting Started

### Prerequisites

* Node.js ≥ 18
* pnpm, npm, or yarn

### New Project

```bash
mkdir sai-evm && cd sai-evm
pnpm init -y
pnpm add ethers bignumber.js
pnpm add -D typescript ts-node @types/node dotenv
npx tsc --init --target ES2022 --module NodeNext --moduleResolution NodeNext
```

> If you also want to call the Cosmos side in the same app, add: `@nibiruchain/nibijs @cosmjs/cosmwasm-stargate @cosmjs/stargate cosmjs-types`.

### Environment Setup

Create a `.env` file with your configuration:

```bash
# Testnet-1
EVM_RPC=https://evm-rpc.testnet-1.nibiru.fi/

# Or Mainnet
# EVM_RPC=https://evm-rpc.nibiru.fi/

PRIVATE_KEY=0x... # Your private key (keep this secret!)
INTERFACE_ADDR=0x... # Contract address from saiEvmInterfaceFromChainType(chainType)
```

### Bootstrap Provider + Signer

```ts
// src/evm.ts
import "dotenv/config"
import { ethers } from "ethers"

export function makeSigner() {
  const rpc = process.env.EVM_RPC!
  const pk = process.env.PRIVATE_KEY!
  const provider = new ethers.JsonRpcProvider(rpc)
  const signer = new ethers.Wallet(pk, provider)
  return { provider, signer }
}
```

### Interface ABI

Import the ABI that exposes these methods: `openTrade`, `executeSimpleFunctions`, `deposit`, `makeWithdrawRequest`, `redeem`, and `executeVaultSimpleFunctions`.

```ts
import PerpVaultEvmInterfaceAbi from "./PerpVaultEvmInterface.json" // Place your ABI file here
```

### Gas Estimation Helpers

```ts
const GAS_BUFFER_NUMERATOR = 11n
const GAS_BUFFER_DENOMINATOR = 10n
const FALLBACK_GAS_LIMIT = 5_000_000n
const FALLBACK_GAS_PRICE = ethers.parseUnits("1", "gwei")

const withGasBuffer = (g: bigint) =>
  g === 0n ? 1n : (g * GAS_BUFFER_NUMERATOR) / GAS_BUFFER_DENOMINATOR

async function estimateGasWithFallback(
  fn: () => Promise<bigint>,
  info?: unknown
) {
  try {
    const est = await fn()
    return { gasLimit: withGasBuffer(est) }
  } catch (error) {
    console.warn("Gas estimation failed, using fallback", info)
    return { gasLimit: FALLBACK_GAS_LIMIT, gasPrice: FALLBACK_GAS_PRICE }
  }
}

const toTxOverrides = ({
  gasLimit,
  gasPrice,
}: {
  gasLimit: bigint
  gasPrice?: bigint
}) => (gasPrice === undefined ? { gasLimit } : { gasLimit, gasPrice })
```

---

## 1. Collateral / Payment Tokens

### Decimal Handling

* **BANK units** use **6 decimals** (Cosmos side)
* **ERC‑20 units** use the token's decimals (typically 6)

### Testnet-1

| Token | ERC-20 Address |
|-------|---|
| **USDC** | `0xAb68f1D1d91854383fd4Df9016E3040D03e8191a` |
| **stNIBI** | `0xCae3d404AFB50016154a4B18091351065154E9bD` |

### Mainnet

| Token | ERC-20 Address |
|-------|---|
| **USDC** | `0x0829F361A05D993d5CEb035cA6DF3446b060970b` |
| **stNIBI** | `0xcA0a9Fb5FBF692fa12fD13c0A900EC56Bb3f0a7b` |

### Converting Between Decimals

When combining BANK and ERC-20 amounts, ensure both use BANK units (6 decimals) before summing:

```ts
const toBankUnits = (
  amt: bigint,
  sourceDecimals: number,
  bankDecimals: number = 6
): bigint => {
  if (sourceDecimals === bankDecimals) return amt
  const diff = Math.abs(sourceDecimals - bankDecimals)
  const factor = 10n ** BigInt(diff)
  return sourceDecimals > bankDecimals ? amt / factor : amt * factor
}
```

---

## 2. Perps – Open Trade

### Method Signature

```ts
contract.openTrade(
  wasmMsgBytes,           // JSON-encoded WASM message with is_evm_origin: true
  collateralIndex,        // Token index (e.g., 0 for first collateral)
  totalAmountBankUnits,   // Total amount in BANK units
  useErc20Amount,         // ERC-20 amount in token decimals
  overrides                // Gas overrides
)
```

### Example

```ts
import { ethers } from "ethers"
import BigNumber from "bignumber.js"
import PerpVaultEvmInterfaceAbi from "./PerpVaultEvmInterface.json"
import { makeSigner } from "./evm"

async function openTrade() {
  const { signer } = makeSigner()
  const iface = new ethers.Contract(
    process.env.INTERFACE_ADDR!,
    PerpVaultEvmInterfaceAbi.abi,
    signer
  )

  const msg = {
    open_trade: {
      market_index: "MarketIndex(0)",
      leverage: "5",
      long: true,
      collateral_index: "TokenIndex(0)",
      trade_type: "trade",
      open_price: "70000",
      tp: undefined,
      sl: undefined,
      slippage_p: "1",
      is_evm_origin: true, // IMPORTANT: Set to true for EVM origin
    },
  }

  const bankDecimals = 6
  const erc20Decimals = 6
  const displayAmount = new BigNumber("100")
  const bankAmount = ethers.parseUnits(displayAmount.toString(), bankDecimals)
  const erc20Amount = ethers.parseUnits(displayAmount.toString(), erc20Decimals)

  const toBankUnits = (
    amt: bigint,
    ercDec: number,
    bankDec: number
  ): bigint => {
    if (ercDec === bankDec) return amt
    const diff = Math.abs(ercDec - bankDec)
    const factor = 10n ** BigInt(diff)
    return ercDec > bankDec ? amt / factor : amt * factor
  }

  const totalBank = bankAmount + toBankUnits(erc20Amount, erc20Decimals, bankDecimals)
  const wasmMsgBytes = ethers.toUtf8Bytes(JSON.stringify(msg))

  const gas = await estimateGasWithFallback(() =>
    iface.openTrade.estimateGas(wasmMsgBytes, 0, totalBank, erc20Amount)
  )

  const tx = await iface.openTrade(
    wasmMsgBytes,
    0,
    totalBank,
    erc20Amount,
    toTxOverrides(gas)
  )
  console.log("Transaction submitted:", tx.hash)

  const receipt = await tx.wait()
  console.log("Mined in block:", receipt?.blockNumber)
}
```

---

## 3. Perps – Close Trade

Close an open position:

```ts
async function closeTrade() {
  const { signer } = makeSigner()
  const iface = new ethers.Contract(
    process.env.INTERFACE_ADDR!,
    PerpVaultEvmInterfaceAbi.abi,
    signer
  )

  const msg = { close_trade: { trade_index: "UserTradeIndex(0)" } }
  const wasmMsgBytes = ethers.toUtf8Bytes(JSON.stringify(msg))

  const gas = await estimateGasWithFallback(() =>
    iface.executeSimpleFunctions.estimateGas(wasmMsgBytes)
  )

  const tx = await iface.executeSimpleFunctions(wasmMsgBytes, toTxOverrides(gas))
  const receipt = await tx.wait()
  console.log("Trade closed in block:", receipt?.blockNumber)
}
```

---

## 4. Referral – Create & Redeem Codes

### Create a Referral Code

```ts
async function createReferralCode() {
  const { signer } = makeSigner()
  const iface = new ethers.Contract(
    process.env.INTERFACE_ADDR!,
    PerpVaultEvmInterfaceAbi.abi,
    signer
  )

  const msg = { create_referrer_code: { code: "MYCODE" } }
  const bytes = ethers.toUtf8Bytes(JSON.stringify(msg))

  const gas = await estimateGasWithFallback(() =>
    iface.executeSimpleFunctions.estimateGas(bytes)
  )

  const tx = await iface.executeSimpleFunctions(bytes, toTxOverrides(gas))
  await tx.wait()
  console.log("Referral code created")
}
```

### Redeem a Referral Code

```ts
async function redeemReferralCode() {
  const { signer } = makeSigner()
  const iface = new ethers.Contract(
    process.env.INTERFACE_ADDR!,
    PerpVaultEvmInterfaceAbi.abi,
    signer
  )

  const msg = { redeem_referrer_code: { code: "PARTNER" } }
  const bytes = ethers.toUtf8Bytes(JSON.stringify(msg))

  const gas = await estimateGasWithFallback(() =>
    iface.executeSimpleFunctions.estimateGas(bytes)
  )

  const tx = await iface.executeSimpleFunctions(bytes, toTxOverrides(gas))
  await tx.wait()
  console.log("Referral code redeemed")
}
```

---

## 5. Vault – Deposit

Deposit collateral into a vault:

```ts
async function depositToVault() {
  const { signer } = makeSigner()
  const iface = new ethers.Contract(
    process.env.INTERFACE_ADDR!,
    PerpVaultEvmInterfaceAbi.abi,
    signer
  )

  const msg = { deposit: {} }
  const bytes = ethers.toUtf8Bytes(JSON.stringify(msg))

  const bankDecimals = 6
  const erc20Decimals = 6
  const bankAmount = ethers.parseUnits("250", bankDecimals)
  const erc20Amount = ethers.parseUnits("250", erc20Decimals)

  const toBankUnits = (
    amt: bigint,
    ercDec: number,
    bankDec: number
  ): bigint => {
    if (ercDec === bankDec) return amt
    const diff = Math.abs(ercDec - bankDec)
    const factor = 10n ** BigInt(diff)
    return ercDec > bankDec ? amt / factor : amt * factor
  }

  const totalBank = bankAmount + toBankUnits(erc20Amount, erc20Decimals, bankDecimals)

  const vaultAddr = "<bech32 vault address>"
  const collateralErc20 = "<erc20 token address>"

  const gas = await estimateGasWithFallback(() =>
    iface.deposit.estimateGas(
      bytes,
      totalBank,
      erc20Amount,
      vaultAddr,
      collateralErc20,
      true
    )
  )

  const tx = await iface.deposit(
    bytes,
    totalBank,
    erc20Amount,
    vaultAddr,
    collateralErc20,
    true,
    toTxOverrides(gas)
  )
  await tx.wait()
  console.log("Deposited to vault")
}
```

---

## 6. Vault – Make Withdraw Request

Request to withdraw funds from a vault:

```ts
async function makeWithdrawRequest() {
  const { signer } = makeSigner()
  const iface = new ethers.Contract(
    process.env.INTERFACE_ADDR!,
    PerpVaultEvmInterfaceAbi.abi,
    signer
  )

  const msg = { make_withdraw_request: {} }
  const bytes = ethers.toUtf8Bytes(JSON.stringify(msg))

  const sharesBank = 1_000_000n // 1.0 shares in BANK units
  const sharesFromErc20 = 0n
  const totalShares = sharesBank + sharesFromErc20

  const vaultAddr = "<vault address>"

  const gas = await estimateGasWithFallback(() =>
    iface.makeWithdrawRequest.estimateGas(vaultAddr, bytes, totalShares, sharesFromErc20)
  )

  const tx = await iface.makeWithdrawRequest(
    vaultAddr,
    bytes,
    totalShares,
    sharesFromErc20,
    toTxOverrides(gas)
  )
  await tx.wait()
  console.log("Withdraw request created")
}
```

---

## 7. Vault – Redeem

Redeem shares from a vault:

```ts
async function redeemVaultShares() {
  const { signer } = makeSigner()
  const iface = new ethers.Contract(
    process.env.INTERFACE_ADDR!,
    PerpVaultEvmInterfaceAbi.abi,
    signer
  )

  const msg = { redeem: { shares: "500000" } } // 0.5 shares
  const bytes = ethers.toUtf8Bytes(JSON.stringify(msg))

  const vaultAddr = "<vault address>"
  const sendToEvm = true

  const gas = await estimateGasWithFallback(() =>
    iface.redeem.estimateGas(bytes, vaultAddr, "500000", sendToEvm)
  )

  const tx = await iface.redeem(
    bytes,
    vaultAddr,
    "500000",
    sendToEvm,
    toTxOverrides(gas)
  )
  await tx.wait()
  console.log("Shares redeemed")
}
```

---

## 8. Vault – Cancel Withdraw Request

Cancel a pending withdraw request:

```ts
async function cancelWithdrawRequest() {
  const { signer } = makeSigner()
  const iface = new ethers.Contract(
    process.env.INTERFACE_ADDR!,
    PerpVaultEvmInterfaceAbi.abi,
    signer
  )

  const msg = { cancel_withdraw_request: { unlock_epoch: 123 } }
  const bytes = ethers.toUtf8Bytes(JSON.stringify(msg))

  const vaultAddr = "<vault address>"

  const gas = await estimateGasWithFallback(() =>
    iface.executeVaultSimpleFunctions.estimateGas(bytes, vaultAddr)
  )

  const tx = await iface.executeVaultSimpleFunctions(
    bytes,
    vaultAddr,
    toTxOverrides(gas)
  )
  await tx.wait()
  console.log("Withdraw request cancelled")
}
```

---

## Error Handling & Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| **"No EVM signer"** | Ensure `makeSigner()` is called and `PRIVATE_KEY` is set in `.env` |
| **Gas estimation fails** | The function automatically falls back to `5,000,000` gas limit and `1 gwei` price |
| **Transaction reverts on-chain** | Use `debug_traceTransaction` on your archive RPC to inspect the deepest call error |
| **Decimal conversion errors** | Always convert ERC-20 and BANK amounts to the same decimal base before summing |
| **Invalid INTERFACE_ADDR** | Verify the address matches your network (Testnet-1 vs Mainnet) |

### Best Practices

* Always use an **EVM signer** (provider alone cannot send transactions)
* Apply gas buffering to avoid "out of gas" errors
* Validate that `is_evm_origin: true` is set in all trade messages
* Convert token decimals correctly before combining BANK and ERC-20 amounts
* Store `PRIVATE_KEY` securely and never commit it to version control
