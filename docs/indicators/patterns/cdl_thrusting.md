# CDL_THRUSTING (Thrusting Pattern)

## Overview

The Thrusting pattern is a two-candle bearish continuation pattern that appears during a downtrend. It consists of a long black candle followed by a white candle that closes above the first candle's low but well below its midpoint. This pattern indicates a failed rally attempt where buying pressure is insufficient to reverse the downtrend, suggesting continuation of the bearish move. The Thrusting pattern is less bearish than the In-Neck and On-Neck patterns but still signals downtrend continuation.

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
- Helps validate pattern structure

**low**
- Array of low prices for each period
- Critical for pattern identification
- Establishes the support level reference

**close**
- Array of closing prices for each period
- Key for determining the "thrusting" level (above low, below midpoint)
- Essential for pattern recognition

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

# Example price data showing downtrend with Thrusting pattern
open =  [50.00, 48.50, 47.00, 46.50]
high =  [50.20, 48.80, 47.30, 47.50]
low =   [48.30, 46.90, 46.50, 46.40]
close = [48.50, 47.00, 46.50, 47.00]

pattern = SQA::TAI.cdl_thrusting(open, high, low, close)

puts "Pattern signal: #{pattern.last}"
# 0 = no pattern, -100 = bearish continuation
```

### Analyzing Pattern Signals

```ruby
# Monitor for bearish continuation signals
pattern.each_with_index do |signal, idx|
  if signal == -100
    puts "Bearish Thrusting pattern at index #{idx}"
    puts "Price: #{close[idx]}, downtrend continuation expected"
  end
end
```

### Combining with Trend Analysis

```ruby
# Use with multiple indicators for confirmation
require 'sqa/tai'

pattern = SQA::TAI.cdl_thrusting(open, high, low, close)
ma50 = SQA::TAI.sma(close, 50)
rsi = SQA::TAI.rsi(close, 14)

current_signal = pattern.last
current_price = close.last

if current_signal == -100 && current_price < ma50.last && rsi.last < 50
  puts "Thrusting pattern with bearish trend confirmation"
  puts "Consider short positions or exit longs"
end
```

## Understanding the Indicator

### What It Measures

The Thrusting pattern measures the strength of a failed rally attempt during a downtrend. When a white candle appears but closes above the previous low yet below the midpoint of the black candle's body, it indicates:
- Insufficient buying pressure to reverse the trend
- Resistance at mid-body level of previous candle
- Bears maintaining control despite brief rally
- Likely continuation of the downtrend

The key characteristic is that the second candle "thrusts" into the first candle's body but doesn't penetrate deeply enough to suggest reversal.

### Pattern Structure

**Thrusting Pattern (Bearish Continuation):**
1. **First candle**: Long black candle in an established downtrend
2. **Second candle**: White candle that:
   - Opens below the previous close
   - Rallies during the session
   - Closes above the first candle's low
   - Closes below the midpoint of the first candle's body
   - Fails to show sufficient strength for reversal

The critical element is the second candle closing in the lower half of the first candle's body, showing weakness in the rally attempt.

### Indicator Characteristics

- **Range**: Returns -100 (bearish continuation) or 0 (no pattern)
- **Type**: Bearish continuation pattern (two-candle formation)
- **Frequency**: Moderately common in downtrends
- **Best Used**: During established downtrends with moderate selling pressure
- **Reliability**: Moderate; less reliable than In-Neck and On-Neck patterns

## Interpretation

### Signal Values

- **-100**: Bearish Thrusting pattern detected - downtrend expected to continue
- **0**: No pattern present at this position

### Pattern Recognition

**Bearish Continuation Signal (-100):**
- Appears during an established downtrend
- First candle shows strong selling with a long black body
- Second candle attempts rally but closes well below the midpoint
- The penetration level indicates insufficient bullish strength
- Suggests sellers will reassert control and push prices lower

### Market Psychology

The Thrusting pattern reveals important market dynamics:
- **Initial Decline**: Long black candle confirms selling pressure
- **Gap Down**: Second candle opens lower, showing bearish sentiment
- **Rally Attempt**: White candle shows some buying interest
- **Weak Penetration**: Close below midpoint shows buyers lack conviction
- **Resistance at Midpoint**: Previous candle's mid-body acts as resistance
- **Continuation Expected**: Insufficient strength suggests more downside

## Trading Signals

### Sell Signals

When the Thrusting pattern appears (-100):

1. **Entry Point**: Enter short after pattern confirmation or on breakdown
2. **Confirmation**: Verify pattern occurs in downtrend with volume confirmation
3. **Stop Loss**: Place stop above the high of the second candle
4. **Target**: Project to next support level or use 2:1 risk-reward

**Example Scenario:**
```ruby
# Detect Thrusting pattern and generate trading signal
if pattern.last == -100
  entry_price = close.last
  pattern_high = [high[-2], high[-1]].max
  stop_loss = pattern_high * 1.02
  risk = stop_loss - entry_price
  target = entry_price - (2 * risk)

  puts "SELL Signal: Thrusting Pattern Detected"
  puts "Entry: $#{entry_price.round(2)}"
  puts "Stop Loss: $#{stop_loss.round(2)}"
  puts "Target: $#{target.round(2)}"
  puts "Risk/Reward: 1:2"
