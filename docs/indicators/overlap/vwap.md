# VWAP (Volume-Weighted Average Price)

> **Note**: VWAP is not a standard TA-Lib indicator and is not currently available in SQA::TAI. This page is provided for reference purposes as VWAP is commonly used alongside other technical indicators.

## Overview

VWAP (Volume-Weighted Average Price) is a trading benchmark that shows the average price an asset has traded at throughout the day, weighted by volume. Unlike simple moving averages, VWAP gives more weight to price levels where more volume traded.

## What is VWAP?

VWAP represents the true average price at which an asset has traded during the day. Institutional traders and algorithms often use VWAP to:
- Benchmark execution quality
- Identify value areas
- Make entry/exit decisions
- Assess intraday trends

### Formula

```
VWAP = Σ(Typical Price × Volume) / Σ(Volume)

Where:
- Typical Price = (High + Low + Close) / 3
- Σ = Cumulative sum from start of day
```

## Typical Usage

If VWAP were available, it would be used like this:

```ruby
# Hypothetical usage (NOT currently available in SQA::TAI)
require 'sqa/tai'

# Note: This functionality is not implemented
# vwap = SQA::TAI.vwap(high, low, close, volume)

# Manual calculation approach:
typical_price = high.zip(low, close).map { |h, l, c| (h + l + c) / 3.0 }
volume_price = typical_price.zip(volume).map { |tp, v| tp * v }

cumulative_volume_price = volume_price.each_with_index.map do |vp, i|
  volume_price[0..i].sum
end

cumulative_volume = volume.each_with_index.map do |v, i|
  volume[0..i].sum
end

vwap = cumulative_volume_price.zip(cumulative_volume).map { |vp, v| vp / v }

puts "Current VWAP: $#{vwap.last.round(2)}"
```

## Interpretation

### Trading Above/Below VWAP

- **Price > VWAP**: Bullish intraday sentiment
  - Buyers willing to pay above average price
  - Potential uptrend continuation
  - Long positions favored

- **Price < VWAP**: Bearish intraday sentiment
  - Sellers accepting below average price
  - Potential downtrend continuation
  - Short positions favored

- **Price at VWAP**: Neutral zone
  - Fair value area
  - Potential support/resistance
  - Breakout direction uncertain

### VWAP as Support/Resistance

VWAP often acts as dynamic support and resistance:
- In uptrends, price tends to stay above VWAP
- In downtrends, price tends to stay below VWAP
- Crosses of VWAP can signal trend changes

## Common Trading Strategies

### 1. VWAP Cross Strategy

```ruby
# Price crosses above VWAP = Buy signal
# Price crosses below VWAP = Sell signal

if close.last > vwap.last && close[-2] <= vwap[-2]
  puts "VWAP Cross Up - Consider LONG"
elsif close.last < vwap.last && close[-2] >= vwap[-2]
  puts "VWAP Cross Down - Consider SHORT"
end
```

### 2. VWAP Pullback Strategy

```ruby
# In uptrend, buy pullbacks to VWAP
# In downtrend, sell rallies to VWAP

uptrend = close[-5..-1].all? { |c| c > vwap[-5..-1].shift }

if uptrend && (close.last - vwap.last).abs / vwap.last < 0.002
  puts "Pullback to VWAP in uptrend - BUY opportunity"
end
```

### 3. VWAP Bands Strategy

```ruby
# Calculate standard deviation bands around VWAP
# Similar to Bollinger Bands

std_dev = calculate_std_dev(close, vwap)
upper_band = vwap.map { |v| v + (2 * std_dev) }
lower_band = vwap.map { |v| v - (2 * std_dev) }

if close.last < lower_band.last
  puts "Price below VWAP lower band - OVERSOLD"
elsif close.last > upper_band.last
  puts "Price above VWAP upper band - OVERBOUGHT"
end
```

## VWAP Best Practices

### 1. Intraday Focus
VWAP is primarily an intraday indicator:
- Resets at the start of each trading day
- Most useful for day traders
- Less relevant for swing/position traders

### 2. Combine with Other Indicators

Use VWAP with available SQA::TAI indicators:

```ruby
# VWAP + RSI
rsi = SQA::TAI.rsi(close, period: 14)

if close.last > vwap.last && rsi.last < 70
  puts "Above VWAP and not overbought - STRONG BUY"
end

# VWAP + Moving Averages
ema_20 = SQA::TAI.ema(close, period: 20)

if close.last > vwap.last && close.last > ema_20.last
  puts "Aligned with both VWAP and EMA - TREND CONFIRMED"
end
```

### 3. Volume Confirmation
VWAP is volume-weighted, so volume spikes matter:
- High volume near VWAP = strong support/resistance
- Low volume near VWAP = weaker significance

## Alternative Indicators in SQA::TAI

While VWAP is not available, consider these similar indicators:

### [Typical Price (TYPPRICE)](../price_transform/typprice.md)
Component of VWAP calculation:
```ruby
typical = SQA::TAI.typprice(high, low, close)
```

### [Moving Averages](ema.md)
Dynamic support/resistance like VWAP:
```ruby
ema_20 = SQA::TAI.ema(close, period: 20)
sma_20 = SQA::TAI.sma(close, period: 20)
```

### [On Balance Volume (OBV)](../volume/obv.md)
Volume-based indicator:
```ruby
obv = SQA::TAI.obv(close, volume)
```

### [Accumulation/Distribution (AD)](../volume/ad.md)
Volume-weighted price indicator:
```ruby
ad = SQA::TAI.ad(high, low, close, volume)
```

## Manual VWAP Calculation

Here's a complete Ruby implementation for calculating VWAP:

```ruby
class VWAPCalculator
  def self.calculate(high, low, close, volume)
    # Calculate typical price
    typical_prices = high.zip(low, close).map do |h, l, c|
      (h + l + c) / 3.0
    end

    # Calculate cumulative volume * price and cumulative volume
    cumulative_vp = 0
    cumulative_vol = 0

    vwap_values = typical_prices.zip(volume).map do |tp, vol|
      cumulative_vp += tp * vol
      cumulative_vol += vol

      cumulative_vp / cumulative_vol
    end

    vwap_values
  end

  # Calculate VWAP bands (similar to Bollinger Bands)
  def self.calculate_with_bands(high, low, close, volume, num_std_dev = 2)
    vwap = calculate(high, low, close, volume)
    typical_prices = high.zip(low, close).map { |h, l, c| (h + l + c) / 3.0 }

    # Calculate standard deviation
    std_devs = vwap.each_with_index.map do |v, i|
      prices_so_far = typical_prices[0..i]
      mean = v
      variance = prices_so_far.map { |p| (p - mean) ** 2 }.sum / prices_so_far.length
      Math.sqrt(variance)
    end

    upper_band = vwap.zip(std_devs).map { |v, sd| v + (num_std_dev * sd) }
    lower_band = vwap.zip(std_devs).map { |v, sd| v - (num_std_dev * sd) }

    { vwap: vwap, upper: upper_band, lower: lower_band }
  end
end

# Usage example
high = [100.5, 101.2, 102.0, 101.5]
low = [99.5, 100.0, 100.5, 100.0]
close = [100.0, 101.0, 101.5, 101.0]
volume = [1000, 1500, 2000, 1200]

vwap = VWAPCalculator.calculate(high, low, close, volume)
puts "VWAP: $#{vwap.last.round(2)}"

bands = VWAPCalculator.calculate_with_bands(high, low, close, volume)
puts "VWAP with bands:"
puts "  Upper: $#{bands[:upper].last.round(2)}"
puts "  VWAP: $#{bands[:vwap].last.round(2)}"
puts "  Lower: $#{bands[:lower].last.round(2)}"
```

## Resources

- [Investopedia: VWAP](https://www.investopedia.com/terms/v/vwap.asp)
- [Volume-Weighted Indicators](../volume/index.md)
- [Price Transform Indicators](../price_transform/index.md)

## See Also

- [Accumulation/Distribution Line (AD)](../volume/ad.md) - Volume-weighted price indicator
- [Typical Price (TYPPRICE)](../price_transform/typprice.md) - Component of VWAP
- [On Balance Volume (OBV)](../volume/obv.md) - Volume-based momentum
- [Moving Averages](ema.md) - Alternative dynamic support/resistance
- [Back to Indicators](../index.md)

---

**Implementation Status**: Not available in current TA-Lib/SQA::TAI version. Use manual calculation or alternative volume-weighted indicators.
