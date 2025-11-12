# CDL_KICKING (Kicking Pattern)

## Overview

The Kicking pattern is a powerful two-candle reversal pattern characterized by two consecutive marubozu candlesticks (candles with no or minimal shadows) that gap in opposite directions. This pattern signals a dramatic shift in market sentiment with strong conviction from both bulls and bears, making it one of the most reliable reversal patterns in candlestick analysis.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `open` | Array<Float> | Required | Array of opening prices for each period |
| `high` | Array<Float> | Required | Array of high prices for each period |
| `low` | Array<Float> | Required | Array of low prices for each period |
| `close` | Array<Float> | Required | Array of closing prices for each period |

### Parameter Details


**Note**: Array elements should be ordered from oldest to newest (chronological order)

**open**
- Opening price for each trading period
- Critical for identifying marubozu characteristics (open near high/low)
- Must be same length as other price arrays

**high**
- Highest price reached during each trading period
- Used to verify marubozu formation (minimal upper shadow)
- Must be same length as other price arrays

**low**
- Lowest price reached during each trading period
- Used to verify marubozu formation (minimal lower shadow)
- Must be same length as other price arrays

**close**
- Closing price for each trading period
- Critical for identifying marubozu characteristics (close near high/low)
- Must be same length as other price arrays

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

# Price data showing kicking pattern
open  = [50.0, 48.0, 47.0, 52.0, 53.0]
high  = [50.2, 48.1, 47.1, 53.5, 54.0]
low   = [47.8, 46.9, 46.8, 52.0, 52.8]
close = [48.0, 47.0, 46.9, 53.5, 53.8]

result = SQA::TAI.cdl_kicking(open, high, low, close)
puts "Pattern Signal: #{result.last}"
```

### Real-Time Monitoring

```ruby
result.each_with_index do |signal, index|
  case signal
  when 100
    puts "Bullish Kicking pattern at period #{index}"
  when -100
    puts "Bearish Kicking pattern at period #{index}"
  end
end
```

## Understanding the Indicator

### What It Measures

The Kicking pattern identifies dramatic sentiment reversals through:
- Two consecutive marubozu candles showing strong conviction
- Gap between candles demonstrating sudden shift
- Absence of shadows indicating no hesitation
- Complete rejection of previous trend

### Pattern Formation

**Bullish Kicking:**
1. First candle: Bearish marubozu (open near high, close near low)
2. Gap up opening of second candle
3. Second candle: Bullish marubozu (open near low, close near high)

**Bearish Kicking:**
1. First candle: Bullish marubozu (open near low, close near high)
2. Gap down opening of second candle
3. Second candle: Bearish marubozu (open near high, close near low)

**Key Characteristics:**
- Both candles must be marubozu (minimal/no shadows)
- Clear gap between the two candles
- Strong bodies on both candles
- Complete trend reversal signal

### Indicator Characteristics

- **Range**: -100 (bearish), 0 (no pattern), +100 (bullish)
- **Type**: Reversal pattern, high reliability
- **Lag**: None - two candle identification
- **Best Used**: At trend reversal points, breakouts
- **Reliability**: High - one of strongest reversal patterns
- **Time Frame**: All time frames; daily most reliable

## Interpretation

### Signal Values

- **+100 (Bullish Kicking)**: Strong bullish reversal
  - Sellers completely rejected
  - Buyers in full control
  - High probability uptrend initiation

- **-100 (Bearish Kicking)**: Strong bearish reversal
  - Buyers completely rejected
  - Sellers in full control
  - High probability downtrend initiation

- **0 (No Pattern)**: Requirements not met

### Pattern Strength Indicators

1. **Gap Size**: Larger gaps = stronger signals
2. **Body Size**: Larger marubozu bodies = more conviction
3. **Shadow Absence**: Perfect marubozu = strongest signal
4. **Volume**: High volume confirms pattern strength

## Trading Signals

### Buy Signals (Bullish Kicking)

**Entry Criteria:**
- Pattern confirmed (signal = +100)
- Enter on close of second candle
- Or enter on break above second candle high

**Stop Loss:**
- Below second candle low
- Or below gap level

**Take Profit:**
- 2:1 or 3:1 reward/risk
- Next resistance level

**Example:**
```ruby
if result.last == 100
  entry = close.last
  stop = low.last * 0.98
  target = entry + ((entry - stop) * 2)

  puts "BUY: #{entry}"
  puts "Stop: #{stop.round(2)}"
  puts "Target: #{target.round(2)}"
