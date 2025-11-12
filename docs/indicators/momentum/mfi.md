# MFI (Money Flow Index)

## Overview

The Money Flow Index (MFI) is a momentum oscillator that incorporates both price and volume data to measure buying and selling pressure. Often called "volume-weighted RSI," MFI oscillates between 0 and 100 and uses typical price and volume to identify overbought and oversold conditions. Developed by Gene Quong and Avrum Soudack, MFI is particularly effective for spotting potential reversals when price and volume diverge.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `high` | Array | Required | Array of high prices |
| `low` | Array | Required | Array of low prices |
| `close` | Array | Required | Array of close prices |
| `volume` | Array | Required | Array of volume values |
| `period` | Integer | 14 | Number of periods for MFI calculation |

### Parameter Details


**Note**: Array elements should be ordered from oldest to newest (chronological order)

**high, low, close**
- Complete OHLC data required for typical price calculation
- Arrays must all be of equal length
- Typical Price = (High + Low + Close) / 3
- Works on any timeframe with volume data

**volume**
- Must correspond to same timeframe as price data
- Can be actual volume, tick volume, or other volume measures
- Higher volume gives more weight to price movements
- Essential for MFI calculation—cannot be omitted

**period** (time_period)
- Standard setting is 14 periods (similar to RSI)
- Shorter periods (7-10) create more sensitive indicator with more signals
- Longer periods (20-25) create smoother indicator with fewer, more reliable signals
- Recommended ranges:
  - **Day trading**: 7-10 periods for quick signals
  - **Swing trading**: 14 periods (standard)
  - **Position trading**: 20-25 periods for major reversals

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

high =   [48.70, 48.72, 48.90, 48.87, 48.82, 49.05, 49.20, 49.35,
          49.92, 50.19, 50.12, 50.10, 50.00, 49.75, 49.80, 50.00,
          50.20, 50.30]
low =    [47.79, 48.14, 48.39, 48.37, 48.24, 48.64, 48.94, 49.03,
          49.50, 49.87, 49.20, 49.00, 48.90, 49.00, 49.10, 49.20,
          49.30, 49.40]
close =  [48.20, 48.61, 48.75, 48.63, 48.74, 49.03, 49.07, 49.32,
          49.91, 50.13, 49.53, 49.50, 49.25, 49.20, 49.45, 49.60,
          49.80, 50.00]
volume = [2800, 3200, 3100, 2900, 3400, 3800, 3600, 4100,
          4500, 4800, 3900, 3500, 3200, 3000, 3300, 3700,
          4000, 4200]

# Calculate 14-period MFI (standard)
mfi = SQA::TAI.mfi(high, low, close, volume, period: 14)

puts "Current MFI: #{mfi.last.round(2)}"
```

### With Custom Parameters

```ruby
# More sensitive 10-period MFI
mfi_fast = SQA::TAI.mfi(high, low, close, volume, period: 10)

# Smoother 20-period MFI
mfi_slow = SQA::TAI.mfi(high, low, close, volume, period: 20)

puts "Fast MFI (10): #{mfi_fast.last.round(2)}"
puts "Standard MFI (14): #{mfi.last.round(2)}"
puts "Slow MFI (20): #{mfi_slow.last.round(2)}"
```

## Understanding the Indicator

### What It Measures

The MFI measures the flow of money into and out of a security over a specified period:

- **Buying Pressure**: How much volume is associated with price increases
- **Selling Pressure**: How much volume is associated with price decreases
- **Volume-Weighted Momentum**: Combines price momentum with volume strength
- **Money Flow Ratio**: Ratio of positive money flow to negative money flow

MFI answers the question: "Is the current price move supported by strong volume, or is it weak and likely to reverse?"

### Calculation Method

MFI calculation involves several steps combining price and volume:

1. **Calculate Typical Price**: (High + Low + Close) / 3
2. **Calculate Raw Money Flow**: Typical Price × Volume
3. **Identify Positive and Negative Money Flow**: Compare current to previous typical price
4. **Sum Positive and Negative Money Flow**: Over the specified period
5. **Calculate Money Flow Ratio**: Positive Money Flow / Negative Money Flow
6. **Calculate MFI**: 100 - (100 / (1 + Money Flow Ratio))

**Formula:**
```
Typical Price = (High + Low + Close) / 3
Raw Money Flow = Typical Price × Volume

