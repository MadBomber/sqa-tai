# Rate of Change Ratio 100 Scale (ROCR100)

The Rate of Change Ratio 100 Scale (ROCR100) is a momentum indicator that measures the ratio of the current price to the price n periods ago, multiplied by 100. This scaling makes it more intuitive to read and interpret compared to the standard ROCR. Values are centered around 100, where values above 100 indicate price increases and values below 100 indicate price decreases. The 100-scale format makes it immediately clear whether prices are rising or falling and by what percentage.

## Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83, 45.10, 45.42, 45.84, 46.08, 46.03, 46.41]

# Calculate 10-period ROCR100
rocr100 = SQA::TAI.rocr100(prices, period: 10)

puts "Current ROCR100: #{rocr100.last.round(2)}"

# Values > 100 mean price is up, < 100 mean price is down
if rocr100.last > 100
  percent_change = rocr100.last - 100
  puts "Price is UP #{percent_change.round(2)}% from #{10} periods ago"
elsif rocr100.last < 100
  percent_change = 100 - rocr100.last
  puts "Price is DOWN #{percent_change.round(2)}% from #{10} periods ago"
else
  puts "Price is UNCHANGED from #{10} periods ago"
end
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prices` | Array<Float> | Yes | - | Array of price values |
| `period` | Integer | No | 10 | Lookback period for comparison |

## Returns

Returns an array of ROCR100 values centered around 100. The first `period` values will be `nil`.

## Formula

ROCR100 = (Current Price / Price n periods ago) × 100

Where:
- Current Price = Most recent price
- Price n periods ago = Price from n periods back
- Result is multiplied by 100 for the scaled format

### Calculation Example

```ruby
# Price today: $46.08
# Price 10 days ago: $44.34
# ROCR100 = (46.08 / 44.34) × 100 = 103.92

# This means:
# - Price is 3.92% higher than 10 periods ago
# - Value above 100 indicates upward momentum
```

## Interpretation

| ROCR100 Value | Interpretation |
|---------------|----------------|
| > 110 | Strong upward momentum (10%+ gain) |
| 102-110 | Moderate upward momentum (2-10% gain) |
| 100-102 | Slight upward momentum (0-2% gain) |
| 100 | No change in price |
| 98-100 | Slight downward momentum (0-2% loss) |
| 90-98 | Moderate downward momentum (2-10% loss) |
| < 90 | Strong downward momentum (10%+ loss) |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

### Key Interpretation Points

- **100 is the center line**: Unlike ROCR which centers at 1.0, ROCR100's 100 baseline is more intuitive
- **Direct percentage reading**: ROCR100 of 105 means 5% gain, 95 means 5% loss
- **Easy mental math**: Subtract 100 to get percentage change
- **Momentum strength**: Distance from 100 indicates momentum strength
- **Trend direction**: Rising ROCR100 shows strengthening momentum, falling shows weakening

## The 100-Scale Advantage

### 1. Intuitive Reading
The 100-scale format is significantly more intuitive than the standard ROCR (centered at 1.0):

```ruby
# Standard ROCR vs ROCR100 comparison
prices = [100, 105, 110, 115, 120]

rocr = SQA::TAI.rocr(prices, period: 2)
rocr100 = SQA::TAI.rocr100(prices, period: 2)

# ROCR values (centered at 1.0)
# [nil, nil, 1.05, 1.095, 1.091]
# Harder to interpret: Is 1.05 good? How much change is that?

# ROCR100 values (centered at 100)
# [nil, nil, 105.0, 109.5, 109.1]
# Immediately clear: 5% gain, 9.5% gain, 9.1% gain
```

### 2. Mental Math Simplicity
With ROCR100, calculating percentage change is trivial:

```ruby
rocr100 = SQA::TAI.rocr100(prices, period: 10)
current = rocr100.last

# Simple subtraction gives percentage change
percent_change = current - 100

