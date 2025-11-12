# Chande Momentum Oscillator (CMO)

The Chande Momentum Oscillator (CMO) is a momentum indicator developed by Tushar Chande that measures the strength and direction of price movement. Unlike RSI which is bounded between 0-100, CMO oscillates between -100 and +100, using the sum of all recent gains and losses rather than averages. This makes CMO more responsive to market changes and provides an unbounded view of momentum strength.

## Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41,
          46.22, 45.64, 46.21, 46.25, 46.08, 46.46]

# Calculate 14-period CMO
cmo = SQA::TAI.cmo(prices, period: 14)

puts "Current CMO: #{cmo.last.round(2)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prices` | Array | Yes | - | Array of price values |
| `period` | Integer | No | 14 | Number of periods for calculation |

## Returns

Returns an array of CMO values ranging from -100 to +100. The first `period` values will be `nil`.

## Interpretation

| CMO Value | Interpretation |
|-----------|----------------|
| +50 to +100 | Strong uptrend / Extremely overbought |
| +25 to +50 | Moderate uptrend / Overbought |
| 0 to +25 | Weak uptrend |
| 0 to -25 | Weak downtrend |
| -25 to -50 | Moderate downtrend / Oversold |
| -50 to -100 | Strong downtrend / Extremely oversold |
| 0 | Neutral - balanced momentum |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

## Example: Basic CMO Trading Signals

```ruby
prices = load_historical_prices('AAPL')

cmo = SQA::TAI.cmo(prices, period: 14)
current_cmo = cmo.last

case current_cmo
when -100...-50
  puts "CMO Extremely Oversold (#{current_cmo.round(2)}) - Strong BUY"
  puts "Intense selling pressure likely to reverse"
when -50...-25
  puts "CMO Oversold (#{current_cmo.round(2)}) - Potential BUY"
when 25...50
  puts "CMO Overbought (#{current_cmo.round(2)}) - Potential SELL"
when 50..100
  puts "CMO Extremely Overbought (#{current_cmo.round(2)}) - Strong SELL"
  puts "Intense buying pressure likely to reverse"
when -10...10
  puts "CMO Neutral (#{current_cmo.round(2)}) - No clear momentum"
else
  puts "CMO at #{current_cmo.round(2)}"
end

# Check momentum direction
if current_cmo > 0
  puts "Positive momentum (buyers in control)"
else
  puts "Negative momentum (sellers in control)"
end
```

## Example: CMO Zero-Line Crossover Strategy

```ruby
prices = load_historical_prices('MSFT')

cmo = SQA::TAI.cmo(prices, period: 14)

current_cmo = cmo.last
prev_cmo = cmo[-2]
prev_prev_cmo = cmo[-3]

# Zero-line crossovers are important trend signals
if prev_cmo < 0 && current_cmo > 0
  puts "CMO crossed above zero - BUY signal"
  puts "Momentum shifted from negative to positive"
  puts "Previous: #{prev_cmo.round(2)} -> Current: #{current_cmo.round(2)}"
elsif prev_cmo > 0 && current_cmo < 0
  puts "CMO crossed below zero - SELL signal"
  puts "Momentum shifted from positive to negative"
  puts "Previous: #{prev_cmo.round(2)} -> Current: #{current_cmo.round(2)}"
end

# Extreme level crossovers
if prev_cmo < 50 && current_cmo >= 50
  puts "CMO crossed above +50 - Extremely strong uptrend"
  puts "Consider taking profits or tightening stops"
elsif prev_cmo > -50 && current_cmo <= -50
  puts "CMO crossed below -50 - Extremely strong downtrend"
  puts "Consider taking profits on shorts or tightening stops"
end

# Momentum acceleration
if current_cmo > prev_cmo && prev_cmo > prev_prev_cmo
  puts "CMO accelerating upward - Momentum building"
elsif current_cmo < prev_cmo && prev_cmo < prev_prev_cmo
  puts "CMO accelerating downward - Momentum declining"
end
```

## Example: CMO Divergence Detection

