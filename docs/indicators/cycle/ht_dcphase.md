# HT_DCPHASE (Hilbert Transform - Dominant Cycle Phase)

## Overview

The Hilbert Transform - Dominant Cycle Phase (HT_DCPHASE) is an advanced technical indicator that identifies the current phase position within the dominant market cycle, measured in degrees from 0 to 360. This indicator answers the critical question: "Where are we in the current market cycle?" By knowing the phase, traders can precisely time entries and exits based on the natural rhythm of the market, buying near cycle bottoms (0°) and selling near cycle tops (180°).

Unlike traditional momentum oscillators that react to price changes, HT_DCPHASE uses the Hilbert Transform to mathematically decompose price data into its phase components, providing a leading perspective on cycle positioning. This makes it invaluable for anticipating turning points and timing trades with the market's natural ebb and flow.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `prices` | Array<Float> | Required | Array of price values (typically close prices) |

### Parameter Details

**prices**
- Input data should be an array of closing prices
- Minimum 32 data points required for reliable results (due to Hilbert Transform calculation requirements)
- More data provides better accuracy in phase identification
- Works best with at least 63+ data points for stable output
- No adjustable parameters - the indicator automatically adapts to current market conditions

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

# Calculate dominant cycle phase
prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 45.61,
          46.50, 47.20, 46.80, 47.50, 48.10, 48.30,
          # ... more data points (need at least 32-63) ...
         ]

phase = SQA::TAI.ht_dcphase(prices)

# The phase tells you where you are in the cycle (0-360 degrees)
current_phase = phase.last
puts "Current cycle phase: #{current_phase.round(1)}°"

# Interpret the phase position
case current_phase
when 0..45
  puts "Near cycle bottom - potential buy zone"
when 46..135
  puts "Rising through cycle - upward momentum"
when 136..225
  puts "Near cycle top - potential sell zone"
when 226..315
  puts "Falling through cycle - downward momentum"
else
  puts "Approaching cycle bottom - prepare for reversal"
end
```

### Practical Application

```ruby
# Use phase to time entries at optimal cycle positions
phase = SQA::TAI.ht_dcphase(prices)
current_phase = phase.last
current_price = prices.last

# Define phase zones for trading
BOTTOM_ZONE = (0..30)      # Buy zone
RISING_ZONE = (31..150)    # Hold long
TOP_ZONE = (151..210)      # Sell zone
FALLING_ZONE = (211..329)  # Hold short or wait
APPROACHING_BOTTOM = (330..360) # Prepare to buy

if BOTTOM_ZONE.cover?(current_phase)
  puts "BUY SIGNAL: Phase at #{current_phase.round}° - cycle bottom"
  puts "Entry: #{current_price}"
  puts "Expected next peak at phase ~180°"

elsif TOP_ZONE.cover?(current_phase)
  puts "SELL SIGNAL: Phase at #{current_phase.round}° - cycle top"
  puts "Exit: #{current_price}"
  puts "Expected next trough at phase ~360°/0°"

elsif APPROACHING_BOTTOM.cover?(current_phase)
  puts "PREPARE: Phase at #{current_phase.round}° - approaching bottom"
  puts "Get ready to enter long position"
