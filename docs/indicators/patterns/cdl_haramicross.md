# CDL_HARAMICROSS (Harami Cross)

## Overview

The Harami Cross is a two-candle reversal pattern where a doji appears completely within the body of the previous candle. The pattern signals potential trend exhaustion and indecision in the market, with the cross (doji) indicating a balance between buyers and sellers after a strong directional move.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `open` | Array<Float> | Required | Array of opening prices for each period |
| `high` | Array<Float> | Required | Array of high prices for each period |
| `low` | Array<Float> | Required | Array of low prices for each period |
| `close` | Array<Float> | Required | Array of closing prices for each period |

### Parameter Details

**open**
- Opening price for each trading period
- Must be same length as high, low, and close arrays
- Used to determine candle body direction and size

**high**
- Highest price reached during each trading period
- Must be same length as other price arrays
- Used to identify shadow lengths

**low**
- Lowest price reached during each trading period
- Must be same length as other price arrays
- Used to identify shadow lengths and doji characteristics

**close**
- Closing price for each trading period
- Must be same length as other price arrays
- Used to determine candle body direction and identify doji formation

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

# Price data arrays
open  = [45.0, 48.0, 47.5, 47.6, 47.5]
high  = [45.5, 48.5, 47.8, 47.9, 48.0]
low   = [44.5, 47.5, 47.3, 47.3, 46.5]
close = [48.0, 48.2, 47.6, 47.5, 46.8]

result = SQA::TAI.cdl_haramicross(open, high, low, close)
puts "Pattern Signal: #{result.last}"
```

### Real-Time Pattern Monitoring

```ruby
# Monitor for pattern across multiple periods
result.each_with_index do |signal, index|
  case signal
  when 100
    puts "Bullish Harami Cross at period #{index}"
  when -100
    puts "Bearish Harami Cross at period #{index}"
  end
end
```

## Understanding the Indicator

### What It Measures

The Harami Cross pattern measures potential reversal points through the emergence of market indecision after a strong trend. The pattern is valuable because:

- The doji shows perfect balance between buyers and sellers
- The small doji within a large candle indicates exhaustion of the previous trend
- It signals hesitation and potential reversal before other indicators
- More reliable than regular Harami due to the doji's stronger indecision signal

### Pattern Formation

The pattern requires two consecutive candles:

1. **First Candle (Mother)**: A large candle (bullish or bearish) showing strong directional movement. This represents the prevailing trend with decisive price action.

2. **Second Candle (Cross/Doji)**: A doji that forms completely within the real body of the first candle. The doji's open and close are nearly equal, showing indecision.

**Key Characteristics:**
- Second candle must be a doji (open ≈ close)
- Doji must be contained within first candle's real body
- The larger the first candle, the more significant the pattern
- Pattern can be bullish or bearish depending on first candle color

### Indicator Characteristics

- **Range**: Returns -100 (bearish), 0 (no pattern), or +100 (bullish)
- **Type**: Pattern recognition, reversal indicator
- **Lag**: None - identifies patterns as they complete (requires two candles)
- **Best Used**: After extended trends, at support/resistance levels
- **Reliability**: Moderate; improves with confirmation
- **Time Frame**: Works on all time frames; daily charts most reliable

## Interpretation

### Signal Values

- **+100 (Bullish Harami Cross)**:
  - Bearish mother candle followed by doji
  - Suggests downtrend may be ending
  - Consider long positions with confirmation

- **-100 (Bearish Harami Cross)**:
  - Bullish mother candle followed by doji
  - Suggests uptrend may be ending
  - Consider short positions or exit longs with confirmation

- **0 (No Pattern)**: Pattern requirements not met

### Pattern Strength Indicators

1. **Mother Candle Size**
   - Larger mother candle = stronger signal
   - Strong directional candle shows trend exhaustion
   - Minimum body size improves reliability

2. **Doji Quality**
   - Smaller doji body = stronger indecision
   - Long shadows on doji indicate volatility
   - Perfect doji (open = close) is most reliable

3. **Positioning**
   - Pattern at support/resistance increases reliability
   - After extended trends more significant
   - Volume confirmation strengthens signal

### Context Considerations

- **Location**: Most effective at key support/resistance levels
- **Volume**: Decreasing volume on doji confirms indecision
- **Market Condition**: Best in trending markets
- **Time Frame**: Higher time frames provide more reliable signals

## Trading Signals

### Buy Signals (Bullish Harami Cross)

1. **Pattern Confirmation**
   - Large bearish candle followed by doji
   - Doji completely within mother candle's body
   - Signal value = +100

2. **Entry Criteria**
   - Enter on break above pattern high
   - Wait for bullish confirmation candle
   - Conservative: wait for close above mother candle open

3. **Additional Confirmation**
   - RSI showing oversold conditions
   - At established support level
   - Volume increase on confirmation candle

**Example Scenario:**
```ruby
if result.last == 100 &&
   close.last > support_level &&
   rsi.last < 35

  entry = high.last
  stop_loss = low[-2] * 0.98
  target = entry + ((entry - stop_loss) * 2)

  puts "BUY Signal at #{entry}"
  puts "Stop: #{stop_loss}, Target: #{target}"
