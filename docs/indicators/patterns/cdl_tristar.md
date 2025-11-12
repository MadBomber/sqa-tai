# CDL_TRISTAR (Tristar)

## Overview

The Tristar is a three-candle both candlestick pattern. This rare pattern consists of three consecutive doji candles, with the middle doji gapping away from the others, indicating a potential major trend reversal. This pattern is recognized by TA-Lib and provides potential trading signals when specific price action criteria are met.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `open` | Array | Required | Array of opening prices for each period |
| `high` | Array | Required | Array of high prices for each period |
| `low` | Array | Required | Array of low prices for each period |
| `close` | Array | Required | Array of closing prices for each period |

### Parameter Details

**open**
- Array of opening prices for the analyzed time series
- Must have the same length as high, low, and close arrays
- Used to determine candle body size and direction

**high**
- Array of high prices for each period
- Used to identify upper shadows and price ranges
- Critical for pattern recognition

**low**
- Array of low prices for each period
- Used to identify lower shadows and price ranges
- Essential for pattern validation

**close**
- Array of closing prices for each period
- Determines candle color (white/black) and body size
- Key element in pattern recognition

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

# Example price data
open =  [48.00, 48.20, 48.50, 48.40, 48.30]
high =  [48.70, 48.72, 48.90, 48.87, 48.82]
low =   [47.79, 48.14, 48.39, 48.37, 48.24]
close = [48.20, 48.61, 48.75, 48.63, 48.74]

pattern = SQA::TAI.cdl_tristar(open, high, low, close)

puts "Pattern signal: #{pattern.last}"
```

### Analyzing Pattern Signals

```ruby
# Monitor for pattern signals
pattern.each_with_index do |signal, idx|
  next if signal == 0
  
  if signal > 0
    puts "Bullish signal at index #{idx}"
  elsif signal < 0
    puts "Bearish signal at index #{idx}"
  end
end
```

### Combining with Trend Indicators

```ruby
# Use with confirmation indicators
require 'sqa/tai'

pattern = SQA::TAI.cdl_tristar(open, high, low, close)
sma_50 = SQA::TAI.sma(close, 50)
rsi = SQA::TAI.rsi(close, 14)

current_signal = pattern.last
current_price = close.last

if current_signal != 0
  trend_aligned = (current_signal > 0 && current_price > sma_50.last) ||
                  (current_signal < 0 && current_price < sma_50.last)
  
  if trend_aligned
    puts "Pattern confirmed by trend - #{current_signal > 0 ? 'BULLISH' : 'BEARISH'}"
  end
end
```

## Understanding the Indicator

### What It Measures

The Tristar pattern measures specific price action characteristics that suggest potential market direction. Candlestick patterns capture market psychology through the interaction of opening, high, low, and closing prices within and across multiple periods.

Key aspects:
- Market sentiment through candle body size and position
- Battle between bulls and bears through shadow formation
- Momentum and trend continuation or reversal potential
- Entry and exit timing through pattern completion

### Pattern Characteristics

- **Range**: Returns +100 (bullish) or -100 (bearish), or 0 (no pattern)
- **Type**: three-candle candlestick pattern
- **Signal**: Both indication
- **Best Used**: Context-dependent; works best in specific market conditions
- **Reliability**: Should be confirmed with other technical indicators

## Interpretation

### Signal Values

- **+100 (bullish) or -100 (bearish)**: Pattern detected - indicates potential both signal
- **0**: No pattern present at this position

### Pattern Recognition

The pattern is identified by TA-Lib's recognition algorithms which analyze:
- Relative candle body sizes
- Shadow lengths and proportions
- Price gaps between candles
- Sequential candle colors and relationships
- Overall market context

## Trading Signals

### Entry Signals

When the pattern appears:

```ruby
if pattern.last != 0
  entry_price = close.last
  
  if pattern.last > 0
    # Bullish signal
    stop_loss = low[-3..-1].min * 0.98
    target = entry_price + 2 * (entry_price - stop_loss)
    puts "BUY Signal at $#{entry_price.round(2)}"
  else
    # Bearish signal
    stop_loss = high[-3..-1].max * 1.02
    target = entry_price - 2 * (stop_loss - entry_price)
    puts "SELL Signal at $#{entry_price.round(2)}"
  end
  
  puts "Stop Loss: $#{stop_loss.round(2)}"
  puts "Target: $#{target.round(2)}"
end
```

### Risk Management

```ruby
# Calculate position size based on risk
def calculate_position_size(capital, risk_percent, entry, stop)
  risk_amount = capital * (risk_percent / 100.0)
  risk_per_share = (entry - stop).abs
  shares = (risk_amount / risk_per_share).floor
  return shares
