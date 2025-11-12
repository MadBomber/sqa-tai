# Linear Regression Intercept (LINEARREG_INTERCEPT)

The Linear Regression Intercept (LINEARREG_INTERCEPT) calculates the Y-intercept (b) of a linear regression line fitted over a specified period. This represents the starting point where the regression trendline crosses the Y-axis, providing the base level from which the trend begins. Combined with the slope, it allows complete reconstruction of the linear regression trendline for price projections and support/resistance identification.

## What It Measures

LINEARREG_INTERCEPT measures:
- **Y-axis Starting Point**: The value where the regression line intersects the Y-axis (when X=0)
- **Base Level**: The theoretical price at the beginning of the regression period
- **Trendline Foundation**: Essential component for constructing the complete trendline equation
- **Support/Resistance Levels**: Historical intercept values can indicate potential price levels

The linear regression line equation is: `Price = Intercept + (Slope × Time)`

## Usage

```ruby
require 'sqa/tai'

prices = [45.50, 46.20, 46.80, 47.10, 47.50,
          48.00, 48.30, 48.70, 49.10, 49.50,
          50.00, 50.40, 50.80, 51.20, 51.60]

# Calculate 14-period linear regression intercept
intercept = SQA::TAI.linearreg_intercept(prices, period: 14)

puts "Current Intercept: #{intercept.last.round(2)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prices` | Array<Float> | Yes | - | Array of price values (typically closing prices) |
| `period` | Integer | No | 14 | Lookback period for regression calculation |

## Returns

Returns an array of intercept values. The first `period - 1` values will be `nil` since insufficient data exists for calculation.

## Interpretation

| Intercept Behavior | Market Interpretation |
|-------------------|----------------------|
| Rising Intercept | Upward shift in base price level, bullish foundation |
| Falling Intercept | Downward shift in base price level, bearish foundation |
| Stable Intercept | Consistent base level, sideways trend foundation |
| High vs Price | Price trading below trendline, potential support |
| Low vs Price | Price trading above trendline, potential resistance |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

### Key Concepts

1. **Trendline Construction**: Intercept + Slope define the complete trendline
2. **Base Level Shift**: Changes in intercept show shifts in trend foundation
3. **Support/Resistance**: Historical intercepts mark significant price levels
4. **Price Projection**: Use with slope to forecast future price levels

## Example: Complete Trendline Construction

```ruby
prices = [100.00, 101.50, 102.00, 103.50, 104.00,
          105.50, 106.00, 107.50, 108.00, 109.50,
          110.00, 111.50, 112.00, 113.50, 114.00]

period = 14

# Get all three regression components
intercept = SQA::TAI.linearreg_intercept(prices, period: period)
slope = SQA::TAI.linearreg_slope(prices, period: period)
regression_line = SQA::TAI.linearreg(prices, period: period)

current_intercept = intercept.last
current_slope = slope.last
current_regression = regression_line.last

puts <<~TRENDLINE
  === Complete Trendline Analysis ===
  Intercept (b): #{current_intercept.round(2)}
  Slope (m): #{current_slope.round(4)}
  Current Regression Value: #{current_regression.round(2)}

  Trendline Equation: Price = #{current_intercept.round(2)} + (#{current_slope.round(4)} × Time)

  Price Projections:
  - Next period: #{(current_intercept + (current_slope * period)).round(2)}
  - 2 periods ahead: #{(current_intercept + (current_slope * (period + 1))).round(2)}
  - 3 periods ahead: #{(current_intercept + (current_slope * (period + 2))).round(2)}
TRENDLINE
```

## Example: Support/Resistance from Intercept

```ruby
prices = load_historical_prices('AAPL')

period = 14
intercept = SQA::TAI.linearreg_intercept(prices, period: period)
slope = SQA::TAI.linearreg_slope(prices, period: period)

# Track intercept levels for support/resistance
intercept_levels = intercept.compact.each_cons(5).map do |window|
  window.sum / window.size
end

current_price = prices.last
current_intercept = intercept.last

# Find nearby intercept levels
tolerance = current_price * 0.02  # 2% tolerance

nearby_levels = intercept_levels.select do |level|
  (level - current_price).abs <= tolerance
end

if nearby_levels.any?
  puts <<~SUPPORT_RESISTANCE
    === Support/Resistance Analysis ===
    Current Price: #{current_price.round(2)}
    Current Intercept: #{current_intercept.round(2)}

    Historical Intercept Levels Nearby:
  SUPPORT_RESISTANCE

  nearby_levels.each do |level|
    position = level < current_price ? "Support" : "Resistance"
    distance = ((level - current_price) / current_price * 100).round(2)
    puts "  #{position}: #{level.round(2)} (#{distance}%)"
  end
end
```

