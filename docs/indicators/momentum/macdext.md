# MACD with Controllable MA Type (MACDEXT)

The Moving Average Convergence Divergence Extended (MACDEXT) is an enhanced version of the standard MACD indicator that allows you to customize the type of moving average used for each component. While the standard MACD uses exponential moving averages (EMA), MACDEXT lets you experiment with different smoothing methods to reduce lag, increase adaptability, or optimize for different market conditions.

## What It Measures

MACDEXT measures the same momentum and trend characteristics as standard MACD - the relationship between two moving averages of different periods. The key difference is the ability to select from 9 different moving average types for the fast line, slow line, and signal line independently.

## Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41,
          46.22, 45.64, 46.21, 46.25, 46.08, 46.46,
          46.57, 45.95, 46.50, 46.02, 46.55, 47.03,
          47.35, 47.28, 47.61, 48.12, 48.34, 48.21]

# Standard MACDEXT with default EMA (equivalent to standard MACD)
macd, signal, histogram = SQA::TAI.macdext(
  prices,
  fast_period: 12,
  slow_period: 26,
  signal_period: 9
)

puts "MACD Line: #{macd.last.round(4)}"
puts "Signal Line: #{signal.last.round(4)}"
puts "Histogram: #{histogram.last.round(4)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prices` | Array | Yes | - | Array of price values |
| `fast_period` | Integer | No | 12 | Fast moving average period |
| `slow_period` | Integer | No | 26 | Slow moving average period |
| `signal_period` | Integer | No | 9 | Signal line period |
| `fast_ma_type` | Integer | No | 0 | Moving average type for fast line |
| `slow_ma_type` | Integer | No | 0 | Moving average type for slow line |
| `signal_ma_type` | Integer | No | 0 | Moving average type for signal line |

## Moving Average Types

MACDEXT supports 9 different moving average algorithms, each with unique characteristics:

| Value | Type | Description | Best For |
|-------|------|-------------|----------|
| 0 | SMA | Simple Moving Average | Equal weight to all prices, smoothest but laggiest |
| 1 | EMA | Exponential Moving Average | Standard MACD, balanced responsiveness |
| 2 | WMA | Weighted Moving Average | Linear weight, more recent emphasis |
| 3 | DEMA | Double Exponential MA | Reduced lag, faster signals |
| 4 | TEMA | Triple Exponential MA | Minimal lag, very responsive |
| 5 | TRIMA | Triangular Moving Average | Double-smoothed, very smooth signals |
| 6 | KAMA | Kaufman Adaptive MA | Adapts to volatility, efficient in choppy markets |
| 7 | MAMA | MESA Adaptive MA | Adapts to market cycles, complex algorithm |
| 8 | T3 | Triple Exponential Smoothed | Very smooth with minimal lag |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

## Returns

Returns three arrays:
1. **MACD Line** - Difference between fast and slow moving averages
2. **Signal Line** - Moving average of MACD line
3. **Histogram** - Difference between MACD and signal line

All arrays maintain the same length as the input prices array, with initial values as `nil` during the warm-up period.

## Interpretation

The interpretation is identical to standard MACD:

- **MACD crosses above Signal**: Bullish signal (potential buy)
- **MACD crosses below Signal**: Bearish signal (potential sell)
- **MACD above zero**: Fast MA above slow MA, upward momentum
- **MACD below zero**: Fast MA below slow MA, downward momentum
- **Histogram increasing**: Momentum strengthening in current direction
- **Histogram decreasing**: Momentum weakening, potential reversal

## Choosing MA Types

### For Reduced Lag (Faster Signals)

Use DEMA, TEMA, or T3 to get earlier signals with less lag:

```ruby
# DEMA for fast response
macd, signal, histogram = SQA::TAI.macdext(
  prices,
  fast_period: 12,
  slow_period: 26,
  signal_period: 9,
  fast_ma_type: 3,    # DEMA
  slow_ma_type: 3,    # DEMA
  signal_ma_type: 3   # DEMA
)
```

**Use when:**
- Trading in fast-moving markets
- Day trading or scalping
- You need earlier entry/exit signals
- Accepting more false signals for speed

### For Smoothness (Cleaner Signals)

Use TRIMA, T3, or SMA to reduce noise and false signals:

```ruby
# T3 for smooth, clean signals
macd, signal, histogram = SQA::TAI.macdext(
  prices,
  fast_period: 12,
  slow_period: 26,
  signal_period: 9,
  fast_ma_type: 8,    # T3
  slow_ma_type: 8,    # T3
  signal_ma_type: 8   # T3
)
```

