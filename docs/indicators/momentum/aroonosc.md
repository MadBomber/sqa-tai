# Aroon Oscillator (AROONOSC)

The Aroon Oscillator is a single-line momentum indicator that measures the difference between Aroon Up and Aroon Down. It simplifies the interpretation of the dual Aroon lines by providing a single oscillator that ranges from -100 to +100, making it easier to identify trend strength and direction.

## Usage

```ruby
require 'sqa/tai'

highs = [48.70, 48.72, 48.90, 48.87, 48.82, 49.05, 49.20, 49.35,
         49.92, 50.19, 50.12, 49.66, 49.88, 50.19, 50.36, 50.57,
         50.65, 50.43, 49.63, 50.33, 50.29, 50.17, 49.32, 48.50,
         48.47, 48.55, 49.42, 49.61, 49.20, 48.94]

lows = [47.79, 48.14, 48.39, 48.37, 48.24, 48.64, 48.94, 49.10,
        49.13, 49.87, 49.20, 48.90, 49.43, 49.73, 49.26, 50.09,
        50.30, 49.21, 48.98, 49.61, 49.20, 49.43, 48.08, 47.64,
        48.09, 47.73, 48.86, 49.17, 48.52, 48.52]

# Calculate 25-period Aroon Oscillator
aroon_osc = SQA::TAI.aroonosc(highs, lows, period: 25)

puts "Current Aroon Oscillator: #{aroon_osc.last.round(2)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `high` | Array | Yes | - | Array of high prices |
| `low` | Array | Yes | - | Array of low prices |
| `period` | Integer | No | 25 | Lookback period for calculations |

## Returns

Returns an array of Aroon Oscillator values ranging from -100 to +100. The first `period` values will be `nil`.

## Formula

```
Aroon Up = ((period - periods since highest high) / period) × 100
Aroon Down = ((period - periods since lowest low) / period) × 100
Aroon Oscillator = Aroon Up - Aroon Down
```

## Understanding Single-Line vs Dual Aroon

### Dual Aroon Lines (AROON)
The traditional Aroon indicator displays two separate lines:
- **Aroon Up**: Measures time since the highest high (0-100)
- **Aroon Down**: Measures time since the lowest low (0-100)

Requires watching two lines and their relationship, making interpretation more complex.

### Single-Line Aroon Oscillator (AROONOSC)
The Aroon Oscillator simplifies this by calculating the difference:
- **Single Line**: Aroon Up minus Aroon Down (-100 to +100)
- **Easier Interpretation**: One line crossing zero instead of two lines crossing each other
- **Clearer Signals**: Positive values indicate uptrend, negative values indicate downtrend

### When to Use Each

**Use Dual Aroon (AROON) when you want to:**
- See the exact strength of both upward and downward movement separately
- Identify when both lines are low (consolidation)
- Analyze the individual behavior of highs and lows
- Get more detailed information about market structure

**Use Aroon Oscillator (AROONOSC) when you want to:**
- Simplify trend direction into a single metric
- Focus on zero-line crossovers for clear signals
- Reduce visual clutter on charts
- Quick assessment of trend strength and direction

## Interpretation

| Value Range | Interpretation |
|-------------|----------------|
| > +50 | Strong uptrend - Aroon Up dominant |
| +20 to +50 | Moderate uptrend - bullish momentum |
| -20 to +20 | No clear trend - consolidation or transition |
| -50 to -20 | Moderate downtrend - bearish momentum |
| < -50 | Strong downtrend - Aroon Down dominant |
| 0 | Neutral - Aroon Up equals Aroon Down |

### Key Signals

- **Zero Line Cross Above**: Bullish signal (Aroon Up > Aroon Down)
- **Zero Line Cross Below**: Bearish signal (Aroon Down > Aroon Up)
- **Extreme Readings**: Values near ±100 indicate very strong trends
- **Oscillation Around Zero**: Suggests ranging or choppy market

## Example: Basic Aroon Oscillator Signals

```ruby
highs = load_historical_highs('AAPL')
lows = load_historical_lows('AAPL')

