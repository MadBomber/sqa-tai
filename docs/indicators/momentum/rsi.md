# Relative Strength Index (RSI)

The Relative Strength Index (RSI) is a momentum oscillator that measures the speed and magnitude of price changes. It oscillates between 0 and 100, with readings above 70 indicating overbought conditions and below 30 indicating oversold conditions.

## Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41,
          46.22, 45.64, 46.21, 46.25, 46.08, 46.46]

# Calculate 14-period RSI
rsi = SQA::TAI.rsi(prices, period: 14)

puts "Current RSI: #{rsi.last.round(2)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prices` | Array | Yes | - | Array of price values |
| `period` | Integer | No | 14 | Number of periods for calculation |

## Returns

Returns an array of RSI values ranging from 0 to 100. The first `period` values will be `nil`.

## Interpretation

| RSI Value | Interpretation |
|-----------|----------------|
| 70-100 | Overbought - potential sell signal |
| 30-70 | Neutral zone |
| 0-30 | Oversold - potential buy signal |
| 50 | Midline - trend direction indicator |

## Example: Basic RSI Strategy

```ruby
prices = load_historical_prices('AAPL')

rsi = SQA::TAI.rsi(prices, period: 14)
current_rsi = rsi.last

case current_rsi
when 0...30
  puts "RSI Oversold (#{current_rsi.round(2)}) - Potential BUY"
when 70..100
  puts "RSI Overbought (#{current_rsi.round(2)}) - Potential SELL"
when 40...60
  puts "RSI Neutral (#{current_rsi.round(2)}) - No clear signal"
else
  puts "RSI at #{current_rsi.round(2)}"
end
```

## Example: RSI Divergence

```ruby
prices = load_historical_prices('TSLA')

rsi = SQA::TAI.rsi(prices, period: 14)

# Find recent highs in price and RSI
price_high_1 = prices[-20..-10].max
price_high_2 = prices[-9..-1].max

rsi_high_1 = rsi[-20..-10].compact.max
rsi_high_2 = rsi[-9..-1].compact.max

# Bearish divergence: price makes higher high, RSI makes lower high
if price_high_2 > price_high_1 && rsi_high_2 < rsi_high_1
  puts "Bearish Divergence detected!"
  puts "Price higher high: #{price_high_1} -> #{price_high_2}"
  puts "RSI lower high: #{rsi_high_1.round(2)} -> #{rsi_high_2.round(2)}"
end

# Bullish divergence: price makes lower low, RSI makes higher low
price_low_1 = prices[-20..-10].min
price_low_2 = prices[-9..-1].min

rsi_low_1 = rsi[-20..-10].compact.min
rsi_low_2 = rsi[-9..-1].compact.min

if price_low_2 < price_low_1 && rsi_low_2 > rsi_low_1
  puts "Bullish Divergence detected!"
  puts "Price lower low: #{price_low_1} -> #{price_low_2}"
  puts "RSI higher low: #{rsi_low_1.round(2)} -> #{rsi_low_2.round(2)}"
end
```

## Example: RSI with Trend Filter

```ruby
prices = load_historical_prices('MSFT')

rsi = SQA::TAI.rsi(prices, period: 14)
sma_200 = SQA::TAI.sma(prices, period: 200)

current_price = prices.last
current_rsi = rsi.last

# Only take signals aligned with trend
if current_price > sma_200.last
  # Uptrend - only look for oversold buy signals
  if current_rsi < 30
    puts "Uptrend + Oversold RSI = Strong BUY signal"
  elsif current_rsi > 70
    puts "Uptrend + Overbought RSI = Take profits"
  end
elsif current_price < sma_200.last
  # Downtrend - only look for overbought sell signals
  if current_rsi > 70
    puts "Downtrend + Overbought RSI = Strong SELL signal"
  elsif current_rsi < 30
    puts "Downtrend + Oversold RSI = Avoid catching falling knife"
  end
end
```

## Advanced Techniques

### 1. RSI Trendlines
Draw trendlines on RSI chart to identify support/resistance

### 2. RSI Swing Rejection
- Bullish: RSI dips below 30, rises above 30, pulls back without breaking 30, then breaks recent high
- Bearish: RSI rises above 70, falls below 70, bounces without breaking 70, then breaks recent low

### 3. RSI Range
Adjust overbought/oversold levels based on market conditions:
- Strong uptrend: 80/40 instead of 70/30
- Strong downtrend: 60/20 instead of 70/30

## Example: Multiple Timeframe RSI

```ruby
# Assuming you have different timeframe data
daily_prices = load_historical_prices('AAPL', timeframe: 'daily')
weekly_prices = load_historical_prices('AAPL', timeframe: 'weekly')

daily_rsi = SQA::TAI.rsi(daily_prices, period: 14)
weekly_rsi = SQA::TAI.rsi(weekly_prices, period: 14)

puts "Daily RSI: #{daily_rsi.last.round(2)}"
puts "Weekly RSI: #{weekly_rsi.last.round(2)}"

# Strongest signals when both timeframes align
if daily_rsi.last < 30 && weekly_rsi.last < 40
  puts "Multi-timeframe oversold - strong buy setup"
elsif daily_rsi.last > 70 && weekly_rsi.last > 60
  puts "Multi-timeframe overbought - strong sell setup"
end
```

## Common Settings

| Period | Use Case |
|--------|----------|
| 9 | Short-term trading |
| 14 | Standard (most common) |
| 21 | Medium-term trends |
| 25 | Long-term analysis |

## Related Indicators

- [MACD](macd.md) - Momentum and trend
- [Stochastic](stoch.md) - Similar oscillator
- [MOM](mom.md) - Rate of change

## See Also

- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
- [Momentum Trading Example](../../examples/momentum-trading.md)
