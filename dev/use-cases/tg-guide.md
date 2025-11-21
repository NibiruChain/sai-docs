# Build Your First SAI Telegram Bot - Beginner's Guide

A step-by-step walkthrough for creating a Telegram bot that queries real data from the SAI protocol. **No prior bot experience needed!**

---

## What You're About to Build

By the end of this guide, you'll have a working Telegram bot that:

- Shows perpetual trades for any wallet address
- Displays oracle prices for all tokens
- Lets users search for specific token prices
- Filters trades by asset (BTC only, ETH only, etc.)
- Displays results with pagination (Next buttons)

**Best part:** No database needed! Everything pulls live data from SAI's GraphQL API.

---

## Prerequisites Checklist

Before starting, make sure you have:

### Software You'll Need

- **Python 3.10+** - [Download here](https://www.python.org/downloads/)
  - Check your version: Open terminal and type `python3 --version`
- **A code editor** - Any of these work:
  - [VS Code](https://code.visualstudio.com/) (recommended for beginners)
  - PyCharm
  - Sublime Text
  - Even Notepad will work!
- **Terminal/Command Line** - You'll need to type a few commands

### Accounts You'll Need

- **Telegram account** - To test your bot
- **A Telegram bot token** - We'll get this from BotFather (the official Telegram bot creator tool)

### Knowledge Requirements

- Basic Python understanding (if-statements, functions, dictionaries)
- How to use terminal/command line (navigating folders, running commands)
- **No GraphQL knowledge needed** - We'll explain everything!

> **Don't have Python installed?** This is normal! Follow the download link above and choose your operating system. Python installation is straightforward.

---

## Part 1: Get Your Telegram Bot Token (5 minutes)

Your bot needs a unique token to identify itself to Telegram. Here's how to get one:

### Step 1: Open BotFather on Telegram

1. Open the Telegram app (phone, desktop, or [web](https://web.telegram.org/))
2. Search for `@BotFather` in the search bar
3. Click on it and start a conversation

You should see BotFather respond with a welcome message and commands.

### Step 2: Create a New Bot

1. Send this command: `/newbot`
2. BotFather will ask: **"Alright! New bot. How are we going to call it? Please choose a name for your bot."**
   - Type something like: `My SAI Trading Bot` (this is what appears in Telegram)
3. BotFather will ask: **"Good. Now let's choose a username for your bot. It must end in bot."**
   - Type something like: `my_sai_trading_bot` (must end with `bot`)
   - Example: `sai_price_bot`, `trading_bot_sai`, etc.

### Step 3: Copy Your Token

BotFather will send you a message like:

```txt
Done! Congratulations on your new bot. You'll find it at t.me/my_sai_trading_bot. 
You can now add a description, about section and profile picture for your bot, see /help for a list of commands. By the way, when you've finished creating your bot and it's ready to go public, ping our Bot Support if you'd like a chance to be featured on the @BotStoreBot and the Bot Store within Telegram.

Here's your token:

123456789:ABCdefGHIjklMNOpqrsTUVwxyz
```

**Important:** This token is like your bot's password. **Never share it publicly or commit it to GitHub!**

---

## Part 2: Prepare Your Computer (10 minutes)

### Step 1: Create a Project Folder

Open your terminal/command prompt and create a folder for your project:

```bash
mkdir sai-telegram-bot
cd sai-telegram-bot
```

**What this does:**

- Creates a new folder called `sai-telegram-bot`
- Moves you into that folder (you'll work from here)

### Step 2: Create a Virtual Environment

A virtual environment is like a sandbox for your project. It keeps your bot's dependencies separate from other Python projects.

**On Mac/Linux:**

```bash
python3 -m venv venv
source venv/bin/activate
```

**On Windows:**

```bash
python -m venv venv
venv\Scripts\activate
```

**What should happen:**

- Your terminal prompt should now show `(venv)` at the beginning
- Example: `(venv) user@computer sai-telegram-bot %`

If you see `(venv)` ✅ - Perfect! You're in the virtual environment.

> **What's a virtual environment?** Think of it like a separate Python installation just for this project. If you install packages here, they won't affect your other projects.

### Step 3: Create Your Project Structure

Let's create the folders and files you'll need:

```bash
mkdir bot
touch bot/__init__.py
touch bot/main.py
touch bot/graphql.py
touch requirements.txt
touch .env
touch env.example
```

**What this creates:**

```txt
sai-telegram-bot/
├── venv/                  # Virtual environment (created automatically)
├── bot/
│   ├── __init__.py       # Makes 'bot' a Python package
│   ├── main.py           # Your bot's main code
│   └── graphql.py        # Code to talk to SAI's API
├── requirements.txt      # List of packages to install
├── .env                  # Your secret config (token goes here)
└── env.example          # Template for .env
```

---

## Part 3: Install Required Packages (2 minutes)

Packages are like plugins that give Python extra abilities. We need several for this bot.

### Step 1: Create `requirements.txt`

Open your code editor and create a file called `requirements.txt` with this content:

```txt
python-telegram-bot==21.4
requests==2.32.3
python-dotenv==1.0.1
pytz==2024.1
```

**What each package does:**

| Package | Purpose |
|---------|---------|
| `python-telegram-bot` | Library for creating Telegram bots |
| `requests` | Makes HTTP requests to APIs |
| `python-dotenv` | Loads secret config from .env file |
| `pytz` | Handles timezones |

### Step 2: Install the Packages

In your terminal (make sure `(venv)` is showing), type:

```bash
pip install -r requirements.txt
```

This will download and install all the packages. You should see lots of text scrolling by. Wait for it to finish.

**Success looks like:**

```cmd
Successfully installed python-telegram-bot-21.4 requests-2.32.3 python-dotenv-1.0.1 pytz-2024.1
```

---

## Part 4: Set Up Your Secret Token (5 minutes)

We'll store your bot token in a special file so it's not exposed in your code.

### Step 1: Create `env.example`

This file shows what secrets are needed (without actual values):

```ini
# Telegram Bot Configuration
# Get your bot token from @BotFather on Telegram
TELEGRAM_BOT_TOKEN=your_bot_token_here

# SAI GraphQL Endpoint (the server we get data from)
SAI_GRAPHQL_ENDPOINT=https://sai-keeper.nibiru.fi/query
```

### Step 2: Create `.env`

Copy the example file:

```bash
cp env.example .env
```

Now open `.env` in your editor and replace `your_bot_token_here` with your actual token from BotFather:

```ini
TELEGRAM_BOT_TOKEN=123456789:ABCdefGHIjklMNOpqrsTUVwxyz
SAI_GRAPHQL_ENDPOINT=https://sai-keeper.nibiru.fi/query
```

**Security note:** The `.env` file should NEVER be shared or committed to GitHub. If you use Git, add `.env` to your `.gitignore` file.

---

## Part 5: Build the GraphQL Client (Intermediate)

The "GraphQL client" is code that talks to SAI's data API. Don't worry - we'll explain everything!

### What is GraphQL?

GraphQL is a way to ask a server for specific data. Think of it like a restaurant menu:

- **REST API (old way):** "Give me all the data about trades" (you get everything)
- **GraphQL (new way):** "Give me only the trade ID, amount, and price" (you get exactly what you want)

### Create `bot/graphql.py`

This file handles all communication with SAI's API. Here's the code:

```python
import os
from typing import Any, Dict, List, Optional
import requests

# Get the GraphQL endpoint from .env file, or use default
SAI_GRAPHQL_ENDPOINT = os.environ.get(
    "SAI_GRAPHQL_ENDPOINT", 
    "https://sai-keeper.nibiru.fi/query"
)


class SaiGQLClient:
    """
    This class talks to the SAI GraphQL API.
    It's like a translator between your bot and SAI's data server.
    """
    
    def __init__(self, endpoint: Optional[str] = None) -> None:
        """
        Initialize the client.
        
        Args:
            endpoint: URL of the GraphQL server (or None to use default)
        """
        self.endpoint = endpoint or SAI_GRAPHQL_ENDPOINT

    def query(self, query: str, variables: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """
        Send a GraphQL query to the server.
        
        Args:
            query: The GraphQL query string (ask what data you want)
            variables: Dynamic values to plug into the query
            
        Returns:
            Dictionary with the response data
            
        Raises:
            RuntimeError if the query fails
        """
        # Send POST request (like sending a letter) to GraphQL server
        resp = requests.post(
            self.endpoint,
            json={"query": query, "variables": variables or {}},
            timeout=20,  # Wait max 20 seconds for response
        )
        
        # Check if the HTTP request itself failed
        resp.raise_for_status()
        
        # Convert response from JSON format to Python dictionary
        try:
            payload = resp.json()
        except ValueError as e:
            # If response wasn't JSON, something went wrong
            raise RuntimeError(
                f"Invalid JSON response from {self.endpoint}: {resp.text[:200]}"
            )
        
        # Check if GraphQL returned an error
        if "errors" in payload:
            raise RuntimeError(str(payload["errors"]))
        
        # Return just the "data" part of the response
        return payload.get("data", {})

    def fetch_trades(
        self, 
        trader: str, 
        is_open: Optional[bool] = None, 
        limit: int = 100,
        base_symbol: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """
        Get trades for a specific wallet address.
        
        Args:
            trader: Wallet address (e.g., "nibiru1abc123...")
            is_open: 
                - True: only open trades
                - False: only closed trades  
                - None: all trades
            limit: Max number of trades to return
            base_symbol: Filter by token (e.g., "BTC" for Bitcoin only)
            
        Returns:
            List of trade dictionaries
        """
        # This is a GraphQL query (in plain English: "give me trades")
        query = """
        query Trades($trader: String!, $isOpen: Boolean, $limit: Int!) {
          perp {
            trades(
              where: { trader: $trader, isOpen: $isOpen }
              limit: $limit
              order_by: sequence
              order_desc: true
            ) {
              id
              trader
              isOpen
              isLong
              leverage
              openPrice
              closePrice
              openCollateralAmount
              collateralAmount
              openBlock { block block_ts }
              closeBlock { block block_ts }
              state {
                positionValue
                liquidationPrice
                pnlCollateral
                pnlPct
              }
              perpBorrowing {
                marketId
                baseToken { id name symbol }
                quoteToken { id name symbol }
              }
            }
          }
        }
        """
        
        # Send the query with the variables
        data = self.query(query, {
            "trader": trader, 
            "isOpen": is_open, 
            "limit": limit
        })
        
        # Extract trades from the response
        trades = data.get("perp", {}).get("trades", [])
        
        # Filter by symbol if user asked for it (e.g., BTC only)
        if base_symbol:
            base_symbol_upper = base_symbol.upper()
            trades = [
                t for t in trades
                if (t.get("perpBorrowing", {}).get("baseToken", {}).get("symbol", "") or "").upper() == base_symbol_upper
            ]
        
        return trades

    def fetch_prices(self, limit: int = 200) -> List[Dict[str, Any]]:
        """
        Get current prices for all tokens from the oracle.
        
        Args:
            limit: Max number of prices to return
            
        Returns:
            List of price dictionaries
        """
        query = """
        query Prices($limit: Int!) {
          oracle {
            tokenPricesUsd(limit: $limit, order_by: token_id) {
              priceUsd
              token { id name symbol }
              lastUpdatedBlock { block block_ts }
            }
          }
        }
        """
        data = self.query(query, {"limit": limit})
        return data.get("oracle", {}).get("tokenPricesUsd", [])

    def fetch_price_by_symbol(self, symbol: str) -> Optional[Dict[str, Any]]:
        """
        Get price for one specific token.
        
        Args:
            symbol: Token symbol (e.g., "BTC", "ETH")
            
        Returns:
            Price dictionary if found, None if not
        """
        prices = self.fetch_prices(limit=200)
        symbol_upper = symbol.upper()
        for price in prices:
            token = price.get("token") or {}
            if (token.get("symbol") or "").upper() == symbol_upper:
                return price
        return None
```

**Key concepts explained:**

- **`class SaiGQLClient:`** - A class is like a blueprint. It groups related functions together.
- **`def query():`** - The main function that sends queries to the API
- **`fetch_trades():`** - Gets trade data for a wallet
- **`fetch_prices():`** - Gets token prices
- **String variables like `$trader`** - These are placeholders that get filled in with real values

---

## Part 6: Create the Bot's Brain (`bot/main.py`)

This is where your bot comes alive! We'll build this in sections.

### Section 1: Imports and Setup

Create `bot/__init__.py` (can be empty):

```python
# This file makes 'bot' a Python package
```

Create `bot/main.py` - Start with imports and setup:

```python
import os
import logging
from typing import Optional

from dotenv import load_dotenv
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import (
    Application,
    CommandHandler,
    CallbackQueryHandler,
    ContextTypes,
)

from .graphql import SaiGQLClient

# Set up logging (so you can see what your bot is doing)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
```

**What this does:**

- Imports libraries we installed earlier
- Sets up logging so we can debug issues
- Imports our GraphQL client

---

### Section 2: Trade Formatting Functions

Add this to `bot/main.py`:

```python
def format_trade_open(trade: dict) -> str:
    """
    Format an open trade for display in Telegram.
    Shows all the important info: position value, profit/loss, etc.
    """
    trade_id = trade.get('id', '?')
    is_long = trade.get('isLong', False)
    side = "🟢 LONG" if is_long else "🔴 SHORT"
    
    # Extract market info (what's being traded)
    market = trade.get("perpBorrowing", {})
    base_token = market.get("baseToken") or {}
    quote_token = market.get("quoteToken") or {}
    base = base_token.get("symbol") or base_token.get("name") or "?"
    quote = quote_token.get("symbol") or quote_token.get("name") or "?"
    
    # Extract trade details
    leverage = trade.get('leverage')
    entry_price = trade.get('openPrice')
    open_collateral = trade.get('openCollateralAmount')
    
    # Extract state info (for open trades)
    state = trade.get('state') or {}
    position_value = state.get('positionValue')  # How much the position is worth
    liquidation_price = state.get('liquidationPrice')  # When you get liquidated
    pnl = state.get('pnlCollateral')  # Profit/Loss in dollars
    pnl_pct = state.get('pnlPct')  # Profit/Loss in percentage
    
    open_ts = trade.get("openBlock", {}).get("block_ts")
    
    # Build the message
    lines = [
        f"━━━━━━━━━━━━━━━━",
        f"Trade #{trade_id} ✅ OPEN",
        f"{base}/{quote} | {side} | {leverage}x leverage",
        f"Entry Price: {entry_price}",
    ]
    
    if liquidation_price:
        lines.append(f"Liquidation Price: {liquidation_price}")
    
    # Convert from micro units to dollars
    # (API stores values * 1,000,000, we need to divide back)
    if position_value is not None:
        position_value_usd = position_value / (10 ** 6)
        lines.append(f"Position Value: ${position_value_usd:,.2f}")
    
    if pnl is not None:
        pnl_usd = pnl / (10 ** 6)
        pnl_sign = "+" if pnl_usd >= 0 else ""
        lines.append(f"PnL: {pnl_sign}${pnl_usd:,.2f}")
    
    if pnl_pct is not None:
        pnl_sign = "+" if pnl_pct >= 0 else ""
        lines.append(f"PnL %: {pnl_sign}{pnl_pct:.2f}%")
    
    if open_collateral:
        collateral_usd = open_collateral / (10 ** 6)
        lines.append(f"Collateral: ${collateral_usd:,.2f}")
    
    if open_ts:
        lines.append(f"Opened: {open_ts}")
    
    return "\n".join(lines)


def format_trade_closed(trade: dict) -> str:
    """
    Format a closed trade for display.
    Shows entry/exit prices and when it was opened/closed.
    """
    trade_id = trade.get('id', '?')
    is_long = trade.get('isLong', False)
    side = "🟢 LONG" if is_long else "🔴 SHORT"
    
    market = trade.get("perpBorrowing", {})
    base_token = market.get("baseToken") or {}
    quote_token = market.get("quoteToken") or {}
    base = base_token.get("symbol") or base_token.get("name") or "?"
    quote = quote_token.get("symbol") or quote_token.get("name") or "?"
    
    leverage = trade.get('leverage')
    entry_price = trade.get('openPrice')
    exit_price = trade.get('closePrice')
    
    open_ts = trade.get("openBlock", {}).get("block_ts")
    close_ts = trade.get("closeBlock", {}).get("block_ts")
    
    lines = [
        f"━━━━━━━━━━━━━━━━",
        f"Trade #{trade_id} ❌ CLOSED",
        f"{base}/{quote} | {side} | {leverage}x leverage",
        f"Entry Price: {entry_price}",
    ]
    
    if exit_price:
        lines.append(f"Exit Price: {exit_price}")
    
    if open_ts:
        lines.append(f"Opened: {open_ts}")
    if close_ts:
        lines.append(f"Closed: {close_ts}")
    
    return "\n".join(lines)
```

**What this does:**

- `format_trade_open()` - Displays an open trade with profit/loss info
- `format_trade_closed()` - Displays a closed trade with entry/exit prices
- The division by `10^6` converts from micro-units (how the API stores numbers) to regular dollars

---

### Section 3: Price Formatting Functions

Add this to `bot/main.py`:

```python
# Popular tokens to show first
POPULAR_TOKENS = ["BTC", "ETH", "USDT", "USDC", "NIBI", "ATOM", "SOL"]

def format_prices(prices: list, start_idx: int = 0, page_size: int = 10) -> tuple:
    """
    Format prices for display with pagination (Next buttons).
    
    Args:
        prices: List of all prices
        start_idx: Which index to start at
        page_size: How many prices per page
        
    Returns:
        (formatted_text, has_more_pages)
    """
    if not prices:
        return "No prices found.", False
    
    # Sort prices: popular tokens first, then by ID
    def sort_key(p):
        token = p.get("token") or {}
        symbol = (token.get("symbol") or "").upper()
        if symbol in POPULAR_TOKENS:
            return (0, POPULAR_TOKENS.index(symbol))
        return (1, token.get("id", 9999))
    
    sorted_prices = sorted(prices, key=sort_key)
    
    # Get just this page of prices
    end_idx = min(start_idx + page_size, len(sorted_prices))
    page_prices = sorted_prices[start_idx:end_idx]
    has_more = end_idx < len(sorted_prices)
    
    # Format as text
    msg_lines = [f"💰 Oracle Prices ({end_idx} of {len(sorted_prices)})\n"]
    for p in page_prices:
        token = p.get("token") or {}
        symbol = token.get("symbol") or token.get("name") or "Unknown"
        price = p.get("priceUsd")
        if price is not None:
            price_str = f"${price:,.2f}" if price >= 1 else f"${price:.8f}"
            msg_lines.append(f"• {symbol}: {price_str}")
    
    return "\n".join(msg_lines), has_more


def format_price_single(price_data: dict) -> str:
    """Format a single price for display."""
    token = price_data.get("token") or {}
    symbol = token.get("symbol") or token.get("name") or "?"
    price = price_data.get("priceUsd")
    
    if price is None:
        return f"Price not available for {symbol}"
    
    price_str = f"${price:,.2f}" if price >= 1 else f"${price:.8f}"
    return f"💰 {symbol}: {price_str}"
```

**What this does:**

- `format_prices()` - Formats multiple prices with pagination
- `format_price_single()` - Formats a single price nicely
- Popular tokens (BTC, ETH, etc.) appear first

---

### Section 4: Command Handlers

Add this to `bot/main.py`:

```python
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Handle /start command - shows welcome message."""
    text = (
        "👋 Welcome to SAI Bot!\n\n"
        "Available commands:\n"
        "/trades <address> - View trades for a wallet\n"
        "/prices - Show all token prices\n"
        "/price <symbol> - Get price for one token\n"
        "/help - Show this message\n\n"
        "Examples:\n"
        "/trades nibiru1abc123def456\n"
        "/price BTC\n"
        "/prices"
    )
    await update.effective_message.reply_text(text)


async def help_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Handle /help command."""
    await start(update, context)
```

**What this does:**

- `/start` command shows welcome message
- `/help` shows the same message

---

### Section 5: The Trades Command

Add this to `bot/main.py`:

```python
async def trades_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """
    Handle /trades command.
    
    Usage:
        /trades <address>
        /trades <address> open
        /trades <address> closed
        /trades <address> btc
    """
    if not context.args:
        await update.effective_message.reply_text(
            "Usage: /trades <wallet_address> [open|closed] [symbol]\n\n"
            "Examples:\n"
            "/trades nibiru1abc123...\n"
            "/trades nibiru1abc123... open\n"
            "/trades nibiru1abc123... btc"
        )
        return
    
    address = context.args[0].strip()
    is_open = None  # None = all trades
    symbol = None
    
    # Parse additional arguments
    for arg in context.args[1:]:
        arg_lower = arg.strip().lower()
        if arg_lower == "open":
            is_open = True
        elif arg_lower == "closed":
            is_open = False
        else:
            symbol = arg.strip().upper()
    
    try:
        # Get trades from SAI
        gql = SaiGQLClient()
        trades = gql.fetch_trades(
            trader=address, 
            is_open=is_open, 
            limit=100, 
            base_symbol=symbol
        )
        
        if not trades:
            await update.effective_message.reply_text(
                f"❌ No trades found for {address}"
            )
            return
        
        # Separate open and closed trades
        open_trades = [t for t in trades if t.get('isOpen')]
        closed_trades = [t for t in trades if not t.get('isOpen')]
        
        # Show open trades first
        if open_trades:
            for i, trade in enumerate(open_trades[:5]):  # Show first 5
                await update.effective_message.reply_text(
                    format_trade_open(trade)
                )
        
        # Show closed trades
        if closed_trades:
            for i, trade in enumerate(closed_trades[:5]):  # Show first 5
                await update.effective_message.reply_text(
                    format_trade_closed(trade)
                )
                
    except Exception as e:
        logger.error(f"Error in trades_cmd: {e}")
        await update.effective_message.reply_text(
            f"❌ Error: {str(e)}"
        )
```

---

### Section 6: The Prices Commands

Add this to `bot/main.py`:

```python
async def prices_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Handle /prices command - show all prices."""
    try:
        gql = SaiGQLClient()
        prices = gql.fetch_prices(limit=200)
        
        if not prices:
            await update.effective_message.reply_text("No prices found.")
            return
        
        # Get first page
        text, has_more = format_prices(prices, start_idx=0, page_size=10)
        
        # Add keyboard with "Next" button if there are more prices
        reply_markup = None
        if has_more:
            keyboard = [[InlineKeyboardButton("Next →", callback_data="prices_next")]]
            reply_markup = InlineKeyboardMarkup(keyboard)
        
        await update.effective_message.reply_text(text, reply_markup=reply_markup)
        
    except Exception as e:
        logger.error(f"Error in prices_cmd: {e}")
        await update.effective_message.reply_text(f"❌ Error: {str(e)}")


async def price_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Handle /price <symbol> command - show single price."""
    if not context.args:
        await update.effective_message.reply_text(
            "Usage: /price <symbol>\n\n"
            "Examples: /price BTC, /price ETH"
        )
        return
    
    symbol = context.args[0].strip()
    
    try:
        gql = SaiGQLClient()
        price_data = gql.fetch_price_by_symbol(symbol)
        
        if not price_data:
            await update.effective_message.reply_text(
                f"❌ Token '{symbol}' not found"
            )
            return
        
        text = format_price_single(price_data)
        await update.effective_message.reply_text(text)
        
    except Exception as e:
        logger.error(f"Error in price_cmd: {e}")
        await update.effective_message.reply_text(f"❌ Error: {str(e)}")
```

---

### Section 7: Callback Handler (for buttons)

Add this to `bot/main.py`:

```python
async def callback_handler(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Handle button clicks (pagination buttons)."""
    query = update.callback_query
    if not query:
        return
    
    # Acknowledge the button click
    await query.answer()
    
    # Handle "Next" button for prices
    if query.data == "prices_next":
        page = context.user_data.get("prices_page", 0) + 1
        context.user_data["prices_page"] = page
        
        try:
            gql = SaiGQLClient()
            prices = gql.fetch_prices(limit=200)
            text, has_more = format_prices(prices, start_idx=page * 10, page_size=10)
            
            reply_markup = None
            if has_more:
                keyboard = [[InlineKeyboardButton("Next →", callback_data="prices_next")]]
                reply_markup = InlineKeyboardMarkup(keyboard)
            
            await query.edit_message_text(text, reply_markup=reply_markup)
        except Exception as e:
            await query.edit_message_text(f"❌ Error: {str(e)}")
```

---

### Section 8: Start the Bot

Add this to the end of `bot/main.py`:

```python
def main() -> None:
    """Main function - creates and starts the bot."""
    # Load environment variables from .env file
    load_dotenv()
    
    # Get bot token
    token = os.environ.get("TELEGRAM_BOT_TOKEN")
    if not token:
        raise RuntimeError("❌ TELEGRAM_BOT_TOKEN not found in .env!")
    
    # Create the bot application
    app = Application.builder().token(token).build()
    
    # Register command handlers
    app.add_handler(CommandHandler("start", start))
    app.add_handler(CommandHandler("help", help_cmd))
    app.add_handler(CommandHandler("trades", trades_cmd))
    app.add_handler(CommandHandler("prices", prices_cmd))
    app.add_handler(CommandHandler("price", price_cmd))
    
    # Register button click handler
    app.add_handler(CallbackQueryHandler(callback_handler))
    
    # Start the bot
    logger.info("🚀 Bot is starting...")
    app.run_polling()


if __name__ == "__main__":
    main()
```

---

## Part 7: Test Your Bot! (5 minutes)

### Step 1: Activate Virtual Environment

Make sure you're in the project folder and the virtual environment is active:

```bash
# You should see (venv) at the start of your terminal prompt
# If not, activate it:

# Mac/Linux:
source venv/bin/activate

# Windows:
venv\Scripts\activate
```

### Step 2: Start the Bot

```bash
python -m bot.main
```

You should see:

```txt
INFO:__main__:🚀 Bot is starting...
```

**This means your bot is running!** Leave this terminal open.

### Step 3: Test on Telegram

1. Open Telegram
2. Search for your bot (the username you created)
3. Send `/start`
4. You should see the welcome message!

Try these commands:

| Command | What it does |
|---------|-------------|
| `/start` | Shows welcome message |
| `/help` | Shows help message |
| `/prices` | Shows all token prices |
| `/price BTC` | Shows BTC price |
| `/trades nibiru1abc123...` | Shows trades (need real wallet address) |

### Step 4: Stop the Bot

When you're done testing, press `Ctrl+C` in the terminal to stop the bot.

---

## Troubleshooting

### Problem: "TELEGRAM_BOT_TOKEN not found"

**Solution:**

1. Check that `.env` file exists in your project root
2. Open it and verify the token is there
3. Make sure there are no spaces: `TELEGRAM_BOT_TOKEN=123456789:ABC...`

### Problem: Bot doesn't respond to commands

**Solution:**

1. Check that the bot is still running (you should see `🚀 Bot is starting...` in terminal)
2. Try the `/start` command first
3. Check for errors in the terminal

### Problem: "ModuleNotFoundError: No module named 'bot'"

**Solution:**

```bash
# Make sure you're in the project root directory
cd /path/to/sai-telegram-bot

# Make sure you activated the virtual environment
source venv/bin/activate  # Mac/Linux
# or
venv\Scripts\activate     # Windows

# Run with -m flag
python -m bot.main
```

### Problem: GraphQL errors or "No prices found"

**Solution:**

1. Check your internet connection
2. Verify the endpoint is correct in `.env`:

   ```txt
   SAI_GRAPHQL_ENDPOINT=https://sai-keeper.nibiru.fi/query
   ```

3. Test the endpoint manually in your browser (visit the URL)

---

## How It All Works Together

Here's the flow when someone uses your bot:

```txt
1. User sends: /prices
   ↓
2. Telegram receives it and forwards to your bot
   ↓
3. prices_cmd() function is called
   ↓
4. SaiGQLClient queries the SAI GraphQL API
   ↓
5. API returns price data
   ↓
6. format_prices() formats the data beautifully
   ↓
7. Bot sends the message back to the user
   ↓
8. User sees prices with a "Next" button
   ↓
9. User clicks "Next"
   ↓
10. callback_handler() fetches the next page
    ↓
11. User sees next page of prices
```

---

## Next Steps

Your bot is working! Now you can:

### Level Up Your Bot

- Add price alerts ("Notify me when BTC hits $100,000")
- Add wallet monitoring ("Show me when this address opens a trade")
- Add more markets or data sources

### Deploy to Production

- Run your bot 24/7 on a server (AWS, DigitalOcean, etc.)
- Use `systemd` or Docker to keep it running

### Learn More

- [python-telegram-bot docs](https://python-telegram-bot.org/)
- [GraphQL basics](https://graphql.org/learn/)
- [SAI Protocol docs](https://docs.sai.fi)

---

## Congratulations! 🎉

You've built your first Telegram bot that:

- Connects to the SAI protocol
- Queries real live data
- Displays prices and trades
- Handles pagination
- Filters by asset

**You're now a bot developer!**

---

## Common Questions

**Q: Can I share my bot with others?**
A: Yes! They can find it by searching your bot's username on Telegram and click "Start".

**Q: Will my bot keep running if I close my computer?**
A: No. You'll need to deploy it to a server to run 24/7. See the "Deploy to Production" section.

**Q: How do I update my bot with new features?**
A: Edit the Python files, then restart the bot (press Ctrl+C and run `python -m bot.main` again).

**Q: Is it safe to share my bot token?**
A: No! Treat it like a password. Keep it in `.env` and never commit to GitHub.

---

Happy coding! 🚀