end

# Example
if pattern.last != 0
  capital = 10000
  risk_percent = 2
  shares = calculate_position_size(capital, risk_percent, close.last, stop_loss)
  puts "Position size: #{shares} shares"
end
```

## Best Practices

### Optimal Use Cases

This pattern works best when:
- Used in conjunction with trend indicators
- Combined with volume analysis
- Confirmed by support/resistance levels
- Applied on appropriate timeframes (daily, 4-hour)
- Part of a comprehensive trading strategy

### Combining with Other Indicators

**With Trend Indicators:**
- Moving Averages: Confirm overall trend direction
- ADX: Verify trend strength
- MACD: Validate momentum

**With Volume Indicators:**
- Volume: Confirm pattern with volume spikes
- OBV: Check for volume trend alignment
- VWAP: Validate price levels

**With Support/Resistance:**
- Key Levels: Pattern more significant at support/resistance
- Fibonacci: Pattern at Fib levels adds conviction
- Pivot Points: Confluence with pivots strengthens signal

### Common Pitfalls

1. **Using in Isolation**: Always combine with other indicators
2. **Ignoring Context**: Market conditions matter significantly
3. **Over-Trading**: Not every pattern results in profitable trade
4. **Poor Risk Management**: Always use stops and position sizing
5. **Missing Confirmation**: Wait for pattern completion and confirmation

### Risk Management Guidelines

**Stop Loss Placement:**
- Place stops beyond pattern extremes
- Add buffer for volatility (1-2%)
- Use ATR for dynamic stop placement
- Consider time-based stops

**Position Sizing:**
- Risk no more than 1-2% per trade
- Scale positions based on conviction
- Consider market volatility
- Adjust for pattern reliability

## Practical Example

Complete trading scenario:

```ruby
require 'sqa/tai'

# Historical price data
open =  [45.00, 46.00, 47.50, 49.00, 48.50]
high =  [46.20, 47.80, 49.30, 50.00, 49.00]
low =   [44.80, 45.90, 47.30, 48.70, 48.00]
close = [46.00, 47.50, 49.00, 48.80, 48.50]

# Calculate pattern and indicators
pattern = SQA::TAI.cdl_tristar(open, high, low, close)
sma_20 = SQA::TAI.sma(close, 5)
rsi = SQA::TAI.rsi(close, 5)

# Analysis
current_signal = pattern.last
current_price = close.last

if current_signal != 0
  puts "=" * 50
  puts "Tristar PATTERN DETECTED"
  puts "=" * 50
  puts "Signal: #{current_signal}"
  puts "Current Price: $#{current_price}"
  puts "SMA: $#{sma_20.last.round(2)}"
  puts "RSI: #{rsi.last.round(2)}"
  puts ""
  
  # Trading decision
  if current_signal > 0 && current_price > sma_20.last
    puts "BULLISH SETUP - Consider long position"
  elsif current_signal < 0 && current_price < sma_20.last
    puts "BEARISH SETUP - Consider short position"
  else
    puts "Pattern detected but not confirmed by trend"
  end
end
```

## Related Indicators

### Similar Patterns
- Other candlestick patterns with similar characteristics
- Patterns that work well in conjunction
- Alternative patterns for same market conditions

### Complementary Indicators
- [ADX](../momentum/adx.md): Trend strength confirmation
- [RSI](../momentum/rsi.md): Momentum validation
- [Moving Averages](../overlap/sma.md): Trend direction
- [Volume Indicators](../volume/obv.md): Volume confirmation

## Advanced Topics

### Multi-Timeframe Analysis

For stronger confirmation:
1. Identify pattern on primary timeframe
2. Confirm trend on higher timeframe
3. Use lower timeframe for entry timing
4. Ensure alignment across timeframes

### Pattern Reliability

Factors affecting pattern reliability:
- Market conditions (trending vs ranging)
- Volatility levels
- Volume characteristics
- Position within larger trend
- Confluence with other signals

### Statistical Considerations

Research suggests candlestick patterns work best when:
- Combined with other technical analysis tools
- Applied in appropriate market contexts
- Used with proper risk management
- Confirmed by volume and momentum

## References

- "Japanese Candlestick Charting Techniques" by Steve Nison
- "Encyclopedia of Candlestick Charts" by Thomas Bulkowski
- "Technical Analysis of the Financial Markets" by John J. Murphy
- "Beyond Candlesticks" by Steve Nison

## See Also

- [Pattern Recognition Overview](index.md)
- [Candlestick Pattern Guide](../index.md)
- [Technical Analysis Basics](../../basics.md)
- [Back to Indicators](../index.md)
