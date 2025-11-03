# Sai Contracts – WASM & EVM Integration Guide

A practical, copy‑paste friendly reference for integrating with Sai’s perpetuals and SLP vaults from **Cosmos (WASM)** and **EVM** wallets. It documents all calls shown in the code you shared, with params, expected preconditions, and example snippets.

> **Environments:** Mainnet and Testnet-2 are both supported. Token routes and contract addresses differ by network; see the **Collateral / Payment Tokens** section.

---

## Quick Glossary

* **BANK**: Cosmos-side coins (e.g., `tf/...` denoms).
* **ERC-20**: EVM-side tokens (e.g., `0x...`).
* **Interface (EVM)**: A single EVM contract that accepts a JSON-encoded WASM message and forwards it cross‑stack to Sai’s modules.
* **Perp**: The perpetuals contract/router on the Cosmos side (referenced via `saiContracts.perp`).
* **Vault**: SLP vault contracts (Cosmos bech32 addresses) that accept deposits/withdrawals/redeems.

---

## Collateral / Payment Tokens

These are the routes supported in the shared code (`usd`, `stnibi`). Values are used for **funds** on WASM calls and for **ERC‑20 params** on EVM interface calls.

### Mainnet

| Route    | Symbol | Display Name                   | bankDenom                                                                    | evmAddr                                      | Default ERC‑20 Decimals |
| -------- | ------ | ------------------------------ | ---------------------------------------------------------------------------- | -------------------------------------------- | ----------------------- |
| `usd`    | USDC   | USDC                           | `erc20/0x0829F361A05D993d5CEb035cA6DF3446b060970b`                           | `0x0829F361A05D993d5CEb035cA6DF3446b060970b` | 6                       |
| `stnibi` | stNIBI | Liquid Staked Nibiru (Wrapped) | `tf/nibi1udqqx30cw8nwjxtl4l28ym9hhrp933zlq8dqxfjzcdhvl8y24zcqpzmh8m/ampNIBI` | `0xcA0a9Fb5FBF692fa12fD13c0A900EC56Bb3f0a7b` | 6                       |

### Testnet‑2

| Route    | Symbol | Display Name                   | bankDenom                                               | evmAddr                                      | Default ERC‑20 Decimals |
| -------- | ------ | ------------------------------ | ------------------------------------------------------- | -------------------------------------------- | ----------------------- |
| `usd`    | USDC   | USDC                           | `tf/nibi1pc2mmwcqhvzn9vsm0umpu40yzl6gfy6nucwn7g/usdc`   | `0xAb68f1D1d91854383fd4Df9016E3040D03e8191a` | 6                       |
| `stnibi` | stNIBI | Liquid Staked Nibiru (Wrapped) | `tf/nibi1pc2mmwcqhvzn9vsm0umpu40yzl6gfy6nucwn7g/stnibi` | `0xCae3d404AFB50016154a4B18091351065154E9bD` | 6                       |

> **Tip:** When calling WASM, you spend BANK units (scaled by token decimals, 6 by default). On EVM, you pass both a **BANK portion** and an **ERC‑20 portion**; these are combined for total amounts.

---

## Shared Concepts & Types

* **Signers**

  * *WASM signer* `{ fromBech32Addr, runner: NibiruTxClient }`
  * *EVM signer* `{ fromHexAddr, runner?: ContractRunner, signer?: Signer }` (must have `signer` to send tx)

* **TradeType Derivation**

  * `Market → "trade"`
  * `Limit/Stop` is derived by comparing `limitPriceUsd` to `open_price`:

    * Long: `limit > open_price` → `stop`, else `limit`
    * Short: `limit < open_price` → `stop`, else `limit`

* **Gas Strategy (EVM)**

  * Estimate with `contract.method.estimateGas(...)` and pad by ×1.1
  * Fallbacks: `gasLimit = 5_000_000`, `gasPrice = 1 gwei` if estimation fails

* **ExecuteResult (normalized)**

  * EVM receipts are converted to a CosmJS‑like `ExecuteResult` with `height`, `transactionHash`, `gasUsed/Wanted`, and `events` (topics/data echoed per log).

* **Explorer Links**

  * UI examples compute `blockUrl` and `txUrl` from `height` and `hash`.

---

# EVM Integration (via Interface Contract)

All EVM flows call a single **Interface** contract (obtained via `saiEvmInterfaceFromChainType(chainType)`). Each call sends a JSON-encoded WASM message (`wasmMsgBytes`) together with token amounts/addresses. Always ensure an EVM **signer** is available.

## 1. Open Perp Trade

**Method:** `openTrade(wasmMsgBytes, collateralIndex, totalAmountBankUnits, useErc20Amount)`

**wasmMsg (JSON):**

