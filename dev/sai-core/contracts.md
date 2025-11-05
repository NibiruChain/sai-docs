# Contract Addresses Reference

Quick reference for all Sai Protocol contract addresses on Testnet and Mainnet.

## Table of Contents

- [Testnet Contracts](#testnet-contracts)
- [Mainnet Contracts](#mainnet-contracts)
- [Payment Tokens](#payment-tokens)

---

## Testnet Contracts

### Core Wasm Contracts

| Contract | Address |
|----------|---------|
| **Perp Manager** | `nibi1qtkcns647w959cj9x2yytateu6dgscfnfkraywwa443pr2erak0s5ux7e5` |
| **Oracle** | `nibi1mqlrsvfhm5vzsz0wxr6mh8pzxzpz6dd4g7nuyycjf6gy5zc53fvq3lq2fz` |

### LP Vaults (Testnet)

| Vault Type | Vault Address | Vault Minter Address |
|------------|---------------|---------------------|
| **Vault 1** | `nibi1jkuszyvgufu5kghmzp47gg02j4jyvtv22hs4vtmefg3wuzqayefqukhv7t` | `nibi174snnesyj442lxhn53xqcffh7us3f6q3se2sswe5cmmj78majj0sskdk3h` |
| **Vault 2** | `nibi1rsp225zym8x4pdcjdazl8jhg9jvxlptutdkynuvkamas8jjv8j5s22s86m` | `nibi1qa4cj932sm2rsuvz0vn8sz9qzarrctj693nnwhkqnjnvekan460shr3v0a` |

### EVM Interface Contract

| Network | Address |
|---------|---------|
| **Testnet** | `0x282F097930E24e4fba97EE8687d15Ed1f298ad19` |

---

## Mainnet Contracts

### Core Wasm Contracts

| Contract | Address |
|----------|---------|
| **Perp Manager** | `nibi1ntmw2dfvd0qnw5fnwdu9pev2hsnqfdj9ny9n0nzh2a5u8v0scflq930mph` |
| **Oracle** | `nibi1xfwyfwtdame6645lgcs4xvf4u0hpsuvxrcelfwtztu0pv7n4l6hqw5a8gj` |

### LP Vaults (Mainnet - Crypto Group)

| Collateral | Vault Address | Vault Minter Address |
|------------|---------------|---------------------|
| **USDC** | `nibi193m2a00pmdsvkcvugrfewqzhtq6k0srkjzvxp2sk357vlpspx5vqxu8d7p` | `nibi15hcra03vdaaveslz6lekm02kuwkce23uj0u5u9ryaggjh4h5dlysfdmfvj` |
| **stNIBI** | `nibi1mrplvu3scplnrgns96kg0j8pk3l2p9c7eaz0qdedx0kt3vmcujyqrjkfej` | `nibi1vp45yer9anh4p99hgkuy4rx6mqt8cqwglfe5zzve22av67yl0k9qjreyv4` |

### EVM Interface Contract

| Network | Address |
|---------|---------|
| **Mainnet** | `0x9F48A925Dda8528b3A5c2A6717Df0F03c8b167c0` |

---

## Payment Tokens

### Mainnet Payment Tokens

| Token | Symbol | EVM Address | Bank Denom | Decimals | Logo |
|-------|--------|-------------|------------|----------|------|
| **USDC** | USDC | `0x0829F361A05D993d5CEb035cA6DF3446b060970b` | `erc20/0x0829F361A05D993d5CEb035cA6DF3446b060970b` | 6 | [🔗](https://raw.githubusercontent.com/NibiruChain/nibiru/main/token-registry/img/002_usdc.png) |
| **Liquid Staked NIBI** | stNIBI | `0xcA0a9Fb5FBF692fa12fD13c0A900EC56Bb3f0a7b` | `tf/nibi1udqqx30cw8nwjxtl4l28ym9hhrp933zlq8dqxfjzcdhvl8y24zcqpzmh8m/ampNIBI` | 6 | [🔗](https://raw.githubusercontent.com/NibiruChain/nibiru/main/token-registry/img/001_stnibi-evm.png) |

### Testnet Payment Tokens

| Token | Symbol | EVM Address | Bank Denom | Decimals | Logo |
|-------|--------|-------------|------------|----------|------|
| **USDC** | USDC | `0xAb68f1D1d91854383fd4Df9016E3040D03e8191a` | `tf/nibi1pc2mmwcqhvzn9vsm0umpu40yzl6gfy6nucwn7g/usdc` | 6 | [🔗](https://raw.githubusercontent.com/NibiruChain/nibiru/main/token-registry/img/002_usdc.png) |
| **Liquid Staked NIBI** | stNIBI | `0xCae3d404AFB50016154a4B18091351065154E9bD` | `tf/nibi1pc2mmwcqhvzn9vsm0umpu40yzl6gfy6nucwn7g/stnibi` | 6 | [🔗](https://raw.githubusercontent.com/NibiruChain/nibiru/main/token-registry/img/001_stnibi-evm.png) |

---

## Usage Notes

### Wasm Contracts

- Use these addresses when interacting directly with Cosmos SDK/Wasm contracts
- Required for CosmJS or nibijs client libraries
- Format: `nibi1...` (Bech32 encoded)

### EVM Interface Contracts

- Use these addresses when interacting via EVM-compatible wallets (MetaMask, etc.)
- Provides EVM-style interface to underlying Wasm contracts
- Format: `0x...` (Ethereum hex address)

### Payment Tokens

- **EVM Address**: Use for ERC20 interactions via Web3/Ethers.js
- **Bank Denom**: Use for Cosmos SDK transactions
- **Contract Address**: Same as Bank Denom, used in Wasm contract calls
- All tokens use **6 decimals**

### Vault Structure

- **Vault**: Main vault contract that holds assets
- **Vault Minter**: Contract that mints/burns vault shares

---

## Quick Copy

### Testnet

```bash
# Core Contracts
PERP_MANAGER="nibi1qtkcns647w959cj9x2yytateu6dgscfnfkraywwa443pr2erak0s5ux7e5"
ORACLE="nibi1mqlrsvfhm5vzsz0wxr6mh8pzxzpz6dd4g7nuyycjf6gy5zc53fvq3lq2fz"
EVM_INTERFACE="0x282F097930E24e4fba97EE8687d15Ed1f298ad19"

# Payment Tokens
USDC_EVM="0xAb68f1D1d91854383fd4Df9016E3040D03e8191a"
STNIBI_EVM="0xCae3d404AFB50016154a4B18091351065154E9bD"
```

### Mainnet

```bash
# Core Contracts
PERP_MANAGER="nibi1ntmw2dfvd0qnw5fnwdu9pev2hsnqfdj9ny9n0nzh2a5u8v0scflq930mph"
ORACLE="nibi1xfwyfwtdame6645lgcs4xvf4u0hpsuvxrcelfwtztu0pv7n4l6hqw5a8gj"
EVM_INTERFACE="0x9F48A925Dda8528b3A5c2A6717Df0F03c8b167c0"

# Payment Tokens
USDC_EVM="0x0829F361A05D993d5CEb035cA6DF3446b060970b"
STNIBI_EVM="0xcA0a9Fb5FBF692fa12fD13c0A900EC56Bb3f0a7b"
```
