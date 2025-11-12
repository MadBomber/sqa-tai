# Stochastic Relative Strength Index (STOCHRSI)

The Stochastic RSI is a momentum oscillator that applies the Stochastic formula to RSI values rather than price. It measures the level of RSI relative to its high-low range over a set period, making it more sensitive than standard RSI. StochRSI oscillates between 0 and 100, providing early signals for overbought and oversold conditions.

## Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41,
          46.22, 45.64, 46.21, 46.25, 46.08, 46.46,
          46.55, 47.03, 47.28, 47.61, 48.12, 48.21]

# Calculate Stochastic RSI (returns two arrays)
fastk, fastd = SQA::TAI.stochrsi(prices, period: 14)

puts "FastK: #{fastk.last.round(2)}"
puts "FastD: #{fastd.last.round(2)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prices` | Array | Yes | - | Array of price values |
| `period` | Integer | No | 14 | RSI period for calculation |
| `fastk_period` | Integer | No | 5 | Period for FastK calculation |
| `fastd_period` | Integer | No | 3 | Period for FastD (signal line) |
| `fastd_ma_type` | Integer | No | 0 | Moving average type for FastD (0=SMA) |

## Returns

Returns two arrays:
1. **FastK** - The Stochastic calculation applied to RSI values
2. **FastD** - Signal line (moving average of FastK)

Both values range from 0 to 100.

## Formula

```
1. Calculate RSI over specified period
2. FastK = 100 × (RSI - Lowest RSI) / (Highest RSI - Lowest RSI)
3. FastD = Moving Average of FastK
```

## Interpretation

| Value | Interpretation |
|-------|----------------|
| 80-100 | Overbought - potential sell signal |
| 20-80 | Neutral zone |
| 0-20 | Oversold - potential buy signal |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

**Key Characteristics:**
- More sensitive than standard RSI
- Generates earlier signals
- More prone to false signals in ranging markets
- FastK/FastD crossovers provide additional confirmation

## Example: Basic StochRSI Strategy

```ruby
prices = load_historical_prices('AAPL')

fastk, fastd = SQA::TAI.stochrsi(prices, period: 14)

k = fastk.last
d = fastd.last

if k < 20 && d < 20
  puts "Oversold: FastK=#{k.round(2)}, FastD=#{d.round(2)}"
  if k > d
    puts "Bullish crossover in oversold zone - BUY signal"
  end
elsif k > 80 && d > 80
  puts "Overbought: FastK=#{k.round(2)}, FastD=#{d.round(2)}"
  if k < d
    puts "Bearish crossover in overbought zone - SELL signal"
  end
end
```

## Example: StochRSI Crossovers

```ruby
prices = load_historical_prices('TSLA')

fastk, fastd = SQA::TAI.stochrsi(prices, period: 14)

# Detect crossovers
if fastk[-2] < fastd[-2] && fastk[-1] > fastd[-1]
  zone = case fastk[-1]
         when 0...20 then "oversold"
         when 20...80 then "neutral"
         else "overbought"
         end

  puts "Bullish crossover in #{zone} zone"
  puts "FastK crossed above FastD at #{fastk[-1].round(2)}"

  if fastk[-1] < 20
    puts "Strong BUY signal - oversold crossover"
  else
    puts "Moderate BUY signal"
  end
elsif fastk[-2] > fastd[-2] && fastk[-1] < fastd[-1]
  zone = case fastk[-1]
         when 0...20 then "oversold"
         when 20...80 then "neutral"
         else "overbought"
         end

  puts "Bearish crossover in #{zone} zone"
  puts "FastK crossed below FastD at #{fastk[-1].round(2)}"

  if fastk[-1] > 80
    puts "Strong SELL signal - overbought crossover"
  else
    puts "Moderate SELL signal"
  end
end
```

## Example: StochRSI Extremes

```ruby
prices = load_historical_prices('NVDA')

fastk, fastd = SQA::TAI.stochrsi(prices, period: 14)

# Count consecutive bars in extreme zones
oversold_bars = 0
overbought_bars = 0

fastk.last(10).each do |value|
  next if value.nil?
  oversold_bars += 1 if value < 20
  overbought_bars += 1 if value > 80
end

if oversold_bars >= 3
  puts "StochRSI oversold for #{oversold_bars} consecutive bars"
  puts "High probability of reversal to upside"
  puts "Wait for FastK to cross above 20 for confirmation"
elsif overbought_bars >= 3
  puts "StochRSI overbought for #{overbought_bars} consecutive bars"
  puts "High probability of reversal to downside"
  puts "Wait for FastK to cross below 80 for confirmation"
end
```

## Example: StochRSI with Trend Filter

