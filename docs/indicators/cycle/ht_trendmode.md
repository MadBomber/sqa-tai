# HT_TRENDMODE (Hilbert Transform - Trend vs Cycle Mode)

## Overview

The Hilbert Transform - Trend vs Cycle Mode (HT_TRENDMODE) is a critical market regime detection indicator that determines whether the market is currently in a trending state or a cycling (oscillating) state. This binary indicator returns a value of 1 for trend mode and 0 for cycle mode, providing traders with essential information for strategy selection. By identifying the market's current regime, traders can avoid using oscillators during trending markets and trend-following strategies during ranging markets, significantly improving trading performance.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `prices` | Array<Float> | Required | Array of price values (typically close prices) |

### Parameter Details

**prices**
- Input data should be an array of closing prices
- Minimum 32 data points required for reliable results (due to Hilbert Transform calculation requirements)
- More data provides better accuracy in regime identification
- Works best with at least 63+ data points for stable output
- The indicator analyzes the frequency content of price movements to determine regime

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

# Calculate trend vs cycle mode
prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 45.61,
          46.50, 47.20, 46.80, 47.50, 48.10, 48.30,
          # ... more data points ...
         ]

mode = SQA::TAI.ht_trendmode(prices)

# Check current market regime
current_mode = mode.last
if current_mode == 1
  puts "Market is in TREND MODE - use trend-following strategies"
else
  puts "Market is in CYCLE MODE - use mean-reversion strategies"
end
```

### Practical Application

```ruby
# Adapt your strategy based on market mode
mode = SQA::TAI.ht_trendmode(prices)
current_mode = mode.last

if current_mode == 1
  # TREND MODE: Use trend-following indicators
  puts "Using trend-following approach"

  # Use moving average crossovers
  fast_ma = SQA::TAI.ema(prices, period: 12)
  slow_ma = SQA::TAI.ema(prices, period: 26)

  # Use ADX for trend strength
  adx = SQA::TAI.adx(highs, lows, prices, period: 14)

  # Ignore oscillator signals
  puts "Ignoring RSI/Stochastic oscillations"

else
  # CYCLE MODE: Use mean-reversion indicators
  puts "Using mean-reversion approach"

  # Use oscillators for entry/exit
  rsi = SQA::TAI.rsi(prices, period: 14)
  stoch_k, stoch_d = SQA::TAI.stoch(highs, lows, prices)

  # Trade range boundaries
  bb_upper, bb_middle, bb_lower = SQA::TAI.bbands(prices, period: 20)

  puts "Trading oversold/overbought conditions"
