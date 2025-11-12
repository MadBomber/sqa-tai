# CDL_MEETINGLINES (Meeting Lines)

> **Note**: This pattern may not be implemented in the current version of TA-Lib/SQA::TAI. Please verify availability before use. The [Counterattack Pattern](cdl_counterattack.md) is very similar and may be used as an alternative.

## Overview

Meeting Lines is a two-candle reversal pattern where two opposite-colored candles have nearly identical closing prices. The pattern suggests a potential trend reversal when the second candle "meets" the first at the same price level, indicating a shift in market sentiment.

## Pattern Structure

### Bullish Meeting Lines
- **First Candle**: Long bearish (black/red) candle in downtrend
- **Second Candle**: Bullish (white/green) candle
- **Key Feature**: Both candles close at approximately the same price
- **Signal**: Potential bullish reversal

### Bearish Meeting Lines
- **First Candle**: Long bullish (white/green) candle in uptrend
- **Second Candle**: Bearish (black/red) candle
- **Key Feature**: Both candles close at approximately the same price
- **Signal**: Potential bearish reversal

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `open` | Array | Required | Array of opening prices |
| `high` | Array | Required | Array of high prices |
| `low` | Array | Required | Array of low prices |
| `close` | Array | Required | Array of closing prices |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

## Hypothetical Usage

```ruby
require 'sqa/tai'

# Note: Verify this pattern is available in your TA-Lib version
open  = [50.0, 49.5, 48.0, 47.5]
high  = [50.5, 50.0, 48.5, 48.5]
low   = [49.5, 48.5, 47.5, 47.0]
close = [49.5, 48.5, 47.5, 47.5]  # Note: last two closes are equal

# If available:
# pattern = SQA::TAI.cdl_meetinglines(open, high, low, close)
#
# if pattern.last == 100
#   puts "Bullish Meeting Lines detected"
# elsif pattern.last == -100
#   puts "Bearish Meeting Lines detected"
# end
```

## Interpretation

### Signal Values
- **+100**: Bullish Meeting Lines pattern
- **-100**: Bearish Meeting Lines pattern
- **0**: No pattern detected

### Trading Implications

**Bullish Meeting Lines**:
- Appears after downtrend
- Shows bears losing control
- Bulls managing to close at previous level
- Suggests potential bottom formation

**Bearish Meeting Lines**:
- Appears after uptrend
- Shows bulls losing control
- Bears managing to close at previous level
- Suggests potential top formation

## Pattern Characteristics

- **Type**: Two-candle reversal pattern
- **Reliability**: Moderate (requires confirmation)
- **Best Timeframe**: Daily charts
- **Confirmation**: Wait for next candle to confirm direction

## Comparison with Similar Patterns

### vs Counterattack Pattern

Meeting Lines is extremely similar to the [Counterattack Pattern](cdl_counterattack.md):
- Both have similar structure
- Both are two-candle reversals
- Key difference: Subtle variations in how TA-Lib defines the closing price proximity

**Recommendation**: Use [Counterattack](cdl_counterattack.md) if Meeting Lines is not available.

### vs Piercing/Dark Cloud Cover

- Meeting Lines: Closes at same level
- [Piercing](cdl_piercing.md): Closes above midpoint of first candle
- [Dark Cloud Cover](cdl_darkcloudcover.md): Closes below midpoint of first candle

## Trading Guidelines

### Entry Signals
1. Wait for pattern completion (both candles closed)
2. Confirm with next candle moving in signal direction
3. Check for volume increase on reversal candle
4. Verify pattern appears at key support/resistance

### Risk Management
- **Stop Loss**: Place beyond the pattern's extreme (high for bearish, low for bullish)
- **Position Sizing**: Use smaller size until confirmation
- **Target**: Next significant support/resistance level

## Confirmation Techniques

### 1. Volume Confirmation
```ruby
# Higher volume on second candle strengthens signal
if pattern.last != 0 && volume.last > volume[-2]
  puts "Volume confirms pattern"
end
```

### 2. Trend Context
```ruby
# Pattern more reliable when reversing established trend
sma_50 = SQA::TAI.sma(close, period: 50)

if pattern.last == 100 && close.last < sma_50.last
  puts "Bullish pattern in downtrend - stronger signal"
end
```

### 3. Support/Resistance
```ruby
# Pattern at key level increases reliability
if pattern.last == 100 && close.last >= support_level * 0.99
  puts "Pattern at support - high probability"
end
```

## See Also

### Similar Reversal Patterns
- [Counterattack](cdl_counterattack.md) - Very similar pattern
- [Piercing Pattern](cdl_piercing.md) - Bullish reversal
- [Dark Cloud Cover](cdl_darkcloudcover.md) - Bearish reversal
- [Engulfing](cdl_engulfing.md) - Strong reversal pattern

### Pattern Resources
- [Candlestick Pattern Index](index.md)
- [Pattern Recognition Guide](../../getting-started/pattern-recognition.md)
- [API Reference](../../api-reference.md)

---

**Availability Note**: This pattern may not be in all TA-Lib implementations. Consider using the [Counterattack Pattern](cdl_counterattack.md) as a close alternative, or use general pattern recognition techniques described in the [Pattern Recognition Guide](../../getting-started/pattern-recognition.md).