```ruby
prices = load_historical_prices('TSLA')

cmo = SQA::TAI.cmo(prices, period: 14)

# Find recent highs in price and CMO
price_high_1_idx = prices[-20..-10].index(prices[-20..-10].max) + (prices.length - 20)
price_high_2_idx = prices[-9..-1].index(prices[-9..-1].max) + (prices.length - 9)

price_high_1 = prices[price_high_1_idx]
price_high_2 = prices[price_high_2_idx]

cmo_high_1 = cmo[price_high_1_idx]
cmo_high_2 = cmo[price_high_2_idx]

# Bearish divergence: price makes higher high, CMO makes lower high
if price_high_2 > price_high_1 && cmo_high_2 < cmo_high_1
  puts "Bearish Divergence detected!"
  puts "Price higher high: #{price_high_1.round(2)} -> #{price_high_2.round(2)}"
  puts "CMO lower high: #{cmo_high_1.round(2)} -> #{cmo_high_2.round(2)}"
  puts "Upward momentum weakening despite rising prices"
  puts "Potential reversal signal"
end

# Bullish divergence: price makes lower low, CMO makes higher low
price_low_1_idx = prices[-20..-10].index(prices[-20..-10].min) + (prices.length - 20)
price_low_2_idx = prices[-9..-1].index(prices[-9..-1].min) + (prices.length - 9)

price_low_1 = prices[price_low_1_idx]
price_low_2 = prices[price_low_2_idx]

cmo_low_1 = cmo[price_low_1_idx]
cmo_low_2 = cmo[price_low_2_idx]

if price_low_2 < price_low_1 && cmo_low_2 > cmo_low_1
  puts "Bullish Divergence detected!"
  puts "Price lower low: #{price_low_1.round(2)} -> #{price_low_2.round(2)}"
  puts "CMO higher low: #{cmo_low_1.round(2)} -> #{cmo_low_2.round(2)}"
  puts "Downward momentum weakening despite falling prices"
  puts "Potential reversal signal"
end
```

## Example: CMO vs RSI Comparison

```ruby
prices = load_historical_prices('NVDA')

# Calculate both indicators
cmo = SQA::TAI.cmo(prices, period: 14)
rsi = SQA::TAI.rsi(prices, period: 14)

current_cmo = cmo.last
current_rsi = rsi.last

puts "CMO: #{current_cmo.round(2)}"
puts "RSI: #{current_rsi.round(2)}"

# Convert RSI to same scale as CMO for comparison
# RSI 0-100 -> CMO -100 to +100: (RSI - 50) * 2
rsi_as_cmo = (current_rsi - 50) * 2

puts "RSI as CMO scale: #{rsi_as_cmo.round(2)}"
puts "Difference: #{(current_cmo - rsi_as_cmo).round(2)}"

# CMO is more responsive than RSI
if current_cmo.abs > rsi_as_cmo.abs
  puts "CMO showing stronger momentum than RSI"
  puts "CMO's unbounded nature captures extreme moves better"
elsif rsi_as_cmo.abs > current_cmo.abs
  puts "RSI showing stronger momentum than CMO"
  puts "Unusual - may indicate smoothing effects in RSI"
end

# Both showing extreme readings = high conviction
if current_cmo > 50 && current_rsi > 70
  puts "Both overbought - high conviction sell signal"
elsif current_cmo < -50 && current_rsi < 30
  puts "Both oversold - high conviction buy signal"
end
```

## Example: CMO with Trend Filter

```ruby
prices = load_historical_prices('GOOGL')

cmo = SQA::TAI.cmo(prices, period: 14)
sma_50 = SQA::TAI.sma(prices, period: 50)
sma_200 = SQA::TAI.sma(prices, period: 200)

current_price = prices.last
current_cmo = cmo.last

# Determine overall trend
trend = if sma_50.last > sma_200.last
  "uptrend"
elsif sma_50.last < sma_200.last
  "downtrend"
else
  "neutral"
end

puts "Current trend: #{trend}"
puts "CMO: #{current_cmo.round(2)}"

# Trade with the trend
case trend
when "uptrend"
  # In uptrend, only take bullish CMO signals
  if current_cmo < -25 && current_cmo > -50
    puts "Uptrend + CMO oversold = BUY opportunity"
    puts "Pullback in strong trend"
  elsif current_cmo > 50
    puts "Uptrend + CMO extremely overbought = Take profits"
    puts "Momentum may be overextended"
  elsif current_cmo < 0
    puts "Uptrend but CMO negative = Caution"
    puts "Wait for momentum to turn positive"
  end

when "downtrend"
  # In downtrend, only take bearish CMO signals
  if current_cmo > 25 && current_cmo < 50
    puts "Downtrend + CMO overbought = SELL opportunity"
    puts "Bounce in weak trend"
  elsif current_cmo < -50
    puts "Downtrend + CMO extremely oversold = Cover shorts"
    puts "Downward momentum may be overextended"
  elsif current_cmo > 0
    puts "Downtrend but CMO positive = Caution"
    puts "Wait for momentum to turn negative"
  end

when "neutral"
  # In neutral trend, use traditional overbought/oversold
  if current_cmo > 50
    puts "Neutral trend + CMO overbought = SELL"
  elsif current_cmo < -50
    puts "Neutral trend + CMO oversold = BUY"
  else
    puts "Neutral trend + Neutral CMO = Wait"
  end
end
```

