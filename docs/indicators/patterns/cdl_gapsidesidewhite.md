# CDL_GAPSIDESIDEWHITE (Up/Down-Gap Side-by-Side White Lines)

## Overview

The Up/Down-Gap Side-by-Side White Lines pattern is a rare three-candle continuation pattern that appears during strong trends. It consists of a gap followed by two consecutive white (bullish) candles with similar bodies, suggesting the current trend will continue despite a brief pause. This pattern signals that buyers or sellers remain in control after a gap, providing confirmation to hold existing positions.

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
- Used to identify gap formation and candle body direction

**high**
- Array of high prices for each period
- Critical for determining candle real body size
- Used to verify pattern structure

**low**
- Array of low prices for each period
- Helps identify gap presence and size
- Used to validate pattern formation

**close**
- Array of closing prices for each period
- Used to determine candle color and body size
- Essential for identifying white (bullish) candle formation

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

# Example price data showing the pattern
open =  [50.00, 52.00, 52.50, 52.40]
high =  [50.50, 52.80, 53.00, 52.90]
low =   [49.80, 51.90, 52.30, 52.20]
close = [50.20, 52.60, 52.80, 52.70]

pattern = SQA::TAI.cdl_gapsidesidewhite(open, high, low, close)

puts "Pattern signal: #{pattern.last}"
# 0 = no pattern, +100 = bullish continuation, -100 = bearish continuation
```

### Analyzing Pattern Signals

```ruby
# Check for pattern occurrence over time
pattern.each_with_index do |signal, idx|
  next if signal == 0

  if signal == 100
    puts "Bullish continuation at index #{idx} - uptrend likely to continue"
  elsif signal == -100
    puts "Bearish continuation at index #{idx} - downtrend likely to continue"
  end
end
```

### Combining with Trend Confirmation

```ruby
# Use with moving average for trend confirmation
require 'sqa/tai'

# Calculate pattern and trend
pattern = SQA::TAI.cdl_gapsidesidewhite(open, high, low, close)
ma20 = SQA::TAI.sma(close, 20)

current_signal = pattern.last
current_price = close.last
current_ma = ma20.last

if current_signal == 100 && current_price > current_ma
  puts "Strong bullish continuation signal confirmed by uptrend"
elsif current_signal == -100 && current_price < current_ma
  puts "Strong bearish continuation signal confirmed by downtrend"
end
```

## Understanding the Indicator

### What It Measures

The Up/Down-Gap Side-by-Side White Lines pattern measures the strength of trend continuation after a gap. When a gap occurs followed by two consecutive white candles with similar bodies, it suggests:
- Strong buying pressure maintaining the trend
- Confidence among market participants
- Reduced likelihood of reversal despite the gap
- Potential for continued movement in the gap direction

This pattern is particularly valuable because gaps typically indicate strong momentum, and the formation of two side-by-side white candles after a gap confirms that the momentum is sustained.

### Pattern Structure

**Upside Gap Side-by-Side White Lines (Bullish Continuation):**
1. First candle: A white candle in an uptrend
2. Second candle: A white candle that gaps up from the first candle
3. Third candle: Another white candle with a body similar to the second candle, opening near the second candle's open

**Downside Gap Side-by-Side White Lines (Bearish Continuation):**
1. First candle: A black candle in a downtrend
2. Second candle: A white candle that gaps down from the first candle
3. Third candle: Another white candle with a body similar to the second candle, opening near the second candle's open

The key characteristic is that despite the two white candles appearing after a gap, the pattern still suggests continuation of the original trend.

### Indicator Characteristics

- **Range**: Returns -100 (bearish continuation), 0 (no pattern), or +100 (bullish continuation)
- **Type**: Continuation pattern (three-candle formation)
- **Frequency**: Rare pattern
- **Best Used**: During strong trending markets with clear directional momentum
- **Reliability**: Moderate to high when confirmed with volume and trend indicators

## Interpretation

### Signal Values

- **+100**: Bullish continuation pattern detected - uptrend expected to continue
- **0**: No pattern present at this position
- **-100**: Bearish continuation pattern detected - downtrend expected to continue

### Pattern Recognition

**Bullish Continuation Signal (+100):**
- Appears during an established uptrend
- Gap up occurs, followed by two consecutive white candles
- Second and third candles have similar body sizes
- Suggests buyers remain in control and will push prices higher

**Bearish Continuation Signal (-100):**
- Appears during an established downtrend
- Gap down occurs, followed by two consecutive white candles
- Despite white candles, the gap direction suggests continued downward pressure
- Indicates a brief consolidation before resuming the downtrend

### Market Psychology

The pattern reveals important market psychology:
- The gap demonstrates strong initial momentum
- The two white candles show buying interest but at a stable level
- The similarity of the two white candles suggests equilibrium at the new level
- The trend is likely to continue after this brief consolidation

## Trading Signals

### Buy Signals

For the bullish continuation pattern (+100):

1. **Entry Point**: Enter long when the pattern completes (after the third candle closes)
2. **Confirmation**: Verify the pattern occurs in an established uptrend
3. **Volume**: Look for sustained or increasing volume during pattern formation

**Example Scenario:**
```ruby
# Detect bullish continuation
if pattern.last == 100 && volume.last > volume[-2..-1].sum / 2
  entry_price = close.last
  stop_loss = low[-3..-1].min - (0.02 * low[-3..-1].min)
  target = entry_price + 2 * (entry_price - stop_loss)

  puts "Buy Signal: Enter at #{entry_price}"
  puts "Stop Loss: #{stop_loss}"
  puts "Target: #{target}"
