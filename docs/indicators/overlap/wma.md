# WMA (Weighted Moving Average)

## Overview

The Weighted Moving Average (WMA) is a technical indicator that applies linear weighting to price data, giving progressively more importance to recent prices while still considering historical data. Developed to address the limitations of the Simple Moving Average's equal weighting, WMA provides a middle ground between the simplicity of SMA and the exponential nature of EMA, making it valuable for traders seeking balanced responsiveness in trend identification.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `input_data` | Array | Required | The price data array (typically close prices) |
| `period` | Integer | 30 | Number of periods for WMA calculation |

### Parameter Details

**input_data**
- Typically uses closing prices for standard trend analysis
- Can use other price types (high, low, typical price) for specialized applications
- Requires at least `period` number of data points for calculation
- More historical data provides better context for trend analysis

**period** (time_period)
- Default is 30 periods, providing good balance of smoothness and responsiveness
- Common periods and their uses:
  - 10-20 periods: Short-term trading, active trend following
  - 20-30 periods: Medium-term trends, standard analysis
  - 50+ periods: Long-term trend identification
- Shorter periods increase responsiveness but generate more signals
- Longer periods provide smoother trends with less noise
- Recommended ranges:
  - Day trading: 10-20 periods
  - Swing trading: 20-30 periods
  - Position trading: 50-100 periods

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41]

# Calculate 10-period WMA
wma = SQA::TAI.wma(prices, period: 10)

puts "Current WMA: #{wma.last.round(2)}"
```

### With Custom Parameters

```ruby
# Calculate 20-period WMA for swing trading
wma_20 = SQA::TAI.wma(prices, period: 20)

# Calculate 50-period WMA for position trading
wma_50 = SQA::TAI.wma(prices, period: 50)

puts "Short-term WMA (20): #{wma_20.last.round(2)}"
puts "Standard WMA (30): #{SQA::TAI.wma(prices).last.round(2)}"
puts "Long-term WMA (50): #{wma_50.last.round(2)}"
```

## Understanding the Indicator

### What It Measures

The WMA measures trend direction with linear weighting:

- **Trend Direction**: Identifies market trends by weighting recent prices more heavily
- **Momentum**: The slope and position indicate trend strength and direction
- **Dynamic Support/Resistance**: Acts as support in uptrends, resistance in downtrends
- **Balanced Response**: More responsive than SMA, smoother than EMA

WMA solves the dilemma between SMA's lag and EMA's potential over-sensitivity by applying a linear weighting scheme that gradually increases weight on more recent prices.

### Calculation Method

The WMA uses linear weighting where recent prices have progressively more weight:

1. **Assign Weights**: Most recent price gets weight of n, previous gets n-1, etc.
2. **Multiply Prices by Weights**: Each price is multiplied by its weight
3. **Sum Weighted Prices**: Add all weighted prices together
4. **Divide by Weight Sum**: Divide by sum of weights (n × (n+1) / 2)

**Formula:**
```
WMA = (P1 × n + P2 × (n-1) + P3 × (n-2) + ... + Pn × 1) / (n × (n+1) / 2)

Where:
P1 = Most recent price (weight = n)
P2 = Previous price (weight = n-1)
Pn = Oldest price (weight = 1)
n = Period

Example for 5-period WMA:
Prices: [10, 11, 12, 11, 10] (oldest to newest)
Weights: [1, 2, 3, 4, 5]
WMA = (10×1 + 11×2 + 12×3 + 11×4 + 10×5) / (1+2+3+4+5)
    = (10 + 22 + 36 + 44 + 50) / 15
    = 162 / 15 = 10.8
