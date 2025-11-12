# Linear Regression Angle (LINEARREG_ANGLE)

The Linear Regression Angle indicator measures the angle of the linear regression line in degrees. It quantifies the steepness and direction of price trends, providing a numerical measure of trend strength. Values range from -90 to +90 degrees, where steeper angles indicate stronger trends.

## Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41,
          46.22, 45.64, 46.21, 46.25, 46.08, 46.46,
          46.57, 45.95, 46.50, 46.02, 46.55, 47.03]

# Calculate 14-period Linear Regression Angle
angle = SQA::TAI.linearreg_angle(prices, period: 14)

puts "Current angle: #{angle.last.round(2)} degrees"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prices` | Array | Yes | - | Array of price values |
| `period` | Integer | No | 14 | Number of periods for linear regression calculation |

## Returns

Returns an array of angle values in degrees, ranging from -90 to +90. The first `period - 1` values will be `nil`.

## Interpretation

| Angle Range | Trend Direction | Trend Strength | Interpretation |
|-------------|-----------------|----------------|----------------|
| +45 to +90 | Uptrend | Very Strong | Steep upward momentum - strong bull trend |
| +30 to +45 | Uptrend | Strong | Sustained upward momentum |
| +15 to +30 | Uptrend | Moderate | Gentle upward trend |
| +5 to +15 | Uptrend | Weak | Slight upward bias |
| -5 to +5 | Sideways | Neutral | Flat/consolidating market |
| -15 to -5 | Downtrend | Weak | Slight downward bias |
| -30 to -15 | Downtrend | Moderate | Gentle downward trend |
| -45 to -30 | Downtrend | Strong | Sustained downward momentum |
| -90 to -45 | Downtrend | Very Strong | Steep downward momentum - strong bear trend |

### Key Insights

- **Positive angles**: Indicate uptrends with steeper angles showing stronger upward momentum
- **Negative angles**: Indicate downtrends with steeper angles showing stronger downward momentum
- **Near 0 degrees** (-5 to +5): Market is moving sideways or consolidating
- **45-degree angle**: Considered the benchmark for a strong, sustainable trend
- **Above 60 degrees**: Extremely steep trend, may be unsustainable
- **Angle flattening**: Momentum is weakening, potential trend exhaustion
- **Angle steepening**: Momentum is accelerating

## Example: Basic Trend Strength Detection

```ruby
prices = load_historical_prices('AAPL')

angle = SQA::TAI.linearreg_angle(prices, period: 14)
current_angle = angle.last

case current_angle
when 45..90
  puts "Very strong uptrend (#{current_angle.round(2)}°) - Strong BUY"
when 30...45
  puts "Strong uptrend (#{current_angle.round(2)}°) - BUY"
when 15...30
  puts "Moderate uptrend (#{current_angle.round(2)}°) - Bullish bias"
when -15...15
  puts "Sideways market (#{current_angle.round(2)}°) - No clear trend"
when -30...-15
  puts "Moderate downtrend (#{current_angle.round(2)}°) - Bearish bias"
when -45...-30
  puts "Strong downtrend (#{current_angle.round(2)}°) - SELL"
when -90...-45
  puts "Very strong downtrend (#{current_angle.round(2)}°) - Strong SELL"
end
```

## Example: Trend Change Detection

```ruby
prices = load_historical_prices('TSLA')

angle = SQA::TAI.linearreg_angle(prices, period: 14)

# Detect trend changes
previous_angle = angle[-2]
current_angle = angle[-1]

# Trend strengthening or weakening
if current_angle > previous_angle && current_angle > 0
  puts "Uptrend strengthening: #{previous_angle.round(2)}° -> #{current_angle.round(2)}°"
elsif current_angle < previous_angle && current_angle < 0
  puts "Downtrend strengthening: #{previous_angle.round(2)}° -> #{current_angle.round(2)}°"
elsif current_angle.abs < previous_angle.abs
  puts "Trend weakening: #{previous_angle.round(2)}° -> #{current_angle.round(2)}°"
end

# Trend reversal detection
if previous_angle > 20 && current_angle < 5
  puts "Uptrend losing momentum - potential reversal signal"
elsif previous_angle < -20 && current_angle > -5
  puts "Downtrend losing momentum - potential reversal signal"
end

# Direction change
if previous_angle > 0 && current_angle < 0
  puts "Trend changed from UP to DOWN"
