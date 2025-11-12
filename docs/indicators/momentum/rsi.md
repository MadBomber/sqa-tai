# RSI (Relative Strength Index)

## Overview

The Relative Strength Index (RSI) is one of the most widely used momentum oscillators in technical analysis. Developed by J. Welles Wilder Jr. in 1978, RSI measures the speed and magnitude of recent price changes to evaluate overbought or oversold conditions in financial markets. The indicator oscillates between 0 and 100, with traditional thresholds at 70 (overbought) and 30 (oversold).

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `input_data` | Array | Required | The price data array (typically close prices) |
| `period` | Integer | 14 | Number of periods for RSI calculation |

### Parameter Details


**Note**: Array elements should be ordered from oldest to newest (chronological order)

**input_data**
- Typically uses closing prices, though any price data can be used
- Requires sufficient data points: at least `period + 1` values
- More historical data provides better context for divergence analysis
- Common to use daily closing prices, but works on any timeframe

**period** (time_period)
- Standard setting is 14 periods (Wilder's original recommendation)
- Shorter periods (7-10) create a more sensitive indicator with more signals
- Longer periods (21-25) create a smoother indicator with fewer, more reliable signals
- Recommended ranges:
  - **Day trading**: 7-9 periods for responsiveness
  - **Swing trading**: 14 periods (standard)
  - **Position trading**: 21-25 periods for trend confirmation

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41,
          46.22, 45.64, 46.21, 46.25, 46.08, 46.46]

# Calculate 14-period RSI (standard)
rsi = SQA::TAI.rsi(prices, period: 14)

puts "Current RSI: #{rsi.last.round(2)}"
```

### With Custom Parameters

```ruby
# More sensitive 9-period RSI for short-term trading
rsi_fast = SQA::TAI.rsi(prices, period: 9)

# Smoother 21-period RSI for position trading
rsi_slow = SQA::TAI.rsi(prices, period: 21)

puts "Fast RSI (9): #{rsi_fast.last.round(2)}"
puts "Standard RSI (14): #{SQA::TAI.rsi(prices).last.round(2)}"
puts "Slow RSI (21): #{rsi_slow.last.round(2)}"
```

## Understanding the Indicator

### What It Measures

The RSI measures momentum by comparing the magnitude of recent gains to recent losses:

- **Momentum Strength**: How quickly prices are moving up or down
- **Overbought/Oversold Conditions**: When an asset may be overextended
- **Trend Exhaustion**: When a strong move may be losing steam
- **Market Psychology**: The balance between buying and selling pressure

RSI answers the question: "Is the current price move sustainable, or is it overextended?"

### Calculation Method

The RSI is calculated using the following process:

1. **Calculate Price Changes**: Determine the change between each closing price
2. **Separate Gains and Losses**: Split changes into positive (gains) and negative (losses)
3. **Calculate Average Gain/Loss**: Use Wilder's smoothing method over the period
4. **Calculate Relative Strength (RS)**: Divide average gain by average loss
5. **Normalize to RSI**: Apply formula to bound between 0 and 100

**Formula:**
```
RS = Average Gain / Average Loss
RSI = 100 - (100 / (1 + RS))

Where:
- Average Gain = Sum of gains over period / period
- Average Loss = Sum of losses over period / period
- Subsequent values use Wilder's smoothing:
  Average Gain = [(Previous Avg Gain) × 13 + Current Gain] / 14
  Average Loss = [(Previous Avg Loss) × 13 + Current Loss] / 14
