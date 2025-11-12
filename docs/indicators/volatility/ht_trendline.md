# HT_TRENDLINE (Hilbert Transform - Instantaneous Trendline)

## Overview

The Hilbert Transform - Instantaneous Trendline (HT_TRENDLINE) is an adaptive trendline indicator that automatically adjusts to the current market cycle. Unlike traditional moving averages with fixed periods, HT_TRENDLINE dynamically adapts to the dominant market cycle length, providing a trendline that responds appropriately to current market conditions. This results in less lag during trends and better responsiveness during cycle changes, making it superior to fixed-period moving averages for trend identification and following.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `prices` | Array<Float> | Required | Array of price values (typically close prices) |

### Parameter Details


**Note**: Array elements should be ordered from oldest to newest (chronological order)

**prices**
- Input data should be an array of closing prices
- Minimum 32 data points required for reliable results (due to Hilbert Transform calculation requirements)
- More data provides better accuracy and stability
- Works best with at least 63+ data points for stable adaptive trendline
- The indicator automatically detects the current market cycle and adapts the trendline smoothing accordingly

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

# Calculate adaptive trendline
prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 45.61,
          46.50, 47.20, 46.80, 47.50, 48.10, 48.30,
          # ... more data points ...
         ]

trendline = SQA::TAI.ht_trendline(prices)

# Compare current price to adaptive trendline
current_price = prices.last
current_trendline = trendline.last

if current_price > current_trendline
  puts "Price above trendline: UPTREND"
  puts "Price: #{current_price.round(2)}"
  puts "Trendline: #{current_trendline.round(2)}"
else
  puts "Price below trendline: DOWNTREND"
  puts "Price: #{current_price.round(2)}"
  puts "Trendline: #{current_trendline.round(2)}"
end
```

### Practical Application

```ruby
# Use trendline for trend following and crossover signals
trendline = SQA::TAI.ht_trendline(prices)

# Detect crossovers
if prices.size >= 2 && trendline.size >= 2
  prev_price = prices[-2]
  prev_trendline = trendline[-2]

  current_price = prices.last
  current_trendline = trendline.last

  # Bullish crossover: price crosses above trendline
  if prev_price <= prev_trendline && current_price > current_trendline
    puts "BULLISH CROSSOVER: Buy signal"
    puts "Price crossed above adaptive trendline"

  # Bearish crossover: price crosses below trendline
  elsif prev_price >= prev_trendline && current_price < current_trendline
    puts "BEARISH CROSSOVER: Sell signal"
    puts "Price crossed below adaptive trendline"
  end
