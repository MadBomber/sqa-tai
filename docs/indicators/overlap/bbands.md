# BBANDS (Bollinger Bands)

## Overview

Bollinger Bands are one of the most widely used volatility indicators in technical analysis, developed by John Bollinger in the 1980s. The indicator consists of three bands: a middle band (typically a simple moving average) and upper/lower bands that are calculated using standard deviations from the middle band. These bands expand during volatile periods and contract during less volatile periods, providing traders with dynamic support and resistance levels while also highlighting overbought and oversold conditions.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `input_data` | Array | Required | The price data array (typically close prices) |
| `period` | Integer | 5 | Number of periods for middle band moving average |
| `nbdev_up` | Float | 2.0 | Number of standard deviations for upper band |
| `nbdev_down` | Float | 2.0 | Number of standard deviations for lower band |
| `ma_type` | Integer | 0 | Moving average type (0=SMA, 1=EMA, etc.) |

### Parameter Details


**Note**: Array elements should be ordered from oldest to newest (chronological order)

**input_data**
- Typically uses closing prices for standard analysis
- Can also use other price types (high, low, typical price) for specialized applications
- Requires at least `period` number of data points for calculation
- More historical data provides better context for band analysis

**period** (time_period)
- Standard setting is 20 periods (Bollinger's original recommendation)
- Shorter periods (10-15) create more sensitive bands with more signals
- Longer periods (30-50) create smoother bands with fewer but more reliable signals
- Recommended ranges:
  - Day trading: 10-15 periods for responsiveness
  - Swing trading: 20 periods (standard)
  - Position trading: 30-50 periods for major trends

**nbdev_up / nbdev_down**
- Standard deviation multiplier controls band width
- Default 2.0 captures approximately 95% of price action statistically
- Lower values (1.5) create tighter bands with more signals
- Higher values (2.5-3.0) create wider bands with fewer signals
- Asymmetric bands (different up/down values) can be used for skewed analysis

**ma_type**
- 0 (SMA) is the standard and most common setting
- Can use other MA types for different characteristics
- EMA (1) creates more responsive bands
- Most traders stick with SMA (0) for consistency

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41,
          46.22, 45.64, 46.21, 46.25, 46.08, 46.46,
          46.57, 45.95, 46.50, 46.02]

# Calculate Bollinger Bands with default settings
upper, middle, lower = SQA::TAI.bbands(prices, period: 20)

puts "Upper Band: #{upper.last.round(2)}"
puts "Middle Band: #{middle.last.round(2)}"
puts "Lower Band: #{lower.last.round(2)}"
```

### With Custom Parameters

```ruby
# Tighter bands for more signals (1.5 standard deviations)
upper, middle, lower = SQA::TAI.bbands(
  prices,
  period: 20,
  nbdev_up: 1.5,
  nbdev_down: 1.5
)

# Asymmetric bands for skewed analysis
upper, middle, lower = SQA::TAI.bbands(
  prices,
  period: 20,
  nbdev_up: 3.0,    # Wider upper band
  nbdev_down: 2.0   # Standard lower band
)
```

### Multiple Output Values

```ruby
# Bollinger Bands return three arrays
upper, middle, lower = SQA::TAI.bbands(prices, period: 20)

# Calculate %B (price position within bands)
current_price = prices.last
percent_b = ((current_price - lower.last) / (upper.last - lower.last)) * 100

puts "Upper: #{upper.last.round(2)}"
puts "Middle: #{middle.last.round(2)}"
puts "Lower: #{lower.last.round(2)}"
puts "%B: #{percent_b.round(2)}%"
```

## Understanding the Indicator

### What It Measures

Bollinger Bands measure price volatility and provide dynamic support and resistance levels:

- **Volatility**: Band width expands during volatile periods and contracts during calm periods
- **Relative Price Position**: Shows whether price is trading at extremes relative to recent history
- **Trend Strength**: Band direction and slope indicate trend momentum
- **Mean Reversion Potential**: Distance from middle band suggests overbought/oversold conditions

Bollinger Bands answer the question: "How far has price moved from its average, and is that movement sustainable?"

### Calculation Method

Bollinger Bands are calculated using statistical measures:

1. **Calculate Middle Band**: Compute simple moving average of closing prices over period
2. **Calculate Standard Deviation**: Measure price dispersion from the middle band
3. **Calculate Upper Band**: Add (standard deviation × nbdev_up) to middle band
4. **Calculate Lower Band**: Subtract (standard deviation × nbdev_down) from middle band
5. **Bands Adapt**: Width automatically adjusts based on market volatility

**Formula:**
```
Middle Band = SMA(close, period)
Standard Deviation = STDEV(close, period)
Upper Band = Middle Band + (nbdev_up × Standard Deviation)
Lower Band = Middle Band - (nbdev_down × Standard Deviation)

