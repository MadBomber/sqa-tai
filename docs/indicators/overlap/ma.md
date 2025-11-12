# MA (Moving Average - Generic Interface)

## Overview

The Generic Moving Average (MA) function is a unified interface that provides access to all eight supported moving average types in SQA::TAI through a single, convenient method. This powerful abstraction eliminates the need to call individual moving average functions, making it easier to switch between different MA types, implement strategies that dynamically select MA algorithms, or compare multiple MA types simultaneously. The MA function is particularly valuable for backtesting systems, adaptive strategies, and educational purposes where understanding the differences between MA types is important.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `input_data` | Array | Required | The price data array (typically close prices) |
| `period` | Integer | 30 | Number of periods for MA calculation |
| `ma_type` | Integer | 0 | Moving average type (0-8, see table below) |

### Parameter Details


**Note**: Array elements should be ordered from oldest to newest (chronological order)

**input_data**
- Typically uses closing prices for standard trend analysis
- Can use other price types for specialized applications
- Requirements vary by MA type selected
- More historical data provides better context

**period** (time_period)
- Default is 30 periods
- Applies to all MA types uniformly
- Common periods:
  - 9-20 periods: Short-term trading
  - 20-50 periods: Medium-term trends
  - 50-200 periods: Long-term trends
- Each MA type interprets the period differently based on its algorithm

**ma_type** (moving_average_type)
- Selects which MA algorithm to use
- Integer values 0-8 correspond to specific MA types
- Each type has different lag, smoothness, and responsiveness characteristics
- See MA Types table below for detailed comparison

### Moving Average Types

| ma_type | Name | Weighting | Lag | Best For |
|---------|------|-----------|-----|----------|
| 0 | [SMA](sma.md) | Equal | High | Basic trend, support/resistance |
| 1 | [EMA](ema.md) | Exponential | Medium | Responsive trend following |
| 2 | [WMA](wma.md) | Linear | Medium | Balance of smoothness |
| 3 | [DEMA](dema.md) | Double Exponential | Low | Reduced lag trading |
| 4 | [TEMA](tema.md) | Triple Exponential | Very Low | Minimal lag, fast signals |
| 5 | [TRIMA](trima.md) | Triangular | Very High | Smoothest, noise reduction |
| 6 | [KAMA](kama.md) | Adaptive | Adaptive | Auto-adjusts to volatility |
| 7 | MAMA | Adaptive | Low | Cycle-adaptive |
| 8 | [T3](t3.md) | Multi-EMA | Low | Smooth with low lag |

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41,
          46.22, 45.64, 46.21, 46.25, 46.08, 46.46,
          46.57, 45.95, 46.50, 46.02, 46.83, 47.21,
          47.55, 47.98, 48.30, 48.67, 49.01, 49.45]

# Calculate a 30-period Simple Moving Average (default)
ma = SQA::TAI.ma(prices, period: 30)

# Calculate a 30-period Exponential Moving Average
ema = SQA::TAI.ma(prices, period: 30, ma_type: 1)

# Calculate a 30-period DEMA
dema = SQA::TAI.ma(prices, period: 30, ma_type: 3)

puts "SMA: #{ma.last.round(2)}"
puts "EMA: #{ema.last.round(2)}"
puts "DEMA: #{dema.last.round(2)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prices` | Array | Yes | - | Array of price values |
| `period` | Integer | No | 30 | Number of periods for calculation |
| `ma_type` | Integer | No | 0 | Moving average type (see table below) |

### Moving Average Types

| ma_type | Name | Description | Best For |
|---------|------|-------------|----------|
| 0 | SMA | Simple Moving Average | Basic trend identification, support/resistance |
| 1 | EMA | Exponential Moving Average | Responsive trend following, recent price emphasis |
| 2 | WMA | Weighted Moving Average | Linear weighting, balance of responsiveness |
| 3 | DEMA | Double Exponential MA | Reduced lag, faster trend signals |
| 4 | TEMA | Triple Exponential MA | Minimal lag, smooth trending |
| 5 | TRIMA | Triangular Moving Average | Smoothest, double-smoothed MA |
| 6 | KAMA | Kaufman Adaptive MA | Auto-adjusts to volatility, smart trending |
| 7 | MAMA | MESA Adaptive MA | Cycle-adaptive, frequency-based |
| 8 | T3 | T3 Moving Average | Very smooth, minimal lag |

## Returns

Returns an array of moving average values. The number of initial `nil` values depends on the MA type and period used.

## Interpretation

Moving averages smooth price data to identify trends:

- **Price above MA**: Bullish trend
- **Price below MA**: Bearish trend
- **MA sloping up**: Uptrend
- **MA sloping down**: Downtrend
- **Price crossing MA**: Potential trend change

## Example: Comparing Multiple MA Types

```ruby
prices = load_historical_prices('AAPL')

# Calculate all MA types with same period
ma_types = {
  'SMA' => 0,
  'EMA' => 1,
  'WMA' => 2,
  'DEMA' => 3,
  'TEMA' => 4,
  'TRIMA' => 5,
  'KAMA' => 6,
  'T3' => 8
}

period = 20
results = {}

ma_types.each do |name, type|
  ma = SQA::TAI.ma(prices, period: period, ma_type: type)
  results[name] = ma.last
  puts "#{name} (#{period}): #{ma.last.round(2)}"
end

# Compare responsiveness
current_price = prices.last
results.each do |name, value|
  diff = ((current_price - value) / value * 100).round(2)
  puts "#{name} distance from price: #{diff}%"
end
```

## Example: Dynamic MA Type Selection

```ruby
prices = load_historical_prices('TSLA')

# Calculate volatility to choose appropriate MA type
atr = SQA::TAI.atr(
  load_historical_data('TSLA', field: :high),
  load_historical_data('TSLA', field: :low),
  prices,
  period: 14
)

current_volatility = atr.last
avg_volatility = atr.compact.sum / atr.compact.size

# Select MA type based on market conditions
ma_type = if current_volatility > avg_volatility * 1.5
  # High volatility - use smoother MA
  5  # TRIMA
elsif current_volatility < avg_volatility * 0.7
  # Low volatility - use responsive MA
  3  # DEMA
else
  # Normal volatility - use adaptive MA
  6  # KAMA
end

ma_names = ['SMA', 'EMA', 'WMA', 'DEMA', 'TEMA', 'TRIMA', 'KAMA', 'MAMA', 'T3']
ma = SQA::TAI.ma(prices, period: 20, ma_type: ma_type)

puts "Current Volatility: #{(current_volatility / prices.last * 100).round(2)}%"
puts "Using: #{ma_names[ma_type]}"
puts "MA Value: #{ma.last.round(2)}"
puts "Price: #{prices.last.round(2)}"
```

## Example: Multi-Timeframe MA Strategy

```ruby
prices = load_historical_prices('MSFT')

# Use different MA types for different purposes
fast_ma = SQA::TAI.ma(prices, period: 10, ma_type: 1)   # EMA - fast signals
medium_ma = SQA::TAI.ma(prices, period: 20, ma_type: 3) # DEMA - balanced
slow_ma = SQA::TAI.ma(prices, period: 50, ma_type: 0)   # SMA - trend filter

current_price = prices.last

# Determine trend
trend = if fast_ma.last > medium_ma.last && medium_ma.last > slow_ma.last
  'STRONG UPTREND'
elsif fast_ma.last < medium_ma.last && medium_ma.last < slow_ma.last
  'STRONG DOWNTREND'
elsif fast_ma.last > slow_ma.last
  'UPTREND'
elsif fast_ma.last < slow_ma.last
  'DOWNTREND'
else
  'NEUTRAL'
end

puts "Trend: #{trend}"
puts "Fast MA (10 EMA): #{fast_ma.last.round(2)}"
puts "Medium MA (20 DEMA): #{medium_ma.last.round(2)}"
puts "Slow MA (50 SMA): #{slow_ma.last.round(2)}"

# Generate signals
if fast_ma.last > medium_ma.last && fast_ma[-2] <= medium_ma[-2]
  puts "BUY Signal: Fast MA crossed above Medium MA"
elsif fast_ma.last < medium_ma.last && fast_ma[-2] >= medium_ma[-2]
  puts "SELL Signal: Fast MA crossed below Medium MA"
end

# Confirm with slow MA
if current_price > slow_ma.last
  puts "Trend Confirmation: Price above slow MA - favor longs"
else
  puts "Trend Confirmation: Price below slow MA - favor shorts"
end
```

## Example: MA Type Performance Comparison

