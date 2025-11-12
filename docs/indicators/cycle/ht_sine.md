# HT_SINE (Hilbert Transform - Sine Wave Indicator)

## Overview

The Hilbert Transform - Sine Wave Indicator (HT_SINE) is an advanced cycle-based technical indicator that generates sine wave and lead sine wave representations of the dominant market cycle. Developed by John F. Ehlers, it transforms price data into smooth oscillating waveforms that reveal the natural rhythm of market cycles, providing traders with precise timing signals for entries and exits based on cycle phase analysis.

Unlike traditional oscillators that measure momentum or rate of change, HT_SINE directly models the market's cyclical behavior as a sine wave, with the lead sine wave positioned 90 degrees ahead to provide early warning of cycle turning points.

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
- The algorithm automatically extracts the dominant cycle and represents it as sine waves

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

# Calculate sine wave indicators
prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 45.61,
          46.50, 47.20, 46.80, 47.50, 48.10, 48.30,
          # ... more data points ...
         ]

sine, lead_sine = SQA::TAI.ht_sine(prices)

# Current values
current_sine = sine.last
current_lead = lead_sine.last

puts "Sine: #{current_sine.round(3)}"
puts "Lead Sine: #{current_lead.round(3)}"
```

### Practical Application

```ruby
# Detect crossover signals
sine, lead_sine = SQA::TAI.ht_sine(prices)

# Current and previous values
curr_sine = sine.last
prev_sine = sine[-2]
curr_lead = lead_sine.last
prev_lead = lead_sine[-2]

# Identify crossovers
if prev_sine <= prev_lead && curr_sine > curr_lead
  puts "BULLISH CROSSOVER: Sine crossed above Lead Sine"
  puts "Consider LONG entry"
elsif prev_sine >= prev_lead && curr_sine < curr_lead
  puts "BEARISH CROSSOVER: Sine crossed below Lead Sine"
  puts "Consider SHORT entry"
end

# Check cycle extremes for signal strength
if curr_sine.abs > 0.7 || curr_lead.abs > 0.7
  puts "Near cycle extreme - stronger signal quality"
end
```

## Understanding the Indicator

### What It Measures

HT_SINE generates **two synchronized sine wave outputs** that model the market's dominant cycle:

1. **Sine Wave**: Represents the current phase of the dominant market cycle
2. **Lead Sine Wave**: Positioned 90 degrees (quarter-cycle) ahead, providing early warnings

Both oscillate between -1 and +1, creating a smooth representation of cyclical price movement. The relationship between these waves reveals:
- Current position within the market cycle
- Upcoming cycle turning points
- Optimal timing for trade entries and exits

### Why It's Important

Traditional indicators react to price changes after they occur. HT_SINE's lead sine component provides a **forward-looking perspective**:

**Key Advantages:**
- **Early Signals**: Lead sine warns of upcoming turning points before they appear in price
- **Cycle Clarity**: Removes noise to reveal underlying market rhythm
- **Precise Timing**: Crossovers occur at specific cycle phases
- **Universal Application**: Works across different markets and timeframes

**Market Cycle Modeling:**
- Markets naturally oscillate between overbought and oversold conditions
- HT_SINE models this oscillation as a pure sine wave
- The lead sine shows where the cycle is heading
- Crossovers indicate cycle phase transitions

### Calculation Method

The Hilbert Transform is a sophisticated mathematical technique that extracts cycle information from price data:

1. **Apply Hilbert Transform** to decompose price into amplitude and phase components
2. **Extract dominant cycle** from the phase information
3. **Generate sine wave** representing current cycle phase (oscillates between -1 and +1)
4. **Generate lead sine** positioned 90 degrees ahead of sine wave
5. **Smooth outputs** to reduce noise while preserving cycle timing

**Key Concept:**
Think of it like converting jagged price movements into smooth musical waves. The sine wave shows "where you are" in the song, while the lead sine shows "what note is coming next."

**Mathematical Relationship:**
- Lead Sine = Sine advanced by 90 degrees (π/2 radians)
- A 90-degree phase shift means the lead sine reaches its peaks/troughs one quarter-cycle before the regular sine
- This advance warning is what makes crossover signals predictive

### Indicator Characteristics

- **Range**: Both sine and lead sine oscillate between -1 and +1
- **Type**: Cycle-based oscillator, leading indicator
- **Lag**: Low - the lead sine component provides advance warning
- **Best Used**: Markets with clear cyclical behavior, range-bound or oscillating markets
- **Signal Quality**: Strongest at cycle extremes (values near ±1), weaker near zero-line

## Interpretation

### Value Ranges

Both sine and lead sine oscillate in a defined range:

**Upper Half (0 to +1):**
- **+0.7 to +1.0**: Cycle approaching peak, market overbought zone
  - Strong bullish phase
  - Watch for bearish reversal signals
  - Strongest when lead sine also near +1
- **+0.3 to +0.7**: Upper mid-cycle, bullish momentum
  - Upward phase continues
  - Safe to hold long positions
  - Monitor for lead sine divergence
- **0 to +0.3**: Crossing into upper territory
  - Early bullish phase
  - Bullish crossover zone
  - Consider new long positions

**Lower Half (-1 to 0):**
- **-1.0 to -0.7**: Cycle approaching trough, market oversold zone
  - Strong bearish phase
  - Watch for bullish reversal signals
  - Strongest when lead sine also near -1
- **-0.7 to -0.3**: Lower mid-cycle, bearish momentum
  - Downward phase continues
  - Avoid long positions
  - Monitor for lead sine divergence
- **-0.3 to 0**: Crossing into lower territory
  - Early bearish phase
  - Bearish crossover zone
  - Consider short positions or exits

### Sine Wave Patterns

**Wave Synchronization:**
When sine and lead sine move together (small separation):
- Market following expected cycle rhythm
- Predictions reliable
- Crossover signals likely to work

**Wave Divergence:**
When sine and lead sine spread apart:
- Market cycle becoming distorted
- Potential cycle break or regime change
- Reduce position sizes, wait for re-synchronization

**Wave Amplitude:**
- Large swings (reaching ±0.9 to ±1.0): Strong cyclical behavior, high signal reliability
- Small swings (staying within ±0.5): Weak cycle, choppy market, lower signal quality
- Increasing amplitude: Cycle strengthening
- Decreasing amplitude: Cycle weakening, possible trend emergence

### Crossover Interpretation

**Bullish Crossover (Sine crosses above Lead Sine):**
- Occurs in lower half of cycle (typically below zero)
- Best when both near -1 (cycle trough)
- Indicates cycle transitioning from down phase to up phase
- Signal to enter long positions or exit shorts

**Bearish Crossover (Sine crosses below Lead Sine):**
- Occurs in upper half of cycle (typically above zero)
- Best when both near +1 (cycle peak)
- Indicates cycle transitioning from up phase to down phase
- Signal to enter short positions or exit longs

**Signal Strength Factors:**
1. **Location**: Crossovers at extremes (near ±1) are stronger
2. **Amplitude**: Larger wave swings produce more reliable signals
3. **Clarity**: Clean crossovers better than multiple touches
4. **Confirmation**: Multiple cycles showing same pattern

## Trading Signals

### Primary Crossover Strategy

**Entry Signals:**

```ruby
sine, lead_sine = SQA::TAI.ht_sine(prices)

