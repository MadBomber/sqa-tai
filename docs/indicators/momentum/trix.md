# TRIX (Triple Exponential Average)

TRIX is a momentum oscillator that measures the 1-day rate of change of a triple-smoothed exponential moving average. The triple smoothing process filters out market noise and short-term fluctuations, making TRIX excellent for identifying significant trend changes with minimal whipsaws.

## Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41,
          46.22, 45.64, 46.21, 46.25, 46.08, 46.46,
          46.57, 45.95, 46.50, 46.02, 46.55, 47.03,
          47.35, 47.28, 47.61, 48.12, 48.34, 48.21,
          48.75, 48.90, 49.25, 49.50, 49.75, 50.00]

# Calculate 30-period TRIX
trix = SQA::TAI.trix(prices, period: 30)

puts "Current TRIX: #{trix.last.round(6)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prices` | Array | Yes | - | Array of price values |
| `period` | Integer | No | 30 | Number of periods for triple EMA calculation |

## Returns

Returns an array of TRIX values. Values are typically very small decimals (often shown as percentages by multiplying by 100). Due to triple smoothing, the first `period * 3` values will be `nil`.

## Formula

```
Step 1: Single EMA = EMA(prices, period)
Step 2: Double EMA = EMA(Single EMA, period)
Step 3: Triple EMA = EMA(Double EMA, period)
Step 4: TRIX = 1-day ROC of Triple EMA = ((Triple EMA today / Triple EMA yesterday) - 1) * 100
```

## Interpretation

| TRIX Value | Interpretation |
|------------|----------------|
| Positive | Upward momentum - bullish |
| Negative | Downward momentum - bearish |
| Zero crossover from below | Buy signal |
| Zero crossover from above | Sell signal |
| Increasing | Momentum strengthening |
| Decreasing | Momentum weakening |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

### Typical Range
TRIX values are unbounded but typically range between -0.5 and +0.5. In strong trends, values may exceed this range.

## Example: TRIX Zero-Line Crossovers

```ruby
prices = load_historical_prices('AAPL')

trix = SQA::TAI.trix(prices, period: 30)

# Check for zero-line crossovers
if trix[-2] < 0 && trix[-1] > 0
  puts "TRIX Bullish Crossover - BUY signal"
  puts "TRIX crossed above zero: #{trix[-1].round(6)}"
  puts "Trend changing from bearish to bullish"
elsif trix[-2] > 0 && trix[-1] < 0
  puts "TRIX Bearish Crossover - SELL signal"
  puts "TRIX crossed below zero: #{trix[-1].round(6)}"
  puts "Trend changing from bullish to bearish"
end

# Current momentum state
if trix.last > 0
  puts "TRIX positive: Bullish momentum"
else
  puts "TRIX negative: Bearish momentum"
end
```

## Example: TRIX with Signal Line

```ruby
prices = load_historical_prices('TSLA')

trix = SQA::TAI.trix(prices, period: 30)

# Create 9-period signal line (EMA of TRIX)
signal = SQA::TAI.ema(trix.compact, period: 9)

# Pad signal line to match TRIX length
nil_count = trix.count(nil)
signal = [nil] * nil_count + signal

# Check for TRIX/Signal crossovers
if trix[-2] < signal[-2] && trix[-1] > signal[-1]
  puts "TRIX crossed above Signal - BUY signal"
  puts "TRIX: #{trix[-1].round(6)}, Signal: #{signal[-1].round(6)}"
elsif trix[-2] > signal[-2] && trix[-1] < signal[-1]
  puts "TRIX crossed below Signal - SELL signal"
  puts "TRIX: #{trix[-1].round(6)}, Signal: #{signal[-1].round(6)}"
end
```

## Example: TRIX Divergence Detection