puts "Price change: #{percent_change.round(2)}%"
# ROCR100 = 107.5 → 7.5% gain
# ROCR100 = 94.3 → 5.7% loss
```

### 3. Better Visualization
The 100 baseline is easier to visualize on charts:

```ruby
# Chart reference levels are more intuitive
rocr100 = SQA::TAI.rocr100(prices, period: 10)

# Common reference levels
puts "Overbought zone (>110):" if rocr100.last > 110
puts "Moderate bullish (100-110):" if rocr100.last.between?(100, 110)
puts "Neutral (98-102):" if rocr100.last.between?(98, 102)
puts "Moderate bearish (90-98):" if rocr100.last.between?(90, 98)
puts "Oversold zone (<90):" if rocr100.last < 90
```

### 4. Easier Threshold Setting
Setting trading thresholds is more natural:

```ruby
prices = load_historical_prices('AAPL')
rocr100 = SQA::TAI.rocr100(prices, period: 10)

# Clear percentage-based thresholds
OVERBOUGHT_THRESHOLD = 110   # 10% gain
OVERSOLD_THRESHOLD = 90      # 10% loss
NEUTRAL_UPPER = 102          # 2% gain
NEUTRAL_LOWER = 98           # 2% loss

case rocr100.last
when (OVERBOUGHT_THRESHOLD..)
  puts "Overbought: #{(rocr100.last - 100).round(2)}% above baseline"
when (...OVERSOLD_THRESHOLD)
  puts "Oversold: #{(100 - rocr100.last).round(2)}% below baseline"
when (NEUTRAL_LOWER..NEUTRAL_UPPER)
  puts "Neutral: Within 2% of baseline"
else
  puts "Trending: #{(rocr100.last - 100).round(2)}% from baseline"
end
```

## Example: Basic Momentum Signals

```ruby
prices = load_historical_prices('AAPL')
rocr100 = SQA::TAI.rocr100(prices, period: 10)

current = rocr100.last
previous = rocr100[-2]

# Crossover signals at 100 (baseline)
if current > 100 && previous <= 100
  puts "BULLISH SIGNAL: ROCR100 crossed above 100"
  puts "Price momentum turning positive"
  puts "Gain: #{(current - 100).round(2)}%"
elsif current < 100 && previous >= 100
  puts "BEARISH SIGNAL: ROCR100 crossed below 100"
  puts "Price momentum turning negative"
  puts "Loss: #{(100 - current).round(2)}%"
end

# Momentum strength
momentum_strength = (current - 100).abs
case momentum_strength
when 0...2
  puts "Weak momentum (#{momentum_strength.round(2)}%)"
when 2...5
  puts "Moderate momentum (#{momentum_strength.round(2)}%)"
when 5...10
  puts "Strong momentum (#{momentum_strength.round(2)}%)"
else
  puts "Extreme momentum (#{momentum_strength.round(2)}%)"
end
```

## Example: Trend Confirmation

```ruby
prices = load_historical_prices('MSFT')
rocr100 = SQA::TAI.rocr100(prices, period: 10)

# Confirm trend strength with ROCR100
current = rocr100.last
recent_avg = rocr100[-5..-1].sum / 5.0

puts "Current ROCR100: #{current.round(2)}"
puts "5-period average: #{recent_avg.round(2)}"

# Sustained momentum above 100
if rocr100[-5..-1].all? { |v| v && v > 100 }
  puts "Strong uptrend: ROCR100 above 100 for 5 periods"
  avg_gain = recent_avg - 100
  puts "Average gain: #{avg_gain.round(2)}%"
elsif rocr100[-5..-1].all? { |v| v && v < 100 }
  puts "Strong downtrend: ROCR100 below 100 for 5 periods"
  avg_loss = 100 - recent_avg
  puts "Average loss: #{avg_loss.round(2)}%"
else
  puts "Mixed momentum: No clear trend"
end

# Accelerating vs decelerating momentum
if current > recent_avg && current > 100
  puts "Momentum accelerating to the upside"
elsif current < recent_avg && current < 100
  puts "Momentum accelerating to the downside"
elsif current < recent_avg && current > 100
  puts "Uptrend but momentum decelerating"
