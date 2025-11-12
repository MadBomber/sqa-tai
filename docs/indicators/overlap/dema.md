# DEMA (Double Exponential Moving Average)

## Overview

The Double Exponential Moving Average (DEMA) is an advanced technical indicator designed to reduce the inherent lag in traditional moving averages. Developed by Patrick Mulloy in 1994, DEMA uses a composite calculation involving two exponential moving averages to provide a smoother, more responsive trend-following indicator that closely tracks price movements while filtering out noise.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `input_data` | Array | Required | The price data array (typically close prices) |
| `period` | Integer | 30 | Number of periods for DEMA calculation |

### Parameter Details


**Note**: Array elements should be ordered from oldest to newest (chronological order)

**input_data**
- Typically uses closing prices for standard trend analysis
- Can use other price types (high, low, typical price) for specialized applications
- Requires sufficient data points: approximately `period * 2` for stable calculations
- More historical data improves the indicator's reliability and smoothness

**period** (time_period)
- Default is 30 periods, providing a balance of smoothness and responsiveness
- Common periods and their uses:
  - 9-12 periods: Short-term trading, high responsiveness
  - 20-30 periods: Medium-term trends, standard analysis
  - 50+ periods: Long-term trend identification
- Shorter periods increase sensitivity but may generate more false signals
- Longer periods provide smoother trends but with slightly more lag
- Recommended ranges:
  - Day trading: 9-15 periods
  - Swing trading: 20-30 periods
  - Position trading: 50-100 periods

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

# Calculate 30-period DEMA (default)
dema = SQA::TAI.dema(prices)

puts "Current DEMA: #{dema.last.round(2)}"
```

### With Custom Parameters

```ruby
# Calculate 10-period DEMA for more responsiveness
dema_10 = SQA::TAI.dema(prices, period: 10)

# Calculate 50-period DEMA for longer-term trends
dema_50 = SQA::TAI.dema(prices, period: 50)

puts "Short-term DEMA (10): #{dema_10.last.round(2)}"
puts "Standard DEMA (30): #{dema.last.round(2)}"
puts "Long-term DEMA (50): #{dema_50.last.round(2)}"
```

## Understanding the Indicator

### What It Measures

The DEMA measures trend direction with reduced lag:

- **Trend Direction**: Identifies the current market trend by smoothing price data
- **Momentum**: The slope and position of DEMA relative to price indicate momentum strength
- **Dynamic Support/Resistance**: Acts as a moving support level in uptrends and resistance in downtrends
- **Lag Reduction**: Responds faster to price changes than traditional moving averages

DEMA solves the fundamental problem of traditional moving averages: they lag behind price action. By using a double exponential calculation, DEMA maintains smoothness while reducing this lag significantly.

### Calculation Method

The DEMA uses a unique double calculation process:

1. **Calculate First EMA**: Apply exponential moving average to prices
2. **Calculate Second EMA**: Apply EMA to the first EMA result
3. **Apply DEMA Formula**: Subtract the double-smoothed value from twice the first EMA
4. **Result**: A responsive moving average with reduced lag

**Formula:**
```
EMA1 = EMA(prices, period)
EMA2 = EMA(EMA1, period)
DEMA = (2 × EMA1) - EMA2

