# HT_DCPERIOD (Hilbert Transform - Dominant Cycle Period)

## Overview

The Hilbert Transform - Dominant Cycle Period (HT_DCPERIOD) is an advanced technical indicator that identifies the dominant market cycle period at any given time. Unlike fixed-period indicators, HT_DCPERIOD dynamically adapts to current market conditions by measuring the actual cycle length in the price data, allowing traders to optimize their analysis to match the market's natural rhythm.

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

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

# Calculate dominant cycle period
prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 45.61,
          46.50, 47.20, 46.80, 47.50, 48.10, 48.30,
          # ... more data points ...
         ]

cycle_period = SQA::TAI.ht_dcperiod(prices)

# The cycle period tells you the current market cycle length
current_period = cycle_period.last
puts "Current dominant cycle: #{current_period.round(1)} periods"
```

### Practical Application

```ruby
# Use the detected cycle period to optimize other indicators
cycle = SQA::TAI.ht_dcperiod(prices)
current_cycle = cycle.last.round

# Adapt your moving average to the current market cycle
adaptive_ma = SQA::TAI.sma(prices, period: current_cycle)

# Or use it to set RSI period dynamically
adaptive_rsi = SQA::TAI.rsi(prices, period: current_cycle)

puts "Market is cycling every #{current_cycle} periods"
puts "Using #{current_cycle}-period indicators for current conditions"
```

## Understanding the Indicator

### What It Measures

HT_DCPERIOD measures **the length of the dominant price cycle** currently present in the market. Markets naturally move in cycles - periods of expansion followed by contraction, uptrends followed by downtrends. These cycles can vary in length depending on market conditions, volatility, and timeframe.

The indicator answers the question: "What is the natural rhythm of this market right now?"

### Why It's Important

Traditional indicators use fixed periods (like 14 for RSI or 20 for moving averages). However, market cycles change over time:
- During high volatility: cycles may shorten to 8-12 periods
- During low volatility: cycles may extend to 30-40 periods
- Different markets have different natural cycles

By identifying the actual cycle length, you can:
- Optimize other indicator periods to match current conditions
- Avoid false signals from mis-tuned indicators
- Better time entries and exits to cycle phases

### Calculation Method

The Hilbert Transform is a mathematical technique that decomposes a price series into its amplitude and phase components:

1. **Apply Hilbert Transform** to the price data to extract phase information
2. **Compute instantaneous period** from the phase rate of change
3. **Smooth the result** to provide a stable cycle period measurement
4. **Output the dominant cycle length** in number of bars/periods

The algorithm automatically adapts to the changing frequency of price oscillations, effectively "listening" to the market's current tempo.

**Key Concept:**
Think of it like musical tempo detection - the indicator identifies how many bars it takes for the market to complete one full cycle (peak to peak or trough to trough).

### Indicator Characteristics

- **Range**: Typically 10 to 50 periods, but can vary
- **Type**: Cycle analysis, adaptive indicator
- **Lag**: Moderate - requires some data history to identify cycles accurately
- **Best Used**: All market conditions, especially useful for adapting other indicators

## Interpretation

### Value Ranges

The HT_DCPERIOD output represents the number of periods (bars) in the current dominant cycle:

- **Short Cycles (8-15 periods)**
  - Market is in high-frequency oscillation mode
  - Often seen during high volatility
  - Price reversals happen quickly
  - Use shorter-period indicators

- **Medium Cycles (16-25 periods)**
  - Normal market conditions
  - Standard indicator periods work well
  - Most common range
  - Balanced between responsiveness and smoothness

- **Long Cycles (26-40+ periods)**
  - Market is in strong trend or low volatility
  - Price changes are gradual
  - Use longer-period indicators to avoid whipsaws
  - Fewer but more reliable signals

### Cycle Changes

**Shortening Cycles:**
When the period value decreases over time, it indicates:
- Increasing market volatility
- Transitions into ranging/choppy conditions
- Need to increase indicator sensitivity
- More frequent trading opportunities (but also more noise)

**Lengthening Cycles:**
When the period value increases over time, it indicates:
- Decreasing volatility or strengthening trend
- Market entering sustained directional move
- Need to decrease indicator sensitivity
- Fewer but higher-quality signals

### Stability Analysis

- **Stable cycle period** (changes slowly): Market in consistent regime
- **Rapidly changing period**: Market in transition or unstable
- **Erratic jumps**: Low signal quality, market may be too noisy

## Trading Signals

### Adaptive Indicator Optimization

**Primary Use Case:** Dynamic parameter adjustment

```ruby
# Calculate current cycle
cycle = SQA::TAI.ht_dcperiod(prices)
optimal_period = cycle.last.round.clamp(10, 30) # Limit to reasonable range

