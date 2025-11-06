# Stochastic Oscillator (STOCH)

The Stochastic Oscillator is a momentum indicator that compares a closing price to its price range over a given time period. It consists of two lines: %K (fast) and %D (slow signal line).

## Usage

```ruby
require 'sqa/tai'

# OHLC data required
high  = [46.08, 46.41, 46.46, 46.57, 46.50, 47.03, 47.35, 47.61, 48.12, 48.34]
low   = [44.61, 44.83, 45.64, 45.95, 46.02, 46.50, 47.28, 47.28, 48.03, 48.21]
close = [45.42, 45.84, 46.08, 46.46, 46.55, 47.03, 47.28, 47.61, 48.12, 48.21]

# Calculate Stochastic (returns two arrays)
slowk, slowd = SQA::TAI.stoch(high, low, close)

puts "%K (fast): #{slowk.last.round(2)}"
puts "%D (slow): #{slowd.last.round(2)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `high` | Array | Yes | - | Array of high prices |
| `low` | Array | Yes | - | Array of low prices |
| `close` | Array | Yes | - | Array of closing prices |
| `fastk_period` | Integer | No | 5 | %K period |
| `slowk_period` | Integer | No | 3 | %K slowing period |
| `slowk_ma_type` | Integer | No | 0 | %K MA type (0=SMA) |
| `slowd_period` | Integer | No | 3 | %D period |
| `slowd_ma_type` | Integer | No | 0 | %D MA type (0=SMA) |

## Returns

Returns two arrays:
1. **%K Line** (SlowK) - Smoothed fast stochastic
2. **%D Line** (SlowD) - Signal line (moving average of %K)

## Formula

```
%K = 100 × (Close - Lowest Low) / (Highest High - Lowest Low)
%D = 3-period SMA of %K
```

## Interpretation

| Value | Interpretation |
|-------|----------------|
| 80-100 | Overbought zone |
| 20-80 | Neutral zone |
| 0-20 | Oversold zone |

## Example: Basic Stochastic Strategy

```ruby
high, low, close = load_ohlc_data('AAPL')

slowk, slowd = SQA::TAI.stoch(high, low, close)

k = slowk.last
d = slowd.last

if k < 20 && d < 20
  puts "Oversold: %K=#{k.round(2)}, %D=#{d.round(2)}"
  if k > d
    puts "Bullish crossover in oversold zone - BUY signal"
  end
elsif k > 80 && d > 80
  puts "Overbought: %K=#{k.round(2)}, %D=#{d.round(2)}"
  if k < d
    puts "Bearish crossover in overbought zone - SELL signal"
  end
end
```

## Example: Stochastic Crossovers

```ruby
high, low, close = load_ohlc_data('TSLA')

slowk, slowd = SQA::TAI.stoch(high, low, close)

# Check for crossovers
if slowk[-2] < slowd[-2] && slowk[-1] > slowd[-1]
  if slowk[-1] < 20
    puts "Bullish crossover in oversold zone - Strong BUY"
  else
    puts "Bullish crossover at #{slowk[-1].round(2)} - Moderate BUY"
  end
elsif slowk[-2] > slowd[-2] && slowk[-1] < slowd[-1]
  if slowk[-1] > 80
    puts "Bearish crossover in overbought zone - Strong SELL"
  else
    puts "Bearish crossover at #{slowk[-1].round(2)} - Moderate SELL"
  end
end
```

## Example: Stochastic Divergence

```ruby
high, low, close = load_ohlc_data('MSFT')

slowk, slowd = SQA::TAI.stoch(high, low, close)

# Find recent lows
price_low_1 = close[-30..-15].min
price_low_2 = close[-14..-1].min

stoch_low_1 = slowk[-30..-15].compact.min
stoch_low_2 = slowk[-14..-1].compact.min

# Bullish divergence: price lower low, stochastic higher low
if price_low_2 < price_low_1 && stoch_low_2 > stoch_low_1
  puts "Bullish Divergence detected!"
  puts "Price: #{price_low_1.round(2)} -> #{price_low_2.round(2)} (lower)"
  puts "Stochastic: #{stoch_low_1.round(2)} -> #{stoch_low_2.round(2)} (higher)"
  puts "Potential reversal to upside"
end
```

## Example: Trend-Filtered Stochastic

```ruby
high, low, close = load_ohlc_data('NVDA')

slowk, slowd = SQA::TAI.stoch(high, low, close)
sma_50 = SQA::TAI.sma(close, period: 50)

current_price = close.last
k = slowk.last

# Only take signals aligned with trend
if current_price > sma_50.last
  # Uptrend - only buy signals
  if k < 20 && slowk[-2] < slowd[-2] && slowk[-1] > slowd[-1]
    puts "Uptrend + Oversold Stochastic Crossover = Strong BUY"
  end
elsif current_price < sma_50.last
  # Downtrend - only sell signals
  if k > 80 && slowk[-2] > slowd[-2] && slowk[-1] < slowd[-1]
    puts "Downtrend + Overbought Stochastic Crossover = Strong SELL"
  end
end
```

## Trading Strategies

### 1. Overbought/Oversold
- Buy when Stochastic enters oversold (<20)
- Sell when Stochastic enters overbought (>80)
- Works best in ranging markets

### 2. Crossover
- Buy when %K crosses above %D
- Sell when %K crosses below %D
- Most reliable in extreme zones

### 3. Divergence
- Bullish: Price lower low, Stochastic higher low
- Bearish: Price higher high, Stochastic lower high
- Powerful reversal signals

### 4. Bull/Bear Setup
- Bull setup: %K crosses above %D while both below 50
- Bear setup: %K crosses below %D while both above 50

## Fast vs Slow Stochastic

```ruby
high, low, close = load_ohlc_data('AAPL')

# Slow Stochastic (default, smoother)
slowk, slowd = SQA::TAI.stoch(high, low, close,
                                  fastk_period: 14,
                                  slowk_period: 3,
                                  slowd_period: 3)

# Fast Stochastic (more sensitive)
fastk, fastd = SQA::TAI.stoch(high, low, close,
                                  fastk_period: 14,
                                  slowk_period: 1,
                                  slowd_period: 3)

puts "Slow Stochastic: %K=#{slowk.last.round(2)}, %D=#{slowd.last.round(2)}"
puts "Fast Stochastic: %K=#{fastk.last.round(2)}, %D=#{fastd.last.round(2)}"
```

## Common Settings

| Setting | %K Period | Slowing | %D Period | Use |
|---------|-----------|---------|-----------|-----|
| Fast | 14 | 1 | 3 | Quick signals |
| Slow (Standard) | 14 | 3 | 3 | Balanced |
| Very Slow | 21 | 5 | 5 | Fewer signals |

## Related Indicators

- [RSI](rsi.md) - Similar momentum oscillator
- [MACD](macd.md) - Trend and momentum
- [MOM](mom.md) - Basic momentum

## See Also

- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
- [Momentum Trading Example](../../examples/momentum-trading.md)
