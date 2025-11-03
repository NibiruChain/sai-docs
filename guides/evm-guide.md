# Sai – EVM Integration Guide

How to drive Sai using an **EVM signer** through the EVM Interface contract. You pass a JSON‑encoded WASM message (`wasmMsgBytes`) along with token amounts/addresses.

---

## 0. Getting Started

### Prereqs

* Node.js ≥ 18, pnpm (or npm/yarn)

### New Project

```bash
mkdir sai-evm && cd sai-evm
pnpm init -y
pnpm add ethers bignumber.js
pnpm add -D typescript ts-node @types/node
npx tsc --init --target ES2022 --module NodeNext --moduleResolution NodeNext
```

> If you also want to call Cosmos side in the same app, add: `@nibiruchain/nibijs @cosmjs/cosmwasm-stargate @cosmjs/stargate cosmjs-types`.

### Minimal Env

```bash
EVM_RPC=https://evm.testnet-2.nibiru.fi # example
PRIVATE_KEY=0x...
INTERFACE_ADDR=0x... # from saiEvmInterfaceFromChainType(chainType)
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

Use the ABI that exposes methods used below (`openTrade`, `executeSimpleFunctions`, `deposit`, `makeWithdrawRequest`, `redeem`, `executeVaultSimpleFunctions`).

```ts
import PerpVaultEvmInterfaceAbi from "./PerpVaultEvmInterface.json" // place your ABI here
```

### Helpers

```ts
const GAS_BUFFER_NUMERATOR = 11n, GAS_BUFFER_DENOMINATOR = 10n
const FALLBACK_GAS_LIMIT = 5_000_000n
const FALLBACK_GAS_PRICE = ethers.parseUnits("1", "gwei")

const withGasBuffer = (g: bigint) => g === 0n ? 1n : (g * GAS_BUFFER_NUMERATOR) / GAS_BUFFER_DENOMINATOR

async function estimateGasWithFallback(fn: () => Promise<bigint>, info?: unknown) {
  try {
    const est = await fn()
    return { gasLimit: withGasBuffer(est) }
  } catch {
    return { gasLimit: FALLBACK_GAS_LIMIT, gasPrice: FALLBACK_GAS_PRICE }
  }
}

const toTxOverrides = ({ gasLimit, gasPrice }: { gasLimit: bigint; gasPrice?: bigint }) =>
  gasPrice === undefined ? { gasLimit } : { gasLimit, gasPrice }
```

---

## 1. Collateral / Payment Tokens

When passing amounts:

* **BANK units** use **6 decimals** (Cosmos side)
* **ERC‑20 units** use the token’s decimals (default 6 here)

### Testnet‑2

* **USDC** ERC‑20: `0xAb68f1D1d91854383fd4Df9016E3040D03e8191a`
* **stNIBI** ERC‑20: `0xCae3d404AFB50016154a4B18091351065154E9bD`

### Mainnet

* **USDC** ERC‑20: `0x0829F361A05D993d5CEb035cA6DF3446b060970b`
* **stNIBI** ERC‑20: `0xcA0a9Fb5FBF692fa12fD13c0A900EC56Bb3f0a7b`

> Convert ERC‑20 portion to BANK units (6‑dec) before summing into `total` when the interface expects a total BANK amount.

---

## 2. Perps – Open Trade

**Method**

```
contract.openTrade(
  wasmMsgBytes,          // JSON-encoded { open_trade: { ... is_evm_origin: true } }
  collateralIndex,       // number from "TokenIndex(N)"
  totalAmountBankUnits,  // BANK units = bankAmount + erc20Amount(converted -> BANK)
  useErc20Amount,        // ERC-20 units in token decimals
  overrides
)
```

**Example**

```ts
import { ethers } from "ethers"
import BigNumber from "bignumber.js"
import PerpVaultEvmInterfaceAbi from "./PerpVaultEvmInterface.json"
import { makeSigner } from "./evm"

