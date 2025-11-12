# KAMA (Kaufman Adaptive Moving Average)

## Overview

The Kaufman Adaptive Moving Average (KAMA) is a sophisticated adaptive moving average developed by Perry Kaufman that automatically adjusts its smoothing constant based on market efficiency and volatility. KAMA becomes faster and more responsive in trending markets while slowing down in choppy, range-bound markets to reduce whipsaws. This intelligent adaptation makes KAMA one of the most advanced trend-following indicators available.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `input_data` | Array | Required | The price data array (typically close prices) |
| `period` | Integer | 30 | Number of periods for efficiency ratio calculation |

### Parameter Details

**input_data**
- Typically uses closing prices for standard trend analysis
- Can use other price types for specialized applications
- Requires sufficient data points for stable efficiency ratio calculations
- More historical data improves adaptation reliability

**period** (time_period)
- Default is 30 periods for balanced adaptation
- Common periods:
  - 10 periods: Short-term, highly adaptive
  - 20 periods: Standard intraday and swing trading
  - 30 periods: Medium-term position trading (default)
  - 50+ periods: Long-term trend identification
- Shorter periods increase adaptation frequency
- Longer periods provide smoother, less reactive trends

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41,
          46.22, 45.64, 46.21, 46.25, 46.08, 46.46,
          46.82, 47.00, 47.32, 47.20, 47.57, 47.80,
          48.00, 48.15, 48.30, 48.40, 48.55, 48.70,
          48.85, 49.00, 49.15, 49.30]

# Calculate 30-period KAMA (default)
kama = SQA::TAI.kama(prices)

puts "Current KAMA: #{kama.last.round(2)}"
```

### With Custom Parameters

```ruby
# Calculate 10-period KAMA for shorter-term adaptation
kama_10 = SQA::TAI.kama(prices, period: 10)

# Calculate 50-period KAMA for long-term trends
kama_50 = SQA::TAI.kama(prices, period: 50)

puts "Short-term KAMA (10): #{kama_10.last.round(2)}"
puts "Standard KAMA (30): #{kama.last.round(2)}"
puts "Long-term KAMA (50): #{kama_50.last.round(2)}"
```

## Understanding the Indicator

### What It Measures

KAMA measures trend direction with intelligent adaptation:

- **Adaptive Trend Direction**: Automatically adjusts responsiveness based on market conditions
- **Market Efficiency**: Measures directional movement versus noise
- **Dynamic Smoothing**: Fast in trends, slow in ranges
- **Whipsaw Reduction**: Minimizes false signals in choppy markets

KAMA solves the fundamental problem of fixed-parameter moving averages: they cannot adapt to changing market conditions. KAMA's efficiency ratio allows it to be responsive when needed and smooth when volatility is high.

### Calculation Method

KAMA uses the Efficiency Ratio (ER) to adapt its smoothing:

1. **Calculate Change**: Net price change over period
2. **Calculate Volatility**: Sum of absolute price changes
3. **Calculate Efficiency Ratio**: Change / Volatility
4. **Calculate Smoothing Constant**: Scale ER between fast and slow constants
5. **Apply Adaptive Smoothing**: Use SC to calculate KAMA

## Formula

KAMA adapts its smoothing factor based on the Efficiency Ratio (ER):

1. Calculate Efficiency Ratio: ER = Change / Volatility
2. Calculate Smoothing Constant: SC = (ER * (Fast - Slow) + Slow)²
3. Apply: KAMA = KAMA_prev + SC * (Price - KAMA_prev)

Where Fast and Slow are the fastest and slowest smoothing constants.

### Indicator Characteristics

- **Range**: Unbounded (follows price range)
- **Type**: Overlay indicator (plotted on price chart)
- **Lag**: Adaptive (low in trends, medium in ranges)
- **Best Used**: All market conditions, adaptive trend following

## Interpretation

### Value Ranges

KAMA's value adapts to market conditions:

- **KAMA Rising**: Indicates uptrend
- **KAMA Falling**: Indicates downtrend
- **KAMA Flat**: Ranging market detected, reduced sensitivity

### Key Levels

- **Price Above KAMA**: Bullish condition
- **Price Below KAMA**: Bearish condition
- **Price Crossing KAMA**: Trend change (quality depends on efficiency)
- **KAMA Slope**: Indicates trend strength and market efficiency

### Signal Interpretation

1. **Trend Direction**
   - Price above rising KAMA = strong uptrend
   - Price below falling KAMA = strong downtrend
   - KAMA flat = low efficiency, avoid trend-following

2. **Momentum Changes**
   - KAMA steepening = increasing efficiency, strong trend
   - KAMA flattening = decreasing efficiency, weakening trend
   - KAMA adaptation = market regime change

3. **Reversal Signals**
   - Price crosses with high efficiency = strong signal
   - Price crosses with low efficiency = weak signal, likely whipsaw
   - Confirm with other indicators

## Trading Signals

### Buy Signals

Specific conditions that generate buy signals:

1. **Primary Signal**: Price crosses above KAMA while efficiency is increasing
2. **Confirmation Signal**: KAMA slope turning upward
3. **Entry Criteria**: Wait for pullback to KAMA in uptrend

**Example Scenario:**
```
When price crosses above KAMA and market efficiency is high (trending),
enter long with stop loss 2-3% below KAMA.
KAMA's adaptation means tighter stops in volatile markets.
```

### Sell Signals

Specific conditions that generate sell signals:

1. **Primary Signal**: Price crosses below KAMA while efficiency is decreasing
2. **Confirmation Signal**: KAMA slope turning downward
3. **Exit Criteria**: Exit when KAMA flattens (low efficiency detected)

**Example Scenario:**
```
When price crosses below KAMA or KAMA flattens significantly,
exit long positions. KAMA's flattening indicates ranging market ahead.
```

## Returns

Returns an array of KAMA values. The first several values will be `nil` due to the calculation requiring sufficient data points.

## Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41,
          46.22, 45.64, 46.21, 46.25, 46.08, 46.46,
          46.82, 47.00, 47.32, 47.20, 47.57, 47.80,
          48.00, 48.15, 48.30, 48.40, 48.55, 48.70,
          48.85, 49.00, 49.15, 49.30]

# Calculate 30-period KAMA (default)
kama = SQA::TAI.kama(prices)

# Calculate 10-period KAMA for shorter-term adaptation
kama_10 = SQA::TAI.kama(prices, period: 10)

puts "Current KAMA: #{kama.last.round(2)}"
```