```json
{
  "open_trade": {
    "market_index": "MarketIndex(N)",
    "leverage": "string",
    "long": true,
    "collateral_index": "TokenIndex(N)",
    "trade_type": "trade|limit|stop",
    "open_price": "<market price or limit price>",
    "tp": "optional string",
    "sl": "optional string",
    "slippage_p": "1",
    "is_evm_origin": true
  }
}
```

**Amounting:**

* Compute BANK portion in **6‑dec units**.
* Compute ERC‑20 portion in **token decimals** (default 6; use `collateral.evmDefaultDecimals` if present).
* `totalAmount` = `bankAmount + evmAmount` (on‑chain Interface handles bridging/combining).

**Preconditions:**

* `orderType === "Market"` requires `open_price`.
* `collateral` must be present; `amtTrade` must be > 0.
* If using smart allocation, split requested amount across BANK/ERC‑20 per wallet balances and preference.

## 2 Close Perp Trade

**Method:** `executeSimpleFunctions(wasmMsgBytes)`

**wasmMsg:**

```json
{ "close_trade": { "trade_index": "UserTradeIndex(<N>)" } }
```

## 3. Referral: Create Code

**Method:** `executeSimpleFunctions(wasmMsgBytes)`

**wasmMsg:**

```json
{ "create_referrer_code": { "code": "<your_code>" } }
```

## 4. Referral: Redeem Code

**Method:** `executeSimpleFunctions(wasmMsgBytes)`

**wasmMsg:**

```json
{ "redeem_referrer_code": { "code": "<partner_code>" } }
```

## 5. Vault: Deposit

**Method:**

```javascript
contract.deposit(
  wasmMsgBytes,                    // { "deposit": {} }
  depositAmountTotalBankUnits,     // BANK units (includes ERC‑20 converted -> BANK)
  useErc20Amount,                  // ERC‑20 units (token decimals)
  vaultAddress,                    // bech32 vault contract
  collateralErc20,                 // ERC‑20 address
  true,                            // sendToEvm on triggers
  overrides
)
```

**Notes:**

* Convert ERC‑20 portion to BANK units before summing into `depositAmountTotal` if needed (decimals may differ).

## 6. Vault: Make Withdraw Request

**Method:**

```javascript
contract.makeWithdrawRequest(
  vaultAddress,
  wasmMsgBytes,     // { "make_withdraw_request": {} }
  totalShares,      // BANK units to lock (sharesBANK + sharesFromERC20)
  useErc20Amount,   // shares to bridge from ERC‑20 (BANK-scaled already)
  overrides
)
```

## 7. Vault: Redeem

**Method:**

```javascript
contract.redeem(
  wasmMsgBytes,              // { "redeem": { "shares": "..." } }
  vaultAddress,
  shares,                    // BANK units
  sendToEvm,                 // boolean
  overrides
)
```

## 8. Vault: Cancel Withdraw Request

**Method:** `executeVaultSimpleFunctions(wasmMsgBytes, vaultAddress)`

**wasmMsg:**

```json
{ "cancel_withdraw_request": { "unlock_epoch": <number> } }
```

---

# WASM (Cosmos) Integration

WASM calls use the `NibiruTxClient` (`signer.runner.wasmClient`). Funds are passed as Cosmos `Coin { denom, amount }` where `amount` is **BANK units** (1e6‑scaled by default).

## 1. Open Perp Trade

**Client:** `wasmClient.execute(sender, saiContracts.perp, msg, fee, memo, funds)`

**Msg:**

```json
{
  "open_trade": {
    "market_index": "MarketIndex(N)",
    "leverage": "string",
    "long": true,
    "collateral_index": "TokenIndex(N)",
    "trade_type": "trade|limit|stop",
    "open_price": "<market price or limit price>",
    "slippage_p": "1",
    "tp": "optional string",
    "sl": "optional string",
    "is_evm_origin": false
  }
}
```

**Funds:**

```json
[{ "denom": "<collateral.bankDenom>", "amount": "<BANK units>" }]
```

**Preconditions:**

* For `Market`, `open_price` is required.
* For `Limit/Stop`, `limitPriceUsd` is required.

**Optional ERC‑20 → BANK bridging**

* If the current BANK balance is insufficient, prepend a `MsgConvertEvmToCoin` to convert ERC‑20 to BANK for the deficit.

## 2. Close Perp Trade

**Client:** `execute(sender, saiContracts.perp, { close_trade: { trade_index: "UserTradeIndex(N)" } }, fee)`

## 3. Referral: Create Code

**Client:** `execute(sender, saiContracts.perp, { create_referrer_code: { code } }, fee)`

## 4. Referral: Redeem Code

**Client:** `execute(sender, saiContracts.perp, { redeem_referrer_code: { code } }, fee)`

