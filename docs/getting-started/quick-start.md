# Quick Start

Get up and running with SQA::TAI in minutes.

## Your First Indicator

```ruby
require 'sqa/tai'

# Sample price data
prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 45.89, 46.03,
          45.61, 46.28, 46.28, 46.00, 46.03, 46.41,
          46.22, 45.64]

# Calculate Simple Moving Average
sma = SQA::TAI.sma(prices, period: 5)
puts "5-period SMA: #{sma.last}"

# Calculate RSI
rsi = SQA::TAI.rsi(prices, period: 14)
puts "14-period RSI: #{rsi.last}"
```

## Common Patterns

### Moving Average Crossover

```ruby
prices = load_stock_prices('AAPL')

# Calculate fast and slow moving averages
sma_fast = SQA::TAI.sma(prices, period: 50)
sma_slow = SQA::TAI.sma(prices, period: 200)

# Check for golden cross
if sma_fast.last > sma_slow.last
  puts "Golden Cross detected - Bullish signal"
else
  puts "Death Cross - Bearish signal"
end
```

### RSI Overbought/Oversold

```ruby
prices = load_stock_prices('TSLA')
rsi = SQA::TAI.rsi(prices, period: 14)

case rsi.last
when 0...30
  puts "Oversold - Potential buy opportunity"
when 70..100
  puts "Overbought - Potential sell opportunity"
else
  puts "Neutral zone"
end
```

### Bollinger Bands

```ruby
prices = load_stock_prices('MSFT')

# Calculate Bollinger Bands
upper, middle, lower = SQA::TAI.bbands(
  prices,
  period: 20,
  nbdev_up: 2.0,
  nbdev_down: 2.0
)

current_price = prices.last

if current_price > upper.last
  puts "Price above upper band - Overbought"
elsif current_price < lower.last
  puts "Price below lower band - Oversold"
else
  puts "Price within bands - Normal"
end
```

## Working with OHLCV Data

Many indicators require Open, High, Low, Close, and Volume data:

```ruby
# Load OHLCV data
data = load_ohlcv_data('SPY')

open   = data[:open]
high   = data[:high]
low    = data[:low]
close  = data[:close]
volume = data[:volume]

# Calculate ATR (volatility)
atr = SQA::TAI.atr(high, low, close, period: 14)
puts "14-day ATR: #{atr.last}"

# Calculate Stochastic
slowk, slowd = SQA::TAI.stoch(high, low, close)
puts "Stochastic K: #{slowk.last}"
puts "Stochastic D: #{slowd.last}"

# Calculate OBV (volume)
obv = SQA::TAI.obv(close, volume)
puts "OBV: #{obv.last}"
```

## Error Handling

Always handle potential errors:

```ruby
begin
  result = SQA::TAI.sma(prices, period: 30)
rescue SQA::TAI::TAINotInstalledError => e
  puts "Error: TA-Lib not installed"
  puts e.message
rescue SQA::TAI::InvalidParameterError => e
  puts "Error: Invalid parameters"
  puts e.message
end
```

## Best Practices

### 1. Check Availability

```ruby
unless SQA::TAI.available?
  puts "TA-Lib is not available. Please install it."
  exit 1
end
```

### 2. Validate Data

```ruby
def calculate_indicators(prices)
  return unless prices && prices.size >= 14

  rsi = SQA::TAI.rsi(prices, period: 14)
  # ... rest of code
end
```

### 3. Handle Incomplete Results

TA-Lib returns nil for periods where calculation isn't possible:

```ruby
sma = SQA::TAI.sma(prices, period: 10)

# Filter out nils
valid_sma = sma.compact

# Or check before using
if sma.last
  puts "Latest SMA: #{sma.last}"
else
  puts "Not enough data for SMA calculation"
end
```

## Next Steps

- [Basic Usage Examples](basic-usage.md)
- [Complete Indicator List](../indicators/index.md)
- [API Reference](../api-reference.md)
- [Advanced Examples](../examples/trend-analysis.md)
