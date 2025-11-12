# CDL_INNECK (In-Neck Pattern)

## Overview

The In-Neck pattern is a two-candle bearish continuation pattern that appears during a downtrend. It consists of a long black candle followed by a white candle that closes near or at the low of the previous candle. This pattern suggests that despite a brief attempt to rally, selling pressure remains dominant and the downtrend is likely to continue. The In-Neck pattern is considered a weak reversal signal and primarily indicates continuation.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `open` | Array | Required | Array of opening prices for each period |
| `high` | Array | Required | Array of high prices for each period |
| `low` | Array | Required | Array of low prices for each period |
| `close` | Array | Required | Array of closing prices for each period |

### Parameter Details


**Note**: Array elements should be ordered from oldest to newest (chronological order)

**open**
- Array of opening prices for the analyzed time series
- Must have the same length as high, low, and close arrays
- Used to determine candle body size and direction

**high**
- Array of high prices for each period
- Used to identify the upper range of price movement
- Helps determine pattern validity

**low**
- Array of low prices for each period
- Critical for identifying the "neck line" where second candle closes
- Used to measure support levels

**close**
- Array of closing prices for each period
- Used to determine candle color and body size
- Essential for pattern recognition

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

# Example price data showing downtrend with In-Neck pattern
open =  [50.00, 48.50, 47.00, 46.80]
high =  [50.20, 48.80, 47.20, 47.50]
low =   [48.30, 46.90, 46.70, 46.60]
close = [48.50, 47.00, 46.80, 46.90]

pattern = SQA::TAI.cdl_inneck(open, high, low, close)

puts "Pattern signal: #{pattern.last}"
# 0 = no pattern, -100 = bearish continuation
```

### Analyzing Pattern Signals

```ruby
# Monitor for bearish continuation signals
pattern.each_with_index do |signal, idx|
  if signal == -100
    puts "Bearish In-Neck pattern at index #{idx}"
    puts "Price: #{close[idx]}, downtrend likely to continue"
  end
end
```

### Combining with Trend Indicators

```ruby
# Use with moving average for confirmation
require 'sqa/tai'

pattern = SQA::TAI.cdl_inneck(open, high, low, close)
ma50 = SQA::TAI.sma(close, 50)

current_signal = pattern.last
current_price = close.last

if current_signal == -100 && current_price < ma50.last
  puts "In-Neck pattern confirmed by downtrend - strong bearish signal"
  puts "Consider exiting long positions or entering short"
end
```

## Understanding the Indicator

### What It Measures

The In-Neck pattern measures the strength of selling pressure during a downtrend. When a white candle appears but can only close at or near the previous candle's low, it indicates:
- Failed rally attempt
- Strong resistance at previous low levels
- Sellers maintaining control despite buying pressure
- High probability of continued decline

This pattern is significant because the market attempts to bounce but fails to recover, demonstrating that bears remain firmly in control.

### Pattern Structure

**In-Neck Pattern (Bearish Continuation):**
1. **First candle**: Long black candle in an established downtrend
2. **Second candle**: White candle that:
   - Opens below the previous close
   - Rallies during the session
   - Closes near or at the previous candle's low (the "neck line")
   - Fails to close significantly above the previous low

The critical element is that the second candle closes near the first candle's low, creating a "neck line" that acts as resistance.

### Indicator Characteristics

- **Range**: Returns -100 (bearish continuation) or 0 (no pattern)
- **Type**: Bearish continuation pattern (two-candle formation)
- **Frequency**: Relatively common in downtrends
- **Best Used**: During established downtrends with clear selling pressure
- **Reliability**: Moderate; works best when confirmed with other indicators

## Interpretation

### Signal Values

- **-100**: Bearish In-Neck pattern detected - downtrend expected to continue
- **0**: No pattern present at this position

### Pattern Recognition

**Bearish Continuation Signal (-100):**
- Appears during an established downtrend
- First candle shows strong selling with a long black body
- Second candle attempts to rally but closes at or near first candle's low
- The "neck line" (first candle's low) acts as resistance
- Indicates sellers remain in control despite brief buying pressure

### Market Psychology

The In-Neck pattern reveals important market dynamics:
- **Initial Decline**: Long black candle shows strong selling pressure
- **Failed Rally**: White candle attempts recovery but fails
- **Resistance at Neck Line**: Previous low becomes resistance level
- **Renewed Selling**: Failure to break above neck line invites more selling
- **Continuation Bias**: Pattern confirms downtrend will likely continue

## Trading Signals

### Sell Signals

When the In-Neck pattern appears (-100):

1. **Entry Point**: Enter short position at the close of the second candle or on a breakdown below the neck line
2. **Confirmation**: Verify pattern occurs in an established downtrend
3. **Stop Loss**: Place stop above the high of the second candle

**Example Scenario:**
```ruby
# Detect In-Neck pattern and generate trading signal
if pattern.last == -100
  entry_price = close.last
  pattern_high = [high[-2], high[-1]].max
  stop_loss = pattern_high * 1.02
  risk = stop_loss - entry_price
  target = entry_price - (2 * risk)

  puts "SELL Signal: In-Neck Pattern Detected"
  puts "Entry: $#{entry_price.round(2)}"
  puts "Stop Loss: $#{stop_loss.round(2)}"
  puts "Target: $#{target.round(2)}"
  puts "Risk/Reward: 1:2"