elsif current > recent_avg && current < 100
  puts "Downtrend but momentum decelerating"
end
```

## Example: Overbought/Oversold Conditions

```ruby
prices = load_historical_prices('TSLA')
rocr100_10 = SQA::TAI.rocr100(prices, period: 10)
rocr100_20 = SQA::TAI.rocr100(prices, period: 20)

current_10 = rocr100_10.last
current_20 = rocr100_20.last

puts "10-period ROCR100: #{current_10.round(2)}"
puts "20-period ROCR100: #{current_20.round(2)}"

# Overbought conditions (percentage thresholds)
if current_10 > 110 && current_20 > 105
  puts "OVERBOUGHT across multiple timeframes"
  puts "10-period: #{(current_10 - 100).round(2)}% gain"
  puts "20-period: #{(current_20 - 100).round(2)}% gain"
  puts "Consider taking profits or waiting for pullback"

  # Extreme overbought
  if current_10 > 120
    puts "EXTREME OVERBOUGHT: 20%+ gain in 10 periods"
    puts "High probability of mean reversion"
  end

# Oversold conditions
elsif current_10 < 90 && current_20 < 95
  puts "OVERSOLD across multiple timeframes"
  puts "10-period: #{(100 - current_10).round(2)}% loss"
  puts "20-period: #{(100 - current_20).round(2)}% loss"
  puts "Potential buying opportunity"

  # Extreme oversold
  if current_10 < 80
    puts "EXTREME OVERSOLD: 20%+ loss in 10 periods"
    puts "High probability of bounce"
  end
end
```

## Example: Divergence Detection

```ruby
prices = load_historical_prices('NVDA')
rocr100 = SQA::TAI.rocr100(prices, period: 10)

# Find recent highs
price_high_1 = prices[-20..-10].max
price_high_2 = prices[-9..-1].max

# Find corresponding ROCR100 values
rocr100_high_1 = rocr100[-20..-10].compact.max
rocr100_high_2 = rocr100[-9..-1].compact.max

# Bearish divergence
if price_high_2 > price_high_1 && rocr100_high_2 < rocr100_high_1
  puts "BEARISH DIVERGENCE detected"
  puts "Price: #{price_high_1.round(2)} -> #{price_high_2.round(2)}"
  puts "ROCR100: #{rocr100_high_2.round(2)} -> #{rocr100_high_1.round(2)}"
  puts "Momentum weakening despite higher prices"

  # Calculate divergence magnitude
  price_change = ((price_high_2 / price_high_1 - 1) * 100).round(2)
  momentum_decline = (rocr100_high_2 - rocr100_high_1).round(2)

  puts "Price gained: #{price_change}%"
  puts "Momentum lost: #{momentum_decline.abs} points"
end

# Bullish divergence
price_low_1 = prices[-20..-10].min
price_low_2 = prices[-9..-1].min

rocr100_low_1 = rocr100[-20..-10].compact.min
rocr100_low_2 = rocr100[-9..-1].compact.min

if price_low_2 < price_low_1 && rocr100_low_2 > rocr100_low_1
  puts "BULLISH DIVERGENCE detected"
  puts "Price: #{price_low_1.round(2)} -> #{price_low_2.round(2)}"
  puts "ROCR100: #{rocr100_low_1.round(2)} -> #{rocr100_low_2.round(2)}"
  puts "Momentum strengthening despite lower prices"

  # Calculate divergence magnitude
  price_change = ((1 - price_low_2 / price_low_1) * 100).round(2)
  momentum_gain = (rocr100_low_2 - rocr100_low_1).round(2)

  puts "Price lost: #{price_change}%"
  puts "Momentum gained: #{momentum_gain} points"
end
```

## Example: Multi-Period Analysis

```ruby
prices = load_historical_prices('SPY')

# Calculate multiple timeframes
rocr100_5 = SQA::TAI.rocr100(prices, period: 5)
rocr100_10 = SQA::TAI.rocr100(prices, period: 10)
rocr100_20 = SQA::TAI.rocr100(prices, period: 20)