end
```

## Understanding the Indicator

### What It Measures

HT_TRENDMODE measures **the market regime** - specifically whether price action exhibits trending characteristics or cyclical (oscillating) characteristics. The indicator uses Hilbert Transform mathematics to analyze the dominant frequency components in price movements:

- **Trend Mode (1)**: Price movements are dominated by directional momentum with minimal cyclical oscillation
- **Cycle Mode (0)**: Price movements are dominated by oscillations around a mean with no sustained direction

The indicator answers the fundamental question: "Should I be trend-following or mean-reverting right now?"

### Why It's Important

Using the wrong strategy for the current market regime is a primary cause of trading losses:

**In Trending Markets:**
- Oscillators generate false signals (constantly showing "overbought" or "oversold")
- Mean-reversion strategies result in catching falling knives or fighting trends
- The market can remain "overbought" or "oversold" for extended periods
- Trend-following strategies perform best

**In Cycling Markets:**
- Trend-following strategies generate whipsaws and false breakouts
- Moving average crossovers produce excessive and unprofitable signals
- Range-bound behavior creates ideal conditions for mean-reversion
- Oscillators provide reliable entry and exit signals

HT_TRENDMODE helps you **automatically select the appropriate strategy** for current conditions, eliminating the guesswork and emotional decision-making that leads to poor strategy selection.

### Calculation Method

The Hilbert Transform uses sophisticated digital signal processing to decompose price data:

1. **Apply Hilbert Transform** to create a complex analytical signal from the price series
2. **Analyze the instantaneous frequency** of the dominant price cycle
3. **Evaluate cycle consistency** - how regular and persistent the cycles are
4. **Generate binary classification**:
   - If price shows sustained directional movement with weak cycles → Mode = 1 (Trend)
   - If price shows strong, regular oscillations without sustained direction → Mode = 0 (Cycle)
5. **Apply smoothing logic** to prevent excessive mode switching

**Key Concept:**
Think of it like audio signal analysis - the indicator distinguishes between a sustained note (trend) and rapid oscillations (cycle). Just as music has both sustained tones and quick vibrations, markets alternate between trending and cycling regimes.

### Indicator Characteristics

- **Range**: Binary output (0 or 1 only)
- **Type**: Market regime detection, classification indicator
- **Lag**: Moderate - requires some confirmation before switching modes
- **Best Used**: As a filter for strategy selection across all timeframes
- **Updates**: Mode can change as market conditions evolve

## Interpretation

### Value Meanings

**Mode = 1 (Trend Mode)**

Market characteristics:
- Sustained directional price movement
- Weak or irregular cyclical components
- Price can move far from mean without reverting
- High probability of trend continuation
- Momentum and directional indicators work well
- Oscillators give false signals

**What to do:**
- Use trend-following strategies
- Employ moving averages, MACD, ADX
- Trade breakouts and momentum
- Avoid counter-trend trades
- Ignore "overbought" or "oversold" oscillator readings
- Let profits run, use trailing stops

**Mode = 0 (Cycle Mode)**

Market characteristics:
- Price oscillates around a central value
- Regular, repeating cycle patterns
- Price tends to revert to mean
- Breakouts often fail
- Range-bound behavior dominates
- Oscillators accurately identify turning points

**What to do:**
- Use mean-reversion strategies
- Employ RSI, Stochastic, Bollinger Bands
- Trade range boundaries
- Take profits at resistance, buy at support
- Avoid trend-following indicators
- Use tighter profit targets, faster exits

### Mode Transitions

**Transition from Cycle (0) to Trend (1):**
- Market is breaking out of range
- Initiate or add to trend-following positions
- Close mean-reversion positions
- Expect sustained directional move
- Raise stop losses to protect capital

**Transition from Trend (1) to Cycle (0):**
- Trend is exhausting, range forming
- Take profits on trend-following positions
- Prepare for mean-reversion opportunities
- Expect price to oscillate in range
- Tighten stops, reduce position sizes

### Mode Persistence

**Stable Mode (few changes):**
- Market in consistent regime
- Strategy selection reliable
- Can commit to single approach

**Frequent Mode Changes:**
- Market in transition or low signal quality
- Use caution with any strategy
- Reduce position sizes
- Wait for mode stability before aggressive trading

## Trading Signals

### Strategy Selection System

**Primary Use Case:** Automatic strategy switching

```ruby
# Get current market mode
mode = SQA::TAI.ht_trendmode(prices)
current_mode = mode.last

# Initialize strategy variables
strategy = nil
indicators_to_use = []

if current_mode == 1
  # TREND MODE STRATEGY
  strategy = :trend_following

  # Calculate trend indicators
  ema_fast = SQA::TAI.ema(prices, period: 12)
  ema_slow = SQA::TAI.ema(prices, period: 26)
  adx = SQA::TAI.adx(highs, lows, prices, period: 14)

  # Entry signal: MA crossover + strong ADX
  if ema_fast.last > ema_slow.last && adx.last > 25
    if ema_fast[-2] <= ema_slow[-2]  # Crossover just occurred
      puts "TREND MODE - BUY SIGNAL (Bullish Crossover)"
      puts "ADX: #{adx.last.round(2)} (Strong trend)"
    end
  elsif ema_fast.last < ema_slow.last && adx.last > 25
    if ema_fast[-2] >= ema_slow[-2]  # Crossover just occurred
      puts "TREND MODE - SELL SIGNAL (Bearish Crossover)"
      puts "ADX: #{adx.last.round(2)} (Strong trend)"
    end
  end