## 5. Vault: Deposit

**Client:** `execute(sender, vaultSelection.address, { deposit: {} }, fee, memo, [funds])`

**Funds:**

```json
[{ "denom": "<collateral.bankDenom>", "amount": "<BANK units>" }]
```

## 6. Vault: Make Withdraw Request

**Share Denom Discovery:** Query once before executing:

```json
{ "get_vault_share_denom": {} }
```

**Client:**

* Execute with funds in **share denom**:

```json
[{ "denom": "<shareDenom>", "amount": "<shares BANK units>" }]
```

**Msg:** `{ "make_withdraw_request": {} }`

## 7. Vault: Redeem

**Client:** `execute(sender, vaultAddress, { redeem: { shares: "..." } }, fee)` (no funds)

## 8. Vault: Cancel Withdraw Request

**Client:** `execute(sender, vaultAddress, { cancel_withdraw_request: { unlock_epoch } }, fee)`

---

## Amounts & Decimals (Gotchas)

* **Default decimals = 6** for BANK. Always scale UI amounts: `display × 10^decimals`.
* When mixing BANK and ERC‑20 on **EVM deposit/withdraw**, convert across decimals before summing.
* Validate that amounts are **finite, non‑negative, non‑zero** after scaling.

---

## Error Handling & UX Patterns

* **Signer presence**: EVM calls require `signer` (not just a runner). WASM requires `runner`.
* **Toast/Notifications**: Use pending/success/failure to surface status. On success, show `height` and `hash` with explorer links.
* **Debugging (EVM)**: If a tx reverts, use archive RPC’s `debug_traceTransaction` to extract the deepest `calls[-1].error`.

---

## Minimal Pseudocode Examples

> Below are slimmed examples you can adapt; they assume your app has already selected `chainType`, `saiContracts`, `interfaceAddress`, `collateral`, etc.

### Open Trade (EVM)

```ts
const msg = { open_trade: { /* ...see schema above... */ is_evm_origin: true } }
const wasmMsgBytes = ethers.toUtf8Bytes(JSON.stringify(msg))
const gas = await estimateGasWithFallback(
  () => contract.openTrade.estimateGas(wasmMsgBytes, collateralIndex, totalAmount, useErc20),
  { msg }
)
const tx = await contract.openTrade(wasmMsgBytes, collateralIndex, totalAmount, useErc20, toTxOverrides(gas))
const res = await tx.wait() // -> map to ExecuteResult if desired
```

### Open Trade (WASM)

```ts
await wasm.execute(
  bech32,
  saiContracts.perp,
  { open_trade: { /* ... */, is_evm_origin: false } },
  "auto",
  undefined,
  [ { denom: collateral.bankDenom, amount: scaledAmount } ]
)
```

### Vault Deposit (EVM)

```ts
const msg = { deposit: {} }
const wasmMsgBytes = ethers.toUtf8Bytes(JSON.stringify(msg))
const bankTotal = bankAmount + toBankUnits(erc20Amount, erc20Dec, 6)
const tx = await contract.deposit(wasmMsgBytes, bankTotal, erc20Amount, vaultAddr, collateral.evmAddr, true, overrides)
await tx.wait()
```

### Make Withdraw Request (WASM)

```ts
const shareDenom = await wasm.queryContractSmart(vaultAddr, { get_vault_share_denom: {} })
await wasm.execute(
  bech32,
  vaultAddr,
  { make_withdraw_request: {} },
  "auto",
  undefined,
  [ { denom: shareDenom, amount: shares } ]
)
```

---

## Preconditions Checklist (per call)

* **Open Trade**: amount > 0; Market→`open_price` present; Limit/Stop→`limitPriceUsd` present; `collateral.index` parseable; signer ready.
* **Close Trade**: `userTradeIndex` set; signer ready.
* **Create/Redeem Referral**: `code` non‑empty; signer ready.
* **Vault Deposit**: amounts properly scaled; convert ERC‑20 portion to BANK for totals on EVM; signer ready.
* **Withdraw Request**: shares in BANK units; (WASM) share denom fetched; signer ready.
* **Redeem**: shares in BANK units; `sendToEvm` flag set (EVM path); signer ready.
* **Cancel Withdraw Request**: `unlock_epoch` set; signer ready.

---

## Appendix: Utility Notes

* **`estimateGasWithFallback`** pads gas by 10% and falls back to `5_000_000 / 1 gwei` if estimation fails.
* **`receiptToExecuteResult`** normalizes EVM receipts to a CosmJS‑like shape.
* **`MsgConvertEvmToCoin`** (WASM path) can optionally be appended if BANK funds are insufficient.
* **Smart Allocation** (optional): split requested amount across BANK / ERC‑20 based on balances and user preference; then scale per‑side and stitch back together.

---
