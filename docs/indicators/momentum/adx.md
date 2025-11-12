# ADX (Average Directional Index)

## Overview

The Average Directional Index (ADX) is a technical indicator that measures the strength of a trend, regardless of its direction. Developed by J. Welles Wilder Jr. as part of the Directional Movement System, ADX is one of the most reliable and widely-used trend strength indicators in technical analysis. Unlike most momentum indicators, ADX does not indicate trend direction—only the strength of the current trend.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `high` | Array | Required | Array of high prices |
| `low` | Array | Required | Array of low prices |
| `close` | Array | Required | Array of close prices |
| `period` | Integer | 14 | Number of periods for ADX calculation |

### Parameter Details


**Note**: Array elements should be ordered from oldest to newest (chronological order)

**high, low, close**
- Requires complete OHLC data (open not needed)
- Arrays must be of equal length
- Minimum data points needed: `(period * 2) + 1` for meaningful results
- Works on any timeframe (intraday, daily, weekly, monthly)

**period** (time_period)
- Wilder's original recommendation: 14 periods
- Shorter periods (7-10) create more responsive but noisier signals
- Longer periods (21-28) create smoother signals with fewer false readings
- Recommended ranges:
  - **Day trading**: 7-10 periods for faster signals
  - **Swing trading**: 14 periods (standard)
  - **Position trading**: 21-28 periods for long-term trend identification

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

high =  [48.70, 48.72, 48.90, 48.87, 48.82, 49.05, 49.20, 49.35,
         49.92, 50.19, 50.12, 50.10, 50.00, 49.75, 49.80, 50.00,
         50.20, 50.30, 50.50, 50.70]
low =   [47.79, 48.14, 48.39, 48.37, 48.24, 48.64, 48.94, 49.03,
         49.50, 49.87, 49.20, 49.00, 48.90, 49.00, 49.10, 49.20,
         49.30, 49.40, 49.50, 49.60]
close = [48.20, 48.61, 48.75, 48.63, 48.74, 49.03, 49.07, 49.32,
         49.91, 50.13, 49.53, 49.50, 49.25, 49.20, 49.45, 49.60,
         49.80, 50.00, 50.20, 50.40]

# Calculate 14-period ADX (standard)
adx = SQA::TAI.adx(high, low, close, period: 14)

puts "Current ADX: #{adx.last.round(2)}"
```

### With Custom Parameters

```ruby
# More sensitive 10-period ADX for day trading
adx_fast = SQA::TAI.adx(high, low, close, period: 10)

# Smoother 21-period ADX for position trading
adx_slow = SQA::TAI.adx(high, low, close, period: 21)

puts "Fast ADX (10): #{adx_fast.last.round(2)}"
puts "Standard ADX (14): #{adx.last.round(2)}"
puts "Slow ADX (21): #{adx_slow.last.round(2)}"
```

## Understanding the Indicator

### What It Measures

The ADX measures the strength of a trend by analyzing the directional movement of price:

- **Trend Strength**: How powerful the current trend is, regardless of direction
- **Market Condition**: Whether the market is trending or ranging
- **Trend Quality**: The reliability of the current directional movement
- **Trend Sustainability**: Whether a trend is strong enough to follow

ADX answers the question: "Is this market worth trading with trend-following strategies, or should I use range-bound strategies?"

### Calculation Method

ADX is derived from the Directional Movement System through several steps:

1. **Calculate Directional Movement (+DM and -DM)**: Measure upward and downward price movement
2. **Calculate True Range (TR)**: Measure price volatility
3. **Smooth +DM, -DM, and TR**: Apply Wilder's smoothing over the period
4. **Calculate Directional Indicators (+DI and -DI)**: Normalize directional movement
5. **Calculate DX**: Measure difference between +DI and -DI
6. **Calculate ADX**: Smooth DX values using Wilder's smoothing

**Formula:**
```
+DM = Current High - Previous High (if positive, else 0)
-DM = Previous Low - Current Low (if positive, else 0)

+DI = 100 × (Smoothed +DM / Smoothed TR)
-DI = 100 × (Smoothed -DM / Smoothed TR)

DX = 100 × |+DI - -DI| / (+DI + -DI)

ADX = Smoothed Average of DX

