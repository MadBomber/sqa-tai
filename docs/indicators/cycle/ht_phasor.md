# HT_PHASOR (Hilbert Transform - Phasor Components)

## Overview

The Hilbert Transform - Phasor Components (HT_PHASOR) is an advanced cycle analysis indicator that decomposes price data into two orthogonal components: the in-phase and quadrature components. Together, these components define a phasor (vector) in cycle space that represents both the amplitude and phase of the dominant market cycle. This provides traders with a mathematical framework for understanding cycle strength, direction, and momentum at any given time.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `prices` | Array<Float> | Required | Array of price values (typically close prices) |

### Parameter Details


**Note**: Array elements should be ordered from oldest to newest (chronological order)

**prices**
- Input data should be an array of closing prices
- Minimum 32 data points required for reliable results (due to Hilbert Transform calculation requirements)
- More data provides better accuracy in cycle identification
- Works best with at least 63+ data points for stable output
- The transform analyzes the frequency domain of the price series to extract cyclical components

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

# Calculate phasor components
prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 45.61,
          46.50, 47.20, 46.80, 47.50, 48.10, 48.30,
          # ... more data points ...
         ]

in_phase, quadrature = SQA::TAI.ht_phasor(prices)

# Current phasor components
current_inphase = in_phase.last
current_quadrature = quadrature.last

puts "In-Phase Component: #{current_inphase.round(4)}"
puts "Quadrature Component: #{current_quadrature.round(4)}"
```

### Calculating Phasor Magnitude and Angle

```ruby
# Get phasor components
in_phase, quadrature = SQA::TAI.ht_phasor(prices)

# Calculate phasor magnitude (cycle amplitude)
magnitude = Math.sqrt(in_phase.last**2 + quadrature.last**2)

# Calculate phasor angle (cycle phase in radians)
angle_rad = Math.atan2(quadrature.last, in_phase.last)
angle_deg = angle_rad * (180.0 / Math::PI)

puts "Cycle Amplitude: #{magnitude.round(4)}"
puts "Cycle Phase: #{angle_deg.round(2)} degrees"
```

### Tracking Phasor Evolution

```ruby
# Monitor how the phasor changes over time
in_phase, quadrature = SQA::TAI.ht_phasor(prices)

# Get last 10 phasor readings
recent_ip = in_phase.last(10)
recent_q = quadrature.last(10)

# Calculate magnitude trend
magnitudes = recent_ip.zip(recent_q).map do |ip, q|
  Math.sqrt(ip**2 + q**2)
end

avg_magnitude = magnitudes.sum / magnitudes.size
current_magnitude = magnitudes.last

if current_magnitude > avg_magnitude * 1.2
  puts "Cycle strength INCREASING"
elsif current_magnitude < avg_magnitude * 0.8
  puts "Cycle strength DECREASING"
else
  puts "Cycle strength STABLE"
