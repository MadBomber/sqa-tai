# Intraday Momentum Index (IMI)

The Intraday Momentum Index (IMI) is a momentum oscillator that combines aspects of RSI and candlestick analysis. Unlike RSI which uses closing prices, IMI uses the relationship between open and close prices to measure intraday momentum. It oscillates between 0 and 100, making it particularly useful for identifying overbought and oversold conditions based on intraday price action.

## Usage

```ruby
require 'sqa/tai'

open_prices = [44.50, 44.25, 44.75, 44.00, 44.50, 45.00,
               45.25, 45.50, 45.75, 46.00, 46.25, 46.50,
               46.75, 47.00, 46.50, 46.75, 47.00, 47.25]

close_prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
                45.10, 45.42, 45.84, 46.08, 46.03, 46.41,
                46.22, 45.64, 46.21, 46.25, 46.08, 46.46]

# Calculate 14-period IMI
imi = SQA::TAI.imi(open_prices, close_prices, period: 14)

puts "Current IMI: #{imi.last.round(2)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `open_prices` | Array | Yes | - | Array of open price values |
| `close_prices` | Array | Yes | - | Array of close price values |
| `period` | Integer | No | 14 | Number of periods for calculation |

## Returns

Returns an array of IMI values ranging from 0 to 100. The first `period` values will be `nil`.

## Interpretation

| IMI Value | Interpretation |
|-----------|----------------|
| 70-100 | Overbought - strong intraday buying pressure |
| 50-70 | Bullish momentum |
| 30-50 | Bearish momentum |
| 0-30 | Oversold - strong intraday selling pressure |
| 50 | Neutral - balanced intraday action |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

## Example: Basic IMI Trading Signals

```ruby
open_prices = load_historical_data('AAPL', field: :open)
close_prices = load_historical_data('AAPL', field: :close)

imi = SQA::TAI.imi(open_prices, close_prices, period: 14)
current_imi = imi.last

case current_imi
when 0...30
  puts "IMI Oversold (#{current_imi.round(2)}) - Potential BUY"
  puts "Strong intraday selling pressure may be exhausted"
when 70..100
  puts "IMI Overbought (#{current_imi.round(2)}) - Potential SELL"
  puts "Strong intraday buying pressure may be exhausted"
when 45...55
  puts "IMI Neutral (#{current_imi.round(2)}) - No clear signal"
  puts "Balanced intraday momentum"
else
  puts "IMI at #{current_imi.round(2)}"
end

# Check trend
if current_imi > 50
  puts "Bullish intraday momentum"
else
  puts "Bearish intraday momentum"
end
```

## Example: IMI Divergence Detection

```ruby
open_prices = load_historical_data('TSLA', field: :open)
close_prices = load_historical_data('TSLA', field: :close)

imi = SQA::TAI.imi(open_prices, close_prices, period: 14)

# Find recent highs in price and IMI
price_high_1 = close_prices[-20..-10].max
price_high_2 = close_prices[-9..-1].max

imi_high_1 = imi[-20..-10].compact.max
imi_high_2 = imi[-9..-1].compact.max

# Bearish divergence: price makes higher high, IMI makes lower high
if price_high_2 > price_high_1 && imi_high_2 < imi_high_1
  puts "Bearish Divergence detected!"
  puts "Price higher high: #{price_high_1.round(2)} -> #{price_high_2.round(2)}"
  puts "IMI lower high: #{imi_high_1.round(2)} -> #{imi_high_2.round(2)}"
  puts "Intraday momentum weakening despite higher prices"
end

# Bullish divergence: price makes lower low, IMI makes higher low
price_low_1 = close_prices[-20..-10].min
price_low_2 = close_prices[-9..-1].min

imi_low_1 = imi[-20..-10].compact.min
imi_low_2 = imi[-9..-1].compact.min

if price_low_2 < price_low_1 && imi_low_2 > imi_low_1
  puts "Bullish Divergence detected!"
  puts "Price lower low: #{price_low_1.round(2)} -> #{price_low_2.round(2)}"
  puts "IMI higher low: #{imi_low_1.round(2)} -> #{imi_low_2.round(2)}"
  puts "Intraday selling pressure weakening"
end
```

## Example: IMI vs RSI Comparison

```ruby
open_prices = load_historical_data('MSFT', field: :open)
close_prices = load_historical_data('MSFT', field: :close)

# Calculate both indicators
imi = SQA::TAI.imi(open_prices, close_prices, period: 14)
rsi = SQA::TAI.rsi(close_prices, period: 14)

current_imi = imi.last
current_rsi = rsi.last

puts "IMI: #{current_imi.round(2)}"
puts "RSI: #{current_rsi.round(2)}"
puts "Difference: #{(current_imi - current_rsi).round(2)}"