## Advanced Techniques

### 1. CMO Extremes as Continuation Signals
In strong trends, extreme CMO values can indicate continuation rather than reversal:
- CMO > +75 in uptrend = Trend acceleration, not necessarily reversal
- CMO < -75 in downtrend = Trend acceleration, not necessarily reversal

### 2. CMO Rate of Change
Monitor how fast CMO changes:
- Rapid CMO increase = Sudden momentum shift
- Gradual CMO increase = Steady momentum build
- CMO flattening at extremes = Potential exhaustion

### 3. Multiple Timeframe CMO
Use CMO on different timeframes for confirmation:
- Daily CMO for trend
- Hourly CMO for entries
- Weekly CMO for position sizing

### 4. CMO Bands
Create custom bands based on historical CMO values:
- Top 10% of CMO values = Extreme overbought
- Bottom 10% of CMO values = Extreme oversold

## Example: CMO Momentum Breakout Strategy

```ruby
prices = load_historical_prices('AMD')
highs = load_historical_data('AMD', field: :high)
lows = load_historical_data('AMD', field: :low)

cmo = SQA::TAI.cmo(prices, period: 14)

# Calculate recent price range
recent_high = highs[-20..-1].max
recent_low = lows[-20..-1].min

current_price = prices.last
current_cmo = cmo.last
prev_cmo = cmo[-2]

puts "Price Range: #{recent_low.round(2)} - #{recent_high.round(2)}"
puts "Current Price: #{current_price.round(2)}"
puts "CMO: #{current_cmo.round(2)}"

# Bullish breakout with momentum confirmation
if current_price > recent_high && current_cmo > 25
  puts "BULLISH BREAKOUT with momentum confirmation!"
  puts "Price broke above resistance with CMO > +25"
  puts "Strong continuation signal"

  if current_cmo > 50
    puts "Extremely strong momentum - high conviction"
  end

# Bearish breakdown with momentum confirmation
elsif current_price < recent_low && current_cmo < -25
  puts "BEARISH BREAKDOWN with momentum confirmation!"
  puts "Price broke below support with CMO < -25"
  puts "Strong continuation signal"

  if current_cmo < -50
    puts "Extremely strong negative momentum - high conviction"
  end

# False breakout warnings
elsif current_price > recent_high && current_cmo < 0
  puts "WARNING: Price breakout but CMO negative"
  puts "Potential false breakout - momentum not confirming"

elsif current_price < recent_low && current_cmo > 0
  puts "WARNING: Price breakdown but CMO positive"
  puts "Potential false breakdown - momentum not confirming"
end

# Momentum acceleration into breakout
if current_price > recent_high && current_cmo > prev_cmo + 10
  puts "Accelerating momentum into breakout - very bullish"
elsif current_price < recent_low && current_cmo < prev_cmo - 10
  puts "Accelerating momentum into breakdown - very bearish"
end
```

## Example: Multi-Period CMO Analysis

