# Moving Average Convergence Divergence - Fixed Parameters (MACDFIX)

MACDFIX is a simplified version of the popular MACD indicator that uses fixed parameters for the fast (12) and slow (26) exponential moving averages. Unlike the standard MACD function which allows you to customize all three periods, MACDFIX locks in the traditional 12/26 parameters, giving you control over only the signal period (default 9). This standardized approach ensures consistent analysis across different markets and time periods, making it ideal for traders who want to stick with the time-tested MACD settings developed by Gerald Appel.

## Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41,
          46.22, 45.64, 46.21, 46.25, 46.08, 46.46,
          46.57, 45.95, 46.50, 46.02, 46.55, 47.03,
          47.35, 47.28, 47.61, 48.12, 48.34, 48.21]

# Calculate MACDFIX (returns three arrays)
macd, signal, histogram = SQA::TAI.macdfix(prices)

puts "MACD Line: #{macd.last.round(4)}"
puts "Signal Line: #{signal.last.round(4)}"
puts "Histogram: #{histogram.last.round(4)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prices` | Array<Float> | Yes | - | Array of price values (typically closing prices) |
| `signal_period` | Integer | No | 9 | Signal line EMA period (only customizable parameter) |

## Returns

Returns three arrays representing the MACD components:
1. **MACD Line** - Difference between 12-period EMA and 26-period EMA (fixed)
2. **Signal Line** - 9-period EMA of MACD line (customizable)
3. **Histogram** - Difference between MACD line and signal line

## Formula

```
MACD Line = EMA(12) - EMA(26)  [FIXED PERIODS]
Signal Line = EMA(signal_period) of MACD Line  [default: 9]
Histogram = MACD Line - Signal Line
```

## Interpretation

| Condition | Interpretation |
|-----------|----------------|
| MACD crosses above Signal | Bullish signal - momentum shifting upward |
| MACD crosses below Signal | Bearish signal - momentum shifting downward |
| MACD above zero | Fast EMA above slow EMA - upward momentum |
| MACD below zero | Fast EMA below slow EMA - downward momentum |
| Histogram increasing | Momentum strengthening in current direction |
| Histogram decreasing | Momentum weakening in current direction |
| Histogram crosses zero | MACD and Signal lines have crossed |

## Why MACDFIX Exists

### Standardization Benefits
The 12/26/9 parameters have been the MACD standard since Gerald Appel developed the indicator in the late 1970s. MACDFIX enforces this standard for several reasons:

1. **Historical Validation** - These periods have been tested across decades and multiple market conditions
2. **Comparability** - Ensures consistent analysis when comparing different securities
3. **Simplification** - Removes the temptation to over-optimize parameters
4. **Industry Standard** - Most trading platforms and analysts use 12/26/9 by default
5. **Prevents Curve Fitting** - Locked parameters discourage data mining for "perfect" settings

### When to Use MACDFIX vs MACD

**Use MACDFIX when:**
- Following traditional technical analysis approaches
- Comparing analysis across multiple securities
- Working with daily timeframes (the standard use case)
- Sharing analysis with other traders who expect standard settings
- Building systematic strategies that avoid over-optimization
- Learning MACD for the first time

**Use standard MACD when:**
- Analyzing intraday charts (may need faster periods)
- Trading highly volatile or illiquid securities
- Working with weekly/monthly timeframes (may need slower periods)
- Your backtesting shows specific periods work better for your strategy
- Adapting to unique market characteristics

## Example: MACDFIX Basic Signals

```ruby
prices = load_historical_prices('AAPL')

macd, signal, histogram = SQA::TAI.macdfix(prices)

# Current values
current_macd = macd.last
current_signal = signal.last
current_histogram = histogram.last

# Previous values for crossover detection
prev_macd = macd[-2]
prev_signal = signal[-2]

# Check for crossovers
if prev_macd < prev_signal && current_macd > current_signal
  puts "Bullish MACDFIX Crossover - BUY signal"
  puts "MACD: #{current_macd.round(4)}, Signal: #{current_signal.round(4)}"
  puts "Histogram: #{current_histogram.round(4)}"
elsif prev_macd > prev_signal && current_macd < current_signal
  puts "Bearish MACDFIX Crossover - SELL signal"
  puts "MACD: #{current_macd.round(4)}, Signal: #{current_signal.round(4)}"
  puts "Histogram: #{current_histogram.round(4)}"
end

# Zero line analysis
if current_macd > 0
  puts "12-EMA above 26-EMA: Bullish trend"
else
  puts "12-EMA below 26-EMA: Bearish trend"
end
```

## Example: Histogram Momentum Analysis