Where smoothing uses Wilder's method:
First value = Simple average of period values
Subsequent values = (Previous × (period-1) + Current) / period
```

### Indicator Characteristics

- **Range**: 0 to 100 (theoretically unbounded but rarely exceeds 100)
- **Type**: Trend strength oscillator (non-directional)
- **Lag**: High lag due to multiple smoothing operations (typically 2× period lag)
- **Best Used**: Identifying trending vs ranging markets, filtering trades, confirming trend strength
- **Limitations**: Does not indicate direction; high lag means late signals

## Interpretation

### Value Ranges

Specific guidance on what different ADX values indicate:

- **0-20**: Weak or absent trend. Market is ranging, consolidating, or moving sideways. Trend-following strategies are unreliable. Consider oscillators and range-bound strategies.
- **20-25**: Developing trend. A trend may be forming but is not yet established. Watch for ADX to continue rising for confirmation.
- **25-50**: Strong trend. Good conditions for trend-following strategies. The trend has clear direction and momentum. Most profitable zone for trend traders.
- **50-75**: Very strong trend. Excellent trending environment with sustained directional movement. Rare but highly profitable for trend followers.
- **75-100**: Extremely strong trend. Very rare and indicates exceptional directional movement. Often seen during major breakouts or market moves.

### Key Levels

- **Below 20**: No trend or weak trend. Market is choppy. Avoid trend-following strategies. Use range-bound approaches (oscillators, support/resistance).
- **20 Threshold**: Critical level. ADX crossing above 20 suggests a trend is developing. ADX falling below 20 suggests trend is ending.
- **25 Threshold**: Classic trend confirmation level. Many traders only take trend-following trades when ADX > 25.
- **50+ Level**: Indicates very strong trend but also potential exhaustion approaching. Watch for ADX to peak and decline.

### Signal Interpretation

How to read ADX signals:

1. **Trend Presence**
   - ADX > 25: Strong trend exists (use +DI/-DI to determine direction)
   - ADX < 20: No meaningful trend (use range-bound strategies)
   - ADX 20-25: Trend developing or ending (watch for confirmation)

2. **Trend Changes**
   - ADX rising: Trend strengthening (gaining momentum)
   - ADX falling: Trend weakening (losing momentum)
   - ADX flat: Trend strength stable

3. **Market Regime Identification**
   - ADX consistently below 20: Ranging market regime
   - ADX consistently above 25: Trending market regime
   - ADX oscillating around 20-25: Transitional market

## Trading Signals

### Buy Signals

Specific conditions that generate buy signals:

1. **Primary Signal**: ADX crosses above 20 or 25 with +DI > -DI
   - Confirms new uptrend is developing
   - Best when ADX is rising from low levels

2. **Trend Confirmation**: ADX > 25 with +DI > -DI and ADX rising
   - Indicates strong established uptrend
   - Look for pullbacks to enter

3. **Strength Filter**: Use ADX > 25 as filter for other buy signals
   - Only take long signals when ADX confirms trend strength
   - Reduces false signals in choppy markets

**Example Scenario:**
```
When ADX crosses above 25 with +DI (30) > -DI (15) and ADX rising,
consider long positions. Confirm with:
- Price breaking above resistance
- +DI rising while -DI falling
- Set stop loss below recent swing low
```

### Sell Signals

Specific conditions that generate sell signals:

1. **Primary Signal**: ADX crosses above 20 or 25 with -DI > +DI
   - Confirms new downtrend is developing
   - Best when ADX is rising from low levels

2. **Trend Confirmation**: ADX > 25 with -DI > +DI and ADX rising
   - Indicates strong established downtrend
   - Look for rallies to enter shorts

3. **Exit Signal**: ADX peaks above 50 then starts declining
   - May indicate trend exhaustion
   - Consider taking profits or tightening stops

**Example Scenario:**
```
When ADX crosses above 25 with -DI (35) > +DI (12) and ADX rising,
consider short positions. Confirm with:
- Price breaking below support
- -DI rising while +DI falling
- Set stop loss above recent swing high
```

### Divergence Analysis

**Trend Weakening:**
- **Pattern**: Price makes new high/low but ADX makes lower high/low
- **Identification**: Compare price extremes with corresponding ADX peaks
- **Significance**: Trend losing strength despite price extension
- **Reliability**: High when ADX was previously above 40
- **Example**: Stock rallies to new high at $120, but ADX peaks at 35 vs previous peak of 42. Uptrend weakening.

**Trend Strengthening:**
- **Pattern**: ADX making higher lows while in uptrend or downtrend
- **Identification**: Track ADX lows during pullbacks
- **Significance**: Trend retaining strength during corrections
- **Reliability**: Strongest when ADX stays above 25 during pullbacks
- **Example**: During pullbacks in uptrend, ADX bottoms at 28, 30, 32 successively. Strong persistent uptrend.

## Best Practices

### Optimal Use Cases

When ADX works best:

- **Market conditions**: Most effective in all conditions as a filter. Identifies when to trend-follow vs when to range-trade. Not affected by volatility.
- **Time frames**: Works on all timeframes but most reliable on daily and 4-hour charts. Higher timeframes produce more reliable trend identification.
- **Asset classes**: Excellent for all asset classes—stocks, forex, commodities, cryptocurrencies. Universal applicability.

### Combining with Other Indicators

Recommended indicator combinations:

- **With Directional Indicators (+DI/-DI)**: Essential combination. ADX shows strength, DI shows direction. Together they provide complete trend picture. Enter long when ADX > 25 and +DI > -DI.

- **With Moving Averages**: Use 50/200 MA for trend direction, ADX for trend strength. Only trade MA crossovers when ADX > 25. Avoids false crossovers in ranging markets.

- **With Oscillators (RSI, Stochastic)**: Use ADX to determine strategy. When ADX < 20, use RSI/Stochastic overbought/oversold signals. When ADX > 25, ignore oscillator extremes and trade with trend.

### Common Pitfalls

What to avoid:

1. **Trading Without Direction**: ADX alone doesn't show direction. Always combine with +DI/-DI or trend indicator. Trading on ADX strength without knowing direction leads to losses.

2. **Chasing High ADX**: When ADX exceeds 50-60, trend may be near exhaustion. Entering late into very high ADX can result in buying/selling at extremes.

3. **Ignoring Time Lag**: ADX has significant lag (2× period). By the time ADX confirms trend, much of the move may be over. Use with other leading indicators for earlier entry.

4. **Using Wrong Threshold**: Traditional 25 threshold may not suit all markets. High-volatility markets (crypto) may need 30-35. Low-volatility markets may use 20.

### Parameter Selection Guidelines

How to choose optimal parameters:

- **Short-term trading (day trading)**:
  - Period: 7-10 for faster trend detection
  - Threshold: 20-25 (lower threshold for more signals)
  - Focus: Quick identification of intraday trends

- **Medium-term trading (swing trading)**:
  - Period: 14 (standard Wilder setting)
  - Threshold: 25 (classic confirmation level)
  - Focus: Multi-day trend identification and following

- **Long-term trading (position trading)**:
  - Period: 21-28 for smoothest signals
  - Threshold: 30 (higher threshold for strongest trends only)
  - Focus: Major trend identification, monthly timeframe

- **Backtesting approach**: Test ADX period and threshold on historical data for your specific asset and timeframe. Find levels where ADX > threshold corresponded with sustained profitable trends.

## Practical Example

Complete trading example with context:

```ruby
require 'sqa/tai'