end
```

## Understanding the Indicator

### What It Measures

HT_TRENDLINE calculates an **adaptive trendline** that automatically adjusts its smoothing based on the current dominant market cycle. The trendline acts as a dynamic support/resistance level and trend direction indicator that:

- Follows trends with minimal lag
- Adapts to changing market cycle lengths
- Provides smoother trendline during longer cycles
- Becomes more responsive during shorter cycles
- Eliminates the need to manually adjust moving average periods

The indicator answers the question: "Where is the current trend center based on the market's natural rhythm?"

### Why It's Important

Traditional moving averages have a fundamental limitation: their fixed period may not match current market conditions:

**Problems with Fixed-Period MAs:**
- 20-period MA too slow during fast cycles (creates excessive lag)
- 20-period MA too fast during slow cycles (generates false signals)
- Constant parameter optimization required as market conditions change
- Same period doesn't work well across different market regimes

**HT_TRENDLINE Solutions:**
- Automatically adapts to current cycle length (no optimization needed)
- Reduces lag compared to traditional MAs of similar smoothness
- Maintains effectiveness as market conditions change
- Single indicator works across different market regimes
- More reliable support/resistance levels

By adapting to the market's natural cycle, HT_TRENDLINE provides a trendline that "fits" current conditions without manual adjustment.

### Calculation Method

The Hilbert Transform uses digital signal processing to create an adaptive trendline:

1. **Detect Dominant Cycle**: Apply Hilbert Transform to identify the current market cycle period
2. **Calculate Phase**: Determine the instantaneous phase of the price cycle
3. **Adaptive Smoothing**: Apply smoothing that adapts to the detected cycle length
4. **Generate Trendline**: Produce an instantaneous trendline value that adjusts to cycle changes
5. **Output**: Return adaptive trendline values that minimize lag while maintaining smoothness

**Key Concept:**
Think of it like a ship's autopilot that constantly adjusts to changing sea conditions. When waves (cycles) are short and choppy, it responds quickly. When waves are long and rolling, it makes smoother adjustments. The trendline automatically "knows" what kind of market cycle it's in and adjusts accordingly.

### Indicator Characteristics

- **Range**: Follows price, no fixed range
- **Type**: Adaptive trend-following indicator, dynamic support/resistance
- **Lag**: Lower lag than fixed-period MAs of comparable smoothness
- **Best Used**: Trend identification, crossover signals, support/resistance
- **Adaptation**: Automatically adjusts to market cycle changes

## Interpretation

### Price Position Relative to Trendline

**Price Above Trendline (Bullish)**

Market characteristics:
- Current uptrend in effect
- Trendline acts as dynamic support
- Buyers in control
- Higher probability of continued upward movement
- Pullbacks to trendline often provide buying opportunities

**What to do:**
- Look for long opportunities
- Use trendline as support level for stop placement
- Buy pullbacks to trendline
- Hold long positions while price remains above trendline
- Avoid short positions

**Price Below Trendline (Bearish)**

Market characteristics:
- Current downtrend in effect
- Trendline acts as dynamic resistance
- Sellers in control
- Higher probability of continued downward movement
- Rallies to trendline often provide selling opportunities

**What to do:**
- Look for short opportunities
- Use trendline as resistance level for stop placement
- Sell rallies to trendline
- Hold short positions while price remains below trendline
- Avoid long positions

### Crossover Signals

**Bullish Crossover (Price crosses above trendline)**

- Potential trend change from down to up
- Buy signal
- Entry point for long positions
- Place stop loss below recent swing low
- Trendline becomes support going forward

**Bearish Crossover (Price crosses below trendline)**

- Potential trend change from up to down
- Sell signal
- Exit point for long positions or short entry
- Place stop loss above recent swing high
- Trendline becomes resistance going forward

### Trendline Slope and Distance

**Steep Slope:**
- Strong trend
- Rapid price movement
- Higher volatility
- Larger profit potential but also higher risk

**Gentle Slope:**
- Moderate trend
- Steady price movement
- Lower volatility
- More sustainable trend

**Price Far from Trendline:**
- Overextended move
- Potential for pullback to trendline
- Profit-taking opportunity if already in position
- Wait for better entry if considering new position

**Price Near Trendline:**
- Healthy trend with normal pullback
- Good entry opportunity in direction of trend
- Trendline testing support/resistance

## Trading Signals

### Crossover Trading Strategy

**Primary Use Case:** Trend change and continuation signals

```ruby
# Calculate adaptive trendline
trendline = SQA::TAI.ht_trendline(prices)

# Track current and previous positions
current_price = prices.last
prev_price = prices[-2]
current_trendline = trendline.last
prev_trendline = trendline[-2]

# Calculate ATR for stops and targets
atr = SQA::TAI.atr(highs, lows, prices, period: 14)
current_atr = atr.last

# Detect crossovers
bullish_cross = prev_price <= prev_trendline && current_price > current_trendline
bearish_cross = prev_price >= prev_trendline && current_price < current_trendline

if bullish_cross
  entry = current_price
  stop = entry - (2.0 * current_atr)
  target = entry + (3.0 * current_atr)

  puts "BULLISH CROSSOVER SIGNAL"
  puts "Entry: BUY at #{entry.round(2)}"
  puts "Stop Loss: #{stop.round(2)} (below trendline)"
  puts "Take Profit: #{target.round(2)} (3:1 R/R)"
  puts "Trendline: #{current_trendline.round(2)} (now support)"

elsif bearish_cross
  entry = current_price
  stop = entry + (2.0 * current_atr)
  target = entry - (3.0 * current_atr)

  puts "BEARISH CROSSOVER SIGNAL"
  puts "Entry: SELL at #{entry.round(2)}"
  puts "Stop Loss: #{stop.round(2)} (above trendline)"
  puts "Take Profit: #{target.round(2)} (3:1 R/R)"
  puts "Trendline: #{current_trendline.round(2)} (now resistance)"
end
```

### Trend Following with Pullbacks

**Use Case:** Enter on pullbacks to trendline in established trend

```ruby
trendline = SQA::TAI.ht_trendline(prices)
atr = SQA::TAI.atr(highs, lows, prices, period: 14)

