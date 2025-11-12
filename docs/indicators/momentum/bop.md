# Balance of Power (BOP)

The Balance of Power (BOP) indicator measures the strength of buyers versus sellers by comparing the close price to the open price relative to the trading range. It oscillates between -1 and +1, providing insight into whether buyers or sellers are in control of the market.

## Formula

```
BOP = (Close - Open) / (High - Low)
```

The indicator calculates the ratio of the price change from open to close against the total trading range. When the close is near the high, buyers are in control. When the close is near the low, sellers dominate.

## Usage

```ruby
require 'sqa/tai'

opens  = [100.0, 102.0, 103.5, 102.0, 101.0]
highs  = [103.0, 105.0, 106.0, 104.0, 103.0]
lows   = [99.0,  101.0, 102.0, 100.0, 99.0]
closes = [102.5, 104.0, 102.5, 101.0, 102.0]

bop = SQA::TAI.bop(
  open:  opens,
  high:  highs,
  low:   lows,
  close: closes
)

puts "Current BOP: #{bop.last.round(3)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `open` | Array<Float> | Yes | - | Array of opening prices |
| `high` | Array<Float> | Yes | - | Array of high prices |
| `low` | Array<Float> | Yes | - | Array of low prices |
| `close` | Array<Float> | Yes | - | Array of closing prices |

## Returns

Returns an array of BOP values ranging from -1.0 to +1.0. Each value represents the balance of buying versus selling pressure for that period.

## Interpretation

| BOP Value | Interpretation | Market Condition |
|-----------|----------------|------------------|
| +0.75 to +1.0 | Strong buying pressure | Close near high, buyers dominating |
| +0.25 to +0.75 | Moderate buying pressure | Close above midpoint, buyers in control |
| -0.25 to +0.25 | Balanced market | Close near middle, equilibrium |
| -0.75 to -0.25 | Moderate selling pressure | Close below midpoint, sellers in control |
| -1.0 to -0.75 | Strong selling pressure | Close near low, sellers dominating |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

### Key Levels

- **+1.0**: Perfect buying pressure (Close = High, Open = Low)
- **+0.5**: Close at 75% of range from low
- **0.0**: Close at exact midpoint or Close = Open
- **-0.5**: Close at 25% of range from low
- **-1.0**: Perfect selling pressure (Close = Low, Open = High)

## Example: Basic BOP Analysis

```ruby
opens  = [50.0, 51.0, 52.0, 51.5, 50.5]
highs  = [52.0, 53.0, 53.5, 53.0, 52.0]
lows   = [49.5, 50.5, 51.0, 50.0, 49.0]
closes = [51.5, 52.5, 51.5, 50.5, 51.5]

bop = SQA::TAI.bop(
  open:  opens,
  high:  highs,
  low:   lows,
  close: closes
)

current_bop = bop.last

case current_bop
when 0.75..1.0
  puts "Strong Buying Pressure (#{current_bop.round(3)}) - Buyers dominating"
when 0.25...0.75
  puts "Moderate Buying Pressure (#{current_bop.round(3)}) - Buyers in control"
when -0.25...0.25
  puts "Balanced Market (#{current_bop.round(3)}) - No clear winner"
when -0.75...-0.25
  puts "Moderate Selling Pressure (#{current_bop.round(3)}) - Sellers in control"
when -1.0...-0.75
  puts "Strong Selling Pressure (#{current_bop.round(3)}) - Sellers dominating"
end
```

## Example: Buying Pressure Scenarios

```ruby
# Scenario 1: Strong Buying Day
# Open at low, close at high - maximum buying pressure
open_1  = 100.0
high_1  = 105.0
low_1   = 100.0
close_1 = 105.0

bop_1 = (close_1 - open_1) / (high_1 - low_1)
puts "Scenario 1 - Strong Buying: BOP = #{bop_1.round(3)}"  # BOP = 1.0

# Scenario 2: Moderate Buying Day
# Open near low, close above midpoint
open_2  = 100.5
high_2  = 105.0
low_2   = 100.0
close_2 = 103.5  # Close in upper half

bop_2 = (close_2 - open_2) / (high_2 - low_2)
puts "Scenario 2 - Moderate Buying: BOP = #{bop_2.round(3)}"  # BOP ≈ 0.6