```

### Indicator Characteristics

- **Range**: 0 to 100 (bounded oscillator)
- **Type**: Momentum oscillator
- **Lag**: Moderate (smoothed average-based calculation)
- **Best Used**: Ranging markets, overbought/oversold identification, divergence analysis
- **Limitations**: Can remain overbought/oversold for extended periods in strong trends

## Interpretation

### Value Ranges

Specific guidance on what different RSI values indicate:

- **Above 70**: Traditional overbought zone - indicates strong upward momentum that may be excessive. Price may be due for a pullback or consolidation.
- **50-70**: Bullish momentum - prices are rising with healthy buying pressure. Not yet overbought.
- **40-60**: Neutral zone - balanced buying and selling pressure. No clear momentum advantage.
- **30-50**: Bearish momentum - prices are declining with selling pressure. Not yet oversold.
- **Below 30**: Traditional oversold zone - indicates strong downward momentum that may be excessive. Price may be due for a bounce or stabilization.

### Key Levels

- **Overbought (70)**: Price may be overextended to upside. Consider taking profits or waiting for pullback.
- **Oversold (30)**: Price may be overextended to downside. Consider looking for entry opportunities.
- **Midpoint (50)**: Represents equilibrium between buying and selling pressure. RSI crossing above 50 suggests bullish momentum; crossing below suggests bearish momentum.
- **Extreme Levels (80+/20-)**: Indicates very strong momentum. While these are rare, they can signal powerful trends or imminent reversals.

**Important**: In strong trends, RSI can remain overbought (>70) or oversold (<30) for extended periods. Adjust thresholds based on market conditions:
- **Strong uptrend**: Use 80/40 instead of 70/30
- **Strong downtrend**: Use 60/20 instead of 70/30

### Signal Interpretation

How to read the RSI's signals:

1. **Trend Direction**
   - RSI above 50: Bullish bias, buyers in control
   - RSI below 50: Bearish bias, sellers in control
   - RSI oscillating around 50: Consolidation, trendless market

2. **Momentum Changes**
   - RSI rising: Increasing bullish momentum
   - RSI falling: Increasing bearish momentum
   - RSI flattening: Momentum stabilizing, possible consolidation

3. **Reversal Signals**
   - Failure swings: RSI fails to reach overbought/oversold on subsequent tests
   - Divergences: RSI and price moving in opposite directions
   - Extreme readings followed by reversal: Very strong signals

## Trading Signals

### Buy Signals

Specific conditions that generate buy signals:

1. **Primary Signal**: RSI crosses below 30 then rises back above 30
   - Confirms oversold condition has ended
   - Best when aligned with support levels

2. **Confirmation Signal**: RSI crosses above 50 from below
   - Indicates shift from bearish to bullish momentum
   - Works well as trend-following entry

3. **Divergence Signal**: Price makes lower low, RSI makes higher low
   - Bullish divergence suggests weakening downtrend
   - Strongest when RSI is in oversold territory

**Example Scenario:**
```
When RSI drops below 30 (oversold), then crosses back above 30,
consider a long position. Confirm with:
- Price finding support at key level
- Volume declining during selloff
- Set stop loss below recent low
```

### Sell Signals

Specific conditions that generate sell signals:

1. **Primary Signal**: RSI crosses above 70 then falls back below 70
   - Confirms overbought condition has ended
   - Best when aligned with resistance levels

2. **Confirmation Signal**: RSI crosses below 50 from above
   - Indicates shift from bullish to bearish momentum
   - Works well as trend-following exit

3. **Divergence Signal**: Price makes higher high, RSI makes lower high
   - Bearish divergence suggests weakening uptrend
   - Strongest when RSI is in overbought territory

**Example Scenario:**
```
When RSI rises above 70 (overbought), then crosses back below 70,
consider closing long positions or initiating shorts. Confirm with:
- Price reaching resistance level
- Volume declining during rally
- Set stop loss above recent high
```

### Divergence Analysis

**Bullish Divergence:**
- **Pattern**: Price makes lower low, RSI makes higher low
- **Identification**: Compare price lows with RSI lows over 20-50 bars
- **Significance**: Suggests downtrend losing momentum, potential reversal ahead
- **Reliability**: High when RSI is oversold (<40) and forms clear higher low
- **Example**: Stock drops from $100 to $90, then to $85. RSI drops to 25, then only to 32 on second low.

**Bearish Divergence:**
- **Pattern**: Price makes higher high, RSI makes lower high
- **Identification**: Compare price highs with RSI highs over 20-50 bars
- **Significance**: Suggests uptrend losing momentum, potential reversal ahead
- **Reliability**: High when RSI is overbought (>60) and forms clear lower high
- **Example**: Stock rises from $100 to $110, then to $115. RSI rises to 75, then only to 68 on second high.

## Best Practices

### Optimal Use Cases

When RSI works best:

- **Market conditions**: Ranging or oscillating markets provide best signals. Strong trending markets can keep RSI overbought/oversold for extended periods.
- **Time frames**: Works on all timeframes but most reliable on daily and 4-hour charts. Lower timeframes generate more false signals.
- **Asset classes**: Excellent for stocks, forex, and cryptocurrencies. Less reliable for commodities with strong seasonal trends.

### Combining with Other Indicators

Recommended indicator combinations:

- **With Trend Indicators**: Use 200-period SMA or EMA to identify trend direction. Only take RSI signals aligned with the trend (RSI oversold in uptrend, RSI overbought in downtrend).

- **With Volume Indicators**: Combine with OBV or volume analysis. Strongest RSI signals occur when volume confirms the move (declining volume in oversold, declining volume in overbought).

- **With Support/Resistance**: RSI signals are most reliable when they occur at key price levels. RSI oversold at support = strong buy. RSI overbought at resistance = strong sell.

### Common Pitfalls

What to avoid:

1. **Over-reliance on RSI alone**: RSI generates many false signals. Always use with trend analysis and support/resistance levels.

2. **Ignoring the trend**: In strong uptrends, RSI rarely gets oversold. In strong downtrends, RSI rarely gets overbought. Adjust thresholds or don't counter-trend trade.

3. **Parameter optimization trap**: Backtesting to find "perfect" period settings leads to overfitting. Standard 14-period works well for most situations.

4. **Time frame mismatch**: Using 5-minute RSI for position trading decisions, or daily RSI for scalping leads to poor results.

### Parameter Selection Guidelines

How to choose optimal parameters:

- **Short-term trading (day trading)**:
  - Period: 7-9 for faster signals
  - Thresholds: 75/25 or 80/20 to reduce noise
  - Focus: Quick reversals, scalping opportunities

- **Medium-term trading (swing trading)**:
  - Period: 14 (standard) for balanced signals
  - Thresholds: 70/30 (traditional)
  - Focus: Multi-day moves, divergences

- **Long-term trading (position trading)**:
  - Period: 21-25 for smoother signals
  - Thresholds: 65/35 or custom based on historical analysis
  - Focus: Major trend changes, monthly patterns

- **Backtesting approach**: Test on historical data for your specific asset and timeframe. Look for RSI levels that historically preceded reversals.

## Practical Example

Complete trading example with context:

```ruby
require 'sqa/tai'

