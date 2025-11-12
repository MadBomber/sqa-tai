# Time Series Forecast (TSF)

The Time Series Forecast (TSF) indicator projects where price is expected to be based on linear regression analysis. It extends the linear regression line one period forward, providing a statistical forecast of the next price point. This indicator is valuable for identifying trend direction, setting price targets, and detecting when actual prices deviate significantly from their expected trajectory.

## Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41,
          46.22, 45.64, 46.21, 46.25, 46.08, 46.46,
          46.95, 47.25]

# Calculate 14-period Time Series Forecast
tsf = SQA::TAI.tsf(prices, period: 14)

puts "Current Price: #{prices.last.round(2)}"
puts "TSF Forecast: #{tsf.last.round(2)}"
puts "Deviation: #{(prices.last - tsf.last).round(2)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prices` | Array | Yes | - | Array of price values (typically closing prices) |
| `period` | Integer | No | 14 | Number of periods for linear regression calculation |

## Returns

Returns an array of forecasted price values. Each value represents where the linear regression model expects price to be at that point. The first `period - 1` values will be `nil`.

## What It Measures

TSF measures the **forecasted price** based on:
- **Linear trend**: The consistent directional movement over the period
- **Statistical projection**: Mathematical extension of the regression line
- **Expected value**: Where price "should be" if trend continues

The difference between actual price and TSF indicates:
- **Positive deviation**: Price trading above forecast (bullish)
- **Negative deviation**: Price trading below forecast (bearish)
- **Convergence**: Price returning to expected trajectory

## Interpretation

| Condition | Interpretation | Trading Implication |
|-----------|----------------|---------------------|
| Price > TSF | Bullish deviation | Upward momentum exceeding trend |
| Price < TSF | Bearish deviation | Downward momentum below trend |
| Price crosses above TSF | Bullish signal | Potential trend reversal up |
| Price crosses below TSF | Bearish signal | Potential trend reversal down |
| Widening gap | Acceleration | Strong momentum in direction |
| Narrowing gap | Deceleration | Momentum weakening |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

### Forecast Interpretation

| TSF Pattern | Market Condition |
|-------------|------------------|
| Rising TSF | Uptrend expected to continue |
| Falling TSF | Downtrend expected to continue |
| Flat TSF | Sideways movement expected |
| Steep TSF slope | Strong trend prediction |
| Gradual TSF slope | Weak trend prediction |

## Example: Basic TSF Crossover Strategy

```ruby
prices = load_historical_prices('AAPL')

tsf = SQA::TAI.tsf(prices, period: 14)
current_price = prices.last
forecast = tsf.last
deviation = current_price - forecast

puts <<~HEREDOC
  Current Price: #{current_price.round(2)}
  TSF Forecast: #{forecast.round(2)}
  Deviation: #{deviation.round(2)} (#{((deviation / forecast) * 100).round(2)}%)
HEREDOC

# Trading signals
if current_price > forecast && deviation > (forecast * 0.02)
  puts "Strong BULLISH signal - Price significantly above forecast"
elsif current_price < forecast && deviation.abs > (forecast * 0.02)
  puts "Strong BEARISH signal - Price significantly below forecast"
elsif current_price > forecast
  puts "Mild bullish - Price above forecast"
elsif current_price < forecast
  puts "Mild bearish - Price below forecast"
else
  puts "Price at forecast - No clear signal"
end
```

## Example: TSF Price Target System