end
```

## Understanding the Indicator

### What It Measures

HT_PHASOR measures two fundamental properties of the dominant market cycle:

**In-Phase Component (I):**
- Represents the current cycle value aligned with the price series
- Indicates the component of the cycle that is "in sync" with current price movement
- Positive values indicate cycle is in upward phase
- Negative values indicate cycle is in downward phase

**Quadrature Component (Q):**
- Represents the cycle value 90 degrees (one quarter cycle) ahead
- Provides leading information about where the cycle is heading
- Acts as a derivative of the in-phase component
- Helps predict upcoming cycle transitions

**Together as a Phasor:**
The phasor is a vector (I, Q) in two-dimensional space that fully describes:
- **Magnitude**: `sqrt(I² + Q²)` = cycle amplitude/strength
- **Angle**: `atan2(Q, I)` = current position within the cycle
- **Direction**: How the phasor is rotating indicates cycle momentum

### Why It's Important

Traditional single-value indicators only show you the current state. The phasor gives you:

1. **Current State**: Where the cycle is now (in-phase component)
2. **Future Direction**: Where the cycle is heading (quadrature component)
3. **Cycle Strength**: How strong the cyclical behavior is (magnitude)
4. **Cycle Position**: Where you are in the cycle (angle)

This multidimensional view allows for:
- More accurate cycle timing
- Earlier detection of cycle reversals
- Better understanding of cycle quality
- Advanced signal filtering and confirmation

### Calculation Method

The Hilbert Transform applies complex mathematical analysis to extract cycle components:

1. **Apply Hilbert Transform** to the price data to create an analytic signal
2. **Extract In-Phase Component** (real part): Current cycle value
3. **Extract Quadrature Component** (imaginary part): Leading cycle value
4. **Output both components** as orthogonal (90° apart) signals
5. **Components define phasor** in complex plane

**Key Concept:**
Think of the phasor as a rotating arrow in two-dimensional space. The arrow's length indicates cycle strength, and its angle indicates where you are in the cycle. As the market cycles, the arrow rotates clockwise through 360 degrees, providing continuous position and momentum information.

### Indicator Characteristics

- **Output**: Two synchronized arrays (in-phase and quadrature)
- **Type**: Cycle decomposition, advanced signal processing
- **Lag**: Moderate - requires history to establish cycle characteristics
- **Relationship**: Quadrature leads in-phase by 90 degrees
- **Best Used**: Markets with clear cyclical behavior, cycle analysis, advanced timing

## Interpretation

### Component Relationships

**In-Phase and Quadrature Interaction:**

The two components work together to provide complete cycle information:

| In-Phase | Quadrature | Cycle Phase | Interpretation |
|----------|------------|-------------|----------------|
| Positive | Positive | 0° - 90° | Early upward phase, momentum building |
| Negative | Positive | 90° - 180° | Late upward phase, approaching peak |
| Negative | Negative | 180° - 270° | Early downward phase, momentum declining |
| Positive | Negative | 270° - 360° | Late downward phase, approaching trough |

### Phasor Magnitude (Cycle Strength)

The magnitude of the phasor indicates cycle quality:

- **High Magnitude (> 2.0)**
  - Strong, well-defined cyclical behavior
  - Cycle signals are reliable
  - Good conditions for cycle-based trading
  - Clear market rhythm

- **Medium Magnitude (0.5 - 2.0)**
  - Moderate cyclical behavior
  - Cycles present but mixed with trend/noise
  - Standard trading conditions
  - Use additional confirmation

- **Low Magnitude (< 0.5)**
  - Weak or no cyclical behavior
  - Market may be trending or random
  - Cycle signals unreliable
  - Consider trend-following instead

### Phasor Angle (Cycle Position)

The angle tells you where you are in the cycle:

- **0° to 90°**: Cycle rising, momentum increasing (bullish acceleration)
- **90° to 180°**: Cycle still rising but momentum decreasing (bullish deceleration)
- **180° to 270°**: Cycle falling, momentum decreasing (bearish acceleration)
- **270° to 360°**: Cycle still falling but momentum increasing (bearish deceleration)

**Critical Angles:**
- **0° (360°)**: Cycle trough - potential buy zone
- **90°**: Maximum upward momentum
- **180°**: Cycle peak - potential sell zone
- **270°**: Maximum downward momentum

### Component Crossovers

**In-Phase Crosses Zero:**
- **Upward cross** (negative to positive): Cycle entering upward phase
- **Downward cross** (positive to negative): Cycle entering downward phase
- Similar to price crossing a moving average

**Quadrature Crosses Zero:**
- **Upward cross**: Predicts upcoming bullish cycle phase (90° ahead)
- **Downward cross**: Predicts upcoming bearish cycle phase (90° ahead)
- Provides leading signal before in-phase crosses

**Components Cross Each Other:**
- **In-Phase crosses above Quadrature**: Acceleration point (0° or 180°)
- **Quadrature crosses above In-Phase**: Deceleration point (90° or 270°)
- These are inflection points in the cycle

## Trading Signals

### Quadrature Leading Signal

**Primary Use Case:** Early cycle reversal detection

```ruby
in_phase, quadrature = SQA::TAI.ht_phasor(prices)

# Quadrature leads in-phase by 90 degrees
current_ip = in_phase.last
previous_ip = in_phase[-2]
current_q = quadrature.last
previous_q = quadrature[-2]

# Quadrature zero cross predicts upcoming in-phase zero cross
if previous_q < 0 && current_q >= 0
  puts "EARLY BUY SIGNAL: Quadrature crossed up"
  puts "Expect in-phase upward cross soon (cycle trough approaching)"

