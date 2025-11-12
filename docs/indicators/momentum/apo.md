# Absolute Price Oscillator (APO)

The Absolute Price Oscillator (APO) measures the absolute difference between two moving averages of different periods. Unlike its percentage-based cousin (PPO), APO shows the actual point difference, making it particularly useful for comparing price momentum in dollar terms.

## Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41,
          46.22, 45.64, 46.21, 46.25, 46.08, 46.46,
          46.57, 45.95, 46.50, 46.02, 46.55, 47.03,
          47.35, 47.28, 47.61, 48.12, 48.34, 48.21]

# Calculate APO with default settings (12, 26)
apo = SQA::TAI.apo(prices)

puts "Current APO: #{apo.last.round(4)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prices` | Array<Float> | Yes | - | Array of price values |
| `fast_period` | Integer | No | 12 | Fast moving average period |
| `slow_period` | Integer | No | 26 | Slow moving average period |
| `ma_type` | Integer | No | 0 | Moving average type (0=SMA, 1=EMA, etc.) |

## Returns

Returns an array of APO values (unbounded, can be positive or negative). The first `slow_period - 1` values will be `nil`.

## Formula

```
APO = Fast MA - Slow MA

Where:
- Fast MA = Moving Average with fast_period
- Slow MA = Moving Average with slow_period
```

## Interpretation

| APO Value | Interpretation |
|-----------|----------------|
| Positive | Fast MA > Slow MA (bullish momentum) |
| Negative | Fast MA < Slow MA (bearish momentum) |
| Zero crossing up | Potential trend change to bullish |
| Zero crossing down | Potential trend change to bearish |
| Increasing | Momentum strengthening |
| Decreasing | Momentum weakening |

## APO vs PPO

The key difference between APO and PPO:

- **APO**: Absolute difference (Fast MA - Slow MA)
- **PPO**: Percentage difference ((Fast MA - Slow MA) / Slow MA × 100)

**When to use APO:**
- Comparing momentum across the same asset over time
- Absolute price movement matters more than percentage
- Working with lower-priced securities

**When to use PPO:**
- Comparing momentum across different assets
- Different price levels (e.g., $10 stock vs $1000 stock)
- Percentage moves are more relevant

## Example: Basic APO Signals

```ruby
prices = load_historical_prices('AAPL')

apo = SQA::TAI.apo(prices, fast_period: 12, slow_period: 26)
current_apo = apo.last
previous_apo = apo[-2]

# Zero line crossovers
if previous_apo < 0 && current_apo > 0
  puts "APO crossed above zero - Bullish signal"
  puts "Fast MA crossed above Slow MA"
elsif previous_apo > 0 && current_apo < 0
  puts "APO crossed below zero - Bearish signal"
  puts "Fast MA crossed below Slow MA"
end

# Current momentum
if current_apo > 0
  puts "APO: #{current_apo.round(4)} - Bullish momentum"
  puts "Fast MA is #{current_apo.round(2)} points above Slow MA"
else
  puts "APO: #{current_apo.round(4)} - Bearish momentum"
  puts "Fast MA is #{current_apo.abs.round(2)} points below Slow MA"
end
```

## Example: APO Trend Analysis

```ruby
prices = load_historical_prices('TSLA')

apo = SQA::TAI.apo(prices, fast_period: 12, slow_period: 26)

# Analyze recent trend
recent_apo = apo.compact.last(5)

if recent_apo.all? { |v| v > 0 }
  puts "Consistent bullish momentum"
  puts "APO values: #{recent_apo.map { |v| v.round(4) }}"

  if recent_apo[-1] > recent_apo[-2]
    puts "Momentum accelerating (APO rising)"
  else
    puts "Momentum decelerating (APO falling)"
  end
elsif recent_apo.all? { |v| v < 0 }
  puts "Consistent bearish momentum"
  puts "APO values: #{recent_apo.map { |v| v.round(4) }}"

  if recent_apo[-1] < recent_apo[-2]
    puts "Bearish momentum accelerating (APO falling)"
  else
    puts "Bearish momentum decelerating (APO rising)"
  end
else
  puts "Mixed signals - momentum transitioning"
  puts "APO values: #{recent_apo.map { |v| v.round(4) }}"
end
```