end
```

## Understanding the Indicator

### What It Measures

HT_DCPHASE measures **the angular position within the dominant market cycle**, expressed in degrees from 0 to 360. Think of the market cycle as a clock face or a wheel that continuously rotates:

- **0° (12 o'clock)**: Cycle trough/bottom - the lowest point
- **90° (3 o'clock)**: Rising through middle - maximum upward momentum
- **180° (6 o'clock)**: Cycle peak/top - the highest point
- **270° (9 o'clock)**: Falling through middle - maximum downward momentum
- **360° (back to 12)**: Returns to cycle bottom to begin next cycle

The indicator provides a continuous measurement of where the market is positioned in its natural oscillation, allowing traders to anticipate the next move before it happens.

### Why It's Important

Traditional indicators tell you what has already happened. Phase analysis tells you where you are in the ongoing cycle:

**Benefits of Phase Analysis:**
- **Precise Timing**: Know when you're at a cycle extreme (buy at 0°, sell at 180°)
- **Leading Information**: Phase can lead price changes at turning points
- **Objective Positioning**: Removes guesswork about cycle location
- **Universal Application**: Works across all timeframes and markets
- **Complementary to Other Indicators**: Adds timing precision to trend and momentum signals

**Real-World Analogy:**
If markets are like ocean tides, HT_DCPHASE tells you whether the tide is at low tide (0°), rising (90°), high tide (180°), or falling (270°). You wouldn't go surfing at low tide or try to collect shells at high tide - similarly, you want to trade with the cycle phase.

### Calculation Method

The Hilbert Transform is a sophisticated mathematical technique from signal processing that reveals the hidden periodic structure in price data:

1. **Apply Hilbert Transform** to the price series to separate it into amplitude and phase components
2. **Extract instantaneous phase** - the angular position in the current cycle
3. **Unwrap phase angles** to handle the 0-360° discontinuity smoothly
4. **Output continuous phase measurement** in degrees

**Key Concept:**
The Hilbert Transform creates an imaginary component that is 90° out of phase with the real price data. By combining these components, the algorithm can extract the instantaneous phase angle at each point in time, effectively creating a mathematical "clock" that tracks cycle position.

**Mathematical Foundation:**
- Uses quadrature (90° shifted) relationships between price and its transform
- Phase = arctan(imaginary_component / real_component)
- Automatically adapts to changing cycle frequencies
- Provides continuous, smooth phase transitions

### Indicator Characteristics

- **Range**: 0 to 360 degrees (continuous)
- **Type**: Cycle analysis, phase measurement
- **Lag**: Moderate - some history needed but provides leading information at extremes
- **Best Used**: Timing entries/exits, identifying reversal zones, confirming cycle position
- **Update Frequency**: Real-time with each new price bar

## Interpretation

### Phase Zones and Their Meanings

The 360° cycle can be divided into actionable trading zones:

#### Zone 1: Bottom/Trough (0° ± 30°)
**Phase Range**: 330° - 30°
**Market Condition**: Cycle bottom, potential reversal point
**Typical Price Action**:
- Downward momentum exhausting
- Price reaching local lows
- Reversal patterns may form
**Trading Implication**: Primary buying zone, enter long positions

#### Zone 2: Rising Phase (30° - 150°)
**Phase Range**: 31° - 150°
**Market Condition**: Upward movement through cycle
**Typical Price Action**:
- Increasing upward momentum
- Higher highs and higher lows
- Bullish trend characteristics
**Trading Implication**: Hold long positions, avoid shorting

#### Zone 3: Top/Peak (150° - 210°)
**Phase Range**: 151° - 210°
**Market Condition**: Cycle top, potential reversal point
**Typical Price Action**:
- Upward momentum slowing
- Price reaching local highs
- Distribution patterns may form
**Trading Implication**: Primary selling zone, exit long positions, consider shorts

#### Zone 4: Falling Phase (210° - 330°)
**Phase Range**: 211° - 329°
**Market Condition**: Downward movement through cycle
**Typical Price Action**:
- Increasing downward momentum
- Lower highs and lower lows
- Bearish trend characteristics
**Trading Implication**: Hold short positions (if applicable), avoid buying, or wait for next cycle

### Phase Rate of Change

The speed at which phase changes provides additional insight:

**Fast Phase Movement:**
- Quick progression through degrees
- Indicates strong, clear cycle
- More reliable for timing
- Often correlates with good trending behavior within the cycle

**Slow Phase Movement:**
- Sluggish progression through degrees
- May indicate weak or unclear cycle
- Less reliable for precise timing
- Consider waiting for clearer conditions

**Stalled Phase:**
- Phase stuck at one value for multiple bars
- Cycle may be breaking down
- Market may be transitioning to trending mode
- Use with HT_TRENDMODE to confirm

### Critical Phase Angles

**Most Important Phases for Trading:**

- **0°/360°**: Absolute cycle bottom - strongest buy signal
- **45°**: Early uptrend confirmation - trend is establishing
- **90°**: Maximum upward momentum - halfway to top
- **135°**: Late uptrend warning - prepare for top
- **180°**: Absolute cycle top - strongest sell signal
- **225°**: Early downtrend confirmation - trend is establishing
- **270°**: Maximum downward momentum - halfway to bottom
- **315°**: Late downtrend warning - prepare for bottom

## Trading Signals

### Basic Phase Trading Strategy

**Entry Signals:**

```ruby
phase = SQA::TAI.ht_dcphase(prices)
current_phase = phase.last
current_price = prices.last

