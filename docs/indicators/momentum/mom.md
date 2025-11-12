# Momentum (MOM)

The Momentum indicator measures the rate of change in prices over a specified time period. It's one of the simplest momentum indicators, showing the difference between the current price and the price N periods ago.

## Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41,
          46.22, 45.64, 46.21, 46.25]

# Calculate 10-period Momentum
mom = SQA::TAI.mom(prices, period: 10)

puts "Current Momentum: #{mom.last.round(2)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prices` | Array | Yes | - | Array of price values |
| `period` | Integer | No | 10 | Lookback period |

## Returns

Returns an array of momentum values. The first `period` values will be `nil`.

## Formula

```
Momentum = Current Price - Price N periods ago
```

## Interpretation

- **Positive values**: Upward momentum (price higher than N periods ago)
- **Negative values**: Downward momentum (price lower than N periods ago)
- **Zero line**: No momentum (price unchanged)
- **Increasing values**: Momentum strengthening
- **Decreasing values**: Momentum weakening

## Example: Basic Momentum Strategy

```ruby
prices = load_historical_prices('AAPL')

mom = SQA::TAI.mom(prices, period: 10)

current_mom = mom.last
previous_mom = mom[-2]

if current_mom > 0
  puts "Positive momentum: #{current_mom.round(2)}"
  if current_mom > previous_mom
    puts "Momentum increasing - trend strengthening"
  else
    puts "Momentum decreasing - trend weakening"
  end
elsif current_mom < 0
  puts "Negative momentum: #{current_mom.round(2)}"
  if current_mom < previous_mom
    puts "Momentum decreasing - downtrend strengthening"
  else
    puts "Momentum increasing - downtrend weakening"
  end
end
```

## Example: Zero Line Crossovers

```ruby
prices = load_historical_prices('TSLA')

mom = SQA::TAI.mom(prices, period: 14)

# Check for zero line crossovers
if mom[-2] < 0 && mom[-1] > 0
  puts "Momentum crossed above zero - Bullish signal"
  puts "Price now higher than 14 periods ago"
elsif mom[-2] > 0 && mom[-1] < 0
  puts "Momentum crossed below zero - Bearish signal"
  puts "Price now lower than 14 periods ago"
end
```

## Example: Momentum Divergence

```ruby
prices = load_historical_prices('MSFT')

mom = SQA::TAI.mom(prices, period: 10)

# Find recent price and momentum peaks
price_peak_1 = prices[-30..-15].max
price_peak_2 = prices[-14..-1].max

mom_peak_1_idx = prices[-30..-15].index(price_peak_1) - 30
mom_peak_2_idx = prices[-14..-1].index(price_peak_2) - 14

mom_peak_1 = mom[mom_peak_1_idx]
mom_peak_2 = mom[mom_peak_2_idx]

# Bearish divergence
if price_peak_2 > price_peak_1 && mom_peak_2 < mom_peak_1
  puts "Bearish Divergence!"
  puts "Price making higher highs but momentum making lower highs"
  puts "Potential trend reversal"
end
```

## Example: Multi-Period Momentum

```ruby
prices = load_historical_prices('NVDA')

# Different momentum periods
mom_5 = SQA::TAI.mom(prices, period: 5)
mom_10 = SQA::TAI.mom(prices, period: 10)
mom_20 = SQA::TAI.mom(prices, period: 20)

puts "5-period Momentum: #{mom_5.last.round(2)}"
puts "10-period Momentum: #{mom_10.last.round(2)}"
puts "20-period Momentum: #{mom_20.last.round(2)}"

# All positive = strong uptrend
if mom_5.last > 0 && mom_10.last > 0 && mom_20.last > 0
  puts "All momentum periods positive - Strong uptrend"
elsif mom_5.last < 0 && mom_10.last < 0 && mom_20.last < 0
  puts "All momentum periods negative - Strong downtrend"
else
  puts "Mixed momentum signals - Potential transition phase"
end
```

## Example: Momentum with Moving Average

```ruby
prices = load_historical_prices('GOOGL')

mom = SQA::TAI.mom(prices, period: 14)
mom_ma = SQA::TAI.sma(mom.compact, period: 10)

# Extend mom_ma with nils to match length
full_mom_ma = Array.new(mom.length - mom_ma.length, nil) + mom_ma

current_mom = mom.last
current_mom_ma = full_mom_ma.last

if current_mom > current_mom_ma
  puts "Momentum above its moving average - Bullish"
elsif current_mom < current_mom_ma
  puts "Momentum below its moving average - Bearish"
end
```

## Trading Strategies

### 1. Zero Line Crossover
- Buy when Momentum crosses above zero
- Sell when Momentum crosses below zero
- Simple trend-following approach

### 2. Momentum Peaks/Troughs
- Sell when Momentum peaks and starts declining
- Buy when Momentum bottoms and starts rising
- Captures momentum shifts early

### 3. Divergence Trading
- Bullish: Price lower low, Momentum higher low
- Bearish: Price higher high, Momentum lower high
- Signals potential reversals

### 4. Momentum Trend
- Buy when Momentum is positive and rising
- Sell when Momentum is negative and falling
- Confirms trend strength

## Common Period Settings

| Period | Use Case |
|--------|----------|
| 5 | Very short-term, sensitive |
| 10 | Short-term trading |
| 14 | Standard setting |
| 20 | Medium-term trends |
| 30+ | Long-term analysis |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

## Advantages

- Simple and easy to understand
- Clear buy/sell signals
- Works well with other indicators
- No overbought/oversold levels to interpret

## Limitations

- Can give false signals in choppy markets
- No absolute overbought/oversold levels
- Needs confirmation from other indicators
- Raw values depend on price scale

## Combining with Other Indicators

```ruby
prices = load_historical_prices('AAPL')

mom = SQA::TAI.mom(prices, period: 12)
rsi = SQA::TAI.rsi(prices, period: 14)
sma_50 = SQA::TAI.sma(prices, period: 50)

current_price = prices.last

# Multiple confirmations
if mom.last > 0 &&              # Positive momentum
   rsi.last > 50 &&             # RSI above midline
   current_price > sma_50.last  # Above 50-day MA
  puts "Multiple indicators confirm uptrend - Strong BUY"
end
```

## Related Indicators

- [RSI](rsi.md) - Normalized momentum
- [MACD](macd.md) - Smoothed momentum with signal
- [Stochastic](stoch.md) - Momentum oscillator

## See Also

- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
- [Momentum Trading Example](../../examples/momentum-trading.md)