# Get current and previous values
curr_sine = sine.last
prev_sine = sine[-2]
curr_lead = lead_sine.last
prev_lead = lead_sine[-2]

# Calculate cycle extreme strength
extreme_value = [curr_sine.abs, curr_lead.abs].max

# Bullish crossover
if prev_sine <= prev_lead && curr_sine > curr_lead
  signal_strength = extreme_value > 0.7 ? "STRONG" : "MODERATE"

  puts "LONG SIGNAL (#{signal_strength})"
  puts "Sine crossed above Lead Sine"
  puts "Sine: #{curr_sine.round(3)}, Lead: #{curr_lead.round(3)}"
  puts "Enter long position" if signal_strength == "STRONG"
end

# Bearish crossover
if prev_sine >= prev_lead && curr_sine < curr_lead
  signal_strength = extreme_value > 0.7 ? "STRONG" : "MODERATE"

  puts "SHORT SIGNAL (#{signal_strength})"
  puts "Sine crossed below Lead Sine"
  puts "Sine: #{curr_sine.round(3)}, Lead: #{curr_lead.round(3)}"
  puts "Enter short position or exit longs" if signal_strength == "STRONG"
end
```

### Cycle Extreme Entry Strategy

**Wait for Optimal Entry Points:**

```ruby
sine, lead_sine = SQA::TAI.ht_sine(prices)

curr_sine = sine.last
curr_lead = lead_sine.last
curr_price = prices.last

# Define extreme zones
EXTREME_THRESHOLD = 0.75

# Oversold zone (cycle trough)
if curr_sine < -EXTREME_THRESHOLD && curr_lead < -EXTREME_THRESHOLD
  if curr_sine > curr_lead
    puts "STRONG BUY ZONE"
    puts "Both sine waves in oversold territory"
    puts "Sine starting to rise - cycle bottoming"
    puts "High-probability long entry"
  else
    puts "OVERSOLD - WAITING"
    puts "Monitor for sine to cross above lead sine"
  end
end

# Overbought zone (cycle peak)
if curr_sine > EXTREME_THRESHOLD && curr_lead > EXTREME_THRESHOLD
  if curr_sine < curr_lead
    puts "STRONG SELL ZONE"
    puts "Both sine waves in overbought territory"
    puts "Sine starting to fall - cycle peaking"
    puts "High-probability short entry or long exit"
  else
    puts "OVERBOUGHT - WAITING"
    puts "Monitor for sine to cross below lead sine"
  end