# Long entry near cycle bottom
if current_phase >= 345 || current_phase <= 15
  puts "STRONG BUY: Phase at cycle bottom (#{current_phase.round}°)"
  target_phase = 180
  puts "Expected profit zone: Phase 150-210° (cycle top)"

# Long entry confirmation in early uptrend
elsif current_phase >= 30 && current_phase <= 60
  puts "BUY: Early uptrend confirmed (#{current_phase.round}°)"
  puts "Catching momentum before mid-cycle"
end
```

**Exit Signals:**

```ruby
# Exit long near cycle top
if current_phase >= 165 && current_phase <= 195
  puts "SELL: Phase at cycle top (#{current_phase.round}°)"
  puts "Take profits before downward phase"

# Early exit warning
elsif current_phase >= 135 && current_phase <= 150
  puts "WARNING: Approaching cycle top (#{current_phase.round}°)"
  puts "Consider tightening stops or partial profit-taking"
end
```

### Combined Phase and Price Strategy

**Enhanced Signal Quality:**

```ruby
# Combine phase with price confirmation
phase = SQA::TAI.ht_dcphase(prices)
rsi = SQA::TAI.rsi(prices, period: 14)

current_phase = phase.last
current_rsi = rsi.last
current_price = prices.last

# Strong buy: Phase bottom + RSI oversold
if (current_phase >= 330 || current_phase <= 30) && current_rsi < 30
  puts "STRONG BUY SIGNAL"
  puts "Phase: #{current_phase.round}° (cycle bottom)"
  puts "RSI: #{current_rsi.round(1)} (oversold)"
  puts "Confluence of cycle and momentum - high probability setup"

# Strong sell: Phase top + RSI overbought
elsif (current_phase >= 150 && current_phase <= 210) && current_rsi > 70
  puts "STRONG SELL SIGNAL"
  puts "Phase: #{current_phase.round}° (cycle top)"
  puts "RSI: #{current_rsi.round(1)} (overbought)"
  puts "Confluence of cycle and momentum - high probability setup"
end
```

### Phase-Based Position Management

**Dynamic Stop Losses:**

```ruby
# Adjust stops based on cycle phase
phase = SQA::TAI.ht_dcphase(prices)
atr = SQA::TAI.atr(highs, lows, prices, period: 14)

current_phase = phase.last
current_atr = atr.last
entry_price = 100.0 # example

# In early phase (30-90°), use wider stops to allow development
if current_phase >= 30 && current_phase <= 90
  stop_distance = 2.5 * current_atr
  puts "Early phase - wider stop: #{stop_distance.round(2)} away"

# Approaching top (135-180°), tighten stops to protect profits
elsif current_phase >= 135 && current_phase <= 180
  stop_distance = 1.5 * current_atr
  puts "Late phase - tighter stop: #{stop_distance.round(2)} away"
end

stop_loss = entry_price - stop_distance
```

### Multi-Indicator Confirmation System

```ruby
# Complete trading system with phase as primary timer
require 'sqa/tai'

def analyze_trade_opportunity(prices, highs, lows)
  # Calculate indicators
  phase = SQA::TAI.ht_dcphase(prices)
  period = SQA::TAI.ht_dcperiod(prices)
  sine, lead_sine = SQA::TAI.ht_sine(prices)
  rsi = SQA::TAI.rsi(prices, period: 14)

  current_phase = phase.last
  current_period = period.last.round
  current_sine = sine.last
  current_lead = lead_sine.last
  current_rsi = rsi.last
  current_price = prices.last

  # Phase-based analysis
  at_bottom = current_phase >= 330 || current_phase <= 30
  at_top = current_phase >= 150 && current_phase <= 210

  # Buy conditions: Phase bottom + confirming indicators
  if at_bottom
    buy_score = 0
    buy_score += 1 if current_rsi < 40
    buy_score += 1 if current_sine < -0.5
    buy_score += 1 if current_lead > current_sine

    if buy_score >= 2
      puts "\n=== BUY OPPORTUNITY ==="
      puts "Phase: #{current_phase.round}° (BOTTOM)"
      puts "Cycle Period: #{current_period} bars"
      puts "RSI: #{current_rsi.round(1)}"
      puts "Confirmation Score: #{buy_score}/3"
      puts "Expected cycle duration: #{current_period} bars"
      puts "Target exit phase: ~180° (cycle top)"
      return :buy
    end
  end

  # Sell conditions: Phase top + confirming indicators
  if at_top
    sell_score = 0
    sell_score += 1 if current_rsi > 60
    sell_score += 1 if current_sine > 0.5
    sell_score += 1 if current_lead < current_sine

    if sell_score >= 2
      puts "\n=== SELL OPPORTUNITY ==="
      puts "Phase: #{current_phase.round}° (TOP)"
      puts "Cycle Period: #{current_period} bars"
      puts "RSI: #{current_rsi.round(1)}"
      puts "Confirmation Score: #{sell_score}/3"
      puts "Expected cycle duration: #{current_period} bars"
      puts "Target exit phase: ~360°/0° (cycle bottom)"
      return :sell
    end
  end

  # No clear signal
  puts "\nPhase: #{current_phase.round}° - No clear signal at this phase"
  return :hold
