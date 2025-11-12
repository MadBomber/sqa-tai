# Linear Regression (LINEARREG)

The Linear Regression indicator calculates the linear regression line (also known as the least squares line or trend line) over a specified period. It represents the expected price value based on the linear trend, providing a statistical forecast of where prices "should" be according to the underlying trend. Unlike moving averages, linear regression gives more weight to recent data through its mathematical formulation and adapts more quickly to changing price trends.

Linear regression is the foundation for many advanced technical indicators and is widely used for trend identification, mean reversion trading, and determining dynamic support and resistance levels.

## Usage

```ruby
require 'sqa/tai'

close_prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
                45.10, 45.42, 45.84, 46.08, 46.03, 46.41,
                46.22, 45.64, 46.21, 46.25, 46.08, 46.46,
                45.90, 46.78, 47.12, 47.45]

# Calculate 14-period linear regression
linreg = SQA::TAI.linearreg(close_prices, period: 14)

puts "Current regression value: #{linreg.last.round(2)}"
puts "Current price: #{close_prices.last.round(2)}"
puts "Deviation: #{(close_prices.last - linreg.last).round(2)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prices` | Array<Float> | Yes | - | Array of price values (typically closing prices) |
| `period` | Integer | No | 14 | Number of periods for regression calculation |

## Returns

Returns an array of linear regression values representing the fitted trend line. The first `period - 1` values will be `nil`.

## Interpretation

| Condition | Interpretation |
|-----------|----------------|
| Price > LinReg | Price is above trend - potential overbought or strong uptrend |
| Price < LinReg | Price is below trend - potential oversold or strong downtrend |
| Price = LinReg | Price is on trend - equilibrium |
| LinReg rising | Uptrend in progress |
| LinReg falling | Downtrend in progress |
| LinReg flat | Sideways/consolidation phase |

### Deviation Analysis
- **Small deviation**: Price is following the trend closely
- **Large deviation**: Price has deviated significantly - mean reversion opportunity
- **Increasing deviation**: Trend acceleration or potential exhaustion
- **Decreasing deviation**: Trend weakening or price returning to trend

## Example: Basic Regression Trading

```ruby
close_prices = load_historical_data('AAPL', field: :close)

linreg = SQA::TAI.linearreg(close_prices, period: 20)

current_price = close_prices.last
current_linreg = linreg.last
deviation = current_price - current_linreg
deviation_pct = (deviation / current_linreg * 100).round(2)

puts "Price: #{current_price.round(2)}"
puts "Linear Regression: #{current_linreg.round(2)}"
puts "Deviation: #{deviation.round(2)} (#{deviation_pct}%)"

# Mean reversion trading
case deviation_pct
when -3..-Float::INFINITY
  puts "Price #{deviation_pct}% below trend - OVERSOLD"
  puts "Mean reversion BUY signal"
when 3..Float::INFINITY
  puts "Price #{deviation_pct}% above trend - OVERBOUGHT"
  puts "Mean reversion SELL signal"
else
  puts "Price near trend line - NEUTRAL"
end

# Trend direction
if linreg.last > linreg[-5]
  puts "Trend: BULLISH (regression line rising)"
elsif linreg.last < linreg[-5]
  puts "Trend: BEARISH (regression line falling)"
else
  puts "Trend: SIDEWAYS (regression line flat)"
end
```

## Example: Linear Regression Channels