elsif previous_q > 0 && current_q <= 0
  puts "EARLY SELL SIGNAL: Quadrature crossed down"
  puts "Expect in-phase downward cross soon (cycle peak approaching)"
end

# Confirm with in-phase
if previous_ip < 0 && current_ip >= 0
  puts "CONFIRMED BUY: In-phase crossed up (cycle trough confirmed)"

elsif previous_ip > 0 && current_ip <= 0
  puts "CONFIRMED SELL: In-phase crossed down (cycle peak confirmed)"
end
```

### Phasor Magnitude Trading

**Entry Signals Based on Cycle Strength:**

```ruby
in_phase, quadrature = SQA::TAI.ht_phasor(prices)

# Calculate current magnitude
ip = in_phase.last
q = quadrature.last
magnitude = Math.sqrt(ip**2 + q**2)

# Calculate angle
angle = Math.atan2(q, ip)
angle_deg = angle * (180.0 / Math::PI)
angle_deg += 360 if angle_deg < 0 # Normalize to 0-360

# Only trade when cycle is strong
if magnitude > 1.5
  if angle_deg >= 0 && angle_deg < 90
    puts "STRONG BUY ZONE: Early upward cycle phase"
    puts "Magnitude: #{magnitude.round(2)} (strong cycle)"
    puts "Phase: #{angle_deg.round(1)}° (building momentum)"

  elsif angle_deg >= 180 && angle_deg < 270
    puts "STRONG SELL ZONE: Early downward cycle phase"
    puts "Magnitude: #{magnitude.round(2)} (strong cycle)"
    puts "Phase: #{angle_deg.round(1)}° (declining momentum)"
  end
else
  puts "NO SIGNAL: Cycle too weak (magnitude: #{magnitude.round(2)})"
  puts "Wait for stronger cyclical behavior"
end
```

### Phasor Divergence

**Detecting Cycle Quality Changes:**

```ruby
in_phase, quadrature = SQA::TAI.ht_phasor(prices)

# Calculate magnitude series
magnitudes = in_phase.zip(quadrature).map do |ip, q|
  Math.sqrt(ip**2 + q**2)
end

# Compare price highs with magnitude highs
recent_prices = prices.last(20)
recent_magnitudes = magnitudes.last(20)

price_high_idx = recent_prices.each_with_index.max[1]
magnitude_high_idx = recent_magnitudes.each_with_index.max[1]

if price_high_idx > magnitude_high_idx
  puts "BEARISH DIVERGENCE: Price making new highs"
  puts "But cycle strength is declining"
  puts "Warning: Trend may be weakening"

elsif price_high_idx < magnitude_high_idx
  puts "BULLISH DIVERGENCE: Cycle strength increasing"
  puts "But price hasn't confirmed yet"
  puts "Opportunity: Strong cycle emerging"
end
```

### Phase-Based Entry Strategy

**Optimal Entry at Specific Cycle Phases:**

```ruby
def calculate_phasor_angle(in_phase, quadrature)
  angle = Math.atan2(quadrature, in_phase)
  degrees = angle * (180.0 / Math::PI)
  degrees += 360 if degrees < 0
  degrees
end

in_phase, quadrature = SQA::TAI.ht_phasor(prices)
magnitude = Math.sqrt(in_phase.last**2 + quadrature.last**2)
phase = calculate_phasor_angle(in_phase.last, quadrature.last)

# Define optimal entry zones
BUY_ZONE = (350..370) # Near cycle trough (accounting for 360° wrap)
SELL_ZONE = (170..190) # Near cycle peak

# Only trade in strong cycles
if magnitude > 1.0
  if BUY_ZONE.cover?(phase) || BUY_ZONE.cover?(phase + 360)
    stop_loss = prices.last * 0.98
    take_profit = prices.last * 1.04

    puts "BUY SIGNAL: Optimal cycle phase"
    puts "Phase: #{phase.round(1)}° (near trough)"
    puts "Magnitude: #{magnitude.round(2)}"
    puts "Entry: #{prices.last.round(2)}"
    puts "Stop: #{stop_loss.round(2)}"
    puts "Target: #{take_profit.round(2)}"

  elsif SELL_ZONE.cover?(phase)
    stop_loss = prices.last * 1.02
    take_profit = prices.last * 0.96

    puts "SELL SIGNAL: Optimal cycle phase"
    puts "Phase: #{phase.round(1)}° (near peak)"
    puts "Magnitude: #{magnitude.round(2)}"
    puts "Entry: #{prices.last.round(2)}"
    puts "Stop: #{stop_loss.round(2)}"
    puts "Target: #{take_profit.round(2)}"
  end
