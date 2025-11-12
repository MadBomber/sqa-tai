# CDL_CDL_KICKINGBYLENGTH (Kicking By Length)

## Overview

The Kicking By Length is a strong reversal candlestick pattern used in technical analysis to identify potential trading opportunities. The pattern consists of Two marubozu candles in opposite directions with gap. This pattern provides traders with insights into market psychology and potential price movements when properly confirmed.

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
- Requires sufficient historical data for pattern recognition
- More data provides better trend context for signal validation

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

open =  [50.0, 49.5, 48.0, 47.5, 48.5]
high =  [50.5, 50.0, 48.5, 48.0, 49.5]
low =   [49.5, 48.5, 47.5, 47.0, 48.0]
close = [49.5, 48.5, 48.0, 47.5, 49.0]

pattern = SQA::TAI.cdl_kickingbylength(open, high, low, close)

puts "Kicking By Length signal: #{pattern.last}"
# Output: 100 or -100 (pattern detected) or 0 (no pattern)
```

### With Confirmation

```ruby
require 'sqa/tai'

# Get historical data
open, high, low, close = get_ohlc_data('AAPL')

# Calculate pattern
pattern = SQA::TAI.cdl_kickingbylength(open, high, low, close)

# Add confirmation with volume and RSI
volume = get_volume_data('AAPL')
rsi = SQA::TAI.rsi(close, period: 14)

if pattern.last != 0
  puts "Kicking By Length detected!"
  puts "Signal strength: #{pattern.last}"
  puts "RSI: #{rsi.last.round(2)}"
  puts "Consider entry with proper risk management"
end
```

## Understanding the Pattern

### What It Measures

The Kicking By Length pattern measures:
- **Market Psychology**: Powerful shift in market sentiment with strong conviction
- **Trend Dynamics**: Potential shift or continuation in price direction
- **Momentum**: Balance of power between buyers and sellers

### Pattern Characteristics

- **Type**: Strong reversal
- **Context**: Best used in any trend
- **Signal**: 100 or -100
- **Reliability**: Very high - one of strongest reversal patterns
- **Timeframes**: Most reliable on daily and 4-hour charts




## Interpretation

### Signal Values

- **+100**: Bullish pattern detected - potential upward reversal or continuation
- **-100**: Bearish pattern detected - potential downward reversal or continuation
- **0**: No pattern detected - continue monitoring

### Pattern Recognition

The Kicking By Length is identified by:
- Specific candle body and shadow relationships
- Position within the prevailing trend
- Can appear in various market conditions

## Trading Signals

### Entry Strategy

**Pattern Confirmation**:
1. Wait for pattern completion
2. Confirm with next candle moving in signal direction
3. Verify with volume increase
4. Check RSI for overbought/oversold conditions

**Entry Points**:
- Aggressive: Enter on pattern completion
- Conservative: Wait for next candle confirmation
- Safe: Combine with support/resistance levels

### Risk Management

**Stop Loss Placement**:
- Place beyond the pattern's extreme point
- Use ATR to set appropriate distance
- Never risk more than 1-2% of capital per trade

**Take Profit Targets**:
- Target 1: Recent swing high/low
- Target 2: Key support/resistance levels
- Target 3: Fibonacci extensions

## Best Practices

### Optimal Use Cases

Kicking By Length works best when:
- Pattern appears in appropriate trend context (any trend)
- Volume confirms the price action
- Other technical indicators align (RSI, MACD, Moving Averages)
- Pattern forms at key support or resistance levels

### Combining with Other Indicators

**Recommended Combinations**:
- **RSI**: Confirm momentum and overbought/oversold conditions
- **MACD**: Verify trend direction and strength
- **Volume**: Validate buying/selling pressure
- **Moving Averages**: Identify overall trend direction
- **Support/Resistance**: Enhance signal reliability at key levels

### Common Pitfalls

**Avoid These Mistakes**:
1. Trading pattern without confirmation
2. Ignoring overall market trend
3. Not using proper stop losses
4. Over-leveraging based on single pattern
5. Forgetting to check volume confirmation

### Parameter Optimization

- Use daily timeframe for highest reliability
- Combine with 4-hour for entry timing
- Avoid very short timeframes (increases false signals)
- Test on historical data before live trading

## Practical Example

Complete trading scenario:

```ruby
require 'sqa/tai'