```ruby
prices = load_historical_prices('TSLA')

macd, signal, histogram = SQA::TAI.macdfix(prices)

# Analyze recent histogram trend
recent_histogram = histogram.compact.last(5)

if recent_histogram.all? { |h| h > 0 }
  # All positive - bullish territory
  if recent_histogram[-1] > recent_histogram[-2]
    puts "Bullish Acceleration"
    puts "MACD above signal and momentum increasing"
    puts "Histogram: #{recent_histogram.map { |h| h.round(4) }}"
  else
    puts "Bullish Deceleration"
    puts "MACD above signal but momentum slowing"
    puts "Consider taking profits or tightening stops"
  end
elsif recent_histogram.all? { |h| h < 0 }
  # All negative - bearish territory
  if recent_histogram[-1] < recent_histogram[-2]
    puts "Bearish Acceleration"
    puts "MACD below signal and downward momentum increasing"
    puts "Histogram: #{recent_histogram.map { |h| h.round(4) }}"
  else
    puts "Bearish Deceleration"
    puts "MACD below signal but downward momentum slowing"
    puts "Possible reversal approaching"
  end
else
  # Mixed signals - in transition
  puts "Momentum Transition Zone"
  puts "Histogram changing from positive to negative or vice versa"
end
```

## Example: MACDFIX Divergence Detection

```ruby
prices = load_historical_prices('MSFT')

macd, signal, histogram = SQA::TAI.macdfix(prices)

# Find recent price peaks
price_peak_1_idx = prices[-30..-15].index(prices[-30..-15].max) - 30
price_peak_2_idx = prices[-14..-1].index(prices[-14..-1].max) - 14

price_peak_1 = prices[price_peak_1_idx]
price_peak_2 = prices[price_peak_2_idx]

macd_peak_1 = macd[price_peak_1_idx]
macd_peak_2 = macd[price_peak_2_idx]

# Bearish divergence: price makes higher high, MACD makes lower high
if price_peak_2 > price_peak_1 && macd_peak_2 < macd_peak_1
  puts <<~DIVERGENCE
    Bearish Divergence Detected!

    Price Action:
      First Peak:  #{price_peak_1.round(2)}
      Second Peak: #{price_peak_2.round(2)} (higher high)

    MACD (12/26):
      First Peak:  #{macd_peak_1.round(4)}
      Second Peak: #{macd_peak_2.round(4)} (lower high)

    Interpretation: Price is making new highs but momentum is weakening.
    This classic bearish divergence often precedes trend reversals.
    Consider reducing long positions or preparing for a pullback.
  DIVERGENCE
end

# Find recent price troughs for bullish divergence
price_trough_1_idx = prices[-30..-15].index(prices[-30..-15].min) - 30
price_trough_2_idx = prices[-14..-1].index(prices[-14..-1].min) - 14

price_trough_1 = prices[price_trough_1_idx]
price_trough_2 = prices[price_trough_2_idx]

macd_trough_1 = macd[price_trough_1_idx]
macd_trough_2 = macd[price_trough_2_idx]

# Bullish divergence: price makes lower low, MACD makes higher low
if price_trough_2 < price_trough_1 && macd_trough_2 > macd_trough_1
  puts <<~DIVERGENCE
    Bullish Divergence Detected!

    Price Action:
      First Trough:  #{price_trough_1.round(2)}
      Second Trough: #{price_trough_2.round(2)} (lower low)

    MACD (12/26):
      First Trough:  #{macd_trough_1.round(4)}
      Second Trough: #{macd_trough_2.round(4)} (higher low)

    Interpretation: Price is making new lows but downward momentum is weakening.
    This classic bullish divergence often signals trend exhaustion.
    Watch for bullish crossover as entry confirmation.
  DIVERGENCE
end
```

## Example: Zero Line Strategy