else
  puts "Waiting: Cycle too weak (magnitude: #{magnitude.round(2)})"
end
```

## Best Practices

### Optimal Use Cases

**When HT_PHASOR works best:**
- **Cyclical markets**: Currency pairs, commodities with seasonal patterns
- **Range-bound conditions**: Markets oscillating between support/resistance
- **Advanced timing**: When you need precise entry/exit within cycles
- **Cycle confirmation**: Validating signals from other cycle indicators
- **Multi-dimensional analysis**: When you need both position and momentum

**Less effective in:**
- Strong trending markets with no mean reversion
- Very short timeframes with excessive noise
- Markets with irregular, chaotic price movements
- Low-liquidity instruments with erratic behavior

### Combining with Other Indicators

**With HT_DCPERIOD (Dominant Cycle Period):**

```ruby
# Use DCPERIOD to validate cycle presence
cycle_period = SQA::TAI.ht_dcperiod(prices).last
in_phase, quadrature = SQA::TAI.ht_phasor(prices)
magnitude = Math.sqrt(in_phase.last**2 + quadrature.last**2)

if cycle_period >= 10 && cycle_period <= 40 && magnitude > 1.0
  puts "Valid cycle detected:"
  puts "Period: #{cycle_period.round(1)} bars"
  puts "Strength: #{magnitude.round(2)}"
  puts "Safe to use phasor signals"
else
  puts "Cycle not well-defined - use caution"
end
```

**With HT_DCPHASE (Dominant Cycle Phase):**

```ruby
# Cross-validate phase measurements
dc_phase = SQA::TAI.ht_dcphase(prices).last
in_phase, quadrature = SQA::TAI.ht_phasor(prices)

phasor_angle = Math.atan2(quadrature.last, in_phase.last)
phasor_phase = phasor_angle * (180.0 / Math::PI)
phasor_phase += 360 if phasor_phase < 0

# Both should agree on cycle position
phase_diff = (dc_phase - phasor_phase).abs
phase_diff = 360 - phase_diff if phase_diff > 180

if phase_diff < 30
  puts "Phase measurements agree - reliable signal"
else
  puts "Phase disagreement - cycle may be transitioning"
end
```

**With HT_SINE (Sine Wave):**

```ruby
# Use sine wave for simplified signals
sine, lead_sine = SQA::TAI.ht_sine(prices)
in_phase, quadrature = SQA::TAI.ht_phasor(prices)

magnitude = Math.sqrt(in_phase.last**2 + quadrature.last**2)

# Phasor magnitude filters sine signals
if sine.last < -0.5 && magnitude > 1.5
  puts "STRONG BUY: Sine oversold + strong cycle"
elsif sine.last > 0.5 && magnitude > 1.5
  puts "STRONG SELL: Sine overbought + strong cycle"
elsif magnitude < 0.5
  puts "IGNORE SINE: Cycle too weak"
end
```

**With Traditional Oscillators:**

```ruby
# Validate RSI signals with phasor
rsi = SQA::TAI.rsi(prices, period: 14)
in_phase, quadrature = SQA::TAI.ht_phasor(prices)

angle = Math.atan2(quadrature.last, in_phase.last) * (180.0 / Math::PI)
angle += 360 if angle < 0

# Cycle should support RSI signal
if rsi.last < 30 && (angle < 45 || angle > 315)
  puts "CONFIRMED BUY: RSI oversold + cycle at trough"
elsif rsi.last > 70 && (angle > 135 && angle < 225)
  puts "CONFIRMED SELL: RSI overbought + cycle at peak"
else
  puts "CONFLICTING SIGNALS: RSI and cycle don't agree"