```

### Indicator Characteristics

- **Range**: Unbounded (follows price range)
- **Type**: Overlay indicator (plotted on price chart)
- **Lag**: Medium lag, between SMA and EMA
- **Best Used**: Trending markets, balanced trend following, crossover systems

## Interpretation

### Value Ranges

The WMA's value follows the price range:

- **WMA Rising**: Indicates upward momentum and bullish trend
- **WMA Falling**: Indicates downward momentum and bearish trend
- **WMA Flat**: Suggests consolidation or range-bound market

### Key Levels

- **Price Above WMA**: Bullish condition, uptrend in progress
- **Price Below WMA**: Bearish condition, downtrend in progress
- **Price Crossing WMA**: Potential trend change signal
- **Distance from WMA**: Extreme distances may indicate overbought/oversold

### Signal Interpretation

How to read the WMA's signals:

1. **Trend Direction**
   - Price consistently above rising WMA = uptrend
   - Price consistently below falling WMA = downtrend
   - Price oscillating around WMA = no clear trend

2. **Momentum Changes**
   - WMA slope steepening = accelerating momentum
   - WMA slope flattening = decelerating momentum
   - WMA slope change = potential trend change

3. **Reversal Signals**
   - Price crosses below WMA = potential reversal to downtrend
   - Price crosses above WMA = potential reversal to uptrend
   - Confirm with volume and other indicators

## Trading Signals

### Buy Signals

Specific conditions that generate buy signals:

1. **Primary Signal**: Price crosses above WMA while WMA is rising
2. **Confirmation Signal**: Increasing volume on the crossover
3. **Entry Criteria**: Close above WMA, WMA sloping upward

**Example Scenario:**
```
When price closes above WMA and WMA has been rising for 2-3 periods,
consider a long position with stop loss 2-3% below WMA.
Target the next resistance level or use a trailing stop.
```

### Sell Signals

Specific conditions that generate sell signals:

1. **Primary Signal**: Price crosses below WMA while WMA is falling
2. **Confirmation Signal**: Increasing volume on the crossover
3. **Exit Criteria**: Close below WMA, WMA sloping downward

**Example Scenario:**
```
When price closes below WMA and WMA has been falling for 2-3 periods,
consider exiting long positions or entering short with stop loss 2-3% above WMA.
```

### Divergence Analysis

**Bullish Divergence:**
- Price makes lower lows while WMA makes higher lows
- Indicates weakening downward momentum
- Often precedes trend reversal to the upside
- More reliable when confirmed with RSI or MACD

**Bearish Divergence:**
- Price makes higher highs while WMA makes lower highs
- Indicates weakening upward momentum
- Often precedes trend reversal to the downside
- Best used at resistance levels

## Best Practices

### Optimal Use Cases

When WMA works best:
- **Balanced trend following**: When you want more response than SMA but less sensitivity than EMA
- **All timeframes**: Effective on intraday, daily, and weekly charts
- **Liquid markets**: Works best in stocks, forex, major cryptocurrencies
- **Crossover systems**: Excellent for dual moving average strategies

### Combining with Other Indicators

Recommended indicator combinations:

**With Trend Indicators:**
- Use ADX to confirm trend strength before following WMA signals
- Combine with longer SMA for multi-timeframe confirmation

**With Volume Indicators:**
- Confirm WMA crossovers with volume spikes
- Use OBV to validate WMA trend direction

**With Other Oscillators:**
- Use RSI for overbought/oversold identification
- Combine with MACD for momentum confirmation
- Stochastic for precise entry timing

### Common Pitfalls

What to avoid:

1. **Comparing Directly to SMA/EMA**: WMA produces different values; don't expect same results
2. **Over-optimization**: Don't curve-fit period selection to historical data
3. **Ignoring Context**: Consider market conditions and multiple timeframes
4. **Using Alone**: WMA works best as part of a complete trading system

### Parameter Selection Guidelines

How to choose optimal parameters:

- **Short-term trading** (day trading): 10-20 period WMA for active signals
- **Medium-term trading** (swing trading): 20-30 period WMA for balanced approach
- **Long-term trading** (position trading): 50-100 period WMA for major trends
- **Backtesting**: Test on historical data to find optimal period for your instrument

## Practical Example

Complete trading example with context:

```ruby
require 'sqa/tai'

# Load historical price data
prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41,
          46.22, 45.64, 46.21, 46.25, 46.08, 46.46,
          46.82, 47.00, 47.32, 47.20, 47.57, 47.80,
          48.00, 48.15, 48.30, 48.40, 48.55, 48.70]