Additional Metrics:
Bandwidth = (Upper Band - Lower Band) / Middle Band × 100
%B = (Price - Lower Band) / (Upper Band - Lower Band) × 100
```

### Indicator Characteristics

- **Range**: Bands are unbounded but contain ~95% of price action with 2.0 standard deviations
- **Type**: Volatility envelope and momentum oscillator
- **Lag**: Moderate (based on moving average period)
- **Best Used**: Ranging markets, volatility breakouts, mean reversion strategies
- **Limitations**: Can remain expanded/contracted for extended periods in strong trends

## Interpretation

### Value Ranges

Specific guidance on what different positions mean:

- **Price at Upper Band**: Indicates strong upward momentum, potential overbought condition. In trending markets, can signal continuation rather than reversal.
- **Price at Middle Band**: Represents fair value or equilibrium. Often acts as support in uptrends or resistance in downtrends.
- **Price at Lower Band**: Indicates strong downward momentum, potential oversold condition. In downtrends, can signal continuation rather than reversal.
- **Price Outside Bands**: Rare occurrence (5% statistically) suggesting extreme conditions. May indicate strong trend or impending reversal.

### Key Levels

- **Upper Band**: Acts as dynamic resistance. Price touching or exceeding upper band suggests overbought conditions or strong bullish momentum.
- **Middle Band (20 SMA)**: Primary support/resistance level. Price crossing middle band often signals trend changes.
- **Lower Band**: Acts as dynamic support. Price touching or falling below lower band suggests oversold conditions or strong bearish momentum.
- **Band Width**: Measures volatility. Narrow bands (squeeze) often precede significant moves. Wide bands indicate high volatility.

### Signal Interpretation

How to read Bollinger Bands signals:

1. **Trend Direction**
   - Price consistently above middle band: Uptrend
   - Price consistently below middle band: Downtrend
   - Price oscillating around middle band: Range-bound market

2. **Volatility Changes**
   - Band squeeze (narrow bands): Low volatility, consolidation, big move brewing
   - Band expansion: High volatility, strong directional move occurring
   - Band contraction after expansion: Volatility decreasing, potential consolidation

3. **Reversal Signals**
   - W-pattern at lower band: Bullish reversal (lower low outside band, higher low inside band)
   - M-pattern at upper band: Bearish reversal (higher high outside band, lower high inside band)
   - Band walk: Price walking along upper band = strong uptrend; along lower band = strong downtrend

## Trading Signals

### Buy Signals

Specific conditions that generate buy signals:

1. **Primary Signal**: Price touches or penetrates lower band then closes back inside
   - Suggests oversold condition ending
   - Most reliable in ranging markets

2. **Confirmation Signal**: Price crosses above middle band from below
   - Indicates momentum shift from bearish to bullish
   - Works as trend-following entry

3. **W-Pattern**: Price makes lower low below lower band, then higher low inside band
   - Classic bullish reversal pattern
   - Strongest when combined with RSI divergence

**Example Scenario:**
```
When price drops below lower band (oversold), then closes back inside
the bands, consider a long position. Confirm with:
- Volume declining during selloff
- RSI showing bullish divergence
- Support level nearby
- Set stop loss below recent low
- Target: Middle band or upper band
```

### Sell Signals

Specific conditions that generate sell signals:

1. **Primary Signal**: Price touches or penetrates upper band then closes back inside
   - Suggests overbought condition ending
   - Most reliable in ranging markets

2. **Confirmation Signal**: Price crosses below middle band from above
   - Indicates momentum shift from bullish to bearish
   - Works as trend-following exit

3. **M-Pattern**: Price makes higher high above upper band, then lower high inside band
   - Classic bearish reversal pattern
   - Strongest when combined with RSI divergence

**Example Scenario:**
```
When price rises above upper band (overbought), then closes back inside
the bands, consider a short position or exit longs. Confirm with:
- Volume declining during rally
- RSI showing bearish divergence
- Resistance level nearby
- Set stop loss above recent high
- Target: Middle band or lower band
```

### Divergence Analysis

**Bullish Divergence:**
- **Pattern**: Price makes lower low at lower band, but momentum indicator (RSI) makes higher low
- **Identification**: Compare price lows touching lower band with RSI lows
- **Significance**: Suggests selling pressure exhausting, potential reversal ahead
- **Reliability**: High when combined with W-pattern formation
- **Example**: Stock drops from $100 to $95 (touching lower band), then to $92 (touching lower band). RSI shows 28 then 32, indicating weakening downside momentum.

**Bearish Divergence:**
- **Pattern**: Price makes higher high at upper band, but momentum indicator (RSI) makes lower high
- **Identification**: Compare price highs touching upper band with RSI highs
- **Significance**: Suggests buying pressure exhausting, potential reversal ahead
- **Reliability**: High when combined with M-pattern formation
- **Example**: Stock rises from $100 to $110 (touching upper band), then to $115 (touching upper band). RSI shows 78 then 72, indicating weakening upside momentum.

## Best Practices

### Optimal Use Cases

When Bollinger Bands work best:

- **Market conditions**: Most reliable in ranging or oscillating markets. In strong trends, price can "walk the bands" for extended periods.
- **Time frames**: Works on all timeframes but most reliable on daily and 4-hour charts. Lower timeframes generate more noise.
- **Asset classes**: Excellent for stocks, forex, and cryptocurrencies. Works well for any liquid market with sufficient volatility.

### Combining with Other Indicators

Recommended indicator combinations:

- **With Momentum Indicators (RSI, Stochastic)**: Use RSI to identify overbought/oversold conditions when price touches bands. Strongest signals occur when both indicators align (price at lower band + RSI oversold = strong buy).

- **With Volume Indicators (OBV, Volume)**: Confirm Bollinger Band signals with volume. Best signals show decreasing volume at band extremes (declining volume at upper band = weak rally, at lower band = weak selloff).

- **With Trend Indicators (ADX, Moving Averages)**: Use ADX or 200-period SMA to determine market regime. In strong trends (ADX > 25), don't counter-trade band touches. In weak trends (ADX < 20), favor mean reversion strategies.

### Common Pitfalls

What to avoid:

1. **Assuming automatic reversals**: Price touching bands doesn't guarantee reversal. In strong trends, price can walk along bands for extended periods. Always confirm with additional indicators.

2. **Ignoring the squeeze**: Narrow bands (squeeze) are often ignored, but they're powerful signals. A squeeze followed by expansion usually precedes significant moves. Don't trade during the squeeze; wait for breakout direction.

3. **Using fixed parameters everywhere**: Standard 20-period, 2.0 std dev works for daily charts but may need adjustment for other timeframes. Intraday may need shorter periods; weekly may need longer.

4. **Counter-trend trading in strong trends**: Trading reversals at bands during strong trends leads to losses. Identify trend first, then trade with trend using bands for entries.

### Parameter Selection Guidelines

How to choose optimal parameters:

- **Short-term trading (day trading)**:
  - Period: 10-15 for faster band adjustment
  - Std Dev: 1.5-2.0 for tighter bands
  - Focus: Quick reversals at bands, scalping opportunities

- **Medium-term trading (swing trading)**:
  - Period: 20 (standard) for balanced signals
  - Std Dev: 2.0 (traditional)
  - Focus: Multi-day moves, band squeeze breakouts

- **Long-term trading (position trading)**:
  - Period: 30-50 for smoother bands
  - Std Dev: 2.0-2.5 for wider envelope
  - Focus: Major trend changes, monthly patterns

- **Backtesting approach**: Test bandwidth statistics for your asset. Calculate historical bandwidth percentiles. If bands contain less than 90% of price action, increase std dev. If they contain more than 98%, decrease std dev.

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

# Calculate Bollinger Bands and supporting indicators
upper, middle, lower = SQA::TAI.bbands(historical_prices, period: 20)
rsi = SQA::TAI.rsi(historical_prices, period: 14)

# Current values
current_price = historical_prices.last
current_upper = upper.last
current_middle = middle.last
current_lower = lower.last
current_rsi = rsi.last

# Calculate bandwidth and %B
bandwidth = ((current_upper - current_lower) / current_middle * 100).round(2)
percent_b = ((current_price - current_lower) / (current_upper - current_lower) * 100).round(2)

puts "=== Bollinger Bands Analysis ==="
puts "Current Price: #{current_price.round(2)}"
puts "Upper Band: #{current_upper.round(2)}"
puts "Middle Band: #{current_middle.round(2)}"
puts "Lower Band: #{current_lower.round(2)}"
puts "Bandwidth: #{bandwidth}%"
puts "%B: #{percent_b}%"
puts "RSI: #{current_rsi.round(2)}"
puts

# Detect squeeze condition
recent_bandwidths = []
upper.last(10).each_with_index do |u, i|
  next unless u && middle[-10..-1][i] && lower[-10..-1][i]
  bw = (u - lower[-10..-1][i]) / middle[-10..-1][i] * 100
  recent_bandwidths << bw
end

avg_bandwidth = recent_bandwidths.sum / recent_bandwidths.size

if bandwidth < avg_bandwidth * 0.7
  puts "SQUEEZE DETECTED"
  puts "Bandwidth below 70% of recent average"
  puts "Volatility expansion likely - wait for breakout direction"
  puts
end

# Trading logic
if current_price <= current_lower && current_rsi < 30
  puts "STRONG BUY SIGNAL"
  puts "Price at lower band: #{current_price.round(2)}"
  puts "RSI oversold: #{current_rsi.round(2)}"
  puts "Entry: #{current_price.round(2)}"
  puts "Stop Loss: #{(current_price * 0.97).round(2)} (3% below entry)"
  puts "Target 1: #{current_middle.round(2)} (middle band)"
  puts "Target 2: #{current_upper.round(2)} (upper band)"

elsif current_price < current_middle && historical_prices[-2] <= lower[-2]
  puts "BUY SIGNAL"
  puts "Price bounced from lower band"
  puts "Entry: #{current_price.round(2)}"
  puts "Stop Loss: #{current_lower.round(2)}"
  puts "Target: #{current_middle.round(2)}"

elsif current_price >= current_upper && current_rsi > 70
  puts "STRONG SELL SIGNAL"
  puts "Price at upper band: #{current_price.round(2)}"
  puts "RSI overbought: #{current_rsi.round(2)}"
  puts "Consider taking profits or initiating shorts"
  puts "Entry: #{current_price.round(2)}"
  puts "Stop Loss: #{(current_price * 1.03).round(2)} (3% above entry)"
  puts "Target 1: #{current_middle.round(2)} (middle band)"
  puts "Target 2: #{current_lower.round(2)} (lower band)"

elsif current_price > current_middle && historical_prices[-2] >= upper[-2]
  puts "SELL SIGNAL"
  puts "Price rejected at upper band"
  puts "Consider taking profits"
  puts "Target: #{current_middle.round(2)}"

elsif percent_b > 50 && percent_b < 80
  puts "HOLD: Price in upper half of bands"
  puts "Bullish momentum but not yet extreme"

elsif percent_b > 20 && percent_b < 50
  puts "HOLD: Price in lower half of bands"
  puts "Bearish momentum but not yet extreme"

else
  puts "NO CLEAR SIGNAL"
  puts "Wait for price to reach band extremes"
end

# Band walk detection
upper_touches = 0
lower_touches = 0
historical_prices.last(5).each_with_index do |price, i|
  idx = -5 + i
  upper_touches += 1 if price >= upper[idx] * 0.99  # Within 1% of upper band
  lower_touches += 1 if price <= lower[idx] * 1.01  # Within 1% of lower band
end

if upper_touches >= 3
  puts "\nBAND WALK DETECTED"
  puts "Price walking along upper band (#{upper_touches}/5 bars)"
  puts "Strong uptrend - avoid shorting"
elsif lower_touches >= 3
  puts "\nBAND WALK DETECTED"
  puts "Price walking along lower band (#{lower_touches}/5 bars)"
  puts "Strong downtrend - avoid buying"
end
```