```ruby
close_prices = load_historical_data('TSLA', field: :close)
high_prices = load_historical_data('TSLA', field: :high)
low_prices = load_historical_data('TSLA', field: :low)

period = 20
linreg = SQA::TAI.linearreg(close_prices, period: period)

# Calculate channel width using standard deviation
stddev = SQA::TAI.stddev(close_prices, period: period)

# Create upper and lower channel bands
upper_channel = linreg.zip(stddev).map do |lr, sd|
  lr && sd ? lr + (2 * sd) : nil
end

lower_channel = linreg.zip(stddev).map do |lr, sd|
  lr && sd ? lr - (2 * sd) : nil
end

current_price = close_prices.last
current_linreg = linreg.last
current_upper = upper_channel.last
current_lower = lower_channel.last

puts "Linear Regression Channel:"
puts "Upper Band: #{current_upper.round(2)}"
puts "Mid Line (LinReg): #{current_linreg.round(2)}"
puts "Lower Band: #{current_lower.round(2)}"
puts "Current Price: #{current_price.round(2)}"

# Channel trading signals
if current_price >= current_upper
  puts "Price at upper channel - potential SELL"
  puts "Take profits or short opportunity"
elsif current_price <= current_lower
  puts "Price at lower channel - potential BUY"
  puts "Support level reached"
elsif current_price > current_linreg
  puts "Price above mid-line - BULLISH position"
else
  puts "Price below mid-line - BEARISH position"
end

# Channel width indicates volatility
channel_width_pct = ((current_upper - current_lower) / current_linreg * 100).round(2)
puts "Channel width: #{channel_width_pct}%"

if channel_width_pct < 5
  puts "Narrow channel - low volatility, breakout possible"
elsif channel_width_pct > 15
  puts "Wide channel - high volatility, mean reversion likely"
end
```

## Example: Regression Slope Analysis

```ruby
close_prices = load_historical_data('MSFT', field: :close)

# Calculate regression and slope
linreg = SQA::TAI.linearreg(close_prices, period: 20)
linreg_slope = SQA::TAI.linearreg_slope(close_prices, period: 20)

current_linreg = linreg.last
prev_linreg = linreg[-5]
current_slope = linreg_slope.last

# Calculate trend strength
trend_change = ((current_linreg - prev_linreg) / prev_linreg * 100).round(2)

puts "Linear Regression: #{current_linreg.round(2)}"
puts "Regression Slope: #{current_slope.round(4)}"
puts "5-period change: #{trend_change}%"

# Interpret slope
if current_slope > 0.5
  puts "Strong uptrend - slope > 0.5"
  puts "Momentum strategy: Stay long"
elsif current_slope > 0
  puts "Weak uptrend - slope between 0 and 0.5"
  puts "Caution: Trend may be weakening"
elsif current_slope < -0.5
  puts "Strong downtrend - slope < -0.5"
  puts "Momentum strategy: Stay short"
else
  puts "Weak downtrend or sideways - slope between -0.5 and 0"
  puts "Range trading or wait for trend"
end

# Slope direction changes (trend reversals)
prev_slope = linreg_slope[-2]
if current_slope > 0 && prev_slope <= 0
  puts "TREND REVERSAL: Slope crossed above zero"
  puts "Potential trend change to bullish"
elsif current_slope < 0 && prev_slope >= 0
  puts "TREND REVERSAL: Slope crossed below zero"
  puts "Potential trend change to bearish"
end
```

## Example: Mean Reversion Strategy

```ruby
close_prices = load_historical_data('SPY', field: :close)

period = 20
linreg = SQA::TAI.linearreg(close_prices, period: period)
stddev = SQA::TAI.stddev(close_prices, period: period)

# Calculate z-score (standard deviations from regression line)
z_scores = close_prices.zip(linreg, stddev).map do |price, lr, sd|
  if lr && sd && sd > 0
    (price - lr) / sd
  else
    nil
  end
end

current_price = close_prices.last
current_linreg = linreg.last
current_zscore = z_scores.last

puts "Mean Reversion Analysis:"
puts "Price: #{current_price.round(2)}"
puts "Regression: #{current_linreg.round(2)}"
puts "Z-Score: #{current_zscore.round(2)}"

# Z-score based mean reversion
case current_zscore
when -2..-Float::INFINITY
  puts "Extreme oversold (Z < -2) - STRONG BUY"
  puts "Price 2+ standard deviations below trend"
  puts "High probability mean reversion trade"
when -1.5..-2
  puts "Oversold (Z between -2 and -1.5) - BUY signal"
  puts "Good mean reversion opportunity"
when 1.5..2
  puts "Overbought (Z between 1.5 and 2) - SELL signal"
  puts "Good mean reversion opportunity"
when 2..Float::INFINITY
  puts "Extreme overbought (Z > 2) - STRONG SELL"
  puts "Price 2+ standard deviations above trend"
  puts "High probability mean reversion trade"
else
  puts "Near trend (|Z| < 1.5) - NEUTRAL"
  puts "Wait for better entry"
end

# Exit strategy
if current_zscore.abs < 0.5
  puts "EXIT signal: Price returned to trend line"
end

# Position sizing based on z-score
position_size = [(current_zscore.abs - 1.5) * 10, 0].max.round(2)
if position_size > 0
  puts "Suggested position size: #{position_size}% of capital"
end
```