end
```

### Cycle Phase Trading System

**Complete Entry/Exit Strategy:**

```ruby
require 'sqa/tai'

def analyze_sine_wave_position(prices, highs, lows)
  # Calculate indicators
  sine, lead_sine = SQA::TAI.ht_sine(prices)
  atr = SQA::TAI.atr(highs, lows, prices, period: 14)

  curr_sine = sine.last
  prev_sine = sine[-2]
  curr_lead = lead_sine.last
  prev_lead = lead_sine[-2]
  curr_price = prices.last
  curr_atr = atr.last

  # Determine cycle phase
  if curr_sine > 0 && curr_lead > 0
    phase = "Upper half - Bullish"
  elsif curr_sine < 0 && curr_lead < 0
    phase = "Lower half - Bearish"
  else
    phase = "Transition zone"
  end

  puts "=== Sine Wave Analysis ==="
  puts "Sine: #{curr_sine.round(3)}"
  puts "Lead Sine: #{curr_lead.round(3)}"
  puts "Cycle Phase: #{phase}"
  puts

  # Trading signals
  extreme_level = [curr_sine.abs, curr_lead.abs].max

  # Buy signal
  if prev_sine <= prev_lead && curr_sine > curr_lead && curr_sine < 0
    puts ">>> BUY SIGNAL <<<"
    puts "Strength: #{extreme_level > 0.7 ? 'STRONG' : 'MODERATE'}"
    puts "Entry Price: #{curr_price.round(2)}"
    puts "Stop Loss: #{(curr_price - 2 * curr_atr).round(2)}"
    puts "Target 1: #{(curr_price + 2 * curr_atr).round(2)} (near zero line)"
    puts "Target 2: #{(curr_price + 4 * curr_atr).round(2)} (cycle peak)"
    puts
  # Sell signal
  elsif prev_sine >= prev_lead && curr_sine < curr_lead && curr_sine > 0
    puts ">>> SELL SIGNAL <<<"
    puts "Strength: #{extreme_level > 0.7 ? 'STRONG' : 'MODERATE'}"
    puts "Entry Price: #{curr_price.round(2)}"
    puts "Stop Loss: #{(curr_price + 2 * curr_atr).round(2)}"
    puts "Target 1: #{(curr_price - 2 * curr_atr).round(2)} (near zero line)"
    puts "Target 2: #{(curr_price - 4 * curr_atr).round(2)} (cycle trough)"
    puts
  # Hold signals
  elsif curr_sine > curr_lead && curr_sine < 0.7
    puts "HOLD LONG - Cycle still rising"
  elsif curr_sine < curr_lead && curr_sine > -0.7
    puts "HOLD SHORT - Cycle still falling"
  else
    puts "NO SIGNAL - Wait for crossover"
  end

  # Warning signals
  if extreme_level < 0.3
    puts "WARNING: Weak cycle amplitude - reduce position size"
  end

  if (curr_sine - curr_lead).abs > 0.5
    puts "WARNING: Large wave separation - cycle may be breaking"
  end
end

# Usage
analyze_sine_wave_position(prices, highs, lows)
```

### Divergence Detection

**Advanced Signal Confirmation:**

```ruby
# Calculate sine waves and price highs/lows
sine, lead_sine = SQA::TAI.ht_sine(prices)

# Find recent peaks
def find_peaks(array, window = 5)
  peaks = []
  (window...array.size - window).each do |i|
    is_peak = true
    (-window..window).each do |offset|
      next if offset == 0
      if array[i] <= array[i + offset]
        is_peak = false
        break
      end
    end
    peaks << i if is_peak
  end
  peaks
end

# Bullish divergence
# Price makes lower low, but sine makes higher low
price_lows = find_peaks(prices.map(&:-@), 5)
sine_lows = find_peaks(sine.map(&:-@), 5)

if price_lows.size >= 2 && sine_lows.size >= 2
  last_price_low = prices[price_lows[-1]]
  prev_price_low = prices[price_lows[-2]]
  last_sine_low = sine[sine_lows[-1]]
  prev_sine_low = sine[sine_lows[-2]]

  if last_price_low < prev_price_low && last_sine_low > prev_sine_low
    puts "BULLISH DIVERGENCE DETECTED"
    puts "Price making lower lows, sine wave making higher lows"
    puts "Potential cycle reversal coming"
  end