end

# Example usage
signal = analyze_trade_opportunity(prices, highs, lows)
```

## Best Practices

### Optimal Use Cases

**When HT_DCPHASE works best:**
- **Cyclical Markets**: Forex pairs, commodities, and markets with clear oscillating behavior
- **Range-Bound Conditions**: When prices are cycling between support and resistance
- **Mean-Reversion Strategies**: Buying bottoms and selling tops of cycles
- **Swing Trading**: Multi-day to multi-week timeframes
- **Confirmation Tool**: Adding timing precision to other trading strategies

**Less effective in:**
- Strong, sustained trends with no retracements (use HT_TRENDMODE to detect)
- Very short timeframes (< 5 minute charts) - too much noise
- Markets with irregular, erratic cycles
- Immediately after major news events that break cycle patterns

### Combining with Other Indicators

**With HT_DCPERIOD (Cycle Length):**
```ruby
phase = SQA::TAI.ht_dcphase(prices)
period = SQA::TAI.ht_dcperiod(prices)

current_phase = phase.last
current_period = period.last.round

# Know where you are AND how long until next turn
puts "Current phase: #{current_phase.round}°"
puts "Full cycle length: #{current_period} bars"

# Calculate approximate bars until phase 180° (top)
if current_phase < 180
  bars_to_top = ((180 - current_phase) / 360.0 * current_period).round
  puts "Approximately #{bars_to_top} bars until cycle top"
end
```

**With HT_SINE (Sine Wave Representation):**
```ruby
phase = SQA::TAI.ht_dcphase(prices)
sine, lead_sine = SQA::TAI.ht_sine(prices)

# Phase gives precise degree, sine gives normalized value
# Use both for confirmation
if phase.last <= 30 && sine.last < -0.5
  puts "Double confirmation: Phase at bottom AND sine wave negative"
  puts "High confidence buy signal"
end
```

**With Momentum Oscillators:**
```ruby
phase = SQA::TAI.ht_dcphase(prices)
rsi = SQA::TAI.rsi(prices, period: 14)
stoch_k, stoch_d = SQA::TAI.stoch(highs, lows, prices)

# Phase determines WHEN to look, oscillators confirm
current_phase = phase.last

if current_phase >= 330 || current_phase <= 30
  # At cycle bottom - check if oscillators agree
  if rsi.last < 30 && stoch_k.last < 20
    puts "CONFIRMED BUY: Phase at bottom + oversold oscillators"
  end

elsif current_phase >= 150 && current_phase <= 210
  # At cycle top - check if oscillators agree
  if rsi.last > 70 && stoch_k.last > 80
    puts "CONFIRMED SELL: Phase at top + overbought oscillators"
  end
end
```

**With Trend Indicators:**
```ruby
# Use phase for timing within trend direction
phase = SQA::TAI.ht_dcphase(prices)
trendmode = SQA::TAI.ht_trendmode(prices)
ema_fast = SQA::TAI.ema(prices, period: 12)
ema_slow = SQA::TAI.ema(prices, period: 26)

if trendmode.last == 1
  # In trend mode - use phase for entry timing only in trend direction
  if ema_fast.last > ema_slow.last && (phase.last >= 330 || phase.last <= 30)
    puts "BUY: Uptrend + cycle bottom phase - optimal entry"
  end
else
  # In cycle mode - use phase for both entries and exits
  puts "Cycle mode - trade both tops and bottoms"