## Example: Trend Following with Regression

```ruby
close_prices = load_historical_data('NVDA', field: :close)

# Multiple timeframe regression
linreg_short = SQA::TAI.linearreg(close_prices, period: 10)
linreg_medium = SQA::TAI.linearreg(close_prices, period: 20)
linreg_long = SQA::TAI.linearreg(close_prices, period: 50)

current_price = close_prices.last
lr_short = linreg_short.last
lr_medium = linreg_medium.last
lr_long = linreg_long.last

puts "Multi-Timeframe Regression Analysis:"
puts "Price: #{current_price.round(2)}"
puts "Short-term (10): #{lr_short.round(2)}"
puts "Medium-term (20): #{lr_medium.round(2)}"
puts "Long-term (50): #{lr_long.round(2)}"

# Trend alignment
if lr_short > lr_medium && lr_medium > lr_long
  puts "STRONG UPTREND: All timeframes aligned bullish"
  puts "Aggressive long position justified"

  if current_price < lr_short
    puts "Price pullback to short-term line - BUY opportunity"
  elsif current_price > lr_short
    puts "Price above short-term line - hold long position"
  end

elsif lr_short < lr_medium && lr_medium < lr_long
  puts "STRONG DOWNTREND: All timeframes aligned bearish"
  puts "Aggressive short position justified"

  if current_price > lr_short
    puts "Price bounce to short-term line - SELL opportunity"
  elsif current_price < lr_short
    puts "Price below short-term line - hold short position"
  end

else
  puts "MIXED SIGNALS: Timeframes not aligned"
  puts "Range trading or reduce position size"

  # Identify specific conflicts
  if lr_short > lr_medium && lr_medium < lr_long
    puts "Short-term bullish, long-term bearish - consolidation"
  elsif lr_short < lr_medium && lr_medium > lr_long
    puts "Short-term bearish, long-term bullish - correction"
  end
end

# Regression convergence/divergence
spread_short_medium = ((lr_short - lr_medium) / lr_medium * 100).round(2)
spread_medium_long = ((lr_medium - lr_long) / lr_long * 100).round(2)

puts "Short/Medium spread: #{spread_short_medium}%"
puts "Medium/Long spread: #{spread_medium_long}%"

if spread_short_medium.abs > 5
  puts "Wide spread indicates strong short-term trend"
elsif spread_short_medium.abs < 1
  puts "Narrow spread indicates consolidation"
end
```

## Example: Breakout Trading with Regression

