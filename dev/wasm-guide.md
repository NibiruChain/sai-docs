---
icon: code
cover: ../.gitbook/assets/sai-banner-guides-1500x500.png
coverY: 0
---

# Sai – WASM Integration Guide

End-to-end instructions for interacting with **Sai** from the Cosmos (WASM) side using `NibiruTxClient`.

---

## 0. Getting Started

### Prerequisites

* Node.js ≥ 18
* pnpm, npm, or yarn

### New Project

```bash
mkdir sai-wasm && cd sai-wasm
pnpm init -y
pnpm add @nibiruchain/nibijs @cosmjs/cosmwasm-stargate @cosmjs/stargate cosmjs-types bignumber.js
pnpm add -D typescript ts-node @types/node dotenv
npx tsc --init --target ES2022 --module NodeNext --moduleResolution NodeNext
```

### Environment Setup

Create a `.env` file with your configuration:

```bash
# Testnet-1
NIBI_RPC=https://rpc.testnet-1.nibiru.fi/

# Or Mainnet
# NIBI_RPC=https://rpc.nibiru.fi/

MNEMONIC="word1 word2 ... word12"  # Your wallet mnemonic (keep this secret!)
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

### Decimal Handling

Default decimals for BANK amounts are **6**. Always scale display amounts to BANK units by multiplying by 10^6.

### Testnet-1

| Token | Bank Denom |
|-------|---|
| **USDC** | `tf/nibi1pc2mmwcqhvzn9vsm0umpu40yzl6gfy6nucwn7g/usdc` |
| **stNIBI** | `tf/nibi1pc2mmwcqhvzn9vsm0umpu40yzl6gfy6nucwn7g/stnibi` |

### Mainnet

| Token | Bank Denom |
|-------|---|
| **USDC** | `erc20/0x0829F361A05D993d5CEb035cA6DF3446b060970b` |
| **stNIBI** | `tf/nibi1udqqx30cw8nwjxtl4l28ym9hhrp933zlq8dqxfjzcdhvl8y24zcqpzmh8m/ampNIBI` |

### Converting Display to BANK Units

```ts
import BigNumber from "bignumber.js"

const displayAmount = new BigNumber("100") // 100 USDC
const bankAmount = displayAmount.times(1e6).integerValue().toString()
// Result: "100000000" (100 * 10^6)
```

---

## 2. Perps – Open Trade

### Message Structure

```json
{
  "open_trade": {
    "market_index": "MarketIndex(N)",
    "leverage": "string (e.g., '5')",
    "long": true,
    "collateral_index": "TokenIndex(N)",
    "trade_type": "trade|limit|stop",
    "open_price": "<market or limit price>",
    "slippage_p": "1",
    "tp": "optional take-profit",
    "sl": "optional stop-loss",
    "is_evm_origin": false
  }
}
```

### Rules

* **Market trades** require `open_price` set to the current market price
* **Limit/Stop trades** require `open_price` set to the trigger price

### Example

```ts
import BigNumber from "bignumber.js"
import { Coin } from "cosmjs-types/cosmos/base/v1beta1/coin"
import { makeNibiruTxClient } from "./wasmClient"

async function openTrade() {
  const { client, bech32 } = await makeNibiruTxClient()

  // Contract addresses (from chain config)
  const saiPerp = "<saiContracts.perp>" // bech32 address
  const bankDenom = "tf/nibi1pc2mmwcqhvzn9vsm0umpu40yzl6gfy6nucwn7g/usdc" // Testnet-1 USDC

  // Convert 100 USDC to BANK units
  const display = new BigNumber("100")
  const amount = display.times(1e6).integerValue().toString() // "100000000"

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

  console.log("Transaction hash:", res.transactionHash)
  console.log("Gas used:", res.gasUsed)
}
```

---

## 3. Perps – Close Trade

Close an open position:

```ts
import { makeNibiruTxClient } from "./wasmClient"

async function closeTrade() {
  const { client, bech32 } = await makeNibiruTxClient()
  const saiPerp = "<saiContracts.perp>"

  const res = await client.wasmClient.execute(
    bech32,
    saiPerp,
    {
      close_trade: {
        trade_index: "UserTradeIndex(0)",
      },
    },
    "auto"
  )

  console.log("Trade closed in tx:", res.transactionHash)
}
```

---

## 4. Referral – Create & Redeem Codes

### Create a Referral Code

```ts
async function createReferralCode() {
  const { client, bech32 } = await makeNibiruTxClient()
  const saiPerp = "<saiContracts.perp>"

  const res = await client.wasmClient.execute(
    bech32,
    saiPerp,
    {
      create_referrer_code: {
        code: "MYCODE",
      },
    },
    "auto"
  )

  console.log("Referral code created in tx:", res.transactionHash)
}
```

### Redeem a Referral Code

```ts
async function redeemReferralCode() {
  const { client, bech32 } = await makeNibiruTxClient()
  const saiPerp = "<saiContracts.perp>"

  const res = await client.wasmClient.execute(
    bech32,
    saiPerp,
    {
      redeem_referrer_code: {
        code: "PARTNER",
      },
    },
    "auto"
  )

  console.log("Referral code redeemed in tx:", res.transactionHash)
}
```

---

## 5. Vault – Deposit

Deposit collateral into a vault:

```ts
import BigNumber from "bignumber.js"
import { Coin } from "cosmjs-types/cosmos/base/v1beta1/coin"
import { makeNibiruTxClient } from "./wasmClient"