end
```

### Common Pitfalls

1. **Insufficient Data**
   - Need minimum 32-63 bars for reliable phase calculation
   - Initial values will be unreliable
   - Always verify sufficient data history before trading

2. **Ignoring Trend Context**
   - Phase works best in cycling markets
   - In strong trends, phase may be less meaningful
   - Always check HT_TRENDMODE first
   - Don't fade strong trends based on phase alone

3. **Over-Trading Phase Zones**
   - Not every phase bottom/top is tradeable
   - Require confirmation from price action or other indicators
   - Quality over quantity - wait for best setups

4. **Misunderstanding Phase Wrapping**
   - Phase goes from 359° to 0° (wraps around)
   - Bottom zone spans 330-30° (crosses the wrap)
   - Use proper logic: `(phase >= 330 || phase <= 30)`

5. **Fixed Zone Boundaries**
   - Optimal buy/sell zones may vary by market
   - Test and adjust zones for your specific instrument
   - Consider market personality and volatility

6. **Ignoring Cycle Period Changes**
   - Phase meaning depends on cycle length
   - A short cycle rotates through phases faster
   - Combine with HT_DCPERIOD for complete picture

### Parameter Selection Guidelines

Since HT_DCPHASE has no adjustable parameters, focus on how to apply it:

**For Intraday Trading:**
- Use on 15-min to 1-hour charts
- Expect faster phase rotation (check every few bars)
- Tighter phase zones (±15° instead of ±30°)
- Combine with smaller ATR multiples for stops

**For Swing Trading:**
- Use on daily charts
- Standard phase zones work well (±30°)
- Check phase daily for position management
- Ideal for multi-day cycle timing

**For Position Trading:**
- Use on weekly charts
- Wider phase zones acceptable (±45°)
- Phase changes slowly - perfect for patience
- Combine with fundamental analysis

## Practical Example

Complete trading system using HT_DCPHASE as primary timer:

```ruby
require 'sqa/tai'

