# Standard Deviation (STDDEV)

Standard Deviation measures the dispersion or volatility of price returns around their mean. It quantifies how much prices deviate from their average value, making it essential for volatility analysis, risk management, and position sizing. Higher standard deviation indicates greater volatility and price swings, while lower values suggest more stable price action.

## Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41,
          46.22, 45.64, 46.21, 46.25, 46.08, 46.46,
          46.57, 45.95, 46.50, 46.02]

# Calculate 20-period standard deviation
stddev = SQA::TAI.stddev(prices, period: 20, nbdev: 1.0)

puts "Current Volatility: #{stddev.last.round(4)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prices` | Array<Float> | Yes | - | Array of price values |
| `period` | Integer | No | 5 | Number of periods for calculation |
| `nbdev` | Float | No | 1.0 | Number of standard deviations (multiplier) |

## Returns

Returns an array of standard deviation values. The first `period - 1` values will be `nil`. Values are scaled by `nbdev` parameter.

## Interpretation

| STDDEV Value | Market Condition | Trading Implication |
|--------------|------------------|---------------------|
| High/Rising | High volatility | Wide price swings, larger stops, breakout potential |
| Low/Falling | Low volatility | Tight range, squeeze pattern, consolidation |
| Expanding | Volatility increasing | Trend acceleration, breakout occurring |
| Contracting | Volatility decreasing | Range compression, pre-breakout squeeze |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

## Example: Volatility Regime Detection

```ruby
prices = load_historical_prices('AAPL')

stddev = SQA::TAI.stddev(prices, period: 20, nbdev: 1.0)
current_vol = stddev.last

# Calculate volatility percentile
recent_vols = stddev.last(100).compact
percentile = recent_vols.count { |v| v < current_vol } / recent_vols.size.to_f * 100

puts "Current Volatility: #{current_vol.round(4)}"
puts "Volatility Percentile: #{percentile.round(1)}%"

case percentile
when 0...20
  puts "Low Volatility Regime - Expect breakout soon"
  puts "Strategy: Prepare for range expansion"
when 20...40
  puts "Below Average Volatility"
  puts "Strategy: Look for squeeze setups"
when 40...60
  puts "Normal Volatility"
  puts "Strategy: Standard position sizing"
when 60...80
  puts "Above Average Volatility"
  puts "Strategy: Reduce position size"
when 80..100
  puts "High Volatility Regime - Exercise caution"
  puts "Strategy: Smaller positions, wider stops"
end
```

## Example: Dynamic Position Sizing

```ruby
prices = load_historical_prices('TSLA')

stddev = SQA::TAI.stddev(prices, period: 20, nbdev: 1.0)
current_price = prices.last
current_vol = stddev.last

# Risk-based position sizing
account_size = 100_000
risk_per_trade = 0.02  # 2% risk
max_position = account_size * 0.10  # Max 10% per position

# Stop loss at 2 standard deviations
stop_distance = current_vol * 2
stop_price = current_price - stop_distance
risk_per_share = stop_distance

# Calculate position size based on volatility
shares = (account_size * risk_per_trade) / risk_per_share
position_value = shares * current_price

# Cap at maximum position size
if position_value > max_position
  shares = max_position / current_price
  position_value = max_position
end

puts <<~POSITION_SIZING
  === Volatility-Based Position Sizing ===
  Current Price: $#{current_price.round(2)}
  Standard Deviation: $#{current_vol.round(2)}
  Stop Loss (2 SD): $#{stop_price.round(2)}
  Risk per Share: $#{risk_per_share.round(2)}

  Recommended Shares: #{shares.round(0)}
  Position Value: $#{position_value.round(2)}
  Max Risk: $#{(shares * risk_per_share).round(2)}
POSITION_SIZING
```

## Example: Volatility Squeeze Detection