**Use when:**
- Trading in noisy/choppy markets
- Swing trading or position trading
- You want fewer but more reliable signals
- Avoiding whipsaws is priority

### For Adaptive Behavior

Use KAMA or MAMA to automatically adjust to market conditions:

```ruby
# KAMA adapts to volatility
macd, signal, histogram = SQA::TAI.macdext(
  prices,
  fast_period: 12,
  slow_period: 26,
  signal_period: 9,
  fast_ma_type: 6,    # KAMA
  slow_ma_type: 6,    # KAMA
  signal_ma_type: 6   # KAMA
)
```

**Use when:**
- Market conditions vary (trending vs. ranging)
- You want automatic adjustment to volatility
- Trading multiple timeframes or instruments
- Optimizing for efficiency in changing markets

## Example: DEMA for Reduced Lag

```ruby
prices = load_historical_prices('AAPL')

# Standard MACD with EMA
macd_ema, signal_ema, hist_ema = SQA::TAI.macd(prices)

# MACDEXT with DEMA for faster response
macd_dema, signal_dema, hist_dema = SQA::TAI.macdext(
  prices,
  fast_period: 12,
  slow_period: 26,
  signal_period: 9,
  fast_ma_type: 3,    # DEMA
  slow_ma_type: 3,    # DEMA
  signal_ma_type: 3   # DEMA
)

puts "Standard MACD (EMA):"
puts "  MACD: #{macd_ema.last.round(4)}"
puts "  Signal: #{signal_ema.last.round(4)}"
puts "  Histogram: #{hist_ema.last.round(4)}"

puts "\nMACDEXT with DEMA (reduced lag):"
puts "  MACD: #{macd_dema.last.round(4)}"
puts "  Signal: #{signal_dema.last.round(4)}"
puts "  Histogram: #{hist_dema.last.round(4)}"

# DEMA typically signals earlier
if macd_dema[-2] < signal_dema[-2] && macd_dema[-1] > signal_dema[-1]
  puts "\nDEMA MACD crossover detected (earlier signal)"
end
```

## Example: KAMA for Adaptive Trading

```ruby
prices = load_historical_prices('TSLA')

# KAMA adapts to market volatility
macd, signal, histogram = SQA::TAI.macdext(
  prices,
  fast_period: 12,
  slow_period: 26,
  signal_period: 9,
  fast_ma_type: 6,    # KAMA
  slow_ma_type: 6,    # KAMA
  signal_ma_type: 6   # KAMA
)

# KAMA moves faster in trending markets, slower in choppy markets
if macd.last > signal.last
  puts "KAMA MACD: Bullish momentum"
  puts "MACD: #{macd.last.round(4)}, Signal: #{signal.last.round(4)}"

  # Check histogram for momentum strength
  if histogram.last > histogram[-2]
    puts "Momentum increasing (KAMA adapting to trend)"
  end
else
  puts "KAMA MACD: Bearish momentum"
  puts "MACD: #{macd.last.round(4)}, Signal: #{signal.last.round(4)}"
end
```

## Example: T3 for Smooth Signals

```ruby
prices = load_historical_prices('MSFT')

# T3 provides very smooth signals with minimal lag
macd, signal, histogram = SQA::TAI.macdext(
  prices,
  fast_period: 12,
  slow_period: 26,
  signal_period: 9,
  fast_ma_type: 8,    # T3
  slow_ma_type: 8,    # T3
  signal_ma_type: 8   # T3
)

puts "T3 MACD (smoothest with minimal lag):"
puts "MACD: #{macd.last.round(4)}"
puts "Signal: #{signal.last.round(4)}"
puts "Histogram: #{histogram.last.round(4)}"

# T3 reduces whipsaws in choppy markets
recent_signals = []
(-10..-1).each do |i|
  if macd[i-1] && signal[i-1] && macd[i] && signal[i]
    if macd[i-1] < signal[i-1] && macd[i] > signal[i]
      recent_signals << "buy"
    elsif macd[i-1] > signal[i-1] && macd[i] < signal[i]
      recent_signals << "sell"
    end
  end
end

puts "\nSignals in last 10 periods: #{recent_signals.length}"
puts "T3 smoothing reduces false crossovers"
```

## Example: Mixed MA Types