# Scenario 3: Weak Buying Day
# Close slightly above open but near midpoint
open_3  = 102.0
high_3  = 105.0
low_3   = 100.0
close_3 = 102.5  # Small gain

bop_3 = (close_3 - open_3) / (high_3 - low_3)
puts "Scenario 3 - Weak Buying: BOP = #{bop_3.round(3)}"  # BOP ≈ 0.1
```

## Example: Selling Pressure Scenarios

```ruby
# Scenario 1: Strong Selling Day
# Open at high, close at low - maximum selling pressure
open_1  = 105.0
high_1  = 105.0
low_1   = 100.0
close_1 = 100.0

bop_1 = (close_1 - open_1) / (high_1 - low_1)
puts "Scenario 1 - Strong Selling: BOP = #{bop_1.round(3)}"  # BOP = -1.0

# Scenario 2: Moderate Selling Day
# Open near high, close below midpoint
open_2  = 104.5
high_2  = 105.0
low_2   = 100.0
close_2 = 101.5  # Close in lower half

bop_2 = (close_2 - open_2) / (high_2 - low_2)
puts "Scenario 2 - Moderate Selling: BOP = #{bop_2.round(3)}"  # BOP ≈ -0.6

# Scenario 3: Weak Selling Day
# Close slightly below open but near midpoint
open_3  = 103.0
high_3  = 105.0
low_3   = 100.0
close_3 = 102.5  # Small loss

bop_3 = (close_3 - open_3) / (high_3 - low_3)
puts "Scenario 3 - Weak Selling: BOP = #{bop_3.round(3)}"  # BOP ≈ -0.1
```

## Example: BOP Divergence Detection

```ruby
# Divergence can signal potential reversals
opens  = load_ohlc_data('AAPL')[:open]
highs  = load_ohlc_data('AAPL')[:high]
lows   = load_ohlc_data('AAPL')[:low]
closes = load_ohlc_data('AAPL')[:close]

bop = SQA::TAI.bop(open: opens, high: highs, low: lows, close: closes)

# Check for bearish divergence
# Price making higher highs, but BOP making lower highs
price_high_1 = closes[-20..-10].max
price_high_2 = closes[-9..-1].max

bop_high_1 = bop[-20..-10].max
bop_high_2 = bop[-9..-1].max

if price_high_2 > price_high_1 && bop_high_2 < bop_high_1
  puts <<~DIVERGENCE
    Bearish Divergence Detected!
    Price: #{price_high_1} -> #{price_high_2} (higher high)
    BOP: #{bop_high_1.round(3)} -> #{bop_high_2.round(3)} (lower high)
    Signal: Weakening buying pressure despite higher prices
    Action: Consider taking profits or preparing for reversal
  DIVERGENCE
end

# Check for bullish divergence
# Price making lower lows, but BOP making higher lows
price_low_1 = closes[-20..-10].min
price_low_2 = closes[-9..-1].min

bop_low_1 = bop[-20..-10].min
bop_low_2 = bop[-9..-1].min

if price_low_2 < price_low_1 && bop_low_2 > bop_low_1
  puts <<~DIVERGENCE
    Bullish Divergence Detected!
    Price: #{price_low_1} -> #{price_low_2} (lower low)
    BOP: #{bop_low_1.round(3)} -> #{bop_low_2.round(3)} (higher low)
    Signal: Weakening selling pressure despite lower prices
    Action: Consider buying or preparing for reversal
  DIVERGENCE
end
```

## Example: BOP Trend Confirmation

```ruby
opens  = load_ohlc_data('TSLA')[:open]
highs  = load_ohlc_data('TSLA')[:high]
lows   = load_ohlc_data('TSLA')[:low]
closes = load_ohlc_data('TSLA')[:close]

bop = SQA::TAI.bop(open: opens, high: highs, low: lows, close: closes)
sma_50 = SQA::TAI.sma(closes, period: 50)

current_price = closes.last
current_bop = bop.last
trend_line = sma_50.last