# Apply to multiple indicators
rsi = SQA::TAI.rsi(prices, period: optimal_period)
stoch_k, stoch_d = SQA::TAI.stoch(
  highs, lows, closes,
  fastk_period: optimal_period,
  slowk_period: 3,
  slowd_period: 3
)

# Now your indicators are tuned to current market conditions
```

### Cycle Phase Trading

**Entry Signals:**

1. **Cycle Bottom Entry**
   - Identify cycle length
   - Use oscillators (RSI, Stochastic) with matching period
   - Enter when oscillator shows oversold during cycle trough
   - Exit after approximately 50% of cycle period

2. **Cycle Top Exit**
   - Monitor overbought on cycle-tuned oscillators
   - Exit long positions at approximately 50% through cycle
   - Consider short entries (if appropriate for your strategy)

**Example Strategy:**
```ruby
cycle_length = SQA::TAI.ht_dcperiod(prices).last.round
half_cycle = (cycle_length / 2.0).round

# Use cycle-tuned RSI
adaptive_rsi = SQA::TAI.rsi(prices, period: cycle_length)
current_rsi = adaptive_rsi.last

# Track position age
bars_in_position = 20 # example

if current_rsi < 30
  puts "POTENTIAL BUY: RSI oversold, cycle may be at trough"
  puts "Expected cycle duration: #{cycle_length} bars"
elsif bars_in_position >= half_cycle && current_rsi > 70
  puts "POTENTIAL SELL: RSI overbought, half-cycle reached"
end
```

### Regime Detection

**Trend vs Range Detection:**

```ruby
# Track cycle period changes
cycles = SQA::TAI.ht_dcperiod(prices)
current_cycle = cycles.last
avg_cycle = cycles.last(10).sum / 10.0

if current_cycle > avg_cycle * 1.3
  puts "TRENDING REGIME: Cycles lengthening - use trend-following strategies"
elsif current_cycle < avg_cycle * 0.7
  puts "RANGING REGIME: Cycles shortening - use mean-reversion strategies"
else
  puts "NORMAL REGIME: Standard strategies applicable"
end
```

## Best Practices

### Optimal Use Cases

**When HT_DCPERIOD works best:**
- **Markets with clear cyclical behavior**: Forex pairs, commodities
- **Medium to long-term analysis**: Daily to weekly charts
- **Adaptive strategy systems**: Systems that optimize parameters automatically
- **Multi-timeframe analysis**: Comparing cycle lengths across timeframes

**Less effective in:**
- Very short timeframes (< 5 minute charts) - too much noise
- Strongly trending markets with no cyclical component
- Low-liquidity markets with erratic price movements

### Combining with Other Indicators

**With Oscillators:**
```ruby
cycle = SQA::TAI.ht_dcperiod(prices).last.round
rsi = SQA::TAI.rsi(prices, period: cycle)
stoch_k, stoch_d = SQA::TAI.stoch(highs, lows, closes, fastk_period: cycle)

# Both oscillators now tuned to current market cycle
# Signals are synchronized with market rhythm
```

**With Trend Indicators:**
```ruby
cycle = SQA::TAI.ht_dcperiod(prices).last.round
# Use half-cycle for fast MA, full cycle for slow MA
fast_ma = SQA::TAI.ema(prices, period: (cycle / 2).round)
slow_ma = SQA::TAI.ema(prices, period: cycle)

