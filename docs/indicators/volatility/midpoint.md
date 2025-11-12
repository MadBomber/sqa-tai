# Midpoint Over Period (MIDPOINT)

The Midpoint indicator calculates the middle point between the highest and lowest prices over a specified period. It represents a dynamic central value that can act as a mean reversion level and helps identify the balance point of recent price action.

## Usage

```ruby
require 'sqa/tai'

# Basic usage with closing prices
closes = [45.15, 46.26, 46.5, 46.31, 46.89, 47.03, 47.28, 47.79, 48.12, 48.45,
          48.67, 49.05, 49.32, 49.67, 49.89]

# Calculate 14-period midpoint
midpoint = SQA::TAI.midpoint(closes, period: 14)

puts "Current Midpoint: #{midpoint.last.round(2)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prices` | Array<Float> | Yes | - | Array of price values (typically closing prices) |
| `period` | Integer | No | 14 | Number of periods for calculation |

## Returns

Returns an array of midpoint values. The first `period - 1` values will be `nil`.

## Formula

```
MIDPOINT = (Highest Price + Lowest Price) / 2

Where:
  Highest Price = Maximum price over the period
  Lowest Price = Minimum price over the period
```

## Interpretation

### Basic Signals

- **Price Above Midpoint**: Bullish bias - price in upper half of recent range
- **Price Below Midpoint**: Bearish bias - price in lower half of recent range
- **Price at Midpoint**: Equilibrium - indecision or consolidation
- **Midpoint Slope**: Rising suggests uptrend, falling suggests downtrend

### Market Context

The midpoint acts as a:
- **Dynamic Support/Resistance**: Price tends to react at the midpoint level
- **Mean Reversion Target**: Price often returns to midpoint after extremes
- **Range Center**: Identifies the middle of recent price action
- **Fair Value**: Represents balanced price level over the period

### Trading Implications

- **Range Trading**: Trade bounces off midpoint in sideways markets
- **Breakouts**: Strong moves through midpoint can signal trend changes
- **Pullbacks**: Midpoint often acts as pullback target in trends
- **Risk Reference**: Use for stop loss and target placement

## Example: Basic Midpoint Analysis

```ruby
closes = load_price_data('AAPL')

midpoint = SQA::TAI.midpoint(closes, period: 14)
current_price = closes.last
current_midpoint = midpoint.last

# Determine position relative to midpoint
distance = current_price - current_midpoint
distance_pct = (distance / current_midpoint) * 100

puts "Current Price: $#{current_price.round(2)}"
puts "Midpoint: $#{current_midpoint.round(2)}"
puts "Distance: $#{distance.round(2)} (#{distance_pct.round(2)}%)"

if distance_pct > 2
  puts "Price significantly above midpoint - upper range, consider resistance"
elsif distance_pct < -2
  puts "Price significantly below midpoint - lower range, consider support"
else
  puts "Price near midpoint - equilibrium zone"
end
```

## Example: Range Trading with Midpoint

```ruby
closes = load_price_data('MSFT')
highs = load_high_data('MSFT')
lows = load_low_data('MSFT')

period = 20
midpoint = SQA::TAI.midpoint(closes, period: period)

# Calculate range extremes
upper_band = highs.each_with_index.map do |h, i|
  next nil if i < period - 1
  highs[(i-period+1)..i].max
end

lower_band = lows.each_with_index.map do |l, i|
  next nil if i < period - 1
  lows[(i-period+1)..i].min
end

current_price = closes.last
current_mid = midpoint.last
current_upper = upper_band.last
current_lower = lower_band.last

range_size = current_upper - current_lower
position_in_range = (current_price - current_lower) / range_size * 100

puts <<~ANALYSIS
  Range Trading Analysis:
  Upper Band: $#{current_upper.round(2)}
  Midpoint:   $#{current_mid.round(2)}
  Lower Band: $#{current_lower.round(2)}
  Current:    $#{current_price.round(2)}

  Range Size: $#{range_size.round(2)}
  Position: #{position_in_range.round(0)}% of range

  Trading Signal:
ANALYSIS

if position_in_range > 75
  puts "  Near upper extreme - consider selling or waiting for pullback"
elsif position_in_range < 25
  puts "  Near lower extreme - consider buying or waiting for bounce"
elsif position_in_range > 45 && position_in_range < 55
  puts "  At midpoint - neutral zone, watch for direction"
else
  puts "  Mid-range - trend may be developing"
end
```

