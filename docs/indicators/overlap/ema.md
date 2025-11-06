# Exponential Moving Average (EMA)

The Exponential Moving Average (EMA) is a type of moving average that gives more weight to recent prices, making it more responsive to price changes than the Simple Moving Average.

## Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41]

# Calculate 12-period EMA
ema = SQA::TAI.ema(prices, period: 12)

puts "Current EMA: #{ema.last}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prices` | Array | Yes | - | Array of price values |
| `period` | Integer | No | 30 | Number of periods for calculation |

## Returns

Returns an array of EMA values. The first `period - 1` values will be `nil`.

## Formula

```
Multiplier = 2 / (period + 1)
EMA = (Price - Previous EMA) × Multiplier + Previous EMA
```

## Interpretation

- More responsive to recent price changes than SMA
- Reacts faster to trend reversals
- Commonly used for shorter-term trading
- Less lag compared to SMA

## Example: MACD Components

The MACD indicator uses two EMAs:

```ruby
prices = load_historical_prices('AAPL')

# MACD uses 12-period and 26-period EMAs
ema_12 = SQA::TAI.ema(prices, period: 12)
ema_26 = SQA::TAI.ema(prices, period: 26)

# MACD line is the difference
macd_line = ema_12.zip(ema_26).map do |fast, slow|
  fast && slow ? fast - slow : nil
end

puts "Current MACD: #{macd_line.last}"
```

## Example: EMA Crossover Strategy

```ruby
prices = load_historical_prices('TSLA')

# Fast and slow EMAs
ema_9 = SQA::TAI.ema(prices, period: 9)
ema_21 = SQA::TAI.ema(prices, period: 21)

# Check for crossover
if ema_9[-2] < ema_21[-2] && ema_9[-1] > ema_21[-1]
  puts "Bullish crossover - Buy signal"
elsif ema_9[-2] > ema_21[-2] && ema_9[-1] < ema_21[-1]
  puts "Bearish crossover - Sell signal"
end
```

## Example: Trend Following

```ruby
prices = load_historical_prices('MSFT')

ema_20 = SQA::TAI.ema(prices, period: 20)
ema_50 = SQA::TAI.ema(prices, period: 50)
ema_200 = SQA::TAI.ema(prices, period: 200)

current_price = prices.last

# Strong uptrend when price above all EMAs
if current_price > ema_20.last &&
   current_price > ema_50.last &&
   current_price > ema_200.last
  puts "Strong uptrend confirmed"

  # Even stronger if EMAs are properly aligned
  if ema_20.last > ema_50.last && ema_50.last > ema_200.last
    puts "EMA alignment confirms trend strength"
  end
end
```

## EMA vs SMA

| Aspect | EMA | SMA |
|--------|-----|-----|
| Weighting | More weight on recent prices | Equal weight all periods |
| Responsiveness | More responsive | Less responsive |
| Lag | Less lag | More lag |
| Smoothness | Less smooth | More smooth |
| Best For | Short-term trading | Long-term trends |

## Related Indicators

- [Simple Moving Average (SMA)](sma.md) - Basic moving average
- [MACD](../momentum/macd.md) - Uses EMAs for calculation
- [Bollinger Bands](bbands.md) - Can use EMA as basis

## See Also

- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
- [Trend Analysis Example](../../examples/trend-analysis.md)