## Example: APO Divergence Detection

```ruby
prices = load_historical_prices('MSFT')

apo = SQA::TAI.apo(prices, fast_period: 12, slow_period: 26)

# Find recent price highs
price_high_1_idx = -30 + prices[-30..-15].index(prices[-30..-15].max)
price_high_2_idx = -14 + prices[-14..-1].index(prices[-14..-1].max)

price_high_1 = prices[price_high_1_idx]
price_high_2 = prices[price_high_2_idx]

apo_high_1 = apo[price_high_1_idx]
apo_high_2 = apo[price_high_2_idx]

# Bearish divergence: price makes higher high, APO makes lower high
if price_high_2 > price_high_1 && apo_high_2 < apo_high_1
  puts "Bearish Divergence detected!"
  puts "Price: $#{price_high_1.round(2)} -> $#{price_high_2.round(2)} (higher high)"
  puts "APO: #{apo_high_1.round(4)} -> #{apo_high_2.round(4)} (lower high)"
  puts "Momentum weakening despite higher prices - potential reversal"
end

# Find recent price lows
price_low_1_idx = -30 + prices[-30..-15].index(prices[-30..-15].min)
price_low_2_idx = -14 + prices[-14..-1].index(prices[-14..-1].min)

price_low_1 = prices[price_low_1_idx]
price_low_2 = prices[price_low_2_idx]

apo_low_1 = apo[price_low_1_idx]
apo_low_2 = apo[price_low_2_idx]

# Bullish divergence: price makes lower low, APO makes higher low
if price_low_2 < price_low_1 && apo_low_2 > apo_low_1
  puts "Bullish Divergence detected!"
  puts "Price: $#{price_low_1.round(2)} -> $#{price_low_2.round(2)} (lower low)"
  puts "APO: #{apo_low_1.round(4)} -> #{apo_low_2.round(4)} (higher low)"
  puts "Momentum improving despite lower prices - potential reversal"
end
```

## Example: APO Histogram Analysis

```ruby
prices = load_historical_prices('NVDA')

# Calculate APO with different periods
apo_fast = SQA::TAI.apo(prices, fast_period: 5, slow_period: 13)
apo_standard = SQA::TAI.apo(prices, fast_period: 12, slow_period: 26)
apo_slow = SQA::TAI.apo(prices, fast_period: 19, slow_period: 39)

puts "Fast APO (5,13): #{apo_fast.last.round(4)}"
puts "Standard APO (12,26): #{apo_standard.last.round(4)}"
puts "Slow APO (19,39): #{apo_slow.last.round(4)}"

# When all three agree, signal is stronger
if apo_fast.last > 0 && apo_standard.last > 0 && apo_slow.last > 0
  puts "\nAll timeframes bullish - strong upward momentum"
elsif apo_fast.last < 0 && apo_standard.last < 0 && apo_slow.last < 0
  puts "\nAll timeframes bearish - strong downward momentum"
else
  puts "\nMixed signals across timeframes - transitional period"
end
```

## Example: APO with Absolute Value Comparison

```ruby
prices = load_historical_prices('GOOGL')

apo = SQA::TAI.apo(prices, fast_period: 12, slow_period: 26)

# Analyze absolute magnitude of momentum
recent_apo = apo.compact.last(20)
avg_apo_magnitude = recent_apo.map(&:abs).sum / recent_apo.length
current_magnitude = apo.last.abs

puts "Average APO magnitude (20 periods): #{avg_apo_magnitude.round(4)}"
puts "Current APO magnitude: #{current_magnitude.round(4)}"

if current_magnitude > avg_apo_magnitude * 1.5
  puts "Unusually strong momentum (#{(current_magnitude / avg_apo_magnitude * 100).round(0)}% of average)"
  puts "Direction: #{apo.last > 0 ? 'Bullish' : 'Bearish'}"
elsif current_magnitude < avg_apo_magnitude * 0.5
  puts "Weak momentum (#{(current_magnitude / avg_apo_magnitude * 100).round(0)}% of average)"
  puts "Market may be consolidating"
end
```