# Historical price data for a stock
high_prices = [
  48.70, 48.72, 48.90, 48.87, 48.82, 49.05, 49.20, 49.35, 49.92, 50.19,
  50.12, 50.10, 50.00, 49.75, 49.80, 50.00, 50.20, 50.30, 50.50, 50.70,
  50.80, 50.90, 51.00, 51.10, 51.20, 51.30, 51.40, 51.50, 51.60, 51.70
]
low_prices = [
  47.79, 48.14, 48.39, 48.37, 48.24, 48.64, 48.94, 49.03, 49.50, 49.87,
  49.20, 49.00, 48.90, 49.00, 49.10, 49.20, 49.30, 49.40, 49.50, 49.60,
  49.70, 49.80, 49.90, 50.00, 50.10, 50.20, 50.30, 50.40, 50.50, 50.60
]
close_prices = [
  48.20, 48.61, 48.75, 48.63, 48.74, 49.03, 49.07, 49.32, 49.91, 50.13,
  49.53, 49.50, 49.25, 49.20, 49.45, 49.60, 49.80, 50.00, 50.20, 50.40,
  50.60, 50.70, 50.90, 51.00, 51.10, 51.20, 51.30, 51.40, 51.50, 51.60
]

# Calculate ADX and directional indicators
adx = SQA::TAI.adx(high_prices, low_prices, close_prices, period: 14)
plus_di = SQA::TAI.plus_di(high_prices, low_prices, close_prices, period: 14)
minus_di = SQA::TAI.minus_di(high_prices, low_prices, close_prices, period: 14)

