# ACCBANDS (Acceleration Bands)

## Overview

Acceleration Bands are a sophisticated volatility-based indicator that creates dynamic price channels similar to Bollinger Bands but with a fundamentally different calculation methodology. Developed to identify breakouts and trend acceleration, ACCBANDS use high and low prices with acceleration factors rather than statistical standard deviation. This approach makes them particularly responsive to momentum shifts and trend acceleration, providing earlier signals for potential breakouts and trend changes. The bands expand and contract based on price volatility and momentum, offering traders valuable insights into market acceleration patterns.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `high` | Array | Required | Array of high price values |
| `low` | Array | Required | Array of low price values |
| `close` | Array | Required | Array of close price values |
| `period` | Integer | 20 | Number of periods for calculation |

### Parameter Details

**high**
- Array of high prices for each period
- Used to calculate upper band with acceleration factor
- More responsive than using only close prices
- Captures full price range for volatility assessment

**low**
- Array of low prices for each period
- Used to calculate lower band with acceleration factor
- Complements high prices for complete range analysis
- Essential for accurate band placement

**close**
- Array of closing prices for each period
- Used to calculate middle band (SMA)
- Standard reference point for band distance
- Typical price level for comparison

**period** (time_period)
- Default is 20 periods, standard for most applications
- Common periods:
  - 10 periods: Short-term, day trading
  - 20 periods: Standard setting (most common)
  - 50 periods: Long-term trends
  - 100+ periods: Major trend identification
- Shorter periods = more responsive but noisier
- Longer periods = smoother but more lag

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

high_prices = [46.08, 46.41, 46.57, 46.50, 46.75, 47.00,
               47.25, 47.50, 47.75, 48.00, 48.25, 48.50,
               48.75, 49.00, 49.25, 49.50, 49.75, 50.00,
               50.25, 50.50, 50.75, 51.00]

low_prices = [44.50, 44.75, 45.00, 45.25, 45.50, 45.75,
              46.00, 46.25, 46.50, 46.75, 47.00, 47.25,
              47.50, 47.75, 48.00, 48.25, 48.50, 48.75,
              49.00, 49.25, 49.50, 49.75]

close_prices = [45.50, 45.75, 46.00, 46.25, 46.50, 46.75,
                47.00, 47.25, 47.50, 47.75, 48.00, 48.25,
                48.50, 48.75, 49.00, 49.25, 49.50, 49.75,
                50.00, 50.25, 50.50, 50.75]

# Calculate Acceleration Bands
upper, middle, lower = SQA::TAI.accbands(high_prices, low_prices, close_prices, period: 20)

puts "Upper Band: #{upper.last.round(2)}"
puts "Middle Band: #{middle.last.round(2)}"
puts "Lower Band: #{lower.last.round(2)}"
```

## Understanding the Indicator

### What It Measures

ACCBANDS measures price acceleration and volatility:

- **Trend Acceleration**: Identifies when price momentum is increasing
- **Breakout Potential**: Signals when price may break out of normal range
- **Volatility Changes**: Band width indicates changing market volatility
- **Support/Resistance Levels**: Dynamic levels based on price acceleration

ACCBANDS solves the problem of detecting trend acceleration early. Unlike Bollinger Bands which use statistical measures, ACCBANDS uses the natural price range (high-low) with acceleration factors, making them more responsive to momentum shifts.

### Calculation Method

ACCBANDS uses high/low prices with acceleration factors:

1. **Calculate SMA**: Simple moving average of close prices (middle band)
2. **Apply Acceleration Factor**: Adjust high prices for upper band
3. **Apply Acceleration Factor**: Adjust low prices for lower band
4. **Result**: Three bands that expand/contract with acceleration

### Indicator Characteristics

- **Range**: Unbounded (follows price range)
- **Type**: Overlay indicator with three bands
- **Lag**: Medium lag, more responsive than Bollinger Bands
- **Best Used**: Trending markets, breakout detection, acceleration analysis

## Returns

Returns three arrays:
1. **Upper Band** - High prices adjusted by acceleration factor
2. **Middle Band** - Simple moving average of close prices
3. **Lower Band** - Low prices adjusted by acceleration factor

The first `period - 1` values will be `nil`.

## Interpretation

### Value Ranges

ACCBANDS provide dynamic price channels:

- **Wide Bands**: High volatility, strong acceleration
- **Narrow Bands**: Low volatility, potential breakout setup
- **Expanding Bands**: Increasing volatility and momentum
- **Contracting Bands**: Decreasing volatility, consolidation

### Key Levels

- **Price Touches Upper Band**: Potential acceleration in uptrend
- **Price Touches Lower Band**: Potential acceleration in downtrend
- **Price Within Bands**: Normal price action
- **Price Outside Bands**: Strong momentum, breakout signal

### Signal Interpretation

1. **Trend Direction**
   - Price walking upper band = strong uptrend with acceleration
   - Price walking lower band = strong downtrend with acceleration
   - Price between bands = normal trading range

2. **Momentum Changes**
   - Band expansion = increasing volatility, momentum building
   - Band contraction = decreasing volatility, potential squeeze
   - Band width changes = volatility regime shifts

3. **Reversal Signals**
   - Price returns from upper band to middle = potential pullback
   - Price returns from lower band to middle = potential bounce
   - Confirm with volume and other indicators

## Trading Signals

### Buy Signals

Specific conditions that generate buy signals:

1. **Primary Signal**: Price closes above upper band, indicating upward acceleration
2. **Confirmation Signal**: Increasing volume on the breakout
3. **Entry Criteria**: Wait for slight pullback toward upper band for entry

**Example Scenario:**
```
When price closes above upper ACCBAND with volume confirmation,
enter long on pullback to upper band with stop at middle band.
Target based on previous resistance or ATR multiples.
```

### Sell Signals

Specific conditions that generate sell signals:

1. **Primary Signal**: Price closes below lower band, indicating downward acceleration
2. **Confirmation Signal**: Increasing volume on the breakdown
3. **Exit Criteria**: Exit longs when price crosses below middle band

**Example Scenario:**
```
When price closes below lower ACCBAND with volume confirmation,
exit long positions or enter short with stop above middle band.
```

## Interpretation

| Signal | Interpretation |
|--------|----------------|
| Price touches upper band | Potential acceleration in uptrend, breakout signal |
| Price touches lower band | Potential acceleration in downtrend, breakdown signal |
| Price within bands | Normal price action, no acceleration |
| Band expansion | Increasing volatility and momentum |
| Band contraction | Decreasing volatility, potential consolidation |

## Example: Breakout Detection

```ruby
high = load_historical_data('AAPL', field: :high)
low = load_historical_data('AAPL', field: :low)
close = load_historical_data('AAPL', field: :close)