end
```

### Exit Signals for Long Positions

For traders holding long positions:

1. **Exit Point**: Consider closing long positions when Thrusting pattern completes
2. **Partial Exit**: May reduce position size rather than full exit
3. **Tighten Stops**: Move stops closer to current price

**Example Scenario:**
```ruby
# Exit or reduce long position on Thrusting pattern
if pattern.last == -100 && position == :long
  puts "WARNING: Thrusting pattern detected"
  puts "Recommendation: Reduce or exit long position"
  puts "Current Price: $#{close.last}"
  puts "Consider tightening stop loss"
end
```

## Best Practices

### Optimal Use Cases

This pattern works best in:
- **Established downtrends**: Clear downward price movement required
- **Moderate volatility**: Not in extreme market conditions
- **Liquid markets**: Better price discovery and execution
- **Time frames**: Most reliable on daily charts; also works on 4-hour charts
- **Volume context**: Pattern stronger with declining volume on second candle

### Combining with Other Indicators

**With Trend Indicators:**
- **Moving Averages**: Price below key MAs (20, 50-day) confirms downtrend
- **ADX**: ADX above 20 confirms trend strength
- **MACD**: MACD below signal line confirms bearish momentum

**With Volume Indicators:**
- **Volume Analysis**: Lower volume on second candle strengthens signal
- **On-Balance Volume (OBV)**: Declining OBV confirms selling pressure
- **Volume pattern**: High volume on first candle, lower on second ideal

**With Support/Resistance:**
- **Resistance Levels**: Pattern at resistance adds confirmation
- **Fibonacci Levels**: Pattern at retracement level increases significance
- **Previous Lows**: Distance to next support guides profit targets

### Common Pitfalls

1. **Confusing with Piercing Line**: Thrusting closes below midpoint, Piercing above
2. **Ignoring Trend Context**: Pattern requires established downtrend
3. **Trading Near Major Support**: Avoid pattern at strong support levels
4. **Overestimating Reliability**: Pattern less reliable than In-Neck/On-Neck
5. **Missing Volume Confirmation**: Volume pattern critical for validation

### Risk Management Guidelines

**Stop Loss Placement:**
- **Initial Stop**: Above the high of the second candle
- **Alternative Stop**: Above recent swing high
- **Buffer**: Add 1-2% for volatility
- **Time Stop**: Exit if no follow-through within 3-5 bars

**Position Sizing:**
- Use conservative position sizes due to moderate reliability
- Risk no more than 1-2% of account per trade
- Consider waiting for additional confirmation before entering
- Scale into position gradually

## Practical Example

Complete trading scenario:

```ruby
require 'sqa/tai'

