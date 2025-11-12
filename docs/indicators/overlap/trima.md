# TRIMA (Triangular Moving Average)

## Overview

The Triangular Moving Average (TRIMA) is a double-smoothed moving average that places more weight on the middle portion of the data series, creating a triangular weight distribution. Developed as an enhancement to the Simple Moving Average, TRIMA provides one of the smoothest trend indicators available, making it particularly valuable for identifying longer-term trends and filtering out short-term market noise.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `input_data` | Array | Required | The price data array (typically close prices) |
| `period` | Integer | 30 | Number of periods for TRIMA calculation |

### Parameter Details

**input_data**
- Typically uses closing prices for standard trend analysis
- Can use other price types (high, low, typical price) for specialized applications
- Requires sufficient data points: approximately `period * 1.5` for stable calculations
- More historical data improves the indicator's reliability and smoothness

**period** (time_period)
- Default is 30 periods, providing excellent smoothness for trend identification
- Common periods and their uses:
  - 10-20 periods: Short to medium-term trends
  - 30-50 periods: Standard trend identification (most common)
  - 100+ periods: Major long-term trends only
- Shorter periods provide some responsiveness but lose TRIMA's smoothness advantage
- Longer periods maximize smoothness but increase lag significantly
- Recommended ranges:
  - Swing trading: 20-30 periods
  - Position trading: 30-50 periods
  - Long-term investing: 100-200 periods

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41,
          46.22, 45.64, 46.21, 46.25, 46.08, 46.46,
          46.82, 47.00, 47.32, 47.20, 47.57, 47.80,
          48.00, 48.15, 48.30, 48.40, 48.55, 48.70,
          48.85, 49.00]

# Calculate 30-period TRIMA (default)
trima = SQA::TAI.trima(prices)

puts "Current TRIMA: #{trima.last.round(2)}"
```

### With Custom Parameters

```ruby
# Calculate 20-period TRIMA
trima_20 = SQA::TAI.trima(prices, period: 20)

# Calculate 50-period TRIMA for long-term trends
trima_50 = SQA::TAI.trima(prices, period: 50)

puts "Short-term TRIMA (20): #{trima_20.last.round(2)}"
puts "Standard TRIMA (30): #{trima.last.round(2)}"
puts "Long-term TRIMA (50): #{trima_50.last.round(2)}"
```

## Understanding the Indicator

### What It Measures

The TRIMA measures trend direction with maximum smoothness:

- **Long-term Trend Direction**: Identifies major market trends by double-smoothing price data
- **Market Structure**: Shows the overall direction of market movement without short-term noise
- **Dynamic Support/Resistance**: Acts as a very stable support level in uptrends and resistance in downtrends
- **Trend Confirmation**: Excellent for confirming trends identified by faster indicators

TRIMA solves the problem of market noise obscuring the underlying trend. By applying a triangular weight distribution where middle values have the highest influence, TRIMA creates one of the smoothest trend indicators available.

### Calculation Method

The TRIMA uses a double-smoothing process with triangular weighting:

1. **Determine Sub-period**: Calculate (period + 1) / 2 for odd periods, or period / 2 for even periods
2. **First SMA**: Calculate Simple Moving Average over the sub-period
3. **Second SMA**: Calculate SMA of the first SMA
4. **Result**: A double-smoothed average with triangular weight distribution

**Formula:**
```
For odd period n:
  Sub-period = (n + 1) / 2
  TRIMA = SMA(SMA(prices, sub-period), sub-period)

For even period n:
  Sub-period = n / 2
  TRIMA = SMA(SMA(prices, sub-period), sub-period + 1)