# Current values
current_price = close_prices.last
current_adx = adx.last
previous_adx = adx[-2]
adx_5_bars_ago = adx[-5]

current_plus_di = plus_di.last
current_minus_di = minus_di.last

puts "=== ADX Trend Analysis ==="
puts "Current Price: $#{current_price.round(2)}"
puts "Current ADX: #{current_adx.round(2)}"
puts "+DI: #{current_plus_di.round(2)}, -DI: #{current_minus_di.round(2)}"
puts

# Determine trend strength
if current_adx > 50
  trend_strength = "VERY STRONG"
elsif current_adx > 25
  trend_strength = "STRONG"
elsif current_adx > 20
  trend_strength = "DEVELOPING"
else
  trend_strength = "WEAK/ABSENT"
end

# Determine trend direction
if current_plus_di > current_minus_di
  trend_direction = "UPTREND"
  directional_spread = current_plus_di - current_minus_di
else
  trend_direction = "DOWNTREND"
  directional_spread = current_minus_di - current_plus_di
end

puts "Trend Strength: #{trend_strength}"
puts "Trend Direction: #{trend_direction}"
puts "Directional Spread: #{directional_spread.round(2)}"
puts

# Trading logic
if current_adx > 25
  # Strong trend - trend-following mode
  adx_change = current_adx - adx_5_bars_ago

  if trend_direction == "UPTREND"
    puts "TRADING SIGNAL: BUY/HOLD LONG"
    puts "Strategy: Trend-following uptrend"
    puts "Entry: Look for pullbacks to support"
    puts "Stop Loss: Below recent swing low"

    if adx_change > 0
      puts "ADX rising: Trend strengthening - High confidence"
    else
      puts "ADX falling: Trend weakening - Watch for exit"
    end

  else # DOWNTREND
    puts "TRADING SIGNAL: SELL/HOLD SHORT"
    puts "Strategy: Trend-following downtrend"
    puts "Entry: Look for rallies to resistance"
    puts "Stop Loss: Above recent swing high"

    if adx_change > 0
      puts "ADX rising: Trend strengthening - High confidence"
    else
      puts "ADX falling: Trend weakening - Watch for exit"
    end
  end

elsif current_adx < 20
  # Weak trend - range-bound mode
  puts "TRADING SIGNAL: RANGE-BOUND MARKET"
  puts "Strategy: Avoid trend-following"
  puts "Consider: Oscillator-based strategies (RSI, Stochastic)"
  puts "Look for: Support/resistance bounces"
  puts "Avoid: Breakout trading until ADX rises"

else # ADX between 20-25
  # Transitional period
  if current_adx > previous_adx
    puts "TRADING SIGNAL: POTENTIAL TREND DEVELOPING"
    puts "ADX rising from #{previous_adx.round(2)} to #{current_adx.round(2)}"
    puts "Watch for ADX to cross above 25 for trend confirmation"
    puts "Prepare for #{trend_direction} if ADX continues rising"
  else
    puts "TRADING SIGNAL: TREND ENDING"
    puts "ADX falling from #{previous_adx.round(2)} to #{current_adx.round(2)}"
    puts "Trend losing strength - consider taking profits"
    puts "Prepare for range-bound market if ADX continues falling"
  end
end

# Warn of potential exhaustion
if current_adx > 50
  puts "\n⚠️  WARNING: ADX Very High"
  puts "Trend may be overextended"
  puts "Watch for ADX peak and reversal"
  puts "Consider tightening stops or taking partial profits"