```ruby
prices = load_historical_prices('TSLA')

tsf = SQA::TAI.tsf(prices, period: 14)
current_price = prices.last
forecast = tsf.last

# Calculate standard deviation of price from TSF
deviations = []
prices.last(14).each_with_index do |price, i|
  next if tsf[-14 + i].nil?
  deviations << (price - tsf[-14 + i]).abs
end

avg_deviation = deviations.sum / deviations.size
std_dev = Math.sqrt(deviations.map { |d| (d - avg_deviation) ** 2 }.sum / deviations.size)

# Set price targets based on forecast and historical deviation
upper_target_1 = forecast + std_dev
upper_target_2 = forecast + (2 * std_dev)
lower_target_1 = forecast - std_dev
lower_target_2 = forecast - (2 * std_dev)

puts <<~HEREDOC
  TSF Price Target Analysis:
  ===========================
  Current Price: $#{current_price.round(2)}
  TSF Forecast: $#{forecast.round(2)}

  Resistance Targets:
  - Target 1 (1 SD): $#{upper_target_1.round(2)}
  - Target 2 (2 SD): $#{upper_target_2.round(2)}

  Support Targets:
  - Target 1 (1 SD): $#{lower_target_1.round(2)}
  - Target 2 (2 SD): $#{lower_target_2.round(2)}

  Average Deviation: $#{avg_deviation.round(2)}
HEREDOC

# Trading recommendations
if current_price > upper_target_1
  puts "Price extended above forecast - Consider profit taking"
elsif current_price < lower_target_1
  puts "Price extended below forecast - Potential buying opportunity"
elsif current_price > forecast
  puts "Price above forecast with room to run to $#{upper_target_1.round(2)}"
else
  puts "Price below forecast with support at $#{lower_target_1.round(2)}"
end
```

## Example: TSF Trend Following System

```ruby
prices = load_historical_prices('MSFT')

tsf_short = SQA::TAI.tsf(prices, period: 10)
tsf_long = SQA::TAI.tsf(prices, period: 20)

current_price = prices.last
short_forecast = tsf_short.last
long_forecast = tsf_long.last

puts <<~HEREDOC
  TSF Multi-Period Trend Analysis:
  ================================
  Current Price: $#{current_price.round(2)}
  Short TSF (10): $#{short_forecast.round(2)}
  Long TSF (20): $#{long_forecast.round(2)}
HEREDOC

# Trend determination
if short_forecast > long_forecast
  trend = "UPTREND"
  strength = ((short_forecast - long_forecast) / long_forecast * 100).round(2)
  puts "#{trend} - Short TSF above Long TSF by #{strength}%"

  if current_price > short_forecast
    puts "BUY SIGNAL - Price above short-term forecast in uptrend"
  elsif current_price < long_forecast
    puts "Potential trend reversal - Price below long-term forecast"
  end
elsif short_forecast < long_forecast
  trend = "DOWNTREND"
  strength = ((long_forecast - short_forecast) / long_forecast * 100).round(2)
  puts "#{trend} - Short TSF below Long TSF by #{strength}%"

  if current_price < short_forecast
    puts "SELL SIGNAL - Price below short-term forecast in downtrend"
  elsif current_price > long_forecast
    puts "Potential trend reversal - Price above long-term forecast"
  end
else
  puts "SIDEWAYS - Short and Long TSF aligned"
end
```

## Example: TSF Mean Reversion Strategy

```ruby
prices = load_historical_prices('SPY')

tsf = SQA::TAI.tsf(prices, period: 20)

# Calculate recent price deviations from forecast
recent_prices = prices.last(5)
recent_forecasts = tsf.last(5)

current_deviation = ((prices.last - tsf.last) / tsf.last * 100)
avg_recent_deviation = recent_prices.each_with_index.map do |price, i|
  ((price - recent_forecasts[i]) / recent_forecasts[i] * 100)
end.sum / 5

puts <<~HEREDOC
  TSF Mean Reversion Analysis:
  ============================
  Current Price: $#{prices.last.round(2)}
  TSF Forecast: $#{tsf.last.round(2)}
  Current Deviation: #{current_deviation.round(2)}%
  5-Period Avg Deviation: #{avg_recent_deviation.round(2)}%
HEREDOC

# Mean reversion signals
case current_deviation
when 3..Float::INFINITY
  puts "EXTREME OVERBOUGHT - High probability mean reversion SHORT"
  puts "Target: Return to forecast at $#{tsf.last.round(2)}"
when 1.5..3
  puts "Moderately overbought - Watch for reversal signs"
when -1.5..1.5
  puts "Price near forecast - No mean reversion opportunity"
when -3..-1.5
  puts "Moderately oversold - Watch for reversal signs"
when -Float::INFINITY..-3
  puts "EXTREME OVERSOLD - High probability mean reversion LONG"
  puts "Target: Return to forecast at $#{tsf.last.round(2)}"
end

# Momentum check
if current_deviation > avg_recent_deviation + 1
  puts "Deviation accelerating - Momentum trade may continue"
elsif current_deviation < avg_recent_deviation - 1
  puts "Deviation decelerating - Mean reversion likely starting"
end
```