## Interpretation

KAMA's adaptive nature makes it unique among moving averages:

- **Trending Markets**: KAMA hugs price closely, providing timely signals
- **Choppy Markets**: KAMA flattens out, avoiding whipsaws
- **Price crosses above KAMA**: Potential buy signal
- **Price crosses below KAMA**: Potential sell signal
- **KAMA slope**: Indicates trend strength

## Example: KAMA Trend Following

```ruby
prices = load_historical_prices('AAPL')
kama = SQA::TAI.kama(prices, period: 20)

current_price = prices.last
current_kama = kama.last
previous_kama = kama[-2]

# Check KAMA direction
kama_rising = current_kama > previous_kama
kama_falling = current_kama < previous_kama

# Check price position
price_above = current_price > current_kama
price_below = current_price < current_kama

if kama_rising && price_above
  puts "STRONG UPTREND - KAMA rising, price above"
elsif kama_falling && price_below
  puts "STRONG DOWNTREND - KAMA falling, price below"
elsif kama_rising && price_below
  puts "Pullback in uptrend - potential buy opportunity"
elsif kama_falling && price_above
  puts "Rally in downtrend - potential sell opportunity"
end
```

## Example: KAMA Crossover System

```ruby
prices = load_historical_prices('SPY')
kama = SQA::TAI.kama(prices, period: 20)

# Check for price crossing KAMA
price_current = prices.last
price_previous = prices[-2]
kama_current = kama.last
kama_previous = kama[-2]

# Bullish crossover
if price_previous <= kama_previous && price_current > kama_current
  puts "BULLISH CROSSOVER - Price crossed above KAMA"
  puts "Entry signal: BUY"
# Bearish crossover
elsif price_previous >= kama_previous && price_current < kama_current
  puts "BEARISH CROSSOVER - Price crossed below KAMA"
  puts "Exit/Short signal: SELL"
end
```

## Example: KAMA with Efficiency Ratio

```ruby
prices = load_historical_prices('TSLA')
kama = SQA::TAI.kama(prices, period: 20)

# Calculate simple efficiency proxy (price range vs total movement)
period = 20
price_change = (prices.last - prices[-period]).abs
total_movement = 0
(1...period).each do |i|
  total_movement += (prices[-i] - prices[-(i+1)]).abs
end

efficiency = total_movement > 0 ? price_change / total_movement : 0

puts "Market Efficiency: #{(efficiency * 100).round(2)}%"

if efficiency > 0.5
  puts "HIGH EFFICIENCY - Strong trending market"
  puts "KAMA will be more responsive"
elsif efficiency < 0.2
  puts "LOW EFFICIENCY - Choppy market"
  puts "KAMA will be smoother, fewer signals"
else
  puts "MODERATE EFFICIENCY - Mixed market conditions"
end
```

## Example: Multi-Timeframe KAMA

