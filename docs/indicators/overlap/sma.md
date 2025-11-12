# SMA (Simple Moving Average)

## Overview

The Simple Moving Average (SMA) is the most basic and widely used moving average in technical analysis. Developed as one of the earliest technical indicators, SMA calculates the arithmetic mean of prices over a specified period, giving equal weight to each data point. Despite its simplicity, the SMA remains a cornerstone of technical analysis, serving as a foundation for trend identification, support/resistance levels, and as a component in numerous other technical indicators.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `input_data` | Array | Required | The price data array (typically close prices) |
| `period` | Integer | 30 | Number of periods for SMA calculation |

### Parameter Details


**Note**: Array elements should be ordered from oldest to newest (chronological order)

**input_data**
- Typically uses closing prices for standard trend analysis
- Can use other price types (high, low, open, typical price) for specialized analysis
- Requires at least `period` number of data points for calculation
- More historical data provides better context for crossover and trend analysis

**period** (time_period)
- No universally "correct" period; choice depends on trading timeframe and style
- Common periods and their uses:
  - 10-20 periods: Short-term trends, day trading
  - 50 periods: Intermediate trends, swing trading
  - 200 periods: Long-term trends, major support/resistance
- Shorter periods are more responsive but generate more noise
- Longer periods are smoother but have greater lag
- Recommended ranges:
  - Day trading: 9-20 periods
  - Swing trading: 20-50 periods
  - Position trading: 50-200 periods

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41]

# Calculate 5-period SMA
sma = SQA::TAI.sma(prices, period: 5)

puts "Current SMA: #{sma.last.round(2)}"
```

### With Custom Parameters

```ruby
# Calculate multiple SMAs for trend analysis
sma_20 = SQA::TAI.sma(prices, period: 20)   # Short-term trend
sma_50 = SQA::TAI.sma(prices, period: 50)   # Intermediate trend
sma_200 = SQA::TAI.sma(prices, period: 200) # Long-term trend

puts "20-period SMA: #{sma_20.last.round(2)}"
puts "50-period SMA: #{sma_50.last.round(2)}"
puts "200-period SMA: #{sma_200.last.round(2)}"
```

## Understanding the Indicator

### What It Measures

The Simple Moving Average measures the average price over a specified period:

- **Trend Direction**: Shows the overall direction of price movement by smoothing out short-term fluctuations
- **Momentum**: The slope of the SMA indicates trend strength (steep = strong, flat = weak)
- **Support/Resistance**: Acts as dynamic support in uptrends and resistance in downtrends
- **Fair Value**: Represents a consensus price level over the specified period

SMA answers the question: "What has been the average price over the recent period, and is current price above or below that average?"

### Calculation Method

The SMA is calculated using simple arithmetic:

1. **Sum Prices**: Add up all closing prices over the specified period
2. **Divide by Period**: Divide the sum by the number of periods
3. **Move Forward**: For each new price, drop the oldest price and add the newest
4. **Repeat**: This creates a moving average that follows price action

**Formula:**
```
SMA = (P1 + P2 + P3 + ... + Pn) / n

Where:
P = Price at each period
n = Number of periods

