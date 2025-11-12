# CDL_CDL_INVERTEDHAMMER (Inverted Hammer)

## Overview

The Inverted Hammer is a single-candle bullish reversal pattern that bullish reversal pattern with long upper shadow at bottom of downtrend. This pattern is used to identify potential trend changes and provides traders with entry signals when combined with proper confirmation.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `open` | Array | Required | Array of opening prices |
| `high` | Array | Required | Array of high prices |
| `low` | Array | Required | Array of low prices |
| `close` | Array | Required | Array of closing prices |

### Parameter Details


**Note**: Array elements should be ordered from oldest to newest (chronological order)

**OHLC Arrays**
- All four price arrays must have the same length
- Minimum 1 candle required for pattern detection
- More historical data provides better context for trend analysis

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

open =  [50.0, 49.5, 48.0, 47.5, 48.5]
high =  [50.5, 50.0, 48.5, 48.0, 49.5]
low =   [49.5, 48.5, 47.5, 47.0, 48.0]
close = [49.5, 48.5, 48.0, 47.5, 49.0]

pattern = SQA::TAI.cdl_invertedhammer(open, high, low, close)

puts "Inverted Hammer signal: #{pattern.last}"
# Output: 100 (pattern detected) or 0 (no pattern)
```

## Understanding the Pattern

### What It Measures

The Inverted Hammer pattern measures:
- **Reversal Potential**: Shift in market sentiment and momentum
- **Market Psychology**: Bears still in control but bulls testing resistance, potential shift
- **Trend Exhaustion**: Signs that current trend is losing strength

### Pattern Characteristics

- **Type**: Single-candle bullish reversal
- **Trend Context**: Must appear in downtrend
- **Signal**: 100
- **Reliability**: Moderate to High (with confirmation)
- **Best Timeframes**: Daily, 4-hour charts

## Trading Signals

### Entry Signals

**Primary Entry**:
Long when next candle closes above inverted hammer

**Risk Management**:
- Stop Loss: Below the low of the inverted hammer
- Target: Recent resistance or swing high
- Risk/Reward: Aim for minimum 1:2 ratio

### Confirmation Requirements

Strengthen the signal with:
1. **Volume Confirmation**: Increased volume on signal candle
2. **Trend Confirmation**: Clear downtrend established
3. **Support/Resistance**: Pattern at key price level
4. **Next Candle**: Following candle confirms direction

## Best Practices

### Optimal Use Cases

- **Market Conditions**: After established trend with clear momentum
- **Timeframes**: Most reliable on daily charts
- **Asset Classes**: Stocks, forex, commodities
- **Volatility**: Normal volatility environments

### Combining with Other Indicators

- **RSI**: Confirm overbought/oversold conditions
- **MACD**: Verify momentum shift
- **Volume**: Validate buying/selling pressure
- **Moving Averages**: Confirm trend context

## Related Indicators

- [RSI](../momentum/rsi.md) - Momentum confirmation
- [MACD](../momentum/macd.md) - Trend and momentum
- [Volume OBV](../volume/obv.md) - Volume confirmation

## See Also

- [Candlestick Pattern Overview](index.md)
- [Pattern Recognition Guide](../../getting-started/pattern-recognition.md)
- [API Reference](../../api-reference.md)
