# Directional Movement Index (DX)

The Directional Movement Index (DX) measures the strength of directional movement in a price trend, regardless of direction. Developed by J. Welles Wilder as part of the Directional Movement System, DX is the raw calculation used to derive the Average Directional Index (ADX). It quantifies how strongly price is moving in a particular direction by comparing the Plus Directional Indicator (+DI) and Minus Directional Indicator (-DI).

## Formula

DX is calculated using the directional indicators:
1. Calculate +DM (Plus Directional Movement) = Current High - Previous High (if positive and greater than downward movement)
2. Calculate -DM (Minus Directional Movement) = Previous Low - Current Low (if positive and greater than upward movement)
3. Calculate True Range (TR) = max(High-Low, |High-PrevClose|, |Low-PrevClose|)
4. Calculate +DI = (Smoothed +DM / Smoothed TR) * 100
5. Calculate -DI = (Smoothed -DM / Smoothed TR) * 100
6. DX = |(+DI - -DI)| / (+DI + -DI) * 100

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `high` | Array<Float> | Yes | - | Array of high prices |
| `low` | Array<Float> | Yes | - | Array of low prices |
| `close` | Array<Float> | Yes | - | Array of close prices |
| `period` | Integer | No | 14 | Number of periods for smoothing |

## Returns

Returns an array of DX values ranging from 0 to 100.

## Usage

```ruby
require 'sqa/tai'

high =  [48.70, 48.72, 48.90, 48.87, 48.82, 49.05, 49.20, 49.35, 49.92, 50.19, 50.12, 50.10, 50.00, 49.75, 49.80]
low =   [47.79, 48.14, 48.39, 48.37, 48.24, 48.64, 48.94, 49.03, 49.50, 49.87, 49.20, 49.00, 48.90, 49.00, 49.10]
close = [48.20, 48.61, 48.75, 48.63, 48.74, 49.03, 49.07, 49.32, 49.91, 50.13, 49.53, 49.50, 49.25, 49.20, 49.45]

dx = SQA::TAI.dx(high, low, close, period: 14)

puts "Current DX: #{dx.last.round(2)}"
```

## Interpretation

| DX Value | Directional Strength |
|----------|---------------------|
| 0-25 | Weak or absent directional movement (ranging market) |
| 25-50 | Moderate directional movement (developing trend) |
| 50-75 | Strong directional movement (established trend) |
| 75-100 | Very strong directional movement (powerful trend) |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

**Key Points:**
- DX measures the *strength* of directional movement, not direction
- Higher DX = stronger trend (either up or down)
- Lower DX = weaker trend or ranging market
- DX > 25 typically indicates meaningful directional movement
- DX is volatile; ADX smooths DX for easier interpretation

## Example: Basic DX Analysis

```ruby
high, low, close = load_historical_ohlc('AAPL')
dx = SQA::TAI.dx(high, low, close, period: 14)

current_dx = dx.last

case current_dx
when 0...25
  puts "WEAK DIRECTIONAL MOVEMENT (DX: #{current_dx.round(2)})"
  puts "Market is ranging or consolidating"
  puts "Trend-following strategies not recommended"
when 25...50
  puts "MODERATE DIRECTIONAL MOVEMENT (DX: #{current_dx.round(2)})"
  puts "Developing trend - monitor for confirmation"
when 50...75
  puts "STRONG DIRECTIONAL MOVEMENT (DX: #{current_dx.round(2)})"
  puts "Established trend - good for trend following"
else
  puts "VERY STRONG DIRECTIONAL MOVEMENT (DX: #{current_dx.round(2)})"
  puts "Powerful trend - potential exhaustion watch"
end
```

## Example: DX with Directional Indicators

```ruby
high, low, close = load_historical_ohlc('SPY')

dx = SQA::TAI.dx(high, low, close, period: 14)
plus_di = SQA::TAI.plus_di(high, low, close, period: 14)
minus_di = SQA::TAI.minus_di(high, low, close, period: 14)

current_dx = dx.last
current_plus = plus_di.last
current_minus = minus_di.last

# Calculate directional movement spread
di_spread = (current_plus - current_minus).abs

puts "DX: #{current_dx.round(2)}"
puts "+DI: #{current_plus.round(2)}"
puts "-DI: #{current_minus.round(2)}"
puts "DI Spread: #{di_spread.round(2)}"

# Identify trend direction and strength
if current_dx > 25
  if current_plus > current_minus
    puts "STRONG UPWARD DIRECTIONAL MOVEMENT"
    puts "Bullish trend with #{current_dx.round(2)} strength"
  else
    puts "STRONG DOWNWARD DIRECTIONAL MOVEMENT"
    puts "Bearish trend with #{current_dx.round(2)} strength"
  end
else
  puts "WEAK DIRECTIONAL MOVEMENT"
  puts "No clear trend - market consolidating"
  puts "+DI and -DI relatively balanced"
end

# High DX indicates one DI dominates
if current_dx > 50
  puts "Very high DI divergence - one direction dominates"
end
```

## Example: DX Spike Detection

