---
description: >-
  Learn Sai by example. A collection of guides and walkthroughs on how to
  perform common tasks on Sai.fun and Nibiru.
icon: code
cover: ../.gitbook/assets/sai-banner-guides-1500x500.png
coverY: 0
---

# For Developers

Welcome to the Sai developer documentation. Whether you're integrating Sai into your application, building on top of the protocol, or querying data from Sai, you'll find everything you need here.

---

## 🚀 Quick Start

Choose your integration path:

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin: 30px 0;">
  <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; border-radius: 12px; color: white;">
    <h3 style="margin-top: 0; display: flex; align-items: center; gap: 10px;">⛓️ EVM Integration</h3>
    <p>Connect via Ethereum Virtual Machine. Build with ethers.js and interact with Sai contracts directly.</p>
    <a href="dev/evm-guide.md" style="color: white; text-decoration: underline; font-weight: bold;">Get Started →</a>
  </div>
  
  <div style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); padding: 30px; border-radius: 12px; color: white;">
    <h3 style="margin-top: 0; display: flex; align-items: center; gap: 10px;">🔗 WASM Integration</h3>
    <p>Build on Cosmos. Interact with Sai using CosmJS and NibiruTxClient for native chain integration.</p>
    <a href="dev/wasm-guide.md" style="color: white; text-decoration: underline; font-weight: bold;">Get Started →</a>
  </div>
</div>

---

## 🔧 Sai Core

The heart of Sai. Smart contracts, modules, and architecture documentation.

<div style="background: rgba(102, 126, 234, 0.1); border-left: 4px solid #667eea; padding: 20px; border-radius: 8px; margin: 20px 0;">
  <p style="margin: 0;"><strong>Comprehensive protocol documentation:</strong> <a href="dev/sai-core/">Sai Core Full Documentation</a></p>
</div>

### Core Modules

<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 15px; margin: 20px 0;">
  <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 20px; border-radius: 12px; color: white; text-decoration: none; transition: transform 0.3s;">
    <h4 style="margin: 0 0 10px 0;">⚙️ Perp Contract</h4>
    <p style="margin: 0 0 15px 0; font-size: 14px;">Core trading contract and mechanisms</p>
    <a href="dev/sai-core/perp-contract.md" style="color: white; text-decoration: underline; font-weight: bold;">Read more →</a>
  </div>
  
  <div style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); padding: 20px; border-radius: 12px; color: white; text-decoration: none;">
    <h4 style="margin: 0 0 10px 0;">🏦 Borrowing Module</h4>
    <p style="margin: 0 0 15px 0; font-size: 14px;">Collateral borrowing and lending logic</p>
    <a href="dev/sai-core/perp-borrowing.md" style="color: white; text-decoration: underline; font-weight: bold;">Read more →</a>
  </div>
  
  <div style="background: linear-gradient(135deg, #fa709a 0%, #fee140 100%); padding: 20px; border-radius: 12px; color: white; text-decoration: none;">
    <h4 style="margin: 0 0 10px 0;">📊 Price Impact Module</h4>
    <p style="margin: 0 0 15px 0; font-size: 14px;">How trades affect market prices</p>
    <a href="dev/sai-core/perp-price-impact.md" style="color: white; text-decoration: underline; font-weight: bold;">Read more →</a>
  </div>
</div>

### Reference

<div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 15px; margin: 20px 0;">
  <div style="background: rgba(30, 30, 30, 0.05); padding: 15px; border-radius: 8px; border: 1px solid rgba(102, 126, 234, 0.2);">
    <strong>📋 <a href="dev/sai-core/perp-state.md">State Variables</a></strong>
    <p style="margin-top: 5px; font-size: 13px; color: #666;">All contract state and variables</p>
  </div>
  
  <div style="background: rgba(30, 30, 30, 0.05); padding: 15px; border-radius: 8px; border: 1px solid rgba(102, 126, 234, 0.2);">
    <strong>📍 <a href="dev/sai-core/contracts.md">Contract Addresses</a></strong>
    <p style="margin-top: 5px; font-size: 13px; color: #666;">All contract deployments and addresses</p>
  </div>
  
  <div style="background: rgba(30, 30, 30, 0.05); padding: 15px; border-radius: 8px; border: 1px solid rgba(102, 126, 234, 0.2);">
    <strong>🔌 <a href="dev/sai-core/contract-integration.md">WASM & EVM</a></strong>
    <p style="margin-top: 5px; font-size: 13px; color: #666;">Cross-chain contract integration</p>
  </div>
</div>

---

## 📡 Sai Keeper

Real-time data queries and subscriptions for the Sai protocol.

<div style="background: rgba(240, 147, 251, 0.1); border-left: 4px solid #f093fb; padding: 20px; border-radius: 8px; margin: 20px 0;">
  <p style="margin: 0;"><strong>Query and monitor Sai:</strong> <a href="dev/sai-keeper/">Sai Keeper Full Documentation</a></p>