# Historical price data for a stock
historical_prices = [
  44.34, 44.09, 44.15, 43.61, 44.33, 44.83, 45.10, 45.42,
  45.84, 46.08, 46.03, 46.41, 46.22, 45.64, 46.21, 46.25,
  46.08, 46.46, 46.57, 45.95, 46.50, 46.02, 45.55, 46.08,
  46.34, 46.00, 45.75, 46.45, 47.02, 46.87
]

# Calculate RSI and supporting indicators
rsi = SQA::TAI.rsi(historical_prices, period: 14)
sma_50 = SQA::TAI.sma(historical_prices, period: 20)  # Trend filter

# Current values
current_price = historical_prices.last
current_rsi = rsi.last
previous_rsi = rsi[-2]

# Trend determination
trend = current_price > sma_50.last ? "UPTREND" : "DOWNTREND"

puts "=== RSI Trading Analysis ==="
puts "Current Price: #{current_price.round(2)}"
puts "Current RSI: #{current_rsi.round(2)}"
puts "Trend: #{trend}"
puts

# Trading logic with trend filter
if trend == "UPTREND"
  # In uptrend, only look for buy signals (oversold conditions)
  if current_rsi < 40 && previous_rsi >= 40
    puts "BUY SIGNAL: RSI crossed below 40 in uptrend"
    puts "Entry: #{current_price.round(2)}"
    puts "Stop Loss: #{(current_price * 0.97).round(2)} (3% below entry)"
    puts "Target: Previous high or when RSI reaches 70"
  elsif current_rsi < 30
    puts "STRONG BUY: RSI oversold in uptrend (#{current_rsi.round(2)})"
    puts "High probability bounce opportunity"
  elsif current_rsi > 70
    puts "TAKE PROFITS: RSI overbought - consider scaling out"
  else
    puts "HOLD: RSI at #{current_rsi.round(2)} - no clear signal"
  end

elsif trend == "DOWNTREND"
  # In downtrend, only look for sell signals (overbought conditions)
  if current_rsi > 60 && previous_rsi <= 60
    puts "SELL SIGNAL: RSI crossed above 60 in downtrend"
    puts "Entry: #{current_price.round(2)}"
    puts "Stop Loss: #{(current_price * 1.03).round(2)} (3% above entry)"
    puts "Target: Previous low or when RSI reaches 30"
  elsif current_rsi > 70
    puts "STRONG SELL: RSI overbought in downtrend (#{current_rsi.round(2)})"
    puts "High probability continuation of downtrend"
  elsif current_rsi < 30
    puts "CAUTION: RSI oversold in downtrend"
    puts "Avoid catching falling knife - wait for trend reversal"
  else
    puts "HOLD/AVOID: RSI at #{current_rsi.round(2)} - no clear signal"
  end
end