current_price = prices.last
current_trendline = trendline.last
current_atr = atr.last
low_price = lows.last
high_price = highs.last

# Define pullback as price touching or approaching trendline
pullback_threshold = current_atr * 0.5

# UPTREND: Buy pullbacks to trendline
if current_price > current_trendline
  distance_to_trendline = low_price - current_trendline

  if distance_to_trendline.abs <= pullback_threshold
    puts "UPTREND PULLBACK BUY OPPORTUNITY"
    puts "Price testing trendline support at #{current_trendline.round(2)}"
    puts "Current price: #{current_price.round(2)}"
    puts "Buy near: #{current_trendline.round(2)}"
    puts "Stop: #{(current_trendline - current_atr).round(2)}"
    puts "Target: #{(current_price + 3 * current_atr).round(2)}"
  end

# DOWNTREND: Sell rallies to trendline
elsif current_price < current_trendline
  distance_to_trendline = high_price - current_trendline

  if distance_to_trendline.abs <= pullback_threshold
    puts "DOWNTREND RALLY SELL OPPORTUNITY"
    puts "Price testing trendline resistance at #{current_trendline.round(2)}"
    puts "Current price: #{current_price.round(2)}"
    puts "Sell near: #{current_trendline.round(2)}"
    puts "Stop: #{(current_trendline + current_atr).round(2)}"
    puts "Target: #{(current_price - 3 * current_atr).round(2)}"
  end
end
```

### Dynamic Stop Loss Management

**Use Case:** Trail stops using adaptive trendline

```ruby
# Position management example
trendline = SQA::TAI.ht_trendline(prices)
atr = SQA::TAI.atr(highs, lows, prices, period: 14)

current_price = prices.last
current_trendline = trendline.last
current_atr = atr.last

# Assume we have a long position
entry_price = 45.50  # example entry
position_type = :long

if position_type == :long
  # Trail stop below trendline
  trailing_stop = current_trendline - (1.0 * current_atr)

  puts "LONG POSITION MANAGEMENT"
  puts "Entry: #{entry_price}"
  puts "Current Price: #{current_price.round(2)}"
  puts "Trendline: #{current_trendline.round(2)}"
  puts "Trailing Stop: #{trailing_stop.round(2)}"
  puts "P/L: #{((current_price - entry_price) / entry_price * 100).round(2)}%"

  if current_price < trailing_stop
    puts "STOP HIT - Exit long position"
    puts "Price broke below trendline support"
  elsif current_price < current_trendline
    puts "WARNING - Price below trendline (potential trend change)"
  else
    puts "HOLD - Price above trendline, trend intact"
  end

else  # short position
  # Trail stop above trendline
  trailing_stop = current_trendline + (1.0 * current_atr)

  puts "SHORT POSITION MANAGEMENT"
  puts "Entry: #{entry_price}"
  puts "Current Price: #{current_price.round(2)}"
  puts "Trendline: #{current_trendline.round(2)}"
  puts "Trailing Stop: #{trailing_stop.round(2)}"
  puts "P/L: #{((entry_price - current_price) / entry_price * 100).round(2)}%"

  if current_price > trailing_stop
    puts "STOP HIT - Exit short position"
    puts "Price broke above trendline resistance"
  elsif current_price > current_trendline
    puts "WARNING - Price above trendline (potential trend change)"
  else
    puts "HOLD - Price below trendline, downtrend intact"
  end
end
```

## Best Practices

### Optimal Use Cases

**When HT_TRENDLINE works best:**
- **Trend following**: Primary use - identifying and following trends
- **Trending markets**: More effective when clear trends exist
- **Medium to long-term trading**: Daily to weekly charts
- **Dynamic support/resistance**: Adaptive levels that adjust to market conditions
- **All asset classes**: Stocks, forex, commodities, crypto
- **Crossover systems**: Less whipsaw than fixed-period MA crossovers

**Less effective in:**
- Strongly ranging/sideways markets (use HT_TRENDMODE to detect)
- Very short timeframes (< 15 minute charts) - too much noise
- Low-liquidity markets with erratic price movements
- During major news events with sudden volatility spikes

### Combining with Other Indicators

**With HT_TRENDMODE:**
```ruby
# Use HT_TRENDMODE to filter when to use trendline
mode = SQA::TAI.ht_trendmode(prices)
trendline = SQA::TAI.ht_trendline(prices)