end
```

## Best Practices

### Optimal Use Cases

**When HT_SINE works best:**
- **Range-bound markets**: Clear oscillation between support and resistance
- **Cyclical markets**: Forex pairs, commodities with seasonal patterns
- **Established cycles**: Markets showing consistent rhythm
- **Medium-term trading**: Daily to weekly charts work best
- **High liquidity**: Major markets with smooth price action

**Less effective in:**
- **Strong trending markets**: Sine waves become distorted
- **Low volatility**: Amplitude shrinks, signals become unclear
- **Very short timeframes**: Too much noise (< 15-minute charts)
- **Break-out scenarios**: Cycle-based approach fails during regime changes
- **News-driven spikes**: Disrupts cyclical patterns

### Combining with Other Indicators

**With HT_DCPERIOD (Cycle Period):**
```ruby
# Validate cycle quality before trading sine signals
cycle_period = SQA::TAI.ht_dcperiod(prices)
sine, lead_sine = SQA::TAI.ht_sine(prices)

curr_cycle = cycle_period.last
curr_sine = sine.last
curr_lead = lead_sine.last

# Only trade if cycle is in reasonable range
if curr_cycle.between?(12, 35)
  # Proceed with sine wave signals
  if sine[-2] <= lead_sine[-2] && curr_sine > curr_lead
    puts "Valid BUY signal - cycle period: #{curr_cycle.round}"
  end
else
  puts "Cycle period outside normal range - avoid sine wave signals"
end
```

**With HT_TRENDMODE (Trend Detection):**
```ruby
# Only use sine wave signals in cycle mode
trend_mode = SQA::TAI.ht_trendmode(prices)
sine, lead_sine = SQA::TAI.ht_sine(prices)

if trend_mode.last == 0 # Cycle mode
  # Use sine wave crossover signals
  if sine.last > lead_sine.last
    puts "LONG - Confirmed cycle mode"
  end
elsif trend_mode.last == 1 # Trend mode
  # Use trend-following indicators instead
  puts "Trend mode detected - sine wave signals not recommended"
end
```

**With HT_DCPHASE (Cycle Phase):**
```ruby
# Confirm cycle position with phase indicator
phase = SQA::TAI.ht_dcphase(prices)
sine, lead_sine = SQA::TAI.ht_sine(prices)

curr_phase = phase.last
curr_sine = sine.last

# Phase near 0 or 360 should align with sine near -1
# Phase near 180 should align with sine near +1
if curr_phase < 45 || curr_phase > 315
  puts "Phase indicates cycle trough"
  puts "Sine should be near -1: #{curr_sine.round(3)}"
  if curr_sine < -0.7
    puts "Phase and sine aligned - strong signal quality"
  end
end
```

**With Traditional Oscillators:**
```ruby
# Confirm with RSI for additional conviction
rsi = SQA::TAI.rsi(prices, period: 14)
sine, lead_sine = SQA::TAI.ht_sine(prices)

# Buy when both oversold
if sine.last < -0.7 && sine.last > lead_sine.last && rsi.last < 30
  puts "STRONG BUY: Both HT_SINE and RSI oversold + bullish crossover"
end

# Sell when both overbought
if sine.last > 0.7 && sine.last < lead_sine.last && rsi.last > 70
  puts "STRONG SELL: Both HT_SINE and RSI overbought + bearish crossover"
end
```

**With Support/Resistance:**
```ruby
# Sine wave signals at key price levels are stronger
sine, lead_sine = SQA::TAI.ht_sine(prices)
curr_price = prices.last

support_level = 100.0 # Your support level
resistance_level = 120.0 # Your resistance level

# Buy signal near support
if sine.last > lead_sine.last && curr_price <= support_level * 1.02
  puts "HIGH PROBABILITY BUY: Sine bullish crossover + near support"
end

# Sell signal near resistance
if sine.last < lead_sine.last && curr_price >= resistance_level * 0.98
  puts "HIGH PROBABILITY SELL: Sine bearish crossover + near resistance"
end
```

### Common Pitfalls

1. **Insufficient Data**
   - Need minimum 32-63 bars for reliable results
   - Initial values will be unstable and unreliable
   - Always skip first 30-40 values when backtesting
   - Verify data quality before trading live

2. **Trading in Trend Mode**
   - Sine waves become distorted during strong trends
   - Crossovers produce false signals
   - Use HT_TRENDMODE to filter out trending periods
   - Switch to trend-following indicators when trend detected

3. **Ignoring Signal Strength**
   - Not all crossovers are equal
   - Crossovers at extremes (near ±1) are much stronger
   - Crossovers near zero line are often false signals
   - Always check amplitude and extreme levels

4. **Over-Trading Weak Cycles**
   - Small wave amplitude indicates weak cycle
   - Multiple small crossovers produce whipsaws
   - Wait for amplitude to increase before trading
   - Use amplitude threshold: trade only if |sine| or |lead| > 0.6

5. **Neglecting Market Context**
   - Sine waves don't predict fundamental shocks
   - News events can break cycle patterns
   - Economic releases can override technical signals
   - Always use risk management regardless of signal strength

6. **Ignoring Wave Synchronization**
   - Large separation between sine and lead sine = trouble
   - Indicates cycle breaking down or regime change
   - Reduce position sizes when separation > 0.5
   - Wait for waves to re-synchronize

### Parameter Selection Guidelines

Since HT_SINE has no adjustable parameters, focus on optimal timeframe selection:

**For Intraday Trading:**
- Use 15-minute to 1-hour charts minimum
- Expect 3-6 crossover signals per day
- Set tight stops (1-2 ATR)
- Take profits quickly at opposite extreme
- Higher false signal rate - use confirmation

**For Swing Trading:**
- Use daily charts (optimal timeframe)
- Expect 2-4 crossover signals per month
- Set moderate stops (2-3 ATR)
- Hold through half-cycle to full-cycle
- Best risk/reward ratio

**For Position Trading:**
- Use weekly charts
- Expect 1-2 crossover signals per quarter
- Set wider stops (3-4 ATR)
- Hold for multiple weeks
- Very reliable signals but fewer opportunities

## Practical Example

Complete trading system with entry, exit, and risk management:

```ruby
require 'sqa/tai'