## Example: Mean Reversion Strategy

```ruby
closes = load_price_data('SPY')

short_period = 10
long_period = 20

midpoint_short = SQA::TAI.midpoint(closes, period: short_period)
midpoint_long = SQA::TAI.midpoint(closes, period: long_period)

current_price = closes.last
short_mid = midpoint_short.last
long_mid = midpoint_long.last

# Calculate distance from both midpoints
short_distance = ((current_price - short_mid) / short_mid) * 100
long_distance = ((current_price - long_mid) / long_mid) * 100

puts <<~REVERSION
  Mean Reversion Analysis:
  Current Price: $#{current_price.round(2)}
  10-period Midpoint: $#{short_mid.round(2)} (#{short_distance.round(2)}% away)
  20-period Midpoint: $#{long_mid.round(2)} (#{long_distance.round(2)}% away)
REVERSION

# Look for mean reversion opportunities
if short_distance > 3 && long_distance > 2
  puts "\nOVERBOUGHT - Price extended above both midpoints"
  puts "Target: Return to $#{short_mid.round(2)} (-#{short_distance.abs.round(1)}%)"
  puts "Stop: Above recent high"

elsif short_distance < -3 && long_distance < -2
  puts "\nOVERSOLD - Price extended below both midpoints"
  puts "Target: Return to $#{short_mid.round(2)} (+#{short_distance.abs.round(1)}%)"
  puts "Stop: Below recent low"

elsif short_distance.abs < 1 && long_distance.abs < 1
  puts "\nEQUILIBRIUM - Price at fair value"
  puts "Wait for extension before entering"
end
```

## Example: Midpoint Breakout System

```ruby
closes = load_price_data('NVDA')
volumes = load_volume_data('NVDA')

period = 14
midpoint = SQA::TAI.midpoint(closes, period: period)

# Track price position relative to midpoint
position_history = closes.each_with_index.map do |price, i|
  next nil if midpoint[i].nil?
  price > midpoint[i] ? 1 : -1  # 1 = above, -1 = below
end

# Detect midpoint crossovers
crossovers = position_history.each_with_index.map do |pos, i|
  next nil if i < 1 || pos.nil? || position_history[i-1].nil?

  if pos == 1 && position_history[i-1] == -1
    :bullish_cross  # Crossed above midpoint
  elsif pos == -1 && position_history[i-1] == 1
    :bearish_cross  # Crossed below midpoint
  else
    :no_cross
  end
end

# Analyze recent crossover
if crossovers.last == :bullish_cross
  avg_volume = volumes[-20..-1].sum / 20.0
  current_volume = volumes.last

  puts "BULLISH MIDPOINT BREAKOUT"
  puts "Price crossed above midpoint: $#{midpoint.last.round(2)}"
  puts "Current price: $#{closes.last.round(2)}"
  puts "Volume: #{current_volume.to_i} (avg: #{avg_volume.to_i})"

  if current_volume > avg_volume * 1.5
    puts "Strong volume confirmation - high probability move"
    puts "Target: Upper range boundary"
    puts "Stop: Below midpoint at $#{(midpoint.last * 0.98).round(2)}"
  else
    puts "Weak volume - wait for confirmation"
  end

elsif crossovers.last == :bearish_cross
  puts "BEARISH MIDPOINT BREAKDOWN"
  puts "Price crossed below midpoint: $#{midpoint.last.round(2)}"
  puts "Current price: $#{closes.last.round(2)}"
  puts "Consider short entry or exit longs"
end
```

## Example: Multi-Timeframe Midpoint Analysis