Where:
- The first SMA smooths the price data
- The second SMA smooths the first SMA
- This creates a triangular weight distribution
- Middle values have the highest influence on the result
```

### Indicator Characteristics

- **Range**: Unbounded (follows price range)
- **Type**: Overlay indicator (plotted on price chart)
- **Lag**: High lag, very smooth with delayed response
- **Best Used**: Long-term position trading, trend confirmation, filtering noise

## Interpretation

### Value Ranges

The TRIMA's value follows the price range with significant smoothing:

- **TRIMA Rising**: Indicates established uptrend
- **TRIMA Falling**: Indicates established downtrend
- **TRIMA Flat**: Suggests consolidation or balanced market

### Key Levels

- **Price Above TRIMA**: Bullish condition, confirmed uptrend
- **Price Below TRIMA**: Bearish condition, confirmed downtrend
- **Price Crossing TRIMA**: Major trend change signal (infrequent but significant)
- **Distance from TRIMA**: Extreme distances suggest potential mean reversion

### Signal Interpretation

How to read the TRIMA's signals:

1. **Trend Direction**
   - Price above rising TRIMA = confirmed major uptrend
   - Price below falling TRIMA = confirmed major downtrend
   - TRIMA flat = no clear long-term trend

2. **Momentum Changes**
   - TRIMA slope steepening = strengthening trend
   - TRIMA slope flattening = weakening trend
   - TRIMA slope reversal = major trend change (rare but significant)

3. **Reversal Signals**
   - Price crosses below TRIMA = major trend reversal to downtrend
   - Price crosses above TRIMA = major trend reversal to uptrend
   - Due to lag, these are late signals but very reliable

## Trading Signals

### Buy Signals

Specific conditions that generate buy signals:

1. **Primary Signal**: Price crosses above TRIMA and TRIMA is rising
2. **Confirmation Signal**: Multiple periods of closes above TRIMA
3. **Entry Criteria**: Wait for pullback to TRIMA for better entry

**Example Scenario:**
```
When price crosses above TRIMA and TRIMA slope turns upward,
confirm the uptrend. Wait for price to pull back toward TRIMA,
then enter long with stop loss 3-5% below TRIMA.
Target major resistance levels or use trailing stop.
```

### Sell Signals

Specific conditions that generate sell signals:

1. **Primary Signal**: Price crosses below TRIMA and TRIMA is falling
2. **Confirmation Signal**: Multiple periods of closes below TRIMA
3. **Exit Criteria**: Don't wait for signal; TRIMA is for trend confirmation, not timing

**Example Scenario:**
```
When price crosses below TRIMA and TRIMA slope turns downward,
exit all long positions. The major trend has reversed.
Consider re-entering only after price recrosses above TRIMA.
```

### Divergence Analysis

**Bullish Divergence:**
- Price makes lower lows while TRIMA makes higher lows or stays flat
- Indicates major trend exhaustion to the downside
- Very reliable due to TRIMA's smoothness eliminating false signals
- Excellent long-term reversal indicator

**Bearish Divergence:**
- Price makes higher highs while TRIMA makes lower highs or stays flat
- Indicates major trend exhaustion to the upside
- Signals potential long-term top formation
- Best used for position exits rather than short entries

## Best Practices

### Optimal Use Cases

When TRIMA works best:
- **Long-term position trading**: Ideal timeframe for TRIMA's characteristics
- **Trend confirmation**: Excellent filter for faster indicator signals
- **Major trend identification**: Clear identification of primary market direction
- **Low-frequency trading**: Best for traders who make few, high-conviction trades

### Combining with Other Indicators

Recommended indicator combinations:

**With Trend Indicators:**
- Use faster MA (EMA 20) for entries while TRIMA confirms overall trend
- Combine with ADX to confirm trend strength when TRIMA shows direction

**With Volume Indicators:**
- Confirm TRIMA crossovers with volume analysis for major trend changes
- Use volume to time entries within TRIMA-confirmed trends

**With Other Oscillators:**
- Use RSI for entry timing within TRIMA trends
- Use MACD for earlier trend change warnings while TRIMA confirms
- Stochastic helps identify pullback entry points in TRIMA trends

### Common Pitfalls

What to avoid:

1. **Using for Timing**: TRIMA is too slow for entry/exit timing
2. **Day Trading**: TRIMA lag makes it unsuitable for short-term trading
3. **Expecting Quick Signals**: TRIMA signals are infrequent but significant
4. **Over-trading**: Wait for clear TRIMA signals; fewer trades, higher quality

### Parameter Selection Guidelines

How to choose optimal parameters:

- **Short-term trading**: Not recommended; use faster MAs instead
- **Medium-term trading** (swing): 20-30 period TRIMA as trend filter only
- **Long-term trading** (position): 30-50 period TRIMA for primary trend
- **Backtesting**: Test on historical data; optimize for trend filtering, not entries

## Practical Example

Complete trading example with context:

```ruby
require 'sqa/tai'

# Load historical price data
prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41,
          46.22, 45.64, 46.21, 46.25, 46.08, 46.46,
          46.82, 47.00, 47.32, 47.20, 47.57, 47.80,
          48.00, 48.15, 48.30, 48.40, 48.55, 48.70,
          48.85, 49.00, 49.15, 49.30, 49.45, 49.60]

# Calculate TRIMA for trend filter
trima = SQA::TAI.trima(prices, period: 30)