```ruby
prices = load_historical_prices('NVDA')

macd, signal, histogram = SQA::TAI.macdfix(prices)

# Zero line crossovers indicate trend changes
prev_macd = macd[-2]
current_macd = macd.last
current_signal = signal.last

# MACD crossing above zero (12-EMA crosses above 26-EMA)
if prev_macd < 0 && current_macd > 0
  puts <<~CROSSOVER
    MACDFIX Zero Line Bullish Crossover!

    The 12-period EMA has crossed above the 26-period EMA.
    This signals a shift from bearish to bullish trend.

    MACD Value: #{current_macd.round(4)}
    Signal Line: #{current_signal.round(4)}

    Strategy:
    - Look for buying opportunities
    - Trend has shifted to bullish
    - Wait for pullbacks to enter long positions
  CROSSOVER

# MACD crossing below zero (12-EMA crosses below 26-EMA)
elsif prev_macd > 0 && current_macd < 0
  puts <<~CROSSOVER
    MACDFIX Zero Line Bearish Crossover!

    The 12-period EMA has crossed below the 26-period EMA.
    This signals a shift from bullish to bearish trend.

    MACD Value: #{current_macd.round(4)}
    Signal Line: #{current_signal.round(4)}

    Strategy:
    - Exit long positions
    - Trend has shifted to bearish
    - Consider short opportunities or stay in cash
  CROSSOVER
end

# Current trend status
puts "\nCurrent Trend Analysis (12-EMA vs 26-EMA):"
if current_macd > 0
  distance_pct = ((current_macd.abs / prices.last) * 100).round(2)
  puts "Bullish: 12-EMA above 26-EMA by #{distance_pct}%"
else
  distance_pct = ((current_macd.abs / prices.last) * 100).round(2)
  puts "Bearish: 12-EMA below 26-EMA by #{distance_pct}%"
end
```

## Example: Combining MACDFIX with Price Action

```ruby
prices = load_historical_prices('GOOGL')

# MACDFIX for momentum
macd, signal, histogram = SQA::TAI.macdfix(prices)

# Add EMAs to see the underlying moving averages
ema_12 = SQA::TAI.ema(prices, period: 12)
ema_26 = SQA::TAI.ema(prices, period: 26)

# Add longer-term trend filter
sma_200 = SQA::TAI.sma(prices, period: 200)

current_price = prices.last
current_macd = macd.last
current_signal = signal.last
current_histogram = histogram.last

# Multi-factor signal analysis
puts <<~ANALYSIS
  Comprehensive MACDFIX Analysis
  ==============================

  Price Action:
    Current Price: $#{current_price.round(2)}
    12-EMA:        $#{ema_12.last.round(2)}
    26-EMA:        $#{ema_26.last.round(2)}
    200-SMA:       $#{sma_200.last.round(2)}

  MACD Components (Fixed 12/26):
    MACD Line:   #{current_macd.round(4)}
    Signal Line: #{current_signal.round(4)}
    Histogram:   #{current_histogram.round(4)}
ANALYSIS

# Strong buy signal criteria
if current_macd > current_signal &&      # MACD above signal
   current_histogram > 0 &&              # Positive histogram
   histogram[-2] < current_histogram &&  # Increasing histogram
   current_price > sma_200.last         # Above 200-day SMA

  puts "\nSTRONG BUY SIGNAL - All indicators aligned:"
  puts "  - MACD above signal line (bullish crossover active)"
  puts "  - Histogram positive and increasing (momentum strengthening)"
  puts "  - Price above 200-SMA (long-term uptrend)"
  puts "  - 12-EMA above 26-EMA (intermediate trend bullish)"

# Strong sell signal criteria
elsif current_macd < current_signal &&      # MACD below signal
      current_histogram < 0 &&              # Negative histogram
      histogram[-2] > current_histogram &&  # Decreasing histogram
      current_price < sma_200.last          # Below 200-day SMA

  puts "\nSTRONG SELL SIGNAL - All indicators aligned:"
  puts "  - MACD below signal line (bearish crossover active)"
  puts "  - Histogram negative and decreasing (downward momentum strengthening)"
  puts "  - Price below 200-SMA (long-term downtrend)"
  puts "  - 12-EMA below 26-EMA (intermediate trend bearish)"

else
  puts "\nMIXED SIGNALS - Wait for clearer confirmation"
end
```

## Example: Custom Signal Period Analysis

```ruby
prices = load_historical_prices('SPY')

# Test different signal periods (only variable parameter in MACDFIX)
signal_periods = [5, 9, 14]  # Fast, standard, slow

puts "MACDFIX Signal Period Comparison"
puts "=" * 50

signal_periods.each do |period|
  macd, signal, histogram = SQA::TAI.macdfix(prices, signal_period: period)

  puts "\nSignal Period: #{period}"
  puts "  MACD Line:   #{macd.last.round(4)}"
  puts "  Signal Line: #{signal.last.round(4)}"
  puts "  Histogram:   #{histogram.last.round(4)}"

  # Check crossover status
  if macd.last > signal.last
    puts "  Status: MACD above Signal (Bullish)"
  else
    puts "  Status: MACD below Signal (Bearish)"
  end
end

puts <<~NOTES

  Signal Period Effects:

  Period 5 (Fast):
    - More responsive to price changes
    - Generates more signals (more false positives)
    - Better for short-term trading

  Period 9 (Standard):
    - Traditional MACD setting
    - Balanced between speed and reliability
    - Most widely used and tested

  Period 14 (Slow):
    - Smoother signal line
    - Fewer but more reliable signals
    - Better for position trading
NOTES
```

