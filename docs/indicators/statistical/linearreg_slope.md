# Linear Regression Slope (LINEARREG_SLOPE)

The Linear Regression Slope indicator measures the slope (rate of change) of the linear regression line over a specified period. It quantifies the speed and direction of price movement, making it an excellent tool for identifying trend strength, momentum, and potential trend reversals.

## What It Measures

LINEARREG_SLOPE calculates the slope coefficient (rise over run) of the best-fit linear regression line through price data. The slope value represents:

- **Rate of Change**: Points gained or lost per period
- **Trend Direction**: Positive (uptrend) or negative (downtrend)
- **Trend Strength**: Larger absolute values indicate stronger trends
- **Momentum**: Changes in slope indicate acceleration or deceleration

## Usage

```ruby
require 'sqa/tai'

prices = [100.0, 102.5, 104.0, 103.5, 105.0, 107.5,
          109.0, 108.5, 110.0, 112.0, 113.5, 115.0,
          114.5, 116.0, 118.5, 120.0, 119.5, 121.0]

# Calculate 14-period linear regression slope
slope = SQA::TAI.linearreg_slope(prices, period: 14)

puts "Current slope: #{slope.last.round(4)}"
puts "Trend: #{slope.last > 0 ? 'Uptrend' : 'Downtrend'}"
puts "Strength: #{slope.last.abs.round(4)} points/period"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prices` | Array<Float> | Yes | - | Array of price values |
| `period` | Integer | No | 14 | Number of periods for regression calculation |

## Returns

Returns an array of slope values representing the rate of price change per period. The first `period - 1` values will be `nil`. Slope values can be positive (uptrend), negative (downtrend), or near zero (sideways).

## Interpretation

| Slope Value | Interpretation |
|-------------|----------------|
| > 1.0 | Strong uptrend - rapid price increase |
| 0.1 to 1.0 | Moderate uptrend - steady price increase |
| -0.1 to 0.1 | Sideways/neutral - no clear trend |
| -1.0 to -0.1 | Moderate downtrend - steady price decrease |
| < -1.0 | Strong downtrend - rapid price decrease |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

### Key Signals

1. **Slope Direction**:
   - Positive slope: Prices trending upward
   - Negative slope: Prices trending downward
   - Zero slope: Prices moving sideways

2. **Slope Magnitude**:
   - Large absolute value: Strong, consistent trend
   - Small absolute value: Weak or choppy trend
   - Increasing magnitude: Trend acceleration
   - Decreasing magnitude: Trend deceleration

3. **Slope Changes**:
   - Slope crosses from negative to positive: Potential bullish reversal
   - Slope crosses from positive to negative: Potential bearish reversal
   - Slope diverges from price: Potential trend exhaustion

## Example: Basic Slope Trading

```ruby
prices = load_historical_prices('AAPL')

slope = SQA::TAI.linearreg_slope(prices, period: 14)
current_slope = slope.last

# Trend identification and strength
if current_slope > 0.5
  puts "Strong uptrend detected"
  puts "Slope: +#{current_slope.round(4)} points/period"
  puts "Signal: HOLD longs or BUY on pullbacks"
elsif current_slope > 0
  puts "Weak uptrend detected"
  puts "Slope: +#{current_slope.round(4)} points/period"
  puts "Signal: Monitor for strengthening or reversal"
elsif current_slope < -0.5
  puts "Strong downtrend detected"
  puts "Slope: #{current_slope.round(4)} points/period"
  puts "Signal: HOLD shorts or SELL on rallies"
elsif current_slope < 0
  puts "Weak downtrend detected"
  puts "Slope: #{current_slope.round(4)} points/period"
  puts "Signal: Monitor for strengthening or reversal"
else
  puts "Sideways/neutral trend"
  puts "Slope: #{current_slope.round(4)} points/period"
  puts "Signal: Wait for trend development"
end
```

## Example: Slope Reversal Detection

