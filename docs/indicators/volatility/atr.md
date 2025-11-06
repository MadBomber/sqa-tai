# Average True Range (ATR)

The Average True Range (ATR) is a volatility indicator that measures the degree of price volatility. It shows how much an asset moves, on average, during a given time frame.

## Usage

```ruby
require 'sqa/tai'

# OHLC data required
high  = [46.08, 46.41, 46.46, 46.57, 46.50, 47.03, 47.35, 47.61, 48.12, 48.34,
         48.21, 48.95, 49.13, 49.32, 49.78]
low   = [44.61, 44.83, 45.64, 45.95, 46.02, 46.50, 47.28, 47.28, 48.03, 48.21,
         47.85, 48.45, 48.67, 48.94, 49.25]
close = [45.42, 45.84, 46.08, 46.46, 46.55, 47.03, 47.28, 47.61, 48.12, 48.21,
         48.15, 48.85, 49.05, 49.25, 49.65]

# Calculate 14-period ATR
atr = SQA::TAI.atr(high, low, close, period: 14)

puts "Current ATR: #{atr.last.round(2)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `high` | Array | Yes | - | Array of high prices |
| `low` | Array | Yes | - | Array of low prices |
| `close` | Array | Yes | - | Array of closing prices |
| `period` | Integer | No | 14 | Number of periods for calculation |

## Returns

Returns an array of ATR values. The first `period` values will be `nil`.

## Formula

```
True Range = Max of:
  - Current High - Current Low
  - |Current High - Previous Close|
  - |Current Low - Previous Close|

ATR = Average of True Range over N periods
```

## Interpretation

- **High ATR**: High volatility, large price swings
- **Low ATR**: Low volatility, small price swings
- **Rising ATR**: Increasing volatility
- **Falling ATR**: Decreasing volatility

ATR doesn't indicate direction, only volatility magnitude.

## Example: Volatility-Based Position Sizing

```ruby
high, low, close = load_ohlc_data('AAPL')

atr = SQA::TAI.atr(high, low, close, period: 14)
current_atr = atr.last
current_price = close.last

# Risk 1% of capital per trade
account_value = 100_000
risk_per_trade = account_value * 0.01  # $1,000

# Use ATR for stop loss (2× ATR is common)
stop_distance = current_atr * 2
position_size = risk_per_trade / stop_distance

puts "Current Price: $#{current_price.round(2)}"
puts "ATR: $#{current_atr.round(2)}"
puts "Stop Distance: $#{stop_distance.round(2)}"
puts "Position Size: #{position_size.round(0)} shares"
puts "Stop Loss: $#{(current_price - stop_distance).round(2)}"
```

## Example: Volatility Breakout

```ruby
high, low, close = load_ohlc_data('TSLA')

atr = SQA::TAI.atr(high, low, close, period: 14)

# Calculate average ATR
avg_atr = atr.compact[-20..-1].sum / 20.0
current_atr = atr.last

# Look for volatility expansion
if current_atr > avg_atr * 1.5
  puts "Volatility breakout detected!"
  puts "Current ATR: #{current_atr.round(2)}"
  puts "20-day Average ATR: #{avg_atr.round(2)}"
  puts "ATR #{((current_atr / avg_atr - 1) * 100).round(0)}% above average"
  puts "Expect larger price moves"
end
```

## Example: ATR Stop Loss and Target

```ruby
high, low, close = load_ohlc_data('MSFT')

atr = SQA::TAI.atr(high, low, close, period: 14)
current_atr = atr.last
current_price = close.last

# For long positions
entry_price = current_price
stop_loss = entry_price - (2 * current_atr)
target_1 = entry_price + (2 * current_atr)
target_2 = entry_price + (3 * current_atr)

puts "Entry: $#{entry_price.round(2)}"
puts "Stop Loss: $#{stop_loss.round(2)} (-#{((1 - stop_loss/entry_price) * 100).round(1)}%)"
puts "Target 1: $#{target_1.round(2)} (+#{((target_1/entry_price - 1) * 100).round(1)}%)"
puts "Target 2: $#{target_2.round(2)} (+#{((target_2/entry_price - 1) * 100).round(1)}%)"
puts "Risk:Reward = 1:#{((target_1 - entry_price) / (entry_price - stop_loss)).round(1)}"
```

## Example: Comparing Volatility Across Assets

```ruby
# Compare volatility of different stocks
symbols = ['AAPL', 'TSLA', 'SPY']

volatility_data = symbols.map do |symbol|
  high, low, close = load_ohlc_data(symbol)
  atr = SQA::TAI.atr(high, low, close, period: 14)
  current_price = close.last
  current_atr = atr.last

  # Normalized ATR (as percentage of price)
  atr_percent = (current_atr / current_price) * 100

  {
    symbol: symbol,
    price: current_price.round(2),
    atr: current_atr.round(2),
    atr_percent: atr_percent.round(2)
  }
end

volatility_data.sort_by { |d| -d[:atr_percent] }.each do |data|
  puts "#{data[:symbol]}: ATR $#{data[:atr]} (#{data[:atr_percent]}% of price)"
end
```

## Example: ATR Bands (Chandelier Exit)

```ruby
high, low, close = load_ohlc_data('NVDA')

atr = SQA::TAI.atr(high, low, close, period: 14)

# Calculate Chandelier Exit (ATR-based trailing stop)
multiplier = 3
lookback = 22

chandelier_long = high.each_with_index.map do |h, i|
  next nil if i < lookback || atr[i].nil?

  highest_high = high[(i-lookback+1)..i].max
  highest_high - (multiplier * atr[i])
end

chandelier_short = low.each_with_index.map do |l, i|
  next nil if i < lookback || atr[i].nil?

  lowest_low = low[(i-lookback+1)..i].min
  lowest_low + (multiplier * atr[i])
end

puts "Current Price: #{close.last.round(2)}"
puts "Chandelier Long Exit: #{chandelier_long.last.round(2)}"
puts "Chandelier Short Exit: #{chandelier_short.last.round(2)}"
```

## Common Uses

### 1. Stop Loss Placement
```ruby
stop_loss = entry_price - (2 * atr)  # For long
stop_loss = entry_price + (2 * atr)  # For short
```

### 2. Position Sizing
```ruby
position_size = account_risk / (atr_multiplier * atr)
```

### 3. Profit Targets
```ruby
target = entry_price + (3 * atr)  # 3× ATR target
```

### 4. Volatility Filter
```ruby
# Only trade when ATR is above average
trade_signal = entry_signal && atr > avg_atr
```

## ATR Period Settings

| Period | Use Case |
|--------|----------|
| 7 | Short-term, more sensitive |
| 14 | Standard (most common) |
| 21 | Medium-term |
| 50 | Long-term trends |

## Advantages

- Non-directional (works in any trend)
- Adapts to changing market conditions
- Useful for risk management
- Works across all timeframes

## Limitations

- Doesn't indicate trend direction
- Lagging indicator
- High ATR doesn't mean trend will continue
- Can be affected by gaps

## Related Indicators

- [True Range (TRANGE)](trange.md) - Single period calculation
- [Bollinger Bands](../overlap/bbands.md) - Another volatility measure
- [Standard Deviation](../overlap/bbands.md) - Used in Bollinger Bands

## See Also

- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
- [Volatility Analysis Example](../../examples/volatility-analysis.md)
