# Moving Average Convergence Divergence (MACD)

MACD is a trend-following momentum indicator that shows the relationship between two exponential moving averages. It consists of the MACD line, signal line, and histogram.

## Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41,
          46.22, 45.64, 46.21, 46.25, 46.08, 46.46,
          46.57, 45.95, 46.50, 46.02, 46.55, 47.03,
          47.35, 47.28, 47.61, 48.12, 48.34, 48.21]

# Calculate MACD (returns three arrays)
macd, signal, histogram = SQA::TAI.macd(prices)

puts "MACD Line: #{macd.last.round(4)}"
puts "Signal Line: #{signal.last.round(4)}"
puts "Histogram: #{histogram.last.round(4)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prices` | Array | Yes | - | Array of price values |
| `fast_period` | Integer | No | 12 | Fast EMA period |
| `slow_period` | Integer | No | 26 | Slow EMA period |
| `signal_period` | Integer | No | 9 | Signal line EMA period |

## Returns

Returns three arrays:
1. **MACD Line** - Difference between fast and slow EMAs
2. **Signal Line** - 9-period EMA of MACD line
3. **Histogram** - Difference between MACD and signal line

## Formula

```
MACD Line = EMA(12) - EMA(26)
Signal Line = EMA(9) of MACD Line
Histogram = MACD Line - Signal Line
```

## Interpretation

- **MACD crosses above Signal**: Bullish signal
- **MACD crosses below Signal**: Bearish signal
- **MACD above zero**: Upward momentum
- **MACD below zero**: Downward momentum
- **Histogram increasing**: Momentum strengthening
- **Histogram decreasing**: Momentum weakening

## Example: MACD Crossover Strategy

```ruby
prices = load_historical_prices('AAPL')

macd, signal, histogram = SQA::TAI.macd(prices)

# Check for crossovers
if macd[-2] < signal[-2] && macd[-1] > signal[-1]
  puts "Bullish MACD Crossover - BUY signal"
  puts "MACD: #{macd[-1].round(4)}, Signal: #{signal[-1].round(4)}"
elsif macd[-2] > signal[-2] && macd[-1] < signal[-1]
  puts "Bearish MACD Crossover - SELL signal"
  puts "MACD: #{macd[-1].round(4)}, Signal: #{signal[-1].round(4)}"
end
```

## Example: MACD Histogram Analysis

```ruby
prices = load_historical_prices('TSLA')

macd, signal, histogram = SQA::TAI.macd(prices)

# Analyze histogram momentum
recent_histogram = histogram.compact.last(5)

if recent_histogram.all? { |h| h > 0 } && recent_histogram[-1] > recent_histogram[-2]
  puts "Bullish momentum strengthening"
  puts "Histogram values: #{recent_histogram.map { |h| h.round(4) }}"
elsif recent_histogram.all? { |h| h < 0 } && recent_histogram[-1] < recent_histogram[-2]
  puts "Bearish momentum strengthening"
  puts "Histogram values: #{recent_histogram.map { |h| h.round(4) }}"
elsif recent_histogram[-1] > recent_histogram[-2]
  puts "Momentum turning bullish (histogram rising)"
else
  puts "Momentum weakening"
end
```

## Example: MACD Divergence

```ruby
prices = load_historical_prices('MSFT')

macd, signal, histogram = SQA::TAI.macd(prices)

# Find recent highs
price_high_1_idx = prices[-30..-15].index(prices[-30..-15].max) - 30
price_high_2_idx = prices[-14..-1].index(prices[-14..-1].max) - 14

price_high_1 = prices[price_high_1_idx]
price_high_2 = prices[price_high_2_idx]

macd_high_1 = macd[price_high_1_idx]
macd_high_2 = macd[price_high_2_idx]

# Bearish divergence
if price_high_2 > price_high_1 && macd_high_2 < macd_high_1
  puts "Bearish Divergence detected!"
  puts "Price: #{price_high_1.round(2)} -> #{price_high_2.round(2)} (higher high)"
  puts "MACD: #{macd_high_1.round(4)} -> #{macd_high_2.round(4)} (lower high)"
  puts "Potential trend reversal"
end
```

## Example: MACD Zero Line Crossover

```ruby
prices = load_historical_prices('NVDA')

macd, signal, histogram = SQA::TAI.macd(prices)

# Zero line crossovers are significant
if macd[-2] < 0 && macd[-1] > 0
  puts "MACD crossed above zero line"
  puts "Trend changing from bearish to bullish"
  puts "Look for buying opportunities"
elsif macd[-2] > 0 && macd[-1] < 0
  puts "MACD crossed below zero line"
  puts "Trend changing from bullish to bearish"
  puts "Consider reducing exposure"
end

# Current trend based on zero line
if macd.last > 0
  puts "MACD above zero: Bullish trend"
else
  puts "MACD below zero: Bearish trend"
end
```

## Trading Strategies

### 1. MACD Crossover
- Buy when MACD crosses above Signal
- Sell when MACD crosses below Signal
- Most common strategy

### 2. Zero Line Crossover
- Buy when MACD crosses above zero
- Sell when MACD crosses below zero
- Confirms trend direction

### 3. Histogram Reversal
- Buy when histogram stops decreasing and turns up
- Sell when histogram stops increasing and turns down
- Earlier signals than crossovers

### 4. Divergence Trading
- Bullish divergence: Price lower low, MACD higher low
- Bearish divergence: Price higher high, MACD lower high
- Powerful reversal signals

## MACD Settings

### Standard Settings (12, 26, 9)
- Most widely used
- Good for daily charts
- Balanced responsiveness

### Fast Settings (5, 13, 5)
- More sensitive
- More signals (more false positives)
- Good for short-term trading

### Slow Settings (19, 39, 9)
- Less sensitive
- Fewer but more reliable signals
- Good for long-term trends

## Combining with Other Indicators

```ruby
prices = load_historical_prices('GOOGL')

# MACD for momentum
macd, signal, histogram = SQA::TAI.macd(prices)

# RSI for overbought/oversold
rsi = SQA::TAI.rsi(prices, period: 14)

# Trend filter
sma_200 = SQA::TAI.sma(prices, period: 200)

current_price = prices.last

# Strong buy signal
if macd.last > signal.last &&  # MACD bullish
   rsi.last < 40 &&            # Not overbought
   current_price > sma_200.last # Uptrend
  puts "Strong BUY signal - all indicators aligned"
end
```

## Related Indicators

- [EMA](../overlap/ema.md) - Used in MACD calculation
- [RSI](rsi.md) - Complementary momentum indicator
- [Stochastic](stoch.md) - Another momentum oscillator

## See Also

- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
- [Momentum Trading Example](../../examples/momentum-trading.md)
