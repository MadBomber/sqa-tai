# Cycle Indicators

Cycle indicators use Hilbert Transform mathematical techniques to identify dominant market cycles and trends. These advanced indicators can detect cyclical patterns, measure trend strength, and predict potential turning points based on phase relationships.

## Overview

Hilbert Transform cycle indicators help traders:
- **Identify Dominant Cycles**: Find the primary cycle length in price data
- **Detect Trend Changes**: Recognize when markets shift from trending to cycling
- **Phase Analysis**: Determine where price is within the current cycle
- **Adaptive Trading**: Adjust strategies based on current market regime

## Available Cycle Indicators

### [Hilbert Transform - Dominant Cycle Period (HT_DCPERIOD)](ht_dcperiod.md)
Identifies the dominant cycle period in the market.

```ruby
period = SQA::TAI.ht_dcperiod(close)
```

**Key Features**:
- Measures cycle length in bars
- Adapts to changing market conditions
- Useful for optimizing indicator periods

### [Hilbert Transform - Dominant Cycle Phase (HT_DCPHASE)](ht_dcphase.md)
Determines the current phase of the dominant cycle.

```ruby
phase = SQA::TAI.ht_dcphase(close)
```

**Key Features**:
- Returns phase angle in degrees (0-360)
- Identifies cycle position
- Helps time entries and exits

### [Hilbert Transform - Phasor Components (HT_PHASOR)](ht_phasor.md)
Provides in-phase and quadrature components of the dominant cycle.

```ruby
in_phase, quadrature = SQA::TAI.ht_phasor(close)
```

**Key Features**:
- Returns two components (I and Q)
- Advanced cycle analysis
- Used for phase calculations

### [Hilbert Transform - Sine Wave (HT_SINE)](ht_sine.md)
Generates sine and lead sine waves based on the dominant cycle.

```ruby
sine, lead_sine = SQA::TAI.ht_sine(close)
```

**Key Features**:
- Sine wave follows price cycles
- Lead sine provides early signals
- Crossovers indicate cycle turns

### [Hilbert Transform - Trend vs Cycle Mode (HT_TRENDMODE)](ht_trendmode.md)
Determines if the market is trending or cycling.

```ruby
trend_mode = SQA::TAI.ht_trendmode(close)
```

**Key Features**:
- Returns 1 for trend, 0 for cycle
- Helps select appropriate strategy
- Adaptive market regime detection

## Common Usage Patterns

### Basic Cycle Detection

```ruby
require 'sqa/tai'

# Load price data
close = load_closes('AAPL')

# Detect dominant cycle
period = SQA::TAI.ht_dcperiod(close)
phase = SQA::TAI.ht_dcphase(close)

puts "Cycle Analysis:"
puts "Dominant Period: #{period.last.round(1)} bars"
puts "Current Phase: #{phase.last.round(1)}°"

# Interpret phase
case phase.last
when 0..90
  puts "Cycle Position: Early upswing"
when 90..180
  puts "Cycle Position: Late upswing"
when 180..270
  puts "Cycle Position: Early downswing"
when 270..360
  puts "Cycle Position: Late downswing"
end
```

### Trend vs Cycle Mode Detection

```ruby
require 'sqa/tai'

close = load_closes('MSFT')

# Detect market mode
trend_mode = SQA::TAI.ht_trendmode(close)

if trend_mode.last == 1
  puts "Market Mode: TRENDING"
  puts "Strategy: Use trend-following indicators"
  puts "Recommended: Moving averages, MACD, ADX"

  # Use trend indicators
  ema_fast = SQA::TAI.ema(close, period: 12)
  ema_slow = SQA::TAI.ema(close, period: 26)

  if ema_fast.last > ema_slow.last
    puts "Trend Direction: UP"
  else
    puts "Trend Direction: DOWN"
  end
else
  puts "Market Mode: CYCLING"
  puts "Strategy: Use oscillators and mean reversion"
  puts "Recommended: RSI, Stochastic, Bollinger Bands"

  # Use cycle indicators
  rsi = SQA::TAI.rsi(close, period: 14)

  if rsi.last > 70
    puts "Cycle Position: Overbought - consider selling"
  elsif rsi.last < 30
    puts "Cycle Position: Oversold - consider buying"
  else
    puts "Cycle Position: Neutral"
  end
end
```

### Sine Wave Trading Signals

