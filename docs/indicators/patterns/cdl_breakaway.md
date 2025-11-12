# Breakaway Pattern

The Breakaway is a five-candle reversal pattern that signals a trend change after a strong move. It begins with a gap in the trend direction, followed by three candles continuing the trend, and concludes with a strong reversal candle that closes within the gap. The pattern shows initial momentum in the old trend direction, followed by exhaustion and reversal.

## Pattern Type

- **Type**: Reversal (Bullish or Bearish)
- **Candles Required**: 5
- **Trend Context**: Appears at trend extremes
- **Reliability**: Moderate to High
- **Frequency**: Rare (1-2%)

## Usage

```ruby
require 'sqa/tai'

# Example price data
open  = [95.0, 92.0, 89.0, 89.5, 93.0]
high  = [95.5, 92.5, 89.2, 89.7, 94.0]
low   = [91.0, 88.5, 88.8, 89.3, 92.5]
close = [92.0, 89.0, 89.1, 89.5, 93.5]

# Detect Breakaway pattern
pattern = SQA::TAI.cdl_breakaway(open, high, low, close)

if pattern.last == 100
  puts "Bullish Breakaway detected!"
elsif pattern.last == -100
  puts "Bearish Breakaway detected!"
end
```

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `open` | Array<Float> | Yes | Array of opening prices |
| `high` | Array<Float> | Yes | Array of high prices |
| `low` | Array<Float> | Yes | Array of low prices |
| `close` | Array<Float> | Yes | Array of closing prices |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

## Returns

Returns an array of integers:
- **0**: No pattern detected
- **+100**: Bullish pattern signal
- **-100**: Bearish pattern signal

## Pattern Recognition Rules

### Bullish Breakaway

- First Candle: Long black candle in downtrend
- Second Candle: Gaps down, continues lower (any color)
- Third & Fourth Candles: Continue in trend direction
- Fifth Candle: Long white candle that closes into the gap
- Gap Closure: Fifth candle closes within first candle body
- Volume: Typically declining through middle candles
- Reversal Volume: High volume on fifth candle

### Bearish Breakaway

- First Candle: Long white candle in uptrend
- Second Candle: Gaps up, continues higher (any color)
- Third & Fourth Candles: Continue in trend direction
- Fifth Candle: Long black candle that closes into the gap
- Gap Closure: Fifth candle closes within first candle body
- Volume: Typically declining through middle candles
- Reversal Volume: High volume on fifth candle

### Key Characteristics

- Clear trend context required
- Strong directional move
- Specific body and shadow requirements
- Volume confirmation helpful
- More reliable at support/resistance levels

## Trading Strategies

### Entry Rules

#### Conservative Entry
```ruby
# Wait for confirmation
if pattern[-2] != 0
  direction = pattern[-2] > 0 ? "LONG" : "SHORT"
  # Confirm with next candle
  if (pattern[-2] > 0 && close.last > close[-1]) ||
     (pattern[-2] < 0 && close.last < close[-1])
    puts "Enter #{direction} with confirmation"
    entry = close.last
  end
end
```

#### Aggressive Entry
```ruby
# Enter on pattern completion
if pattern.last != 0
  direction = pattern.last > 0 ? "LONG" : "SHORT"
  entry = close.last
  puts "Enter #{direction} at #{entry}"
end
```

### Stop Loss Placement

```ruby
if pattern.last != 0
  if pattern.last > 0  # Bullish
    stop = low[-1] * 0.99
    puts "Stop below pattern low: #{stop}"
  else  # Bearish
    stop = high[-1] * 1.01
    puts "Stop above pattern high: #{stop}"
  end
end
```

### Profit Targets

```ruby
if pattern.last != 0
  entry = close.last
  if pattern.last > 0  # Bullish
    stop = low[-1] * 0.99
    risk = entry - stop
    target_1 = entry + (risk * 2)
    target_2 = entry + (risk * 3)
  else  # Bearish
    stop = high[-1] * 1.01
    risk = stop - entry
    target_1 = entry - (risk * 2)
    target_2 = entry - (risk * 3)
  end

  puts "T1 (2R): #{target_1}"
  puts "T2 (3R): #{target_2}"
end
```

## Example: Complete Analysis