end
```

### Sell Signals (Bearish Harami Cross)

1. **Pattern Confirmation**
   - Large bullish candle followed by doji
   - Doji completely within mother candle's body
   - Signal value = -100

2. **Entry Criteria**
   - Enter on break below pattern low
   - Wait for bearish confirmation candle
   - Conservative: wait for close below mother candle open

3. **Additional Confirmation**
   - RSI showing overbought conditions
   - At established resistance level
   - Volume increase on confirmation candle

### Position Management

**Stop Loss Placement:**
- Long: Below doji low or mother candle low
- Short: Above doji high or mother candle high
- ATR-based: 1.5-2x ATR from entry

**Take Profit Targets:**
- First target: 1:1 reward/risk ratio
- Second target: Next support/resistance level
- Trailing stop: After first target hit

## Best Practices

### Optimal Use Cases

**Market Conditions:**
- After extended trends (5+ candles in same direction)
- At key support/resistance levels
- When momentum indicators show extremes
- During period of trend exhaustion

**Time Frames:**
- Daily charts: Most reliable
- 4-hour charts: Good for swing trading
- Weekly charts: Stronger signals, fewer occurrences
- Intraday: Less reliable, needs confirmation

**Asset Classes:**
- Stocks: Highly effective
- Forex: Works on major pairs
- Commodities: Reliable on liquid contracts
- Cryptocurrencies: Use with caution due to volatility

### Combining with Other Indicators

**With Trend Indicators:**
- **Moving Averages**: Pattern at MA provides strong support/resistance
- **MACD**: Divergence confirms potential reversal
- **ADX**: Low ADX suggests trend weakening

**With Momentum Indicators:**
- **RSI**: Overbought/oversold confirms pattern
- **Stochastic**: Extreme readings strengthen signal
- **CCI**: Oversold/overbought zones add conviction

**With Support/Resistance:**
- **Fibonacci Levels**: Pattern at key retracement levels
- **Pivot Points**: Daily/weekly pivots add significance
- **Volume Profile**: High volume nodes validate pattern

### Common Pitfalls

1. **Trading Without Confirmation**
   - Don't enter immediately on pattern completion
   - Wait for third candle confirmation
   - Require break of pattern high/low

2. **Ignoring Trend Context**
   - Pattern needs preceding trend
   - Weak in ranging markets
   - Verify strong directional move before pattern

3. **Poor Risk Management**
   - Always use stop losses
   - Don't risk more than 2% per trade
   - Account for pattern failure

4. **Volume Neglect**
   - Confirm with volume analysis
   - Decreasing volume on doji is positive
   - Volume surge on confirmation validates pattern

### Parameter Selection Guidelines

**Short-term Trading:**
- Use 15-minute to 1-hour charts cautiously
- Require additional confirmation
- Tighter stops, smaller positions

**Medium-term Trading:**
- 4-hour to daily charts recommended
- Balance sensitivity and reliability
- Hold for multiple days

**Long-term Trading:**
- Daily to weekly charts
- Fewer signals, higher reliability
- Larger position sizes with confirmation

## Practical Example

```ruby
require 'sqa/tai'

# Historical price data
open  = [45.0, 46.0, 48.0, 49.0, 50.0, 51.0, 51.5, 51.6, 49.5]
high  = [46.5, 48.5, 49.5, 50.5, 51.5, 52.0, 51.8, 51.8, 49.8]
low   = [45.0, 45.8, 47.8, 48.8, 49.8, 50.8, 51.4, 51.4, 48.5]
close = [46.0, 48.0, 49.0, 50.0, 51.0, 51.5, 51.6, 51.5, 49.0]

