# CDL_ONNECK (On-Neck Pattern)

## Overview

The On-Neck pattern is a two-candle bearish continuation pattern that appears during a downtrend. It consists of a long black candle followed by a white candle that closes at or slightly below the low of the previous candle. This pattern is similar to the In-Neck pattern but with the second candle closing even lower, indicating stronger selling pressure and a higher probability of downtrend continuation.

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
- Used to identify the upper range of price movement
- Helps determine pattern validity

**low**
- Array of low prices for each period
- Critical for identifying the "on-neck" line where second candle closes
- Used to measure support breakdown

**close**
- Array of closing prices for each period
- Used to determine candle color and body size
- Essential for pattern recognition

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

# Example price data showing downtrend with On-Neck pattern
open =  [50.00, 48.50, 47.00, 46.70]
high =  [50.20, 48.80, 47.20, 47.40]
low =   [48.30, 46.90, 46.70, 46.50]
close = [48.50, 47.00, 46.70, 46.65]

pattern = SQA::TAI.cdl_onneck(open, high, low, close)

puts "Pattern signal: #{pattern.last}"
# 0 = no pattern, -100 = bearish continuation
```

### Analyzing Pattern Signals

```ruby
# Monitor for bearish continuation signals
pattern.each_with_index do |signal, idx|
  if signal == -100
    puts "Bearish On-Neck pattern at index #{idx}"
    puts "Price: #{close[idx]}, strong downtrend continuation expected"
  end
end
```

### Combining with Support Levels

```ruby
# Use with support/resistance for confirmation
require 'sqa/tai'

pattern = SQA::TAI.cdl_onneck(open, high, low, close)
ma50 = SQA::TAI.sma(close, 50)

current_signal = pattern.last
current_price = close.last

if current_signal == -100 && current_price < ma50.last
  puts "On-Neck pattern breaking below support - very bearish"
  puts "Consider aggressive short positions"
end
```

## Understanding the Indicator

### What It Measures

The On-Neck pattern measures the failure of a rally attempt during a downtrend, with the second candle closing at or below the first candle's low. This indicates:
- Complete rejection of rally attempts
- Breakdown of support at previous low
- Strong selling pressure overwhelming buyers
- High probability of continued sharp decline

This pattern is more bearish than the In-Neck pattern because the second candle not only fails to rally but actually closes at or below the previous low, showing extreme weakness.

### Pattern Structure

**On-Neck Pattern (Bearish Continuation):**
1. **First candle**: Long black candle in an established downtrend
2. **Second candle**: White candle that:
   - Opens below the previous close (gaps down)
   - Attempts to rally during the session
   - Closes at or slightly below the previous candle's low
   - Shows complete failure to hold above the "neck line"

The key difference from In-Neck: On-Neck closes AT or BELOW the first candle's low, while In-Neck closes NEAR but above the low.

### Indicator Characteristics

- **Range**: Returns -100 (bearish continuation) or 0 (no pattern)
- **Type**: Bearish continuation pattern (two-candle formation)
- **Frequency**: Less common than In-Neck, more reliable
- **Best Used**: During strong downtrends with clear selling dominance
- **Reliability**: Moderate to high; stronger signal than In-Neck pattern

## Interpretation

### Signal Values

- **-100**: Bearish On-Neck pattern detected - strong downtrend continuation expected
- **0**: No pattern present at this position

### Pattern Recognition

**Bearish Continuation Signal (-100):**
- Appears during an established downtrend
- First candle shows strong selling with a long black body
- Second candle gaps down, attempts rally, but closes at/below first candle's low
- The "on-neck" close demonstrates complete support failure
- Indicates bears are firmly in control with no viable support

### Market Psychology

The On-Neck pattern reveals critical market dynamics:
- **Initial Decline**: Long black candle confirms strong selling
- **Gap Down Open**: Market opens lower, showing overnight weakness
- **Failed Recovery**: White candle attempts recovery but completely fails
- **Support Breakdown**: Close at/below previous low breaks support
- **Capitulation Signal**: Buyers give up, sellers dominate completely
- **Continuation Certainty**: Pattern strongly suggests more downside ahead

## Trading Signals

### Sell Signals

When the On-Neck pattern appears (-100):

1. **Entry Point**: Enter short at close of second candle or on breakdown below pattern
2. **Confirmation**: Verify pattern occurs in strong downtrend with volume
3. **Stop Loss**: Place stop above the high of the second candle
4. **Target**: Project distance from pattern to next support level

**Example Scenario:**
```ruby
# Detect On-Neck pattern and generate aggressive short signal
if pattern.last == -100
  entry_price = close.last
  pattern_high = [high[-2], high[-1]].max
  stop_loss = pattern_high * 1.015
  risk = stop_loss - entry_price
  target = entry_price - (2.5 * risk)  # More aggressive target

  puts "STRONG SELL Signal: On-Neck Pattern Detected"
  puts "Entry: $#{entry_price.round(2)}"
  puts "Stop Loss: $#{stop_loss.round(2)}"
  puts "Target: $#{target.round(2)}"
  puts "Risk/Reward: 1:2.5"
  puts "Support broken - expect accelerated decline"