# IMI measures intraday action, RSI measures closing momentum
if current_imi > current_rsi + 10
  puts "IMI > RSI: Strong intraday buying (closes > opens)"
  puts "Bullish candle pattern trend"
elsif current_rsi > current_imi + 10
  puts "RSI > IMI: Prices rising but weak intraday action"
  puts "Caution: May indicate buying exhaustion"
end

# Strong signals when both align
if current_imi < 30 && current_rsi < 30
  puts "Both oversold - high conviction BUY signal"
elsif current_imi > 70 && current_rsi > 70
  puts "Both overbought - high conviction SELL signal"
end
```

## Advanced Techniques

### 1. Intraday Gap Analysis
IMI is particularly useful when combined with gap analysis:
- Large gap up + IMI > 70 = Gap may fill
- Large gap down + IMI < 30 = Potential reversal

### 2. Candlestick Pattern Confirmation
Use IMI to confirm candlestick patterns:
- Bullish engulfing + IMI rising = Strong buy
- Bearish engulfing + IMI falling = Strong sell

### 3. Timeframe Analysis
- Daily IMI: Swing trading signals
- Hourly IMI: Day trading signals
- 15-min IMI: Scalping opportunities

### 4. IMI Zones
Customize zones based on market conditions:
- Volatile markets: 80/20 instead of 70/30
- Quiet markets: 60/40 for earlier signals

## Example: Intraday Trading Strategy

```ruby
# For day trading with minute/hourly data
open_prices = load_intraday_data('SPY', field: :open, interval: '5min')
close_prices = load_intraday_data('SPY', field: :close, interval: '5min')

imi = SQA::TAI.imi(open_prices, close_prices, period: 14)

# Track intraday momentum
current_imi = imi.last
prev_imi = imi[-2]

# Entry signals
if current_imi < 30 && prev_imi >= 30
  puts "IMI crossed below 30 - SELL signal"
  puts "Short entry at: #{close_prices.last.round(2)}"
elsif current_imi > 70 && prev_imi <= 70
  puts "IMI crossed above 70 - BUY signal"
  puts "Long entry at: #{close_prices.last.round(2)}"
end

# Exit signals (mean reversion)
if current_imi > 50 && prev_imi < 50
  puts "IMI crossed above 50 - Exit short positions"
elsif current_imi < 50 && prev_imi > 50
  puts "IMI crossed below 50 - Exit long positions"
end

# Calculate strength of move
candle_strength = ((close_prices.last - open_prices.last).abs /
                   open_prices.last * 100).round(2)
puts "Candle Strength: #{candle_strength}%"
puts "IMI reflects intraday momentum: #{current_imi.round(2)}"
```

## Example: Multi-Period IMI

```ruby
open_prices = load_historical_data('NVDA', field: :open)
close_prices = load_historical_data('NVDA', field: :close)

# Calculate multiple periods
imi_7 = SQA::TAI.imi(open_prices, close_prices, period: 7)
imi_14 = SQA::TAI.imi(open_prices, close_prices, period: 14)
imi_21 = SQA::TAI.imi(open_prices, close_prices, period: 21)

puts "Short-term IMI (7): #{imi_7.last.round(2)}"
puts "Standard IMI (14): #{imi_14.last.round(2)}"
puts "Long-term IMI (21): #{imi_21.last.round(2)}"

# All periods aligned = strong signal
if imi_7.last > 70 && imi_14.last > 70 && imi_21.last > 70
  puts "All timeframes overbought - strong reversal candidate"
elsif imi_7.last < 30 && imi_14.last < 30 && imi_21.last < 30
  puts "All timeframes oversold - strong reversal candidate"
end

# Divergence between timeframes
if imi_7.last > 70 && imi_21.last < 50
  puts "Short-term overbought but longer-term neutral"
  puts "Potential pullback in uptrend"
elsif imi_7.last < 30 && imi_21.last > 50
  puts "Short-term oversold but longer-term bullish"
  puts "Buying opportunity in uptrend"
end
```

## Common Settings

| Period | Use Case |
|--------|----------|
| 7 | Short-term, day trading |
| 14 | Standard (most common) |
| 21 | Swing trading |
| 30 | Position trading |

## Key Differences from RSI

| Feature | IMI | RSI |
|---------|-----|-----|
| Data Used | Open and Close | Close only |
| Focus | Intraday momentum | Overall momentum |
| Sensitivity | More sensitive to candle patterns | Smoother, trend-focused |
| Best For | Day trading, intraday analysis | Swing trading, trend analysis |
| Gap Sensitivity | Affected by gaps | Less affected by gaps |

## Related Indicators

- [RSI](rsi.md) - Similar oscillator using closes
- [Stochastic](stoch.md) - Another overbought/oversold indicator
- [MFI](mfi.md) - Money Flow Index (volume-weighted)
- [CCI](cci.md) - Commodity Channel Index

## See Also

- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
- [Momentum Trading Example](../../examples/momentum-trading.md)