```ruby
close_prices = load_historical_data('AMZN', field: :close)
high_prices = load_historical_data('AMZN', field: :high)
low_prices = load_historical_data('AMZN', field: :low)
volume = load_historical_data('AMZN', field: :volume)

period = 20
linreg = SQA::TAI.linearreg(close_prices, period: period)
linreg_slope = SQA::TAI.linearreg_slope(close_prices, period: period)

# Calculate how long price has been near regression
lookback = 10
recent_prices = close_prices.last(lookback)
recent_linreg = linreg.last(lookback)

near_line_count = recent_prices.zip(recent_linreg).count do |price, lr|
  ((price - lr).abs / lr * 100) < 2  # Within 2% of regression line
end

consolidation_ratio = (near_line_count.to_f / lookback * 100).round(0)

puts "Breakout Analysis:"
puts "Current Price: #{close_prices.last.round(2)}"
puts "Regression Line: #{linreg.last.round(2)}"
puts "Consolidation: #{consolidation_ratio}% of last #{lookback} periods"

# Detect consolidation
if consolidation_ratio > 70 && linreg_slope.last.abs < 0.1
  puts "CONSOLIDATION DETECTED - breakout imminent"
  puts "Flat regression slope with tight price action"

  # Look for breakout
  recent_high = high_prices.last(period).max
  recent_low = low_prices.last(period).min
  current_high = high_prices.last
  current_low = low_prices.last

  if current_high > recent_high
    puts "UPSIDE BREAKOUT - BUY signal"
    puts "Entry: #{current_high.round(2)}"
    puts "Target: #{(current_high + (current_high - recent_low)).round(2)}"
    puts "Stop: #{linreg.last.round(2)}"

    # Volume confirmation
    avg_volume = volume.last(period).sum / period
    if volume.last > avg_volume * 1.5
      puts "Strong volume confirmation"
    end

  elsif current_low < recent_low
    puts "DOWNSIDE BREAKOUT - SELL signal"
    puts "Entry: #{current_low.round(2)}"
    puts "Target: #{(current_low - (recent_high - current_low)).round(2)}"
    puts "Stop: #{linreg.last.round(2)}"

    if volume.last > avg_volume * 1.5
      puts "Strong volume confirmation"
    end
  else
    puts "No breakout yet - wait for range break"
    puts "Resistance: #{recent_high.round(2)}"
    puts "Support: #{recent_low.round(2)}"
  end

elsif linreg_slope.last.abs > 0.5
  puts "Strong trend in progress - not consolidating"
  puts "Look for pullbacks to regression line instead"
end
```

## Advanced Techniques

### 1. Regression Channels for Volatility
Use the distance between price and regression line to measure volatility:
- Narrowing channel: Volatility contracting (breakout setup)
- Widening channel: Volatility expanding (mean reversion setup)
- Parallel channel: Steady trend

### 2. Multiple Regression Periods
Compare different periods to identify trend structure:
- Short period (10): Immediate trend
- Medium period (20): Primary trend
- Long period (50): Major trend
- All aligned: High conviction trades

### 3. Regression as Dynamic Support/Resistance
The regression line acts as dynamic support in uptrends and resistance in downtrends:
- Price bounces off line: Trend continuation
- Price breaks through line: Trend reversal
- Multiple touches: Strengthens the line

### 4. Regression with Price Action
Combine regression with candlestick patterns:
- Hammer at regression line: Strong buy
- Shooting star at regression line: Strong sell
- Doji at regression line: Indecision/reversal

### 5. Time-Based Projections
Use the regression line to project future prices:
- Extend the line forward for price targets
- Compare actual vs projected: Measure trend strength
- Acceleration/deceleration of trend

## Example: Complete Trading System