class CyclePhaseTrader
  # Phase zone definitions
  BOTTOM_ENTRY = -30..30
  TOP_EXIT = 150..210
  RISING_HOLD = 31..149
  FALLING_WAIT = 211..329
  APPROACHING_BOTTOM = 330..360

  def initialize(prices, highs, lows)
    @prices = prices
    @highs = highs
    @lows = lows

    # Ensure sufficient data
    raise "Need at least 63 bars" if prices.size < 63
  end

  def analyze
    # Calculate all indicators
    @phase = SQA::TAI.ht_dcphase(@prices)
    @period = SQA::TAI.ht_dcperiod(@prices)
    @trendmode = SQA::TAI.ht_trendmode(@prices)
    @sine, @lead_sine = SQA::TAI.ht_sine(@prices)
    @rsi = SQA::TAI.rsi(@prices, period: 14)
    @atr = SQA::TAI.atr(@highs, @lows, @prices, period: 14)

    current_phase = @phase.last
    current_period = @period.last.round
    current_trendmode = @trendmode.last
    current_price = @prices.last
    current_atr = @atr.last

    puts "\n" + "="*60
    puts "CYCLE PHASE ANALYSIS"
    puts "="*60
    puts "Current Price: #{current_price.round(2)}"
    puts "Cycle Phase: #{current_phase.round(1)}°"
    puts "Cycle Period: #{current_period} bars"
    puts "Market Mode: #{current_trendmode == 1 ? 'TREND' : 'CYCLE'}"
    puts "ATR: #{current_atr.round(2)}"
    puts "-"*60

    # Adjust phase for wrap-around (normalize to -180 to 180 for easier logic)
    normalized_phase = current_phase > 180 ? current_phase - 360 : current_phase

    # Check phase zone
    if BOTTOM_ENTRY.cover?(normalized_phase.abs) && normalized_phase.abs == normalized_phase.abs
      analyze_bottom_entry(current_price, current_phase, current_period, current_atr)
    elsif TOP_EXIT.cover?(current_phase)
      analyze_top_exit(current_price, current_phase, current_period, current_atr)
    elsif RISING_HOLD.cover?(current_phase)
      analyze_rising_phase(current_phase, current_period)
    elsif FALLING_WAIT.cover?(current_phase) || APPROACHING_BOTTOM.cover?(current_phase)
      analyze_falling_phase(current_phase, current_period)
    end

    puts "="*60
  end

  private

  def analyze_bottom_entry(price, phase, period, atr)
    puts "\nPHASE ZONE: CYCLE BOTTOM (0°)"
    puts "Status: PRIMARY BUY ZONE"
    puts ""

    # Check confirmation
    rsi_confirm = @rsi.last < 40
    sine_confirm = @sine.last < -0.3
    lead_confirm = @lead_sine.last > @sine.last

    confirmations = [rsi_confirm, sine_confirm, lead_confirm].count(true)

    puts "Confirmations:"
    puts "  RSI < 40: #{rsi_confirm ? '✓' : '✗'} (#{@rsi.last.round(1)})"
    puts "  Sine < -0.3: #{sine_confirm ? '✓' : '✗'} (#{@sine.last.round(3)})"
    puts "  Lead > Sine: #{lead_confirm ? '✓' : '✗'}"
    puts "  Total: #{confirmations}/3"
    puts ""

    if confirmations >= 2
      # Generate buy signal with full details
      entry = price
      stop_loss = entry - (2.0 * atr)
      target_1 = entry + (2.0 * atr)
      target_2 = entry + (3.0 * atr)
      risk_reward = ((target_1 - entry) / (entry - stop_loss)).round(2)

      puts "*** BUY SIGNAL GENERATED ***"
      puts ""
      puts "Entry: #{entry.round(2)}"
      puts "Stop Loss: #{stop_loss.round(2)} (-#{((entry - stop_loss) / entry * 100).round(2)}%)"
      puts "Target 1: #{target_1.round(2)} (+#{((target_1 - entry) / entry * 100).round(2)}%)"
      puts "Target 2: #{target_2.round(2)} (+#{((target_2 - entry) / entry * 100).round(2)}%)"
      puts "Risk:Reward: 1:#{risk_reward}"
      puts ""
      puts "Expected Duration: ~#{period} bars to reach cycle top"
      puts "Target Exit Phase: 150-210° (cycle top)"
      puts "Management: Move stop to breakeven at Target 1"
    else
      puts "Insufficient confirmations - wait for stronger signal"
    end
  end

  def analyze_top_exit(price, phase, period, atr)
    puts "\nPHASE ZONE: CYCLE TOP (180°)"
    puts "Status: PRIMARY SELL ZONE"
    puts ""

    # Check confirmation
    rsi_confirm = @rsi.last > 60
    sine_confirm = @sine.last > 0.3
    lead_confirm = @lead_sine.last < @sine.last

    confirmations = [rsi_confirm, sine_confirm, lead_confirm].count(true)

    puts "Confirmations:"
    puts "  RSI > 60: #{rsi_confirm ? '✓' : '✗'} (#{@rsi.last.round(1)})"
    puts "  Sine > 0.3: #{sine_confirm ? '✓' : '✗'} (#{@sine.last.round(3)})"
    puts "  Lead < Sine: #{lead_confirm ? '✓' : '✗'}"
    puts "  Total: #{confirmations}/3"
    puts ""

    if confirmations >= 2
      puts "*** SELL SIGNAL GENERATED ***"
      puts ""
      puts "Exit Price: #{price.round(2)}"
      puts "Rationale: Cycle top reached with confirmation"
      puts "Expected: Phase will decline toward 270° then 360°/0°"
      puts "Next Opportunity: Buy signal expected in ~#{(period / 2).round} bars"
    else
      puts "Insufficient confirmations - consider partial exit or tighten stops"
    end
  end

  def analyze_rising_phase(phase, period)
    puts "\nPHASE ZONE: RISING (30-150°)"
    puts "Status: HOLD LONG POSITIONS"
    puts ""
    puts "Current Phase: #{phase.round}°"

    # Estimate progress to top
    progress = ((phase - 30) / 120.0 * 100).round
    bars_to_top = ((180 - phase) / 180.0 * period / 2).round

    puts "Progress to Top: #{progress}%"
    puts "Estimated Bars to Top: ~#{bars_to_top}"
    puts ""

    if phase > 120
      puts "WARNING: Approaching cycle top soon"
      puts "Action: Consider tightening stops or partial profit-taking"
    else
      puts "Action: Hold positions, let profits run"
    end
  end

  def analyze_falling_phase(phase, period)
    if phase >= 330
      puts "\nPHASE ZONE: APPROACHING BOTTOM (330-360°)"
      puts "Status: PREPARE FOR BUY"
      puts ""

      bars_to_bottom = ((360 - phase) / 360.0 * period).round
      puts "Estimated Bars to Bottom: ~#{bars_to_bottom}"
      puts "Action: Watch for buy confirmations (RSI, Sine, price action)"
    else
      puts "\nPHASE ZONE: FALLING (210-330°)"
      puts "Status: WAIT / HOLD SHORT"
      puts ""

      progress = ((phase - 210) / 120.0 * 100).round
      puts "Progress to Bottom: #{progress}%"
      puts "Action: Stay out or hold short positions if applicable"
    end
  end
