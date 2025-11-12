# AVGPRICE (Average Price)

## Overview

The Average Price (AVGPRICE) is a simple yet effective price transformation indicator that calculates the arithmetic mean of the Open, High, Low, and Close (OHLC) prices for each period. This indicator provides a balanced representation of price action by giving equal weight to all four critical price points, creating a smoothed price series that reduces noise and captures the true center of each period's trading range.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `open` | Array | Required | Array of open prices for each period |
| `high` | Array | Required | Array of high prices for each period |
| `low` | Array | Required | Array of low prices for each period |
| `close` | Array | Required | Array of close prices for each period |

### Parameter Details

**open**
- Opening price for each trading period
- Represents the first traded price when the period begins
- Critical for understanding session gaps and overnight market action
- All arrays must have the same length

**high**
- Highest price reached during each trading period
- Captures maximum bullish momentum for the period
- Important for identifying resistance levels and breakout points
- All arrays must have the same length

**low**
- Lowest price reached during each trading period
- Captures maximum bearish pressure for the period
- Important for identifying support levels and breakdown points
- All arrays must have the same length

**close**
- Closing price for each trading period
- Represents the final settlement price for the period
- Often considered the most important price point
- All arrays must have the same length

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

# Sample OHLC data
open =  [48.00, 48.20, 48.50, 48.40, 48.30]
high =  [48.70, 48.72, 48.90, 48.87, 48.82]
low =   [47.79, 48.14, 48.39, 48.37, 48.24]
close = [48.20, 48.61, 48.75, 48.63, 48.74]

# Calculate average price
avgprice = SQA::TAI.avgprice(open, high, low, close)

puts "Current Average Price: #{avgprice.last.round(2)}"
```

### With Real Market Data

```ruby
# Load historical OHLC data
ohlc_data = load_historical_data('AAPL')
open  = ohlc_data.map(&:open)
high  = ohlc_data.map(&:high)
low   = ohlc_data.map(&:low)
close = ohlc_data.map(&:close)

# Calculate average price series
avgprice = SQA::TAI.avgprice(open, high, low, close)

# Display recent values
puts "Last 5 Average Prices:"
avgprice.last(5).each_with_index do |price, i|
  puts "#{i+1}. #{price.round(4)}"
end
```

### Multiple Timeframe Analysis

```ruby
# Daily and hourly data
daily_ohlc = load_historical_data('SPY', timeframe: 'daily')
hourly_ohlc = load_historical_data('SPY', timeframe: 'hourly')

daily_avg = SQA::TAI.avgprice(
  daily_ohlc.map(&:open),
  daily_ohlc.map(&:high),
  daily_ohlc.map(&:low),
  daily_ohlc.map(&:close)
)

hourly_avg = SQA::TAI.avgprice(
  hourly_ohlc.map(&:open),
  hourly_ohlc.map(&:high),
  hourly_ohlc.map(&:low),
  hourly_ohlc.map(&:close)
)

puts "Daily Average Price: #{daily_avg.last.round(2)}"
puts "Current Hourly Average Price: #{hourly_avg.last.round(2)}"
```

## Understanding the Indicator

### What It Measures

The Average Price provides a comprehensive snapshot of price action by considering all four critical price points:

- **True Center Point**: Unlike using only close prices, AVGPRICE captures the mathematical center of the entire period's trading range
- **Reduced Noise**: By averaging four price points, random price spikes or drops are smoothed out, revealing underlying trends
- **Balanced Representation**: Equal weighting of OHLC ensures no single price point dominates the analysis
- **Session Completeness**: Incorporates the full price journey from open through the high-low range to close

AVGPRICE answers the question: "What is the fair average value where the market traded during this period?"

### Calculation Method

The Average Price is calculated using a simple arithmetic mean:

1. **Sum all four prices**: Add Open + High + Low + Close
2. **Divide by four**: Calculate the arithmetic mean
3. **Result**: A single average price value that represents the period

**Formula:**
```
AVGPRICE = (Open + High + Low + Close) / 4