Where:
- EMA1 is the first exponential moving average of prices
- EMA2 is the exponential moving average of EMA1
- The subtraction removes excess smoothing, reducing lag
- Multiplying EMA1 by 2 compensates for the removed smoothing
```

### Indicator Characteristics

- **Range**: Unbounded (follows price range)
- **Type**: Overlay indicator (plotted on price chart)
- **Lag**: Low lag, more responsive than SMA and EMA
- **Best Used**: Trending markets, trend following strategies, crossover systems

## Interpretation

### Value Ranges

The DEMA's value is always close to the price range:

- **DEMA Rising**: Indicates upward momentum and bullish trend
- **DEMA Falling**: Indicates downward momentum and bearish trend
- **DEMA Flat**: Suggests consolidation or range-bound market

### Key Levels

- **Price Above DEMA**: Bullish condition, uptrend in progress
- **Price Below DEMA**: Bearish condition, downtrend in progress
- **Price Crossing DEMA**: Potential trend change signal
- **Distance from DEMA**: Extreme distances may indicate overbought/oversold conditions

### Signal Interpretation

How to read the DEMA's signals:

1. **Trend Direction**
   - Price consistently above rising DEMA = strong uptrend
   - Price consistently below falling DEMA = strong downtrend
   - Price oscillating around flat DEMA = no clear trend

2. **Momentum Changes**
   - DEMA slope steepening = accelerating momentum
   - DEMA slope flattening = decelerating momentum
   - DEMA slope change = potential trend change

3. **Reversal Signals**
   - Price crosses below DEMA from above = potential reversal to downtrend
   - Price crosses above DEMA from below = potential reversal to uptrend
   - Confirm with volume and other indicators

## Trading Signals

### Buy Signals

Specific conditions that generate buy signals:

1. **Primary Signal**: Price crosses above DEMA while DEMA is rising
2. **Confirmation Signal**: Increasing volume on the crossover
3. **Entry Criteria**: Close above DEMA, DEMA sloping upward

**Example Scenario:**
```
When price closes above DEMA and DEMA has been rising for 3+ periods,
consider a long position with stop loss 2-3% below DEMA.
Target the next resistance level or use a trailing stop.
```

### Sell Signals

Specific conditions that generate sell signals:

1. **Primary Signal**: Price crosses below DEMA while DEMA is falling
2. **Confirmation Signal**: Increasing volume on the crossover
3. **Exit Criteria**: Close below DEMA, DEMA sloping downward

**Example Scenario:**
```
When price closes below DEMA and DEMA has been falling for 3+ periods,
consider exiting long positions or entering short with stop loss 2-3% above DEMA.
```

### Divergence Analysis

**Bullish Divergence:**
- Price makes lower lows while DEMA makes higher lows
- Indicates weakening downward momentum
- Often precedes trend reversal to the upside
- More reliable when confirmed with RSI or MACD divergence

**Bearish Divergence:**
- Price makes higher highs while DEMA makes lower highs
- Indicates weakening upward momentum
- Often precedes trend reversal to the downside
- More reliable in overbought conditions

## Best Practices

### Optimal Use Cases

When DEMA works best:
- **Trending markets**: DEMA excels when clear trends are present
- **All timeframes**: Equally effective on intraday, daily, and weekly charts
- **Liquid markets**: Works best in stocks, forex, and major cryptocurrencies
- **Momentum trading**: Ideal for catching and riding strong trends

### Combining with Other Indicators

Recommended indicator combinations:

**With Trend Indicators:**
- Use ADX to confirm trend strength before following DEMA signals
- Combine with longer-period SMA for multi-timeframe trend confirmation

**With Volume Indicators:**
- Confirm DEMA crossovers with volume spikes for higher probability trades
- Use OBV to validate DEMA trend direction

**With Other Oscillators:**
- Use RSI to identify overbought/oversold conditions for better entries
- Combine with MACD for momentum confirmation

### Common Pitfalls

What to avoid:

1. **Over-reliance**: DEMA alone can generate false signals in choppy markets
2. **False Signals**: Ranging markets produce whipsaws; use ADX to filter
3. **Parameter Optimization**: Avoid curve-fitting to historical data
4. **Ignoring Context**: Consider market conditions and multiple timeframes

### Parameter Selection Guidelines

How to choose optimal parameters:

- **Short-term trading** (day trading): 9-15 period DEMA for quick signals
- **Medium-term trading** (swing trading): 20-30 period DEMA for balanced approach
- **Long-term trading** (position trading): 50-100 period DEMA for major trends
- **Backtesting**: Test on historical data to find optimal period for your instrument and timeframe

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
          48.85, 49.00]

# Calculate DEMA for crossover strategy
dema_short = SQA::TAI.dema(prices, period: 10)
dema_long = SQA::TAI.dema(prices, period: 30)

# Analysis logic
current_price = prices.last
short_dema = dema_short.last
long_dema = dema_long.last

prev_short = dema_short[-2]
prev_long = dema_long[-2]

# Check for golden cross (bullish)
if prev_short <= prev_long && short_dema > long_dema
  puts "BUY Signal: DEMA Golden Cross"
  puts "Short DEMA crossed above Long DEMA"
  puts "Entry: #{current_price.round(2)}"
  puts "Stop Loss: #{(long_dema * 0.97).round(2)}"
  puts "Target: #{(current_price * 1.05).round(2)}"

# Check for death cross (bearish)
elsif prev_short >= prev_long && short_dema < long_dema
  puts "SELL Signal: DEMA Death Cross"
  puts "Short DEMA crossed below Long DEMA"
  puts "Exit Long Positions"
  puts "Stop Loss: #{(long_dema * 1.03).round(2)}"

# Check price position relative to DEMA
elsif current_price > short_dema && short_dema > long_dema
  puts "Strong Uptrend: Hold long positions"
  puts "Price: #{current_price.round(2)}"
  puts "Short DEMA: #{short_dema.round(2)}"
  puts "Long DEMA: #{long_dema.round(2)}"

elsif current_price < short_dema && short_dema < long_dema
  puts "Strong Downtrend: Avoid longs"
  puts "Consider shorts or stay in cash"
end
```

## Related Indicators

### Similar Indicators
- **[EMA](ema.md)**: Single exponential moving average, simpler but more lag
- **[TEMA](tema.md)**: Triple exponential MA, even less lag than DEMA
- **[T3](t3.md)**: Tillson T3, smoother with customizable lag

### Complementary Indicators
- **[ADX](../momentum/adx.md)**: Confirms trend strength for DEMA signals
- **[RSI](../momentum/rsi.md)**: Identifies overbought/oversold for better entries
- **[MACD](../momentum/macd.md)**: Momentum confirmation for DEMA crossovers

### Indicator Family

DEMA belongs to the exponential moving average family:
- **SMA**: Base moving average with equal weighting
- **EMA**: Exponential weighting, reduced lag from SMA
- **DEMA**: Double calculation, further reduced lag
- **TEMA**: Triple calculation, minimal lag
- Use DEMA when you need responsiveness but still want smoothness

## Advanced Topics

### Multi-Timeframe Analysis

Use DEMA across multiple timeframes for comprehensive analysis:
- Daily DEMA for overall trend direction
- 4-hour DEMA for intermediate entries
- 1-hour DEMA for precise timing
- Only take trades when all timeframes align

### Market Regime Adaptation

Adjust DEMA parameters based on market volatility:
- High volatility: Use longer periods (30-50) to reduce noise
- Low volatility: Use shorter periods (10-20) for better responsiveness
- Calculate ATR to measure volatility and adapt accordingly

### Statistical Validation

DEMA reliability metrics:
- More reliable in trending markets (ADX > 25)
- False signal rate increases in ranging markets
- Crossover signals have 60-70% success rate in strong trends
- Combine with volume analysis to improve accuracy to 70-80%

## References

- Mulloy, Patrick (1994). "Smoothing Data with Faster Moving Averages". Technical Analysis of Stocks & Commodities magazine
- Murphy, John J. "Technical Analysis of the Financial Markets"
- Pring, Martin J. "Technical Analysis Explained"

## See Also

- [Overlap Studies Overview](../index.md)
- [EMA Documentation](ema.md)
- [TEMA Documentation](tema.md)
- [Moving Average Comparison](ma.md)
