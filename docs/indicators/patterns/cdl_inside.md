# CDL_INSIDE - See Three Inside Up/Down

> **Redirect**: The pattern you're looking for is documented as [Three Inside Up/Down (CDL_3INSIDE)](cdl_3inside.md).

## Pattern Name Clarification

In TA-Lib, the "inside" pattern is officially named **CDL_3INSIDE**, which stands for "Three Inside Up" (bullish) and "Three Inside Down" (bearish).

## Quick Reference

**Pattern Type**: Three-candle reversal pattern

**Bullish Version (Three Inside Up)**:
1. Large bearish candle
2. Small bullish candle inside first candle's range (harami)
3. Bullish candle closing above first candle's high

**Bearish Version (Three Inside Down)**:
1. Large bullish candle
2. Small bearish candle inside first candle's range (harami)
3. Bearish candle closing below first candle's low

## Documentation

For complete documentation, please see:

### [→ Three Inside Up/Down (CDL_3INSIDE)](cdl_3inside.md)

The complete documentation includes:
- Detailed pattern structure
- Parameter specifications
- Usage examples
- Trading strategies
- Confirmation techniques
- Risk management guidelines

## Usage Example

**Note**: Array elements should be ordered from oldest to newest (chronological order)

```ruby
require 'sqa/tai'

open  = [50.0, 49.5, 49.8, 50.5]
high  = [50.5, 50.0, 50.0, 51.0]
low   = [49.5, 49.0, 49.5, 49.5]
close = [49.5, 49.7, 50.2, 50.8]

# Use cdl_3inside (not cdl_inside)
pattern = SQA::TAI.cdl_3inside(open, high, low, close)

if pattern.last == 100
  puts "Bullish Three Inside Up detected"
elsif pattern.last == -100
  puts "Bearish Three Inside Down detected"
end
```

## Related Patterns

- **[Three Inside Up/Down (CDL_3INSIDE)](cdl_3inside.md)** - Full documentation
- **[Harami (CDL_HARAMI)](cdl_harami.md)** - Two-candle precursor pattern
- **[Three Outside Up/Down (CDL_3OUTSIDE)](cdl_3outside.md)** - Related pattern with engulfing

## See Also

- [Candlestick Patterns Index](index.md)
- [Pattern Recognition Guide](../../getting-started/pattern-recognition.md)
- [All Two-Candle Patterns](index.md#two-candlestick-patterns)
- [All Three-Candle Patterns](index.md#three-candlestick-patterns)

---

**Note**: Always use `cdl_3inside` in your code, not `cdl_inside`. The "3" prefix indicates it's a three-candle pattern and is the correct TA-Lib function name.