```ruby
prices = load_historical_prices('MSFT')

fastk, fastd = SQA::TAI.stochrsi(prices, period: 14)
ema_50 = SQA::TAI.ema(prices, period: 50)
ema_200 = SQA::TAI.ema(prices, period: 200)

current_price = prices.last
k = fastk.last
d = fastd.last

# Determine trend
trend = if current_price > ema_50.last && ema_50.last > ema_200.last
          :strong_uptrend
        elsif current_price > ema_50.last
          :uptrend
        elsif current_price < ema_50.last && ema_50.last < ema_200.last
          :strong_downtrend
        else
          :downtrend
        end

puts <<~OUTPUT
  Trend: #{trend}
  Price: #{current_price.round(2)}
  StochRSI FastK: #{k.round(2)}
  StochRSI FastD: #{d.round(2)}
OUTPUT

case trend
when :strong_uptrend, :uptrend
  # Only look for oversold buy signals in uptrend
  if k < 20 && fastk[-2] < fastd[-2] && fastk[-1] > fastd[-1]
    puts "#{trend.to_s.upcase} + Oversold StochRSI crossover = Strong BUY"
  end
when :strong_downtrend, :downtrend
  # Only look for overbought sell signals in downtrend
  if k > 80 && fastk[-2] > fastd[-2] && fastk[-1] < fastd[-1]
    puts "#{trend.to_s.upcase} + Overbought StochRSI crossover = Strong SELL"
  end
end
```

## Example: StochRSI Divergence

```ruby
prices = load_historical_prices('AMZN')

fastk, fastd = SQA::TAI.stochrsi(prices, period: 14)

# Find recent highs
price_high_1 = prices[-40..-20].max
price_high_2 = prices[-19..-1].max

stoch_high_1 = fastk[-40..-20].compact.max
stoch_high_2 = fastk[-19..-1].compact.max

# Bearish divergence: price higher high, StochRSI lower high
if price_high_2 > price_high_1 && stoch_high_2 < stoch_high_1
  puts "Bearish Divergence detected!"
  puts "Price higher high: #{price_high_1.round(2)} -> #{price_high_2.round(2)}"
  puts "StochRSI lower high: #{stoch_high_1.round(2)} -> #{stoch_high_2.round(2)}"
  puts "Potential reversal to downside"
end

# Find recent lows
price_low_1 = prices[-40..-20].min
price_low_2 = prices[-19..-1].min

stoch_low_1 = fastk[-40..-20].compact.min
stoch_low_2 = fastk[-19..-1].compact.min

# Bullish divergence: price lower low, StochRSI higher low
if price_low_2 < price_low_1 && stoch_low_2 > stoch_low_1
  puts "Bullish Divergence detected!"
  puts "Price lower low: #{price_low_1.round(2)} -> #{price_low_2.round(2)}"
  puts "StochRSI higher low: #{stoch_low_1.round(2)} -> #{stoch_low_2.round(2)}"
  puts "Potential reversal to upside"
end
```

## Example: StochRSI with RSI Confirmation

```ruby
prices = load_historical_prices('GOOGL')

# Calculate both indicators
fastk, fastd = SQA::TAI.stochrsi(prices, period: 14)
rsi = SQA::TAI.rsi(prices, period: 14)

k = fastk.last
d = fastd.last
rsi_value = rsi.last

puts <<~OUTPUT
  StochRSI FastK: #{k.round(2)}
  StochRSI FastD: #{d.round(2)}
  RSI: #{rsi_value.round(2)}
OUTPUT

# Strong signals when both indicators agree
if k < 20 && rsi_value < 30
  puts "Both StochRSI and RSI oversold - Very Strong BUY signal"
  if fastk[-2] < fastd[-2] && fastk[-1] > fastd[-1]
    puts "StochRSI crossover adds confirmation"
  end
elsif k > 80 && rsi_value > 70
  puts "Both StochRSI and RSI overbought - Very Strong SELL signal"
  if fastk[-2] > fastd[-2] && fastk[-1] < fastd[-1]
    puts "StochRSI crossover adds confirmation"
  end
elsif k < 20 && rsi_value > 50
  puts "StochRSI oversold but RSI neutral - Wait for RSI confirmation"
elsif k > 80 && rsi_value < 50
  puts "StochRSI overbought but RSI neutral - Wait for RSI confirmation"
end
```

## Example: Multiple Timeframe StochRSI

```ruby
# Assuming you have different timeframe data
daily_prices = load_historical_prices('AAPL', timeframe: 'daily')
hourly_prices = load_historical_prices('AAPL', timeframe: 'hourly')

daily_k, daily_d = SQA::TAI.stochrsi(daily_prices, period: 14)
hourly_k, hourly_d = SQA::TAI.stochrsi(hourly_prices, period: 14)

puts <<~OUTPUT
  Daily StochRSI: K=#{daily_k.last.round(2)}, D=#{daily_d.last.round(2)}
  Hourly StochRSI: K=#{hourly_k.last.round(2)}, D=#{hourly_d.last.round(2)}
OUTPUT

# Strongest signals when both timeframes align
if daily_k.last < 30 && hourly_k.last < 20
  puts "Multi-timeframe oversold alignment - Strong buy setup"
  if hourly_k[-2] < hourly_d[-2] && hourly_k[-1] > hourly_d[-1]
    puts "Hourly crossover triggers entry"
  end
elsif daily_k.last > 70 && hourly_k.last > 80
  puts "Multi-timeframe overbought alignment - Strong sell setup"
  if hourly_k[-2] > hourly_d[-2] && hourly_k[-1] < hourly_d[-1]
    puts "Hourly crossover triggers entry"
  end
end
```