else
  # CYCLE MODE STRATEGY
  strategy = :mean_reversion

  # Calculate oscillator indicators
  rsi = SQA::TAI.rsi(prices, period: 14)
  bb_upper, bb_middle, bb_lower = SQA::TAI.bbands(prices, period: 20, nbdevup: 2, nbdevdn: 2)
  current_price = prices.last

  # Entry signal: RSI extremes + Bollinger Band touch
  if rsi.last < 30 && current_price < bb_lower.last
    puts "CYCLE MODE - BUY SIGNAL (Oversold + Lower BB)"
    puts "RSI: #{rsi.last.round(2)} (Oversold)"
    puts "Target: #{bb_middle.last.round(2)} (Middle BB)"

  elsif rsi.last > 70 && current_price > bb_upper.last
    puts "CYCLE MODE - SELL SIGNAL (Overbought + Upper BB)"
    puts "RSI: #{rsi.last.round(2)} (Overbought)"
    puts "Target: #{bb_middle.last.round(2)} (Middle BB)"
  end
end

puts "Current Strategy: #{strategy}"
```

### Filtering False Signals

**Use Case:** Prevent oscillator whipsaws during trends

```ruby
mode = SQA::TAI.ht_trendmode(prices)
rsi = SQA::TAI.rsi(prices, period: 14)

current_mode = mode.last
current_rsi = rsi.last

# Only act on RSI signals during cycle mode
if current_rsi < 30
  if current_mode == 0
    puts "VALID BUY: RSI oversold in CYCLE MODE"
  else
    puts "IGNORED: RSI oversold but market in TREND MODE"
    puts "Price may continue lower despite oversold reading"
  end

elsif current_rsi > 70
  if current_mode == 0
    puts "VALID SELL: RSI overbought in CYCLE MODE"
  else
    puts "IGNORED: RSI overbought but market in TREND MODE"
    puts "Price may continue higher despite overbought reading"
  end
end
```

### Regime-Based Position Sizing

**Use Case:** Adjust risk based on market mode

```ruby
mode = SQA::TAI.ht_trendmode(prices)
current_mode = mode.last

# Base position size
base_position = 100  # shares/contracts

# Mode-based position sizing
if current_mode == 1
  # TREND MODE: Larger positions, wider stops
  position_size = base_position * 1.5
  stop_multiplier = 2.5
  profit_target_multiplier = 4.0

  puts "Trend Mode Position Sizing:"
  puts "Position: #{position_size} units (150% of base)"
  puts "Stop: #{stop_multiplier}x ATR"
  puts "Target: #{profit_target_multiplier}x ATR (let winners run)"

else
  # CYCLE MODE: Smaller positions, tighter stops
  position_size = base_position
  stop_multiplier = 1.5
  profit_target_multiplier = 2.0

  puts "Cycle Mode Position Sizing:"
  puts "Position: #{position_size} units (100% of base)"
  puts "Stop: #{stop_multiplier}x ATR"
  puts "Target: #{profit_target_multiplier}x ATR (take profits faster)"
end

# Calculate actual levels
atr = SQA::TAI.atr(highs, lows, prices, period: 14)
current_atr = atr.last
current_price = prices.last

stop_distance = current_atr * stop_multiplier
target_distance = current_atr * profit_target_multiplier

puts "Stop Loss: #{(current_price - stop_distance).round(2)}"
puts "Take Profit: #{(current_price + target_distance).round(2)}"
```

## Best Practices

### Optimal Use Cases

**When HT_TRENDMODE works best:**
- **Strategy filtering**: Primary use - deciding which indicators to trust
- **Automated trading systems**: Programmatic strategy switching
- **Multi-strategy portfolios**: Allocate capital between trend/cycle strategies
- **All market types**: Works across stocks, forex, commodities, crypto
- **All timeframes**: Effective from daily to intraday charts (with sufficient data)

**Less effective in:**
- Very short timeframes (< 15 minute charts) - too much noise
- Low-liquidity markets - erratic price action confuses regime detection
- During major news events - sudden volatility can cause temporary misclassification
- Markets in transition - mode may be unstable between regimes

### Combining with Other Indicators

**With HT_DCPERIOD:**
```ruby
# Use both indicators for comprehensive cycle analysis
mode = SQA::TAI.ht_trendmode(prices)
cycle = SQA::TAI.ht_dcperiod(prices)