# Calculate pattern
pattern = SQA::TAI.cdl_haramicross(open, high, low, close)
rsi = SQA::TAI.rsi(close, time_period: 14)

# Analyze current signal
if pattern.last == -100
  puts "BEARISH HARAMI CROSS DETECTED"
  puts "Mother Candle: O=#{open[-2]}, C=#{close[-2]}"
  puts "Doji: O=#{open[-1]}, C=#{close[-1]}"
  puts "RSI: #{rsi.last.round(2)}"

  if rsi.last > 70
    puts "Strong sell signal - RSI overbought"
    entry = close.last
    stop = high[-2] * 1.02
    target = entry - ((stop - entry) * 2)

    puts "Entry: #{entry}"
    puts "Stop: #{stop.round(2)}"
    puts "Target: #{target.round(2)}"
  end

elsif pattern.last == 100
  puts "BULLISH HARAMI CROSS DETECTED"
  puts "Mother Candle: O=#{open[-2]}, C=#{close[-2]}"
  puts "Doji: O=#{open[-1]}, C=#{close[-1]}"
  puts "RSI: #{rsi.last.round(2)}"

  if rsi.last < 30
    puts "Strong buy signal - RSI oversold"
    entry = close.last
    stop = low[-2] * 0.98
    target = entry + ((entry - stop) * 2)

    puts "Entry: #{entry}"
    puts "Stop: #{stop.round(2)}"
    puts "Target: #{target.round(2)}"
  end
end
```

## Related Indicators

### Similar Patterns

- **[Harami](cdl_harami.md)**: Similar pattern without doji requirement; Harami Cross is more specific and reliable
- **[Doji](cdl_doji.md)**: Single candle indecision pattern; Harami Cross adds context of prior trend
- **[Inside Bar](cdl_inside.md)**: General inside candle pattern; Harami Cross requires doji specifically

### Complementary Patterns

- **[Engulfing](cdl_engulfing.md)**: Can follow Harami Cross to confirm reversal
- **[Piercing Pattern](cdl_piercing.md)**: Bullish confirmation after Bullish Harami Cross
- **[Dark Cloud Cover](cdl_darkcloudcover.md)**: Bearish confirmation after Bearish Harami Cross

### Pattern Family

**Harami Pattern Family:**
- **Harami**: Small candle within large candle
- **Harami Cross**: Doji within large candle (more specific)
- Both indicate potential reversals through contraction after expansion

## Advanced Topics

### Multi-Timeframe Analysis

```ruby
# Daily pattern with 4-hour confirmation
daily_pattern = SQA::TAI.cdl_haramicross(daily_open, daily_high, daily_low, daily_close)
h4_pattern = SQA::TAI.cdl_haramicross(h4_open, h4_high, h4_low, h4_close)

if daily_pattern.last == 100 && h4_pattern.last == 100
  puts "Strong bullish signal - multiple timeframe confirmation"
end
```

### Market Regime Adaptation

**Trending Markets:**
- Pattern most reliable
- Standard entry rules apply
- Strong confirmation recommended

**Ranging Markets:**
- Less reliable, many false signals
- Require multiple confirmations
- Reduce position size

**High Volatility:**
- Wider stops needed
- Doji more common, reduce significance
- Confirm with volume

### Statistical Validation

**Historical Success Rates:**
- 55-60% success rate with confirmation
- 40-45% without confirmation
- Daily timeframe shows best results
- RSI confirmation increases success to 65-70%

## References

- **"Japanese Candlestick Charting Techniques" by Steve Nison**: Comprehensive coverage of Harami Cross pattern
- **"Encyclopedia of Candlestick Charts" by Thomas Bulkowski**: Statistical analysis of pattern performance
- **Original Japanese Sources**: Pattern from traditional Japanese candlestick analysis

## See Also

- [Candlestick Patterns Overview](index.md)
- [Harami - Similar Pattern](cdl_harami.md)
- [Doji - Foundation Pattern](cdl_doji.md)
- [Pattern Recognition Guide](../index.md)
- [API Reference](../../api-reference.md)