```ruby
high, low, close = load_historical_ohlc('TSLA')
dx = SQA::TAI.dx(high, low, close, period: 14)

current_dx = dx.last
prev_dx = dx[-2]
dx_5_ago = dx[-6]

dx_change = current_dx - prev_dx
dx_5_change = current_dx - dx_5_ago

puts "Current DX: #{current_dx.round(2)}"
puts "Previous DX: #{prev_dx.round(2)}"
puts "Change: #{dx_change.round(2)}"

# Detect rapid DX increases (trend development)
if dx_change > 10 && current_dx > 25
  puts "SHARP DX INCREASE - New trend forming!"
  puts "Directional movement accelerating"
elsif dx_change < -10 && current_dx < 25
  puts "SHARP DX DECREASE - Trend weakening"
  puts "Entering range-bound conditions"
end

# Sustained DX increase over multiple periods
if dx_5_change > 20
  puts "DX rising strongly over 5 periods"
  puts "Trend gaining momentum consistently"
end

# DX spikes and reversal
if current_dx > 60 && prev_dx > 60 && dx_change < 0
  puts "DX declining from very high levels"
  puts "Possible trend exhaustion - watch for reversal"
end
```

## Example: DX Divergence Analysis

```ruby
high, low, close = load_historical_ohlc('NVDA')

dx = SQA::TAI.dx(high, low, close, period: 14)
plus_di = SQA::TAI.plus_di(high, low, close, period: 14)
minus_di = SQA::TAI.minus_di(high, low, close, period: 14)

# Find price and DX peaks
price_high_1 = close[-20..-10].max
price_high_2 = close[-9..-1].max

dx_high_1 = dx[-20..-10].compact.max
dx_high_2 = dx[-9..-1].compact.max

# Bearish divergence: price higher high, DX lower high
if price_high_2 > price_high_1 && dx_high_2 < dx_high_1
  puts "BEARISH DIVERGENCE DETECTED"
  puts "Price higher high: #{price_high_1.round(2)} -> #{price_high_2.round(2)}"
  puts "DX lower high: #{dx_high_1.round(2)} -> #{dx_high_2.round(2)}"
  puts "Directional strength weakening despite higher prices"
  puts "Warning: Trend may be losing momentum"
end

# Bullish divergence: price lower low, DX higher low
price_low_1 = close[-20..-10].min
price_low_2 = close[-9..-1].min

dx_low_1 = dx[-20..-10].compact.min
dx_low_2 = dx[-9..-1].compact.min

if price_low_2 < price_low_1 && dx_low_2 > dx_low_1
  puts "BULLISH DIVERGENCE DETECTED"
  puts "Price lower low: #{price_low_1.round(2)} -> #{price_low_2.round(2)}"
  puts "DX higher low: #{dx_low_1.round(2)} -> #{dx_low_2.round(2)}"
  puts "Directional strength building despite lower prices"
  puts "Potential trend reversal forming"
end
```

## Example: DX Breakout Confirmation

```ruby
high, low, close = load_historical_ohlc('MSFT')

dx = SQA::TAI.dx(high, low, close, period: 14)
plus_di = SQA::TAI.plus_di(high, low, close, period: 14)

# Identify resistance breakout
resistance = 250.00
current_price = close.last
prev_price = close[-2]

current_dx = dx.last
prev_dx = dx[-2]

# Price breaks resistance
if current_price > resistance && prev_price <= resistance
  puts "PRICE BREAKOUT at #{current_price.round(2)}"

  # Check DX confirmation
  if current_dx > 25 && current_dx > prev_dx
    puts "DX CONFIRMS BREAKOUT (#{current_dx.round(2)})"
    puts "Strong directional movement supporting breakout"
    puts "High probability of sustained move"
  elsif current_dx < 20
    puts "WARNING: DX LOW (#{current_dx.round(2)})"
    puts "Weak directional strength - false breakout risk"
    puts "Wait for DX to rise above 25 for confirmation"
  else
    puts "DX moderate (#{current_dx.round(2)})"
    puts "Monitor for DX increase to confirm trend"
  end

  # Check directional indicator alignment
  if plus_di.last > minus_di.last
    puts "+DI > -DI: Directional indicators support upside"
  end
end
```

## Example: DX vs ADX Comparison

```ruby
high, low, close = load_historical_ohlc('GOOGL')

dx = SQA::TAI.dx(high, low, close, period: 14)
adx = SQA::TAI.adx(high, low, close, period: 14)

current_dx = dx.last
current_adx = adx.last

puts "DX (raw): #{current_dx.round(2)}"
puts "ADX (smoothed): #{current_adx.round(2)}"
puts "Difference: #{(current_dx - current_adx).round(2)}"

# DX is more volatile, ADX is smoother
if current_dx > current_adx + 20
  puts "DX SPIKE above ADX"
  puts "Recent surge in directional strength"
  puts "New trend developing - ADX will follow"
elsif current_dx < current_adx - 10
  puts "DX BELOW ADX"
  puts "Recent directional weakness"
  puts "Trend may be losing steam"
else
  puts "DX and ADX aligned"
  puts "Consistent directional movement"
end

# Track DX volatility
dx_volatility = dx[-10..-1].compact.map { |v| (v - current_adx).abs }.sum / 10
puts "DX volatility around ADX: #{dx_volatility.round(2)}"

if dx_volatility > 15
  puts "High DX volatility - choppy directional changes"
elsif dx_volatility < 5
  puts "Low DX volatility - stable directional trend"
end
```