# MA crossovers are now cycle-adaptive
```

**With Other Hilbert Transform Indicators:**
- **[HT_TRENDMODE](ht_trendmode.md)**: Determine if market is trending or cycling
- **[HT_DCPHASE](ht_dcphase.md)**: Identify where you are in the current cycle
- **[HT_PHASOR](ht_phasor.md)**: Get leading/lagging components
- **[HT_SINE](ht_sine.md)**: Generate cycle-based trading signals

### Common Pitfalls

1. **Insufficient Data**
   - Need minimum 32-63 bars for reliable results
   - Initial values will be unstable
   - Always check for sufficient history

2. **Over-Optimization**
   - Don't change strategy parameters on every cycle tick
   - Use smoothed/averaged cycle values for parameter selection
   - Avoid excessive trading from parameter changes

3. **Ignoring Market Context**
   - Cycle detection works poorly in strong, sustained trends with no retracements
   - Combine with trend indicators (like HT_TRENDMODE)
   - Be aware when cycle analysis isn't appropriate

4. **Period Constraints**
   - Very short detected cycles (< 10) may be noise
   - Very long cycles (> 50) may indicate trend, not cycle
   - Clamp to reasonable ranges: `cycle.clamp(10, 40)`

### Parameter Selection Guidelines

Since HT_DCPERIOD has no adjustable parameters, focus on how to use its output:

**For Intraday Trading:**
- Use detected cycle on 15-min to 1-hour charts
- Expect shorter cycles (10-20 periods)
- Update indicator periods every few hours

**For Swing Trading:**
- Use detected cycle on daily charts
- Expect medium cycles (15-30 periods)
- Update indicator periods daily or weekly

**For Position Trading:**
- Use detected cycle on weekly charts
- Expect longer cycles (20-40 periods)
- Update indicator periods monthly

## Practical Example

Complete trading system example:

```ruby
require 'sqa/tai'

# Historical price data (need at least 63 bars)
prices = [
  # ... your price data ...
]
highs = [...]
lows = [...]

# Detect current market cycle
cycle_periods = SQA::TAI.ht_dcperiod(prices)
current_cycle = cycle_periods.last.round.clamp(10, 30)

# Smooth cycle to avoid excessive changes
recent_cycles = cycle_periods.last(5)
smoothed_cycle = (recent_cycles.sum / recent_cycles.size).round

puts "Current cycle: #{current_cycle} periods"
puts "Smoothed cycle: #{smoothed_cycle} periods"

# Apply cycle-adaptive indicators
rsi = SQA::TAI.rsi(prices, period: smoothed_cycle)
atr = SQA::TAI.atr(highs, lows, prices, period: smoothed_cycle)
ema_fast = SQA::TAI.ema(prices, period: (smoothed_cycle / 2).round)
ema_slow = SQA::TAI.ema(prices, period: smoothed_cycle)

# Trading logic
current_price = prices.last
current_rsi = rsi.last
current_atr = atr.last
fast_ma = ema_fast.last
slow_ma = ema_slow.last

# Generate signals based on cycle-tuned indicators
if fast_ma > slow_ma && current_rsi < 40
  stop_loss = current_price - (2 * current_atr)
  take_profit = current_price + (3 * current_atr)

  puts "BUY SIGNAL"
  puts "Entry: #{current_price.round(2)}"
  puts "Stop Loss: #{stop_loss.round(2)}"
  puts "Take Profit: #{take_profit.round(2)}"
  puts "Expected cycle duration: #{smoothed_cycle} bars"

elsif fast_ma < slow_ma && current_rsi > 60
  stop_loss = current_price + (2 * current_atr)
  take_profit = current_price - (3 * current_atr)

  puts "SELL SIGNAL"
  puts "Entry: #{current_price.round(2)}"
  puts "Stop Loss: #{stop_loss.round(2)}"
  puts "Take Profit: #{take_profit.round(2)}"
  puts "Expected cycle duration: #{smoothed_cycle} bars"
else
  puts "NO SIGNAL - Waiting for cycle-tuned confirmation"
end

# Track cycle regime changes
if cycle_periods.size >= 20
  avg_cycle_20 = cycle_periods.last(20).sum / 20.0
  if current_cycle > avg_cycle_20 * 1.2
    puts "WARNING: Cycles lengthening - market may be trending"
  elsif current_cycle < avg_cycle_20 * 0.8
    puts "WARNING: Cycles shortening - market may be ranging"
  end