# Divergence detection (simplified)
puts "\n=== Divergence Check ==="
price_high_recent = historical_prices.last(10).max
price_high_previous = historical_prices[-20..-11].max
rsi_high_recent = rsi.last(10).compact.max
rsi_high_previous = rsi[-20..-11].compact.max

if price_high_recent > price_high_previous && rsi_high_recent < rsi_high_previous
  puts "⚠️  BEARISH DIVERGENCE DETECTED"
  puts "Price making higher highs, RSI making lower highs"
  puts "Potential trend exhaustion - consider taking profits"
end
```

## Related Indicators

### Similar Indicators
- **[Stochastic Oscillator](stoch.md)**: Another momentum oscillator comparing price to its range. Stochastic is more sensitive than RSI and generates more signals. Use Stochastic for faster markets, RSI for smoother analysis.
- **[CCI (Commodity Channel Index)](cci.md)**: Measures deviation from average price. CCI is unbounded (can exceed 100), while RSI is bounded (0-100). CCI better for identifying extreme conditions.

### Complementary Indicators
- **[MACD](macd.md)**: Trend-following momentum indicator. Use MACD for trend direction and entries, RSI for timing and overbought/oversold confirmation.
- **[Bollinger Bands](../overlap/bbands.md)**: Volatility bands. RSI signals at Bollinger Band extremes are particularly reliable.
- **[Volume (OBV)](../volume/obv.md)**: Confirms momentum. RSI divergences with volume confirmation are strongest signals.

### Indicator Family
RSI belongs to the momentum oscillator family:
- **RSI**: Smoothed momentum based on gains vs losses
- **Stochastic**: Raw momentum comparing current price to recent range
- **Williams %R**: Similar to Stochastic, focuses on overbought levels
- **MFI (Money Flow Index)**: "Volume-weighted RSI" incorporating volume data

**When to prefer RSI**: For general momentum analysis, overbought/oversold identification, and divergence analysis. RSI's smoothing makes it less noisy than Stochastic while being more responsive than moving averages.

## Advanced Topics

### Multi-Timeframe Analysis

Use RSI across multiple timeframes for comprehensive analysis:

- **Higher timeframe RSI** (daily/weekly) identifies major trend direction and overbought/oversold conditions
- **Lower timeframe RSI** (4H/1H) provides precise entry timing within the higher timeframe trend
- Strongest signals when all timeframes align (e.g., daily RSI oversold + 4H RSI oversold in uptrend)

Example: If weekly RSI is oversold (30) and daily RSI crosses above 30, this represents a high-probability long entry with both timeframes supporting the move.

### Market Regime Adaptation

RSI behavior changes in different market conditions:

- **Bull Markets**: RSI tends to stay elevated (50-80 range). Oversold readings are rare and represent strong buy opportunities. Consider 80/40 thresholds.
- **Bear Markets**: RSI tends to stay depressed (20-50 range). Overbought readings are rare and represent strong sell opportunities. Consider 60/20 thresholds.
- **Ranging Markets**: Traditional 70/30 thresholds work best. RSI provides clearest signals in these conditions.
- **High Volatility**: RSI generates more extreme readings and false signals. Consider longer periods (21-25) to smooth out noise.

### Statistical Validation

RSI reliability metrics and considerations:

- **Success Rate**: Studies show RSI oversold/overbought signals have 55-65% success rate when used alone. Combining with trend filters improves this to 65-75%.
- **Risk/Reward**: RSI divergences offer best risk/reward ratios (typically 1:3 or better) compared to simple overbought/oversold signals (1:1.5).
- **Optimal Thresholds**: Vary by asset class. Stocks: 70/30, Forex: 75/25, Crypto: 80/20 due to higher volatility.
- **False Signal Rate**: Approximately 35-45% of RSI signals fail. Always use stop losses and position sizing to manage risk.

## References

- Wilder, J. Welles Jr. "New Concepts in Technical Trading Systems" (1978) - Original RSI publication
- Brown, Constance. "Technical Analysis for the Trading Professional" (1999) - Advanced RSI techniques including divergence patterns
- Cardwell, Andrew. "RSI: The Complete Guide" - Failure swings and positive/negative reversals
- [TradingView: RSI Educational Guide](https://www.tradingview.com/support/solutions/43000502338-relative-strength-index-rsi/)
- [StockCharts: RSI Technical Analysis](https://school.stockcharts.com/doku.php?id=technical_indicators:relative_strength_index_rsi)

## See Also

- [Momentum Indicators Overview](../index.md)
- [Basic Usage Guide](../../getting-started/basic-usage.md)
- [API Reference](../../api-reference.md)