## Trading Strategies

### 1. Classic MACDFIX Crossover
The most common and straightforward MACDFIX strategy:
- **Buy Signal**: MACD line crosses above signal line
- **Sell Signal**: MACD line crosses below signal line
- **Best For**: Trending markets, swing trading
- **Risk**: Whipsaws in choppy, sideways markets

### 2. Zero Line Trend Trading
Use the zero line to identify major trend changes:
- **Long Entry**: MACD crosses above zero (confirms uptrend)
- **Short Entry**: MACD crosses below zero (confirms downtrend)
- **Exit**: When MACD crosses back through zero
- **Best For**: Position trading, trend following
- **Risk**: Late entries, trends may be maturing

### 3. Histogram Reversal
Early entry strategy using histogram momentum:
- **Entry**: When histogram stops increasing/decreasing and reverses
- **Confirmation**: Wait for 2-3 bars of histogram reversal
- **Exit**: When histogram reverses again
- **Best For**: Active traders seeking early entries
- **Risk**: Earlier signals = more false signals

### 4. Divergence Trading
Powerful reversal strategy for experienced traders:
- **Bullish**: Price lower low + MACD higher low
- **Bearish**: Price higher high + MACD lower high
- **Entry**: Wait for MACDFIX crossover to confirm
- **Best For**: Identifying trend reversals, swing trading
- **Risk**: Divergences can persist, need confirmation

## Differences from Standard MACD

| Feature | MACDFIX | MACD |
|---------|---------|------|
| Fast Period | Fixed at 12 | Customizable (default 12) |
| Slow Period | Fixed at 26 | Customizable (default 26) |
| Signal Period | Customizable (default 9) | Customizable (default 9) |
| Use Case | Standardized analysis | Flexible analysis |
| Optimization Risk | Lower (fewer parameters) | Higher (three parameters) |
| Comparability | High (always 12/26) | Lower (varied settings) |
| Complexity | Simpler (one parameter) | More complex (three parameters) |
| Learning Curve | Easier | Slightly harder |

## Advanced Techniques

### 1. Multi-Timeframe MACDFIX
Use MACDFIX on different timeframes for confirmation:
- **Daily MACDFIX**: Primary trend direction
- **4-Hour MACDFIX**: Entry timing
- **1-Hour MACDFIX**: Precise entry points
- **Rule**: Only trade when all timeframes align

### 2. MACDFIX with Volume
Combine MACDFIX with volume analysis:
- **Strong Signal**: MACDFIX crossover + volume spike
- **Weak Signal**: MACDFIX crossover + low volume
- Volume confirms the conviction behind the move

### 3. MACDFIX Overbought/Oversold
While not designed for this, extreme MACDFIX values can signal exhaustion:
- Track historical MACDFIX extremes for your security
- Very high readings = potential pullback
- Very low readings = potential bounce

### 4. Dual Signal Period Strategy
Run two MACDFIX calculations with different signal periods:
- MACDFIX(9) for standard signals
- MACDFIX(5) for early warning
- Trade only when both agree

## Common Pitfalls

### 1. Trading Every Crossover
Not all MACDFIX crossovers are created equal:
- **Solution**: Add filters (trend, volume, support/resistance)
- **Better**: Wait for crossover + zero line alignment

### 2. Ignoring the Trend Context
MACDFIX works best in trending markets:
- **Problem**: Generates false signals in choppy markets
- **Solution**: Use trend filter (200-SMA or ADX)

### 3. Missing the Fixed Parameters Limitation
MACDFIX uses 12/26 periods regardless of timeframe:
- **Issue**: May be too slow for 5-minute charts
- **Issue**: May be too fast for monthly charts
- **Solution**: Use standard MACD for non-daily charts

### 4. Expecting Exact Tops and Bottoms
MACDFIX is a momentum indicator, not a reversal indicator:
- **Reality**: Signals often come after the move has started
- **Benefit**: Confirms trends rather than picking tops/bottoms

## Related Indicators

- [MACD](macd.md) - Full version with customizable fast/slow periods
- [MACDEXT](macdext.md) - Extended version with customizable MA types
- [PPO](ppo.md) - Percentage Price Oscillator (MACD in percentage form)
- [EMA](../overlap/ema.md) - Exponential Moving Average (MACDFIX foundation)
- [RSI](rsi.md) - Complementary momentum oscillator
- [Stochastic](stoch.md) - Another momentum indicator for confirmation

## See Also

- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
- [Momentum Trading Example](../../examples/momentum-trading.md)
