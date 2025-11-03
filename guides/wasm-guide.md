# Sai – WASM Integration Guide

End‑to‑end instructions for interacting with **Sai** from the Cosmos (WASM) side using `NibiruTxClient`.

---

## 0. Getting Started

### Prereqs

* Node.js ≥ 18
* pnpm (or npm/yarn)

### New Project

```bash
mkdir sai-wasm && cd sai-wasm
pnpm init -y # or: npm init -y
pnpm add @nibiruchain/nibijs @cosmjs/cosmwasm-stargate @cosmjs/stargate cosmjs-types bignumber.js
pnpm add -D typescript ts-node @types/node
npx tsc --init --target ES2022 --module NodeNext --moduleResolution NodeNext
```

### Minimal Env

Create `.env` with your RPC + mnemonic or direct offline signer strategy.

```bash
NIBI_RPC=https://rpc.testnet-2.nibiru.fi # example
MNEMONIC="word1 word2 ..."
```

### Bootstrap Client

```ts
// src/wasmClient.ts
import "dotenv/config"
import { NibiruTxClient } from "@nibiruchain/nibijs"

export async function makeNibiruTxClient() {
  const rpc = process.env.NIBI_RPC!
  const mnemonic = process.env.MNEMONIC!
  const client = await NibiruTxClient.connectWithSignerFromMnemonic(rpc, mnemonic)
  const account = (await client.signer.getAccounts())[0]
  return { client, bech32: account.address }
}
```

---

## 1. Collateral / Payment Tokens

Default decimals for BANK amounts are **6**.

### Testnet‑2

* **USDC**: `bankDenom = tf/nibi1pc2mmwcqhvzn9vsm0umpu40yzl6gfy6nucwn7g/usdc`
* **stNIBI**: `bankDenom = tf/nibi1pc2mmwcqhvzn9vsm0umpu40yzl6gfy6nucwn7g/stnibi`

### Mainnet

* **USDC**: `bankDenom = erc20/0x0829F361A05D993d5CEb035cA6DF3446b060970b`
* **stNIBI**: `bankDenom = tf/nibi1udqqx30cw8nwjxtl4l28ym9hhrp933zlq8dqxfjzcdhvl8y24zcqpzmh8m/ampNIBI`

> Scale display amounts → BANK units via `amount * 10^6`, floor to integer.

---

## 2. Perps – Open Trade

**Msg**

```json
{
  "open_trade": {
    "market_index": "MarketIndex(N)",
    "leverage": "string",
    "long": true,
    "collateral_index": "TokenIndex(N)",
    "trade_type": "trade|limit|stop",
    "open_price": "<market or limit>",
    "slippage_p": "1",
    "tp": "optional",
    "sl": "optional",
    "is_evm_origin": false
  }
}
```

**Funds**

```json
[{ "denom": "<collateral.bankDenom>", "amount": "<BANK units>" }]
```

**Rules**

* `Market` requires `open_price`.
* `Limit/Stop` require `limitPriceUsd` (becomes `open_price`).

**Code**

```ts
import BigNumber from "bignumber.js"
import { Coin } from "cosmjs-types/cosmos/base/v1beta1/coin"
import { makeNibiruTxClient } from "./wasmClient"

async function openTrade() {
  const { client, bech32 } = await makeNibiruTxClient()
  const saiPerp = "<saiContracts.perp>" // bech32
  const bankDenom = "<bankDenom>"

  const display = new BigNumber("100") // 100 USDC
  const amount = display.times(1e6).integerValue().toString()

  const msg = {
    open_trade: {
      market_index: "MarketIndex(0)",
      leverage: "5",
      long: true,
      collateral_index: "TokenIndex(0)",
      trade_type: "trade",
      open_price: "70000",
      slippage_p: "1",
      is_evm_origin: false,
    },
  }

  const res = await client.wasmClient.execute(
    bech32,
    saiPerp,
    msg,
    "auto",
    undefined,
    [Coin.fromPartial({ denom: bankDenom, amount })]
  )
  console.log("tx hash:", res.transactionHash)
}
```

---

## 3. Perps – Close Trade

```ts
await client.wasmClient.execute(
  bech32,
  saiPerp,
  { close_trade: { trade_index: "UserTradeIndex(0)" } },
  "auto"
)
```

---

## 4. Referral – Create & Redeem

```ts
await client.wasmClient.execute(
  bech32,
  saiPerp,
  { create_referrer_code: { code: "MYCODE" } },
  "auto"
)

await client.wasmClient.execute(
  bech32,
  saiPerp,
  { redeem_referrer_code: { code: "PARTNER" } },
  "auto"
)
```

---

## 5. Vault – Deposit

```ts
const vaultAddr = "<vault bech32>"
const bankDenom = "<collateral.bankDenom>"
const amount = new BigNumber("250").times(1e6).integerValue().toString()

await client.wasmClient.execute(
  bech32,
  vaultAddr,
  { deposit: {} },
  "auto",
  undefined,
  [Coin.fromPartial({ denom: bankDenom, amount })]
)
```

---

## 6. Vault – Make Withdraw Request

1. Query share denom:

```ts
const shareDenom = await client.wasmClient.queryContractSmart(vaultAddr, { get_vault_share_denom: {} })
```

2. Execute with share funds:

```ts
await client.wasmClient.execute(
  bech32,
  vaultAddr,
  { make_withdraw_request: {} },
  "auto",
  undefined,
  [Coin.fromPartial({ denom: shareDenom, amount: "1000000" })] // 1.0 share in BANK units
)
```

---

## 7. Vault – Redeem

```ts
await client.wasmClient.execute(
  bech32,
  vaultAddr,
  { redeem: { shares: "500000" } }, // 0.5 shares
  "auto"
)
```

---

## 8. Vault – Cancel Withdraw Request

```ts
await client.wasmClient.execute(
  bech32,
  vaultAddr,
  { cancel_withdraw_request: { unlock_epoch: 123 } },
  "auto"
)
```

---

## Troubleshooting

* Ensure `runner` exists: you must create `NibiruTxClient` and have an account.
* Amounts must be non‑negative integers in BANK units (6 decimals default).
* For insufficient BANK funds, consider a prior EVM→BANK conversion on the UI layer (see EVM guide).