end
```

### Sell Signals

For the bearish continuation pattern (-100):

1. **Entry Point**: Consider closing long positions or entering short when pattern completes
2. **Confirmation**: Verify the pattern occurs in an established downtrend
3. **Stop Loss**: Place stop above the highest point of the three-candle pattern

**Example Scenario:**
```ruby
# Detect bearish continuation
if pattern.last == -100 && close.last < sma_50.last
  entry_price = close.last
  stop_loss = high[-3..-1].max + (0.02 * high[-3..-1].max)
  target = entry_price - 2 * (stop_loss - entry_price)

  puts "Sell Signal: Enter short at #{entry_price}"
  puts "Stop Loss: #{stop_loss}"
  puts "Target: #{target}"
end
```

### Position Management

**Holding Existing Positions:**
- If already long and +100 appears: Hold position, trend continuation expected
- If already short and -100 appears: Hold position, downtrend continuation expected
- Pattern serves as confirmation to maintain current positions

## Best Practices

### Optimal Use Cases

This pattern works best in:
- **Strong trending markets**: Clear directional movement required
- **Medium to high volatility**: Gaps are more meaningful
- **Liquid markets**: Better price discovery and gap reliability
- **Continuation phase**: After initial trend establishment, not at trend start
- **Time frames**: Works across timeframes but most reliable on daily and 4-hour charts

### Combining with Other Indicators

**With Trend Indicators:**
- **Moving Averages**: Confirm trend direction; pattern should align with MA slope
- **ADX**: Verify trend strength; ADX above 25 confirms strong trend
- **MACD**: Look for continued separation of MACD lines in trend direction

**With Volume Indicators:**
- **Volume Analysis**: Increasing volume strengthens continuation signal
- **On-Balance Volume (OBV)**: Should confirm trend direction
- **Volume Profile**: Look for acceptance at new price levels after gap

**With Support/Resistance:**
- Verify pattern doesn't occur near major resistance (bullish) or support (bearish)
- Pattern is more reliable when room exists for continued trend movement

### Common Pitfalls

1. **Ignoring Trend Context**: Pattern requires an established trend; avoid using in ranging markets
2. **Misidentifying White Candles**: Ensure both second and third candles are genuinely white (close > open)
3. **Overlooking Gap Size**: Small gaps may not provide sufficient continuation momentum
4. **False Gaps**: In 24-hour markets, weekend gaps may be less reliable
5. **Over-trading**: Pattern is rare; don't force pattern recognition in unclear formations

### Risk Management Guidelines

**Stop Loss Placement:**
- **Bullish Pattern**: Below the low of the three-candle formation
- **Bearish Pattern**: Above the high of the three-candle formation
- **Buffer**: Add 1-2% buffer for volatility

**Position Sizing:**
- Use smaller position sizes due to moderate pattern reliability
- Consider scaling in after initial confirmation
- Never risk more than 2% of capital on a single trade

## Practical Example

Complete trading scenario:

```ruby
require 'sqa/tai'