Example for 5-period SMA:
Prices: [10, 11, 12, 11, 10]
SMA = (10 + 11 + 12 + 11 + 10) / 5 = 54 / 5 = 10.8
```

### Indicator Characteristics

- **Range**: Unbounded; moves with price
- **Type**: Trend-following overlay indicator
- **Lag**: High lag due to equal weighting of all periods
- **Best Used**: Trending markets, trend identification, classical technical analysis
- **Limitations**: Lags price action significantly; all data points weighted equally regardless of recency

## Interpretation

### Value Ranges

The SMA itself doesn't have fixed ranges, but its relationship to price provides signals:

- **Price Above SMA**: Bullish condition; price is trading above average. Suggests uptrend or bullish momentum.
- **Price At SMA**: Equilibrium point; price at fair value. Often acts as support or resistance.
- **Price Below SMA**: Bearish condition; price is trading below average. Suggests downtrend or bearish momentum.
- **Distance from SMA**: Large deviations suggest overbought/oversold conditions and potential mean reversion.

### Key Levels

- **50-period SMA**: Widely watched intermediate trend indicator. Price above = intermediate uptrend, below = intermediate downtrend.
- **200-period SMA**: Most important SMA for long-term trend. Acts as major support/resistance. Often called "the line in the sand."
- **Multiple SMA Alignment**: When price > SMA20 > SMA50 > SMA200, this shows strong uptrend with all timeframes aligned.

### Signal Interpretation

How to read SMA signals:

1. **Trend Direction**
   - SMA sloping upward: Uptrend
   - SMA sloping downward: Downtrend
   - SMA flat: Consolidation or range-bound

2. **Trend Strength**
   - Steep SMA slope: Strong trend
   - Gradual SMA slope: Moderate trend
   - Flat SMA: Weak or no trend

3. **Reversal Signals**
   - Price crosses above SMA: Potential bullish reversal
   - Price crosses below SMA: Potential bearish reversal
   - SMA crossovers: Golden Cross (bullish), Death Cross (bearish)

## Trading Signals

### Buy Signals

Specific conditions that generate buy signals:

1. **Primary Signal**: Price crosses above SMA from below
   - Indicates momentum shift from bearish to bullish
   - Most reliable when SMA is sloping upward

2. **Confirmation Signal**: Price pulls back to SMA and bounces (SMA acts as support)
   - Shows SMA is respected as support level
   - Provides lower-risk entry in established uptrend

3. **Golden Cross**: Shorter-period SMA crosses above longer-period SMA
   - Classic bullish signal (e.g., 50 SMA crosses above 200 SMA)
   - Indicates major trend change to bullish

**Example Scenario:**
```
When price crosses above 50-period SMA while the SMA is rising,
consider a long position. Confirm with:
- Volume increasing on the breakout
- Price closing above SMA (not just touching)
- 200-period SMA also sloping upward
- Set stop loss below recent swing low or below SMA
- Target: Next resistance level or previous high
```

### Sell Signals

Specific conditions that generate sell signals:

1. **Primary Signal**: Price crosses below SMA from above
   - Indicates momentum shift from bullish to bearish
   - Most reliable when SMA is sloping downward

2. **Confirmation Signal**: Price rallies to SMA and rejects (SMA acts as resistance)
   - Shows SMA is respected as resistance level
   - Provides lower-risk entry for shorts in established downtrend

3. **Death Cross**: Shorter-period SMA crosses below longer-period SMA
   - Classic bearish signal (e.g., 50 SMA crosses below 200 SMA)
   - Indicates major trend change to bearish

**Example Scenario:**
```
When price crosses below 50-period SMA while the SMA is falling,
consider closing longs or initiating shorts. Confirm with:
- Volume increasing on the breakdown
- Price closing below SMA (not just touching)
- 200-period SMA also sloping downward
- Set stop loss above recent swing high or above SMA
- Target: Next support level or previous low
```

### Divergence Analysis

While SMA itself doesn't show divergence, comparing price action to SMA behavior provides insights:

**Bullish Setup:**
- **Pattern**: Price makes lower low but remains above rising SMA
- **Identification**: SMA continues rising while price corrects
- **Significance**: Suggests correction within uptrend, buying opportunity
- **Reliability**: High when price stays above SMA during correction

**Bearish Setup:**
- **Pattern**: Price makes higher high but SMA begins flattening or falling
- **Identification**: Price momentum weakening despite higher prices
- **Significance**: Suggests weakening uptrend, potential reversal
- **Reliability**: High when price starts oscillating around SMA after trend

## Best Practices

### Optimal Use Cases

When SMA works best:

- **Market conditions**: Most effective in trending markets. Less useful in choppy, range-bound markets where frequent crossovers generate whipsaws.
- **Time frames**: Works on all timeframes. Daily charts most popular for 50/200 SMA. Hourly charts common for day trading with 20/50 SMA.
- **Asset classes**: Universal application across stocks, forex, commodities, cryptocurrencies. Particularly reliable for liquid, established markets.

### Combining with Other Indicators

Recommended indicator combinations:

- **With Momentum Indicators (RSI, MACD)**: Use SMA for trend direction, RSI/MACD for timing. Only take RSI buy signals when price is above SMA (with-trend trades).

- **With Volume Indicators**: Confirm SMA crossovers with volume. Valid breakouts above SMA should show increased volume. Low volume crossovers are less reliable.

- **With Other Moving Averages**: Multiple SMA periods (20/50/200) create trend hierarchy. EMA for faster signals, SMA for trend confirmation. Shorter SMA crossing longer SMA generates crossover signals.

### Common Pitfalls

What to avoid:

1. **Using single SMA in isolation**: SMA alone generates many false signals. Always combine with trend confirmation, volume, or momentum indicators.

2. **Chasing crossovers in choppy markets**: In ranging markets, price crosses SMA frequently causing whipsaws. Use ADX or other trend strength indicators to filter choppy periods.

3. **Ignoring the lag**: SMA lags price significantly. By the time SMA signals a trend change, much of the move may be over. Use shorter periods or leading indicators for early entries.

4. **Wrong period for timeframe**: Using daily chart parameters (50/200) on 5-minute charts, or vice versa, generates poor results. Adjust periods to your trading timeframe.

### Parameter Selection Guidelines

How to choose optimal parameters:

- **Short-term trading (day trading)**:
  - Period: 9-20 for trend direction
  - Crossover pairs: 9/21 or 12/26
  - Focus: Intraday trends, quick reversals

- **Medium-term trading (swing trading)**:
  - Period: 20-50 (standard)
  - Crossover pairs: 20/50 or 50/100
  - Focus: Multi-day/week trends

- **Long-term trading (position trading)**:
  - Period: 50-200 for major trends
  - Crossover pairs: 50/200 (Golden/Death Cross)
  - Focus: Monthly/yearly trends, major support/resistance

- **Backtesting approach**: Test various periods on historical data. Calculate win rate and profit factor for price-SMA crosses. Optimal period shows best risk/reward for your specific market and timeframe.

## Practical Example

Complete trading example with context:

```ruby
require 'sqa/tai'

