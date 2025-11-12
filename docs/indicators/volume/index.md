# Volume Indicators

Volume indicators analyze trading volume to confirm price movements, identify trend strength, and detect potential reversals. Volume is often called the "fuel" of price movements - significant price changes on high volume are more reliable than those on low volume.

## Overview

Volume indicators help traders understand:
- **Trend Confirmation**: High volume validates price trends
- **Buying/Selling Pressure**: Who's in control - bulls or bears
- **Divergences**: When price and volume disagree (warning signal)
- **Breakout Validation**: Real breakouts occur on high volume

## Available Volume Indicators

### [Accumulation/Distribution Line (AD)](ad.md)
Cumulative indicator that uses volume flow to assess buying/selling pressure.

```ruby
ad = SQA::TAI.ad(high, low, close, volume)
```

**Key Features**:
- Cumulative volume-weighted price indicator
- Identifies money flow into or out of asset
- Useful for divergence analysis

### [Chaikin A/D Oscillator (ADOSC)](adosc.md)
Momentum indicator derived from the Accumulation/Distribution Line.

```ruby
adosc = SQA::TAI.adosc(high, low, close, volume, fast_period: 3, slow_period: 10)
```

**Key Features**:
- MACD of the A/D Line
- Shows momentum of accumulation/distribution
- Earlier warning signals than A/D Line

### [On Balance Volume (OBV)](obv.md)
Simple but powerful cumulative volume indicator.

```ruby
obv = SQA::TAI.obv(close, volume)
```

**Key Features**:
- Adds volume on up days, subtracts on down days
- Leading indicator for price movements
- Excellent for divergence detection

## Common Usage Patterns

### Volume Confirmation

```ruby
require 'sqa/tai'

# Load price and volume data
close, volume = load_price_volume('AAPL')

# Calculate volume indicators
obv = SQA::TAI.obv(close, volume)
ad = SQA::TAI.ad(high, low, close, volume)

# Check if price move confirmed by volume
if close.last > close[-2] && obv.last > obv[-2]
  puts "Price rise confirmed by OBV"
end
```

### Divergence Detection

```ruby
require 'sqa/tai'

high, low, close, volume = load_ohlc_volume('MSFT')

# Calculate indicators
obv = SQA::TAI.obv(close, volume)
ad = SQA::TAI.ad(high, low, close, volume)

# Check for bearish divergence
if close.last > close[-10] && obv.last < obv[-10]
  puts "Bearish divergence: Price up but OBV down"
  puts "Potential trend reversal warning"
end

# Check for bullish divergence
if close.last < close[-10] && obv.last > obv[-10]
  puts "Bullish divergence: Price down but OBV up"
  puts "Potential bottom forming"
end
```

### Breakout Validation

```ruby
require 'sqa/tai'

high, low, close, volume = load_ohlc_volume('TSLA')

# Calculate indicators
obv = SQA::TAI.obv(close, volume)
resistance = 250.0  # Key resistance level

# Validate breakout
if close.last > resistance
  obv_momentum = (obv.last - obv[-5]) / obv[-5] * 100

  if obv_momentum > 2.0
    puts "Valid breakout with strong volume confirmation"
    puts "OBV momentum: #{obv_momentum.round(2)}%"
  else
    puts "Breakout on weak volume - may be false"
  end
end
```

## Volume Analysis Best Practices

### 1. Volume Leads Price

Volume often changes direction before price. Watch for:
```ruby
# Volume increasing while price consolidates
# Often signals big move coming
```

### 2. Confirm Trends with Volume

```ruby
# Uptrend should have higher volume on up days
# Downtrend should have higher volume on down days
# Decreasing volume in trend = potential reversal
```

### 3. Use Multiple Volume Indicators

```ruby
# Combine OBV, AD, and ADOSC for stronger signals
# Agreement between indicators increases reliability
```

### 4. Watch for Divergences

```ruby
# Price making new highs but volume declining = bearish
# Price making new lows but volume declining = bullish
```

## Example: Complete Volume Analysis

```ruby
require 'sqa/tai'

# Load data
high, low, close, volume = load_ohlc_volume('NVDA')

# Calculate volume indicators
obv = SQA::TAI.obv(close, volume)
ad = SQA::TAI.ad(high, low, close, volume)
adosc = SQA::TAI.adosc(high, low, close, volume, fast_period: 3, slow_period: 10)

# Calculate price indicators for context
sma_20 = SQA::TAI.sma(close, period: 20)
rsi = SQA::TAI.rsi(close, period: 14)

# Analyze current conditions
puts "Volume Analysis for NVDA"
puts "=" * 50

# Trend analysis
trend = close.last > sma_20.last ? "Uptrend" : "Downtrend"
puts "\nTrend: #{trend}"
puts "Price: $#{close.last.round(2)}"
puts "RSI: #{rsi.last.round(2)}"

# Volume confirmation
obv_change = ((obv.last - obv[-5]) / obv[-5].abs * 100).round(2)
ad_change = ((ad.last - ad[-5]) / ad[-5].abs * 100).round(2)

puts "\nVolume Indicators:"
puts "OBV Change (5 bars): #{obv_change}%"
puts "AD Change (5 bars): #{ad_change}%"
puts "ADOSC: #{adosc.last.round(2)}"

# Signal generation
score = 0
signals = []

# OBV confirmation
if trend == "Uptrend" && obv_change > 0
  score += 2
  signals << "OBV confirms uptrend"
elsif trend == "Downtrend" && obv_change < 0
  score += 2
  signals << "OBV confirms downtrend"
end

# A/D confirmation
if trend == "Uptrend" && ad_change > 0
  score += 2
  signals << "A/D confirms uptrend"
elsif trend == "Downtrend" && ad_change < 0
  score += 2
  signals << "A/D confirms downtrend"
end

# ADOSC momentum
if adosc.last > 0 && adosc.last > adosc[-1]
  score += 1
  signals << "ADOSC positive and rising"
elsif adosc.last < 0 && adosc.last < adosc[-1]
  score += 1
  signals << "ADOSC negative and falling"
end

# Divergence check
price_direction = close.last > close[-10] ? "up" : "down"
obv_direction = obv.last > obv[-10] ? "up" : "down"

if price_direction != obv_direction
  signals << "WARNING: Divergence detected (Price #{price_direction}, OBV #{obv_direction})"
  score -= 2
end

puts "\nSignals:"
signals.each { |s| puts "- #{s}" }

puts "\nOverall Score: #{score}/5"
if score >= 4
  puts "Strong volume confirmation - high confidence"
elsif score >= 2
  puts "Moderate volume confirmation"
else
  puts "Weak or conflicting volume signals"
end
```

## Key Concepts

### Volume Trends
- **Increasing Volume**: Growing interest, trend likely to continue
- **Decreasing Volume**: Waning interest, trend may be exhausting
- **Volume Spikes**: Potential climax or reversal points

### Volume and Price Relationships
- **Price up + Volume up**: Healthy uptrend
- **Price up + Volume down**: Weak rally, potential reversal
- **Price down + Volume up**: Strong selling pressure
- **Price down + Volume down**: Weak decline, potential bottom

### Volume Divergences
- **Bullish**: Price lower but volume indicators higher
- **Bearish**: Price higher but volume indicators lower

## See Also

- [Accumulation/Distribution (AD)](ad.md)
- [Chaikin A/D Oscillator (ADOSC)](adosc.md)
- [On Balance Volume (OBV)](obv.md)
- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