## Example: Intercept Shift Detection

```ruby
prices = load_historical_prices('TSLA')

period = 14
intercept = SQA::TAI.linearreg_intercept(prices, period: period)

# Calculate rate of change in intercept
intercept_changes = intercept.compact.each_cons(2).map do |prev, curr|
  ((curr - prev) / prev * 100).round(2)
end

recent_change = intercept_changes.last(5).sum / 5

if recent_change > 0.5
  puts <<~ANALYSIS
    === Intercept Rising ===
    Average Change: +#{recent_change.round(2)}%
    Interpretation: Base level shifting higher, bullish foundation
    Action: Look for uptrend continuation
  ANALYSIS
elsif recent_change < -0.5
  puts <<~ANALYSIS
    === Intercept Falling ===
    Average Change: #{recent_change.round(2)}%
    Interpretation: Base level shifting lower, bearish foundation
    Action: Consider defensive positioning
  ANALYSIS
else
  puts <<~ANALYSIS
    === Intercept Stable ===
    Average Change: #{recent_change.round(2)}%
    Interpretation: Consistent base level
    Action: Monitor for breakout
  ANALYSIS
end
```

## Example: Trendline Channel Construction

```ruby
prices = load_historical_prices('MSFT')
highs = load_historical_highs('MSFT')
lows = load_historical_lows('MSFT')

period = 14

# Calculate regression components for close, high, and low
intercept_close = SQA::TAI.linearreg_intercept(prices, period: period)
slope_close = SQA::TAI.linearreg_slope(prices, period: period)

intercept_high = SQA::TAI.linearreg_intercept(highs, period: period)
slope_high = SQA::TAI.linearreg_slope(highs, period: period)

intercept_low = SQA::TAI.linearreg_intercept(lows, period: period)
slope_low = SQA::TAI.linearreg_slope(lows, period: period)

# Construct channel
current_price = prices.last
current_time = period

# Calculate channel boundaries
upper_channel = intercept_high.last + (slope_high.last * current_time)
middle_line = intercept_close.last + (slope_close.last * current_time)
lower_channel = intercept_low.last + (slope_low.last * current_time)

channel_width = upper_channel - lower_channel
price_position = ((current_price - lower_channel) / channel_width * 100).round(2)

puts <<~CHANNEL
  === Regression Channel ===
  Upper Channel: #{upper_channel.round(2)}
  Middle Line: #{middle_line.round(2)}
  Lower Channel: #{lower_channel.round(2)}

  Channel Width: #{channel_width.round(2)}
  Current Price: #{current_price.round(2)}
  Position in Channel: #{price_position}%

  Trading Signals:
CHANNEL

if price_position > 80
  puts "  - Price near upper channel: Consider taking profits"
elsif price_position < 20
  puts "  - Price near lower channel: Consider buying opportunity"
else
  puts "  - Price in middle range: Wait for better entry"
end
```

## Example: Multi-Period Intercept Analysis

```ruby
prices = load_historical_prices('SPY')

periods = [10, 20, 50]

puts "=== Multi-Period Intercept Analysis ==="

periods.each do |period|
  intercept = SQA::TAI.linearreg_intercept(prices, period: period)
  slope = SQA::TAI.linearreg_slope(prices, period: period)

  current_intercept = intercept.last
  current_slope = slope.last

  # Project current value
  projected_value = current_intercept + (current_slope * period)
  current_price = prices.last

  deviation = ((current_price - projected_value) / projected_value * 100).round(2)

  puts <<~PERIOD_ANALYSIS

    #{period}-Period Analysis:
      Intercept: #{current_intercept.round(2)}
      Slope: #{current_slope.round(4)}
      Projected Value: #{projected_value.round(2)}
      Current Price: #{current_price.round(2)}
      Deviation: #{deviation}%
  PERIOD_ANALYSIS
end

# Analyze trend consistency
intercepts = periods.map do |period|
  SQA::TAI.linearreg_intercept(prices, period: period).last
end

if intercepts.sort == intercepts
  puts "\nAll intercepts rising: Strong uptrend structure"
elsif intercepts.sort.reverse == intercepts
  puts "\nAll intercepts falling: Strong downtrend structure"
else
  puts "\nMixed intercept levels: Trend inconsistency"
end
```

## Example: Intercept with Angle for Trend Strength