# Historical price data for a stock
historical_prices = [
  44.34, 44.09, 44.15, 43.61, 44.33, 44.83, 45.10, 45.42,
  45.84, 46.08, 46.03, 46.41, 46.22, 45.64, 46.21, 46.25,
  46.08, 46.46, 46.57, 45.95, 46.50, 46.02, 45.55, 46.08,
  46.34, 46.00, 45.75, 46.45, 47.02, 46.87, 47.20, 47.55,
  47.85, 48.10, 48.35, 48.60, 48.85, 49.10, 49.35, 49.60,
  49.85, 50.10, 50.35, 50.60, 50.85, 51.10, 51.35, 51.60,
  51.85, 52.10
]

# Calculate multiple SMAs for comprehensive analysis
sma_20 = SQA::TAI.sma(historical_prices, period: 20)
sma_50 = SQA::TAI.sma(historical_prices, period: 50)

# Current values
current_price = historical_prices.last
current_sma_20 = sma_20.last
current_sma_50 = sma_50.last

puts "=== SMA Trading Analysis ==="
puts "Current Price: #{current_price.round(2)}"
puts "20-period SMA: #{current_sma_20.round(2)}"
puts "50-period SMA: #{current_sma_50.round(2)}"
puts

# Determine overall trend
if current_price > current_sma_20 && current_sma_20 > current_sma_50
  trend = "STRONG UPTREND"
  bias = "BULLISH"
elsif current_price < current_sma_20 && current_sma_20 < current_sma_50
  trend = "STRONG DOWNTREND"
  bias = "BEARISH"
elsif current_price > current_sma_20
  trend = "SHORT-TERM UPTREND"
  bias = "CAUTIOUSLY BULLISH"
elsif current_price < current_sma_20
  trend = "SHORT-TERM DOWNTREND"
  bias = "CAUTIOUSLY BEARISH"
else
  trend = "NEUTRAL/CONSOLIDATING"
  bias = "NEUTRAL"