```ruby
prices = load_historical_prices('MSFT')

stddev = SQA::TAI.stddev(prices, period: 20, nbdev: 1.0)

# Calculate Bollinger Band width using standard deviation
upper, middle, lower = SQA::TAI.bbands(prices, period: 20, nbdev_up: 2.0, nbdev_down: 2.0)
bandwidth = (upper.last - lower.last) / middle.last * 100

# Compare current volatility to recent range
recent_stddevs = stddev.last(100).compact
min_vol = recent_stddevs.min
max_vol = recent_stddevs.max
avg_vol = recent_stddevs.sum / recent_stddevs.size
current_vol = stddev.last

# Squeeze detection
vol_range = max_vol - min_vol
vol_position = (current_vol - min_vol) / vol_range * 100

puts "=== Volatility Squeeze Analysis ==="
puts "Current STDDEV: #{current_vol.round(4)}"
puts "Average STDDEV: #{avg_vol.round(4)}"
puts "Volatility Position: #{vol_position.round(1)}% of range"
puts "Bollinger Bandwidth: #{bandwidth.round(2)}%"

if vol_position < 25 && bandwidth < 10
  puts "\n*** SQUEEZE ALERT ***"
  puts "Extremely low volatility detected"
  puts "Prepare for significant breakout"
  puts "Watch for direction confirmation"
elsif vol_position > 75
  puts "\nHigh Volatility - Trend in motion"
  puts "Consider trailing stops"
end
```

## Example: Volatility Breakout Strategy

```ruby
prices = load_historical_prices('NVDA')
highs = load_historical_highs('NVDA')
lows = load_historical_lows('NVDA')

stddev = SQA::TAI.stddev(prices, period: 20, nbdev: 1.0)
sma = SQA::TAI.sma(prices, period: 20)

# Track volatility compression
recent_vols = stddev.last(10).compact
avg_recent_vol = recent_vols.sum / recent_vols.size
longer_vols = stddev.last(50).compact
avg_longer_vol = longer_vols.sum / longer_vols.size

volatility_ratio = avg_recent_vol / avg_longer_vol
current_price = prices.last
current_high = highs.last
current_low = lows.last

puts "=== Volatility Breakout Setup ==="
puts "Volatility Ratio: #{(volatility_ratio * 100).round(1)}%"

if volatility_ratio < 0.5
  puts "Volatility compressed to 50% of normal"

  # Set breakout levels
  upper_breakout = sma.last + (stddev.last * 2.5)
  lower_breakout = sma.last - (stddev.last * 2.5)

  puts "\nBreakout Levels:"
  puts "Upper: $#{upper_breakout.round(2)}"
  puts "Lower: $#{lower_breakout.round(2)}"

  # Check for breakout
  if current_high > upper_breakout
    puts "\n*** BULLISH BREAKOUT ***"
    puts "Entry: $#{upper_breakout.round(2)}"
    puts "Target: $#{(upper_breakout + stddev.last * 4).round(2)}"
    puts "Stop: $#{(upper_breakout - stddev.last * 1.5).round(2)}"
  elsif current_low < lower_breakout
    puts "\n*** BEARISH BREAKOUT ***"
    puts "Entry: $#{lower_breakout.round(2)}"
    puts "Target: $#{(lower_breakout - stddev.last * 4).round(2)}"
    puts "Stop: $#{(lower_breakout + stddev.last * 1.5).round(2)}"
  else
    puts "\nWaiting for breakout direction..."
  end
end
```

## Example: Volatility-Adjusted Stop Loss

```ruby
prices = load_historical_prices('AMZN')

stddev = SQA::TAI.stddev(prices, period: 14, nbdev: 1.0)
atr = SQA::TAI.atr(highs, lows, prices, period: 14)

current_price = prices.last
current_stddev = stddev.last
current_atr = atr.last

puts "=== Volatility-Based Stop Placement ==="
puts "Current Price: $#{current_price.round(2)}"
puts "Standard Deviation: $#{current_stddev.round(2)}"
puts "ATR: $#{current_atr.round(2)}"

# Multiple stop loss approaches
stop_1sd = current_price - (current_stddev * 1.0)
stop_2sd = current_price - (current_stddev * 2.0)
stop_3sd = current_price - (current_stddev * 3.0)
stop_atr = current_price - (current_atr * 2.0)

puts <<~STOPS

  Stop Loss Options:
  1. Tight (1 SD):    $#{stop_1sd.round(2)} - Risk: $#{(current_price - stop_1sd).round(2)}
  2. Medium (2 SD):   $#{stop_2sd.round(2)} - Risk: $#{(current_price - stop_2sd).round(2)}
  3. Wide (3 SD):     $#{stop_3sd.round(2)} - Risk: $#{(current_price - stop_3sd).round(2)}
  4. ATR-based (2x):  $#{stop_atr.round(2)} - Risk: $#{(current_price - stop_atr).round(2)}

  Recommendation:
  - Day trades: Use 1-2 SD
  - Swing trades: Use 2-3 SD
  - Position trades: Use 3 SD or ATR
STOPS
```

## Example: Volatility Expansion/Contraction Cycles