```ruby
prices = load_historical_prices('NVDA')

# Mix different MA types for unique characteristics
macd, signal, histogram = SQA::TAI.macdext(
  prices,
  fast_period: 12,
  slow_period: 26,
  signal_period: 9,
  fast_ma_type: 3,    # DEMA for fast line (responsive)
  slow_ma_type: 1,    # EMA for slow line (standard)
  signal_ma_type: 8   # T3 for signal line (smooth)
)

puts "Hybrid MACDEXT:"
puts "  Fast: DEMA (responsive)"
puts "  Slow: EMA (standard)"
puts "  Signal: T3 (smooth)"
puts ""
puts "MACD: #{macd.last.round(4)}"
puts "Signal: #{signal.last.round(4)}"
puts "Histogram: #{histogram.last.round(4)}"

# This combination gives fast detection with smooth confirmation
if macd[-2] < signal[-2] && macd[-1] > signal[-1]
  puts "\nBullish crossover with mixed MA types"
  puts "Fast DEMA detection + smooth T3 confirmation"
end
```

## Example: Comparing Multiple MA Types

```ruby
prices = load_historical_prices('GOOGL')

# Compare different MA types
ma_types = {
  'EMA' => 1,
  'DEMA' => 3,
  'TEMA' => 4,
  'KAMA' => 6,
  'T3' => 8
}

puts "MACDEXT Comparison for Different MA Types:"
puts "-" * 60

ma_types.each do |name, type|
  macd, signal, histogram = SQA::TAI.macdext(
    prices,
    fast_period: 12,
    slow_period: 26,
    signal_period: 9,
    fast_ma_type: type,
    slow_ma_type: type,
    signal_ma_type: type
  )

  signal_type = if macd.last > signal.last
    "BULLISH"
  else
    "BEARISH"
  end

  puts "#{name.ljust(6)}: MACD=#{macd.last.round(4).to_s.rjust(8)} " \
       "Signal=#{signal.last.round(4).to_s.rjust(8)} " \
       "Hist=#{histogram.last.round(4).to_s.rjust(8)} #{signal_type}"
end

puts "\nNote differences in values and potential timing of crossovers"
```

## Trading Strategies with MACDEXT

### 1. Fast Entry Strategy (DEMA/TEMA)
```ruby
# Use DEMA or TEMA for aggressive entry
macd, signal, histogram = SQA::TAI.macdext(
  prices,
  fast_ma_type: 3,    # DEMA
  slow_ma_type: 3,
  signal_ma_type: 3
)

# Enter on early crossovers
if macd[-2] < signal[-2] && macd[-1] > signal[-1]
  puts "DEMA MACD: Early buy signal"
  puts "Trade aggressively with tight stops"
end
```

### 2. Smooth Confirmation Strategy (T3)
```ruby
# Use T3 for clean signals
macd, signal, histogram = SQA::TAI.macdext(
  prices,
  fast_ma_type: 8,    # T3
  slow_ma_type: 8,
  signal_ma_type: 8
)

# Wait for clear confirmation
if macd.last > signal.last && histogram.last > histogram[-2]
  puts "T3 MACD: Confirmed buy with momentum"
  puts "Lower risk, cleaner entry"
end
```

### 3. Adaptive Strategy (KAMA)
```ruby
# Use KAMA to adapt to market conditions
macd, signal, histogram = SQA::TAI.macdext(
  prices,
  fast_ma_type: 6,    # KAMA
  slow_ma_type: 6,
  signal_ma_type: 6
)

# KAMA adjusts automatically
if macd[-2] < signal[-2] && macd[-1] > signal[-1]
  puts "KAMA MACD: Market-adaptive buy signal"
  puts "Responds to current volatility environment"
end
```

### 4. Multi-Confirmation Strategy
```ruby
# Get signals from multiple MA types
macd_fast, signal_fast, hist_fast = SQA::TAI.macdext(
  prices,
  fast_ma_type: 3,    # DEMA - fast
  slow_ma_type: 3,
  signal_ma_type: 3
)

macd_smooth, signal_smooth, hist_smooth = SQA::TAI.macdext(
  prices,
  fast_ma_type: 8,    # T3 - smooth
  slow_ma_type: 8,
  signal_ma_type: 8
)

# Strongest signals when both agree
fast_bullish = macd_fast.last > signal_fast.last
smooth_bullish = macd_smooth.last > signal_smooth.last

if fast_bullish && smooth_bullish
  puts "Strong Buy: Both DEMA and T3 MACD are bullish"
  puts "Fast signal confirmed by smooth signal"
elsif !fast_bullish && !smooth_bullish
  puts "Strong Sell: Both DEMA and T3 MACD are bearish"
  puts "Fast signal confirmed by smooth signal"
else
  puts "Mixed signals: Wait for confirmation"
end
```