```ruby
prices = load_historical_prices('TSLA')

slope = SQA::TAI.linearreg_slope(prices, period: 14)

# Check for slope reversals
previous_slope = slope[-2]
current_slope = slope.last

if previous_slope.nil? || current_slope.nil?
  puts "Insufficient data"
else
  # Bullish reversal: slope crosses from negative to positive
  if previous_slope < 0 && current_slope > 0
    puts "BULLISH REVERSAL SIGNAL"
    puts "Slope changed from #{previous_slope.round(4)} to #{current_slope.round(4)}"
    puts "Action: Consider LONG entry"
    puts "Strength: #{current_slope > 0.5 ? 'Strong' : 'Weak'}"

  # Bearish reversal: slope crosses from positive to negative
  elsif previous_slope > 0 && current_slope < 0
    puts "BEARISH REVERSAL SIGNAL"
    puts "Slope changed from #{previous_slope.round(4)} to #{current_slope.round(4)}"
    puts "Action: Consider SHORT entry or exit longs"
    puts "Strength: #{current_slope < -0.5 ? 'Strong' : 'Weak'}"

  # Trend acceleration
  elsif current_slope.abs > previous_slope.abs * 1.5
    trend_direction = current_slope > 0 ? "upward" : "downward"
    puts "TREND ACCELERATION"
    puts "#{trend_direction.capitalize} trend is accelerating"
    puts "Slope: #{previous_slope.round(4)} -> #{current_slope.round(4)}"

  # Trend deceleration
  elsif current_slope.abs < previous_slope.abs * 0.5
    trend_direction = current_slope > 0 ? "upward" : "downward"
    puts "TREND DECELERATION WARNING"
    puts "#{trend_direction.capitalize} trend is losing momentum"
    puts "Slope: #{previous_slope.round(4)} -> #{current_slope.round(4)}"
  end
end
```

## Example: Slope Divergence Strategy

```ruby
prices = load_historical_prices('NVDA')

slope = SQA::TAI.linearreg_slope(prices, period: 14)

# Compare recent highs/lows
price_high_1 = prices[-20..-11].max
price_high_2 = prices[-10..-1].max

slope_high_1 = slope[-20..-11].compact.max
slope_high_2 = slope[-10..-1].compact.max

# Bearish divergence: price makes higher high, slope makes lower high
if price_high_2 > price_high_1 && slope_high_2 < slope_high_1
  puts "BEARISH DIVERGENCE DETECTED"
  puts "Price higher high: #{price_high_1} -> #{price_high_2}"
  puts "Slope lower high: #{slope_high_1.round(4)} -> #{slope_high_2.round(4)}"
  puts "Signal: Uptrend losing momentum - potential reversal"
  puts "Action: Consider taking profits or preparing for short"
end

# Check for bullish divergence
price_low_1 = prices[-20..-11].min
price_low_2 = prices[-10..-1].min

slope_low_1 = slope[-20..-11].compact.min
slope_low_2 = slope[-10..-1].compact.min

# Bullish divergence: price makes lower low, slope makes higher low
if price_low_2 < price_low_1 && slope_low_2 > slope_low_1
  puts "BULLISH DIVERGENCE DETECTED"
  puts "Price lower low: #{price_low_1} -> #{price_low_2}"
  puts "Slope higher low: #{slope_low_1.round(4)} -> #{slope_low_2.round(4)}"
  puts "Signal: Downtrend losing momentum - potential reversal"
  puts "Action: Consider bottom fishing or preparing for long"
end
```

## Example: Slope with Trend Filter

```ruby
prices = load_historical_prices('MSFT')

slope = SQA::TAI.linearreg_slope(prices, period: 14)
sma_50 = SQA::TAI.sma(prices, period: 50)
sma_200 = SQA::TAI.sma(prices, period: 200)

current_price = prices.last
current_slope = slope.last

# Determine overall trend
trend = if sma_50.last > sma_200.last
  "uptrend"
elsif sma_50.last < sma_200.last
  "downtrend"
else
  "sideways"
end

puts "Overall trend: #{trend.upcase}"
puts "Current slope: #{current_slope.round(4)}"

# Trading signals aligned with trend
case trend
when "uptrend"
  if current_slope > 0.5
    puts "Strong uptrend confirmed by slope"
    puts "Signal: STRONG BUY - trend acceleration"
  elsif current_slope > 0
    puts "Uptrend intact but weakening"
    puts "Signal: HOLD or add on dips"
  elsif current_slope < 0
    puts "WARNING: Negative slope in uptrend"
    puts "Signal: Possible pullback - wait for confirmation"
  end

when "downtrend"
  if current_slope < -0.5
    puts "Strong downtrend confirmed by slope"
    puts "Signal: STRONG SELL or SHORT"
  elsif current_slope < 0
    puts "Downtrend intact but weakening"
    puts "Signal: HOLD shorts or add on rallies"
  elsif current_slope > 0
    puts "WARNING: Positive slope in downtrend"
    puts "Signal: Possible bounce - wait for confirmation"
  end

when "sideways"
  if current_slope.abs < 0.1
    puts "Sideways trend confirmed by flat slope"
    puts "Signal: Range trading strategy"
  else
    puts "Slope developing: #{current_slope > 0 ? 'bullish' : 'bearish'}"
    puts "Signal: Potential breakout forming"
  end
end
```