If Typical Price > Previous Typical Price:
  Positive Money Flow += Raw Money Flow
Else:
  Negative Money Flow += Raw Money Flow

Money Flow Ratio = (Sum of Positive Money Flow over period) /
                   (Sum of Negative Money Flow over period)

MFI = 100 - (100 / (1 + Money Flow Ratio))
```

### Indicator Characteristics

- **Range**: 0 to 100 (bounded oscillator)
- **Type**: Volume-weighted momentum oscillator
- **Lag**: Moderate (similar to RSI but volume-weighted)
- **Best Used**: Identifying overbought/oversold with volume confirmation, spotting divergences
- **Limitations**: Requires volume data; less effective in low-volume environments

## Interpretation

### Value Ranges

Specific guidance on what different MFI values indicate:

- **80-100**: Overbought zone. Strong buying pressure but may be excessive. Price vulnerable to pullback, especially if volume is declining.
- **50-80**: Bullish momentum zone. Healthy buying pressure with good volume support. Uptrend likely to continue.
- **20-50**: Bearish momentum zone. Selling pressure present with volume confirmation. Downtrend may continue.
- **0-20**: Oversold zone. Strong selling pressure but may be excessive. Price vulnerable to bounce, especially if volume is declining.

### Key Levels

- **Overbought (80)**: High buying pressure. When MFI crosses above 80, market may be overextended. Look for failure to stay above 80 as reversal signal.
- **Oversold (20)**: High selling pressure. When MFI crosses below 20, market may be oversold. Look for MFI crossing back above 20 as reversal signal.
- **Midpoint (50)**: Equilibrium between buying and selling pressure. MFI crossing above 50 suggests bullish bias; below 50 suggests bearish bias.
- **Extreme Levels (90+/10-)**: Very rare and indicate extreme conditions. Usually precede sharp reversals.

**Important**: MFI overbought/oversold can persist during strong trends. In strong uptrends, MFI often stays between 40-80. In strong downtrends, MFI often stays between 20-60.

### Signal Interpretation

How to read MFI signals:

1. **Volume Confirmation**
   - MFI rising with RSI: Volume confirms price move (strong signal)
   - MFI falling while RSI rising: Price move lacks volume support (weak signal)
   - MFI diverging from price: Volume-price imbalance suggests reversal

2. **Momentum Changes**
   - MFI crossing above 50: Buying pressure gaining control
   - MFI crossing below 50: Selling pressure gaining control
   - MFI flattening at extremes: Momentum stabilizing, potential reversal

3. **Trend Quality**
   - Strong uptrend: MFI consistently above 50, rarely below 40
   - Strong downtrend: MFI consistently below 50, rarely above 60
   - Ranging market: MFI oscillating between 30-70

## Trading Signals

### Buy Signals

Specific conditions that generate buy signals:

1. **Primary Signal**: MFI crosses below 20 then rises back above 20
   - Confirms oversold condition ending with volume support
   - Best when combined with price support level

2. **Confirmation Signal**: MFI crosses above 50 from below
   - Indicates shift from selling to buying pressure
   - Volume-confirmed momentum change

3. **Divergence Signal**: Price makes lower low, MFI makes higher low
   - Bullish divergence with volume showing strength
   - Strongest when MFI is below 30

**Example Scenario:**
```
When MFI drops below 20 (oversold with high selling volume),
then crosses back above 20, consider long positions. Confirm with:
- Price finding support at key level
- Volume declining during selloff
- RSI also oversold for double confirmation
- Set stop loss below recent low
```

### Sell Signals

Specific conditions that generate sell signals:

1. **Primary Signal**: MFI crosses above 80 then falls back below 80
   - Confirms overbought condition ending
   - Best when combined with price resistance level

2. **Confirmation Signal**: MFI crosses below 50 from above
   - Indicates shift from buying to selling pressure
   - Volume-confirmed momentum change

3. **Divergence Signal**: Price makes higher high, MFI makes lower high
   - Bearish divergence showing volume weakness
   - Strongest when MFI is above 70

**Example Scenario:**
```
When MFI rises above 80 (overbought with high buying volume),
then crosses back below 80, consider closing longs or shorting. Confirm with:
- Price reaching resistance level
- Volume declining during rally
- RSI also overbought for double confirmation
- Set stop loss above recent high
```

### Divergence Analysis

**Bullish Divergence:**
- **Pattern**: Price makes lower low, MFI makes higher low
- **Identification**: Compare price lows with MFI lows over 20-40 bars
- **Significance**: Selling pressure weakening despite lower prices (volume drying up on decline)
- **Reliability**: Very high when MFI is below 30 and forms clear higher low
- **Example**: Stock drops from $50 to $45, then to $43. MFI drops to 18, then only to 25 on second low. Selling exhaustion likely.

**Bearish Divergence:**
- **Pattern**: Price makes higher high, MFI makes lower high
- **Identification**: Compare price highs with MFI highs over 20-40 bars
- **Significance**: Buying pressure weakening despite higher prices (volume drying up on rally)
- **Reliability**: Very high when MFI is above 70 and forms clear lower high
- **Example**: Stock rises from $50 to $55, then to $57. MFI rises to 85, then only to 78 on second high. Buying exhaustion likely.

## Best Practices

### Optimal Use Cases

When MFI works best:

- **Market conditions**: Most effective in liquid markets with consistent volume. Less reliable in illiquid or low-volume stocks. Works best when volume patterns are meaningful.
- **Time frames**: Excellent on daily and 4-hour charts. Less reliable on very short timeframes where volume can be erratic. Weekly charts provide strongest signals.
- **Asset classes**: Outstanding for stocks with good volume. Works well for forex (with tick volume), commodities, and liquid cryptocurrencies. Avoid for low-volume securities.

### Combining with Other Indicators

Recommended indicator combinations:

- **With RSI**: Compare MFI and RSI to assess volume strength. When both are overbought/oversold, signal is very strong. When they diverge, MFI shows true strength (volume-weighted).

- **With Price Action**: MFI divergences at support/resistance are most powerful. MFI oversold at support = strong buy. MFI overbought at resistance = strong sell.

- **With Trend Indicators**: Use moving averages or ADX to identify trend. Only take MFI oversold signals in uptrends, MFI overbought signals in downtrends for highest probability.

### Common Pitfalls

What to avoid:

1. **Ignoring the Trend**: Taking MFI overbought signals in strong uptrends leads to early exits. In strong trends, MFI can stay overbought/oversold for extended periods. Always confirm trend first.

2. **Trading Without Volume Context**: MFI depends on volume quality. In stocks with manipulated or irregular volume, MFI gives false signals. Ensure volume patterns are legitimate.

3. **Over-reliance on Levels**: Using only 80/20 levels without considering divergences, trend, and support/resistance misses the full picture. MFI is most powerful with divergence analysis.

4. **Comparing Different Volume Types**: Don't compare MFI values across assets with different volume characteristics (e.g., stocks vs forex tick volume). Calibrate thresholds for each market.

### Parameter Selection Guidelines

How to choose optimal parameters:

- **Short-term trading (day trading)**:
  - Period: 7-10 for faster signals
  - Thresholds: 80/20 or 85/15
  - Focus: Quick reversals with volume confirmation

- **Medium-term trading (swing trading)**:
  - Period: 14 (standard)
  - Thresholds: 80/20 (traditional)
  - Focus: Multi-day moves, volume-confirmed divergences

- **Long-term trading (position trading)**:
  - Period: 20-25 for major reversals
  - Thresholds: 75/25 or 70/30 (wider range)
  - Focus: Monthly timeframe, major volume shifts

- **Backtesting approach**: Test MFI period and thresholds on historical data for your specific asset. Find levels where MFI extremes historically preceded reversals with good volume.

## Practical Example

Complete trading example with context:

```ruby
require 'sqa/tai'