puts "5-period ROCR100: #{rocr100_5.last.round(2)} (#{(rocr100_5.last - 100).round(2)}%)"
puts "10-period ROCR100: #{rocr100_10.last.round(2)} (#{(rocr100_10.last - 100).round(2)}%)"
puts "20-period ROCR100: #{rocr100_20.last.round(2)} (#{(rocr100_20.last - 100).round(2)}%)"

# All timeframes aligned above 100 = strong bullish
if rocr100_5.last > 100 && rocr100_10.last > 100 && rocr100_20.last > 100
  puts "\nSTRONG BULLISH: All timeframes above 100"
  puts "Short-term momentum: #{(rocr100_5.last - 100).round(2)}%"
  puts "Medium-term momentum: #{(rocr100_10.last - 100).round(2)}%"
  puts "Long-term momentum: #{(rocr100_20.last - 100).round(2)}%"

  # Check if momentum is accelerating
  if rocr100_5.last > rocr100_10.last && rocr100_10.last > rocr100_20.last
    puts "Momentum ACCELERATING across timeframes"
  end

# All timeframes aligned below 100 = strong bearish
elsif rocr100_5.last < 100 && rocr100_10.last < 100 && rocr100_20.last < 100
  puts "\nSTRONG BEARISH: All timeframes below 100"
  puts "Short-term decline: #{(100 - rocr100_5.last).round(2)}%"
  puts "Medium-term decline: #{(100 - rocr100_10.last).round(2)}%"
  puts "Long-term decline: #{(100 - rocr100_20.last).round(2)}%"

  # Check if decline is accelerating
  if rocr100_5.last < rocr100_10.last && rocr100_10.last < rocr100_20.last
    puts "Decline ACCELERATING across timeframes"
  end

# Mixed signals
else
  puts "\nMIXED SIGNALS: Timeframes diverging"

  # Potential reversal patterns
  if rocr100_5.last < 100 && rocr100_20.last > 100
    puts "Short-term pullback in long-term uptrend"
    puts "Potential buying opportunity"
  elsif rocr100_5.last > 100 && rocr100_20.last < 100
    puts "Short-term bounce in long-term downtrend"
    puts "Potential selling opportunity"
  end
end
```

## Example: Trading Strategy with ROCR100

```ruby
prices = load_historical_prices('AAPL')
rocr100 = SQA::TAI.rocr100(prices, period: 10)

# Define thresholds
STRONG_BUY = 90      # 10% decline
BUY = 95             # 5% decline
NEUTRAL_LOW = 98     # 2% decline
NEUTRAL_HIGH = 102   # 2% gain
SELL = 105           # 5% gain
STRONG_SELL = 110    # 10% gain

current = rocr100.last
price = prices.last

case current
when (...STRONG_BUY)
  puts "STRONG BUY SIGNAL at $#{price.round(2)}"
  puts "ROCR100: #{current.round(2)} (#{(100 - current).round(2)}% below baseline)"
  puts "Price down significantly, extreme oversold"

when (STRONG_BUY...BUY)
  puts "BUY SIGNAL at $#{price.round(2)}"
  puts "ROCR100: #{current.round(2)} (#{(100 - current).round(2)}% below baseline)"
  puts "Price declining, oversold condition"

when (BUY...NEUTRAL_LOW)
  puts "Weak sell at $#{price.round(2)}"
  puts "ROCR100: #{current.round(2)} (#{(100 - current).round(2)}% below baseline)"
  puts "Slight decline, approaching neutral"

when (NEUTRAL_LOW..NEUTRAL_HIGH)
  puts "NEUTRAL at $#{price.round(2)}"
  puts "ROCR100: #{current.round(2)} (near baseline)"
  puts "No clear momentum signal"

when (NEUTRAL_HIGH..SELL)
  puts "Weak buy at $#{price.round(2)}"
  puts "ROCR100: #{current.round(2)} (#{(current - 100).round(2)}% above baseline)"
  puts "Slight gain, approaching overbought"

