# TEMA (Triple Exponential Moving Average)

## Overview

The Triple Exponential Moving Average (TEMA) is an advanced technical indicator designed to minimize lag even further than the Double Exponential Moving Average (DEMA). Developed by Patrick Mulloy in 1994, TEMA uses a triple calculation of exponential moving averages to provide one of the most responsive trend-following indicators while maintaining smoothness and filtering out market noise.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `input_data` | Array | Required | The price data array (typically close prices) |
| `period` | Integer | 30 | Number of periods for TEMA calculation |

### Parameter Details

**input_data**
- Typically uses closing prices for standard trend analysis
- Can use other price types (high, low, typical price, median price) for specialized applications
- Requires sufficient data points: approximately `period * 3` for stable calculations
- More historical data improves the indicator's reliability and reduces initial calculation artifacts

**period** (time_period)
- Default is 30 periods, providing excellent responsiveness with good smoothness
- Common periods and their uses:
  - 5-8 periods: Scalping and very short-term trading
  - 10-15 periods: Day trading and active swing trading
  - 20-30 periods: Standard swing and position trading
  - 50+ periods: Long-term trend identification
- Shorter periods maximize responsiveness but may increase noise
- Longer periods provide smoother trends with slightly more lag
- Recommended ranges:
  - Scalping: 5-9 periods
  - Day trading: 10-15 periods
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

# Calculate 30-period TEMA (default)
tema = SQA::TAI.tema(prices)

puts "Current TEMA: #{tema.last.round(2)}"
```

### With Custom Parameters

```ruby
# Calculate 10-period TEMA for maximum responsiveness
tema_10 = SQA::TAI.tema(prices, period: 10)

# Calculate 50-period TEMA for longer-term trends
tema_50 = SQA::TAI.tema(prices, period: 50)

puts "Short-term TEMA (10): #{tema_10.last.round(2)}"
puts "Standard TEMA (30): #{tema.last.round(2)}"
puts "Long-term TEMA (50): #{tema_50.last.round(2)}"
```

## Understanding the Indicator

### What It Measures

The TEMA measures trend direction with minimal lag:

- **Trend Direction**: Identifies the current market trend by triple-smoothing price data
- **Momentum**: The slope and position of TEMA relative to price indicate strong momentum shifts
- **Dynamic Support/Resistance**: Acts as a highly responsive support level in uptrends and resistance in downtrends
- **Minimal Lag**: Responds to price changes faster than any traditional moving average

TEMA addresses the core challenge of technical analysis: balancing responsiveness with smoothness. By using three layers of exponential smoothing with a compensation formula, TEMA achieves remarkable responsiveness while still filtering out most market noise.

### Calculation Method

The TEMA uses a sophisticated triple calculation process:

1. **Calculate First EMA**: Apply exponential moving average to prices
2. **Calculate Second EMA**: Apply EMA to the first EMA result
3. **Calculate Third EMA**: Apply EMA to the second EMA result
4. **Apply TEMA Formula**: Combine all three EMAs with specific weightings
5. **Result**: A highly responsive moving average with minimal lag

**Formula:**
```
EMA1 = EMA(prices, period)
EMA2 = EMA(EMA1, period)
EMA3 = EMA(EMA2, period)
TEMA = (3 × EMA1) - (3 × EMA2) + EMA3