class SineWaveTrader
  EXTREME_THRESHOLD = 0.70  # Minimum for strong signals
  WEAK_AMPLITUDE = 0.30     # Below this, avoid trading
  MAX_SEPARATION = 0.50     # Max distance between sine waves

  def initialize(prices, highs, lows)
    @prices = prices
    @highs = highs
    @lows = lows

    # Calculate indicators
    @sine, @lead_sine = SQA::TAI.ht_sine(@prices)
    @cycle_period = SQA::TAI.ht_dcperiod(@prices)
    @trend_mode = SQA::TAI.ht_trendmode(@prices)
    @atr = SQA::TAI.atr(@highs, @lows, @prices, period: 14)
    @rsi = SQA::TAI.rsi(@prices, period: 14)
  end

  def analyze
    return "Insufficient data" if @sine.size < 2

    # Current and previous values
    curr_sine = @sine.last
    prev_sine = @sine[-2]
    curr_lead = @lead_sine.last
    prev_lead = @lead_sine[-2]
    curr_price = @prices.last
    curr_atr = @atr.last
    curr_trend_mode = @trend_mode.last
    curr_rsi = @rsi.last

    # Calculate metrics
    extreme_level = [curr_sine.abs, curr_lead.abs].max
    wave_separation = (curr_sine - curr_lead).abs
    amplitude_strength = extreme_level > EXTREME_THRESHOLD ? "Strong" : "Weak"

    puts <<~ANALYSIS
      ==========================================
      SINE WAVE TRADING ANALYSIS
      ==========================================
      Price: #{curr_price.round(2)}
      ATR: #{curr_atr.round(2)}

      Sine Wave Values:
      - Sine: #{curr_sine.round(3)}
      - Lead Sine: #{curr_lead.round(3)}
      - Separation: #{wave_separation.round(3)}

      Cycle Metrics:
      - Extreme Level: #{extreme_level.round(3)} (#{amplitude_strength})
      - Cycle Period: #{@cycle_period.last.round(1)} bars
      - Trend Mode: #{curr_trend_mode == 1 ? 'TREND' : 'CYCLE'}
      - RSI: #{curr_rsi.round(1)}
    ANALYSIS

    # Pre-flight checks
    if curr_trend_mode == 1
      puts "\nWARNING: Trend mode detected - sine signals unreliable"
      return "No trade - trending market"
    end

    if extreme_level < WEAK_AMPLITUDE
      puts "\nWARNING: Weak cycle amplitude - poor signal quality"
      return "No trade - weak cycle"
    end

    if wave_separation > MAX_SEPARATION
      puts "\nWARNING: Large wave separation - cycle breaking down"
      return "No trade - unstable cycle"
    end

    # Signal detection
    bullish_cross = prev_sine <= prev_lead && curr_sine > curr_lead
    bearish_cross = prev_sine >= prev_lead && curr_sine < curr_lead

    if bullish_cross
      puts "\n#{extreme_level > EXTREME_THRESHOLD ? '>>> STRONG BUY SIGNAL <<<' : '>> BUY SIGNAL <<'}"
      generate_buy_signal(curr_price, curr_atr, curr_sine, curr_rsi, extreme_level)
    elsif bearish_cross
      puts "\n#{extreme_level > EXTREME_THRESHOLD ? '>>> STRONG SELL SIGNAL <<<' : '>> SELL SIGNAL <<'}"
      generate_sell_signal(curr_price, curr_atr, curr_sine, curr_rsi, extreme_level)
    elsif curr_sine > curr_lead && curr_sine < 0.8
      puts "\nPOSITION: Hold Long - Cycle still rising"
      puts "Exit Target: Sine reaches +#{EXTREME_THRESHOLD.round(2)} or bearish crossover"
    elsif curr_sine < curr_lead && curr_sine > -0.8
      puts "\nPOSITION: Hold Short - Cycle still falling"
      puts "Exit Target: Sine reaches -#{EXTREME_THRESHOLD.round(2)} or bullish crossover"
    else
      puts "\nNO SIGNAL - Waiting for crossover"
      puts "Current Phase: #{get_cycle_phase(curr_sine)}"
    end
  end

  private

  def generate_buy_signal(price, atr, sine, rsi, extreme)
    stop_loss = price - (2 * atr)
    target_1 = price + (2 * atr)
    target_2 = price + (4 * atr)
    risk = price - stop_loss
    reward_1 = target_1 - price
    reward_2 = target_2 - price

    puts <<~SIGNAL

      Entry: #{price.round(2)}
      Stop Loss: #{stop_loss.round(2)} (-#{((risk / price) * 100).round(2)}%)

      Target 1: #{target_1.round(2)} (R:R 1:#{(reward_1 / risk).round(1)})
      Target 2: #{target_2.round(2)} (R:R 1:#{(reward_2 / risk).round(1)})

      Signal Quality:
      - Extreme Level: #{extreme.round(3)} #{extreme > EXTREME_THRESHOLD ? '(STRONG)' : '(Moderate)'}
      - RSI Confirmation: #{rsi < 40 ? 'YES - Oversold' : 'NO - Not oversold'}
      - Cycle Phase: #{get_cycle_phase(sine)}

      Expected Duration: #{(@cycle_period.last / 2).round} bars to peak

      Trade Plan:
      1. Enter long position at market
      2. Place stop at #{stop_loss.round(2)}
      3. Take 50% profit at Target 1
      4. Move stop to breakeven
      5. Take remaining 50% at Target 2 or bearish crossover
    SIGNAL
  end

  def generate_sell_signal(price, atr, sine, rsi, extreme)
    stop_loss = price + (2 * atr)
    target_1 = price - (2 * atr)
    target_2 = price - (4 * atr)
    risk = stop_loss - price
    reward_1 = price - target_1
    reward_2 = price - target_2

    puts <<~SIGNAL

      Entry: #{price.round(2)}
      Stop Loss: #{stop_loss.round(2)} (+#{((risk / price) * 100).round(2)}%)

      Target 1: #{target_1.round(2)} (R:R 1:#{(reward_1 / risk).round(1)})
      Target 2: #{target_2.round(2)} (R:R 1:#{(reward_2 / risk).round(1)})

      Signal Quality:
      - Extreme Level: #{extreme.round(3)} #{extreme > EXTREME_THRESHOLD ? '(STRONG)' : '(Moderate)'}
      - RSI Confirmation: #{rsi > 60 ? 'YES - Overbought' : 'NO - Not overbought'}
      - Cycle Phase: #{get_cycle_phase(sine)}

      Expected Duration: #{(@cycle_period.last / 2).round} bars to trough

      Trade Plan:
      1. Enter short position at market (or exit longs)
      2. Place stop at #{stop_loss.round(2)}
      3. Take 50% profit at Target 1
      4. Move stop to breakeven
      5. Take remaining 50% at Target 2 or bullish crossover
    SIGNAL
  end

  def get_cycle_phase(sine_value)
    case sine_value
    when 0.7..1.0 then "Peak (Overbought)"
    when 0.3..0.7 then "Rising (Bullish)"
    when -0.3..0.3 then "Midpoint (Neutral)"
    when -0.7..-0.3 then "Falling (Bearish)"
    when -1.0..-0.7 then "Trough (Oversold)"
    end
  end