aroon_osc = SQA::TAI.aroonosc(highs, lows, period: 25)
current_value = aroon_osc.last

case current_value
when 50..100
  puts "Strong Uptrend (#{current_value.round(2)}) - HOLD or BUY dips"
when 20..50
  puts "Moderate Uptrend (#{current_value.round(2)}) - Bullish bias"
when -20..20
  puts "No Clear Trend (#{current_value.round(2)}) - Stay neutral"
when -50..-20
  puts "Moderate Downtrend (#{current_value.round(2)}) - Bearish bias"
when -100..-50
  puts "Strong Downtrend (#{current_value.round(2)}) - Avoid or SHORT"
end
```

## Example: Zero Line Crossover Strategy

```ruby
highs = load_historical_highs('TSLA')
lows = load_historical_lows('TSLA')

aroon_osc = SQA::TAI.aroonosc(highs, lows, period: 25)

# Check for zero line crossovers
if aroon_osc[-2] < 0 && aroon_osc[-1] > 0
  puts "Bullish Crossover - Aroon Oscillator crossed above zero"
  puts "Previous: #{aroon_osc[-2].round(2)}, Current: #{aroon_osc[-1].round(2)}"
  puts "SIGNAL: Potential trend change to uptrend - BUY"
elsif aroon_osc[-2] > 0 && aroon_osc[-1] < 0
  puts "Bearish Crossover - Aroon Oscillator crossed below zero"
  puts "Previous: #{aroon_osc[-2].round(2)}, Current: #{aroon_osc[-1].round(2)}"
  puts "SIGNAL: Potential trend change to downtrend - SELL"
end
```

## Example: Extreme Reading Detection

```ruby
highs = load_historical_highs('MSFT')
lows = load_historical_lows('MSFT')

aroon_osc = SQA::TAI.aroonosc(highs, lows, period: 25)
current = aroon_osc.last

# Extreme readings suggest strong trends
if current > 70
  puts "Extremely strong uptrend (#{current.round(2)})"
  puts "Recent highs being made consistently"
  puts "Strategy: Ride the trend, use trailing stops"
elsif current < -70
  puts "Extremely strong downtrend (#{current.round(2)})"
  puts "Recent lows being made consistently"
  puts "Strategy: Stay out or short with tight stops"
end

# Near zero suggests consolidation
if current.abs < 10
  puts "Weak trend/consolidation (#{current.round(2)})"
  puts "Highs and lows happening at similar times"
  puts "Strategy: Wait for breakout, avoid trending strategies"
end
```

## Example: Divergence Analysis

```ruby
prices = load_historical_prices('NVDA')
highs = load_historical_highs('NVDA')
lows = load_historical_lows('NVDA')

aroon_osc = SQA::TAI.aroonosc(highs, lows, period: 25)

# Find recent price highs
price_high_1_idx = -30
price_high_2_idx = -10
price_high_1 = prices[price_high_1_idx]
price_high_2 = prices[price_high_2_idx]

# Corresponding Aroon Oscillator values
aroon_high_1 = aroon_osc[price_high_1_idx]
aroon_high_2 = aroon_osc[price_high_2_idx]

# Bearish divergence: Price makes higher high, Aroon Osc makes lower high
if price_high_2 > price_high_1 && aroon_high_2 < aroon_high_1
  puts "Bearish Divergence Detected!"
  puts "Price: #{price_high_1.round(2)} -> #{price_high_2.round(2)} (higher high)"
  puts "Aroon Osc: #{aroon_high_1.round(2)} -> #{aroon_high_2.round(2)} (lower high)"
  puts "Warning: Uptrend momentum weakening, potential reversal"
end

# Find recent price lows
price_low_1_idx = -30
price_low_2_idx = -10
price_low_1 = prices[price_low_1_idx]
price_low_2 = prices[price_low_2_idx]