end
```

### Common Pitfalls

1. **Insufficient Data**
   - Need minimum 32-63 bars for Hilbert Transform
   - Initial values will be unstable and unreliable
   - Always validate data length before trading

2. **Ignoring Magnitude**
   - Don't trade phasor angle when magnitude is low
   - Low magnitude means weak or no cycle
   - Always check cycle strength before using position signals

3. **Phase Wrap-Around**
   - Angle jumps from 359° to 0° (or π to -π in radians)
   - Handle transitions carefully in code
   - Normalize angles to consistent range (0-360° or -180° to 180°)

4. **Over-Trading on Noise**
   - Small fluctuations in components don't mean much
   - Use thresholds for crossovers and changes
   - Smooth or filter when needed

5. **Mixing Trending and Cycling**
   - Phasor assumes cyclical behavior exists
   - In strong trends, cycles may be weak or absent
   - Use HT_TRENDMODE to determine market regime first

### Parameter Selection Guidelines

Since HT_PHASOR has no adjustable parameters, focus on how to interpret and use the output:

**For Different Timeframes:**

**Intraday Trading (5-min to 1-hour charts):**
- Expect higher noise, lower magnitude
- Use magnitude > 1.0 as minimum threshold
- Check phasor every few bars for position updates
- Shorter cycle periods (10-20 bars)

**Swing Trading (daily charts):**
- Better signal quality, clearer cycles
- Use magnitude > 0.75 as threshold
- Update daily for position management
- Medium cycle periods (15-30 bars)

**Position Trading (weekly charts):**
- Strongest signals, most reliable cycles
- Use magnitude > 0.5 as threshold
- Monitor weekly for long-term positioning
- Longer cycle periods (20-40 bars)

**Magnitude Thresholds by Market:**
- **Forex pairs**: Typically 0.5 - 3.0
- **Stock indices**: Typically 1.0 - 4.0
- **Commodities**: Typically 0.75 - 3.5
- **Individual stocks**: Highly variable, 0.3 - 5.0

## Practical Example

Complete cycle trading system using phasor components:

```ruby
require 'sqa/tai'

# Historical price data (need at least 63 bars)
prices = [
  # ... your price data ...
]

# Get phasor components
in_phase, quadrature = SQA::TAI.ht_phasor(prices)

# Verify we have enough data
if in_phase.size < 20
  puts "Insufficient data for reliable signals"
  exit
end

# Calculate phasor metrics
def phasor_metrics(in_phase, quadrature)
  ip = in_phase.last
  q = quadrature.last

  magnitude = Math.sqrt(ip**2 + q**2)
  angle_rad = Math.atan2(q, ip)
  angle_deg = angle_rad * (180.0 / Math::PI)
  angle_deg += 360 if angle_deg < 0

  {
    in_phase: ip,
    quadrature: q,
    magnitude: magnitude,
    angle: angle_deg,
    angle_rad: angle_rad
  }
end

# Get current phasor state
current = phasor_metrics(in_phase, quadrature)
previous = phasor_metrics(in_phase[0..-2], quadrature[0..-2])

# Display phasor status
puts "=== Phasor Analysis ==="
puts "In-Phase: #{current[:in_phase].round(4)}"
puts "Quadrature: #{current[:quadrature].round(4)}"
puts "Magnitude: #{current[:magnitude].round(4)}"
puts "Phase: #{current[:angle].round(1)}°"
puts ""

# Check cycle strength
MIN_MAGNITUDE = 1.0

if current[:magnitude] < MIN_MAGNITUDE
  puts "Cycle too weak (#{current[:magnitude].round(2)} < #{MIN_MAGNITUDE})"
  puts "No trading signals - wait for stronger cycle"
  exit
end

puts "Cycle strength: GOOD (magnitude: #{current[:magnitude].round(2)})"
puts ""

# Determine cycle quadrant
def cycle_quadrant(angle)
  case angle
  when 0...90
    "Rising (accelerating)"
  when 90...180
    "Rising (decelerating)"
  when 180...270
    "Falling (accelerating)"
  when 270...360
    "Falling (decelerating)"
  end
end

puts "Cycle Status: #{cycle_quadrant(current[:angle])}"
puts ""

# Trading signals
puts "=== Trading Signals ==="

# Signal 1: Quadrature zero cross (leading indicator)
if previous[:quadrature] < 0 && current[:quadrature] >= 0
  puts "EARLY WARNING: Quadrature upward cross"
  puts "Cycle trough approaching in ~quarter cycle"
  puts "Prepare for buy opportunity"
  puts ""
end

if previous[:quadrature] > 0 && current[:quadrature] <= 0
  puts "EARLY WARNING: Quadrature downward cross"
  puts "Cycle peak approaching in ~quarter cycle"
  puts "Prepare for sell opportunity"
  puts ""