end

# Example usage with real data
prices = [
  # ... your actual price data (need 63+ bars)
]
highs = [...]
lows = [...]

trader = CyclePhaseTrader.new(prices, highs, lows)
trader.analyze
```

## Related Indicators

### Hilbert Transform Family

- **[HT_DCPERIOD](ht_dcperiod.md)**: Identifies the length of the dominant cycle - tells you HOW LONG the cycle is
- **[HT_SINE](ht_sine.md)**: Generates sine wave representation of cycle - normalized version of phase
- **[HT_PHASOR](ht_phasor.md)**: Provides in-phase and quadrature components for advanced analysis
- **[HT_TRENDMODE](ht_trendmode.md)**: Determines if market is in trend or cycle mode - crucial for knowing when to use phase
- **[HT_TRENDLINE](../volatility/ht_trendline.md)**: Provides instantaneous trendline based on Hilbert Transform

**Complete Cycle Analysis Workflow:**
1. Use **HT_TRENDMODE** to determine if market is cycling (required for phase to be meaningful)
2. Use **HT_DCPERIOD** to know the cycle length
3. Use **HT_DCPHASE** (this indicator) to know where you are in the cycle
4. Use **HT_SINE** for normalized cycle representation and crossover signals

### Complementary Indicators

- **[RSI](../momentum/rsi.md)**: Combine with phase for entry/exit confirmation
- **[Stochastic](../momentum/stoch.md)**: Additional momentum confirmation at phase extremes
- **[ATR](../volatility/atr.md)**: Size stops and targets based on volatility
- **[MAMA](../volatility/mama.md)**: Adaptive moving average that responds to cycle changes
- **[EMA](../overlap/ema.md)**: Use for trend context with phase timing

### Alternative Phase Indicators

While HT_DCPHASE is unique in its mathematical approach, similar concepts include:
- Traditional cycle counting (peak-to-peak, trough-to-trough)
- Detrended Price Oscillator (DPO) - shows position in cycle but less precise
- Ehlers Fisher Transform - different phase representation

## Advanced Topics

### Phase Velocity Analysis

Monitor how fast phase is changing to assess cycle quality:

```ruby
# Calculate phase velocity (degrees per bar)
phases = SQA::TAI.ht_dcphase(prices)

# Look at recent phase changes
recent_phases = phases.last(5)
phase_changes = recent_phases.each_cons(2).map { |a, b|
  change = b - a
  # Handle wrap-around
  change = change - 360 if change > 180
  change = change + 360 if change < -180
  change
}

avg_velocity = phase_changes.sum / phase_changes.size

puts "Average phase velocity: #{avg_velocity.round(1)}°/bar"

if avg_velocity.abs > 20
  puts "Fast phase movement - strong, clear cycle"
elsif avg_velocity.abs < 5
  puts "Slow phase movement - weak or unclear cycle"
end
```

### Phase Divergence Detection

Look for divergences between price and phase:

```ruby
# Compare price action with phase expectations
phases = SQA::TAI.ht_dcphase(prices)
current_phase = phases.last
current_price = prices.last
prev_price = prices[-10]

# At cycle top, price should be making highs
if current_phase >= 150 && current_phase <= 210
  if current_price < prev_price
    puts "BEARISH DIVERGENCE: Phase at top but price lower than before"
    puts "Strong sell signal - cycle top with price weakness"
  end
end

# At cycle bottom, price should be making lows
if current_phase >= 330 || current_phase <= 30
  if current_price > prev_price
    puts "BULLISH DIVERGENCE: Phase at bottom but price higher than before"
    puts "Strong buy signal - cycle bottom with price strength"
  end