```ruby
prices = load_historical_prices('SPY')

# Test different MA types over historical data
period = 20
ma_types = [0, 1, 2, 3, 4, 5, 6, 8]
ma_names = ['SMA', 'EMA', 'WMA', 'DEMA', 'TEMA', 'TRIMA', 'KAMA', 'T3']

puts "Analyzing MA Performance:"
puts "-" * 60

ma_types.each_with_index do |type, i|
  ma = SQA::TAI.ma(prices, period: period, ma_type: type)

  # Calculate metrics
  valid_data = prices.zip(ma).reject { |p, m| m.nil? }

  # Average distance from price
  distances = valid_data.map { |p, m| ((p - m).abs / m * 100) }
  avg_distance = (distances.sum / distances.size).round(3)

  # Responsiveness (how much MA changes)
  changes = ma.compact.each_cons(2).map { |a, b| ((b - a).abs / a * 100) }
  avg_change = (changes.sum / changes.size).round(3)

  # Current values
  current_ma = ma.last.round(2)
  current_diff = ((prices.last - current_ma) / current_ma * 100).round(2)

  puts "#{ma_names[i].ljust(8)} | MA: #{current_ma.to_s.rjust(8)} | " \
       "Diff: #{current_diff.to_s.rjust(6)}% | " \
       "Avg Dist: #{avg_distance.to_s.rjust(5)}% | " \
       "Responsiveness: #{avg_change.to_s.rjust(5)}%"
end

puts "-" * 60
puts "Interpretation:"
puts "- Lower Avg Distance = Closer to price (more responsive)"
puts "- Higher Responsiveness = Reacts faster to changes"
puts "- Trade-off: Responsive MAs may whipsaw more"
```

## Trading Strategies

### 1. Universal MA Crossover
Use any MA type for crossover signals:
```ruby
fast = SQA::TAI.ma(prices, period: 10, ma_type: 1)  # EMA
slow = SQA::TAI.ma(prices, period: 30, ma_type: 0)  # SMA
# Buy when fast crosses above slow
```

### 2. Adaptive MA Strategy
Switch MA types based on market conditions:
- Trending: Use DEMA or TEMA (responsive)
- Ranging: Use TRIMA or SMA (smooth)
- Volatile: Use KAMA (adaptive)

### 3. MA Type Divergence
Compare fast and slow MA types:
```ruby
fast_responsive = SQA::TAI.ma(prices, period: 20, ma_type: 3)  # DEMA
slow_smooth = SQA::TAI.ma(prices, period: 20, ma_type: 5)      # TRIMA
# Divergence between types signals momentum change
```

### 4. MA Envelope Strategy
Create envelopes around any MA type:
```ruby
ma = SQA::TAI.ma(prices, period: 20, ma_type: 6)  # KAMA
upper = ma.map { |m| m * 1.02 }  # +2%
lower = ma.map { |m| m * 0.98 }  # -2%
```

## Common Settings

| Period | Use Case | Recommended MA Type |
|--------|----------|---------------------|
| 9-13 | Short-term trading | EMA (1), DEMA (3) |
| 20-26 | Swing trading | EMA (1), TEMA (4) |
| 50 | Medium-term trend | SMA (0), KAMA (6) |
| 100-200 | Long-term trend | SMA (0), TRIMA (5) |

## MA Type Selection Guide

### When to Use Each Type:

**SMA (0)**: Classic analysis, support/resistance levels, long-term trends

**EMA (1)**: Most popular, good balance, all timeframes

**WMA (2)**: When you want more weight on recent data than SMA but less than EMA

**DEMA (3)**: Trending markets, need faster signals, trend following

**TEMA (4)**: Strong trends, minimize lag, momentum trading

**TRIMA (5)**: Ranging markets, noise reduction, smooth analysis

**KAMA (6)**: Volatile/changing markets, automatic adaptation, sophisticated strategies

**MAMA (7)**: Cycle trading, frequency analysis, advanced technical analysis

**T3 (8)**: Smooth trends, minimal whipsaws, position trading

## Performance Characteristics

| MA Type | Lag | Smoothness | Responsiveness | Complexity |
|---------|-----|------------|----------------|------------|
| SMA | High | Medium | Low | Low |
| EMA | Medium | Medium | Medium | Low |
| WMA | Medium | Medium | Medium | Low |
| DEMA | Low | Low | High | Medium |
| TEMA | Very Low | Low | Very High | Medium |
| TRIMA | Very High | Very High | Low | Low |
| KAMA | Adaptive | Medium | Adaptive | High |
| MAMA | Low | Medium | High | Very High |
| T3 | Low | Very High | Medium | High |

## Related Indicators

- [Simple Moving Average (SMA)](sma.md) - Individual SMA documentation
- [Exponential Moving Average (EMA)](ema.md) - Individual EMA documentation
- [DEMA](dema.md) - Double Exponential MA
- [TEMA](tema.md) - Triple Exponential MA
- [TRIMA](trima.md) - Triangular MA
- [KAMA](kama.md) - Kaufman Adaptive MA
- [T3](t3.md) - T3 Moving Average
- [WMA](wma.md) - Weighted Moving Average

## See Also

- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
- [Trend Analysis Example](../../examples/trend-analysis.md)