# Historical data showing downtrend
open =  [52.00, 51.00, 50.00, 48.50, 47.00, 46.50, 45.50]
high =  [52.50, 51.20, 50.20, 48.80, 47.40, 47.50, 46.00]
low =   [50.90, 49.80, 48.30, 46.90, 46.40, 46.30, 45.20]
close = [51.00, 50.00, 48.50, 47.00, 46.50, 47.00, 45.40]

# Calculate indicators
pattern = SQA::TAI.cdl_thrusting(open, high, low, close)
sma_20 = SQA::TAI.sma(close, 5)  # Using 5 for short data
rsi = SQA::TAI.rsi(close, 5)

# Analysis
current_signal = pattern.last
current_price = close.last
in_downtrend = current_price < sma_20.last

if current_signal == -100 && in_downtrend
  puts "=" * 50
  puts "THRUSTING BEARISH CONTINUATION PATTERN"
  puts "=" * 50
  puts "Current Price: $#{current_price}"
  puts "Pattern Signal: #{current_signal}"
  puts "Below 20 SMA: #{in_downtrend}"
  puts "RSI: #{rsi.last.round(2)}"
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
  puts "PATTERN DETAILS:"
  puts "- First candle: Long black (selling pressure)"
  puts "- Second candle: White thrust (weak rally)"
  puts "- Close below midpoint: Insufficient buying"
  puts "- Downtrend expected to continue"
end
```

## Related Indicators

### Similar Patterns

- **[In-Neck Pattern](cdl_inneck.md)**: More bearish, closes at previous low
- **[On-Neck Pattern](cdl_onneck.md)**: Most bearish, closes below previous low
- **[Piercing Line](cdl_piercing.md)**: Bullish counterpart, closes above midpoint
- **[Dark Cloud Cover](cdl_darkcloudcover.md)**: Bearish reversal pattern

### Complementary Patterns

- **[Bearish Engulfing](cdl_engulfing.md)**: Stronger bearish signal
- **[Evening Star](cdl_eveningstar.md)**: Bearish reversal pattern
- **[Three Black Crows](cdl_3blackcrows.md)**: Strong bearish continuation

### Indicator Combinations

- **[RSI](../momentum/rsi.md)**: Confirms bearish momentum below 50
- **[Moving Averages](../overlap/sma.md)**: Confirms downtrend structure
- **[MACD](../momentum/macd.md)**: Validates bearish momentum

## Advanced Topics

### Multi-Timeframe Analysis

For stronger confirmation:
1. Identify Thrusting pattern on trading timeframe (daily)
2. Confirm downtrend on higher timeframe (weekly)
3. Use lower timeframe (4-hour) for precise entry timing
4. Monitor for follow-through on all timeframes

### Pattern Variations

- **Strong Thrusting**: Second candle closes near (but below) midpoint
- **Weak Thrusting**: Second candle barely penetrates first candle's body
- **Volume Pattern**: High volume first candle, declining volume second

### Statistical Considerations

Research suggests:
- Success rate: Approximately 54-60% for continuation
- Average decline: 3-6% after pattern completion
- Time to target: Usually 10-20 trading days
- Less reliable than In-Neck or On-Neck patterns
- Works better when combined with other bearish indicators

## References

- "Japanese Candlestick Charting Techniques" by Steve Nison
- "Encyclopedia of Candlestick Charts" by Thomas Bulkowski
- "The Candlestick Course" by Steve Nison
- "Technical Analysis of the Financial Markets" by John J. Murphy

## See Also

- [Pattern Recognition Overview](index.md)
- [Bearish Continuation Patterns](../index.md)
- [In-Neck Pattern](cdl_inneck.md)
- [On-Neck Pattern](cdl_onneck.md)
- [Back to Indicators](../index.md)