current_mode = mode.last
current_cycle = cycle.last.round

if current_mode == 0
  # In cycle mode, use the detected cycle period
  puts "CYCLE MODE: Optimizing for #{current_cycle}-period cycle"
  rsi = SQA::TAI.rsi(prices, period: current_cycle)

  # Trade the cycle
  puts "Buy at cycle troughs, sell at cycle peaks"
  puts "Expected cycle duration: #{current_cycle} bars"

else
  # In trend mode, cycle period indicates trend strength
  if current_cycle > 30
    puts "TREND MODE: Long cycle (#{current_cycle}) = Strong trend"
  else
    puts "TREND MODE: Short cycle (#{current_cycle}) = Weak trend or emerging"
  end
end
```

**With Trend Strength Indicators:**
```ruby
mode = SQA::TAI.ht_trendmode(prices)
adx = SQA::TAI.adx(highs, lows, prices, period: 14)

current_mode = mode.last
current_adx = adx.last

# Confirm trend mode with ADX
if current_mode == 1 && current_adx > 25
  puts "CONFIRMED STRONG TREND"
  puts "High confidence in trend-following strategies"

elsif current_mode == 1 && current_adx < 20
  puts "WARNING: Trend mode but weak ADX"
  puts "Possible transition period - use caution"

elsif current_mode == 0 && current_adx < 20
  puts "CONFIRMED RANGING MARKET"
  puts "High confidence in mean-reversion strategies"

else  # Mode = 0 but ADX > 25
  puts "CONFLICT: Cycle mode but high ADX"
  puts "Market may be transitioning - wait for clarity"
end
```

**With Volatility Indicators:**
```ruby
mode = SQA::TAI.ht_trendmode(prices)
bb_upper, bb_middle, bb_lower = SQA::TAI.bbands(prices, period: 20)
bb_width = bb_upper.last - bb_lower.last

current_mode = mode.last

if current_mode == 1
  # Trend mode: Use BB for trend confirmation and entries on pullbacks
  if prices.last > bb_upper.last
    puts "Strong uptrend - price above upper BB"
  end
  puts "Wait for pullbacks to middle BB for entries"

else
  # Cycle mode: Use BB for range boundaries
  puts "Trade BB extremes:"
  puts "Buy near: #{bb_lower.last.round(2)}"
  puts "Sell near: #{bb_upper.last.round(2)}"
  puts "Target: #{bb_middle.last.round(2)}"
end
```

**With Other Hilbert Transform Indicators:**
- **[HT_DCPERIOD](ht_dcperiod.md)**: Use cycle period only when mode = 0 (cycle mode)
- **[HT_DCPHASE](ht_dcphase.md)**: Phase is most useful in cycle mode (0)
- **[HT_SINE](ht_sine.md)**: Sine/LeadSine signals work best in cycle mode
- **[HT_PHASOR](ht_phasor.md)**: In-phase and quadrature components for advanced analysis

### Common Pitfalls

1. **Ignoring Mode Changes**
   - Don't continue trend-following when mode switches to 0
   - Don't continue mean-reversion when mode switches to 1
   - Always check current mode before taking signals
   - Exit positions that conflict with current mode

2. **Over-Trading Mode Transitions**
   - Mode changes can produce brief whipsaws
   - Wait for mode stability (same value for 2-3 bars)
   - Don't reverse entire portfolio on single mode change
   - Use mode as filter, not sole trigger

3. **Insufficient Data**
   - Need minimum 32-63 bars for reliable mode detection
   - Initial values will be unstable or incorrect
   - Don't trade based on mode with insufficient history
   - Verify data quality and quantity

4. **Conflicting Signals**
   - Mode may say "trend" while visual inspection shows range
   - Use additional confirmation indicators (ADX, volatility)
   - Trust the mode more with longer data history
   - Be cautious during mode disagreements

5. **Wrong Timeframe**
   - Mode on 5-minute chart may differ from daily chart
   - Use appropriate timeframe for your trading style
   - Consider multi-timeframe analysis
   - Higher timeframe mode generally more reliable

### Strategy Selection Guidelines

**For Day Trading:**
- Use HT_TRENDMODE on 15-minute to 1-hour charts
- Mode changes more frequently - confirm with volume
- Quick strategy switches may be necessary
- Keep tight stops regardless of mode

**For Swing Trading:**
- Use HT_TRENDMODE on daily charts
- Mode typically more stable
- Ideal for switching between trend and range strategies
- Adjust position holding time based on mode

**For Position Trading:**
- Use HT_TRENDMODE on weekly charts
- Mode changes are rare but significant
- Major implications for portfolio allocation
- Long-term trend mode = growth stocks, cycle mode = value stocks

## Practical Example

Complete adaptive trading system:

```ruby
require 'sqa/tai'