# Confirm trends with BOP
if current_price > trend_line
  # Uptrend
  if current_bop > 0.5
    puts <<~SIGNAL
      Strong Uptrend Confirmed
      Price above 50 SMA: #{current_price} > #{trend_line.round(2)}
      BOP shows strong buying: #{current_bop.round(3)}
      Action: Hold longs, add on pullbacks
    SIGNAL
  elsif current_bop < -0.3
    puts <<~WARNING
      Uptrend Warning
      Price above 50 SMA but BOP shows selling: #{current_bop.round(3)}
      Signal: Possible trend exhaustion
      Action: Tighten stops, watch for reversal
    WARNING
  end
elsif current_price < trend_line
  # Downtrend
  if current_bop < -0.5
    puts <<~SIGNAL
      Strong Downtrend Confirmed
      Price below 50 SMA: #{current_price} < #{trend_line.round(2)}
      BOP shows strong selling: #{current_bop.round(3)}
      Action: Hold shorts, add on rallies
    SIGNAL
  elsif current_bop > 0.3
    puts <<~WARNING
      Downtrend Warning
      Price below 50 SMA but BOP shows buying: #{current_bop.round(3)}
      Signal: Possible trend exhaustion
      Action: Cover shorts, watch for reversal
    WARNING
  end
end
```

## Example: BOP Reversal Signals

```ruby
opens  = load_ohlc_data('MSFT')[:open]
highs  = load_ohlc_data('MSFT')[:high]
lows   = load_ohlc_data('MSFT')[:low]
closes = load_ohlc_data('MSFT')[:close]

bop = SQA::TAI.bop(open: opens, high: highs, low: lows, close: closes)

# Look for reversal patterns
recent_bop = bop[-5..-1]

# Reversal from oversold (consecutive negative BOP to positive)
if recent_bop[0..2].all? { |v| v < -0.6 } && recent_bop[-1] > 0.5
  puts <<~REVERSAL
    Bullish Reversal Signal
    Previous 3 periods: Strong selling pressure (BOP < -0.6)
    Current period: Strong buying pressure (BOP > 0.5)
    Signal: Sellers exhausted, buyers taking control
    Action: Consider long entry
  REVERSAL
end

# Reversal from overbought (consecutive positive BOP to negative)
if recent_bop[0..2].all? { |v| v > 0.6 } && recent_bop[-1] < -0.5
  puts <<~REVERSAL
    Bearish Reversal Signal
    Previous 3 periods: Strong buying pressure (BOP > 0.6)
    Current period: Strong selling pressure (BOP < -0.5)
    Signal: Buyers exhausted, sellers taking control
    Action: Consider short entry or exit longs
  REVERSAL
end
```

## Example: BOP with Volume Confirmation

```ruby
opens   = load_ohlc_data('NVDA')[:open]
highs   = load_ohlc_data('NVDA')[:high]
lows    = load_ohlc_data('NVDA')[:low]
closes  = load_ohlc_data('NVDA')[:close]
volumes = load_ohlc_data('NVDA')[:volume]

bop = SQA::TAI.bop(open: opens, high: highs, low: lows, close: closes)
avg_volume = volumes[-20..-1].sum / 20.0

current_bop = bop.last
current_volume = volumes.last

# Strong signals when BOP and volume align
if current_bop > 0.7 && current_volume > avg_volume * 1.5
  puts <<~STRONG_SIGNAL
    Strong Bullish Signal
    BOP: #{current_bop.round(3)} (strong buying pressure)
    Volume: #{current_volume} (#{((current_volume / avg_volume - 1) * 100).round(1)}% above average)
    Interpretation: High conviction buying
    Action: Strong buy signal
  STRONG_SIGNAL
elsif current_bop < -0.7 && current_volume > avg_volume * 1.5
  puts <<~STRONG_SIGNAL
    Strong Bearish Signal
    BOP: #{current_bop.round(3)} (strong selling pressure)
    Volume: #{current_volume} (#{((current_volume / avg_volume - 1) * 100).round(1)}% above average)
    Interpretation: High conviction selling
    Action: Strong sell signal
  STRONG_SIGNAL
elsif current_bop.abs > 0.7 && current_volume < avg_volume * 0.7
  puts <<~WEAK_SIGNAL
    Questionable Signal
    BOP: #{current_bop.round(3)} (extreme reading)
    Volume: #{current_volume} (#{((1 - current_volume / avg_volume) * 100).round(1)}% below average)
    Interpretation: Weak conviction, likely false signal
    Action: Wait for volume confirmation
  WEAK_SIGNAL