## Related Indicators

### Similar Indicators
- **[Keltner Channels](../volatility/keltner.md)**: Uses ATR instead of standard deviation for band calculation. Keltner Channels are smoother but less responsive to volatility spikes. Use Keltner when you want cleaner bands, Bollinger for volatility-based analysis.
- **[Acceleration Bands (ACCBANDS)](accbands.md)**: Uses high/low prices with acceleration factor. ACCBANDS are more responsive to momentum changes, while Bollinger Bands better reflect statistical volatility.

### Complementary Indicators
- **[RSI (Relative Strength Index)](../momentum/rsi.md)**: Perfect companion to Bollinger Bands. Use RSI to confirm overbought/oversold conditions at band extremes. Strongest signals when both indicators align.
- **[MACD](../momentum/macd.md)**: Use MACD for trend direction and momentum confirmation. MACD crossovers at Bollinger Band extremes provide powerful combined signals.
- **[Volume (OBV)](../volume/obv.md)**: Confirms band signals. Best Bollinger Band reversals show declining volume at extremes (declining volume at upper band = weak rally).

### Indicator Family
Bollinger Bands belong to the volatility envelope family:
- **Bollinger Bands**: Standard deviation-based, most popular
- **Keltner Channels**: ATR-based, smoother
- **Donchian Channels**: High/low-based, breakout-focused
- **Price Envelopes**: Percentage-based, simple construction