# Historical price data (need at least 63 bars)
prices = [
  # ... your price data ...
]
highs = [...]
lows = [...]

# Detect current market regime
mode = SQA::TAI.ht_trendmode(prices)
current_mode = mode.last

# Check mode stability (has it been consistent?)
recent_modes = mode.last(5)
mode_changes = recent_modes.each_cons(2).count { |a, b| a != b }
mode_stable = mode_changes <= 1

unless mode_stable
  puts "WARNING: Market regime is unstable (#{mode_changes} changes in 5 bars)"
  puts "Reducing position sizes and waiting for clarity"
end

puts "=" * 50
puts "MARKET REGIME ANALYSIS"
puts "=" * 50
puts "Current Mode: #{current_mode == 1 ? 'TREND' : 'CYCLE'}"
puts "Mode Stability: #{mode_stable ? 'STABLE' : 'UNSTABLE'}"
puts

# TREND MODE STRATEGY
if current_mode == 1
  puts "TREND MODE ACTIVE - Trend-Following Strategy"
  puts "-" * 50

  # Calculate trend indicators
  ema_12 = SQA::TAI.ema(prices, period: 12)
  ema_26 = SQA::TAI.ema(prices, period: 26)
  adx = SQA::TAI.adx(highs, lows, prices, period: 14)
  plus_di = SQA::TAI.plus_di(highs, lows, prices, period: 14)
  minus_di = SQA::TAI.minus_di(highs, lows, prices, period: 14)
  atr = SQA::TAI.atr(highs, lows, prices, period: 14)

  current_price = prices.last
  current_adx = adx.last
  current_atr = atr.last

  # Determine trend direction and strength
  bullish_trend = ema_12.last > ema_26.last && plus_di.last > minus_di.last
  bearish_trend = ema_12.last < ema_26.last && minus_di.last > plus_di.last
  strong_trend = current_adx > 25

  puts "EMA(12): #{ema_12.last.round(2)}"
  puts "EMA(26): #{ema_26.last.round(2)}"
  puts "ADX: #{current_adx.round(2)} #{strong_trend ? '(STRONG)' : '(WEAK)'}"
  puts "ATR: #{current_atr.round(2)}"
  puts

  # Generate trend-following signals
  if bullish_trend && strong_trend
    entry_price = current_price
    stop_loss = current_price - (2.5 * current_atr)
    take_profit = current_price + (4.0 * current_atr)

    puts "STRONG BULLISH TREND DETECTED"
    puts "=" * 50
    puts "ENTRY: BUY at #{entry_price.round(2)}"
    puts "STOP LOSS: #{stop_loss.round(2)} (2.5x ATR)"
    puts "TAKE PROFIT: #{take_profit.round(2)} (4.0x ATR)"
    puts "POSITION SIZE: 150% of base (trend mode)"
    puts
    puts "Strategy: Ride the trend with wide stop"
    puts "Management: Use trailing stop, let profits run"

  elsif bearish_trend && strong_trend
    entry_price = current_price
    stop_loss = current_price + (2.5 * current_atr)
    take_profit = current_price - (4.0 * current_atr)

    puts "STRONG BEARISH TREND DETECTED"
    puts "=" * 50
    puts "ENTRY: SELL at #{entry_price.round(2)}"
    puts "STOP LOSS: #{stop_loss.round(2)} (2.5x ATR)"
    puts "TAKE PROFIT: #{take_profit.round(2)} (4.0x ATR)"
    puts "POSITION SIZE: 150% of base (trend mode)"
    puts
    puts "Strategy: Ride the trend with wide stop"
    puts "Management: Use trailing stop, let profits run"

  else
    puts "NO CLEAR TREND SIGNAL"
    puts "Waiting for strong directional move and ADX > 25"
  end

  puts
  puts "IGNORED INDICATORS IN TREND MODE:"
  puts "- RSI (will show false overbought/oversold)"
  puts "- Stochastic (will generate whipsaw signals)"
  puts "- Bollinger Band extremes (price can stay outside bands)"