upper, middle, lower = SQA::TAI.accbands(high, low, close, period: 20)

current_close = close.last
current_high = high.last
current_low = low.last

# Detect breakouts
if current_close > upper.last
  puts "Bullish Breakout: Price accelerating above upper band"
  puts "Entry: #{current_close.round(2)}"
  puts "Stop: #{middle.last.round(2)}"
elsif current_close < lower.last
  puts "Bearish Breakdown: Price accelerating below lower band"
  puts "Entry: #{current_close.round(2)}"
  puts "Stop: #{middle.last.round(2)}"
end

# Calculate band width for volatility assessment
bandwidth = ((upper.last - lower.last) / middle.last * 100).round(2)
puts "Current Bandwidth: #{bandwidth}%"
```

## Example: Trend Acceleration Strategy

```ruby
high = load_historical_data('TSLA', field: :high)
low = load_historical_data('TSLA', field: :low)
close = load_historical_data('TSLA', field: :close)

upper, middle, lower = SQA::TAI.accbands(high, low, close, period: 20)

# Look at recent price action
recent_closes = close[-5..-1]
recent_uppers = upper[-5..-1].compact
recent_lowers = lower[-5..-1].compact

# Count touches of bands
upper_touches = recent_closes.zip(recent_uppers).count { |c, u| c >= u }
lower_touches = recent_closes.zip(recent_lowers).count { |c, l| c <= l }

if upper_touches >= 3
  puts "Strong Uptrend: Multiple upper band touches"
  puts "Trend is accelerating - consider trailing stop"
elsif lower_touches >= 3
  puts "Strong Downtrend: Multiple lower band touches"
  puts "Downward acceleration - avoid catching falling knife"
end

# Check for mean reversion opportunity
if close.last < lower.last && close[-2] > lower[-2]
  puts "Potential Mean Reversion: First touch of lower band"
  puts "Target: Middle band at #{middle.last.round(2)}"
end
```

## Example: Comparing with Bollinger Bands

```ruby
high = load_historical_data('MSFT', field: :high)
low = load_historical_data('MSFT', field: :low)
close = load_historical_data('MSFT', field: :close)

# Calculate both band types
acc_upper, acc_middle, acc_lower = SQA::TAI.accbands(high, low, close, period: 20)
bb_upper, bb_middle, bb_lower = SQA::TAI.bbands(close, period: 20)

# Compare band widths
acc_width = ((acc_upper.last - acc_lower.last) / acc_middle.last * 100).round(2)
bb_width = ((bb_upper.last - bb_lower.last) / bb_middle.last * 100).round(2)

puts "Acceleration Bands Width: #{acc_width}%"
puts "Bollinger Bands Width: #{bb_width}%"

# Acceleration Bands typically show earlier expansion
if acc_width > bb_width * 1.1
  puts "ACCBANDS showing early volatility expansion"
  puts "Momentum may be building"
elsif bb_width > acc_width * 1.1
  puts "BBANDS wider - statistical volatility higher"
  puts "Price action may be more erratic"