```ruby
open, high, low, close, volume = load_ohlc_volume_data('AAPL')

pattern = SQA::TAI.cdl_breakaway(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)
sma_50 = SQA::TAI.sma(close, period: 50)

if pattern.last != 0
  direction = pattern.last > 0 ? "BULLISH" : "BEARISH"
  puts "#{direction} Breakaway Pattern Detected"
  puts "=" * 60

  # Trend verification
  if pattern.last > 0
    downtrend = close[-5] < sma_50[-5]
    oversold = rsi.last < 30
    puts "Downtrend: #{downtrend}"
    puts "Oversold: #{oversold}"
  else
    uptrend = close[-5] > sma_50[-5]
    overbought = rsi.last > 70
    puts "Uptrend: #{uptrend}"
    puts "Overbought: #{overbought}"
  end

  # Volume analysis
  avg_vol = volume[-20..-2].sum / 19.0
  vol_confirmation = volume.last > avg_vol * 1.2

  puts "Volume confirmation: #{vol_confirmation}"

  # Calculate trade setup
  entry = close.last
  if pattern.last > 0
    stop = low[-1] * 0.99
    risk = entry - stop
    target = entry + (risk * 2.5)
  else
    stop = high[-1] * 1.01
    risk = stop - entry
    target = entry - (risk * 2.5)
  end

  rr = ((target - entry).abs / risk).round(1)

  puts "\nTrade Setup:"
  puts "Entry: $#{entry.round(2)}"
  puts "Stop: $#{stop.round(2)}"
  puts "Target: $#{target.round(2)}"
  puts "R:R: 1:#{rr}"
end
```

## Pattern Statistics

### Frequency
- **Occurrence**: Rare (1-2%)
- **Best Timeframes**: Daily and weekly charts
- **Markets**: Works on all liquid markets

### Success Rate
- **Perfect pattern**: 70-78%
- **With confirmation**: 75-85%
- **At support/resistance**: 78-88%
- **With volume**: 72-82%

### Average Move
- **Initial move**: 8-15%
- **Major reversals**: 20-40%
- **Time to target**: 10-30 candles

## Best Practices

### Do's
1. Verify trend context before trading
2. Check for volume confirmation
3. Combine with RSI for extremes
4. Look for pattern at key levels
5. Wait for confirmation if unsure
6. Use proper stop loss placement
7. Scale positions appropriately
8. Monitor for pattern invalidation
9. Consider timeframe alignment
10. Track pattern success rate

### Don'ts
1. Don't trade without trend context
2. Don't ignore volume signals
3. Don't skip confirmation in ranging markets
4. Don't use tight stops initially
5. Don't overtrade the pattern
6. Don't ignore larger timeframes
7. Don't chase after significant move
8. Don't skip risk management
9. Don't trade in low liquidity
10. Don't ignore market conditions

## Common Mistakes

1. **Misidentification**: Verify all pattern requirements
2. **Wrong context**: Pattern needs appropriate trend
3. **No confirmation**: Wait for follow-through
4. **Poor stop placement**: Use logical invalidation points
5. **Ignoring volume**: Volume confirms conviction
6. **Overtrading**: Wait for quality setups
7. **No risk management**: Always use stops

## Related Patterns

### Similar Patterns
- [Hammer](cdl_hammer.md) - Single candle reversal
- [Engulfing](cdl_engulfing.md) - Two candle reversal
- [Morning Star](cdl_morningstar.md) - Three candle reversal
- [Evening Star](cdl_eveningstar.md) - Three candle reversal

### Component Patterns
- [Marubozu](cdl_marubozu.md) - Strong directional candle
- [Doji](cdl_doji.md) - Indecision candle
- [Long Line](cdl_longline.md) - Strong body

## Key Takeaways

1. **Trend context critical** - must have appropriate trend
2. **Volume confirms** - high volume on reversal validates
3. **Wait for confirmation** - reduces false signals
4. **Support/resistance** - more reliable at key levels
5. **Risk management** - always use stops
6. **Position sizing** - adjust for pattern strength
7. **Timeframe matters** - higher timeframes more reliable
8. **Combine indicators** - use RSI, MA, volume
9. **Track performance** - learn from results
10. **Stay disciplined** - follow your rules

## See Also

- [Hammer](cdl_hammer.md)
- [Shooting Star](cdl_shootingstar.md)
- [Engulfing](cdl_engulfing.md)
- [Morning Star](cdl_morningstar.md)
- [Evening Star](cdl_eveningstar.md)
- [Pattern Recognition Overview](index.md)
- [Back to Indicators](../index.md)
































































































































































































































































































































