end

# Usage Example
prices = [
  # Your price data - need at least 63 bars
]
highs = [...]
lows = [...]

trader = SineWaveTrader.new(prices, highs, lows)
trader.analyze
```

## Related Indicators

### Hilbert Transform Family

- **[HT_DCPERIOD](ht_dcperiod.md)**: Identifies the length of the dominant cycle (use to validate sine wave reliability)
- **[HT_DCPHASE](ht_dcphase.md)**: Shows current position within the cycle (0-360 degrees) - confirms sine wave position
- **[HT_PHASOR](ht_phasor.md)**: Provides in-phase and quadrature components for advanced cycle analysis
- **[HT_TRENDMODE](ht_trendmode.md)**: Critical for filtering - only use sine signals in cycle mode (0), not trend mode (1)
- **[HT_TRENDLINE](../volatility/ht_trendline.md)**: Provides instantaneous trendline based on Hilbert Transform

### Complementary Indicators

- **[RSI](../momentum/rsi.md)**: Confirm sine wave signals with RSI oversold/overbought levels
- **[STOCH](../momentum/stoch.md)**: Another oscillator for signal confirmation
- **[ATR](../volatility/atr.md)**: Essential for setting stops and targets based on volatility
- **[MACD](../momentum/macd.md)**: Can confirm trend direction when sine waves disagree

### Alternative Cycle/Oscillator Indicators

- **[CCI](../momentum/cci.md)**: Commodity Channel Index - another cycle-based oscillator
- **[CMO](../momentum/cmo.md)**: Chande Momentum Oscillator - momentum-based alternative
- **[MAMA](../volatility/mama.md)**: MESA Adaptive Moving Average - uses similar adaptive technology

## Advanced Topics

### Multi-Timeframe Sine Wave Analysis

```ruby
# Compare sine waves across timeframes for nested cycle analysis
daily_prices = [...] # daily data
hourly_prices = [...] # hourly data

