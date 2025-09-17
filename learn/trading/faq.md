---
icon: message-question
---

# FAQ

**Q1: How do I partially close a position?**\
A: Use **Decrease Position Size**. You specify how much collateral or leverage to reduce. The rest remains open.

**Q2: Why didn’t my limit order trigger at the exact price I set?**\
A: Slippage and real-time Oracle updates can cause execution at a slightly worse or better price. Also, an external keeper must execute the trigger.

**Q3: Who triggers my Stop Loss or Take Profit?**\
A: Anyone can call “TriggerTrade.” Typically, bots or keepers monitor the price and do it for small “trigger fees.”

**Q4: How do Borrowing Fees get charged?**\
A: Borrowing fees accrue while your trade is open and are subtracted when you close the position or reduce its size.

**Q5: I see a ‘Close Only’ or ‘Paused’ mode. What does that mean?**\
A: The protocol can temporarily restrict new positions (Close Only) or fully pause trading in emergencies. You can still close existing trades in Close Only mode.