current_mode = mode.last
current_price = prices.last
current_trendline = trendline.last

if current_mode == 1
  # TREND MODE: Trust trendline signals
  puts "Market in TREND MODE - HT_TRENDLINE reliable"

  if current_price > current_trendline
    puts "Uptrend confirmed - follow long signals"
  else
    puts "Downtrend confirmed - follow short signals"
  end

else
  # CYCLE MODE: Trendline less reliable, use oscillators instead
  puts "Market in CYCLE MODE - HT_TRENDLINE may whipsaw"
  puts "Consider using oscillators (RSI, Stochastic) for mean-reversion instead"
end
```

**With HT_DCPERIOD:**
```ruby
# Compare adaptive trendline to cycle-optimized moving average
trendline = SQA::TAI.ht_trendline(prices)
cycle = SQA::TAI.ht_dcperiod(prices)

current_cycle = cycle.last.round
current_trendline = trendline.last

# Create moving average based on detected cycle
cycle_ma = SQA::TAI.sma(prices, period: current_cycle)
current_cycle_ma = cycle_ma.last

puts "Adaptive Trendline: #{current_trendline.round(2)}"
puts "#{current_cycle}-period SMA: #{current_cycle_ma.round(2)}"
puts "Difference: #{(current_trendline - current_cycle_ma).round(2)}"

# Both should be similar, confirming cycle-adaptive behavior
```

**With Traditional Moving Averages:**
```ruby
# Compare adaptive trendline to fixed-period MAs
trendline = SQA::TAI.ht_trendline(prices)
sma_20 = SQA::TAI.sma(prices, period: 20)
ema_20 = SQA::TAI.ema(prices, period: 20)

current_price = prices.last
current_trendline = trendline.last
current_sma = sma_20.last
current_ema = ema_20.last

puts "Current Price: #{current_price.round(2)}"
puts "HT Trendline: #{current_trendline.round(2)} (adaptive)"
puts "SMA(20): #{current_sma.round(2)} (fixed)"
puts "EMA(20): #{current_ema.round(2)} (fixed)"
puts

# Adaptive trendline often shows less lag
puts "Trendline lag: #{(current_price - current_trendline).round(2)}"
puts "SMA lag: #{(current_price - current_sma).round(2)}"
puts "EMA lag: #{(current_price - current_ema).round(2)}"
```

**With Volatility Indicators:**
```ruby
# Use ATR for stop placement relative to trendline
trendline = SQA::TAI.ht_trendline(prices)
atr = SQA::TAI.atr(highs, lows, prices, period: 14)
bb_upper, bb_middle, bb_lower = SQA::TAI.bbands(prices, period: 20)

current_price = prices.last
current_trendline = trendline.last
current_atr = atr.last

# Trendline with volatility-adjusted stops
if current_price > current_trendline
  stop_loss = current_trendline - (1.5 * current_atr)
  puts "UPTREND: Trendline at #{current_trendline.round(2)}"
  puts "Stop Loss: #{stop_loss.round(2)} (trendline - 1.5*ATR)"

  # Check if price overextended using Bollinger Bands
  if current_price > bb_upper.last
    puts "WARNING: Price above upper BB - overextended"
    puts "Consider waiting for pullback to trendline"
  end
end
```

**With Oscillators:**
```ruby
# Use oscillators to time entries on pullbacks to trendline
trendline = SQA::TAI.ht_trendline(prices)
rsi = SQA::TAI.rsi(prices, period: 14)

current_price = prices.last
current_trendline = trendline.last
current_rsi = rsi.last

# UPTREND: Look for oversold RSI near trendline support
if current_price > current_trendline
  distance_pct = ((current_price - current_trendline) / current_price * 100).abs

  if distance_pct < 2 && current_rsi < 40
    puts "STRONG BUY SETUP"
    puts "Uptrend + Pullback to trendline + Oversold RSI"
    puts "Price near trendline: #{current_trendline.round(2)}"
    puts "RSI: #{current_rsi.round(2)}"
  end

# DOWNTREND: Look for overbought RSI near trendline resistance
elsif current_price < current_trendline
  distance_pct = ((current_trendline - current_price) / current_price * 100).abs

  if distance_pct < 2 && current_rsi > 60
    puts "STRONG SELL SETUP"
    puts "Downtrend + Rally to trendline + Overbought RSI"
    puts "Price near trendline: #{current_trendline.round(2)}"
    puts "RSI: #{current_rsi.round(2)}"
  end