# Historical OHLCV data
high_prices =   [48.70, 48.90, 49.20, 49.92, 50.19, 50.12, 50.00, 49.80,
                 50.00, 50.30, 50.70, 51.00, 51.20, 51.40, 51.60, 51.50,
                 51.30, 51.00, 50.80, 50.50]
low_prices =    [47.79, 48.39, 48.94, 49.50, 49.87, 49.20, 48.90, 49.10,
                 49.20, 49.40, 49.60, 49.90, 50.10, 50.30, 50.50, 50.40,
                 50.20, 50.00, 49.80, 49.60]
close_prices =  [48.20, 48.75, 49.07, 49.91, 50.13, 49.53, 49.25, 49.45,
                 49.60, 50.00, 50.40, 50.90, 51.10, 51.30, 51.50, 51.40,
                 51.20, 50.90, 50.70, 50.40]
volume_data =   [2800, 3100, 3600, 4500, 4800, 3900, 3200, 3300,
                 3700, 4200, 4600, 5000, 5200, 5400, 5100, 4500,
                 4000, 3800, 3500, 3200]

# Calculate MFI and RSI for comparison
mfi = SQA::TAI.mfi(high_prices, low_prices, close_prices, volume_data, period: 14)
rsi = SQA::TAI.rsi(close_prices, period: 14)