# Historical data showing strong uptrend
open =  [45.00, 46.00, 47.50, 49.00, 51.00, 51.50, 51.40]
high =  [46.20, 47.80, 49.30, 50.80, 52.00, 52.10, 51.90]
low =   [44.80, 45.90, 47.30, 48.80, 50.80, 51.20, 51.10]
close = [46.00, 47.50, 49.00, 50.50, 51.80, 51.70, 51.60]

# Calculate pattern
pattern = SQA::TAI.cdl_gapsidesidewhite(open, high, low, close)

# Calculate supporting indicators
sma_20 = SQA::TAI.sma(close, 5)  # Using 5 for short data
adx = SQA::TAI.adx(high, low, close, 5)

# Analysis
current_signal = pattern.last
current_price = close.last
trend_confirmed = current_price > sma_20.last

if current_signal == 100 && trend_confirmed
  puts "=" * 50
  puts "BULLISH CONTINUATION PATTERN DETECTED"
  puts "=" * 50
  puts "Current Price: $#{current_price}"
  puts "Pattern Signal: #{current_signal}"
  puts "Above 20 SMA: #{trend_confirmed}"
  puts ""

  # Calculate trade parameters
  pattern_low = low[-3..-1].min
  stop_loss = pattern_low * 0.98
  risk = current_price - stop_loss
  target = current_price + (2 * risk)

  puts "TRADE SETUP:"
  puts "Entry: $#{current_price.round(2)}"
  puts "Stop Loss: $#{stop_loss.round(2)}"
  puts "Target: $#{target.round(2)}"
  puts "Risk/Reward: 1:2"
  puts "Risk Amount: $#{risk.round(2)} per share"

elsif current_signal == -100
  puts "Bearish continuation detected - consider exiting longs"
else
  puts "No pattern detected at current position"
end
```

## Related Indicators

### Similar Patterns

- **[Three White Soldiers](cdl_3whitesoldiers.md)**: Strong bullish continuation with three consecutive white candles
- **[Rising Three Methods](cdl_risefall3methods.md)**: Continuation pattern with consolidation candles
- **[Separating Lines](cdl_separatinglines.md)**: Another gap-based continuation pattern

### Complementary Patterns

- **[Doji](cdl_doji.md)**: Helps identify when continuation may pause
- **[Engulfing](cdl_engulfing.md)**: Can signal reversal if continuation fails
- **[Dark Cloud Cover](cdl_darkcloudcover.md)**: Potential reversal signal to watch for

### Indicator Combinations

- **[ADX](../momentum/adx.md)**: Confirms trend strength
- **[Volume Indicators](../volume/obv.md)**: Validates continuation momentum
- **[Moving Averages](../overlap/sma.md)**: Confirms overall trend direction

## Advanced Topics

### Multi-Timeframe Analysis

For stronger confirmation:
1. Identify pattern on primary timeframe (e.g., daily)
2. Confirm trend direction on higher timeframe (e.g., weekly)
3. Use lower timeframe (e.g., 4-hour) for precise entry timing
4. All timeframes should show aligned trend direction

### Pattern Variations

- **Large Gap**: Gaps larger than 2% are more significant
- **Equal Bodies**: More symmetrical second and third candles increase reliability
- **Volume Pattern**: Decreasing volume on the two white candles can indicate consolidation before continuation

### Market Context Considerations

- **Gap Fill Risk**: Monitor for gap-filling behavior which would invalidate the pattern
- **News Events**: Verify gap isn't solely due to temporary news
- **Market Hours**: In 24-hour markets, verify gap represents genuine demand shift

## References

- "Japanese Candlestick Charting Techniques" by Steve Nison
- "Encyclopedia of Candlestick Charts" by Thomas Bulkowski
- "Beyond Candlesticks" by Steve Nison
- Technical Analysis of Financial Markets by John J. Murphy

## See Also

- [Pattern Recognition Overview](index.md)
- [Continuation Patterns Guide](../index.md)
- [Gap Trading Strategies](../index.md)
- [Back to Indicators](../index.md)