aroon_low_1 = aroon_osc[price_low_1_idx]
aroon_low_2 = aroon_osc[price_low_2_idx]

# Bullish divergence: Price makes lower low, Aroon Osc makes higher low
if price_low_2 < price_low_1 && aroon_low_2 > aroon_low_1
  puts "Bullish Divergence Detected!"
  puts "Price: #{price_low_1.round(2)} -> #{price_low_2.round(2)} (lower low)"
  puts "Aroon Osc: #{aroon_low_1.round(2)} -> #{aroon_low_2.round(2)} (higher low)"
  puts "Opportunity: Downtrend momentum weakening, potential reversal"
end
```

## Example: Trend Strength Filter

```ruby
highs = load_historical_highs('GOOGL')
lows = load_historical_lows('GOOGL')
prices = load_historical_prices('GOOGL')

aroon_osc = SQA::TAI.aroonosc(highs, lows, period: 25)
sma_50 = SQA::TAI.sma(prices, period: 50)

current_price = prices.last
current_aroon = aroon_osc.last

# Only take trades in strong trends
if current_aroon > 50 && current_price > sma_50.last
  puts "Strong uptrend confirmed by both indicators"
  puts "Aroon Oscillator: #{current_aroon.round(2)} (strong up)"
  puts "Price above SMA(50): Trend is healthy"
  puts "Strategy: Look for pullbacks to buy"
elsif current_aroon < -50 && current_price < sma_50.last
  puts "Strong downtrend confirmed by both indicators"
  puts "Aroon Oscillator: #{current_aroon.round(2)} (strong down)"
  puts "Price below SMA(50): Downtrend is healthy"
  puts "Strategy: Avoid longs, consider shorts"
else
  puts "Weak or mixed trend signals"
  puts "Aroon Oscillator: #{current_aroon.round(2)}"
  puts "Strategy: Wait for stronger trend confirmation"
end
```

## Example: Comparing Dual Aroon vs Aroon Oscillator

```ruby
highs = load_historical_highs('AMZN')
lows = load_historical_lows('AMZN')

# Get both versions
aroon_down, aroon_up = SQA::TAI.aroon(highs, lows, period: 25)
aroon_osc = SQA::TAI.aroonosc(highs, lows, period: 25)

puts "=== Current Values ==="
puts "Aroon Up: #{aroon_up.last.round(2)}"
puts "Aroon Down: #{aroon_down.last.round(2)}"
puts "Aroon Oscillator: #{aroon_osc.last.round(2)}"
puts ""

# Verify the relationship
calculated_osc = aroon_up.last - aroon_down.last
puts "Verification: #{aroon_up.last.round(2)} - #{aroon_down.last.round(2)} = #{calculated_osc.round(2)}"
puts "Actual Oscillator: #{aroon_osc.last.round(2)}"
puts ""

# Interpretation comparison
puts "=== Dual Aroon Interpretation ==="
if aroon_up.last > 70 && aroon_down.last < 30
  puts "Aroon Up dominant and high - strong uptrend"
elsif aroon_down.last > 70 && aroon_up.last < 30
  puts "Aroon Down dominant and high - strong downtrend"
elsif aroon_up.last < 30 && aroon_down.last < 30
  puts "Both low - consolidation period"
end

puts ""
puts "=== Aroon Oscillator Interpretation ==="
if aroon_osc.last > 40
  puts "Oscillator above +40 - strong uptrend"
elsif aroon_osc.last < -40
  puts "Oscillator below -40 - strong downtrend"
elsif aroon_osc.last.abs < 20
  puts "Oscillator near zero - weak or no trend"