# CYCLE MODE STRATEGY
else
  puts "CYCLE MODE ACTIVE - Mean-Reversion Strategy"
  puts "-" * 50

  # Calculate mean-reversion indicators
  rsi = SQA::TAI.rsi(prices, period: 14)
  stoch_k, stoch_d = SQA::TAI.stoch(highs, lows, prices,
                                     fastk_period: 14,
                                     slowk_period: 3,
                                     slowd_period: 3)
  bb_upper, bb_middle, bb_lower = SQA::TAI.bbands(prices,
                                                   period: 20,
                                                   nbdevup: 2,
                                                   nbdevdn: 2)
  atr = SQA::TAI.atr(highs, lows, prices, period: 14)

  current_price = prices.last
  current_rsi = rsi.last
  current_stoch_k = stoch_k.last
  current_atr = atr.last

  puts "Current Price: #{current_price.round(2)}"
  puts "RSI: #{current_rsi.round(2)}"
  puts "Stochastic K: #{current_stoch_k.round(2)}"
  puts "BB Upper: #{bb_upper.last.round(2)}"
  puts "BB Middle: #{bb_middle.last.round(2)}"
  puts "BB Lower: #{bb_lower.last.round(2)}"
  puts "ATR: #{current_atr.round(2)}"
  puts

  # Generate mean-reversion signals
  oversold = current_rsi < 30 && current_stoch_k < 20
  overbought = current_rsi > 70 && current_stoch_k > 80
  near_lower_bb = current_price < bb_lower.last
  near_upper_bb = current_price > bb_upper.last

  if oversold && near_lower_bb
    entry_price = current_price
    stop_loss = current_price - (1.5 * current_atr)
    take_profit = bb_middle.last

    puts "OVERSOLD CONDITION DETECTED"
    puts "=" * 50
    puts "ENTRY: BUY at #{entry_price.round(2)}"
    puts "STOP LOSS: #{stop_loss.round(2)} (1.5x ATR)"
    puts "TAKE PROFIT: #{take_profit.round(2)} (Middle BB)"
    puts "POSITION SIZE: 100% of base (cycle mode)"
    puts
    puts "Strategy: Buy at lower extreme, target mean"
    puts "Management: Take profits at resistance/middle BB"

  elsif overbought && near_upper_bb
    entry_price = current_price
    stop_loss = current_price + (1.5 * current_atr)
    take_profit = bb_middle.last

    puts "OVERBOUGHT CONDITION DETECTED"
    puts "=" * 50
    puts "ENTRY: SELL at #{entry_price.round(2)}"
    puts "STOP LOSS: #{stop_loss.round(2)} (1.5x ATR)"
    puts "TAKE PROFIT: #{take_profit.round(2)} (Middle BB)"
    puts "POSITION SIZE: 100% of base (cycle mode)"
    puts
    puts "Strategy: Sell at upper extreme, target mean"
    puts "Management: Take profits at support/middle BB"

  else
    puts "NO EXTREME CONDITION"
    puts "Waiting for oversold (RSI<30, Stoch<20) at lower BB"
    puts "      or overbought (RSI>70, Stoch>80) at upper BB"
  end

  puts
  puts "IGNORED INDICATORS IN CYCLE MODE:"
  puts "- Moving average crossovers (will whipsaw)"
  puts "- Trend lines (will generate false breakouts)"
  puts "- ADX (not relevant in ranging market)"
end

# Monitor for mode changes
puts
puts "=" * 50
puts "REGIME MONITORING"
puts "=" * 50

