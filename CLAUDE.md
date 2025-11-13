# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is the documentation repository for **Sai.fun**, a perpetual futures trading platform built on Nibiru. The repository is structured as a GitBook-based documentation site covering user guides, technical architecture, and smart contract details.

## Architecture & Structure

### Documentation Organization

- **`README.md`**: Main landing page introducing Sai.fun platform
- **`SUMMARY.md`**: GitBook table of contents defining navigation structure
- **`learn/`**: Educational content about platform mechanics
  - `trading/`: Trading features, fees, leverage, liquidations
  - `slp.md`: Sai Liquidity Provision (vault) mechanics
- **`guides/`**: User-facing guides for getting started
- **`sai-core/smart-contracts/`**: Technical documentation for the 5-contract system
- **`community.md`**: Community links and resources

### Smart Contract System Architecture

The platform consists of 5 interconnected smart contracts:

1. **`perp`** (Rust/Wasm): Core perpetual trading logic, positions, margins, liquidations
2. **EVM Interface** (Solidity): Bridge for MetaMask/EVM wallet interactions
3. **`vault`**: Liquidity provider pools, implements SLP share system
4. **`oracle`**: Price feeds and permissions management
5. **`vault-token-minter`**: Token factory integration for vault shares

### Content Flow Architecture

- **Liquidity**: LPs deposit → vault mints shares → provides counterparty liquidity
- **Trading**: Traders interact via EVM/Wasm → perp contract → oracle prices → vault settlement
- **Settlement**: Trader PnL settles against vault (wins paid by vault, losses accrue to vault)

## Working with Documentation

### GitBook Integration

- Uses GitBook-specific frontmatter (description, icon, cover, coverY)
- Content references using `{% content-ref url="..." %}` syntax
- Hint blocks using `{% hint style="info" %}` format
- Navigation structure controlled by SUMMARY.md

### Documentation Standards

- All pages should have appropriate frontmatter metadata
- Use GitBook content-ref blocks for cross-references
- Maintain consistency with existing tone (technical but accessible)
- Follow the established information architecture

### Key Concepts to Understand

- **SLP (Sai Liquidity Provision)**: Single-collateral vault model where LPs provide counterparty liquidity
- **Multi-VM Architecture**: Platform supports both Cosmos (Wasm) and EVM interactions
- **Perpetual Futures**: Leveraged trading up to 150x with oracle settlement
- **Price Impact**: Dynamic execution pricing based on market depth and open interest

### Related Repositories

- **sai-keeper**: Off-chain service for event indexing, trade triggering, and analytics (referenced in sai-keeper-documentation-outline.md)
- **Smart contracts**: Rust/CosmWasm contracts for core protocol logic

### Content Types

- **Learn**: Conceptual explanations of how the platform works
- **Guides**: Step-by-step user instructions
- **Core**: Technical architecture and smart contract documentation

When editing documentation, ensure consistency with the platform's positioning as a user-friendly, fully on-chain perpetual futures trading experience with automated features and competitive pricing.