## Example: Multi-Period DX Analysis

```ruby
high, low, close = load_historical_ohlc('AMZN')

# Calculate multiple periods
dx_7 = SQA::TAI.dx(high, low, close, period: 7)
dx_14 = SQA::TAI.dx(high, low, close, period: 14)
dx_21 = SQA::TAI.dx(high, low, close, period: 21)

puts "Short-term DX (7): #{dx_7.last.round(2)}"
puts "Standard DX (14): #{dx_14.last.round(2)}"
puts "Long-term DX (21): #{dx_21.last.round(2)}"

# All periods strong = very strong trend
if dx_7.last > 40 && dx_14.last > 40 && dx_21.last > 40
  puts "ALL TIMEFRAMES SHOW STRONG DIRECTIONAL MOVEMENT"
  puts "Established, powerful trend across all periods"
elsif dx_7.last < 20 && dx_14.last < 20 && dx_21.last < 20
  puts "ALL TIMEFRAMES SHOW WEAK DIRECTIONAL MOVEMENT"
  puts "Strong range-bound market - avoid trend strategies"
end

# Divergence between timeframes
if dx_7.last > 50 && dx_21.last < 30
  puts "Short-term DX strong, long-term weak"
  puts "Recent surge in directional movement"
  puts "New trend potentially forming"
elsif dx_7.last < 25 && dx_21.last > 40
  puts "Short-term DX weak, long-term strong"
  puts "Recent consolidation in established trend"
  puts "Potential continuation after pause"
end

# Calculate DX slope across periods
dx_trend = (dx_7.last + dx_14.last + dx_21.last) / 3
puts "Average DX across periods: #{dx_trend.round(2)}"
```

## Common Settings

| Period | Use Case |
|--------|----------|
| 7 | Short-term, sensitive to recent changes |
| 14 | Standard (Wilder's original) |
| 21 | Longer-term, smoother trends |
| 28 | Very smooth, major trends only |

## Trading Strategies

### 1. Trend Filter
- Enter trend trades only when DX > 25
- Use range strategies when DX < 25
- Higher DX = stronger trend signal

### 2. Breakout Confirmation
- Price breakout + DX > 30 = confirmed breakout
- Price breakout + DX < 20 = potential false breakout
- Wait for DX to rise above 25 after breakout

### 3. DX Divergence
- Price higher highs + DX lower highs = bearish divergence
- Price lower lows + DX higher lows = bullish divergence
- Indicates weakening/strengthening directional momentum

### 4. DX Extremes
- DX > 60: Very strong trend, watch for exhaustion
- DX < 15: Very weak trend, consolidation likely
- DX spike from low to high: New trend emerging

## Key Differences: DX vs ADX

| Feature | DX | ADX |
|---------|-----|-----|
| Calculation | Raw directional strength | Smoothed average of DX |
| Volatility | More volatile, reactive | Smoother, stable |
| Signal Speed | Faster signals | Lagging signals |
| Best For | Detecting trend changes | Confirming trend strength |
| Reading | More choppy | Easier to read |

## Understanding DX Components

DX is calculated from the directional indicators:

**When +DI >> -DI:**
- Large difference creates high DX
- Strong upward directional movement
- Bullish trend strength

**When -DI >> +DI:**
- Large difference creates high DX
- Strong downward directional movement
- Bearish trend strength

**When +DI ≈ -DI:**
- Small difference creates low DX
- Weak directional movement
- Range-bound market

## Advanced Techniques

### 1. DX Rate of Change
Track how quickly DX changes to identify trend acceleration:
```ruby
dx_roc = ((dx.last - dx[-5]) / dx[-5] * 100).round(2)
puts "DX Rate of Change: #{dx_roc}%"
```

### 2. DX Zones
Customize thresholds based on asset volatility:
- High volatility stocks: Use 30/20 instead of 25
- Low volatility stocks: Use 20/15
- Cryptocurrencies: Use 35/25

### 3. DX Histogram
Visualize DX changes period-to-period:
```ruby
dx_change = dx.last - dx[-2]
puts "DX Change: #{dx_change > 0 ? '+' : ''}#{dx_change.round(2)}"
```

### 4. Combine with Volume
Strong DX + High Volume = High conviction trend
Strong DX + Low Volume = Weak trend, caution

## Related Indicators

- [ADX](adx.md) - Average Directional Index (smoothed DX)
- [ADXR](adxr.md) - ADX Rating
- [PLUS_DI](plus_di.md) - Plus Directional Indicator
- [MINUS_DI](minus_di.md) - Minus Directional Indicator

## See Also

- [Back to Indicators](../index.md)
- [Momentum Indicators Overview](../index.md)