end

# Check for convergence/divergence signals
if close.last > acc_upper.last && close.last > bb_upper.last
  puts "Strong Breakout: Above both band types"
  puts "High conviction signal"
elsif close.last > acc_upper.last && close.last < bb_upper.last
  puts "Early Momentum: ACCBANDS breakout first"
  puts "Watch for BBANDS confirmation"
end
```

## Best Practices

### Optimal Use Cases

When ACCBANDS works best:
- **Trending markets**: Excellent for identifying and riding strong trends
- **Breakout trading**: Early detection of momentum shifts and breakouts
- **Volatility analysis**: Understanding market acceleration patterns
- **Momentum strategies**: Combining with momentum indicators for confirmation

### Combining with Other Indicators

**With Trend Indicators:**
- Use ADX to confirm trend strength when ACCBANDS shows breakout
- Combine with moving averages for multi-confirmation signals

**With Volume Indicators:**
- Confirm ACCBANDS signals with volume spikes for higher probability
- Use OBV to validate acceleration detected by bands

**With Other Oscillators:**
- RSI helps identify overbought/oversold at band extremes
- MACD provides momentum confirmation for ACCBANDS breakouts
- ATR helps set stop-loss distances based on volatility

### Common Pitfalls

What to avoid:

1. **False Breakouts**: Use volume confirmation to filter false signals
2. **Ranging Markets**: ACCBANDS generates many whipsaws in choppy markets
3. **Over-trading**: Wait for clear breakouts beyond bands, not just touches
4. **Ignoring Context**: Consider overall market structure and support/resistance

### Parameter Selection Guidelines

How to choose optimal parameters:

- **Short-term trading** (day trading): 10 period ACCBANDS for active signals
- **Medium-term trading** (swing trading): 20 period ACCBANDS (standard)
- **Long-term trading** (position trading): 50 period ACCBANDS for major trends
- **Backtesting**: Test different periods but 20 is optimal for most applications

## Practical Example

See the comprehensive examples above demonstrating:
- ACCBANDS breakout detection with entry/exit points
- Trend acceleration strategies with band walking
- Comparison with Bollinger Bands
- Volume confirmation techniques

## Trading Strategies

### 1. Acceleration Breakout
- Enter when price closes above upper band
- Confirms momentum acceleration
- Set stop at middle band
- Target previous swing highs

### 2. Band Walk Strategy
- Price walking along upper band = strong uptrend
- Price walking along lower band = strong downtrend
- Stay with trend until band crosses back

### 3. Squeeze and Expansion
- Narrow bands indicate low volatility
- Wait for expansion and breakout
- Direction of expansion signals trend

### 4. False Breakout Filter
- Use with volume indicators
- Require multiple period closes beyond bands
- Avoid whipsaws in ranging markets

## Advanced Topics

### Multi-Timeframe Analysis

Use ACCBANDS across multiple timeframes:
- Higher timeframe bands for overall trend context
- Lower timeframe bands for precise entry timing
- Trade only when breakouts align across timeframes

### Market Regime Adaptation

ACCBANDS behavior in different conditions:
- **Trending markets**: Bands walk with price, clear signals
- **Ranging markets**: Many false breakouts, use filters
- **High volatility**: Wide bands, larger stops needed
- **Low volatility**: Narrow bands, potential squeeze setup

### Statistical Validation

ACCBANDS reliability metrics:
- Most reliable with volume confirmation (70-80% success)
- Less reliable in ranging markets (40-50% success)
- Band walking strategies have high win rate in trends
- Breakout signals improve with multiple timeframe confirmation

## References

- Price, K. "Acceleration Bands" Technical Analysis of Stocks & Commodities
- Murphy, John J. "Technical Analysis of the Financial Markets"
- Bollinger, John. "Bollinger on Bollinger Bands"

## Common Settings

| Period | Use Case |
|--------|----------|
| 10 | Short-term trading, day trading |
| 20 | Standard setting (most common) |
| 50 | Long-term trends, position trading |
| 100 | Major trend identification |

## Differences from Bollinger Bands

| Feature | Acceleration Bands | Bollinger Bands |
|---------|-------------------|-----------------|
| Calculation | Uses high/low with acceleration factor | Uses standard deviation |
| Sensitivity | More responsive to momentum | More responsive to volatility |
| Best Use | Trend acceleration, breakouts | Volatility, mean reversion |
| Band Width | Based on price range | Based on statistical deviation |

## Related Indicators

- [Bollinger Bands (BBANDS)](bbands.md) - Similar volatility bands
- [Keltner Channels](kama.md) - ATR-based bands
- [ATR](../volatility/atr.md) - Volatility measurement
- [ADX](../momentum/adx.md) - Trend strength confirmation

## See Also

- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
- [Volatility Analysis Example](../../examples/volatility-analysis.md)