**When to prefer Bollinger Bands**: For volatility analysis, statistical overbought/oversold identification, and mean reversion strategies. Bollinger Bands adapt automatically to changing market conditions through standard deviation calculation.

## Advanced Topics

### Multi-Timeframe Analysis

Use Bollinger Bands across multiple timeframes for comprehensive analysis:

- **Higher timeframe bands** (daily/weekly) identify major support/resistance zones and trend direction
- **Lower timeframe bands** (4H/1H) provide precise entry timing within the higher timeframe trend
- Strongest signals when price reaches lower timeframe band within higher timeframe band zone

Example: If price touches daily lower band and then 4H lower band, this represents a high-probability long entry with both timeframes supporting the setup.

### Market Regime Adaptation

Bollinger Bands behavior changes in different market conditions:

- **Trending Markets**: Price tends to walk along one band. Upper band acts as support in uptrends; lower band as resistance in downtrends. Don't fade the trend. Use opposite band for entries in trend direction.
- **Ranging Markets**: Price oscillates between bands. Traditional buy-at-lower-band, sell-at-upper-band strategy works best. Middle band acts as pivot.
- **Low Volatility**: Bands contract into squeeze. Avoid trading until breakout. Squeeze often precedes significant moves.
- **High Volatility**: Bands expand rapidly. Price may overshoot bands more frequently. Use wider stop losses and be prepared for whipsaws.