elsif previous_angle < 0 && current_angle > 0
  puts "Trend changed from DOWN to UP"
end
```

## Example: Angle-Based Entry and Exit Strategy

```ruby
prices = load_historical_prices('MSFT')

angle = SQA::TAI.linearreg_angle(prices, period: 14)
slope = SQA::TAI.linearreg_slope(prices, period: 14)

current_angle = angle.last
previous_angle = angle[-2]

# Entry signals based on angle strength
if current_angle > 30 && previous_angle < 30
  puts "Entering LONG position - angle crossed above 30° threshold"
  puts "Strong uptrend confirmed at #{current_angle.round(2)}°"
elsif current_angle < -30 && previous_angle > -30
  puts "Entering SHORT position - angle crossed below -30° threshold"
  puts "Strong downtrend confirmed at #{current_angle.round(2)}°"
end

# Exit signals based on angle flattening
if current_angle > 0 && current_angle < 15 && previous_angle > 15
  puts "Exiting LONG - uptrend weakening (#{current_angle.round(2)}°)"
elsif current_angle < 0 && current_angle > -15 && previous_angle < -15
  puts "Exiting SHORT - downtrend weakening (#{current_angle.round(2)}°)"
end

# Warning signals
if current_angle > 70
  puts "WARNING: Extremely steep uptrend (#{current_angle.round(2)}°)"
  puts "May be unsustainable - consider taking profits"
elsif current_angle < -70
  puts "WARNING: Extremely steep downtrend (#{current_angle.round(2)}°)"
  puts "May be unsustainable - consider covering shorts"
end
```

## Example: Multiple Period Analysis

```ruby
prices = load_historical_prices('NVDA')

# Compare different timeframes
angle_short = SQA::TAI.linearreg_angle(prices, period: 10)
angle_medium = SQA::TAI.linearreg_angle(prices, period: 20)
angle_long = SQA::TAI.linearreg_angle(prices, period: 50)

puts "Short-term angle (10): #{angle_short.last.round(2)}°"
puts "Medium-term angle (20): #{angle_medium.last.round(2)}°"
puts "Long-term angle (50): #{angle_long.last.round(2)}°"

# All timeframes aligned
if angle_short.last > 30 && angle_medium.last > 25 && angle_long.last > 20
  puts "All timeframes showing strong uptrend - HIGH CONFIDENCE BUY"
elsif angle_short.last < -30 && angle_medium.last < -25 && angle_long.last < -20
  puts "All timeframes showing strong downtrend - HIGH CONFIDENCE SELL"
end

# Divergence between timeframes
if angle_short.last > 30 && angle_long.last < 0
  puts "Short-term bullish but long-term bearish - CAUTION"
elsif angle_short.last < -30 && angle_long.last > 0
  puts "Short-term bearish but long-term bullish - CAUTION"
end
```

## Example: Combining with Linear Regression Slope

```ruby
prices = load_historical_prices('GOOGL')

angle = SQA::TAI.linearreg_angle(prices, period: 14)
slope = SQA::TAI.linearreg_slope(prices, period: 14)
linreg = SQA::TAI.linearreg(prices, period: 14)

current_price = prices.last
current_angle = angle.last
current_slope = slope.last
current_linreg = linreg.last

puts "Current price: $#{current_price.round(2)}"
puts "Linear regression value: $#{current_linreg.round(2)}"
puts "Slope: #{current_slope.round(4)}"
puts "Angle: #{current_angle.round(2)}°"

# Strong trend confirmation
if current_angle > 45 && current_price > current_linreg
  puts "Strong uptrend with price above regression line - STRONG BUY"
  puts "Expected continuation of upward momentum"
elsif current_angle < -45 && current_price < current_linreg
  puts "Strong downtrend with price below regression line - STRONG SELL"
  puts "Expected continuation of downward momentum"
end

# Mean reversion opportunities
if current_angle.abs < 10 && (current_price - current_linreg).abs > (current_price * 0.02)
  if current_price < current_linreg
    puts "Price below regression line in sideways market - potential BUY"
  else
    puts "Price above regression line in sideways market - potential SELL"
  end
end
```

## Example: Angle Histogram for Trend Analysis

```ruby
prices = load_historical_prices('AAPL')

angle = SQA::TAI.linearreg_angle(prices, period: 14)