```ruby
prices = load_historical_prices('SPY')

stddev = SQA::TAI.stddev(prices, period: 20, nbdev: 1.0)

# Calculate volatility trend
stddev_sma = SQA::TAI.sma(stddev.compact, period: 10)
current_vol = stddev.last
trend_vol = stddev_sma.last

# Identify cycle phase
volatility_trend = current_vol > trend_vol ? "Expanding" : "Contracting"
vol_change = ((current_vol - trend_vol) / trend_vol * 100).round(2)

# Historical context
vols_50 = stddev.last(50).compact
vols_200 = stddev.last(200).compact

avg_50 = vols_50.sum / vols_50.size
avg_200 = vols_200.sum / vols_200.size

puts <<~CYCLES
  === Volatility Cycle Analysis ===
  Current Volatility: #{current_vol.round(4)}
  Trend (10-period MA): #{trend_vol.round(4)}

  Cycle Phase: #{volatility_trend}
  Change from Trend: #{vol_change}%

  Historical Context:
  50-day Average: #{avg_50.round(4)}
  200-day Average: #{avg_200.round(4)}
CYCLES

if volatility_trend == "Expanding"
  puts "\nVolatility Expansion Phase:"
  puts "- Expect larger price swings"
  puts "- Widen stop losses"
  puts "- Reduce position sizes"
  puts "- Look for trend continuation"
else
  puts "\nVolatility Contraction Phase:"
  puts "- Range-bound market likely"
  puts "- Tighten stops"
  puts "- Prepare for breakout"
  puts "- Reduce directional bias"
end
```

## Trading Strategies

### 1. Volatility Squeeze Breakout
- **Setup**: STDDEV contracts to historical lows
- **Entry**: Break of consolidation range
- **Target**: Move equal to previous volatility expansion
- **Stop**: Opposite side of consolidation range

### 2. Volatility Mean Reversion
- **Setup**: STDDEV expands to extreme levels
- **Entry**: Price returns toward moving average
- **Target**: Return to normal volatility range
- **Stop**: Beyond recent volatility extreme

### 3. Dynamic Stop Placement
- **Conservative**: 3 × STDDEV from entry
- **Moderate**: 2 × STDDEV from entry
- **Aggressive**: 1 × STDDEV from entry
- **Adjust**: As volatility changes

### 4. Position Sizing by Volatility
- **High Vol**: Smaller positions (50-75% normal)
- **Normal Vol**: Standard position size
- **Low Vol**: Potentially larger (100-125% normal)
- **Formula**: Risk / (2 × STDDEV) = Shares

## Common Settings

| Period | Use Case | Typical NBDEV |
|--------|----------|---------------|
| 5-10 | Short-term trading | 1.0-1.5 |
| 14-20 | Swing trading | 1.0-2.0 |
| 20-30 | Bollinger Bands | 2.0 |
| 50-100 | Position trading | 2.0-3.0 |

## Volatility Interpretation

| STDDEV/Price Ratio | Volatility Level | Market State |
|-------------------|------------------|--------------|
| < 1% | Very Low | Extreme compression |
| 1-2% | Low | Range-bound |
| 2-4% | Normal | Typical market |
| 4-6% | Elevated | Active trending |
| > 6% | High | Extreme conditions |

## Advanced Techniques

### 1. Bollinger Band Construction
STDDEV is the foundation of Bollinger Bands:
- Upper Band = SMA + (STDDEV × 2)
- Middle Band = SMA
- Lower Band = SMA - (STDDEV × 2)

### 2. Statistical Significance
- 1 SD: 68% of prices within range
- 2 SD: 95% of prices within range
- 3 SD: 99.7% of prices within range

### 3. Volatility Clustering
Periods of high volatility tend to cluster together, as do periods of low volatility.

### 4. VIX Correlation
Compare equity STDDEV to VIX for broader market context.

## Related Indicators

- [Bollinger Bands (BBANDS)](../overlap/bbands.md) - Uses STDDEV for band width
- [Average True Range (ATR)](../volatility/atr.md) - Alternative volatility measure
- [Variance (VAR)](var.md) - STDDEV squared
- [Normalized ATR (NATR)](../volatility/natr.md) - Percentage-based volatility

## See Also

- [Back to Indicators](../index.md)
- [Statistical Indicators Overview](../index.md)
<!-- TODO: Create example file -->
- Volatility Analysis Example
<!-- TODO: Create guide file -->
- Risk Management Guide