end
```

### Exit Signals for Long Positions

For traders holding long positions:

1. **Exit Point**: Close long positions when In-Neck pattern completes
2. **Partial Exit**: Consider reducing position size immediately
3. **Trailing Stop**: Tighten stop losses to protect profits

**Example Scenario:**
```ruby
# Exit long position on In-Neck pattern
if pattern.last == -100 && position == :long
  puts "WARNING: In-Neck pattern detected"
  puts "Recommendation: Exit long position"
  puts "Current Price: $#{close.last}"
  puts "Downtrend continuation expected"
end
```

## Best Practices

### Optimal Use Cases

This pattern works best in:
- **Established downtrends**: Clear downward price movement required
- **After significant decline**: Pattern more reliable after sustained selling
- **Near resistance levels**: Added confirmation when pattern forms at resistance
- **Time frames**: Most reliable on daily charts; also effective on 4-hour charts
- **Volume confirmation**: Decreasing volume on second candle strengthens signal

### Combining with Other Indicators

**With Trend Indicators:**
- **Moving Averages**: Price should be below key MAs (20, 50, 200-day)
- **ADX**: ADX above 25 confirms strong downtrend
- **MACD**: MACD below signal line confirms bearish momentum

**With Volume Indicators:**
- **Volume Analysis**: High volume on first candle, lower on second
- **On-Balance Volume (OBV)**: Declining OBV confirms selling pressure
- **Volume decrease**: Lower volume on second candle shows weak buying

**With Support/Resistance:**
- **Resistance Levels**: Pattern more significant at known resistance
- **Previous Lows**: Neck line at previous support turned resistance
- **Fibonacci Levels**: Pattern at Fibonacci retracement adds confirmation

### Common Pitfalls

1. **Trading Against Major Support**: Avoid pattern near strong support levels
2. **Ignoring Overall Trend**: Pattern requires established downtrend
3. **Confusing with On-Neck**: In-Neck closes at low; On-Neck closes below low
4. **Missing Volume Confirmation**: Pattern stronger with appropriate volume
5. **Weak Downtrend Context**: Pattern less reliable in ranging or weak downtrends

### Risk Management Guidelines

**Stop Loss Placement:**
- **Initial Stop**: Above the high of the second candle
- **Alternative Stop**: Above recent swing high
- **Buffer**: Add 1-2% for volatility
- **Time Stop**: Exit if pattern doesn't follow through within 3-5 bars

**Position Sizing:**
- Risk no more than 1-2% of account per trade
- Consider smaller positions due to moderate reliability
- Scale into position after confirmation

## Practical Example

Complete trading scenario:

```ruby
require 'sqa/tai'