end
```

### Common Pitfalls

1. **Insufficient Data**
   - Need minimum 32-63 bars for reliable trendline
   - Initial values will be unstable or incorrect
   - Always verify sufficient price history
   - Don't trade based on trendline with insufficient data

2. **Using in Ranging Markets**
   - Adaptive trendline still generates whipsaws in tight ranges
   - Check HT_TRENDMODE first (mode = 0 indicates ranging)
   - In cycle mode, switch to oscillators instead
   - Not all markets are suitable for trend-following

3. **Ignoring Volatility**
   - Trendline crossovers alone are insufficient
   - Always use ATR or volatility measure for stops
   - Wide stops in high volatility, tighter in low volatility
   - Distance from trendline should be volatility-adjusted

4. **Overtrading Crossovers**
   - Not every crossover is a high-quality signal
   - Require confirmation (volume, momentum, pattern)
   - Avoid trading against higher timeframe trend
   - Wait for clear separation after crossover

5. **Fixed Stop Distance**
   - Don't use fixed-point stops with adaptive trendline
   - Stops should adapt to current volatility (ATR-based)
   - Trail stops using trendline position
   - Adjust stop distance based on market conditions

### Strategy Guidelines

**For Day Trading:**
- Use HT_TRENDLINE on 15-minute to 1-hour charts
- Trendline adapts to intraday cycles
- Quick crossover signals for scalping and day trades
- Combine with volume for confirmation
- Use tight ATR-based stops

**For Swing Trading:**
- Use HT_TRENDLINE on daily charts (most effective)
- Ideal timeframe for adaptive trendline
- Hold positions while price remains on correct side
- Trail stops below/above trendline
- Multi-day to multi-week holding periods

**For Position Trading:**
- Use HT_TRENDLINE on weekly charts
- Long-term trend identification
- Major trend changes signaled by crossovers
- Wide stops to avoid premature exits
- Hold through normal volatility and pullbacks

## Practical Example

Complete trend-following system using adaptive trendline:

```ruby
require 'sqa/tai'

# Historical price data (need at least 63 bars)
prices = [
  # ... your price data ...
]
highs = [...]
lows = [...]

# Calculate adaptive trendline and supporting indicators
trendline = SQA::TAI.ht_trendline(prices)
mode = SQA::TAI.ht_trendmode(prices)
cycle = SQA::TAI.ht_dcperiod(prices)
atr = SQA::TAI.atr(highs, lows, prices, period: 14)
rsi = SQA::TAI.rsi(prices, period: 14)

# Current values
current_price = prices.last
current_trendline = trendline.last
current_mode = mode.last
current_cycle = cycle.last.round
current_atr = atr.last
current_rsi = rsi.last

# Previous values for crossover detection
prev_price = prices[-2]
prev_trendline = trendline[-2]

puts "=" * 60
puts "HT_TRENDLINE ADAPTIVE TREND FOLLOWING SYSTEM"
puts "=" * 60
puts

# Market regime analysis
puts "MARKET ANALYSIS"
puts "-" * 60
puts "Current Price: #{current_price.round(2)}"
puts "Adaptive Trendline: #{current_trendline.round(2)}"
puts "Market Mode: #{current_mode == 1 ? 'TREND' : 'CYCLE'}"
puts "Dominant Cycle: #{current_cycle} periods"
puts "ATR: #{current_atr.round(2)}"
puts "RSI: #{current_rsi.round(2)}"
puts

# Calculate trend characteristics
price_above_trendline = current_price > current_trendline
distance_from_trendline = (current_price - current_trendline).abs
distance_pct = (distance_from_trendline / current_price * 100)

puts "TREND STATUS"
puts "-" * 60
if price_above_trendline
  puts "Trend Direction: UPTREND"
  puts "Trendline Support: #{current_trendline.round(2)}"
else
  puts "Trend Direction: DOWNTREND"
  puts "Trendline Resistance: #{current_trendline.round(2)}"
end
puts "Distance from Trendline: #{distance_from_trendline.round(2)} (#{distance_pct.round(2)}%)"
puts

# Detect crossovers
bullish_crossover = prev_price <= prev_trendline && current_price > current_trendline
bearish_crossover = prev_price >= prev_trendline && current_price < current_trendline

# Generate trading signals
puts "TRADING SIGNALS"
puts "-" * 60