```ruby
require 'sqa/tai'

close = load_closes('TSLA')

# Generate sine waves
sine, lead_sine = SQA::TAI.ht_sine(close)

# Current and previous values
curr_sine = sine.last
prev_sine = sine[-2]
curr_lead = lead_sine.last
prev_lead = lead_sine[-2]

puts "Sine Wave Analysis:"
puts "Sine: #{curr_sine.round(3)}"
puts "Lead Sine: #{curr_lead.round(3)}"

# Detect crossovers
if prev_sine < prev_lead && curr_sine > curr_lead
  puts "\nBUY SIGNAL: Sine crossed above Lead Sine"
  puts "Cycle turning up"
elsif prev_sine > prev_lead && curr_sine < curr_lead
  puts "\nSELL SIGNAL: Sine crossed below Lead Sine"
  puts "Cycle turning down"
else
  puts "\nNo crossover - hold position"
end
```

### Adaptive Indicator Periods

```ruby
require 'sqa/tai'

close = load_closes('NVDA')

# Get dominant cycle period
dc_period = SQA::TAI.ht_dcperiod(close)
current_period = dc_period.last.round(0)

puts "Adaptive Period Selection:"
puts "Dominant Cycle: #{current_period} bars"

# Use cycle period for adaptive indicators
adaptive_rsi = SQA::TAI.rsi(close, period: current_period)
adaptive_ma = SQA::TAI.sma(close, period: current_period)

# Standard indicators for comparison
standard_rsi = SQA::TAI.rsi(close, period: 14)
standard_ma = SQA::TAI.sma(close, period: 20)

puts "\nAdaptive vs Standard:"
puts "Adaptive RSI(#{current_period}): #{adaptive_rsi.last.round(2)}"
puts "Standard RSI(14): #{standard_rsi.last.round(2)}"
puts "Adaptive MA(#{current_period}): $#{adaptive_ma.last.round(2)}"
puts "Standard MA(20): $#{standard_ma.last.round(2)}"
```

## Understanding Hilbert Transform

### What is Hilbert Transform?

The Hilbert Transform is a mathematical operation that:
- Shifts a signal by 90 degrees in phase
- Allows calculation of instantaneous amplitude and phase
- Enables detection of dominant cycles without Fourier Transform

### Key Concepts

**Dominant Cycle**: The most prominent cyclical pattern in price data
- Typically ranges from 10 to 40 bars
- Changes over time as market conditions shift

**Phase**: Position within the cycle
- 0°: Cycle bottom
- 90°: Rising through midpoint
- 180°: Cycle top
- 270°: Falling through midpoint

**Trend Mode**: Market regime classification
- Trending: Directional price movement
- Cycling: Oscillating around mean

## Best Practices

### 1. Combine Cycle Indicators

```ruby
# Use multiple cycle indicators together
period = SQA::TAI.ht_dcperiod(close)
trend_mode = SQA::TAI.ht_trendmode(close)
sine, lead = SQA::TAI.ht_sine(close)

# Make decisions based on agreement
```

### 2. Adapt to Market Regime

```ruby
# Different strategies for different modes
if trend_mode == 1
  # Use trend-following strategies
else
  # Use mean-reversion strategies
end
```

### 3. Allow for Warmup Period

```ruby
# Cycle indicators need data to stabilize
# Use at least 50-60 bars before trusting signals
valid_data = close[60..-1]
```

### 4. Validate with Price Action

```ruby
# Don't trade cycle signals alone
# Confirm with support/resistance, volume, etc.
```

## Example: Complete Cycle Analysis System

