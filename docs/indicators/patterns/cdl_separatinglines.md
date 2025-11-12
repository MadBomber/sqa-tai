# CDL_SEPARATINGLINES (Separating Lines)

## Overview

The Separating Lines pattern is a two-candle continuation pattern that can be either bullish or bearish depending on the prevailing trend. It consists of two candles of opposite colors that open at the same level, with the second candle moving in the direction of the trend. This pattern suggests strong momentum continuation and is considered a reliable signal when it appears in established trends.

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
- Critical for identifying the "separating" open at same level
- Must have same length as other price arrays

**high**
- Array of high prices for each period
- Used to validate candle body structure
- Helps confirm pattern strength

**low**
- Array of low prices for each period
- Used in pattern validation
- Helps measure candle body size

**close**
- Array of closing prices for each period
- Determines candle color and direction
- Essential for pattern recognition

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

# Example price data
open =  [48.00, 48.20, 48.50, 48.50]
high =  [48.70, 48.72, 48.90, 49.20]
low =   [47.79, 48.14, 48.39, 48.40]
close = [48.20, 48.61, 48.50, 49.00]

pattern = SQA::TAI.cdl_separatinglines(open, high, low, close)

puts "Pattern signal: #{pattern.last}"
# -100 = bearish continuation, 0 = no pattern, +100 = bullish continuation
```

### Analyzing Signals

```ruby
# Monitor for continuation signals
pattern.each_with_index do |signal, idx|
  case signal
  when 100
    puts "Bullish Separating Lines at #{idx} - uptrend continuation"
  when -100
    puts "Bearish Separating Lines at #{idx} - downtrend continuation"
  end
end
```

## Understanding the Indicator

### What It Measures

The Separating Lines pattern measures trend continuation strength through equal opens with opposite-colored candles. It indicates:
- Strong momentum in the trend direction
- Market agreement at a specific price level
- High probability of trend continuation
- Rejection of counter-trend movement

The pattern is significant because both candles open at the same level but move in opposite directions, with the trend-following candle showing strength.

### Pattern Structure

**Bullish Separating Lines (Uptrend Continuation):**
1. First candle: Black candle in an uptrend (pullback)
2. Second candle: White candle that:
   - Opens at same level as first candle's open
   - Closes higher, confirming uptrend
   - Shows strong bullish momentum

**Bearish Separating Lines (Downtrend Continuation):**
1. First candle: White candle in a downtrend (bounce)
2. Second candle: Black candle that:
   - Opens at same level as first candle's open
   - Closes lower, confirming downtrend
   - Shows strong bearish momentum

### Indicator Characteristics

- **Range**: Returns -100 (bearish continuation), 0 (no pattern), or +100 (bullish continuation)
- **Type**: Continuation pattern (two-candle formation)
- **Frequency**: Moderately rare
- **Best Used**: Strong trending markets
- **Reliability**: High when in established trend

## Interpretation

### Signal Values

- **+100**: Bullish continuation - uptrend expected to continue
- **0**: No pattern present
- **-100**: Bearish continuation - downtrend expected to continue

### Pattern Recognition

**Bullish Continuation (+100):**
- Appears in established uptrend
- Black candle (pullback) followed by white candle
- Both open at same level
- White candle confirms trend strength

**Bearish Continuation (-100):**
- Appears in established downtrend
- White candle (bounce) followed by black candle
- Both open at same level
- Black candle confirms trend weakness

## Trading Signals

### Buy Signals

For bullish pattern (+100):

```ruby
if pattern.last == 100
  entry_price = close.last
  stop_loss = low[-2..-1].min * 0.98
  target = entry_price + 2 * (entry_price - stop_loss)

  puts "BUY Signal: Bullish Separating Lines"
  puts "Entry: $#{entry_price.round(2)}"
  puts "Stop: $#{stop_loss.round(2)}"
  puts "Target: $#{target.round(2)}"
end
```

### Sell Signals

For bearish pattern (-100):

```ruby
if pattern.last == -100
  entry_price = close.last
  stop_loss = high[-2..-1].max * 1.02
  target = entry_price - 2 * (stop_loss - entry_price)

  puts "SELL Signal: Bearish Separating Lines"
  puts "Entry: $#{entry_price.round(2)}"
  puts "Stop: $#{stop_loss.round(2)}"
  puts "Target: $#{target.round(2)}"
end
```

## Best Practices

### Optimal Use Cases

- Strong established trends
- Liquid markets with clear price action
- Daily and 4-hour timeframes
- Trend confirmation needed

### Combining with Other Indicators

**With Trend Indicators:**
- Moving Averages: Confirm trend direction
- ADX: Verify trend strength above 25
- MACD: Validate momentum direction

**With Volume:**
- Higher volume on second candle strengthens signal
- OBV should confirm trend direction

### Common Pitfalls

1. Trading in ranging markets
2. Ignoring overall trend context
3. Missing volume confirmation
4. Incorrect open level identification

## Practical Example

```ruby
require 'sqa/tai'

open =  [45.00, 46.00, 47.50, 47.00, 47.00]
high =  [46.20, 47.80, 48.30, 47.80, 48.50]
low =   [44.80, 45.90, 47.00, 46.80, 46.90]
close = [46.00, 47.50, 47.00, 47.00, 48.30]

pattern = SQA::TAI.cdl_separatinglines(open, high, low, close)
sma_20 = SQA::TAI.sma(close, 5)

if pattern.last == 100 && close.last > sma_20.last
  puts "Bullish Separating Lines in uptrend - STRONG BUY"
elsif pattern.last == -100 && close.last < sma_20.last
  puts "Bearish Separating Lines in downtrend - STRONG SELL"
end
```

## Related Indicators

### Similar Patterns
- [Meeting Lines](cdl_meetinglines.md): Opposite pattern
- [Piercing Line](cdl_piercing.md): Similar bullish signal
- [Dark Cloud Cover](cdl_darkcloudcover.md): Similar bearish signal

### Indicator Combinations
- [ADX](../momentum/adx.md): Trend strength confirmation
- [Moving Averages](../overlap/sma.md): Trend direction
- [Volume](../volume/obv.md): Momentum validation

## References

- "Japanese Candlestick Charting Techniques" by Steve Nison
- "Encyclopedia of Candlestick Charts" by Thomas Bulkowski
- "Technical Analysis of the Financial Markets" by John J. Murphy

## See Also

- [Pattern Recognition Overview](index.md)
- [Continuation Patterns](../index.md)
- [Back to Indicators](../index.md)