# Analyze recent angle history
recent_angles = angle.compact.last(20)

# Calculate statistics
avg_angle = recent_angles.sum / recent_angles.size
max_angle = recent_angles.max
min_angle = recent_angles.min

puts "Average angle (last 20): #{avg_angle.round(2)}°"
puts "Max angle: #{max_angle.round(2)}°"
puts "Min angle: #{min_angle.round(2)}°"
puts "Range: #{(max_angle - min_angle).round(2)}°"

# Trend consistency
if recent_angles.all? { |a| a > 20 }
  puts "Consistently strong uptrend"
elsif recent_angles.all? { |a| a < -20 }
  puts "Consistently strong downtrend"
elsif recent_angles.all? { |a| a.abs < 15 }
  puts "Consistently sideways/consolidating"
else
  puts "Mixed trend - no clear consistency"
end

# Volatility in angle
angle_std = Math.sqrt(recent_angles.map { |a| (a - avg_angle)**2 }.sum / recent_angles.size)
puts "Angle standard deviation: #{angle_std.round(2)}°"

if angle_std > 20
  puts "High angle volatility - unstable trend"
elsif angle_std < 5
  puts "Low angle volatility - stable trend"
end
```

## Trading Strategies

### 1. Strong Trend Following
- Enter long when angle crosses above 30°
- Enter short when angle crosses below -30°
- Exit when angle flattens below 15° (long) or above -15° (short)
- Best for trending markets

### 2. Angle Momentum Strategy
- Buy when angle is rising and above 20°
- Sell when angle is falling and below -20°
- Hold positions as long as angle maintains direction
- Add to positions when angle steepens

### 3. Mean Reversion in Sideways Markets
- Trade only when angle is between -10° and +10°
- Buy when price is below regression line
- Sell when price is above regression line
- Exit when angle breaks out of range

### 4. Trend Exhaustion Detection
- Watch for angles above 60° or below -60°
- Reduce position size as angle becomes extreme
- Exit when angle starts to flatten
- Prepare for potential reversal

## Common Period Settings

| Period | Use Case | Sensitivity |
|--------|----------|-------------|
| 7-10 | Short-term trading | High - More responsive, more signals |
| 14 | Standard analysis | Medium - Balanced approach |
| 20-25 | Swing trading | Medium-Low - Smoother trends |
| 50+ | Long-term trends | Low - Very smooth, fewer signals |

## Angle Strength Guidelines

### Uptrend Strength
- **Weak** (5-15°): Gentle rise, be cautious
- **Moderate** (15-30°): Steady uptrend, good for accumulation
- **Strong** (30-45°): Solid uptrend, ideal for trend following
- **Very Strong** (45-60°): Powerful uptrend, monitor for sustainability
- **Extreme** (60-90°): Parabolic move, high risk of reversal

### Downtrend Strength
- **Weak** (-5 to -15°): Gentle decline, be cautious
- **Moderate** (-15 to -30°): Steady downtrend, consider shorts
- **Strong** (-30 to -45°): Solid downtrend, ideal for short selling
- **Very Strong** (-45 to -60°): Powerful downtrend, monitor for bounce
- **Extreme** (-60 to -90°): Capitulation, possible oversold

## Advanced Techniques

### 1. Angle Divergence
Watch for divergence between price and angle:
- Price making higher highs but angle decreasing = bearish divergence
- Price making lower lows but angle increasing = bullish divergence

### 2. Angle Channels
Track the range of angles over time:
- Consistent angle range indicates stable trend
- Expanding angle range indicates increasing volatility
- Contracting angle range indicates consolidation

### 3. Multi-Timeframe Angle Alignment
Strongest signals when angles align across timeframes:
- Daily, weekly, monthly all positive = strong bull market
- Daily, weekly, monthly all negative = strong bear market

## Related Indicators

- [LINEARREG_SLOPE](linearreg_slope.md) - Raw slope value (not in degrees)
- [LINEARREG](linearreg.md) - Linear regression line value
- [LINEARREG_INTERCEPT](linearreg_intercept.md) - Y-intercept of regression line
- [TSF](tsf.md) - Time Series Forecast
- [ADX](../momentum/adx.md) - Trend strength (different method)

## See Also

- [Back to Indicators](../index.md)
- [Statistical Indicators Overview](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