async function depositToVault() {
  const { client, bech32 } = await makeNibiruTxClient()

  const vaultAddr = "<vault bech32 address>"
  const bankDenom = "tf/nibi1pc2mmwcqhvzn9vsm0umpu40yzl6gfy6nucwn7g/usdc" // Testnet-1 USDC

  // Convert 250 USDC to BANK units
  const amount = new BigNumber("250")
    .times(1e6)
    .integerValue()
    .toString()

  const res = await client.wasmClient.execute(
    bech32,
    vaultAddr,
    { deposit: {} },
    "auto",
    undefined,
    [Coin.fromPartial({ denom: bankDenom, amount })]
  )

  console.log("Deposited to vault in tx:", res.transactionHash)
}
```

---

## 6. Vault – Make Withdraw Request

Request to withdraw funds from a vault:

```ts
import { Coin } from "cosmjs-types/cosmos/base/v1beta1/coin"
import { makeNibiruTxClient } from "./wasmClient"

async function makeWithdrawRequest() {
  const { client, bech32 } = await makeNibiruTxClient()

  const vaultAddr = "<vault bech32 address>"

  // First, query the vault to get the share denom
  const shareDenom = await client.wasmClient.queryContractSmart(vaultAddr, {
    get_vault_share_denom: {},
  })

  console.log("Share denom:", shareDenom)

  // Request to withdraw 1.0 share (1,000,000 in BANK units)
  const res = await client.wasmClient.execute(
    bech32,
    vaultAddr,
    { make_withdraw_request: {} },
    "auto",
    undefined,
    [Coin.fromPartial({ denom: shareDenom, amount: "1000000" })]
  )

  console.log("Withdraw request created in tx:", res.transactionHash)
}
```

---

## 7. Vault – Redeem

Redeem shares from a vault:

```ts
import { makeNibiruTxClient } from "./wasmClient"

async function redeemVaultShares() {
  const { client, bech32 } = await makeNibiruTxClient()

  const vaultAddr = "<vault bech32 address>"

  // Redeem 0.5 shares (500,000 in BANK units)
  const res = await client.wasmClient.execute(
    bech32,
    vaultAddr,
    {
      redeem: {
        shares: "500000",
      },
    },
    "auto"
  )

  console.log("Shares redeemed in tx:", res.transactionHash)
}
```

---

## 8. Vault – Cancel Withdraw Request

Cancel a pending withdraw request:

```ts
import { makeNibiruTxClient } from "./wasmClient"

async function cancelWithdrawRequest() {
  const { client, bech32 } = await makeNibiruTxClient()

  const vaultAddr = "<vault bech32 address>"

  const res = await client.wasmClient.execute(
    bech32,
    vaultAddr,
    {
      cancel_withdraw_request: {
        unlock_epoch: 123, // Replace with actual unlock epoch
      },
    },
    "auto"
  )

  console.log("Withdraw request cancelled in tx:", res.transactionHash)
}
```

---

## Query Examples

### Query Vault Share Denom

```ts
async function getVaultShareDenom() {
  const { client } = await makeNibiruTxClient()
  const vaultAddr = "<vault bech32 address>"

  const shareDenom = await client.wasmClient.queryContractSmart(vaultAddr, {
    get_vault_share_denom: {},
  })

  console.log("Share denom:", shareDenom)
  return shareDenom
}
```

### Query User Trades

```ts
async function getUserTrades() {
  const { client, bech32 } = await makeNibiruTxClient()
  const saiPerp = "<saiContracts.perp>"

  const trades = await client.wasmClient.queryContractSmart(saiPerp, {
    get_user_trades: {
      user: bech32,
    },
  })

  console.log("User trades:", trades)
  return trades
}
```

### Query Vault Info

```ts
async function getVaultInfo() {
  const { client } = await makeNibiruTxClient()
  const vaultAddr = "<vault bech32 address>"

  const info = await client.wasmClient.queryContractSmart(vaultAddr, {
    get_info: {},
  })

  console.log("Vault info:", info)
  return info
}
```

---

## Error Handling & Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| **"No account found"** | Ensure your mnemonic is valid and `NibiruTxClient` is properly initialized |
| **"Insufficient funds"** | Verify you have enough tokens (in BANK units) in your wallet |
| **"Invalid denom"** | Double-check the `bankDenom` matches your network (Testnet-1 vs Mainnet) |
| **"Contract not found"** | Ensure the contract address is correct for your network |
| **Decimal conversion errors** | Always multiply display amounts by 10^6 before passing to WASM |
| **Transaction timeout** | Increase the timeout or check RPC connectivity |

### Best Practices

* Always ensure the `NibiruTxClient` is connected before executing transactions
* Validate that amounts are non-negative integers in BANK units
* Use `"auto"` for gas estimation unless you have specific gas requirements
* Store your mnemonic securely and never commit it to version control
* Always query contract state before making assumptions about parameters
* Test on Testnet-1 before moving to Mainnet

### Debugging Tips

* Check transaction details: `client.getTx(transactionHash)`
* Inspect error messages: Transaction results include detailed error reasons
* Use logs: Add `console.log()` statements to trace execution flow
* Monitor gas: The transaction response includes gas used and fees paid