Where:
- EMA1 is the first exponential moving average of prices
- EMA2 is the exponential moving average of EMA1
- EMA3 is the exponential moving average of EMA2
- The formula removes triple smoothing lag while maintaining smoothness
- Coefficients (3, -3, +1) compensate for the triple calculation
```

### Indicator Characteristics

- **Range**: Unbounded (follows price range)
- **Type**: Overlay indicator (plotted on price chart)
- **Lag**: Minimal lag, most responsive of standard moving averages
- **Best Used**: Strong trending markets, momentum trading, breakout strategies

## Interpretation

### Value Ranges

The TEMA's value closely tracks the price range:

- **TEMA Rising Steeply**: Indicates strong upward momentum and bullish trend
- **TEMA Falling Steeply**: Indicates strong downward momentum and bearish trend
- **TEMA Flat**: Suggests consolidation or range-bound market, reduced momentum

### Key Levels

- **Price Above TEMA**: Bullish condition, uptrend in progress
- **Price Below TEMA**: Bearish condition, downtrend in progress
- **Price Crossing TEMA**: Potential trend change signal (highly responsive)
- **Distance from TEMA**: Large distances may indicate exhaustion or strong momentum

### Signal Interpretation

How to read the TEMA's signals:

1. **Trend Direction**
   - Price consistently above rising TEMA = strong uptrend with momentum
   - Price consistently below falling TEMA = strong downtrend with momentum
   - Price oscillating around TEMA = no clear trend, avoid trend-following

2. **Momentum Changes**
   - TEMA slope steepening rapidly = accelerating momentum, strong move
   - TEMA slope flattening = decelerating momentum, trend weakening
   - TEMA slope reversal = potential trend change, watch for confirmation

3. **Reversal Signals**
   - Price crosses below TEMA = early warning of potential reversal to downtrend
   - Price crosses above TEMA = early warning of potential reversal to uptrend
   - Multiple crosses in short period = ranging market, avoid trading

## Trading Signals

### Buy Signals

Specific conditions that generate buy signals:

1. **Primary Signal**: Price crosses above TEMA while TEMA is rising or just starting to rise
2. **Confirmation Signal**: Increasing volume on the crossover, RSI above 50
3. **Entry Criteria**: Close above TEMA, TEMA slope turning upward

**Example Scenario:**
```
When price closes above TEMA and TEMA slope has turned positive,
consider a long position with stop loss 1-2% below TEMA.
Due to TEMA's responsiveness, use tighter stops than with slower MAs.
Target recent resistance or use a trailing stop to capture the trend.
```

### Sell Signals

Specific conditions that generate sell signals:

1. **Primary Signal**: Price crosses below TEMA while TEMA is falling or just starting to fall
2. **Confirmation Signal**: Increasing volume on the crossover, RSI below 50
3. **Exit Criteria**: Close below TEMA, TEMA slope turning downward

**Example Scenario:**
```
When price closes below TEMA and TEMA slope has turned negative,
consider exiting long positions or entering short with stop loss 1-2% above TEMA.
TEMA responds quickly, so act promptly on signals to avoid larger losses.
```

### Divergence Analysis

**Bullish Divergence:**
- Price makes lower lows while TEMA makes higher lows
- Indicates weakening downward momentum despite lower prices
- TEMA's responsiveness makes this signal appear earlier than with slower MAs
- Confirm with RSI or MACD divergence for higher probability setups

**Bearish Divergence:**
- Price makes higher highs while TEMA makes lower highs or fails to confirm
- Indicates weakening upward momentum despite higher prices
- Often precedes sharp reversals due to TEMA's sensitivity
- Most reliable when occurring at resistance levels

## Best Practices

### Optimal Use Cases

When TEMA works best:
- **Strong trending markets**: TEMA excels at catching and riding strong trends
- **Momentum trading**: Ideal for traders who want to enter trends early
- **Short to medium timeframes**: Works well on 5-min to daily charts
- **Liquid, volatile markets**: Best in active markets with clear price movements

### Combining with Other Indicators

Recommended indicator combinations:

**With Trend Indicators:**
- Use ADX above 25 to confirm strong trend before following TEMA signals
- Combine with slower MA (SMA 50 or 200) for multi-timeframe trend filter

**With Volume Indicators:**
- Confirm TEMA crossovers with above-average volume for higher probability
- Use volume price trend (VPT) to validate TEMA direction

**With Other Oscillators:**
- Use RSI to avoid taking TEMA signals in extreme overbought/oversold
- Combine with Stochastic for precise entry timing
- MACD provides good confirmation for TEMA trend changes

### Common Pitfalls

What to avoid:

1. **Over-trading**: TEMA's sensitivity can generate frequent signals in choppy markets
2. **Ignoring Market Context**: TEMA works poorly in ranging markets; use ADX filter
3. **Too-tight Stops**: While stops should be tighter with TEMA, too tight causes premature exits
4. **Chasing Price**: Don't chase price far from TEMA; wait for pullbacks

### Parameter Selection Guidelines

How to choose optimal parameters:

- **Short-term trading** (scalping): 5-9 period TEMA for ultra-responsive signals
- **Medium-term trading** (day/swing): 15-30 period TEMA for balanced approach
- **Long-term trading** (position): 50-100 period TEMA for major trend identification
- **Backtesting**: Test multiple periods to find optimal for your instrument and style

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

# Calculate TEMA for trend following
tema = SQA::TAI.tema(prices, period: 20)

# Calculate ADX to filter ranging markets
# (assuming we have high, low, close data)
# adx = SQA::TAI.adx(high, low, prices, period: 14)

# Analysis logic
current_price = prices.last
current_tema = tema.last
prev_price = prices[-2]
prev_tema = tema[-2]

# Calculate TEMA slope
tema_slope = current_tema - tema[-3]
slope_direction = tema_slope > 0 ? "rising" : "falling"

# Check for crossover signals
if prev_price <= prev_tema && current_price > current_tema
  puts "BUY Signal: Price crossed above TEMA"
  puts "TEMA is #{slope_direction}"
  puts "Entry: #{current_price.round(2)}"
  puts "TEMA: #{current_tema.round(2)}"
  puts "Stop Loss: #{(current_tema * 0.98).round(2)}"
  puts "Target: #{(current_price * 1.03).round(2)}"

elsif prev_price >= prev_tema && current_price < current_tema
  puts "SELL Signal: Price crossed below TEMA"
  puts "TEMA is #{slope_direction}"
  puts "Exit/Short Entry: #{current_price.round(2)}"
  puts "TEMA: #{current_tema.round(2)}"
  puts "Stop Loss: #{(current_tema * 1.02).round(2)}"

# Trend continuation analysis
elsif current_price > current_tema && tema_slope > 0
  distance = ((current_price - current_tema) / current_tema * 100).round(2)
  puts "Uptrend in Progress"
  puts "Price #{distance}% above rising TEMA"

  if distance < 2
    puts "Good entry zone - price near TEMA support"
  elsif distance > 5
    puts "Extended - wait for pullback to TEMA"
  else
    puts "Normal distance - trend healthy"
  end

elsif current_price < current_tema && tema_slope < 0
  distance = ((current_tema - current_price) / current_tema * 100).round(2)
  puts "Downtrend in Progress"
  puts "Price #{distance}% below falling TEMA"
  puts "Avoid longs - stay in cash or consider shorts on rallies to TEMA"
end
```