## Example: TSF Channel Breakout

```ruby
prices = load_historical_prices('NVDA')
highs = load_historical_highs('NVDA')
lows = load_historical_lows('NVDA')

tsf = SQA::TAI.tsf(prices, period: 14)

# Create forecast channel using high/low forecasts
tsf_high = SQA::TAI.tsf(highs, period: 14)
tsf_low = SQA::TAI.tsf(lows, period: 14)

current_price = prices.last
forecast = tsf.last
forecast_high = tsf_high.last
forecast_low = tsf_low.last
channel_width = forecast_high - forecast_low

puts <<~HEREDOC
  TSF Channel Breakout Analysis:
  ==============================
  Current Price: $#{current_price.round(2)}
  Forecast Center: $#{forecast.round(2)}
  Forecast High: $#{forecast_high.round(2)}
  Forecast Low: $#{forecast_low.round(2)}
  Channel Width: $#{channel_width.round(2)}
HEREDOC

# Channel position
position_in_channel = ((current_price - forecast_low) / channel_width * 100).round(2)
puts "Channel Position: #{position_in_channel}%"

# Breakout signals
if current_price > forecast_high
  breakout_strength = ((current_price - forecast_high) / forecast_high * 100).round(2)
  puts "BULLISH BREAKOUT - #{breakout_strength}% above forecast channel"
  puts "Upside target: $#{(current_price + channel_width).round(2)}"
elsif current_price < forecast_low
  breakout_strength = ((forecast_low - current_price) / forecast_low * 100).round(2)
  puts "BEARISH BREAKDOWN - #{breakout_strength}% below forecast channel"
  puts "Downside target: $#{(current_price - channel_width).round(2)}"
elsif position_in_channel > 80
  puts "Near upper channel - Potential breakout or reversal"
elsif position_in_channel < 20
  puts "Near lower channel - Potential breakdown or reversal"
else
  puts "Mid-channel - No clear breakout signal"
end
```

## Advanced Techniques

### 1. TSF Slope Analysis
Monitor the rate of change in TSF values to identify trend acceleration or deceleration.

### 2. Multi-Timeframe TSF
Use TSF on different timeframes (daily, weekly) to identify aligned forecasts for higher probability trades.

### 3. TSF with Volume
Confirm TSF signals with volume analysis - high volume on price moves toward TSF suggests strong mean reversion.

### 4. Adaptive Periods
Adjust the TSF period based on market volatility - shorter periods in volatile markets, longer in stable markets.

### 5. TSF Envelope
Create upper and lower bands around TSF (±1-2 standard deviations) for channel trading.

## Example: Complete TSF Trading System