if mode.size >= 10
  recent_10_modes = mode.last(10)
  trend_mode_pct = (recent_10_modes.count(1) / 10.0) * 100

  puts "Last 10 bars: #{trend_mode_pct.round}% trend mode, #{(100-trend_mode_pct).round}% cycle mode"

  if trend_mode_pct > 70
    puts "Market predominantly trending - bias toward trend-following"
  elsif trend_mode_pct < 30
    puts "Market predominantly cycling - bias toward mean-reversion"
  else
    puts "Market transitioning between regimes - use caution"
  end
end
```

## Related Indicators

### Hilbert Transform Family

- **[HT_DCPERIOD](ht_dcperiod.md)**: Identifies the dominant cycle period - use with HT_TRENDMODE to optimize indicator periods in cycle mode
- **[HT_DCPHASE](ht_dcphase.md)**: Shows current phase within the cycle - most useful when HT_TRENDMODE = 0
- **[HT_SINE](ht_sine.md)**: Generates sine wave signals for timing - works best when HT_TRENDMODE = 0
- **[HT_PHASOR](ht_phasor.md)**: Provides in-phase and quadrature components for advanced cycle analysis
- **[HT_TRENDLINE](../volatility/ht_trendline.md)**: Instantaneous trendline - works with HT_TRENDMODE for comprehensive analysis

### Complementary Indicators

**For Trend Mode (when HT_TRENDMODE = 1):**
- **[ADX](../momentum/adx.md)**: Confirm trend strength
- **[MACD](../momentum/macd.md)**: Trend direction and momentum
- **[EMA](../overlap/ema.md)**: Moving average crossovers and trends
- **[PLUS_DI/MINUS_DI](../momentum/plus_di.md)**: Directional movement

**For Cycle Mode (when HT_TRENDMODE = 0):**
- **[RSI](../momentum/rsi.md)**: Overbought/oversold in ranges
- **[STOCH](../momentum/stoch.md)**: Oscillator for cycle extremes
- **[BBANDS](../overlap/bbands.md)**: Range boundaries and mean
- **[CCI](../momentum/cci.md)**: Commodity Channel Index for ranges

**For Mode Confirmation:**
- **[ATR](../volatility/atr.md)**: Volatility context for both modes
- **[STDDEV](../statistical/stddev.md)**: Statistical volatility measurement

## Advanced Topics

### Multi-Timeframe Regime Analysis

```ruby
# Analyze regime across multiple timeframes
daily_prices = [...]   # Daily data
hourly_prices = [...]  # Hourly data

daily_mode = SQA::TAI.ht_trendmode(daily_prices).last
hourly_mode = SQA::TAI.ht_trendmode(hourly_prices).last

puts "Daily Mode: #{daily_mode == 1 ? 'TREND' : 'CYCLE'}"
puts "Hourly Mode: #{hourly_mode == 1 ? 'TREND' : 'CYCLE'}"

# Trading rules based on timeframe alignment
if daily_mode == 1 && hourly_mode == 1
  puts "ALIGNED TREND - Strongest trend-following setup"
  puts "High confidence long-term trend trades"

elsif daily_mode == 0 && hourly_mode == 0
  puts "ALIGNED CYCLE - Strongest mean-reversion setup"
  puts "High confidence range-trading opportunities"

elsif daily_mode == 1 && hourly_mode == 0
  puts "MIXED REGIME - Daily trend, hourly cycles"
  puts "Trade pullbacks within daily trend using hourly oscillators"

else  # daily_mode == 0 && hourly_mode == 1
  puts "MIXED REGIME - Daily range, hourly trend"
  puts "Trade intraday trends but respect daily range boundaries"
end
```

### Portfolio Allocation by Regime

```ruby
# Allocate capital based on market regime
mode = SQA::TAI.ht_trendmode(prices)
current_mode = mode.last

total_capital = 100_000  # Example portfolio size