end

# Signal 2: In-phase zero cross (confirmation)
if previous[:in_phase] < 0 && current[:in_phase] >= 0
  current_price = prices.last
  atr = SQA::TAI.atr([44.0] * prices.size, [43.0] * prices.size, prices, period: 14).last

  stop_loss = current_price - (2.0 * atr)
  take_profit = current_price + (3.0 * atr)

  puts "*** BUY SIGNAL ***"
  puts "In-phase upward cross (cycle trough confirmed)"
  puts "Entry: #{current_price.round(2)}"
  puts "Stop Loss: #{stop_loss.round(2)} (-#{((1 - stop_loss/current_price) * 100).round(1)}%)"
  puts "Take Profit: #{take_profit.round(2)} (+#{((take_profit/current_price - 1) * 100).round(1)}%)"
  puts "Cycle magnitude: #{current[:magnitude].round(2)}"
  puts ""
end

if previous[:in_phase] > 0 && current[:in_phase] <= 0
  current_price = prices.last
  atr = SQA::TAI.atr([44.0] * prices.size, [43.0] * prices.size, prices, period: 14).last

  stop_loss = current_price + (2.0 * atr)
  take_profit = current_price - (3.0 * atr)

  puts "*** SELL SIGNAL ***"
  puts "In-phase downward cross (cycle peak confirmed)"
  puts "Entry: #{current_price.round(2)}"
  puts "Stop Loss: #{stop_loss.round(2)} (+#{((stop_loss/current_price - 1) * 100).round(1)}%)"
  puts "Take Profit: #{take_profit.round(2)} (-#{((1 - take_profit/current_price) * 100).round(1)}%)"
  puts "Cycle magnitude: #{current[:magnitude].round(2)}"
  puts ""
end

# Signal 3: Optimal phase entry zones
BUY_ZONE_START = 350
BUY_ZONE_END = 10
SELL_ZONE_START = 170
SELL_ZONE_END = 190

in_buy_zone = current[:angle] >= BUY_ZONE_START || current[:angle] <= BUY_ZONE_END
in_sell_zone = current[:angle] >= SELL_ZONE_START && current[:angle] <= SELL_ZONE_END

if in_buy_zone && current[:magnitude] > MIN_MAGNITUDE
  puts "OPTIMAL BUY ZONE"
  puts "Phase: #{current[:angle].round(1)}° (near cycle trough)"
  puts "High probability of upward movement"
  puts ""
elsif in_sell_zone && current[:magnitude] > MIN_MAGNITUDE
  puts "OPTIMAL SELL ZONE"
  puts "Phase: #{current[:angle].round(1)}° (near cycle peak)"
  puts "High probability of downward movement"
  puts ""
end

# Signal 4: Magnitude change analysis
recent_magnitudes = (0...10).map do |i|
  ip = in_phase[-(i+1)]
  q = quadrature[-(i+1)]
  Math.sqrt(ip**2 + q**2)
end.reverse

avg_magnitude = recent_magnitudes.sum / recent_magnitudes.size
magnitude_trend = (current[:magnitude] - avg_magnitude) / avg_magnitude

if magnitude_trend > 0.2
  puts "CYCLE STRENGTHENING: +#{(magnitude_trend * 100).round(1)}%"
  puts "Signals becoming more reliable"
  puts ""
elsif magnitude_trend < -0.2
  puts "CYCLE WEAKENING: #{(magnitude_trend * 100).round(1)}%"
  puts "Consider reducing position size"
  puts ""
end

# Display position recommendation
puts "=== Position Recommendation ==="

if current[:magnitude] >= MIN_MAGNITUDE * 1.5
  puts "Position size: FULL (strong cycle)"
elsif current[:magnitude] >= MIN_MAGNITUDE
  puts "Position size: REDUCED (moderate cycle)"
else
  puts "Position size: NONE (weak cycle)"
end