# Only trade in trend mode
if current_mode == 1
  puts "Market Mode: TREND - Trendline signals ACTIVE"
  puts

  # Bullish crossover signal
  if bullish_crossover
    entry = current_price
    stop = current_trendline - (2.0 * current_atr)
    target = current_price + (3.0 * current_atr)
    risk = entry - stop
    reward = target - entry
    rr_ratio = reward / risk

    puts "BULLISH CROSSOVER DETECTED"
    puts "=" * 60
    puts "Signal: BUY (Long Entry)"
    puts
    puts "Entry Price: #{entry.round(2)}"
    puts "Stop Loss: #{stop.round(2)} (below trendline - 2*ATR)"
    puts "Take Profit: #{target.round(2)} (3*ATR target)"
    puts "Risk: #{risk.round(2)}"
    puts "Reward: #{reward.round(2)}"
    puts "Risk/Reward: 1:#{rr_ratio.round(2)}"
    puts
    puts "Position Management:"
    puts "- Trail stop to (trendline - 1*ATR) as trade progresses"
    puts "- Exit if price closes below trendline"
    puts "- Consider taking partial profits at 2*ATR"
    puts "- Hold remainder for full target"

  # Bearish crossover signal
  elsif bearish_crossover
    entry = current_price
    stop = current_trendline + (2.0 * current_atr)
    target = current_price - (3.0 * current_atr)
    risk = stop - entry
    reward = entry - target
    rr_ratio = reward / risk

    puts "BEARISH CROSSOVER DETECTED"
    puts "=" * 60
    puts "Signal: SELL (Short Entry or Exit Long)"
    puts
    puts "Entry Price: #{entry.round(2)}"
    puts "Stop Loss: #{stop.round(2)} (above trendline + 2*ATR)"
    puts "Take Profit: #{target.round(2)} (3*ATR target)"
    puts "Risk: #{risk.round(2)}"
    puts "Reward: #{reward.round(2)}"
    puts "Risk/Reward: 1:#{rr_ratio.round(2)}"
    puts
    puts "Position Management:"
    puts "- Trail stop to (trendline + 1*ATR) as trade progresses"
    puts "- Exit if price closes above trendline"
    puts "- Consider taking partial profits at 2*ATR"
    puts "- Hold remainder for full target"

  # No crossover - check for pullback opportunities
  else
    puts "No crossover detected - analyzing pullback opportunities"
    puts

    # Uptrend pullback
    if price_above_trendline
      puts "Current Uptrend: Look for pullback entries"

      # Check if near trendline
      if distance_pct < 2.0
        puts
        puts "PULLBACK BUY OPPORTUNITY"
        puts "Price near trendline support: #{current_trendline.round(2)}"
        puts "Current price: #{current_price.round(2)}"

        # RSI confirmation
        if current_rsi < 50
          puts "RSI: #{current_rsi.round(2)} (oversold in uptrend)"
          puts "STRONG BUY SETUP: Uptrend + Pullback + RSI confirmation"
          puts
          puts "Suggested Entry: #{current_price.round(2)}"
          puts "Stop: #{(current_trendline - 1.5 * current_atr).round(2)}"
          puts "Target: #{(current_price + 3 * current_atr).round(2)}"
        else
          puts "RSI: #{current_rsi.round(2)} (wait for deeper pullback)"
        end
      else
        puts "Price #{distance_pct.round(2)}% above trendline"
        puts "Wait for pullback closer to trendline support"
      end

    # Downtrend rally
    else
      puts "Current Downtrend: Look for rally sell opportunities"

      # Check if near trendline
      if distance_pct < 2.0
        puts
        puts "RALLY SELL OPPORTUNITY"
        puts "Price near trendline resistance: #{current_trendline.round(2)}"
        puts "Current price: #{current_price.round(2)}"

        # RSI confirmation
        if current_rsi > 50
          puts "RSI: #{current_rsi.round(2)} (overbought in downtrend)"
          puts "STRONG SELL SETUP: Downtrend + Rally + RSI confirmation"
          puts
          puts "Suggested Entry: #{current_price.round(2)}"
          puts "Stop: #{(current_trendline + 1.5 * current_atr).round(2)}"
          puts "Target: #{(current_price - 3 * current_atr).round(2)}"
        else
          puts "RSI: #{current_rsi.round(2)} (wait for stronger rally)"
        end
      else
        puts "Price #{distance_pct.round(2)}% below trendline"
        puts "Wait for rally closer to trendline resistance"
      end
    end
  end