# Current values
current_price = close_prices.last
current_mfi = mfi.last
previous_mfi = mfi[-2]
current_rsi = rsi.last

puts "=== MFI Trading Analysis ==="
puts "Current Price: $#{current_price.round(2)}"
puts "Current MFI: #{current_mfi.round(2)}"
puts "Current RSI: #{current_rsi.round(2)}"
puts "MFI-RSI Spread: #{(current_mfi - current_rsi).round(2)}"
puts

# Analyze volume strength
if (current_mfi - current_rsi).abs < 5
  volume_assessment = "Volume aligned with price"
elsif current_mfi > current_rsi + 10
  volume_assessment = "Strong volume support (bullish)"
elsif current_rsi > current_mfi + 10
  volume_assessment = "Weak volume support (bearish)"
end

puts "Volume Assessment: #{volume_assessment}"
puts

# Trading signals
if current_mfi > 80
  puts "SIGNAL: MFI OVERBOUGHT"
  puts "Current MFI: #{current_mfi.round(2)}"

  if current_mfi < previous_mfi
    puts "MFI turning down from overbought - SELL SIGNAL"
    puts "Entry: Short at $#{current_price.round(2)}"
    puts "Stop Loss: $#{(current_price * 1.02).round(2)} (2% above)"
    puts "Target: Previous support or MFI at 50"
  else
    puts "MFI still rising - wait for turn or exit longs"
  end

  if current_rsi < 70
    puts "⚠️  RSI not overbought - volume overheating, possible exhaustion"
  end

elsif current_mfi < 20
  puts "SIGNAL: MFI OVERSOLD"
  puts "Current MFI: #{current_mfi.round(2)}"

  if current_mfi > previous_mfi
    puts "MFI turning up from oversold - BUY SIGNAL"
    puts "Entry: Long at $#{current_price.round(2)}"
    puts "Stop Loss: $#{(current_price * 0.98).round(2)} (2% below)"
    puts "Target: Previous resistance or MFI at 50"
  else
    puts "MFI still falling - wait for turn or avoid catching falling knife"
  end

  if current_rsi > 30
    puts "⚠️  RSI not oversold - volume-driven selloff, potential reversal"
  end

elsif current_mfi > 50 && previous_mfi <= 50
  puts "SIGNAL: MFI CROSSED ABOVE 50"
  puts "Buying pressure taking control with volume"
  puts "Consider entering long or adding to position"

elsif current_mfi < 50 && previous_mfi >= 50
  puts "SIGNAL: MFI CROSSED BELOW 50"
  puts "Selling pressure taking control with volume"
  puts "Consider exiting longs or entering short"

else
  puts "NEUTRAL: MFI at #{current_mfi.round(2)}"
  puts "No clear signal - wait for extreme or crossover"
end

# Divergence check (simplified)
puts "\n=== Divergence Analysis ==="
price_high_recent = close_prices.last(5).max
price_high_previous = close_prices[-10..-6].max
mfi_high_recent = mfi.last(5).compact.max
mfi_high_previous = mfi[-10..-6].compact.max

if price_high_recent > price_high_previous && mfi_high_recent < mfi_high_previous
  puts "⚠️  BEARISH DIVERGENCE DETECTED"
  puts "Price making higher highs, MFI making lower highs"
  puts "Volume not supporting rally - potential reversal"
  puts "Consider taking profits or preparing short position"
end

price_low_recent = close_prices.last(5).min
price_low_previous = close_prices[-10..-6].min
mfi_low_recent = mfi.last(5).compact.min
mfi_low_previous = mfi[-10..-6].compact.min

if price_low_recent < price_low_previous && mfi_low_recent > mfi_low_previous
  puts "⚠️  BULLISH DIVERGENCE DETECTED"
  puts "Price making lower lows, MFI making higher lows"
  puts "Selling pressure weakening - potential reversal"
  puts "Consider buying dips or preparing long position"