```ruby
closes = load_price_data('TSLA')

# Calculate midpoints for different timeframes
midpoint_5 = SQA::TAI.midpoint(closes, period: 5)   # Short-term
midpoint_14 = SQA::TAI.midpoint(closes, period: 14)  # Medium-term
midpoint_50 = SQA::TAI.midpoint(closes, period: 50)  # Long-term

current_price = closes.last

# Determine trend alignment
short_position = current_price > midpoint_5.last ? "above" : "below"
medium_position = current_price > midpoint_14.last ? "above" : "below"
long_position = current_price > midpoint_50.last ? "above" : "below"

puts <<~MULTI_TF
  Multi-Timeframe Midpoint Analysis:
  Current Price: $#{current_price.round(2)}

  5-day Midpoint:  $#{midpoint_5.last.round(2)} (#{short_position})
  14-day Midpoint: $#{midpoint_14.last.round(2)} (#{medium_position})
  50-day Midpoint: $#{midpoint_50.last.round(2)} (#{long_position})
MULTI_TF

# Check for alignment
if [short_position, medium_position, long_position].all? { |p| p == "above" }
  puts "\nSTRONG BULLISH ALIGNMENT"
  puts "Price above all timeframe midpoints - strong uptrend"
  puts "Look for pullbacks to higher midpoints as buying opportunities"

elsif [short_position, medium_position, long_position].all? { |p| p == "below" }
  puts "\nSTRONG BEARISH ALIGNMENT"
  puts "Price below all timeframe midpoints - strong downtrend"
  puts "Look for rallies to lower midpoints as selling opportunities"

else
  puts "\nMIXED SIGNALS - Transitional phase"
  puts "Midpoints not aligned - wait for clearer trend"
end
```

## Example: Midpoint as Dynamic Support/Resistance

```ruby
closes = load_price_data('AAPL')
highs = load_high_data('AAPL')
lows = load_low_data('AAPL')

period = 20
midpoint = SQA::TAI.midpoint(closes, period: period)

# Count touches of midpoint
touches = 0
bounces = 0

closes.each_with_index do |price, i|
  next if i < period || midpoint[i].nil?

  mid = midpoint[i]
  tolerance = mid * 0.01  # 1% tolerance

  # Check if price touched midpoint
  if (lows[i] <= mid + tolerance && highs[i] >= mid - tolerance)
    touches += 1

    # Check if it bounced (didn't close far from midpoint)
    if (closes[i] - mid).abs < tolerance
      bounces += 1
    end
  end
end

bounce_rate = touches > 0 ? (bounces.to_f / touches * 100) : 0

puts <<~SUPPORT_RESISTANCE
  Midpoint Support/Resistance Analysis (Last #{period} periods):
  Midpoint Level: $#{midpoint.last.round(2)}
  Times Tested: #{touches}
  Successful Bounces: #{bounces}
  Bounce Rate: #{bounce_rate.round(0)}%

  Current Price: $#{closes.last.round(2)}
SUPPORT_RESISTANCE

if touches > 3 && bounce_rate > 60
  puts "\nMidpoint is STRONG support/resistance"
  puts "High probability of reaction at $#{midpoint.last.round(2)}"
elsif touches > 0
  puts "\nMidpoint shows MODERATE support/resistance"
else
  puts "\nMidpoint not yet tested - significance unknown"
end

# Check current proximity
distance = ((closes.last - midpoint.last) / midpoint.last).abs * 100
if distance < 1
  puts "\nWARNING: Price approaching midpoint - watch for reaction"
end
```

## Example: Midpoint Squeeze Detection