else
  # Cycle mode - trendline less reliable
  puts "Market Mode: CYCLE - Trendline signals DISABLED"
  puts
  puts "Market is ranging/cycling - not suitable for trend-following"
  puts "Consider using oscillators for mean-reversion instead:"
  puts "- RSI for overbought/oversold"
  puts "- Stochastic for cycle timing"
  puts "- Bollinger Bands for range boundaries"
  puts
  puts "Wait for HT_TRENDMODE to switch to 1 (TREND) before using trendline"
end

puts
puts "=" * 60
```

## Related Indicators

### Hilbert Transform Family

- **[HT_TRENDMODE](../cycle/ht_trendmode.md)**: Determines if market is trending or cycling - use as filter for HT_TRENDLINE
- **[HT_DCPERIOD](../cycle/ht_dcperiod.md)**: Identifies the dominant cycle period that HT_TRENDLINE adapts to
- **[HT_DCPHASE](../cycle/ht_dcphase.md)**: Shows current phase within the cycle for timing entries
- **[HT_SINE](../cycle/ht_sine.md)**: Generates sine wave signals based on cycle analysis
- **[HT_PHASOR](../cycle/ht_phasor.md)**: Provides in-phase and quadrature components for advanced analysis

### Complementary Indicators

**For Trend Confirmation:**
- **[ADX](../momentum/adx.md)**: Confirm trend strength when using trendline
- **[MACD](../momentum/macd.md)**: Additional momentum confirmation
- **[EMA](../overlap/ema.md)**: Compare adaptive vs fixed-period trendlines

**For Entry Timing:**
- **[RSI](../momentum/rsi.md)**: Time pullback entries to trendline
- **[STOCH](../momentum/stoch.md)**: Identify oversold/overbought on pullbacks
- **[CCI](../momentum/cci.md)**: Confirm extremes at trendline tests

**For Risk Management:**
- **[ATR](atr.md)**: Volatility-based stop placement relative to trendline
- **[BBANDS](../overlap/bbands.md)**: Identify overextended moves from trendline
- **[NATR](natr.md)**: Normalized volatility for position sizing

### Alternative Adaptive Indicators

- **[MAMA](mama.md)**: MESA Adaptive Moving Average - another adaptive approach
- **[KAMA](../overlap/kama.md)**: Kaufman Adaptive Moving Average - efficiency-based adaptation
- **[T3](../overlap/t3.md)**: Tillson T3 - low-lag moving average (not adaptive but responsive)

## Advanced Topics

### Comparing Adaptive vs Fixed Trendlines

```ruby
# Compare HT_TRENDLINE adaptation to traditional MAs
trendline = SQA::TAI.ht_trendline(prices)
sma_10 = SQA::TAI.sma(prices, period: 10)
sma_20 = SQA::TAI.sma(prices, period: 20)
sma_30 = SQA::TAI.sma(prices, period: 30)
ema_20 = SQA::TAI.ema(prices, period: 20)

# Analyze lag characteristics
prices.each_with_index do |price, i|
  next if i < 30  # Skip initial unstable period

  ht_lag = (price - trendline[i]).abs
  sma10_lag = (price - sma_10[i]).abs
  sma20_lag = (price - sma_20[i]).abs
  sma30_lag = (price - sma_30[i]).abs
  ema20_lag = (price - ema_20[i]).abs

  puts "Bar #{i}: Price=#{price.round(2)}"
  puts "  HT Trendline lag: #{ht_lag.round(3)}"
  puts "  SMA(10) lag: #{sma10_lag.round(3)}"
  puts "  SMA(20) lag: #{sma20_lag.round(3)}"
  puts "  SMA(30) lag: #{sma30_lag.round(3)}"
  puts "  EMA(20) lag: #{ema20_lag.round(3)}"
end

# HT_TRENDLINE typically shows:
# - Less lag than SMA(20) with comparable smoothness
# - More smoothness than SMA(10) with comparable responsiveness
# - Automatic optimization without parameter adjustment
```

### Multi-Timeframe Trendline Analysis

```ruby
# Align trendlines across timeframes for high-confidence signals
daily_prices = [...]    # Daily data
hourly_prices = [...]   # Hourly data

daily_trendline = SQA::TAI.ht_trendline(daily_prices)
hourly_trendline = SQA::TAI.ht_trendline(hourly_prices)