# Higher timeframe (daily) - primary trend
daily_sine, daily_lead = SQA::TAI.ht_sine(daily_prices)

# Lower timeframe (hourly) - entry timing
hourly_sine, hourly_lead = SQA::TAI.ht_sine(hourly_prices)

# Trade in direction of daily, time entries with hourly
if daily_sine.last > daily_lead.last
  puts "Daily cycle: BULLISH - look for long entries only"

  if hourly_sine.last > hourly_lead.last && hourly_sine.last < -0.5
    puts "Hourly cycle: OVERSOLD + bullish crossover"
    puts "HIGH PROBABILITY LONG ENTRY"
  end
elsif daily_sine.last < daily_lead.last
  puts "Daily cycle: BEARISH - look for short entries only"

  if hourly_sine.last < hourly_lead.last && hourly_sine.last > 0.5
    puts "Hourly cycle: OVERBOUGHT + bearish crossover"
    puts "HIGH PROBABILITY SHORT ENTRY"
  end
end
```

### Sine Wave Prediction

**Project Future Sine Values:**

```ruby
# Current cycle period
cycle_period = SQA::TAI.ht_dcperiod(prices).last
sine, lead_sine = SQA::TAI.ht_sine(prices)

curr_sine = sine.last
curr_lead = lead_sine.last

# Estimate bars until next extreme
# Sine wave completes full cycle in cycle_period bars
# From current position, estimate distance to peak/trough

if curr_sine > 0 && curr_sine < curr_lead
  # Rising toward peak
  bars_to_peak = (cycle_period * 0.25).round # Quarter cycle
  puts "Expected peak in approximately #{bars_to_peak} bars"
  puts "Current sine: #{curr_sine.round(3)}"

elsif curr_sine > 0 && curr_sine > curr_lead
  # Falling from peak
  bars_to_trough = (cycle_period * 0.25).round
  puts "Expected trough in approximately #{bars_to_trough} bars"

elsif curr_sine < 0 && curr_sine > curr_lead
  # Rising from trough
  bars_to_peak = (cycle_period * 0.25).round
  puts "Expected peak in approximately #{bars_to_peak} bars"

elsif curr_sine < 0 && curr_sine < curr_lead
  # Falling toward trough
  bars_to_trough = (cycle_period * 0.25).round
  puts "Expected trough in approximately #{bars_to_trough} bars"
end
```

### Cycle Strength Measurement

**Quantify Signal Quality:**

```ruby
def measure_cycle_strength(sine, lead_sine, window = 20)
  # Recent amplitude
  recent_sine = sine.last(window)
  recent_lead = lead_sine.last(window)

  # Calculate average amplitude
  sine_amplitude = recent_sine.map(&:abs).sum / window.to_f
  lead_amplitude = recent_lead.map(&:abs).sum / window.to_f
  avg_amplitude = (sine_amplitude + lead_amplitude) / 2.0

  # Calculate wave synchronization
  separations = recent_sine.zip(recent_lead).map { |s, l| (s - l).abs }
  avg_separation = separations.sum / window.to_f

  # Count crossovers
  crossovers = 0
  (1...recent_sine.size).each do |i|
    if (recent_sine[i-1] <= recent_lead[i-1] && recent_sine[i] > recent_lead[i]) ||
       (recent_sine[i-1] >= recent_lead[i-1] && recent_sine[i] < recent_lead[i])
      crossovers += 1
    end
  end

  puts "Cycle Strength Analysis (last #{window} bars):"
  puts "- Average Amplitude: #{avg_amplitude.round(3)}"
  puts "- Wave Separation: #{avg_separation.round(3)}"
  puts "- Crossovers: #{crossovers}"

  # Quality assessment
  if avg_amplitude > 0.6 && avg_separation < 0.3 && crossovers >= 2
    puts "Quality: EXCELLENT - Strong reliable signals"
  elsif avg_amplitude > 0.4 && avg_separation < 0.4 && crossovers >= 1
    puts "Quality: GOOD - Acceptable signal quality"
  elsif avg_amplitude > 0.3
    puts "Quality: MODERATE - Use with caution"
  else
    puts "Quality: POOR - Avoid trading sine signals"
  end
end