```ruby
prices = load_historical_prices('MSFT')

trix = SQA::TAI.trix(prices, period: 30)

# Find recent highs in price and TRIX
price_high_1 = prices[-60..-30].max
price_high_2 = prices[-29..-1].max

trix_high_1_idx = prices[-60..-30].index(price_high_1) - 60
trix_high_2_idx = prices[-29..-1].index(price_high_2) - 29

trix_high_1 = trix[trix_high_1_idx]
trix_high_2 = trix[trix_high_2_idx]

# Bearish divergence: price makes higher high, TRIX makes lower high
if price_high_2 > price_high_1 && trix_high_2 < trix_high_1
  puts "Bearish Divergence detected!"
  puts "Price higher high: #{price_high_1.round(2)} -> #{price_high_2.round(2)}"
  puts "TRIX lower high: #{trix_high_1.round(6)} -> #{trix_high_2.round(6)}"
  puts "Warning: Uptrend may be losing momentum"
end

# Bullish divergence: price makes lower low, TRIX makes higher low
price_low_1 = prices[-60..-30].min
price_low_2 = prices[-29..-1].min

trix_low_1_idx = prices[-60..-30].index(price_low_1) - 60
trix_low_2_idx = prices[-29..-1].index(price_low_2) - 29

trix_low_1 = trix[trix_low_1_idx]
trix_low_2 = trix[trix_low_2_idx]

if price_low_2 < price_low_1 && trix_low_2 > trix_low_1
  puts "Bullish Divergence detected!"
  puts "Price lower low: #{price_low_1.round(2)} -> #{price_low_2.round(2)}"
  puts "TRIX higher low: #{trix_low_1.round(6)} -> #{trix_low_2.round(6)}"
  puts "Potential trend reversal to the upside"
end
```

## Example: TRIX Momentum Strength

```ruby
prices = load_historical_prices('NVDA')

trix = SQA::TAI.trix(prices, period: 30)

# Analyze TRIX momentum changes
recent_trix = trix.compact.last(10)

# Check if momentum is accelerating
trix_changes = recent_trix.each_cons(2).map { |a, b| b - a }

if trix.last > 0 && trix_changes.last(3).all? { |c| c > 0 }
  puts "Bullish momentum accelerating"
  puts "TRIX: #{trix.last.round(6)}"
  puts "Last 3 changes: #{trix_changes.last(3).map { |c| c.round(6) }}"
  puts "Strong uptrend in progress"
elsif trix.last < 0 && trix_changes.last(3).all? { |c| c < 0 }
  puts "Bearish momentum accelerating"
  puts "TRIX: #{trix.last.round(6)}"
  puts "Last 3 changes: #{trix_changes.last(3).map { |c| c.round(6) }}"
  puts "Strong downtrend in progress"
elsif trix.last > 0 && trix_changes.last(3).any? { |c| c < 0 }
  puts "Bullish momentum weakening"
  puts "Consider taking profits"
elsif trix.last < 0 && trix_changes.last(3).any? { |c| c > 0 }
  puts "Bearish momentum weakening"
  puts "Downtrend may be exhausting"
end
```

## Example: TRIX Triple-Smoothed Trend Confirmation

```ruby
prices = load_historical_prices('GOOGL')

# Multiple TRIX periods for confirmation
trix_short = SQA::TAI.trix(prices, period: 15)  # More responsive
trix_medium = SQA::TAI.trix(prices, period: 30) # Standard
trix_long = SQA::TAI.trix(prices, period: 60)   # Less responsive

# All three TRIX values positive = strong bullish trend
if trix_short.last > 0 && trix_medium.last > 0 && trix_long.last > 0
  puts "Triple TRIX Confirmation: STRONG BULLISH"
  puts "Short (15): #{trix_short.last.round(6)}"
  puts "Medium (30): #{trix_medium.last.round(6)}"
  puts "Long (60): #{trix_long.last.round(6)}"
  puts "All timeframes show positive momentum"
elsif trix_short.last < 0 && trix_medium.last < 0 && trix_long.last < 0
  puts "Triple TRIX Confirmation: STRONG BEARISH"
  puts "Short (15): #{trix_short.last.round(6)}"
  puts "Medium (30): #{trix_medium.last.round(6)}"
  puts "Long (60): #{trix_long.last.round(6)}"
  puts "All timeframes show negative momentum"
elsif trix_short.last > 0 && trix_medium.last > 0 && trix_long.last < 0
  puts "Early bullish momentum developing"
  puts "Short and medium term positive, long term still negative"
  puts "Monitor for long-term TRIX to turn positive"
end
```