## Trading Strategies

### 1. Overbought/Oversold Extremes
- Buy when StochRSI drops below 20 (oversold)
- Sell when StochRSI rises above 80 (overbought)
- More sensitive than regular RSI
- Best in trending markets

### 2. FastK/FastD Crossovers
- Buy when FastK crosses above FastD (especially in oversold zone)
- Sell when FastK crosses below FastD (especially in overbought zone)
- Most reliable crossovers occur near extremes
- Confirm with price action

### 3. Divergence Trading
- Bullish divergence: Price makes lower low, StochRSI makes higher low
- Bearish divergence: Price makes higher high, StochRSI makes lower high
- Powerful reversal signals
- Requires patience for setup

### 4. Zero-Line Rejection
- Buy when StochRSI bounces off 0-10 level without full reversal
- Sell when StochRSI bounces off 90-100 level without full reversal
- Indicates strong momentum continuation

### 5. Midline Cross
- Buy when StochRSI crosses above 50 from below
- Sell when StochRSI crosses below 50 from above
- Indicates momentum shift

## Advanced Techniques

### 1. StochRSI Range Adjustment
Adjust overbought/oversold levels based on market conditions:
- Strong bull market: Use 85/25 instead of 80/20
- Strong bear market: Use 75/15 instead of 80/20
- Volatile markets: Use 90/10 for fewer, stronger signals

### 2. Multiple Confirmations
Wait for multiple signals before entering:
- StochRSI extreme + crossover
- StochRSI extreme + divergence + crossover
- StochRSI + RSI agreement

### 3. Time-Based Filters
Count bars in extreme zones:
- 3+ bars oversold = stronger reversal signal
- 3+ bars overbought = stronger reversal signal

## StochRSI vs RSI vs Stochastic

```ruby
prices = load_historical_prices('META')
high, low, close = load_ohlc_data('META')

# Calculate all three
stoch_rsi_k, stoch_rsi_d = SQA::TAI.stochrsi(prices, period: 14)
rsi = SQA::TAI.rsi(prices, period: 14)
stoch_k, stoch_d = SQA::TAI.stoch(high, low, close)

puts <<~COMPARISON
  === Indicator Comparison ===
  StochRSI K: #{stoch_rsi_k.last.round(2)} (most sensitive)
  RSI:         #{rsi.last.round(2)} (moderate)
  Stochastic:  #{stoch_k.last.round(2)} (price-based)

  StochRSI measures RSI momentum
  RSI measures price momentum
  Stochastic measures price position in range
COMPARISON

# All three oversold = strongest buy signal
if stoch_rsi_k.last < 20 && rsi.last < 30 && stoch_k.last < 20
  puts "\nAll three indicators oversold - MAXIMUM BUY SIGNAL"
elsif stoch_rsi_k.last > 80 && rsi.last > 70 && stoch_k.last > 80
  puts "\nAll three indicators overbought - MAXIMUM SELL SIGNAL"
end
```

## Common Settings

| Setting | RSI Period | FastK | FastD | Use Case |
|---------|-----------|-------|-------|----------|
| Standard | 14 | 5 | 3 | Balanced approach |
| Sensitive | 14 | 3 | 3 | Quick signals |
| Smooth | 14 | 7 | 5 | Fewer false signals |
| Long-term | 21 | 8 | 5 | Position trading |

## Advantages and Limitations

### Advantages
- More sensitive than standard RSI
- Provides earlier signals
- Combines benefits of RSI and Stochastic
- Excellent for timing entries/exits
- Works well with trend filters

### Limitations
- More prone to false signals
- Can whipsaw in ranging markets
- May signal reversals too early
- Requires confirmation from other indicators
- Not suitable as standalone indicator

## Best Practices

1. **Use with Trend Filter**: Only take signals aligned with the major trend
2. **Wait for Extremes**: Focus on signals in overbought (>80) or oversold (<20) zones
3. **Confirm with Crossovers**: Wait for FastK/FastD crossover for stronger confirmation
4. **Check Multiple Timeframes**: Align signals across timeframes
5. **Combine with Volume**: Stronger signals when accompanied by volume confirmation
6. **Set Realistic Targets**: StochRSI is for timing, not for predicting magnitude
7. **Use Stop Losses**: Protect against false signals with appropriate stops

## Related Indicators

- [RSI](rsi.md) - Base indicator for StochRSI calculation
- [Stochastic](stoch.md) - Original Stochastic formula
- [MACD](macd.md) - Complementary momentum indicator
- [MFI](mfi.md) - Volume-weighted RSI variant

## See Also

- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
- [Momentum Trading Example](../../examples/momentum-trading.md)