## MA Type Selection Guide

### When to Use Each Type

**SMA (0)**: Basic, equal weighting
- Educational purposes
- Very long-term analysis
- When simplicity is needed

**EMA (1)**: Standard MACD default
- General purpose trading
- Balanced responsiveness
- Industry standard comparisons

**WMA (2)**: Linear weighting
- Slightly more responsive than SMA
- Rarely used in MACD

**DEMA (3)**: Reduced lag
- Day trading
- Fast-moving markets
- Early signal detection
- Accept more false signals

**TEMA (4)**: Minimal lag
- Scalping
- Very fast markets
- Maximum responsiveness
- Highest false signal rate

**TRIMA (5)**: Maximum smoothness
- Very choppy markets
- Long-term trends only
- Minimizing whipsaws

**KAMA (6)**: Adaptive to volatility
- Variable market conditions
- Multi-market trading
- Automatic optimization
- All-weather indicator

**MAMA (7)**: Adaptive to cycles
- Cyclic markets
- Complex analysis
- Advanced users only

**T3 (8)**: Smooth with minimal lag
- Swing trading
- Clean signals preferred
- Balance of speed and smoothness
- Reducing false crossovers

## Combining with Other Indicators

```ruby
prices = load_historical_prices('AAPL')

# MACDEXT with DEMA for momentum
macd, signal, histogram = SQA::TAI.macdext(
  prices,
  fast_ma_type: 3,    # DEMA
  slow_ma_type: 3,
  signal_ma_type: 3
)

# RSI for overbought/oversold
rsi = SQA::TAI.rsi(prices, period: 14)

# Trend filter with SMA
sma_200 = SQA::TAI.sma(prices, period: 200)

current_price = prices.last

# Multi-indicator confirmation
if macd.last > signal.last &&      # DEMA MACD bullish
   histogram.last > histogram[-2] && # Momentum increasing
   rsi.last < 70 &&                  # Not overbought
   current_price > sma_200.last      # Above long-term trend
  puts "Strong BUY: All indicators aligned"
  puts "DEMA MACD: #{macd.last.round(4)}"
  puts "RSI: #{rsi.last.round(2)}"
  puts "Price vs SMA200: +#{((current_price/sma_200.last - 1) * 100).round(2)}%"
end
```

## Performance Comparison

Different MA types will produce different results:

```ruby
prices = load_historical_prices('TSLA', days: 100)

# Test different MA types
results = []

[
  ['Standard EMA', 1],
  ['Fast DEMA', 3],
  ['Fastest TEMA', 4],
  ['Adaptive KAMA', 6],
  ['Smooth T3', 8]
].each do |name, ma_type|
  macd, signal, histogram = SQA::TAI.macdext(
    prices,
    fast_ma_type: ma_type,
    slow_ma_type: ma_type,
    signal_ma_type: ma_type
  )

  # Count crossovers (trading signals)
  crossovers = 0
  (1...macd.compact.length).each do |i|
    if (macd[i-1] < signal[i-1] && macd[i] > signal[i]) ||
       (macd[i-1] > signal[i-1] && macd[i] < signal[i])
      crossovers += 1
    end
  end

  results << {
    name: name,
    signals: crossovers,
    current_macd: macd.last.round(4),
    current_signal: signal.last.round(4)
  }
end

puts "MA Type Performance Comparison:"
puts "-" * 60
results.each do |r|
  puts "#{r[:name].ljust(20)}: #{r[:signals]} signals, " \
       "MACD=#{r[:current_macd]}, Signal=#{r[:current_signal]}"
end
puts "\nMore signals = more responsive (but more false positives)"
puts "Fewer signals = smoother (but delayed entries)"
```

## Related Indicators

- [MACD](macd.md) - Standard MACD with EMA
- [APO](apo.md) - Absolute Price Oscillator
- [PPO](ppo.md) - Percentage Price Oscillator
- [EMA](../overlap/ema.md) - Exponential Moving Average
- [DEMA](../overlap/dema.md) - Double Exponential Moving Average
- [TEMA](../overlap/tema.md) - Triple Exponential Moving Average
- [KAMA](../overlap/kama.md) - Kaufman Adaptive Moving Average
- [T3](../overlap/t3.md) - Triple Exponential Smoothed Moving Average

## See Also

- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
<!-- TODO: Create guide file -->
- Moving Averages Guide