## Example: Slope Acceleration Signals

```ruby
prices = load_historical_prices('AMZN')

slope = SQA::TAI.linearreg_slope(prices, period: 14)

# Calculate slope change rate (acceleration)
slope_changes = []
(1...slope.length).each do |i|
  next if slope[i].nil? || slope[i-1].nil?
  slope_changes << slope[i] - slope[i-1]
end

recent_acceleration = slope_changes.last(5).compact

if recent_acceleration.any?
  avg_acceleration = recent_acceleration.sum / recent_acceleration.length

  puts "Current slope: #{slope.last.round(4)}"
  puts "Average acceleration: #{avg_acceleration.round(6)}"

  if avg_acceleration > 0.1
    puts "STRONG ACCELERATION DETECTED"
    puts "Trend is gaining momentum rapidly"
    puts "Signal: Momentum trade opportunity"
    puts "Action: #{slope.last > 0 ? 'BUY breakout' : 'SELL breakdown'}"

  elsif avg_acceleration > 0.01
    puts "Moderate acceleration detected"
    puts "Trend is strengthening"
    puts "Signal: Trend following opportunity"

  elsif avg_acceleration < -0.1
    puts "STRONG DECELERATION DETECTED"
    puts "Trend is losing momentum rapidly"
    puts "Signal: Reversal warning"
    puts "Action: Prepare to exit or reverse position"

  elsif avg_acceleration < -0.01
    puts "Moderate deceleration detected"
    puts "Trend is weakening"
    puts "Signal: Take profits or tighten stops"

  else
    puts "Stable slope - consistent trend"
    puts "Signal: Maintain current strategy"
  end
end
```

## Example: Multi-Period Slope Analysis

```ruby
prices = load_historical_prices('GOOGL')

# Calculate slopes for different periods
slope_short = SQA::TAI.linearreg_slope(prices, period: 7)
slope_medium = SQA::TAI.linearreg_slope(prices, period: 14)
slope_long = SQA::TAI.linearreg_slope(prices, period: 28)

puts "Short-term slope (7): #{slope_short.last.round(4)}"
puts "Medium-term slope (14): #{slope_medium.last.round(4)}"
puts "Long-term slope (28): #{slope_long.last.round(4)}"

# Analyze slope alignment
all_positive = [slope_short.last, slope_medium.last, slope_long.last].all? { |s| s > 0 }
all_negative = [slope_short.last, slope_medium.last, slope_long.last].all? { |s| s < 0 }

if all_positive
  puts "\nALL SLOPES POSITIVE - Strong uptrend"

  if slope_short.last > slope_medium.last && slope_medium.last > slope_long.last
    puts "Accelerating uptrend - slopes increasing"
    puts "Signal: STRONG BUY - momentum building"
  else
    puts "Mixed slope magnitudes"
    puts "Signal: BUY but monitor for changes"
  end

elsif all_negative
  puts "\nALL SLOPES NEGATIVE - Strong downtrend"

  if slope_short.last < slope_medium.last && slope_medium.last < slope_long.last
    puts "Accelerating downtrend - slopes steepening"
    puts "Signal: STRONG SELL - momentum building"
  else
    puts "Mixed slope magnitudes"
    puts "Signal: SELL but monitor for changes"
  end

else
  puts "\nMIXED SLOPES - Conflicting signals"

  if slope_short.last > 0 && slope_medium.last < 0
    puts "Short-term reversal in downtrend"
    puts "Signal: Possible bottom forming"
  elsif slope_short.last < 0 && slope_medium.last > 0
    puts "Short-term reversal in uptrend"
    puts "Signal: Possible top forming"
  end
end
```

## Advanced Techniques

### 1. Slope Bands
Create bands around zero slope to identify trend zones:
- Strong trend: |slope| > 0.5
- Moderate trend: 0.1 < |slope| < 0.5
- Weak/sideways: |slope| < 0.1

### 2. Slope Rate of Change
Monitor how quickly the slope itself is changing to identify:
- Trend acceleration (slope increasing)
- Trend deceleration (slope decreasing)
- Momentum exhaustion (slope rate flattening)

### 3. Slope Support/Resistance
Use historical slope levels as support/resistance:
- Slopes often bounce at previous slope levels
- Slope breakouts signal strong momentum shifts