# Historical price data
historical_data = get_market_data('AAPL', days: 50)

# Calculate pattern and indicators
pattern = SQA::TAI.cdl_kickingbylength(
  historical_data[:open],
  historical_data[:high],
  historical_data[:low],
  historical_data[:close]
)

rsi = SQA::TAI.rsi(historical_data[:close], period: 14)
macd, signal, _ = SQA::TAI.macd(historical_data[:close])

# Trading logic
if pattern.last == 100  # Bullish signal
  current_price = historical_data[:close].last
  pattern_low = historical_data[:low].last(3).min

  if rsi.last < 70 && macd.last > signal.last
    puts "STRONG BUY SIGNAL"
    puts "Entry: $#{current_price}"
    puts "Stop: $#{pattern_low * 0.98}"
    puts "Target: $#{current_price * 1.05}"
    puts "Risk/Reward: 1:2.5"
  end
elsif pattern.last == -100  # Bearish signal
  current_price = historical_data[:close].last
  pattern_high = historical_data[:high].last(3).max

  if rsi.last > 30 && macd.last < signal.last
    puts "STRONG SELL SIGNAL"
    puts "Entry: $#{current_price}"
    puts "Stop: $#{pattern_high * 1.02}"
    puts "Target: $#{current_price * 0.95}"
    puts "Risk/Reward: 1:2.5"
  end
end
```

## Related Indicators

### Similar Patterns
- [Doji](cdl_doji.md) - Indecision candle patterns
- [Hammer](cdl_hammer.md) - Bullish reversal pattern
- [Engulfing](cdl_engulfing.md) - Strong reversal pattern

### Complementary Indicators
- [RSI](../momentum/rsi.md) - Momentum confirmation
- [MACD](../momentum/macd.md) - Trend direction and strength
- [Volume OBV](../volume/obv.md) - Volume analysis
- [Bollinger Bands](../overlap/bbands.md) - Volatility context

### Pattern Family
The Kicking By Length belongs to the candlestick pattern family used for:
- Identifying potential reversals
- Confirming trend continuations
- Analyzing market psychology
- Timing entry and exit points

## Advanced Topics

### Multi-Timeframe Analysis

Use Kicking By Length across multiple timeframes:
- **Weekly**: Identify major trend direction
- **Daily**: Spot pattern formation
- **4-Hour**: Fine-tune entry timing
- **1-Hour**: Manage position and stops

### Market Regime Adaptation

Pattern reliability varies by market:
- **Trending Markets**: Moderate reliability
- **Ranging Markets**: Higher reliability
- **High Volatility**: Use wider stops and smaller position sizes
- **Low Volatility**: Tighten stops but expect smaller moves

### Statistical Considerations

- Success rate varies by market conditions (typically 50-65%)
- Confirmation significantly improves reliability
- Volume validation adds 10-15% to success rate
- Pattern at support/resistance adds 15-20% reliability

## References

- Nison, Steve. "Japanese Candlestick Charting Techniques" (1991)
- Bulkowski, Thomas. "Encyclopedia of Candlestick Charts" (2008)
- Morris, Gregory L. "Candlestick Charting Explained" (2006)
- [StockCharts Candlestick Patterns](https://school.stockcharts.com/doku.php?id=chart_analysis:introduction_to_candlesticks)

## See Also

- [Candlestick Pattern Overview](index.md)
- [Pattern Recognition Guide](../../getting-started/pattern-recognition.md)
- [API Reference](../../api-reference.md)