## Example: APO Crossover with Confirmation

```ruby
prices = load_historical_prices('AMZN')

apo = SQA::TAI.apo(prices, fast_period: 12, slow_period: 26)

# Look for crossover with momentum confirmation
if apo[-3] < 0 && apo[-2] < 0 && apo[-1] > 0
  puts "APO zero line crossover - Bullish signal"
  puts "APO moved from #{apo[-2].round(4)} to #{apo[-1].round(4)}"

  # Check if momentum is accelerating
  if apo[-1] > apo[-2] + (apo[-2] - apo[-3])
    puts "Accelerating bullish momentum - Strong buy signal"
  else
    puts "Standard bullish crossover - Moderate buy signal"
  end
elsif apo[-3] > 0 && apo[-2] > 0 && apo[-1] < 0
  puts "APO zero line crossover - Bearish signal"
  puts "APO moved from #{apo[-2].round(4)} to #{apo[-1].round(4)}"

  # Check if momentum is accelerating
  if apo[-1] < apo[-2] - (apo[-3] - apo[-2])
    puts "Accelerating bearish momentum - Strong sell signal"
  else
    puts "Standard bearish crossover - Moderate sell signal"
  end
end
```

## Trading Strategies

### 1. Zero Line Crossover
- **Buy**: APO crosses above zero (Fast MA > Slow MA)
- **Sell**: APO crosses below zero (Fast MA < Slow MA)
- Simple and clear trend identification

### 2. Absolute Momentum Strength
- Compare current APO magnitude to historical average
- Larger absolute values indicate stronger trends
- Useful for position sizing

### 3. APO Divergence
- **Bullish**: Price lower low, APO higher low
- **Bearish**: Price higher high, APO lower high
- Signals potential trend reversals

### 4. Multi-Timeframe APO
- Use different period combinations
- Confirm signals when all timeframes align
- Filter false signals

## APO Settings

### Standard Settings (12, 26)
- Default and most widely used
- Based on traditional MACD parameters
- Good for daily charts

### Fast Settings (5, 13)
- More responsive to price changes
- More frequent signals
- Good for short-term trading
- More false signals

### Slow Settings (19, 39)
- Less sensitive to noise
- Fewer but more reliable signals
- Good for long-term trend following

### Custom Settings
Choose periods based on:
- Your trading timeframe
- Asset volatility
- Market conditions

## Combining with Other Indicators

```ruby
prices = load_historical_prices('SPY')

# APO for absolute momentum
apo = SQA::TAI.apo(prices, fast_period: 12, slow_period: 26)

# PPO for percentage momentum (comparison)
ppo = SQA::TAI.ppo(prices, fast_period: 12, slow_period: 26)

# Volume confirmation
volumes = load_historical_volumes('SPY')
obv = SQA::TAI.obv(prices, volumes)

current_price = prices.last

puts "APO: #{apo.last.round(4)} (absolute difference)"
puts "PPO: #{ppo.last.round(4)}% (percentage difference)"

# Strong signal when both agree and volume confirms
if apo.last > 0 && ppo.last > 0 && obv[-1] > obv[-5]
  puts "Strong bullish signal:"
  puts "- Positive absolute momentum (APO > 0)"
  puts "- Positive percentage momentum (PPO > 0)"
  puts "- Rising volume indicator (OBV)"
  puts "High conviction buy opportunity"
end
```

## Advantages and Limitations

### Advantages
- Shows actual point difference between MAs
- Easy to interpret for single asset analysis
- Useful for volatility-based position sizing
- Clear zero-line crossover signals

### Limitations
- Not suitable for comparing different assets
- Scale depends on price level of asset
- Requires confirmation from other indicators
- Can give false signals in ranging markets

## Related Indicators

- [PPO](ppo.md) - Percentage Price Oscillator (percentage-based version)
- [MACD](macd.md) - Similar concept with signal line
- [EMA](../overlap/ema.md) - Used in APO calculation
- [SMA](../overlap/sma.md) - Alternative MA type for APO

## See Also

- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
- [Momentum Trading Example](../../examples/momentum-trading.md)