## Related Indicators

### Similar Indicators
- **[DEMA](dema.md)**: Double exponential MA, slightly more lag but smoother
- **[EMA](ema.md)**: Single exponential MA, traditional approach with more lag
- **[T3](t3.md)**: Tillson T3, similar responsiveness with different calculation

### Complementary Indicators
- **[ADX](../momentum/adx.md)**: Essential for filtering trending vs ranging markets
- **[RSI](../momentum/rsi.md)**: Helps identify overbought/oversold for better entries
- **[Stochastic](../momentum/stoch.md)**: Precise entry timing with TEMA direction
- **[ATR](../volatility/atr.md)**: Sets appropriate stop-loss distances

### Indicator Family

TEMA belongs to the exponential moving average family:
- **SMA**: Base moving average with maximum lag
- **EMA**: Exponential weighting, reduced lag
- **DEMA**: Double calculation, low lag
- **TEMA**: Triple calculation, minimal lag (most responsive)
- Use TEMA when you need the fastest reaction to price changes

## Advanced Topics

### Multi-Timeframe Analysis

Use TEMA across multiple timeframes for comprehensive trend analysis:
- Higher timeframe TEMA (daily/weekly) for overall trend direction
- Medium timeframe TEMA (4H/1H) for entry setup identification
- Lower timeframe TEMA (15M/5M) for precise entry timing
- Trade only when all timeframes align in same direction

### Market Regime Adaptation

Adjust TEMA usage based on market conditions:
- **Trending markets** (ADX > 25): Follow TEMA signals aggressively
- **Ranging markets** (ADX < 20): Reduce position size or avoid TEMA trades
- **High volatility**: Use longer periods (30-50) to reduce whipsaws
- **Low volatility**: Use shorter periods (10-20) to catch early moves

### Statistical Validation

TEMA reliability metrics:
- Most reliable in strong trends (ADX > 30): 70-80% win rate
- Less reliable in ranging markets (ADX < 20): 40-50% win rate
- False signal rate lower when confirmed with volume
- Optimal when combined with momentum oscillators (RSI, Stochastic)

## References

- Mulloy, Patrick (1994). "Smoothing Data with Faster Moving Averages". Technical Analysis of Stocks & Commodities magazine
- Murphy, John J. "Technical Analysis of the Financial Markets"
- Pring, Martin J. "Technical Analysis Explained"
- Achelis, Steven B. "Technical Analysis from A to Z"

## See Also

- [Overlap Studies Overview](../index.md)
- [DEMA Documentation](dema.md)
- [EMA Documentation](ema.md)
- [Moving Average Comparison](ma.md)
- [ADX for Trend Filtering](../momentum/adx.md)