end
```

## Related Indicators

### Similar Indicators
- **[RSI (Relative Strength Index)](rsi.md)**: Similar oscillator but without volume. RSI uses only price closes. MFI adds volume dimension. Use MFI when volume is reliable; RSI when volume data is questionable.

- **[CCI (Commodity Channel Index)](cci.md)**: Another overbought/oversold oscillator. CCI is unbounded and measures deviation from average. MFI is bounded 0-100 and volume-weighted. MFI better for volume confirmation.

### Complementary Indicators
- **[OBV (On-Balance Volume)](../volume/obv.md)**: Pure volume indicator. Use OBV to confirm MFI signals. When both show divergence, reversal probability is very high.

- **[VWAP (Volume-Weighted Average Price)](../overlap/vwap.md)**: Shows average price weighted by volume. Combine with MFI: MFI oversold + price below VWAP = strong buy. MFI overbought + price above VWAP = strong sell.

- **[ADX (Average Directional Index)](adx.md)**: Trend strength indicator. Use ADX to filter MFI signals. Take MFI signals only when ADX > 25 (trending) for highest win rate.

### Indicator Family
MFI belongs to the volume-weighted momentum oscillator family:
- **MFI**: Volume-weighted RSI, bounded 0-100
- **RSI**: Price-only momentum, bounded 0-100
- **CMF (Chaikin Money Flow)**: Volume-weighted but different calculation
- **A/D Line**: Cumulative volume-price indicator

**When to prefer MFI**: When volume is reliable and meaningful. MFI is superior to RSI for identifying divergences because it captures volume changes. Essential for confirming price moves are volume-backed.

## Advanced Topics

### Multi-Timeframe Analysis

Use MFI across multiple timeframes for comprehensive analysis:

- **Higher timeframe MFI** (weekly/daily) identifies major volume-backed moves and reversals
- **Lower timeframe MFI** (4H/1H) provides precise entry timing
- Strongest signals when all timeframes align (e.g., weekly MFI oversold + daily MFI oversold + 4H MFI turning up)

Example: If daily MFI shows bearish divergence while 4H MFI crosses below 20, this represents high-probability short setup.

### Market Regime Adaptation

MFI behavior varies by market conditions:

- **High Volume Environments** (earnings, news events): MFI can spike to extremes quickly. Use wider thresholds (85/15) to avoid false signals.

- **Low Volume Environments** (holidays, overnight): MFI becomes unreliable. Avoid trading MFI signals during low-volume periods.

- **Trending Markets**: MFI stays elevated in uptrends (40-80) or depressed in downtrends (20-60). Adjust thresholds based on trend.

- **Accumulation/Distribution**: MFI between 40-60 with low volatility often indicates accumulation (before uptrend) or distribution (before downtrend).

### Statistical Validation

MFI reliability metrics:

- **Success Rate**: MFI divergences have 65-75% success rate when combined with support/resistance, higher than RSI alone (55-65%).

- **Volume Requirement**: MFI signals most reliable when recent volume is at least 80% of average volume. Below that, reliability drops significantly.

- **Optimal Thresholds**: Studies show 80/20 optimal for most markets, but crypto and volatile stocks benefit from 85/15 thresholds.

- **Divergence Lead Time**: MFI divergences typically lead price reversals by 3-10 bars on the timeframe being analyzed.

## References

- Quong, Gene and Soudack, Avrum. "Money Flow Index" - Original MFI developers
- Murphy, John J. "Technical Analysis of the Financial Markets" (1999) - MFI interpretation and volume analysis
- Achelis, Steven B. "Technical Analysis from A to Z" (2000) - MFI practical applications
- [TradingView: MFI Educational Guide](https://www.tradingview.com/support/solutions/43000501986-money-flow-index-mfi/)
- [StockCharts: MFI Technical Analysis](https://school.stockcharts.com/doku.php?id=technical_indicators:money_flow_index_mfi)

## See Also

- [Momentum Indicators Overview](../index.md)
- [RSI - Price-Only Momentum](rsi.md)
- [Volume Indicators](../volume/index.md)
- [Basic Usage Guide](../../getting-started/basic-usage.md)
- [API Reference](../../api-reference.md)