# Usage
sine, lead_sine = SQA::TAI.ht_sine(prices)
measure_cycle_strength(sine, lead_sine)
```

### Backtesting Framework

**Test Sine Wave Strategy:**

```ruby
def backtest_sine_strategy(prices, highs, lows)
  sine, lead_sine = SQA::TAI.ht_sine(prices)
  atr = SQA::TAI.atr(highs, lows, prices, period: 14)

  trades = []
  position = nil

  # Start after warm-up period
  (50...prices.size).each do |i|
    curr_sine = sine[i]
    prev_sine = sine[i-1]
    curr_lead = lead_sine[i]
    prev_lead = lead_sine[i-1]
    curr_price = prices[i]
    curr_atr = atr[i]

    extreme_level = [curr_sine.abs, curr_lead.abs].max

    # Entry logic
    if position.nil?
      # Bullish crossover
      if prev_sine <= prev_lead && curr_sine > curr_lead && extreme_level > 0.7
        position = {
          type: 'long',
          entry_price: curr_price,
          entry_bar: i,
          stop_loss: curr_price - (2 * curr_atr),
          target: curr_price + (4 * curr_atr)
        }
      # Bearish crossover
      elsif prev_sine >= prev_lead && curr_sine < curr_lead && extreme_level > 0.7
        position = {
          type: 'short',
          entry_price: curr_price,
          entry_bar: i,
          stop_loss: curr_price + (2 * curr_atr),
          target: curr_price - (4 * curr_atr)
        }
      end
    else
      # Exit logic
      hit_stop = false
      hit_target = false
      opposite_cross = false

      if position[:type] == 'long'
        hit_stop = lows[i] <= position[:stop_loss]
        hit_target = highs[i] >= position[:target]
        opposite_cross = prev_sine >= prev_lead && curr_sine < curr_lead
      else # short
        hit_stop = highs[i] >= position[:stop_loss]
        hit_target = lows[i] <= position[:target]
        opposite_cross = prev_sine <= prev_lead && curr_sine > curr_lead
      end

      if hit_stop || hit_target || opposite_cross
        exit_price = if hit_stop
          position[:stop_loss]
        elsif hit_target
          position[:target]
        else
          curr_price
        end

        pnl = position[:type] == 'long' ?
          exit_price - position[:entry_price] :
          position[:entry_price] - exit_price

        trades << {
          type: position[:type],
          entry: position[:entry_price],
          exit: exit_price,
          pnl: pnl,
          pnl_pct: (pnl / position[:entry_price]) * 100,
          bars_held: i - position[:entry_bar],
          exit_reason: hit_stop ? 'stop' : (hit_target ? 'target' : 'crossover')
        }

        position = nil
      end
    end
  end

  # Calculate statistics
  return "No trades" if trades.empty?

  total_trades = trades.size
  winning_trades = trades.select { |t| t[:pnl] > 0 }
  losing_trades = trades.select { |t| t[:pnl] <= 0 }

  win_rate = (winning_trades.size.to_f / total_trades * 100).round(2)
  avg_win = winning_trades.empty? ? 0 : winning_trades.sum { |t| t[:pnl_pct] } / winning_trades.size
  avg_loss = losing_trades.empty? ? 0 : losing_trades.sum { |t| t[:pnl_pct] } / losing_trades.size
  avg_bars = trades.sum { |t| t[:bars_held] }.to_f / total_trades

  puts <<~RESULTS
    ==========================================
    BACKTEST RESULTS
    ==========================================
    Total Trades: #{total_trades}
    Winning Trades: #{winning_trades.size}
    Losing Trades: #{losing_trades.size}
    Win Rate: #{win_rate}%

    Average Win: #{avg_win.round(2)}%
    Average Loss: #{avg_loss.round(2)}%
    Average Bars Held: #{avg_bars.round(1)}

    Exit Reasons:
    - Stop Loss: #{trades.count { |t| t[:exit_reason] == 'stop' }}
    - Target: #{trades.count { |t| t[:exit_reason] == 'target' }}
    - Crossover: #{trades.count { |t| t[:exit_reason] == 'crossover' }}
  RESULTS

  trades
end

# Run backtest
trades = backtest_sine_strategy(prices, highs, lows)
```

## References

- **"Rocket Science for Traders"** by John F. Ehlers - Comprehensive coverage of Hilbert Transform and sine wave generation
- **"Cybernetic Analysis for Stocks and Futures"** by John F. Ehlers - Advanced cycle-based trading techniques
- **"Cycle Analytics for Traders"** by John F. Ehlers - Deep dive into cycle detection and trading
- **Original Research**: John F. Ehlers developed the Hilbert Transform approach for financial markets
- **TA-Lib Documentation**: [HT_SINE Function](https://ta-lib.org/function.html?name=HT_SINE)

## See Also

- [Cycle Indicators Overview](../index.md)
- [Hilbert Transform Indicators Family](../index.md#cycle-indicators)
<!-- TODO: Create example file -->
- Using HT_SINE with HT_TRENDMODE
<!-- TODO: Create example file -->
- Adaptive Trading Strategies
- [API Reference](../../api-reference.md)