puts "Current magnitude: #{current[:magnitude].round(2)}"
puts "Threshold: #{MIN_MAGNITUDE}"
```

## Related Indicators

### Hilbert Transform Family

- **[HT_DCPERIOD](ht_dcperiod.md)**: Identifies the length of the dominant market cycle
- **[HT_DCPHASE](ht_dcphase.md)**: Provides the phase angle within the dominant cycle (0-360°)
- **[HT_SINE](ht_sine.md)**: Sine wave representation with leading indicator
- **[HT_TRENDMODE](ht_trendmode.md)**: Determines if market is trending or cycling
- **[HT_TRENDLINE](../volatility/ht_trendline.md)**: Instantaneous trendline based on Hilbert Transform

### Complementary Indicators

- **[MAMA](../volatility/mama.md)**: MESA Adaptive Moving Average - uses Hilbert Transform concepts
- **[RSI](../momentum/rsi.md)**: Combine with phasor for confirmed overbought/oversold
- **[STOCH](../momentum/stoch.md)**: Use phasor to optimize stochastic period
- **[ATR](../volatility/atr.md)**: Position sizing based on phasor magnitude

### Mathematical Relatives

- **Complex Fourier Transform**: HT_PHASOR is closely related to frequency analysis
- **Quadrature Mirror Filters**: Digital signal processing concept
- **Vector Analysis**: Phasor is a vector in 2D space

## Advanced Topics

### Phasor Rotation Analysis

Track how the phasor rotates over time:

```ruby
in_phase, quadrature = SQA::TAI.ht_phasor(prices)

# Calculate angular velocity (how fast phasor is rotating)
def angular_velocity(in_phase, quadrature, lookback = 5)
  angles = (0...lookback).map do |i|
    ip = in_phase[-(i+1)]
    q = quadrature[-(i+1)]
    Math.atan2(q, ip)
  end.reverse

  # Calculate differences (handling wrap-around)
  velocities = (1...angles.size).map do |i|
    diff = angles[i] - angles[i-1]
    diff -= 2 * Math::PI if diff > Math::PI
    diff += 2 * Math::PI if diff < -Math::PI
    diff
  end

  velocities.sum / velocities.size
end

rotation_speed = angular_velocity(in_phase, quadrature)
degrees_per_bar = rotation_speed * (180.0 / Math::PI)

puts "Phasor rotating at #{degrees_per_bar.round(2)}°/bar"

if degrees_per_bar.abs > 20
  puts "Fast rotation - short cycle period"
elsif degrees_per_bar.abs < 5
  puts "Slow rotation - long cycle period"
end
```

### 3D Phasor Visualization Concepts

While we can't display 3D graphics here, conceptually:

```ruby
# Create time series of phasor positions
def phasor_trajectory(in_phase, quadrature, length = 50)
  trajectory = []

  (0...length).each do |i|
    next if i >= in_phase.size

    ip = in_phase[-(length - i)]
    q = quadrature[-(length - i)]

    trajectory << {
      time: i,
      in_phase: ip,
      quadrature: q,
      magnitude: Math.sqrt(ip**2 + q**2)
    }
  end

  trajectory
end

# Analyze trajectory characteristics
trajectory = phasor_trajectory(in_phase, quadrature)

# Check if trajectory is circular (good cycle) or erratic
magnitudes = trajectory.map { |t| t[:magnitude] }
mag_stddev = Math.sqrt(magnitudes.map { |m| (m - magnitudes.sum/magnitudes.size)**2 }.sum / magnitudes.size)
mag_mean = magnitudes.sum / magnitudes.size

coefficient_variation = mag_stddev / mag_mean

if coefficient_variation < 0.15
  puts "Clean circular trajectory - excellent cycle quality"
elsif coefficient_variation < 0.30
  puts "Moderate trajectory variation - acceptable cycle"
else
  puts "Erratic trajectory - poor cycle quality"