# Historical data showing downtrend
open =  [52.00, 51.00, 50.00, 48.50, 47.00, 46.80, 46.00]
high =  [52.50, 51.20, 50.20, 48.80, 47.20, 47.50, 46.50]
low =   [50.90, 49.80, 48.30, 46.90, 46.70, 46.60, 45.50]
close = [51.00, 50.00, 48.50, 47.00, 46.80, 46.90, 45.80]

# Calculate indicators
pattern = SQA::TAI.cdl_inneck(open, high, low, close)
sma_20 = SQA::TAI.sma(close, 5)  # Using 5 for short data
adx = SQA::TAI.adx(high, low, close, 5)

# Analysis
current_signal = pattern.last
current_price = close.last
in_downtrend = current_price < sma_20.last

if current_signal == -100 && in_downtrend
  puts "=" * 50
  puts "IN-NECK BEARISH CONTINUATION PATTERN"
  puts "=" * 50
  puts "Current Price: $#{current_price}"
  puts "Pattern Signal: #{current_signal}"
  puts "Below 20 SMA: #{in_downtrend}"
  puts ""

  # Calculate trade parameters
  entry = current_price
  pattern_high = [high[-2], high[-1]].max
  stop = pattern_high * 1.02
  risk = stop - entry
  target = entry - (2 * risk)

  puts "SHORT TRADE SETUP:"
  puts "Entry: $#{entry.round(2)}"
  puts "Stop Loss: $#{stop.round(2)}"
  puts "Target: $#{target.round(2)}"
  puts "Risk per share: $#{risk.round(2)}"
  puts ""
  puts "STRATEGY:"
  puts "- Enter short at market"
  puts "- Place stop above pattern high"
  puts "- Take profit at 2x risk target"
  puts "- Monitor for breakdown below neck line"
end
```

## Related Indicators

### Similar Patterns

- **[On-Neck Pattern](cdl_onneck.md)**: Similar but second candle closes below first candle's low
- **[Thrusting Pattern](cdl_thrusting.md)**: Second candle closes slightly higher into first candle's body
- **[Dark Cloud Cover](cdl_darkcloudcover.md)**: Stronger bearish reversal pattern

### Complementary Patterns

- **[Bearish Engulfing](cdl_engulfing.md)**: Stronger bearish signal
- **[Evening Star](cdl_eveningstar.md)**: Bearish reversal pattern
- **[Three Black Crows](cdl_3blackcrows.md)**: Strong bearish continuation

### Indicator Combinations

- **[RSI](../momentum/rsi.md)**: RSI below 50 confirms bearish momentum
- **[Moving Averages](../overlap/sma.md)**: Price below MAs confirms downtrend
- **[Volume](../volume/ad.md)**: Volume pattern confirms selling pressure

## Advanced Topics

### Multi-Timeframe Analysis

For stronger confirmation:
1. Identify In-Neck pattern on trading timeframe (daily)
2. Confirm downtrend on higher timeframe (weekly)
3. Use lower timeframe (4-hour) for precise entry
4. Wait for breakdown below neck line on lower timeframe

### Pattern Variations

- **Perfect In-Neck**: Second candle closes exactly at first candle's low
- **Near In-Neck**: Second candle closes within 1% of first candle's low
- **Volume Pattern**: High volume on first candle, declining volume on second

### Statistical Considerations

Research by Thomas Bulkowski suggests:
- Success rate: Approximately 56-62% for continuation
- Average decline: 3-7% after pattern completion
- Time to target: Usually achieved within 10-15 trading days
- Performance better in strong downtrends

## References

- "Japanese Candlestick Charting Techniques" by Steve Nison
- "Encyclopedia of Candlestick Charts" by Thomas Bulkowski
- "The Candlestick Course" by Steve Nison
- "Technical Analysis of the Financial Markets" by John J. Murphy

## See Also

- [Pattern Recognition Overview](index.md)
- [Bearish Continuation Patterns](../index.md)
- [On-Neck Pattern](cdl_onneck.md)
- [Back to Indicators](../index.md)