end
```

## Related Indicators

### Hilbert Transform Family

- **[HT_DCPHASE](ht_dcphase.md)**: Identifies the current phase within the dominant cycle (where you are in the cycle)
- **[HT_PHASOR](ht_phasor.md)**: Provides in-phase and quadrature components for advanced cycle analysis
- **[HT_SINE](ht_sine.md)**: Generates sine wave representation of the cycle for timing entries/exits
- **[HT_TRENDMODE](ht_trendmode.md)**: Determines if market is in trend or cycle mode
- **[HT_TRENDLINE](../volatility/ht_trendline.md)**: Provides instantaneous trendline based on Hilbert Transform

### Complementary Indicators

- **[MAMA](../volatility/mama.md)**: MESA Adaptive Moving Average - uses similar adaptive concepts
- **[KAMA](../overlap/kama.md)**: Kaufman Adaptive Moving Average - another adaptive approach
- **[ATR](../volatility/atr.md)**: Use with detected cycle for adaptive stop losses

### Alternative Cycle Indicators

While HT_DCPERIOD is unique in TA-Lib, other cycle analysis approaches include:
- Fourier analysis (not in TA-Lib)
- Maximum Entropy Spectral Analysis (MESA) - related to Hilbert Transform
- Simple cycle counting methods

## Advanced Topics

### Multi-Timeframe Cycle Analysis

```ruby
# Compare cycles across timeframes
daily_prices = [...] # daily data
hourly_prices = [...] # hourly data

daily_cycle = SQA::TAI.ht_dcperiod(daily_prices).last
hourly_cycle = SQA::TAI.ht_dcperiod(hourly_prices).last

puts "Daily cycle: #{daily_cycle.round} days"
puts "Hourly cycle: #{hourly_cycle.round} hours"

# Nested cycles concept:
# - Trade daily cycle direction
# - Time entries using hourly cycle
```

### Market Regime Adaptation

```ruby
# Detect regime transitions
cycles = SQA::TAI.ht_dcperiod(prices)

# Calculate cycle trend
cycle_sma = SQA::TAI.sma(cycles, period: 10)
cycle_trend = cycles.last > cycle_sma.last ? "lengthening" : "shortening"

if cycle_trend == "lengthening"
  puts "Shift to trend-following strategies"
  # Increase position size for trends, reduce mean-reversion trades
else
  puts "Shift to mean-reversion strategies"
  # Increase mean-reversion trades, reduce trend-following
end
```

### Statistical Validation

**Reliability Considerations:**
- More reliable with 100+ bars of history
- Accuracy decreases in purely random price movements
- Works best when true cyclical components exist
- Combine with other indicators for validation

**Testing Cycle Stability:**
```ruby
# Check if cycle is stable enough to use
recent_cycles = cycle_periods.last(10)
cycle_stddev = Math.sqrt(recent_cycles.map { |c| (c - recent_cycles.sum/10.0)**2 }.sum / 10.0)
cycle_cv = cycle_stddev / (recent_cycles.sum / 10.0) # Coefficient of variation

if cycle_cv < 0.15
  puts "Stable cycle - safe to use for parameter optimization"
else
  puts "Unstable cycle - use with caution or default parameters"
end
```

## References

- **"Rocket Science for Traders"** by John F. Ehlers - Comprehensive coverage of Hilbert Transform and cycle analysis
- **"Cybernetic Analysis for Stocks and Futures"** by John F. Ehlers - Advanced adaptive indicators
- **Original Research**: John F. Ehlers pioneered the application of Hilbert Transform to trading
- **TA-Lib Documentation**: [HT_DCPERIOD Function](https://ta-lib.org/function.html?name=HT_DCPERIOD)

## See Also

- [Cycle Indicators Overview](../index.md)
- [Hilbert Transform Indicators Family](../index.md#cycle-indicators)
<!-- TODO: Create example file -->
- Adaptive Indicators Guide
- [API Reference](../../api-reference.md)