```ruby
prices = load_historical_prices('GOOGL')

period = 14
intercept = SQA::TAI.linearreg_intercept(prices, period: period)
slope = SQA::TAI.linearreg_slope(prices, period: period)
angle = SQA::TAI.linearreg_angle(prices, period: period)

current_intercept = intercept.last
current_slope = slope.last
current_angle = angle.last

# Calculate base level change
prev_intercept = intercept[-5]
intercept_change = ((current_intercept - prev_intercept) / prev_intercept * 100).round(2)

puts <<~TREND_STRENGTH
  === Trend Strength Analysis ===
  Base Level (Intercept): #{current_intercept.round(2)}
  Intercept Change (5 periods): #{intercept_change}%

  Trend Slope: #{current_slope.round(4)}
  Trend Angle: #{current_angle.round(2)}°

  Interpretation:
TREND_STRENGTH

case
when current_angle > 45
  puts "  - Very steep uptrend (#{current_angle.round(0)}°)"
  puts "  - Intercept shift: #{intercept_change}%"
  puts "  - Action: Caution on parabolic move, consider profit-taking"
when current_angle > 20
  puts "  - Strong uptrend (#{current_angle.round(0)}°)"
  puts "  - Intercept shift: #{intercept_change}%"
  puts "  - Action: Hold positions, trend is healthy"
when current_angle > 0
  puts "  - Mild uptrend (#{current_angle.round(0)}°)"
  puts "  - Intercept shift: #{intercept_change}%"
  puts "  - Action: Monitor for acceleration"
when current_angle > -20
  puts "  - Mild downtrend (#{current_angle.round(0)}°)"
  puts "  - Intercept shift: #{intercept_change}%"
  puts "  - Action: Consider defensive measures"
when current_angle > -45
  puts "  - Strong downtrend (#{current_angle.round(0)}°)"
  puts "  - Intercept shift: #{intercept_change}%"
  puts "  - Action: Avoid long positions"
else
  puts "  - Very steep downtrend (#{current_angle.round(0)}°)"
  puts "  - Intercept shift: #{intercept_change}%"
  puts "  - Action: Stay in cash or short"
end
```

## Advanced Techniques

### 1. Trendline Equation Construction
Combine intercept with slope to create complete trendline equations:
- `y = intercept + (slope × x)`
- Use for precise price projections
- Calculate expected price at any future period

### 2. Historical Support/Resistance
- Track historical intercept values
- Previous intercepts often act as support/resistance
- Create a map of significant price levels

### 3. Channel Analysis
- Calculate intercepts for high, low, and close prices
- Construct regression channels
- Identify overbought/oversold conditions within channel

### 4. Intercept Divergence
- Compare intercept direction with price direction
- Rising intercepts + falling prices = potential reversal
- Falling intercepts + rising prices = unsustainable rally

### 5. Multi-Timeframe Intercepts
- Calculate intercepts across multiple periods
- Aligned intercepts confirm trend strength
- Diverging intercepts signal trend weakness

## Common Settings

| Period | Use Case | Intercept Sensitivity |
|--------|----------|---------------------|
| 9-10 | Short-term trading | High - rapid base level changes |
| 14 | Standard analysis | Medium - balanced responsiveness |
| 20-21 | Medium-term trends | Lower - smoother base levels |
| 50 | Long-term analysis | Low - major structural changes only |
| 100+ | Macro trends | Very low - fundamental shifts |

## Trading Applications

### Entry Signals
- Price returns to projected trendline (intercept + slope × time)
- Intercept shifts upward after downtrend
- Price finds support at historical intercept level

### Exit Signals
- Price diverges significantly from trendline
- Intercept begins declining during uptrend
- Price breaks through multiple historical intercept levels

### Risk Management
- Use channel width (based on intercepts of high/low) for stop placement
- Monitor intercept stability for trend confidence
- Adjust position size based on intercept change rate

## Limitations and Considerations

1. **Linear Assumption**: Assumes linear relationships, may miss curved trends
2. **Historical Focus**: Based on past data, doesn't predict external shocks
3. **Period Sensitivity**: Different periods yield different intercepts
4. **Component Indicator**: Most useful when combined with slope and angle
5. **Not a Standalone Signal**: Requires confirmation from other indicators

## Related Indicators

- [LINEARREG](linearreg.md) - Complete linear regression line
- [LINEARREG_SLOPE](linearreg_slope.md) - Slope of regression line
- [LINEARREG_ANGLE](linearreg_angle.md) - Angle of regression line
- [TSF](tsf.md) - Time Series Forecast
- [STDDEV](stddev.md) - Standard deviation for channel bands

## See Also

- [Back to Indicators](../index.md)
- [Statistical Indicators Overview](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