end
```

## Related Indicators

### Similar Indicators
- **[ADXR (ADX Rating)](adxr.md)**: Smoothed version of ADX that averages current ADX with ADX from N periods ago. ADXR is less volatile and provides more stable trend strength readings. Use ADXR when you want fewer false signals and smoother trend identification.

- **[DX (Directional Movement Index)](dx.md)**: The raw directional movement calculation before smoothing into ADX. DX is more volatile but more responsive. ADX is the preferred indicator as it smooths out DX noise.

### Complementary Indicators
- **[PLUS_DI (+DI)](plus_di.md)**: Measures positive directional movement (uptrend strength). Essential companion to ADX. Use +DI > -DI to identify uptrend direction when ADX shows strength.

- **[MINUS_DI (-DI)](minus_di.md)**: Measures negative directional movement (downtrend strength). Essential companion to ADX. Use -DI > +DI to identify downtrend direction when ADX shows strength.

- **[ATR (Average True Range)](../volatility/atr.md)**: Measures volatility and is part of the same Wilder system. Use ATR for position sizing and stop loss placement when ADX identifies trend.

### Indicator Family
ADX belongs to the Directional Movement System family developed by Wilder:
- **DX**: Raw directional movement calculation
- **ADX**: Smoothed DX showing trend strength
- **ADXR**: Further smoothed ADX
- **+DI/-DI**: Directional indicators showing trend direction

**When to prefer ADX**: For determining whether to use trend-following or range-bound strategies. ADX is the gold standard for trend strength identification and market regime filtering. Always combine with directional indicators (+DI/-DI) for complete analysis.

## Advanced Topics

### Multi-Timeframe Analysis

Use ADX across multiple timeframes for robust trend identification:

- **Higher timeframe ADX** (daily/weekly) identifies major trend strength and overall market regime
- **Lower timeframe ADX** (4H/1H) identifies short-term trend strength for precise entry timing
- Strongest trends when all timeframes show ADX > 25 (e.g., weekly ADX 35, daily ADX 30, 4H ADX 28)

Example: If weekly ADX is 40 (very strong trend) and daily ADX is 28 (strong trend), focus on daily pullbacks as entry opportunities in the direction of the weekly trend.

### Market Regime Adaptation

ADX behavior and optimal thresholds vary by market type:

- **Low Volatility Markets** (utilities, bonds): ADX rarely exceeds 30. Use threshold of 20 for trend confirmation. ADX > 25 indicates exceptionally strong trend.

- **Medium Volatility Markets** (large-cap stocks, major forex pairs): Standard ADX thresholds work well. Use 25 for trend confirmation, 40+ indicates very strong trend.

- **High Volatility Markets** (crypto, small-caps, emerging markets): ADX can frequently spike above 40. Consider using 30-35 as trend threshold to avoid false signals.

- **Trending Periods**: In sustained bull/bear markets, ADX stays elevated. Use ADX falling below 30 (instead of 25) as trend-end signal.

### Statistical Validation

ADX reliability metrics and considerations:

- **Lag Period**: ADX typically lags price by 2× the period setting. With 14-period ADX, expect signals about 28 bars after trend begins.

- **False Positive Rate**: ADX crossing above 25 fails to produce sustained trend approximately 30-40% of time. Always use with directional confirmation.

- **Optimal Threshold**: Studies show ADX threshold of 25 is optimal for most markets, but varies by asset. Backtest your specific market to find optimal level.

- **Trend Persistence**: When ADX crosses above 25, average trend duration is 1.5-2× the ADX period. With 14-period ADX, expect trend to last 21-28 bars on average.

- **Risk/Reward**: Trading only when ADX > 25 increases win rate by approximately 15-20% compared to taking all signals, while reducing trade frequency by 40-50%.

## References

- Wilder, J. Welles Jr. "New Concepts in Technical Trading Systems" (1978) - Original ADX publication and Directional Movement System
- Murphy, John J. "Technical Analysis of the Financial Markets" (1999) - Comprehensive ADX interpretation and application
- Kaufman, Perry J. "Trading Systems and Methods" (2013) - Statistical analysis of ADX performance
- [TradingView: ADX Educational Guide](https://www.tradingview.com/support/solutions/43000502344-average-directional-index-adx/)
- [StockCharts: ADX Technical Analysis](https://school.stockcharts.com/doku.php?id=technical_indicators:average_directional_index_adx)

## See Also

- [Momentum Indicators Overview](../index.md)
- [ADXR - Smoothed ADX](adxr.md)
- [+DI / -DI - Directional Indicators](plus_di.md)
- [Basic Usage Guide](../../getting-started/basic-usage.md)
- [API Reference](../../api-reference.md)