if current_mode == 1
  # TREND MODE: Allocate to trend-following strategies
  trend_following_allocation = total_capital * 0.70
  mean_reversion_allocation = total_capital * 0.20
  cash_reserve = total_capital * 0.10

  puts "TREND MODE ALLOCATION:"
  puts "Trend Following: $#{trend_following_allocation.round(2)} (70%)"
  puts "Mean Reversion: $#{mean_reversion_allocation.round(2)} (20%)"
  puts "Cash: $#{cash_reserve.round(2)} (10%)"

else
  # CYCLE MODE: Allocate to mean-reversion strategies
  trend_following_allocation = total_capital * 0.20
  mean_reversion_allocation = total_capital * 0.70
  cash_reserve = total_capital * 0.10

  puts "CYCLE MODE ALLOCATION:"
  puts "Trend Following: $#{trend_following_allocation.round(2)} (20%)"
  puts "Mean Reversion: $#{mean_reversion_allocation.round(2)} (70%)"
  puts "Cash: $#{cash_reserve.round(2)} (10%)"
end
```

### Mode Transition Detection

```ruby
# Detect and act on mode changes
mode = SQA::TAI.ht_trendmode(prices)

if mode.size >= 2
  current_mode = mode.last
  previous_mode = mode[-2]

  if current_mode != previous_mode
    # Mode just changed
    if current_mode == 1
      puts "MODE CHANGE ALERT: CYCLE → TREND"
      puts "Actions:"
      puts "1. Close mean-reversion positions"
      puts "2. Exit range-trading strategies"
      puts "3. Prepare for breakout opportunities"
      puts "4. Widen stop losses"
      puts "5. Increase position holding time"

    else
      puts "MODE CHANGE ALERT: TREND → CYCLE"
      puts "Actions:"
      puts "1. Take profits on trend-following positions"
      puts "2. Exit momentum trades"
      puts "3. Prepare for range-bound trading"
      puts "4. Tighten stop losses"
      puts "5. Decrease position holding time"
    end
  end
end
```

### Statistical Analysis of Modes

```ruby
# Analyze mode history for regime characteristics
mode = SQA::TAI.ht_trendmode(prices)

if mode.size >= 50
  # Calculate mode statistics
  total_bars = mode.size
  trend_bars = mode.count(1)
  cycle_bars = mode.count(0)

  trend_percentage = (trend_bars.to_f / total_bars * 100).round(2)
  cycle_percentage = (cycle_bars.to_f / total_bars * 100).round(2)

  puts "REGIME STATISTICS (#{total_bars} bars)"
  puts "Trend Mode: #{trend_percentage}% of time"
  puts "Cycle Mode: #{cycle_percentage}% of time"

  # Find average regime duration
  regime_durations = []
  current_duration = 1

  mode.each_cons(2) do |prev, curr|
    if prev == curr
      current_duration += 1
    else
      regime_durations << current_duration
      current_duration = 1
    end
  end

  avg_duration = regime_durations.sum.to_f / regime_durations.size
  puts "Average Regime Duration: #{avg_duration.round(1)} bars"
  puts "Regime Changes: #{regime_durations.size} times"

  # Characterize market
  if trend_percentage > 60
    puts "Market Character: TRENDING (favors trend-following)"
  elsif cycle_percentage > 60
    puts "Market Character: RANGING (favors mean-reversion)"
  else
    puts "Market Character: BALANCED (mixed strategies needed)"
  end
end
```

## References

- **"Rocket Science for Traders"** by John F. Ehlers - Comprehensive coverage of Hilbert Transform and market regime detection
- **"Cybernetic Analysis for Stocks and Futures"** by John F. Ehlers - Advanced applications of Hilbert Transform indicators
- **"Cycle Analytics for Traders"** by John F. Ehlers - Detailed explanation of cycle vs trend identification
- **Original Research**: John F. Ehlers pioneered the application of digital signal processing to financial markets
- **TA-Lib Documentation**: [HT_TRENDMODE Function](https://ta-lib.org/function.html?name=HT_TRENDMODE)

## See Also

- [Cycle Indicators Overview](../index.md)
- [Hilbert Transform Indicators Family](../index.md#cycle-indicators)
<!-- TODO: Create example file -->
- Strategy Selection Guide
<!-- TODO: Create example file -->
- Adaptive Trading Systems
- [API Reference](../../api-reference.md)