end

puts "Trend: #{trend}"
puts "Bias: #{bias}"
puts

# Detect crossovers
if sma_20[-2] < sma_50[-2] && sma_20.last > sma_50.last
  puts "GOLDEN CROSS DETECTED!"
  puts "20 SMA crossed above 50 SMA"
  puts "Strong bullish signal - major trend change"
  puts
elsif sma_20[-2] > sma_50[-2] && sma_20.last < sma_50.last
  puts "DEATH CROSS DETECTED!"
  puts "20 SMA crossed below 50 SMA"
  puts "Strong bearish signal - major trend change"
  puts
end

# Check price position relative to SMAs
price_to_sma20_pct = ((current_price - current_sma_20) / current_sma_20 * 100).round(2)
price_to_sma50_pct = ((current_price - current_sma_50) / current_sma_50 * 100).round(2)

puts "Price distance from 20 SMA: #{price_to_sma20_pct}%"
puts "Price distance from 50 SMA: #{price_to_sma50_pct}%"
puts

# Trading signals
if current_price > current_sma_20 && historical_prices[-2] <= sma_20[-2]
  puts "BUY SIGNAL: Price crossed above 20 SMA"
  puts "Entry: #{current_price.round(2)}"
  puts "Stop Loss: #{(current_sma_20 * 0.98).round(2)} (2% below 20 SMA)"
  puts "Target: Previous resistance or extended move"
  puts

elsif current_price < current_sma_20 && historical_prices[-2] >= sma_20[-2]
  puts "SELL SIGNAL: Price crossed below 20 SMA"
  puts "Entry: #{current_price.round(2)}"
  puts "Stop Loss: #{(current_sma_20 * 1.02).round(2)} (2% above 20 SMA)"
  puts "Target: Previous support or extended move"
  puts

elsif price_to_sma20_pct > 5 && bias == "BULLISH"
  puts "TAKE PROFITS SIGNAL"
  puts "Price extended #{price_to_sma20_pct}% above 20 SMA"
  puts "Consider taking partial profits"
  puts "Potential mean reversion to SMA"
  puts

elsif price_to_sma20_pct < -5 && bias == "BEARISH"
  puts "COVER SHORTS SIGNAL"
  puts "Price extended #{price_to_sma20_pct.abs}% below 20 SMA"
  puts "Consider covering partial shorts"
  puts "Potential mean reversion to SMA"
  puts

elsif price_to_sma20_pct.abs < 1
  puts "PRICE AT SMA"
  if bias == "BULLISH"
    puts "Price testing 20 SMA support"
    puts "Watch for bounce - potential buying opportunity"
  elsif bias == "BEARISH"
    puts "Price testing 20 SMA resistance"
    puts "Watch for rejection - potential shorting opportunity"
  end
  puts

else
  puts "NO CLEAR SIGNAL - HOLD CURRENT POSITIONS"
  puts "Waiting for price to reach key levels"
  puts
end

# Calculate SMA slope for trend strength
sma20_slope = ((current_sma_20 - sma_20[-5]) / sma_20[-5] * 100).round(2)
sma50_slope = ((current_sma_50 - sma_50[-10]) / sma_50[-10] * 100).round(2)

puts "=== Trend Strength Analysis ==="
puts "20 SMA slope (5 bars): #{sma20_slope}%"
puts "50 SMA slope (10 bars): #{sma50_slope}%"

if sma20_slope > 2
  puts "Strong upward momentum on 20 SMA"
elsif sma20_slope < -2
  puts "Strong downward momentum on 20 SMA"
else
  puts "Flat or weak momentum on 20 SMA"