daily_price = daily_prices.last
hourly_price = hourly_prices.last
daily_trend = daily_trendline.last
hourly_trend = hourly_trendline.last

puts "Daily: #{daily_price > daily_trend ? 'UPTREND' : 'DOWNTREND'}"
puts "Hourly: #{hourly_price > hourly_trend ? 'UPTREND' : 'DOWNTREND'}"

# Highest confidence when both aligned
if daily_price > daily_trend && hourly_price > hourly_trend
  puts "ALIGNED UPTREND - Highest confidence long signals"
elsif daily_price < daily_trend && hourly_price < hourly_trend
  puts "ALIGNED DOWNTREND - Highest confidence short signals"
else
  puts "MIXED SIGNALS - Use caution, possible consolidation"
end
```

### Trendline as Dynamic Support/Resistance

```ruby
# Track how price respects trendline as support/resistance
trendline = SQA::TAI.ht_trendline(prices)
touches = 0
bounces = 0

prices.each_with_index do |price, i|
  next if i < 63  # Skip initial period

  trend_val = trendline[i]
  prev_trend = trendline[i-1]

  # Calculate distance from trendline as percentage
  distance_pct = ((price - trend_val) / price * 100).abs

  # Count touches (within 1% of trendline)
  if distance_pct < 1.0
    touches += 1

    # Check if price bounced (moved away from trendline)
    if i < prices.size - 1
      next_distance = ((prices[i+1] - trendline[i+1]) / prices[i+1] * 100).abs
      if next_distance > distance_pct
        bounces += 1
      end
    end
  end
end

bounce_rate = touches > 0 ? (bounces.to_f / touches * 100) : 0
puts "Trendline touches: #{touches}"
puts "Successful bounces: #{bounces}"
puts "Bounce rate: #{bounce_rate.round(2)}%"
puts "Trendline reliability: #{bounce_rate > 60 ? 'HIGH' : 'MODERATE'}"
```

### Volatility-Adjusted Trendline Channels

```ruby
# Create channel around adaptive trendline using ATR
trendline = SQA::TAI.ht_trendline(prices)
atr = SQA::TAI.atr(highs, lows, prices, period: 14)

# Create upper and lower channel bands
channel_width = 2.0  # ATR multiplier

upper_channel = trendline.zip(atr).map { |t, a| t + (channel_width * a) }
lower_channel = trendline.zip(atr).map { |t, a| t - (channel_width * a) }

current_price = prices.last
current_trendline = trendline.last
current_upper = upper_channel.last
current_lower = lower_channel.last

puts "Adaptive Trendline Channel"
puts "Upper Band: #{current_upper.round(2)}"
puts "Trendline: #{current_trendline.round(2)}"
puts "Lower Band: #{current_lower.round(2)}"
puts "Current Price: #{current_price.round(2)}"
puts

# Price position in channel
if current_price > current_upper
  puts "Price ABOVE channel - overextended uptrend"
  puts "Consider taking profits or waiting for pullback"
elsif current_price < current_lower
  puts "Price BELOW channel - overextended downtrend"
  puts "Consider taking profits or waiting for bounce"
elsif current_price > current_trendline
  puts "Price in UPPER half of uptrend channel"
  puts "Healthy uptrend, but approaching resistance"
else
  puts "Price in LOWER half of downtrend channel"
  puts "Healthy downtrend, but approaching support"
end
```

## References

- **"Rocket Science for Traders"** by John F. Ehlers - Comprehensive coverage of Hilbert Transform and adaptive indicators
- **"Cybernetic Analysis for Stocks and Futures"** by John F. Ehlers - Advanced applications including instantaneous trendline
- **"Cycle Analytics for Traders"** by John F. Ehlers - Detailed explanation of cycle-adaptive techniques
- **Original Research**: John F. Ehlers pioneered the application of Hilbert Transform to create adaptive trendlines
- **TA-Lib Documentation**: [HT_TRENDLINE Function](https://ta-lib.org/function.html?name=HT_TRENDLINE)

## See Also

- [Volatility Indicators Overview](../index.md)
- [Hilbert Transform Indicators Family](../cycle/index.md)
- [Adaptive Indicators Guide](../../examples/adaptive-indicators.md)
- [Trend Following Strategies](../../examples/trend-following.md)
- [API Reference](../../api-reference.md)