when (SELL..STRONG_SELL)
  puts "SELL SIGNAL at $#{price.round(2)}"
  puts "ROCR100: #{current.round(2)} (#{(current - 100).round(2)}% above baseline)"
  puts "Price advancing, overbought condition"

when (STRONG_SELL..)
  puts "STRONG SELL SIGNAL at $#{price.round(2)}"
  puts "ROCR100: #{current.round(2)} (#{(current - 100).round(2)}% above baseline)"
  puts "Price up significantly, extreme overbought"
end

# Additional context
trend = rocr100[-5..-1].compact
if trend.all? { |v| v > current }
  puts "Warning: Momentum declining"
elsif trend.all? { |v| v < current }
  puts "Note: Momentum building"
end
```

## Common Settings

| Period | Use Case | Typical Range |
|--------|----------|---------------|
| 5 | Very short-term, day trading | 95-105 |
| 10 | Standard, short-term trends | 90-110 |
| 14 | Swing trading | 90-110 |
| 20 | Intermediate trends | 85-115 |
| 30 | Long-term momentum | 80-120 |

## Advanced Techniques

### 1. Rate of Change of ROCR100
Monitor how quickly momentum is changing:

```ruby
rocr100 = SQA::TAI.rocr100(prices, period: 10)

# Calculate ROC of ROCR100 itself
roc_of_rocr100 = []
rocr100.each_cons(5) do |window|
  if window.all?
    change = window.last - window.first
    roc_of_rocr100 << change
  end
end

if roc_of_rocr100.last > 2
  puts "Momentum accelerating rapidly"
elsif roc_of_rocr100.last < -2
  puts "Momentum decelerating rapidly"
end
```

### 2. ROCR100 Bands
Create bands around 100 for trading zones:

```ruby
# Calculate average distance from 100
deviations = rocr100.compact.map { |v| (v - 100).abs }
avg_deviation = deviations.sum / deviations.length

upper_band = 100 + avg_deviation
lower_band = 100 - avg_deviation

puts "ROCR100 Bands: #{lower_band.round(2)} - 100 - #{upper_band.round(2)}"
```

### 3. Comparative ROCR100
Compare momentum across different assets:

```ruby
spy_rocr100 = SQA::TAI.rocr100(spy_prices, period: 10)
qqq_rocr100 = SQA::TAI.rocr100(qqq_prices, period: 10)

if spy_rocr100.last > qqq_rocr100.last
  puts "SPY showing stronger momentum than QQQ"
  puts "SPY: #{spy_rocr100.last.round(2)} vs QQQ: #{qqq_rocr100.last.round(2)}"
end
```

## Key Differences from Related Indicators

| Feature | ROCR100 | ROCR | ROC | ROCP |
|---------|---------|------|-----|------|
| Baseline | 100 | 1.0 | 0 | 0 |
| Formula | (P/Pn) × 100 | P/Pn | ((P-Pn)/Pn) × 100 | (P-Pn)/Pn |
| Reading | 105 = 5% gain | 1.05 = 5% gain | 5 = 5% gain | 0.05 = 5% gain |
| Intuitive | Most intuitive | Less intuitive | Intuitive | Least intuitive |
| Best For | General use | Academic | Charts | Calculations |

### Why Choose ROCR100?

1. **Most User-Friendly**: 100 baseline is universally understood
2. **Quick Mental Math**: Simply subtract 100 for percentage
3. **Clear Visualization**: 100 line is obvious reference on charts
4. **Easy Thresholds**: Round numbers (100, 105, 110) are natural
5. **Better Communication**: "ROCR100 is 107" is clearer than "ROCR is 1.07"

## Related Indicators

- [ROC](roc.md) - Rate of Change (percentage)
- [ROCR](rocr.md) - Rate of Change Ratio (ratio format)
- [ROCP](rocp.md) - Rate of Change Percentage (decimal)
- [MOM](mom.md) - Momentum (absolute change)
- [RSI](rsi.md) - Relative Strength Index

## See Also

- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
- [Momentum Indicators Overview](../index.md)