```ruby
class RegressionTradingSystem
  def initialize(symbol, period: 20)
    @symbol = symbol
    @period = period
    @position = nil  # :long, :short, or nil
  end

  def analyze
    close_prices = load_historical_data(@symbol, field: :close)

    # Calculate indicators
    linreg = SQA::TAI.linearreg(close_prices, period: @period)
    linreg_slope = SQA::TAI.linearreg_slope(close_prices, period: @period)
    stddev = SQA::TAI.stddev(close_prices, period: @period)

    current_price = close_prices.last
    current_linreg = linreg.last
    current_slope = linreg_slope.last
    current_stddev = stddev.last

    # Calculate metrics
    deviation = current_price - current_linreg
    deviation_pct = (deviation / current_linreg * 100).round(2)
    z_score = current_stddev > 0 ? (deviation / current_stddev).round(2) : 0

    # Trend determination
    trend = if current_slope > 0.3
              :strong_uptrend
            elsif current_slope > 0
              :weak_uptrend
            elsif current_slope < -0.3
              :strong_downtrend
            elsif current_slope < 0
              :weak_downtrend
            else
              :sideways
            end

    puts <<~ANALYSIS
      === #{@symbol} Regression Analysis ===
      Price: #{current_price.round(2)}
      LinReg: #{current_linreg.round(2)}
      Deviation: #{deviation_pct}%
      Z-Score: #{z_score}
      Slope: #{current_slope.round(4)}
      Trend: #{trend}
    ANALYSIS

    # Trading logic
    generate_signals(
      current_price, current_linreg, z_score,
      deviation_pct, trend, current_slope
    )
  end

  def generate_signals(price, linreg, z_score, deviation_pct, trend, slope)
    # Mean reversion in sideways markets
    if trend == :sideways
      if z_score < -1.5 && @position != :long
        puts "MEAN REVERSION BUY: Oversold in sideways market"
        @position = :long
      elsif z_score > 1.5 && @position != :short
        puts "MEAN REVERSION SELL: Overbought in sideways market"
        @position = :short
      elsif z_score.abs < 0.5 && @position
        puts "EXIT: Returned to mean"
        @position = nil
      end

    # Trend following in trending markets
    elsif trend == :strong_uptrend
      if deviation_pct < -2 && @position != :long
        puts "TREND BUY: Pullback to support in uptrend"
        @position = :long
      elsif slope < 0 && @position == :long
        puts "EXIT LONG: Trend reversal"
        @position = nil
      end

    elsif trend == :strong_downtrend
      if deviation_pct > 2 && @position != :short
        puts "TREND SELL: Rally to resistance in downtrend"
        @position = :short
      elsif slope > 0 && @position == :short
        puts "EXIT SHORT: Trend reversal"
        @position = nil
      end

    # Reduced size in weak trends
    elsif [:weak_uptrend, :weak_downtrend].include?(trend)
      puts "WEAK TREND: Reduce position size or wait"
    end

    puts "Current Position: #{@position || 'None'}"
  end
end

# Run the system
system = RegressionTradingSystem.new('AAPL', period: 20)
system.analyze
```

## Common Settings

| Period | Use Case | Characteristics |
|--------|----------|-----------------|
| 10 | Day trading | Very responsive, frequent signals |
| 14 | Standard short-term | Good balance of responsiveness |
| 20 | Swing trading | Most common setting |
| 50 | Position trading | Longer-term trend following |
| 100 | Long-term investing | Major trend identification |

## Advantages

1. **Statistical Foundation**: Based on rigorous mathematical principles
2. **Trend Identification**: Clearly shows underlying trend direction
3. **Mean Reversion**: Quantifies deviations from trend
4. **Predictive**: Projects future price levels
5. **Versatile**: Works in trending and ranging markets
6. **Objective**: Removes emotional decision making
7. **Combinable**: Integrates well with other indicators

## Limitations

1. **Lagging**: Based on historical data, not predictive
2. **Trend Changes**: Slow to adapt to sudden reversals
3. **Sideways Markets**: Less useful in choppy conditions
4. **Whipsaws**: Can generate false signals in volatile markets
5. **Parameter Sensitive**: Results vary significantly with period choice
6. **Linear Assumption**: Assumes linear relationships (markets aren't always linear)

## Best Practices

1. **Combine with Slope**: Use LINEARREG_SLOPE to confirm trend direction
2. **Use Multiple Timeframes**: Align short and long-term regression
3. **Add Channels**: Create bands using standard deviation
4. **Volume Confirmation**: Confirm breakouts with volume
5. **Risk Management**: Always use stops at regression line
6. **Market Conditions**: Switch between mean reversion and trend following
7. **Regular Reoptimization**: Adjust period based on market volatility

## Related Indicators

- [LINEARREG_SLOPE](linearreg_slope.md) - Slope of the regression line
- [LINEARREG_ANGLE](linearreg_angle.md) - Angle of the regression line
- [LINEARREG_INTERCEPT](linearreg_intercept.md) - Y-intercept of regression line
- [TSF](tsf.md) - Time Series Forecast (regression projected forward)
- [STDDEV](stddev.md) - Standard deviation for channel bands
- [CORREL](correl.md) - Correlation coefficient for trend strength

## See Also

- [Back to Indicators](../index.md)
- [Statistical Indicators Overview](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
<!-- TODO: Create example file -->
- Trend Trading Examples