end
```

## Related Indicators

### Similar Indicators
- **[Exponential Moving Average (EMA)](ema.md)**: Gives more weight to recent prices. EMA is more responsive than SMA but also more prone to whipsaws. Use EMA when you need faster signals, SMA for smoother analysis.
- **[Weighted Moving Average (WMA)](wma.md)**: Applies linear weighting. WMA falls between SMA and EMA in responsiveness. Less common but useful for balanced approach.

### Complementary Indicators
- **[Bollinger Bands](bbands.md)**: Uses SMA as middle band with standard deviation bands. Perfect combination for volatility and mean reversion analysis.
- **[MACD](../momentum/macd.md)**: Uses EMAs but combines well with SMA for trend confirmation. Use 200 SMA for long-term trend, MACD for timing.
- **[ADX](../momentum/adx.md)**: Measures trend strength. Use ADX to determine when SMA signals are most reliable (ADX > 25 = strong trend, use SMA crosses).

### Indicator Family
SMA belongs to the moving average family:
- **SMA**: Equal weighting, smoothest, highest lag
- **EMA**: Exponential weighting, more responsive
- **WMA**: Linear weighting, balanced approach
- **DEMA/TEMA**: Multiple smoothing, lowest lag

**When to prefer SMA**: For classical technical analysis, identifying major support/resistance (especially 200 SMA), and when you want the most reliable long-term trend indicator. SMA's lag is actually beneficial for filtering noise and avoiding false signals.

## Advanced Topics

### Multi-Timeframe Analysis

Use SMA across multiple timeframes for comprehensive analysis:

- **Higher timeframe SMA** (daily 200 SMA) identifies major trend direction - this is your primary trend filter
- **Lower timeframe SMA** (hourly 20 SMA) provides precise entry timing within the higher timeframe trend
- Strongest trades when all timeframes align (price above daily 200 SMA, hourly 20 SMA, and 4H 50 SMA)

Example: If daily 200 SMA is rising and price is above it, only take hourly 20 SMA buy signals. Ignore sell signals against the major trend.

### Market Regime Adaptation

SMA behavior and effectiveness changes in different market conditions:

- **Trending Markets**: SMA works excellently. Price respects SMA as support/resistance. Use SMA crossovers and price-SMA crosses confidently.
- **Ranging Markets**: SMA generates many false crossovers. Price oscillates above/below SMA frequently. Consider using shorter periods or different indicators (RSI, Stochastic).
- **High Volatility**: Price makes large moves away from SMA. Increase SMA period to filter noise, or use ATR for stop losses instead of SMA-based stops.
- **Low Volatility**: Price stays very close to SMA. Small moves trigger signals. Tighten stop losses and take quicker profits.

### Statistical Validation

SMA reliability metrics and considerations:

- **Crossover Success Rate**: Price crossing SMA has approximately 50-60% success rate in trending markets, but only 40-45% in ranging markets. Always identify trend regime first.
- **Golden/Death Cross Effectiveness**: 50/200 SMA crosses are lagging signals but historically reliable. Success rate approximately 60-70% but significant portion of move completed before signal.
- **SMA as Support/Resistance**: 200 SMA acts as support/resistance with approximately 65-70% success rate in established trends. First touch usually holds better than subsequent touches.
- **Optimal Period**: Varies by market. Test historically: calculate win rate for price-SMA crosses at various periods (10, 20, 30, 50, 100, 200). Peak win rate indicates optimal period for your specific market.

## References

- Murphy, John J. "Technical Analysis of the Financial Markets" (1999) - Classic comprehensive guide covering moving averages
- Kirkpatrick, Charles D. and Dahlquist, Julie R. "Technical Analysis: The Complete Resource for Financial Market Technicians" (2010)
- [StockCharts: Moving Averages](https://school.stockcharts.com/doku.php?id=technical_indicators:moving_averages) - Educational resource for MA analysis
- [TradingView: Moving Averages Guide](https://www.tradingview.com/support/solutions/43000502589-moving-average-ma/)
- Granville, Joseph. "Granville's New Strategy of Daily Stock Market Timing for Maximum Profit" (1976) - Early work on moving average strategies

## See Also

- [Overlap Studies Overview](../index.md)
- [Exponential Moving Average (EMA)](ema.md) - More responsive alternative
- [Bollinger Bands](bbands.md) - Uses SMA as foundation
- [MACD](../momentum/macd.md) - Uses EMAs but complements SMA analysis
- [Basic Usage Guide](../../getting-started/basic-usage.md)
- [API Reference](../../api-reference.md)