```ruby
require 'sqa/tai'

# Load data
close = load_closes('AAPL')
high, low = load_hl('AAPL')

puts "Complete Cycle Analysis System"
puts "=" * 60

# 1. Detect market mode
trend_mode = SQA::TAI.ht_trendmode(close)
mode = trend_mode.last == 1 ? "TRENDING" : "CYCLING"

puts "\n1. Market Regime: #{mode}"

# 2. Get dominant cycle characteristics
dc_period = SQA::TAI.ht_dcperiod(close)
dc_phase = SQA::TAI.ht_dcphase(close)

puts "\n2. Cycle Characteristics:"
puts "   Dominant Period: #{dc_period.last.round(1)} bars"
puts "   Current Phase: #{dc_phase.last.round(1)}°"

# 3. Sine wave analysis
sine, lead_sine = SQA::TAI.ht_sine(close)

puts "\n3. Sine Wave Indicators:"
puts "   Sine: #{sine.last.round(3)}"
puts "   Lead Sine: #{lead_sine.last.round(3)}"

# Detect crossover
prev_cross = (sine[-2] - lead_sine[-2]) > 0
curr_cross = (sine.last - lead_sine.last) > 0

if prev_cross != curr_cross
  signal = curr_cross ? "BULLISH" : "BEARISH"
  puts "   >>> CROSSOVER DETECTED: #{signal} <<<"
end

# 4. Select strategy based on mode
puts "\n4. Strategy Selection:"

if trend_mode.last == 1
  puts "   Mode: Trending"
  puts "   Strategy: Trend Following"

  # Calculate trend indicators
  ema_12 = SQA::TAI.ema(close, period: 12)
  ema_26 = SQA::TAI.ema(close, period: 26)
  macd, signal, hist = SQA::TAI.macd(close)

  trend_direction = ema_12.last > ema_26.last ? "UP" : "DOWN"
  puts "   Trend Direction: #{trend_direction}"
  puts "   MACD: #{macd.last.round(2)}"

  if trend_direction == "UP" && macd.last > signal.last
    puts "   >>> STRONG BUY SIGNAL <<<"
  elsif trend_direction == "DOWN" && macd.last < signal.last
    puts "   >>> STRONG SELL SIGNAL <<<"
  end
else
  puts "   Mode: Cycling"
  puts "   Strategy: Mean Reversion"

  # Use adaptive period from cycle analysis
  period = dc_period.last.round(0).clamp(10, 30)

  # Calculate oscillators
  rsi = SQA::TAI.rsi(close, period: period)
  upper, middle, lower = SQA::TAI.bbands(close, period: period)

  puts "   RSI(#{period}): #{rsi.last.round(2)}"
  puts "   Price vs BB: $#{close.last.round(2)}"
  puts "   BB Upper: $#{upper.last.round(2)}"
  puts "   BB Lower: $#{lower.last.round(2)}"

  if close.last < lower.last && rsi.last < 30
    puts "   >>> OVERSOLD - BUY SIGNAL <<<"
  elsif close.last > upper.last && rsi.last > 70
    puts "   >>> OVERBOUGHT - SELL SIGNAL <<<"
  end
end

# 5. Cycle timing
puts "\n5. Cycle Timing:"

phase = dc_phase.last
case phase
when 0..45
  position = "Bottom (0-45°)"
  action = "Accumulate on weakness"
when 45..135
  position = "Rising (45-135°)"
  action = "Hold or add to longs"
when 135..225
  position = "Top (135-225°)"
  action = "Take profits or reduce"
when 225..315
  position = "Falling (225-315°)"
  action = "Hold or add to shorts"
when 315..360
  position = "Bottom approach (315-360°)"
  action = "Prepare to accumulate"
end

puts "   Phase: #{phase.round(1)}° - #{position}"
puts "   Action: #{action}"

# 6. Risk assessment
puts "\n6. Risk Assessment:"

# Calculate ATR for volatility
atr = SQA::TAI.atr(high, low, close, period: 14)
atr_pct = (atr.last / close.last * 100).round(2)

puts "   ATR: $#{atr.last.round(2)} (#{atr_pct}%)"

if atr_pct > 3.0
  puts "   Volatility: HIGH - Use wider stops"
elsif atr_pct > 1.5
  puts "   Volatility: MODERATE - Normal stops"
else
  puts "   Volatility: LOW - Tighter stops acceptable"
end

# 7. Final recommendation
puts "\n7. Trading Recommendation:"

score = 0
score += 2 if trend_mode.last == 1 && sine.last > lead_sine.last
score += 2 if trend_mode.last == 0 && (phase > 315 || phase < 45)
score += 1 if atr_pct < 2.5

puts "   Confidence Score: #{score}/5"

if score >= 4
  puts "   >>> HIGH CONFIDENCE SETUP <<<"
elsif score >= 3
  puts "   >>> MODERATE SETUP - MONITOR <<<"
else
  puts "   >>> LOW CONFIDENCE - WAIT <<<"
end
```

## Advanced Topics

### Multi-Timeframe Cycle Analysis

```ruby
# Analyze cycles across timeframes
daily_period = SQA::TAI.ht_dcperiod(daily_close)
hourly_period = SQA::TAI.ht_dcperiod(hourly_close)

# Cycle alignment
if daily_period.last > 20 && hourly_period.last > 10
  puts "Cycles aligned - stronger signals"
end
```

### Cycle-Based Position Sizing

```ruby
# Adjust position size based on cycle confidence
if trend_mode.last == 1
  # Higher confidence in trending markets
  position_size = base_size * 1.5
else
  # Lower confidence in cycling markets
  position_size = base_size * 0.75
end
```

## See Also

- [HT Dominant Cycle Period](ht_dcperiod.md)
- [HT Dominant Cycle Phase](ht_dcphase.md)
- [HT Phasor Components](ht_phasor.md)
- [HT Sine Wave](ht_sine.md)
- [HT Trend vs Cycle Mode](ht_trendmode.md)
- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