```ruby
closes = load_price_data('BTC')

period = 14
midpoint = SQA::TAI.midpoint(closes, period: period)

# Calculate range width over time
range_width = closes.each_with_index.map do |price, i|
  next nil if i < period - 1

  window = closes[(i-period+1)..i]
  high = window.max
  low = window.min
  (high - low) / midpoint[i] * 100  # Width as % of midpoint
end

# Calculate average range width
avg_width = range_width.compact[-50..-1].sum / 50.0
current_width = range_width.last

compression_ratio = (avg_width - current_width) / avg_width * 100

puts <<~SQUEEZE
  Midpoint Range Analysis:
  Current Range Width: #{current_width.round(2)}%
  50-Period Average: #{avg_width.round(2)}%
  Compression: #{compression_ratio.round(0)}%
SQUEEZE

if compression_ratio > 30
  puts "\nRANGE COMPRESSION DETECTED"
  puts "Price consolidating around midpoint"
  puts "Prepare for potential breakout"
  puts "Watch for volume expansion and directional move"

elsif compression_ratio < -30
  puts "\nRANGE EXPANSION"
  puts "Large price swings - high volatility"
  puts "Trend may be in progress"

else
  puts "\nNORMAL RANGE"
  puts "No significant compression or expansion"
end
```

## Common Uses

### 1. Range Center Identification
```ruby
midpoint = SQA::TAI.midpoint(closes, period: 20)
# Price above midpoint = upper half of range (bullish)
# Price below midpoint = lower half of range (bearish)
```

### 2. Mean Reversion Trading
```ruby
distance_pct = ((price - midpoint.last) / midpoint.last) * 100
# Enter when distance > threshold
# Exit when price returns to midpoint
```

### 3. Dynamic Support/Resistance
```ruby
# Use midpoint as dynamic level for:
# - Stop loss placement
# - Profit targets
# - Entry triggers
```

### 4. Trend Confirmation
```ruby
# Uptrend: Price consistently above midpoint
# Downtrend: Price consistently below midpoint
# Reversal: Price crosses midpoint with volume
```

## Midpoint Period Settings

| Period | Use Case | Characteristics |
|--------|----------|-----------------|
| 5-7 | Intraday/scalping | Very responsive, frequent signals |
| 10-14 | Swing trading | Balanced, standard setting |
| 20-30 | Position trading | Smoother, less noise |
| 50+ | Long-term trends | Very stable, major levels |

## Trading Strategies

### Mean Reversion Strategy
1. Wait for price to extend >3% from midpoint
2. Enter when price starts moving back toward midpoint
3. Target: Return to midpoint
4. Stop: Beyond recent extreme

### Breakout Strategy
1. Identify consolidation around midpoint
2. Wait for decisive break above/below
3. Confirm with volume
4. Enter on breakout, target range size move

### Support/Resistance Strategy
1. Track historical bounces off midpoint
2. Enter when price approaches tested level
3. Use tight stops below/above midpoint
4. Take profits at range extremes

## Advantages

- Simple calculation and interpretation
- Works in all market conditions
- Adapts to current price action
- Useful for both trend and range trading
- Provides objective fair value reference
- Combines well with other indicators

## Limitations

- Lagging indicator (based on historical data)
- No inherent directional bias
- Can whipsaw in choppy markets
- Doesn't account for volume or momentum
- Less effective in strongly trending markets
- Requires price to establish range first

## Combining with Other Indicators

### With Moving Averages
```ruby
midpoint = SQA::TAI.midpoint(closes, period: 14)
sma = SQA::TAI.sma(closes, period: 20)
# Midpoint above SMA = short-term strength
# Midpoint below SMA = short-term weakness
```

### With RSI
```ruby
midpoint = SQA::TAI.midpoint(closes, period: 14)
rsi = SQA::TAI.rsi(closes, period: 14)
# Price at midpoint + RSI extreme = strong reversal signal
```

### With Volume
```ruby
# Breakout through midpoint + high volume = strong signal
# Touch midpoint + low volume = weak bounce
```

## Related Indicators

- [MIDPRICE](midprice.md) - Midpoint using high/low instead of max/min
- [ATR](atr.md) - Measure volatility around midpoint
- [Bollinger Bands](../overlap/bbands.md) - Bands around moving average midpoint
- [Donchian Channels](../overlap/dema.md) - Channel with midpoint line

## See Also

- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
- [Volatility Analysis Example](../../examples/volatility-analysis.md)