### 4. Slope Histogram
Convert slope values to histogram format for visual clarity:
- Positive bars: Uptrend strength
- Negative bars: Downtrend strength
- Bar height: Trend intensity

## Example: Complete Slope Trading System

```ruby
class SlopeTradingSystem
  def initialize(prices, short_period: 7, long_period: 21)
    @prices = prices
    @slope_short = SQA::TAI.linearreg_slope(prices, period: short_period)
    @slope_long = SQA::TAI.linearreg_slope(prices, period: long_period)
  end

  def analyze
    short = @slope_short.last
    long = @slope_long.last

    return nil if short.nil? || long.nil?

    # Calculate slope characteristics
    trend_strength = short.abs
    trend_direction = short > 0 ? "bullish" : "bearish"
    alignment = (short > 0 && long > 0) || (short < 0 && long < 0)

    # Generate signals
    signal = generate_signal(short, long, alignment)

    {
      short_slope: short.round(4),
      long_slope: long.round(4),
      trend_direction: trend_direction,
      trend_strength: classify_strength(trend_strength),
      alignment: alignment,
      signal: signal,
      confidence: calculate_confidence(short, long, alignment)
    }
  end

  private

  def generate_signal(short, long, alignment)
    if alignment && short > 0.5
      "STRONG BUY"
    elsif alignment && short > 0
      "BUY"
    elsif alignment && short < -0.5
      "STRONG SELL"
    elsif alignment && short < 0
      "SELL"
    elsif short > 0 && long < 0
      "BULLISH REVERSAL"
    elsif short < 0 && long > 0
      "BEARISH REVERSAL"
    else
      "NEUTRAL"
    end
  end

  def classify_strength(slope_abs)
    case slope_abs
    when 0...0.1 then "weak"
    when 0.1...0.5 then "moderate"
    when 0.5...1.0 then "strong"
    else "very strong"
    end
  end

  def calculate_confidence(short, long, alignment)
    base = alignment ? 0.7 : 0.3
    strength_bonus = [short.abs, 1.0].min * 0.3
    (base + strength_bonus).round(2)
  end
end

# Usage
prices = load_historical_prices('AAPL')
system = SlopeTradingSystem.new(prices)
result = system.analyze

puts <<~ANALYSIS
  === SLOPE TRADING ANALYSIS ===
  Short-term slope: #{result[:short_slope]}
  Long-term slope: #{result[:long_slope]}
  Trend direction: #{result[:trend_direction].upcase}
  Trend strength: #{result[:trend_strength].upcase}
  Slopes aligned: #{result[:alignment] ? 'YES' : 'NO'}

  SIGNAL: #{result[:signal]}
  Confidence: #{(result[:confidence] * 100).round(0)}%
ANALYSIS
```

## Common Settings

| Period | Use Case | Sensitivity |
|--------|----------|-------------|
| 5-7 | Very short-term trading | High - quick signals, more noise |
| 10-14 | Short-term trading (standard) | Moderate - balanced approach |
| 20-25 | Swing trading | Lower - smoother signals |
| 50+ | Position trading | Low - major trend changes only |

## Advantages

- Quantifies trend strength objectively
- Identifies trend acceleration/deceleration
- Easy to interpret (positive/negative/magnitude)
- Works well with other regression indicators
- Excellent for momentum trading
- Less lag than moving averages

## Limitations

- Can be whipsawed in choppy markets
- Absolute slope values depend on price level
- No inherent overbought/oversold levels
- May give false signals in ranging markets
- Requires context (compare to historical slopes)

## Tips for Use

1. **Normalize slopes** by dividing by price for cross-asset comparison
2. **Use multiple periods** to confirm trend across timeframes
3. **Combine with price action** to confirm slope signals
4. **Monitor slope changes** as much as slope values
5. **Set thresholds** based on historical slope distributions
6. **Use divergences** to identify potential reversals early

## Related Indicators

- [LINEARREG](linearreg.md) - Linear regression forecast value
- [LINEARREG_ANGLE](linearreg_angle.md) - Slope expressed as angle in degrees
- [LINEARREG_INTERCEPT](linearreg_intercept.md) - Y-intercept of regression line
- [TSF](tsf.md) - Time Series Forecast (regression + projection)
- [ROC](../momentum/roc.md) - Rate of Change (similar concept)
- [MOM](../momentum/mom.md) - Momentum indicator

## See Also

- [Back to Indicators](../index.md)
- [Statistical Indicators Overview](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
- [Trend Following Strategies](../../examples/trend-following.md)