```ruby
# Assuming different timeframe data
daily_prices = load_historical_prices('MSFT', timeframe: 'daily')
weekly_prices = load_historical_prices('MSFT', timeframe: 'weekly')

daily_kama = SQA::TAI.kama(daily_prices, period: 20)
weekly_kama = SQA::TAI.kama(weekly_prices, period: 20)

daily_price = daily_prices.last
weekly_price = weekly_prices.last

daily_trend = daily_price > daily_kama.last ? "UP" : "DOWN"
weekly_trend = weekly_price > weekly_kama.last ? "UP" : "DOWN"

puts "Daily trend: #{daily_trend}"
puts "Weekly trend: #{weekly_trend}"

if daily_trend == "UP" && weekly_trend == "UP"
  puts "ALIGNED UPTREND - Strongest bullish setup"
elsif daily_trend == "DOWN" && weekly_trend == "DOWN"
  puts "ALIGNED DOWNTREND - Strongest bearish setup"
else
  puts "CONFLICTING TRENDS - Wait for alignment"
end
```

## Advantages Over Traditional Moving Averages

1. **Adaptive**: Automatically adjusts to market conditions
2. **Reduced Whipsaws**: Slows down in choppy markets
3. **Timely in Trends**: Responds quickly in trending markets
4. **Self-Optimizing**: No need to constantly adjust parameters

## Common Settings

| Period | Use Case |
|--------|----------|
| 10 | Short-term, highly adaptive |
| 20 | Standard intraday and swing trading |
| 30 | Medium-term position trading (default) |
| 50+ | Long-term trend identification |

### Optimal Use Cases

When KAMA works best:
- **All market conditions**: KAMA adapts to both trending and ranging markets
- **Volatile markets**: Automatically adjusts to volatility changes
- **All timeframes**: Effective on all timeframes due to adaptive nature
- **Smart trend following**: Best for traders who want automatic adaptation

### Combining with Other Indicators

**With Trend Indicators:**
- Use ADX to measure trend strength alongside KAMA efficiency
- Combine with fixed MA to compare adaptive vs non-adaptive signals

**With Volume Indicators:**
- Confirm KAMA signals with volume for higher probability
- Use volume to validate efficiency ratio readings

**With Other Oscillators:**
- RSI helps identify overbought/oversold within KAMA trends
- MACD provides momentum confirmation for KAMA signals

### Common Pitfalls

What to avoid:

1. **Ignoring Efficiency**: Don't trade KAMA signals in low-efficiency markets
2. **Over-optimization**: Period affects efficiency calculation; don't over-optimize
3. **Expecting Constant Response**: KAMA changes speed; accept this variability
4. **Using Alone**: While adaptive, KAMA still benefits from confirmation

### Parameter Selection Guidelines

How to choose optimal parameters:

- **Short-term trading**: 10-20 period KAMA for frequent adaptation
- **Medium-term trading**: 20-30 period KAMA for balanced adaptation
- **Long-term trading**: 30-50 period KAMA for major trend identification
- **Backtesting**: Test period selection but remember KAMA auto-adapts

## Practical Example

See the comprehensive examples above demonstrating:
- KAMA trend following with efficiency analysis
- KAMA crossover systems
- Multi-timeframe KAMA alignment
- Efficiency ratio interpretation

## Advanced Topics

### Multi-Timeframe Analysis

Use KAMA across multiple timeframes:
- Higher timeframe KAMA for overall market direction
- Lower timeframe KAMA for entry timing
- Compare efficiency ratios across timeframes
- Only trade when efficiency is high on multiple timeframes

### Market Regime Adaptation

KAMA automatically adapts but understanding helps:
- High efficiency (>0.5): Strong trending, KAMA responsive
- Medium efficiency (0.2-0.5): Mixed conditions, KAMA balanced
- Low efficiency (<0.2): Ranging market, KAMA slow
- Monitor efficiency to understand KAMA behavior

### Statistical Validation

KAMA reliability metrics:
- Most reliable when efficiency ratio is high (>0.5)
- Reduces whipsaws by 30-50% vs fixed MAs in ranging markets
- Maintains trend-following effectiveness in trending markets
- Best combined with efficiency ratio analysis for signal quality

## References

- Kaufman, Perry J. "Trading Systems and Methods"
- Kaufman, Perry J. "New Trading Systems and Methods"
- Murphy, John J. "Technical Analysis of the Financial Markets"

## Best Practices

1. **Combine with Volume**: Confirm KAMA signals with volume
2. **Use Multiple Timeframes**: Check alignment across timeframes
3. **Wait for Confirmed Breaks**: Avoid false signals at KAMA touches
4. **Consider Market Regime**: KAMA works best in markets with clear trend/range cycles
5. **Monitor Efficiency**: Track efficiency ratio to understand KAMA's current mode

## Related Indicators

- [EMA](ema.md) - Exponential Moving Average
- [DEMA](dema.md) - Double Exponential Moving Average
- [TEMA](tema.md) - Triple Exponential Moving Average
- [T3](t3.md) - Tillson T3 Moving Average
- [MAMA](../volatility/mama.md) - MESA Adaptive Moving Average

## See Also

- [Back to Indicators](../index.md)
- [Overlap Studies Overview](../index.md)