end
```

### Harmonic Analysis

Detect harmonic relationships in cycles:

```ruby
# Compare phasor at different scales
def harmonic_correlation(prices, harmonic = 2)
  # Get phasor for full data
  ip1, q1 = SQA::TAI.ht_phasor(prices)

  # Get phasor for downsampled data (higher frequency cycle)
  downsampled = prices.select.with_index { |_, i| i % harmonic == 0 }
  ip2, q2 = SQA::TAI.ht_phasor(downsampled)

  # Calculate correlation between magnitudes
  mag1 = ip1.zip(q1).map { |ip, q| Math.sqrt(ip**2 + q**2) }
  mag2_expanded = []

  ip2.size.times do |i|
    harmonic.times { mag2_expanded << Math.sqrt(ip2[i]**2 + q2[i]**2) }
  end

  # Trim to same length
  min_len = [mag1.size, mag2_expanded.size].min
  mag1 = mag1.last(min_len)
  mag2_expanded = mag2_expanded.last(min_len)

  # Simple correlation
  mean1 = mag1.sum / mag1.size
  mean2 = mag2_expanded.sum / mag2_expanded.size

  numerator = mag1.zip(mag2_expanded).map { |a, b| (a - mean1) * (b - mean2) }.sum
  denom1 = Math.sqrt(mag1.map { |a| (a - mean1)**2 }.sum)
  denom2 = Math.sqrt(mag2_expanded.map { |b| (b - mean2)**2 }.sum)

  correlation = numerator / (denom1 * denom2)

  {
    harmonic: harmonic,
    correlation: correlation,
    interpretation: correlation > 0.5 ? "Strong harmonic present" : "No harmonic relationship"
  }
end

result = harmonic_correlation(prices, 2)
puts "#{result[:harmonic]}x Harmonic Analysis:"
puts "Correlation: #{result[:correlation].round(3)}"
puts result[:interpretation]
```

### Statistical Validation

Assess signal reliability:

```ruby
# Measure phasor stability over time
def phasor_stability(in_phase, quadrature, window = 20)
  return nil if in_phase.size < window

  # Get recent magnitudes
  magnitudes = (0...window).map do |i|
    ip = in_phase[-(i+1)]
    q = quadrature[-(i+1)]
    Math.sqrt(ip**2 + q**2)
  end

  # Calculate coefficient of variation
  mean = magnitudes.sum / magnitudes.size
  stddev = Math.sqrt(magnitudes.map { |m| (m - mean)**2 }.sum / magnitudes.size)
  cv = stddev / mean

  # Calculate angular stability
  angles = (0...window).map do |i|
    ip = in_phase[-(i+1)]
    q = quadrature[-(i+1)]
    Math.atan2(q, ip)
  end

  # Angular standard deviation (circular statistics)
  cos_sum = angles.map { |a| Math.cos(a) }.sum
  sin_sum = angles.map { |a| Math.sin(a) }.sum
  r = Math.sqrt(cos_sum**2 + sin_sum**2) / angles.size
  angular_stability = r # 1.0 = perfect stability, 0.0 = random

  {
    magnitude_cv: cv,
    angular_stability: angular_stability,
    quality: (cv < 0.2 && angular_stability > 0.8) ? "Excellent" :
             (cv < 0.4 && angular_stability > 0.6) ? "Good" :
             (cv < 0.6 && angular_stability > 0.4) ? "Fair" : "Poor"
  }
end

in_phase, quadrature = SQA::TAI.ht_phasor(prices)
stability = phasor_stability(in_phase, quadrature)

if stability
  puts "Phasor Quality Assessment:"
  puts "Magnitude Variation: #{(stability[:magnitude_cv] * 100).round(1)}%"
  puts "Angular Stability: #{(stability[:angular_stability] * 100).round(1)}%"
  puts "Overall Quality: #{stability[:quality]}"

  if stability[:quality] == "Excellent" || stability[:quality] == "Good"
    puts "Recommendation: Signals are reliable - trade with confidence"
  else
    puts "Recommendation: Signals questionable - use additional confirmation"
  end
end
```

## References

- **"Rocket Science for Traders"** by John F. Ehlers - Comprehensive coverage of Hilbert Transform and phasor analysis
- **"Cybernetic Analysis for Stocks and Futures"** by John F. Ehlers - Advanced cycle indicators and adaptive systems
- **"Cycle Analytics for Traders"** by John F. Ehlers - Detailed cycle analysis methodologies
- **Original Research**: John F. Ehlers pioneered the application of Hilbert Transform and phasor analysis to trading
- **Digital Signal Processing**: Concepts from electrical engineering adapted for market analysis
- **TA-Lib Documentation**: [HT_PHASOR Function](https://ta-lib.org/function.html?name=HT_PHASOR)

## See Also

- [Cycle Indicators Overview](../index.md)
- [Hilbert Transform Indicators Family](../index.md#cycle-indicators)
<!-- TODO: Create example file -->
- Advanced Cycle Analysis Guide
- [API Reference](../../api-reference.md)