### Statistical Validation

Bollinger Bands reliability metrics and considerations:

- **Coverage**: With 2.0 standard deviations, bands should contain approximately 95% of price action. Test your specific market to verify.
- **Reversal Success Rate**: Price touching bands leads to reversal about 50-60% in ranging markets, much lower (30-40%) in trending markets. Always identify trend first.
- **Squeeze Effectiveness**: Historically, 70-80% of squeezes (bandwidth in lowest 20th percentile) lead to significant moves within 5-10 bars. Direction remains unpredictable.
- **Optimal Bandwidth**: Varies by asset. Calculate historical bandwidth statistics. If current bandwidth is in lowest 10th percentile, volatility expansion is highly likely.

## References

- Bollinger, John. "Bollinger on Bollinger Bands" (2001) - The definitive guide by the indicator's creator
- Bollinger, John. "Using Bollinger Bands," Stocks & Commodities V. 10:2 (47-51)
- [BollingerBands.com](https://www.bollingerbands.com/) - Official website with educational resources
- [StockCharts: Bollinger Bands](https://school.stockcharts.com/doku.php?id=technical_indicators:bollinger_bands) - Comprehensive technical analysis guide
- [TradingView: Bollinger Bands Educational Guide](https://www.tradingview.com/support/solutions/43000501971-bollinger-bands-bb/)

## See Also

- [Overlap Studies Overview](../index.md)
- [Simple Moving Average (SMA)](sma.md) - Used for middle band calculation
- [Standard Deviation (STDDEV)](../statistical/stddev.md) - Core calculation component
- [RSI](../momentum/rsi.md) - Excellent companion indicator
- [Basic Usage Guide](../../getting-started/basic-usage.md)
- [API Reference](../../api-reference.md)
