---
description: >-
  Sai's perpetual exchange app is implemented in Rust, a powerful language for
  secure, sandboxed programming, that compiles into Wasm bytecode. 5 key
  contracts manage everything on Sai, fully onchain.
---

# Smart Contracts

### How Sai the Sai Smart Contracts Work

* **`perp` (Perpetuals trading core)**:
  * Maintains markets, positions, margin, and liquidations.
  * Calculates execution price with price impact, applies trading/borrowing/funding fees, and updates PnL.
  * Enforces risk constraints (maintenance margin, max leverage, funding payments).
  * Entry points (conceptually): open/close position, modify collateral, place/execute orders, liquidate under-margined positions.
  * Reads prices from `oracle`, collects/streams fees, and settles PnL against `vault`.
* **EVM interface (`PerpVaultEvmInterface.sol`)**:
  * Lets MetaMask/EVM users interact with the Wasm contracts.
  * Handles token conversion and cross-VM calls to `perp` and `vault`.
  * Mirrors the essential user flows (deposit, withdraw, open/close) for EVM wallets.
* **`vault` (Liquidity provider pool)**: [Implements SLP Vaults](../../learn/slp.md).
  * Aggregates LP liquidity to underwrite trader PnL.
  * Issues and accounts for shares against total assets; supports deposits and epoch-based withdrawals.
  * Absorbs trader PnL: when traders win, the vault pays out; when traders lose, the vault accrues profits.
  * Coordinates with `vault-token-minter` for share token mint/burn and with `perp` for settlement transfers.
* **`oracle` (Price feed and permissions)**:
  * Stores and serves the canonical mark price per market.
  * Controls who can update prices and under what conditions.
  * Provides prices to `perp` for margin checks, execution, funding, and liquidation thresholds.
* **`vault-token-minter` (Token factory bridge for shares)**:
  * Controls minting/burning of vault share tokens via Nibiru’s token factory.
  * Enforces whitelist/ownership checks to prevent unauthorized supply changes.
  * Called by `vault` to mint on deposit and burn on withdrawal/redemption.

### Interaction model

1. **Liquidity lifecycle**
   1. LPs deposit assets into `vault` → `vault` mints shares via `vault-token-minter`.
   2. LPs request withdrawals → `vault` queues and later exits via epochs, burning shares on completion.
2. **Trading lifecycle**
   1. Trader requests an action (EVM or Wasm): open/close/modify position in `perp`.
   2. `perp` fetches price from `oracle`, computes price impact, fees, and checks margin/leverage constraints.
   3. `perp` updates position state, accrues funding/borrowing fees, and computes PnL deltas.
3. **Settlement path**
   1. Trader losses → profits accrue to `vault`.
   2. Trader gains → `perp` sources payout from `vault`.
4. **Funding and price alignment**
   1. `perp` periodically computes funding based on price deltas between mark and index; longs/shorts pay/receive accordingly.
   2. Funding transfers are accounted in positions and net settle via `vault` over time.
5. **Liquidations**
   1. If a position’s margin fraction drops below maintenance, `perp` allows a liquidator to close the position.
   2. `perp` calculates close price (with impact), applies penalties/fees, and settles PnL with `vault`.
   3. Any residual collateral after penalties is returned to the trader; bad debt is socialized to `vault` within configured limits.

#### **Access and safety**

1. Ownership/roles restrict sensitive ops: oracle price updates, mint permissions, parameter changes.
2. `perp` enforces invariants (max leverage, min maintenance, fee bounds).
3. `vault` enforces epoch rules and share/accounting correctness.
4. Cross-VM calls are designed to avoid re-entrancy and maintain atomic accounting on state-changing operations.

### Data and accounting at a glance

* **`perp` state**: markets, position records (size, entry price, collateral, accumulated funding/borrowing), pending orders, parameters.
* **`vault` state**: total assets, total shares, per-account share balances, withdrawal epochs/queues.
* **`oracle` state**: price per market with update metadata.
* **`vault-token-minter` state**: mint/burn permissions and token metadata.

### Typical end-to-end flows

* Open a long:
  * User calls `perp.open_position` → `perp` gets price from `oracle`, applies price impact and fees, locks collateral, records position.
* Close a long in profit:
  * `perp` computes PnL at current `oracle` price (with impact), deducts fees, and transfers profit from `vault` to user.
* LP exit:
  * User requests withdraw → `vault` queues for epoch → on execution, `vault` burns shares via `vault-token-minter` and releases assets.
* The contracts’ business roles are: `perp` (trade logic and risk), `vault` (liquidity and PnL sink/source), `oracle` (truthful prices), `vault-token-minter` (controlled share supply), with an EVM facade enabling wallet-native access.

### Sai and the EVM

Sai is written as a Multi VM app with contracts written in both Rust and Solidity. This lets the application benefit from the security benefits of working with Wasm while remaining fully capable of tapping into the flexibility and familiarity that comes with the Ethereum Virtual Machine (EVM).&#x20;