```ruby
class TSFTradingSystem
  attr_reader :prices, :tsf, :position

  def initialize(prices, period: 14, deviation_threshold: 0.02)
    @prices = prices
    @period = period
    @deviation_threshold = deviation_threshold
    @tsf = SQA::TAI.tsf(prices, period: period)
    @position = :flat
  end

  def analyze
    current_price = @prices.last
    forecast = @tsf.last
    prev_price = @prices[-2]
    prev_forecast = @tsf[-2]

    deviation = (current_price - forecast) / forecast
    prev_deviation = (prev_price - prev_forecast) / prev_forecast

    signal = determine_signal(current_price, forecast, deviation, prev_deviation)

    {
      current_price: current_price.round(2),
      forecast: forecast.round(2),
      deviation_pct: (deviation * 100).round(2),
      signal: signal,
      trend: forecast > @tsf[-5] ? 'UP' : 'DOWN',
      strength: calculate_strength(deviation)
    }
  end

  private

  def determine_signal(current, forecast, deviation, prev_deviation)
    # Crossover signals
    if current > forecast && @prices[-2] <= @tsf[-2]
      @position = :long
      return :buy_crossover
    elsif current < forecast && @prices[-2] >= @tsf[-2]
      @position = :short
      return :sell_crossover
    end

    # Extreme deviation signals (mean reversion)
    if deviation > @deviation_threshold * 2
      return :extreme_overbought
    elsif deviation < -@deviation_threshold * 2
      return :extreme_oversold
    end

    # Trend following signals
    if deviation > @deviation_threshold && deviation > prev_deviation
      return :bullish_momentum
    elsif deviation < -@deviation_threshold && deviation < prev_deviation
      return :bearish_momentum
    end

    :neutral
  end

  def calculate_strength(deviation)
    strength = (deviation.abs / @deviation_threshold * 100).round(0)
    strength > 100 ? 100 : strength
  end
end

# Usage
prices = load_historical_prices('AAPL')
system = TSFTradingSystem.new(prices, period: 14, deviation_threshold: 0.015)
analysis = system.analyze

puts <<~HEREDOC
  TSF Trading System Analysis:
  ============================
  Price: $#{analysis[:current_price]}
  Forecast: $#{analysis[:forecast]}
  Deviation: #{analysis[:deviation_pct]}%
  Signal: #{analysis[:signal]}
  Trend: #{analysis[:trend]}
  Strength: #{analysis[:strength]}%
HEREDOC
```

## Common Use Cases

### 1. Trend Following
- Enter long when price crosses above TSF in uptrend
- Enter short when price crosses below TSF in downtrend
- Exit when price crosses back through TSF

### 2. Mean Reversion
- Buy when price drops significantly below TSF
- Sell when price rises significantly above TSF
- Target: Return to TSF forecast level

### 3. Price Targets
- Use TSF as dynamic support/resistance
- Set profit targets based on TSF ± standard deviations
- Adjust stops to TSF levels

### 4. Breakout Confirmation
- Wait for price to break above/below TSF channel
- Use TSF slope to confirm breakout direction
- Higher TSF forecast suggests sustainable breakout

## Common Settings

| Period | Use Case | Sensitivity |
|--------|----------|-------------|
| 5-7 | Day trading | Very high - quick signals |
| 10-14 | Swing trading | High - responsive to changes |
| 20-30 | Position trading | Medium - smoother trends |
| 50+ | Long-term investing | Low - major trends only |

## Tips for Trading

1. **Combine with Trend Indicators**: Use TSF with moving averages to filter signals in trend direction
2. **Volume Confirmation**: Confirm TSF signals with above-average volume
3. **Multiple Periods**: Use 2-3 TSF periods for confluence signals
4. **Risk Management**: Set stops below/above TSF to limit losses
5. **Divergence Trading**: Watch for price making new highs/lows while TSF doesn't

## Advantages

- **Forward-looking**: Projects future price unlike lagging indicators
- **Objective**: Based on statistical calculation, not subjective
- **Trend identification**: Clearly shows expected price trajectory
- **Dynamic levels**: Automatically adjusts to market conditions
- **Mean reversion**: Shows when prices deviate from normal

## Limitations

- **Lagging component**: Based on historical data
- **Trending markets**: Works best in trending conditions
- **Whipsaws**: Can generate false signals in choppy markets
- **No volatility adjustment**: Doesn't account for market volatility changes
- **Linear assumption**: Assumes trend continues linearly

## Related Indicators

- [Linear Regression (LINEARREG)](linearreg.md) - Current regression value
- [Linear Regression Slope (LINEARREG_SLOPE)](linearreg_slope.md) - Trend strength
- [Linear Regression Angle (LINEARREG_ANGLE)](linearreg_angle.md) - Trend angle
- [Standard Deviation (STDDEV)](stddev.md) - Forecast uncertainty

## See Also

- [Back to Indicators](../index.md)
- [Statistical Indicators Overview](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