async function openTrade() {
  const { signer } = makeSigner()
  const iface = new ethers.Contract(process.env.INTERFACE_ADDR!, PerpVaultEvmInterfaceAbi.abi, signer)

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
      is_evm_origin: true,
    },
  }

  const bankDecimals = 6
  const erc20Decimals = 6
  const displayAmount = new BigNumber("100")
  const bankAmount = ethers.parseUnits(displayAmount.toString(), bankDecimals)
  const erc20Amount = ethers.parseUnits(displayAmount.toString(), erc20Decimals)

  const toBankUnits = (amt: bigint, ercDec: number, bankDec: number) => {
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

  const tx = await iface.openTrade(wasmMsgBytes, 0, totalBank, erc20Amount, toTxOverrides(gas))
  console.log("submitted:", tx.hash)
  const rcpt = await tx.wait()
  console.log("mined in block:", rcpt.blockNumber)
}
```

---

## 3. Perps – Close Trade

```ts
const msg = { close_trade: { trade_index: "UserTradeIndex(0)" } }
const wasmMsgBytes = ethers.toUtf8Bytes(JSON.stringify(msg))
const gas = await estimateGasWithFallback(() => iface.executeSimpleFunctions.estimateGas(wasmMsgBytes))
const tx = await iface.executeSimpleFunctions(wasmMsgBytes, toTxOverrides(gas))
await tx.wait()
```

---

## 4. Referral – Create & Redeem

```ts
// Create
let msg = { create_referrer_code: { code: "MYCODE" } }
let bytes = ethers.toUtf8Bytes(JSON.stringify(msg))
let gas = await estimateGasWithFallback(() => iface.executeSimpleFunctions.estimateGas(bytes))
await (await iface.executeSimpleFunctions(bytes, toTxOverrides(gas))).wait()

// Redeem
msg = { redeem_referrer_code: { code: "PARTNER" } }
bytes = ethers.toUtf8Bytes(JSON.stringify(msg))
gas = await estimateGasWithFallback(() => iface.executeSimpleFunctions.estimateGas(bytes))
await (await iface.executeSimpleFunctions(bytes, toTxOverrides(gas))).wait()
```

---

## 5. Vault – Deposit

```ts
const msg = { deposit: {} }
const bytes = ethers.toUtf8Bytes(JSON.stringify(msg))
const bankDecimals = 6
const erc20Decimals = 6
const bankAmount = ethers.parseUnits("250", bankDecimals)
const erc20Amount = ethers.parseUnits("250", erc20Decimals)

const toBankUnits = (amt: bigint, ercDec: number, bankDec: number) => {
  if (ercDec === bankDec) return amt
  const diff = Math.abs(ercDec - bankDec)
  const factor = 10n ** BigInt(diff)
  return ercDec > bankDec ? amt / factor : amt * factor
}
const totalBank = bankAmount + toBankUnits(erc20Amount, erc20Decimals, bankDecimals)

const vaultAddr = "<bech32 vault>"
const collateralErc20 = "<erc20 address>"
const gas = await estimateGasWithFallback(() =>
  iface.deposit.estimateGas(bytes, totalBank, erc20Amount, vaultAddr, collateralErc20, true)
)
await (await iface.deposit(bytes, totalBank, erc20Amount, vaultAddr, collateralErc20, true, toTxOverrides(gas))).wait()
```

---

## 6. Vault – Make Withdraw Request

```ts
const msg = { make_withdraw_request: {} }
const bytes = ethers.toUtf8Bytes(JSON.stringify(msg))
const sharesBank = 1_000_000n
const sharesFromErc20 = 0n
const totalShares = sharesBank + sharesFromErc20
const gas = await estimateGasWithFallback(() =>
  iface.makeWithdrawRequest.estimateGas("<vault>", bytes, totalShares, sharesFromErc20)
)
await (await iface.makeWithdrawRequest("<vault>", bytes, totalShares, sharesFromErc20, toTxOverrides(gas))).wait()
```

---

## 7. Vault – Redeem

```ts
const msg = { redeem: { shares: "500000" } }
const bytes = ethers.toUtf8Bytes(JSON.stringify(msg))
const sendToEvm = true
const gas = await estimateGasWithFallback(() =>
  iface.redeem.estimateGas(bytes, "<vault>", "500000", sendToEvm)
)
await (await iface.redeem(bytes, "<vault>", "500000", sendToEvm, toTxOverrides(gas))).wait()
```

---

## 8. Vault – Cancel Withdraw Request

```ts
const msg = { cancel_withdraw_request: { unlock_epoch: 123 } }
const bytes = ethers.toUtf8Bytes(JSON.stringify(msg))
const gas = await estimateGasWithFallback(() =>
  iface.executeVaultSimpleFunctions.estimateGas(bytes, "<vault>")
)
await (await iface.executeVaultSimpleFunctions(bytes, "<vault>", toTxOverrides(gas))).wait()
```

---

## Error Patterns & Tips

* Always ensure an **EVM signer** is present (provider alone can’t send txs).
* Use padded gas; fall back to `5,000,000` and `1 gwei` if estimation fails.
* If a tx reverts on chain, inspect the revert reason via your archive RPC (`debug_traceTransaction`) and surface the deepest call error.
* When combining BANK + ERC‑20 amounts for totals, convert decimals correctly before summing.