end
```

### Multi-Timeframe Phase Analysis

Use phase across timeframes for nested cycle analysis:

```ruby
# Daily and hourly phase alignment
daily_phase = SQA::TAI.ht_dcphase(daily_prices).last
hourly_phase = SQA::TAI.ht_dcphase(hourly_prices).last

puts "Daily Phase: #{daily_phase.round}°"
puts "Hourly Phase: #{hourly_phase.round}°"

# Best trades: both timeframes aligned at bottoms
if (daily_phase >= 330 || daily_phase <= 30) &&
   (hourly_phase >= 330 || hourly_phase <= 30)
  puts "POWER SETUP: Both daily and hourly phases at bottom"
  puts "Highest probability long entry"
end

# Trade with higher timeframe, time with lower
if daily_phase >= 30 && daily_phase <= 150
  # Daily in rising phase (bullish)
  if hourly_phase >= 330 || hourly_phase <= 30
    puts "BUY: Daily rising phase + hourly phase at bottom"
    puts "Optimal timing for daily trend direction"
  end
end
```

### Phase-Based Position Sizing

Adjust position size based on phase confidence:

```ruby
def calculate_position_size(base_size, phase, confirmations)
  current_phase = phase.last

  # Maximum size at optimal phases with confirmations
  if (current_phase >= 330 || current_phase <= 30) && confirmations >= 2
    size_multiplier = 1.0 # Full size at bottom with confirmation
  elsif (current_phase >= 150 && current_phase <= 210) && confirmations >= 2
    size_multiplier = 0.0 # No new positions at top (exit zone)
  elsif current_phase > 30 && current_phase < 90
    size_multiplier = 0.75 # Reduced size in early uptrend
  elsif current_phase > 90 && current_phase < 150
    size_multiplier = 0.5 # Half size in late uptrend
  else
    size_multiplier = 0.0 # No positions in falling phase
  end

  position_size = base_size * size_multiplier

  puts "Phase: #{current_phase.round}°"
  puts "Size Multiplier: #{(size_multiplier * 100).round}%"
  puts "Position Size: #{position_size.round(2)}"

  position_size
end
```

### Cycle Phase Prediction

Estimate future phase values based on current period:

```ruby
def project_future_phase(prices, bars_ahead)
  phases = SQA::TAI.ht_dcphase(prices)
  periods = SQA::TAI.ht_dcperiod(prices)

  current_phase = phases.last
  current_period = periods.last

  # Degrees per bar (assuming constant cycle)
  degrees_per_bar = 360.0 / current_period

  # Project future phase
  future_phase = current_phase + (degrees_per_bar * bars_ahead)
  future_phase = future_phase % 360 # Wrap around

  puts "Current Phase: #{current_phase.round}°"
  puts "Current Period: #{current_period.round} bars"
  puts "Projected Phase in #{bars_ahead} bars: #{future_phase.round}°"

  # Identify next key phase
  if current_phase < 180 && future_phase < 180
    bars_to_top = ((180 - current_phase) / degrees_per_bar).round
    puts "Estimated bars to cycle top (180°): #{bars_to_top}"
  elsif current_phase > 180
    bars_to_bottom = ((360 - current_phase) / degrees_per_bar).round
    puts "Estimated bars to cycle bottom (360°/0°): #{bars_to_bottom}"
  end

  future_phase
end

# Example: Where will phase be in 10 bars?
project_future_phase(prices, 10)
```

## References

- **"Rocket Science for Traders"** by John F. Ehlers - Comprehensive treatment of Hilbert Transform and phase analysis
- **"Cybernetic Analysis for Stocks and Futures"** by John F. Ehlers - Advanced applications of cycle phase in trading
- **"Cycle Analytics for Traders"** by John F. Ehlers - Detailed cycle theory and practical applications
- **Original Research**: John F. Ehlers developed the application of Hilbert Transform to financial markets
- **Signal Processing**: Hilbert Transform is a standard tool in electrical engineering and signal processing
- **TA-Lib Documentation**: [HT_DCPHASE Function](https://ta-lib.org/function.html?name=HT_DCPHASE)

## See Also

- [Cycle Indicators Overview](../index.md)
- [Hilbert Transform Indicators Family](../index.md#cycle-indicators)
<!-- TODO: Create example file -->
- Phase-Based Trading Strategies Guide
- [API Reference](../../api-reference.md)