end
```

## Trading Strategies

### 1. Zero Line Crossover
- **Buy**: When Aroon Oscillator crosses above 0
- **Sell**: When Aroon Oscillator crosses below 0
- **Best for**: Catching trend changes early
- **Risk**: Can generate false signals in choppy markets

### 2. Extreme Reading Strategy
- **Buy**: When Oscillator drops below -70 then rises back above -50
- **Sell**: When Oscillator rises above +70 then falls back below +50
- **Best for**: Identifying exhausted trends and reversals
- **Risk**: Missing the bulk of strong trends

### 3. Sustained Trend Following
- **Buy**: When Oscillator stays above +50 for multiple periods
- **Sell**: When Oscillator stays below -50 for multiple periods
- **Hold**: As long as oscillator remains on the same side
- **Best for**: Riding strong established trends
- **Risk**: Late entries and exits

### 4. Range-Bound Trading
- **Avoid**: When Oscillator oscillates between -30 and +30
- **Wait**: For clear break above +30 or below -30
- **Best for**: Avoiding choppy, directionless markets
- **Risk**: Missing early trend formation

## Common Period Settings

| Period | Sensitivity | Best Use Case |
|--------|-------------|---------------|
| 14 | Very High | Short-term trading, quick trend changes |
| 20 | High | Active trading, swing trading |
| 25 | Standard | Default setting, balanced approach |
| 30 | Medium | Position trading, filtering noise |
| 50 | Low | Long-term trends, major trend changes |

**Note**: Default period of 25 was chosen by the indicator's developer (Tushar Chande) as optimal for detecting trends while minimizing false signals.

## Advantages and Limitations

### Advantages
- **Simplicity**: Single line easier to interpret than dual lines
- **Clear Signals**: Zero line crossovers are unambiguous
- **Trend Identification**: Quickly shows trend strength and direction
- **Oscillator Format**: Fits well with other oscillators on charts
- **No Lag**: Based on actual time periods, not smoothed averages

### Limitations
- **Choppy Markets**: Generates false signals in sideways markets
- **Delayed Extremes**: By definition, needs full period for extreme readings
- **No Price Magnitude**: Only measures time, not size of price moves
- **Requires Dual Arrays**: Needs both high and low data (not just close)
- **Period Sensitivity**: Performance varies significantly with different periods

## Combining with Other Indicators

```ruby
highs = load_historical_highs('META')
lows = load_historical_lows('META')
prices = load_historical_prices('META')

# Aroon Oscillator for trend
aroon_osc = SQA::TAI.aroonosc(highs, lows, period: 25)

# ADX for trend strength
adx = SQA::TAI.adx(highs, lows, prices, period: 14)

# RSI for momentum
rsi = SQA::TAI.rsi(prices, period: 14)

current_aroon = aroon_osc.last
current_adx = adx.last
current_rsi = rsi.last

# Multi-indicator confluence
if current_aroon > 40 && current_adx > 25 && current_rsi < 70
  puts "Strong BUY Setup:"
  puts "  Aroon Osc: #{current_aroon.round(2)} (uptrend)"
  puts "  ADX: #{current_adx.round(2)} (strong trend)"
  puts "  RSI: #{current_rsi.round(2)} (not overbought)"
  puts "All indicators aligned for uptrend"
elsif current_aroon < -40 && current_adx > 25 && current_rsi > 30
  puts "Strong SELL Setup:"
  puts "  Aroon Osc: #{current_aroon.round(2)} (downtrend)"
  puts "  ADX: #{current_adx.round(2)} (strong trend)"
  puts "  RSI: #{current_rsi.round(2)} (not oversold)"
  puts "All indicators aligned for downtrend"
elsif current_aroon.abs < 20 && current_adx < 20
  puts "No Trend Detected:"
  puts "  Aroon Osc: #{current_aroon.round(2)} (neutral)"
  puts "  ADX: #{current_adx.round(2)} (weak trend)"
  puts "Market is consolidating - avoid trending strategies"
end
```

## Related Indicators

- [AROON](aroon.md) - Dual-line version with separate Aroon Up and Down
- [ADX](adx.md) - Alternative trend strength indicator
- [MACD](macd.md) - Another momentum oscillator
- [RSI](rsi.md) - Overbought/oversold momentum indicator

## See Also

- [Back to Indicators](../index.md)
- [Momentum Indicators Overview](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