end
```

### Exit Signals for Long Positions

For traders holding long positions:

1. **Immediate Exit**: Close all long positions when On-Neck pattern completes
2. **No Partial Exit**: Pattern too bearish for partial positions
3. **Consider Reversal**: May warrant opening short position

**Example Scenario:**
```ruby
# Urgent exit signal for long positions
if pattern.last == -100 && position == :long
  puts "URGENT: On-Neck pattern detected - STRONG BEARISH"
  puts "Recommendation: Exit ALL long positions immediately"
  puts "Current Price: $#{close.last}"
  puts "Support broken - sharp decline expected"
  puts "Consider reversing to short position"
end
```

### Short Entry Strategy

```ruby
# Complete short strategy with On-Neck pattern
if pattern.last == -100
  # Verify downtrend strength
  recent_lows = low[-10..-1]
  declining_lows = recent_lows.each_cons(2).all? { |a, b| b < a }

  if declining_lows
    puts "ON-NECK PATTERN IN STRONG DOWNTREND"
    puts "High probability short setup"
    puts ""
    puts "Entry triggers:"
    puts "1. Immediate entry at market"
    puts "2. Or wait for break below #{close.last - 0.10}"
    puts "3. Add to position on continuation"
  end
end
```

## Best Practices

### Optimal Use Cases

This pattern works best in:
- **Strong established downtrends**: Clear persistent selling pressure
- **After significant decline**: Pattern more reliable after sustained move down
- **Breaking support**: Pattern at key support levels increases significance
- **High volume context**: High volume on both candles confirms pattern
- **Time frames**: Most reliable on daily charts; very effective on weekly charts

### Combining with Other Indicators

**With Trend Indicators:**
- **Moving Averages**: Price well below all major MAs (20, 50, 200-day)
- **ADX**: ADX above 30 confirms very strong downtrend
- **MACD**: MACD well below signal line with increasing separation
- **Parabolic SAR**: SAR dots above price confirming downtrend

**With Volume Indicators:**
- **Volume Analysis**: High volume on both candles critical
- **On-Balance Volume (OBV)**: Sharply declining OBV confirms pattern
- **Accumulation/Distribution**: Declining line confirms distribution
- **Volume Surge**: Increasing volume validates support breakdown

**With Momentum Indicators:**
- **RSI**: RSI below 40, ideally below 30
- **Stochastic**: In oversold territory but not turning up
- **CCI**: Below -100 confirming bearish momentum

### Common Pitfalls

1. **Trading Near Major Support**: Avoid pattern at very strong historical support
2. **Low Volume Pattern**: Pattern much less reliable without volume confirmation
3. **Confused Identification**: Ensure close is AT or BELOW first candle's low
4. **Weak Downtrend**: Pattern requires strong pre-existing downtrend
5. **Oversold Bounce Risk**: Be cautious if RSI below 20 (potential bounce)

### Risk Management Guidelines

**Stop Loss Placement:**
- **Tight Stop**: Just above second candle's high (aggressive)
- **Standard Stop**: 1-2% above pattern high
- **Swing Stop**: Above recent swing high
- **Time Stop**: Exit if no follow-through in 2-3 bars

**Position Sizing:**
- Can use larger position size due to higher reliability
- Still risk no more than 2% of account
- Consider scaling in after initial confirmation
- Trail stops as profit develops

**Profit Targets:**
- **Target 1**: 1.5x risk (take partial profit)
- **Target 2**: 2.5x risk (main target)
- **Target 3**: Trail stop for extended move
- **Next Support**: Project to next major support level

## Practical Example

Complete trading scenario:

```ruby
require 'sqa/tai'

# Historical data showing strong downtrend
open =  [55.00, 53.00, 51.00, 49.50, 47.50, 46.70, 45.00]
high =  [55.50, 53.20, 51.30, 49.80, 47.80, 47.40, 45.50]
low =   [52.80, 50.80, 49.30, 47.30, 46.60, 46.50, 44.20]
close = [53.00, 51.00, 49.50, 47.50, 46.70, 46.55, 44.50]

# Calculate indicators
pattern = SQA::TAI.cdl_onneck(open, high, low, close)
sma_20 = SQA::TAI.sma(close, 5)  # Using 5 for short data
rsi = SQA::TAI.rsi(close, 5)

# Analysis
current_signal = pattern.last
current_price = close.last
in_strong_downtrend = current_price < sma_20.last
rsi_bearish = rsi.last < 50