# Calculate WMA for crossover strategy
wma_20 = SQA::TAI.wma(prices, period: 20)
wma_50 = SQA::TAI.wma(prices, period: 50)

# Compare with SMA and EMA
sma_20 = SQA::TAI.sma(prices, period: 20)
ema_20 = SQA::TAI.ema(prices, period: 20)

# Analysis logic
current_price = prices.last
current_wma = wma_20.last
current_sma = sma_20.last
current_ema = ema_20.last

prev_wma_20 = wma_20[-2]
prev_wma_50 = wma_50[-2]
current_wma_50 = wma_50.last

puts "Current Price: #{current_price.round(2)}"
puts "WMA-20: #{current_wma.round(2)}"
puts "SMA-20: #{current_sma.round(2)}"
puts "EMA-20: #{current_ema.round(2)}"
puts ""

# WMA typically falls between SMA and EMA
puts "MA Comparison (showing WMA's balanced nature):"
puts "SMA (slowest): #{current_sma.round(2)}"
puts "WMA (balanced): #{current_wma.round(2)}"
puts "EMA (fastest): #{current_ema.round(2)}"
puts ""

# Check for golden cross/death cross
if prev_wma_20 <= prev_wma_50 && current_wma >= current_wma_50
  puts "GOLDEN CROSS: WMA-20 crossed above WMA-50"
  puts "Bullish trend signal"
  puts "Entry: #{current_price.round(2)}"
  puts "Stop Loss: #{(current_wma_50 * 0.97).round(2)}"

elsif prev_wma_20 >= prev_wma_50 && current_wma <= current_wma_50
  puts "DEATH CROSS: WMA-20 crossed below WMA-50"
  puts "Bearish trend signal"
  puts "Exit longs or consider shorts"

# Price position relative to WMA
elsif current_price > current_wma && current_wma > current_wma_50
  puts "Uptrend: Price > WMA-20 > WMA-50"
  puts "Hold long positions"

elsif current_price < current_wma && current_wma < current_wma_50
  puts "Downtrend: Price < WMA-20 < WMA-50"
  puts "Avoid longs, stay in cash or short"
end
```

## Related Indicators

### Similar Indicators
- **[SMA](sma.md)**: Equal weighting, slower response
- **[EMA](ema.md)**: Exponential weighting, faster response
- **[DEMA](dema.md)**: Double exponential, very low lag

### Complementary Indicators
- **[ADX](../momentum/adx.md)**: Confirms trend strength for WMA signals
- **[RSI](../momentum/rsi.md)**: Identifies overbought/oversold for better entries
- **[MACD](../momentum/macd.md)**: Momentum confirmation for WMA crossovers
- **[Volume](../volume/obv.md)**: Confirms trend changes with WMA

### Indicator Family

WMA belongs to the moving average family:
- **SMA**: Equal weighting (most lag)
- **WMA**: Linear weighting (balanced)
- **EMA**: Exponential weighting (least lag)
- Use WMA when you want balance between smoothness and responsiveness

## Advanced Topics

### Multi-Timeframe Analysis

Use WMA across multiple timeframes:
- Daily WMA for overall trend direction
- 4-hour WMA for intermediate entries
- 1-hour WMA for precise timing
- Trade when all timeframes align

### Market Regime Adaptation

Adjust WMA parameters based on market volatility:
- High volatility: Use longer periods (30-50) to reduce noise
- Low volatility: Use shorter periods (15-25) for better responsiveness
- Calculate ATR to measure volatility and adapt

### Statistical Validation

WMA reliability metrics:
- Reliable in trending markets (ADX > 25)
- False signal rate increases in ranging markets
- Crossover signals have 65-75% success rate in trends
- Combine with volume for 75-85% accuracy

## References

- Murphy, John J. "Technical Analysis of the Financial Markets"
- Pring, Martin J. "Technical Analysis Explained"
- Achelis, Steven B. "Technical Analysis from A to Z"

## See Also

- [Overlap Studies Overview](../index.md)
- [SMA Documentation](sma.md)
- [EMA Documentation](ema.md)
- [Moving Average Comparison](ma.md)