Where:
- Open = Opening price of the period
- High = Highest price reached during the period
- Low = Lowest price reached during the period
- Close = Closing price of the period
- Result is a simple average (arithmetic mean)
```

### Indicator Characteristics

- **Range**: Unbounded (can be any positive value, bounded by the price range of the security)
- **Type**: Price transformation indicator / smoothing indicator
- **Lag**: Minimal (real-time calculation with no historical dependencies)
- **Best Used**: Smoothing price series, base for further calculations, trend identification, reducing noise in volatile markets
- **Limitations**: Loses some information by simplifying four values into one; may not reflect intraday dynamics for long-period charts

## Interpretation

### Value Ranges

The Average Price itself doesn't have fixed interpretation levels, but its relationship to other price points provides valuable insights:

- **AVGPRICE = Close**: Balanced session - close is at the average of the range
- **AVGPRICE > Close**: Weak close - price closed below the period's average, suggesting bearish pressure
- **AVGPRICE < Close**: Strong close - price closed above the period's average, suggesting bullish strength
- **AVGPRICE near High**: Bullish session - most trading occurred in upper range
- **AVGPRICE near Low**: Bearish session - most trading occurred in lower range

### Key Levels

- **Close vs AVGPRICE**: Primary relationship to assess session strength
  - Close > AVGPRICE: Bulls controlled the close
  - Close < AVGPRICE: Bears controlled the close
  - Close = AVGPRICE: Neutral session

- **AVGPRICE as Support/Resistance**: When price approaches previous AVGPRICE levels, it may act as support (below) or resistance (above)

- **Moving Average of AVGPRICE**: Applying a moving average to AVGPRICE creates a double-smoothed trend indicator

### Signal Interpretation

How to read Average Price signals:

1. **Trend Direction**
   - Series of rising AVGPRICE values: Uptrend
   - Series of falling AVGPRICE values: Downtrend
   - Flat AVGPRICE values: Consolidation or range-bound

2. **Price Strength**
   - Close consistently above AVGPRICE: Strong bullish momentum
   - Close consistently below AVGPRICE: Strong bearish momentum
   - Close oscillating around AVGPRICE: Balanced trading, no clear momentum

3. **Volatility Assessment**
   - Large difference between AVGPRICE and Close: High intraday volatility
   - Small difference between AVGPRICE and Close: Low volatility, tight range trading
   - AVGPRICE smooths out extreme values compared to using Close alone

## Trading Signals

### Buy Signals

Specific conditions that generate buy signals:

1. **Primary Signal - Close Above Average**: Current close crosses above AVGPRICE after being below
   - Indicates shift from weak to strong session
   - Best when occurring after oversold conditions
   - Confirms buyers stepped in during the session

2. **Confirmation Signal - AVGPRICE Uptrend**: Rising series of AVGPRICE values
   - Confirms underlying trend is bullish
   - Provides objective measure of trend direction
   - Works as trend filter for other indicators

3. **Support Test**: Price declines to previous AVGPRICE levels and bounces
   - AVGPRICE from prior periods can act as support
   - Bounce from AVGPRICE support suggests buying interest
   - Strongest when combined with volume confirmation

**Example Scenario:**
```
When price has been below AVGPRICE for several periods (weak closes),
and then closes above AVGPRICE, consider a long position:
- Confirms shift from bearish to bullish momentum
- Entry: On close above AVGPRICE
- Stop Loss: Below recent AVGPRICE low
- Target: Previous resistance or when close falls below AVGPRICE
```

### Sell Signals

Specific conditions that generate sell signals:

1. **Primary Signal - Close Below Average**: Current close crosses below AVGPRICE after being above
   - Indicates shift from strong to weak session
   - Best when occurring after overbought conditions
   - Confirms sellers controlled the session close

2. **Confirmation Signal - AVGPRICE Downtrend**: Falling series of AVGPRICE values
   - Confirms underlying trend is bearish
   - Provides objective measure of trend deterioration
   - Works as trend filter to avoid longs

3. **Resistance Test**: Price rallies to previous AVGPRICE levels and fails
   - AVGPRICE from prior periods can act as resistance
   - Rejection at AVGPRICE resistance suggests selling pressure
   - Strongest when combined with volume confirmation

**Example Scenario:**
```
When price has been above AVGPRICE for several periods (strong closes),
and then closes below AVGPRICE, consider closing longs or initiating shorts:
- Confirms shift from bullish to bearish momentum
- Entry: On close below AVGPRICE
- Stop Loss: Above recent AVGPRICE high
- Target: Previous support or when close rises above AVGPRICE
```

### Divergence Analysis

**Bullish Divergence:**
- **Pattern**: Price makes lower low, but AVGPRICE makes higher low
- **Identification**: Compare recent price lows with corresponding AVGPRICE values
- **Significance**: Suggests the average trading level is improving even as price makes new lows
- **Reliability**: Moderate - works best when combined with momentum indicators
- **Example**: Stock drops to $50 (AVGPRICE $51), then to $49 (AVGPRICE $51.50). Price made new low but AVGPRICE held higher, suggesting accumulation.

**Bearish Divergence:**
- **Pattern**: Price makes higher high, but AVGPRICE makes lower high
- **Identification**: Compare recent price highs with corresponding AVGPRICE values
- **Significance**: Suggests the average trading level is deteriorating even as price makes new highs
- **Reliability**: Moderate - works best when combined with momentum indicators
- **Example**: Stock rises to $100 (AVGPRICE $98), then to $102 (AVGPRICE $97). Price made new high but AVGPRICE is lower, suggesting distribution.

## Best Practices

### Optimal Use Cases

When Average Price works best:

- **Market conditions**: All market conditions - trending, ranging, volatile, or calm. AVGPRICE is a neutral transformation that works universally.
- **Time frames**: Works on all timeframes - intraday (1-min, 5-min), daily, weekly, monthly. Most commonly used on daily charts.
- **Asset classes**: Applicable to all assets with OHLC data - stocks, forex, commodities, cryptocurrencies, indices, futures.
- **Volatility**: Particularly useful in volatile markets where close prices alone may misrepresent the period's true trading center.

### Combining with Other Indicators

Recommended indicator combinations:

- **With Moving Averages**: Apply SMA or EMA to AVGPRICE series for double-smoothed trend indicators. This reduces noise further while maintaining trend sensitivity.
  ```ruby
  avgprice = SQA::TAI.avgprice(open, high, low, close)
  avgprice_sma = SQA::TAI.sma(avgprice, period: 20)
  ```

- **With Momentum Indicators**: Use AVGPRICE as the input for RSI, MACD, or Stochastic instead of close prices. This provides momentum analysis based on the period's average rather than just the close.
  ```ruby
  avgprice = SQA::TAI.avgprice(open, high, low, close)
  rsi_on_avg = SQA::TAI.rsi(avgprice, period: 14)
  ```

- **With Volatility Indicators**: Compare AVGPRICE to Bollinger Bands or ATR to assess whether the average price is within normal volatility ranges.

- **With Volume**: Combine AVGPRICE with volume analysis. High volume at AVGPRICE levels confirms significance of that price zone.

### Common Pitfalls

What to avoid:

1. **Using alone for trading decisions**: AVGPRICE is a smoothing tool, not a complete trading system. Always combine with trend, momentum, or volume indicators for confirmation.

2. **Ignoring the price components**: While AVGPRICE provides a smooth average, check the individual OHLC components. Large spreads between high and low indicate volatility that AVGPRICE masks.

3. **Over-smoothing**: Applying multiple layers of smoothing (AVGPRICE → SMA → EMA) can create excessive lag and delayed signals.

4. **Neglecting timeframe context**: AVGPRICE on a 5-minute chart has different implications than on a daily chart. Match your analysis timeframe to your trading horizon.

### Parameter Selection Guidelines

AVGPRICE has no configurable parameters (always uses all four OHLC values), but consider these factors when using it:

- **Short-term trading (day trading)**:
  - Use AVGPRICE on 1-min to 15-min charts
  - Focus on Close vs AVGPRICE relationship for entry/exit timing
  - Quick reversals: Watch for close crossing AVGPRICE

- **Medium-term trading (swing trading)**:
  - Use AVGPRICE on hourly or daily charts
  - Apply moving averages to AVGPRICE for trend identification
  - Look for AVGPRICE trend alignment with price trend

- **Long-term trading (position trading)**:
  - Use AVGPRICE on daily or weekly charts
  - Focus on long-term AVGPRICE trends
  - Combine with fundamental analysis for major positions

## Practical Example

Complete trading example with context:

```ruby
require 'sqa/tai'