end
```

### Sell Signals (Bearish Kicking)

**Entry Criteria:**
- Pattern confirmed (signal = -100)
- Enter on close of second candle
- Or enter on break below second candle low

**Stop Loss:**
- Above second candle high
- Or above gap level

**Take Profit:**
- 2:1 or 3:1 reward/risk
- Next support level

## Best Practices

### Optimal Use Cases

**Market Conditions:**
- After extended trends
- At breakout points
- High volume periods
- Clear support/resistance levels

**Time Frames:**
- Daily: Most reliable
- 4-hour: Good for swing trading
- Weekly: Very strong signals
- Intraday: Requires confirmation

**Asset Classes:**
- Stocks: Highly effective
- Forex: Works on major pairs
- Futures: Very reliable
- Cryptocurrencies: Effective in high volatility

### Combining with Other Indicators

**With Volume:**
- High volume on both candles confirms strength
- Volume surge validates pattern

**With Momentum:**
- RSI extremes add conviction
- MACD confirmation strengthens signal

**With Support/Resistance:**
- Pattern at key levels highly significant
- Fibonacci levels add importance

### Common Pitfalls

1. **Ignoring Gap Requirement**
   - Must have clear gap between candles
   - Gap validates sentiment shift

2. **Poor Marubozu Identification**
   - Check for minimal shadows
   - Both candles must be strong marubozu

3. **No Volume Confirmation**
   - Always verify with volume
   - Low volume reduces reliability

4. **Wrong Time Frame**
   - Higher time frames more reliable
   - Intraday needs strict filtering

## Practical Example

```ruby
require 'sqa/tai'

# Historical data
open  = [48.0, 49.0, 50.0, 51.0, 50.8, 46.0, 47.0]
high  = [49.5, 50.5, 51.5, 51.2, 50.9, 47.5, 48.5]
low   = [47.8, 48.8, 49.8, 50.7, 46.0, 45.9, 46.8]
close = [49.0, 50.0, 51.0, 50.8, 46.1, 47.0, 48.2]

pattern = SQA::TAI.cdl_kicking(open, high, low, close)

if pattern.last == 100
  puts "BULLISH KICKING DETECTED"
  puts "First candle (bearish): O=#{open[-2]}, C=#{close[-2]}"
  puts "Second candle (bullish): O=#{open[-1]}, C=#{close[-1]}"
  puts "Gap size: #{(open[-1] - close[-2]).round(2)}"

  entry = close.last
  stop = low.last * 0.985
  target = entry + ((entry - stop) * 2.5)

  puts "\nTrade Setup:"
  puts "Entry: $#{entry.round(2)}"
  puts "Stop: $#{stop.round(2)}"
  puts "Target: $#{target.round(2)}"
  puts "Risk/Reward: 1:2.5"

elsif pattern.last == -100
  puts "BEARISH KICKING DETECTED"
  puts "First candle (bullish): O=#{open[-2]}, C=#{close[-2]}"
  puts "Second candle (bearish): O=#{open[-1]}, C=#{close[-1]}"
  puts "Gap size: #{(close[-2] - open[-1]).round(2)}"

  entry = close.last
  stop = high.last * 1.015
  target = entry - ((stop - entry) * 2.5)

  puts "\nTrade Setup:"
  puts "Entry: $#{entry.round(2)}"
  puts "Stop: $#{stop.round(2)}"
  puts "Target: $#{target.round(2)}"
  puts "Risk/Reward: 1:2.5"
end
```

## Related Indicators

### Similar Patterns

- **[Kicking by Length](cdl_kickingbylength.md)**: Variant where direction determined by longer marubozu
- **[Engulfing](cdl_engulfing.md)**: Similar reversal concept but without gap requirement
- **[Marubozu](cdl_marubozu.md)**: Single candle component of Kicking pattern

### Complementary Patterns

- **[Belt Hold](cdl_belthold.md)**: Single marubozu providing continuation confirmation
- **[Two Crows](cdl_2crows.md)**: Can follow bearish kicking for additional bearish confirmation
- **[Three White Soldiers](cdl_3whitesoldiers.md)**: Can follow bullish kicking to confirm uptrend

## Advanced Topics

### Multi-Timeframe Analysis

```ruby
# Daily kicking with weekly confirmation
daily_pattern = SQA::TAI.cdl_kicking(daily_open, daily_high, daily_low, daily_close)
weekly_trend = weekly_close.last > weekly_sma.last

if daily_pattern.last == 100 && weekly_trend
  puts "Strong bullish setup - daily kicking + weekly uptrend"
end
```

### Market Regime Adaptation

**Trending Markets:** Pattern most powerful, high success rate

**Ranging Markets:** Less frequent but still reliable at range boundaries

**High Volatility:** More frequent patterns, confirm with volume

### Statistical Validation

**Success Rates:**
- 70-75% success rate with proper confirmation
- 65-70% on daily charts
- Improves to 75-80% with volume confirmation
- One of highest reliability candlestick patterns

## References

- **"Japanese Candlestick Charting Techniques" by Steve Nison**: Comprehensive coverage of Kicking pattern
- **"Encyclopedia of Candlestick Charts" by Thomas Bulkowski**: Statistical performance analysis
- **Traditional Japanese Analysis**: Pattern represents complete market reversal

## See Also

- [Candlestick Patterns Overview](index.md)
- [Kicking by Length](cdl_kickingbylength.md)
- [Marubozu](cdl_marubozu.md)
- [Pattern Recognition Guide](../index.md)
- [API Reference](../../api-reference.md)