```ruby
prices = load_historical_prices('SPY')

# Calculate multiple periods for comprehensive view
cmo_7 = SQA::TAI.cmo(prices, period: 7)
cmo_14 = SQA::TAI.cmo(prices, period: 14)
cmo_21 = SQA::TAI.cmo(prices, period: 21)
cmo_50 = SQA::TAI.cmo(prices, period: 50)

puts "Short-term CMO (7): #{cmo_7.last.round(2)}"
puts "Standard CMO (14): #{cmo_14.last.round(2)}"
puts "Medium-term CMO (21): #{cmo_21.last.round(2)}"
puts "Long-term CMO (50): #{cmo_50.last.round(2)}"

# All periods aligned = very strong signal
if cmo_7.last > 25 && cmo_14.last > 25 && cmo_21.last > 25 && cmo_50.last > 25
  puts "\nAll timeframes showing positive momentum - STRONG BUY"
  puts "Aligned bullish momentum across all periods"

  if cmo_7.last > 50 && cmo_14.last > 50
    puts "Near-term extremely overbought - consider waiting for pullback"
  end

elsif cmo_7.last < -25 && cmo_14.last < -25 && cmo_21.last < -25 && cmo_50.last < -25
  puts "\nAll timeframes showing negative momentum - STRONG SELL"
  puts "Aligned bearish momentum across all periods"

  if cmo_7.last < -50 && cmo_14.last < -50
    puts "Near-term extremely oversold - shorts may want to cover"
  end
end

# Divergence between timeframes
if cmo_7.last > 25 && cmo_50.last < -25
  puts "\nShort-term bullish but long-term bearish"
  puts "Counter-trend rally - be cautious"

elsif cmo_7.last < -25 && cmo_50.last > 25
  puts "\nShort-term bearish but long-term bullish"
  puts "Pullback in uptrend - potential buying opportunity"
end

# Momentum turning points
if cmo_7.last > 0 && cmo_14.last < 0 && cmo_21.last < 0
  puts "\nMomentum may be turning positive"
  puts "Short-term leading longer-term"

elsif cmo_7.last < 0 && cmo_14.last > 0 && cmo_21.last > 0
  puts "\nMomentum may be turning negative"
  puts "Short-term leading longer-term"
end

# Calculate momentum consistency
cmo_values = [cmo_7.last, cmo_14.last, cmo_21.last, cmo_50.last]
cmo_avg = cmo_values.sum / cmo_values.length
cmo_range = cmo_values.max - cmo_values.min

puts "\nMomentum Consistency:"
puts "Average CMO: #{cmo_avg.round(2)}"
puts "CMO Range: #{cmo_range.round(2)}"

if cmo_range < 20
  puts "Low range - consistent momentum across timeframes"
elsif cmo_range > 50
  puts "High range - conflicting signals across timeframes"
end
```

## Common Settings

| Period | Use Case |
|--------|----------|
| 7 | Short-term trading, quick signals |
| 9 | Day trading |
| 14 | Standard (most common) |
| 20 | Swing trading |
| 50 | Long-term momentum analysis |

## Key Differences from RSI

| Feature | CMO | RSI |
|---------|-----|-----|
| Range | -100 to +100 | 0 to 100 |
| Calculation | Sum of all gains and losses | Exponential average of gains and losses |
| Zero Line | Yes (important reference) | No (uses 50 as midpoint) |
| Sensitivity | More responsive to changes | Smoother, less noise |
| Extreme Values | Can exceed ±50 regularly | Rarely exceeds 80/20 |
| Best For | Trend strength, breakouts | Overbought/oversold conditions |
| Data Usage | All data in period | Weighted/smoothed data |

### CMO Advantages:
- **Unbounded**: Can show true momentum extremes without artificial limits
- **More responsive**: Uses all data equally, catches changes faster
- **Clearer neutral**: Zero line provides obvious momentum direction
- **Better for trends**: Extreme values indicate strong trends rather than just overbought/oversold

### CMO Disadvantages:
- **More volatile**: Can give false signals in choppy markets
- **Harder to interpret**: No fixed overbought/oversold levels
- **Less popular**: Fewer traders use it, less self-fulfilling prophecy effect

## Related Indicators

- [RSI](rsi.md) - Similar momentum oscillator (bounded 0-100)
- [ROC](roc.md) - Rate of Change (percentage based)
- [MOM](mom.md) - Momentum indicator (absolute values)
- [MACD](macd.md) - Moving Average Convergence Divergence
- [Stochastic](stoch.md) - Another momentum oscillator

## See Also

- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
- [Momentum Trading Example](../../examples/momentum-trading.md)