# Historical OHLC data for a stock
historical_data = [
  { open: 48.00, high: 48.70, low: 47.79, close: 48.20 },
  { open: 48.20, high: 48.72, low: 48.14, close: 48.61 },
  { open: 48.50, high: 48.90, low: 48.39, close: 48.75 },
  { open: 48.40, high: 48.87, low: 48.37, close: 48.63 },
  { open: 48.30, high: 48.82, low: 48.24, close: 48.74 },
  { open: 48.60, high: 49.05, low: 48.50, close: 48.95 },
  { open: 48.80, high: 49.20, low: 48.70, close: 49.10 },
  { open: 49.00, high: 49.50, low: 48.85, close: 49.35 },
  { open: 49.20, high: 49.80, low: 49.10, close: 49.60 },
  { open: 49.50, high: 50.00, low: 49.30, close: 49.85 }
]

# Extract OHLC arrays
open  = historical_data.map { |d| d[:open] }
high  = historical_data.map { |d| d[:high] }
low   = historical_data.map { |d| d[:low] }
close = historical_data.map { |d| d[:close] }

# Calculate Average Price
avgprice = SQA::TAI.avgprice(open, high, low, close)

# Calculate supporting indicators
avgprice_sma = SQA::TAI.sma(avgprice, period: 5)
close_sma = SQA::TAI.sma(close, period: 5)