# Calculate faster EMA for entries
ema_fast = SQA::TAI.ema(prices, period: 10)

# Analysis logic
current_price = prices.last
current_trima = trima.last
current_ema = ema_fast.last

# Check TRIMA trend direction
trima_slope = current_trima - trima[-5]
trend = if trima_slope > 0
  "UPTREND"
elsif trima_slope < 0
  "DOWNTREND"
else
  "NEUTRAL"
end

puts "Major Trend (TRIMA): #{trend}"
puts "TRIMA Value: #{current_trima.round(2)}"

# Trading logic based on TRIMA trend
if trend == "UPTREND"
  # Look for pullback entries in uptrend
  if current_price < current_ema && current_price > current_trima
    puts "BUY Setup: Pullback in uptrend"
    puts "Price between EMA and TRIMA - good entry zone"
    puts "Entry: Near #{current_ema.round(2)}"
    puts "Stop: Below #{current_trima.round(2)}"
  elsif current_price > current_ema
    puts "Uptrend in Progress"
    puts "Hold long positions, wait for pullback to add"
  elsif current_price < current_trima
    puts "WARNING: Price below TRIMA in uptrend"
    puts "Consider tightening stops"
  end

elsif trend == "DOWNTREND"
  puts "Downtrend in Progress - AVOID LONGS"
  if current_price > current_ema
    puts "Rally to resistance (EMA) - potential short entry"
    puts "Or wait for trend reversal above TRIMA"
  end

else
  puts "No Clear Trend - Wait for TRIMA direction"
  puts "Current Price: #{current_price.round(2)}"
  puts "Distance from TRIMA: #{((current_price - current_trima) / current_trima * 100).round(2)}%"
end

# Check for major trend reversal
prev_price_position = prices[-2] > trima[-2]
current_price_position = current_price > current_trima

if !prev_price_position && current_price_position
  puts "\n*** MAJOR TREND REVERSAL: Bullish ***"
  puts "Price crossed above TRIMA - major uptrend beginning"
elsif prev_price_position && !current_price_position
  puts "\n*** MAJOR TREND REVERSAL: Bearish ***"
  puts "Price crossed below TRIMA - major downtrend beginning"
end
```

## Related Indicators

### Similar Indicators
- **[SMA](sma.md)**: Single smoothing, less smooth than TRIMA
- **[EMA](ema.md)**: Exponential weighting, much more responsive
- **[DEMA](dema.md)**: Double exponential, opposite philosophy (speed vs smoothness)

### Complementary Indicators
- **[EMA](ema.md)**: Use for entries while TRIMA confirms trend
- **[ADX](../momentum/adx.md)**: Confirms trend strength when TRIMA shows direction
- **[RSI](../momentum/rsi.md)**: Times entries within TRIMA trends
- **[ATR](../volatility/atr.md)**: Sets stop-loss distances in TRIMA trends

### Indicator Family

TRIMA belongs to the moving average family with unique characteristics:
- **SMA**: Equal weighting of all periods
- **WMA**: Linear weighting favoring recent prices
- **TRIMA**: Triangular weighting favoring middle prices (smoothest)
- Use TRIMA when smoothness and noise reduction are paramount

## Advanced Topics

### Multi-Timeframe Analysis

Use TRIMA across multiple timeframes:
- Weekly/Monthly TRIMA for primary market direction
- Daily TRIMA for intermediate trend
- Use faster indicators on lower timeframes for entries
- Only trade in direction of TRIMA on higher timeframe

### Market Regime Adaptation

TRIMA performance in different market conditions:
- **Strong trends**: TRIMA excels at identifying and confirming
- **Ranging markets**: TRIMA stays flat, signaling no trend (very useful)
- **Volatile markets**: TRIMA smooths volatility, shows underlying trend
- **Quiet markets**: TRIMA may be too slow; consider faster indicators

### Statistical Validation

TRIMA reliability metrics:
- Very high reliability for trend identification (80-90% accuracy)
- Low false signal rate due to extreme smoothing
- Late entry signals but excellent trend confirmation
- Best used as filter, not standalone trading system

## References

- Kaufman, Perry J. "Trading Systems and Methods"
- Murphy, John J. "Technical Analysis of the Financial Markets"
- Pring, Martin J. "Technical Analysis Explained"

## See Also

- [Overlap Studies Overview](../index.md)
- [SMA Documentation](sma.md)
- [WMA Documentation](wma.md)
- [Moving Average Comparison](ma.md)