if current_signal == -100 && in_strong_downtrend
  puts "=" * 60
  puts "ON-NECK BEARISH CONTINUATION PATTERN DETECTED"
  puts "=" * 60
  puts "Current Price: $#{current_price}"
  puts "Pattern Signal: #{current_signal}"
  puts "Below 20 SMA: #{in_strong_downtrend}"
  puts "RSI: #{rsi.last.round(2)} (bearish: #{rsi_bearish})"
  puts ""

  # Calculate trade parameters
  entry = current_price
  pattern_high = [high[-2], high[-1]].max
  stop = pattern_high * 1.015
  risk = stop - entry

  target1 = entry - (1.5 * risk)
  target2 = entry - (2.5 * risk)
  target3 = entry - (4.0 * risk)

  puts "AGGRESSIVE SHORT TRADE SETUP:"
  puts "-" * 60
  puts "Entry Price: $#{entry.round(2)}"
  puts "Stop Loss: $#{stop.round(2)}"
  puts "Risk per share: $#{risk.round(2)}"
  puts ""
  puts "PROFIT TARGETS:"
  puts "Target 1 (50% exit): $#{target1.round(2)} - 1.5R"
  puts "Target 2 (30% exit): $#{target2.round(2)} - 2.5R"
  puts "Target 3 (trail 20%): $#{target3.round(2)} - 4.0R"
  puts ""
  puts "RATIONALE:"
  puts "- Strong downtrend confirmed"
  puts "- Support level broken at #{low[-2]}"
  puts "- Failed rally shows weakness"
  puts "- RSI confirms bearish momentum"
  puts ""
  puts "EXECUTION PLAN:"
  puts "1. Enter short at market open"
  puts "2. Place stop at $#{stop.round(2)}"
  puts "3. Scale out at targets"
  puts "4. Trail stop on remaining position"
end
```

## Related Indicators

### Similar Patterns

- **[In-Neck Pattern](cdl_inneck.md)**: Similar but less bearish (closes near vs at/below low)
- **[Thrusting Pattern](cdl_thrusting.md)**: Second candle closes slightly higher into body
- **[Piercing Line](cdl_piercing.md)**: Bullish counterpart pattern
- **[Dark Cloud Cover](cdl_darkcloudcover.md)**: Bearish reversal pattern

### Complementary Patterns

- **[Bearish Engulfing](cdl_engulfing.md)**: Another strong bearish signal
- **[Three Black Crows](cdl_3blackcrows.md)**: Strong bearish continuation
- **[Evening Star](cdl_eveningstar.md)**: Bearish reversal at tops
- **[Shooting Star](cdl_shootingstar.md)**: Bearish reversal signal

### Indicator Combinations

- **[RSI](../momentum/rsi.md)**: Confirms bearish momentum
- **[ADX](../momentum/adx.md)**: Validates trend strength
- **[Moving Averages](../overlap/sma.md)**: Confirms downtrend structure
- **[MACD](../momentum/macd.md)**: Shows bearish divergence

## Advanced Topics

### Multi-Timeframe Analysis

For optimal confirmation:
1. **Weekly Chart**: Confirm major downtrend
2. **Daily Chart**: Identify On-Neck pattern
3. **4-Hour Chart**: Time precise entry
4. **1-Hour Chart**: Monitor for follow-through

All timeframes should align bearishly for highest probability trades.

### Pattern Variations and Reliability

**High Reliability Indicators:**
- Close more than 0.5% below first candle's low
- High volume on both candles
- Occurs at broken support level
- Part of larger bearish pattern complex

**Lower Reliability Indicators:**
- Close exactly at (not below) first candle's low
- Low volume on second candle
- No support level nearby
- Oversold conditions present

### Statistical Performance

Research by Thomas Bulkowski:
- Success rate: Approximately 63-67% for continuation
- Average decline: 5-10% after pattern completion
- Time to target: Usually 8-20 trading days
- Break-even failure rate: About 33%
- Works better in bear markets than bull markets

### Market Context Considerations

**Best Market Conditions:**
- Bear market environment
- Sector rotation away from stock
- Negative news flow
- Increased market volatility

**Caution Conditions:**
- Extreme oversold readings (RSI < 20)
- Major support nearby
- Positive divergences forming
- Market turning bullish

## References

- "Japanese Candlestick Charting Techniques" by Steve Nison
- "Encyclopedia of Candlestick Charts" by Thomas Bulkowski
- "The Candlestick Course" by Steve Nison
- "Technical Analysis of the Financial Markets" by John J. Murphy
- "Trading Classic Chart Patterns" by Thomas Bulkowski

## See Also

- [Pattern Recognition Overview](index.md)
- [Bearish Continuation Patterns](../index.md)
- [In-Neck Pattern](cdl_inneck.md)
- [Thrusting Pattern](cdl_thrusting.md)
- [Back to Indicators](../index.md)