# Current values
current_close = close.last
current_avgprice = avgprice.last
previous_close = close[-2]
previous_avgprice = avgprice[-2]

puts "=== Average Price Trading Analysis ==="
puts "Current Close: #{current_close.round(2)}"
puts "Current AVGPRICE: #{current_avgprice.round(2)}"
puts "Difference: #{(current_close - current_avgprice).round(4)}"
puts

# Analyze close strength relative to AVGPRICE
close_position = ((current_close - current_avgprice) / current_avgprice * 100).round(2)

if current_close > current_avgprice
  puts "STRONG CLOSE: Close is #{close_position.abs}% above AVGPRICE"
  puts "Interpretation: Bulls controlled the session"
  puts "Price closed in upper portion of the range"
elsif current_close < current_avgprice
  puts "WEAK CLOSE: Close is #{close_position.abs}% below AVGPRICE"
  puts "Interpretation: Bears controlled the session"
  puts "Price closed in lower portion of the range"
else
  puts "NEUTRAL CLOSE: Close equals AVGPRICE"
  puts "Interpretation: Balanced session, no clear advantage"
end
puts

# Check for crossovers (trading signals)
if previous_close <= previous_avgprice && current_close > current_avgprice
  puts "BUY SIGNAL: Close crossed above AVGPRICE"
  puts "Action: Consider long entry"
  puts "Entry: #{current_close.round(2)}"
  puts "Stop Loss: #{(current_close * 0.98).round(2)} (2% below)"
  puts "Rationale: Shift from weak to strong closes indicates potential uptrend"
  puts