## Trading Strategies

### 1. Zero-Line Crossover (Primary Strategy)
- **Buy Signal**: TRIX crosses above zero from below
- **Sell Signal**: TRIX crosses below zero from above
- Most reliable TRIX signals
- Minimal whipsaws due to triple smoothing

### 2. Signal Line Crossover
- **Buy Signal**: TRIX crosses above its signal line (typically 9-period EMA)
- **Sell Signal**: TRIX crosses below its signal line
- Earlier signals than zero-line crossovers
- More signals but also more false positives

### 3. Divergence Trading
- **Bullish Divergence**: Price makes lower low, TRIX makes higher low
- **Bearish Divergence**: Price makes higher high, TRIX makes lower high
- Powerful reversal signals
- Works best at trend extremes

### 4. Directional Filter
- **Long Positions Only**: When TRIX > 0
- **Short Positions Only**: When TRIX < 0
- Use TRIX as trend filter for other strategies
- Keeps you on the right side of the trend

## TRIX Settings

### Short-term (15 periods)
- More sensitive to price changes
- More signals and crossovers
- Better for swing trading
- Higher risk of false signals

### Standard (30 periods)
- Balance of responsiveness and reliability
- Most commonly used setting
- Good for medium-term trends
- Developed by Jack Hutson

### Long-term (60 periods)
- Very smooth, minimal whipsaws
- Fewer but more reliable signals
- Best for identifying major trends
- Lags during rapid trend changes

## Advantages of TRIX

1. **Noise Filtering**: Triple smoothing eliminates most market noise
2. **Minimal Whipsaws**: Fewer false signals than single or double smoothed indicators
3. **Clear Signals**: Zero-line crossovers are unambiguous
4. **Leading Indicator**: Can signal trend changes before price
5. **Versatile**: Works across different timeframes and markets

## Combining with Other Indicators

```ruby
prices = load_historical_prices('AAPL')

# TRIX for smoothed momentum
trix = SQA::TAI.trix(prices, period: 30)

# RSI for overbought/oversold
rsi = SQA::TAI.rsi(prices, period: 14)

# Volume confirmation
volumes = load_historical_volumes('AAPL')
volume_sma = SQA::TAI.sma(volumes, period: 20)

current_price = prices.last
current_volume = volumes.last

# Strong buy when TRIX bullish with volume confirmation
if trix[-2] < 0 && trix[-1] > 0 &&        # TRIX zero crossover
   rsi.last < 70 &&                        # Not overbought
   current_volume > volume_sma.last * 1.2  # Above average volume
  puts "Strong BUY signal - TRIX crossover with volume"
  puts "TRIX: #{trix.last.round(6)}"
  puts "RSI: #{rsi.last.round(2)}"
  puts "Volume: #{(current_volume / volume_sma.last * 100).round(0)}% of average"
end
```

## Common Pitfalls

1. **Lag**: Triple smoothing creates significant lag - TRIX is not for scalping
2. **Period Selection**: Too short = more noise, too long = excessive lag
3. **Range-Bound Markets**: TRIX works best in trending markets
4. **Confirmation**: Always use with price action or other indicators
5. **Early Exits**: Don't exit on first sign of TRIX weakening in strong trends

## TRIX vs Other Momentum Indicators

| Feature | TRIX | MACD | RSI |
|---------|------|------|-----|
| Smoothing | Triple | Double | Single |
| Lag | High | Medium | Low |
| Whipsaws | Very Few | Some | Many |
| Range | Unbounded | Unbounded | 0-100 |
| Best For | Trend following | Momentum shifts | Extremes |

## Related Indicators

- [MACD](macd.md) - Double-smoothed momentum indicator
- [EMA](../overlap/ema.md) - Used in TRIX calculation
- [ROC](roc.md) - Rate of change (single smoothing)
- [PPO](ppo.md) - Percentage price oscillator

## See Also

- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
- [Momentum Trading Example](../../examples/momentum-trading.md)