</div>

### Getting Started with Keeper

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin: 20px 0;">
  <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 20px; border-radius: 12px; color: white;">
    <h4 style="margin-top: 0;">📚 Core Concepts</h4>
    <p>Understand how Keeper works, data structures, and architecture</p>
    <a href="dev/sai-keeper/core-concepts.md" style="color: white; text-decoration: underline; font-weight: bold;">Learn →</a>
  </div>
  
  <div style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); padding: 20px; border-radius: 12px; color: white;">
    <h4 style="margin-top: 0;">⚡ Client Setup</h4>
    <p>Set up your development environment and initialize the client</p>
    <a href="dev/sai-keeper/client-setup.md" style="color: white; text-decoration: underline; font-weight: bold;">Setup →</a>
  </div>
</div>

### API Reference

<div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 15px; margin: 20px 0;">
  <div style="background: #f0f4ff; padding: 15px; border-radius: 8px; border-left: 3px solid #667eea;">
    <strong>📈 <a href="dev/sai-keeper/api-perp.md">Perp API</a></strong>
    <p style="margin: 5px 0; font-size: 13px;">Query perpetual positions and market data</p>
  </div>
  
  <div style="background: #f0f4ff; padding: 15px; border-radius: 8px; border-left: 3px solid #667eea;">
    <strong>💰 <a href="dev/sai-keeper/api-lp.md">LP API</a></strong>
    <p style="margin: 5px 0; font-size: 13px;">Liquidity provider positions and data</p>
  </div>
  
  <div style="background: #ffe6f0; padding: 15px; border-radius: 8px; border-left: 3px solid #f093fb;">
    <strong>🔮 <a href="dev/sai-keeper/api-oracle.md">Oracle API</a></strong>
    <p style="margin: 5px 0; font-size: 13px;">Price feeds and oracle information</p>
  </div>
  
  <div style="background: #ffe6f0; padding: 15px; border-radius: 8px; border-left: 3px solid #f093fb;">
    <strong>💳 <a href="dev/sai-keeper/api-fees.md">Fees API</a></strong>
    <p style="margin: 5px 0; font-size: 13px;">Fee structures and calculations</p>
  </div>
</div>

### Code Examples

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin: 20px 0;">
  <div style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); padding: 20px; border-radius: 12px; color: white;">
    <h4 style="margin-top: 0;">🔍 Queries</h4>
    <p>Learn how to query Sai data with real-world examples</p>
    <a href="dev/sai-keeper/examples-queries.md" style="color: white; text-decoration: underline; font-weight: bold;">View Examples →</a>
  </div>
  
  <div style="background: linear-gradient(135deg, #fa709a 0%, #fee140 100%); padding: 20px; border-radius: 12px; color: #333;">
    <h4 style="margin-top: 0;">📡 Subscriptions</h4>
    <p>Real-time data subscriptions and event streaming</p>
    <a href="dev/sai-keeper/examples-subscriptions.md" style="color: #333; text-decoration: underline; font-weight: bold;">View Examples →</a>
  </div>
</div>

### Advanced Topics

<div style="background: rgba(200, 200, 200, 0.1); padding: 15px; border-radius: 8px; margin: 20px 0;">
  <strong>🎯 <a href="dev/sai-keeper/filters-pagination.md">Filters & Pagination</a></strong>
  <p style="margin: 8px 0 0 0; font-size: 14px;">Advanced filtering and pagination techniques for large datasets</p>
</div>

---

## 💡 Need Help?

<div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 15px; margin: 20px 0;">
  <div style="background: #f0f8ff; padding: 20px; border-radius: 8px; border-left: 3px solid #667eea;">
    <strong>❓ Questions?</strong>
    <p style="margin: 10px 0 0 0; font-size: 14px;"><a href="../learn/trading/faq.md">Check our FAQ</a> or ask in our <a href="../community.md">community</a></p>
  </div>
  
  <div style="background: #fff0f8; padding: 20px; border-radius: 8px; border-left: 3px solid #f093fb;">
    <strong>🐛 Bug Report?</strong>
    <p style="margin: 10px 0 0 0; font-size: 14px;">Open an issue on our <strong>GitHub repository</strong></p>
  </div>
  
  <div style="background: #f0fff0; padding: 20px; border-radius: 8px; border-left: 3px solid #4facfe;">
    <strong>✨ Feature Request?</strong>
    <p style="margin: 10px 0 0 0; font-size: 14px;">Let us know on <a href="https://x.com/saidotfun">X/Twitter</a></p>
  </div>
</div>

---

<div style="text-align: center; margin: 40px 0; padding: 30px; background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(240, 147, 251, 0.1) 100%); border-radius: 12px;">
  <h3 style="margin-top: 0;">Ready to build?</h3>
  <p>Pick an integration method above and start coding. We've got you covered! 🚀</p>
</div>