elsif previous_close >= previous_avgprice && current_close < current_avgprice
  puts "SELL SIGNAL: Close crossed below AVGPRICE"
  puts "Action: Consider closing longs or short entry"
  puts "Entry: #{current_close.round(2)}"
  puts "Stop Loss: #{(current_close * 1.02).round(2)} (2% above)"
  puts "Rationale: Shift from strong to weak closes indicates potential downtrend"
  puts
end

# Trend analysis using AVGPRICE
puts "=== Trend Analysis ==="
recent_avgprices = avgprice.last(5)

if recent_avgprices.each_cons(2).all? { |a, b| b > a }
  puts "AVGPRICE Trend: STRONG UPTREND"
  puts "Last 5 AVGPRICE values are consistently rising"
  puts "Strategy: Look for dips to buy, hold long positions"
elsif recent_avgprices.each_cons(2).all? { |a, b| b < a }
  puts "AVGPRICE Trend: STRONG DOWNTREND"
  puts "Last 5 AVGPRICE values are consistently falling"
  puts "Strategy: Look for rallies to sell, avoid long positions"
else
  puts "AVGPRICE Trend: MIXED/CONSOLIDATING"
  puts "No clear directional trend in AVGPRICE"
  puts "Strategy: Range trading, wait for breakout confirmation"
end
puts

# Compare smoothed AVGPRICE to smoothed close
if avgprice_sma.last > close_sma.last
  puts "AVGPRICE SMA > Close SMA"
  puts "Interpretation: Recent closes have been below average ranges"
  puts "Potential: Market may be oversold or weakening"
elsif avgprice_sma.last < close_sma.last
  puts "AVGPRICE SMA < Close SMA"
  puts "Interpretation: Recent closes have been above average ranges"
  puts "Potential: Market may be overbought or strengthening"
else
  puts "AVGPRICE SMA ≈ Close SMA"
  puts "Interpretation: Balanced trading, closes near range midpoints"
end

# Volatility assessment using AVGPRICE
puts "\n=== Volatility Assessment ==="
volatility_score = historical_data.map do |d|
  avg = (d[:open] + d[:high] + d[:low] + d[:close]) / 4.0
  (d[:close] - avg).abs
end.last(5).reduce(:+) / 5.0

puts "Average deviation of Close from AVGPRICE (last 5 periods): #{volatility_score.round(4)}"
if volatility_score > current_avgprice * 0.01
  puts "HIGH VOLATILITY: Closes vary significantly from AVGPRICE"
  puts "Implication: Wide intraday ranges, increased risk"
elsif volatility_score < current_avgprice * 0.003
  puts "LOW VOLATILITY: Closes near AVGPRICE consistently"
  puts "Implication: Tight trading ranges, potential for breakout"
else
  puts "MODERATE VOLATILITY: Normal variation between Close and AVGPRICE"