end
```

## Advanced Techniques

### 1. BOP Moving Average
Smooth BOP with a moving average to filter noise:

```ruby
bop = SQA::TAI.bop(open: opens, high: highs, low: lows, close: closes)
bop_sma = SQA::TAI.sma(bop.compact, period: 10)

# Trade when BOP crosses its moving average
if bop[-2] < bop_sma[-2] && bop[-1] > bop_sma[-1]
  puts "BOP crossed above MA - Bullish crossover"
elsif bop[-2] > bop_sma[-2] && bop[-1] < bop_sma[-1]
  puts "BOP crossed below MA - Bearish crossover"
end
```

### 2. BOP Histogram
Track changes in BOP momentum:

```ruby
bop = SQA::TAI.bop(open: opens, high: highs, low: lows, close: closes)

# Calculate BOP change
bop_change = bop.each_cons(2).map { |a, b| b - a }

if bop_change.last > 0.3
  puts "Rapid increase in buying pressure"
elsif bop_change.last < -0.3
  puts "Rapid increase in selling pressure"
end
```

### 3. BOP Zones
Define action zones based on BOP levels:

```ruby
current_bop = bop.last

action = case current_bop
  when 0.8..1.0   then "Accumulation zone - strong hands buying"
  when 0.5...0.8  then "Bullish zone - buyers in control"
  when 0.2...0.5  then "Neutral bullish - weak buying"
  when -0.2...0.2 then "Equilibrium - wait for breakout"
  when -0.5...-0.2 then "Neutral bearish - weak selling"
  when -0.8...-0.5 then "Bearish zone - sellers in control"
  when -1.0...-0.8 then "Capitulation zone - panic selling"
  end

puts "Current BOP Zone: #{action}"
```

## Trading Strategies

### Strategy 1: BOP Breakout
Enter when BOP breaks above/below key levels:

```ruby
# Buy when BOP crosses above 0 after being negative
if bop[-2] < 0 && bop[-1] > 0
  puts "BOP breakout - Buyers taking control"
end

# Sell when BOP crosses below 0 after being positive
if bop[-2] > 0 && bop[-1] < 0
  puts "BOP breakdown - Sellers taking control"
end
```

### Strategy 2: Extreme BOP Reversal
Fade extreme readings:

```ruby
# When BOP is extremely negative, look for bounce
if bop.last < -0.85
  puts "Extreme selling pressure - potential bounce candidate"
end

# When BOP is extremely positive, look for pullback
if bop.last > 0.85
  puts "Extreme buying pressure - potential pullback candidate"
end
```

### Strategy 3: BOP Trend Following
Follow persistent BOP direction:

```ruby
recent_bop = bop[-5..-1]

if recent_bop.all? { |v| v > 0.4 }
  puts "Consistent buying pressure - uptrend intact"
elsif recent_bop.all? { |v| v < -0.4 }
  puts "Consistent selling pressure - downtrend intact"
end
```

## Limitations

1. **Range Dependency**: BOP requires sufficient intraday range (High - Low). Small ranges can produce unreliable readings.

2. **Gap Sensitivity**: Large gaps between close and next open can cause BOP to miss important market sentiment.

3. **No Time Component**: BOP treats all price movement equally regardless of when it occurred during the period.

4. **Normalization**: BOP normalizes to range, which can hide absolute volatility differences.

## Best Practices

1. **Combine with Price Action**: Use BOP to confirm what price is telling you, not as standalone signal.

2. **Watch for Divergences**: Most powerful when BOP diverges from price direction.

3. **Use Multiple Timeframes**: Align BOP readings across different timeframes for stronger signals.

4. **Volume Confirmation**: High BOP readings with high volume are more reliable than low volume signals.

5. **Trend Context**: BOP works best in trending markets; can give false signals in choppy conditions.

## Related Indicators

- [RSI](rsi.md) - Momentum oscillator for overbought/oversold
- [MFI](mfi.md) - Money Flow Index combines price and volume
- [ADX](adx.md) - Trend strength measurement
- [OBV](../volume/obv.md) - On Balance Volume for volume analysis

## See Also

- [Back to Indicators](../index.md)
- [Momentum Indicators Overview](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