end
```

## Related Indicators

### Similar Indicators
- **[MEDPRICE (Median Price)](medprice.md)**: Calculates (High + Low) / 2. MEDPRICE focuses only on the trading range extremes, while AVGPRICE includes open and close. Use MEDPRICE when you want to focus purely on the range center regardless of where the session opened or closed.

- **[TYPPRICE (Typical Price)](typprice.md)**: Calculates (High + Low + Close) / 3. TYPPRICE gives more weight to the close by excluding open. Use TYPPRICE when the close is most important, AVGPRICE when all four values matter equally.

- **[WCLPRICE (Weighted Close Price)](wclprice.md)**: Calculates (High + Low + Close + Close) / 4, giving double weight to close. WCLPRICE emphasizes the close while AVGPRICE treats all values equally. Use WCLPRICE when close is most significant.

### Complementary Indicators
- **[SMA (Simple Moving Average)](../overlap/sma.md)**: Apply SMA to AVGPRICE for a double-smoothed trend indicator. This combination reduces noise while maintaining trend identification capability.

- **[ATR (Average True Range)](../volatility/atr.md)**: Use ATR to measure volatility while AVGPRICE provides the price center. Together they give both central tendency and dispersion measures.

- **[RSI (Relative Strength Index)](../momentum/rsi.md)**: Calculate RSI using AVGPRICE instead of close for momentum analysis based on the period's average rather than just the closing value.

### Indicator Family
AVGPRICE belongs to the price transformation family:
- **AVGPRICE**: Equal-weighted average of all four OHLC values
- **MEDPRICE**: Simple average of high and low (range midpoint)
- **TYPPRICE**: Weighted average emphasizing close over high/low
- **WCLPRICE**: Heavily weighted toward close (double weight)

**When to prefer AVGPRICE**: When you want an unbiased, balanced representation of the period's trading activity. AVGPRICE gives equal importance to the open, high, low, and close, making it ideal when no single price point should dominate the analysis.

## Advanced Topics

### Multi-Timeframe Analysis

Use AVGPRICE across multiple timeframes for comprehensive analysis:

- **Higher timeframe AVGPRICE** (daily/weekly) identifies major support/resistance levels and primary trend direction
- **Lower timeframe AVGPRICE** (hourly/4H) provides precise entry/exit timing within the higher timeframe context
- Strongest signals occur when close crosses AVGPRICE on multiple timeframes simultaneously

Example: If daily AVGPRICE shows an uptrend and hourly close crosses above hourly AVGPRICE, this represents a high-probability long entry with both timeframes aligned.

### Market Regime Adaptation

AVGPRICE behavior in different market conditions:

- **Bull Markets**: AVGPRICE tends to rise steadily. Closes consistently above AVGPRICE indicate strong hands accumulating. Use AVGPRICE pullbacks as buying opportunities.

- **Bear Markets**: AVGPRICE trends downward. Closes consistently below AVGPRICE indicate distribution. Use AVGPRICE rallies as selling opportunities.

- **Ranging Markets**: AVGPRICE oscillates within a range. Use AVGPRICE as a dynamic support/resistance level within the range boundaries.

- **High Volatility**: Large gap between individual OHLC values means AVGPRICE provides significant smoothing. Particularly valuable for filtering noise.

- **Low Volatility**: AVGPRICE, close, and other price transformations converge tightly. Less differentiation between indicators.

### Statistical Validation

AVGPRICE reliability and characteristics:

- **Smoothing Effect**: AVGPRICE reduces standard deviation of price series by approximately 20-30% compared to close prices alone, depending on volatility.

- **Central Tendency**: AVGPRICE represents the true mathematical center of the period's price action, making it an unbiased measure of central tendency.

- **Lag**: Zero lag - AVGPRICE is calculated in real-time with current period data. Unlike moving averages, there is no historical dependency creating lag.

- **Correlation with Close**: High correlation (typically 0.95-0.99) with close prices, but smoother and less susceptible to extreme values.

- **Optimal Applications**: Most effective when used as input for other indicators or as a smoothed price series for trend analysis. Less effective as a standalone trading signal generator.

## References

- Murphy, John J. "Technical Analysis of the Financial Markets" (1999) - Discussion of price transformation indicators
- Achelis, Steven B. "Technical Analysis from A to Z" (2000) - Comprehensive overview of price transformation techniques
- Kirkpatrick, Charles D. & Dahlquist, Julie R. "Technical Analysis: The Complete Resource for Financial Market Technicians" (2010)
- [StockCharts: Price Transformations](https://school.stockcharts.com/doku.php?id=technical_indicators:price_transformations)
- [TradingView: Price Calculations](https://www.tradingview.com/support/solutions/43000594683-price-calculations/)

## See Also

- [Price Transform Indicators Overview](index.md)
- [MEDPRICE (Median Price)](medprice.md)
- [TYPPRICE (Typical Price)](typprice.md)
- [WCLPRICE (Weighted Close Price)](wclprice.md)
- [Basic Usage Guide](../../getting-started/basic-usage.md)
- [API Reference](../../api-reference.md)
