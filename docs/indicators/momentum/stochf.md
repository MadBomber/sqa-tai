# STOCHF (Fast Stochastic Oscillator)

## Overview

The Fast Stochastic Oscillator (STOCHF) is a momentum indicator that shows where the closing price is relative to the high-low range over a given period. It is the more responsive version of the standard Stochastic Oscillator, providing quicker signals with less smoothing. STOCHF consists of two lines: %K (fast line) and %D (signal line), both oscillating between 0 and 100 to identify overbought and oversold conditions.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `high` | Array | Required | Array of high prices |
| `low` | Array | Required | Array of low prices |
| `close` | Array | Required | Array of close prices |
| `fastk_period` | Integer | 5 | Period for %K calculation |
| `fastd_period` | Integer | 3 | Period for %D moving average |
| `fastd_ma_type` | Integer | 0 | MA type for %D (0=SMA, 1=EMA, etc.) |

### Parameter Details


**Note**: Array elements should be ordered from oldest to newest (chronological order)

**high, low, close**
- Complete HLC data required (open not needed)
- Arrays must be of equal length
- Minimum data points: fastk_period + fastd_period
- Works on any timeframe (1-minute to monthly)

**fastk_period**
- Standard setting is 5 periods for fast response
- Shorter periods (3-4) create extremely sensitive signals
- Longer periods (7-10) smooth the indicator but lose "fast" characteristic
- Recommended ranges:
  - **Scalping**: 3-5 periods for maximum responsiveness
  - **Day trading**: 5-7 periods (standard)
  - **Swing trading**: 8-10 periods for reduced noise

**fastd_period**
- Standard setting is 3 periods (moving average of %K)
- Creates the signal line (%D) by smoothing %K
- Shorter periods (2) make %D more responsive to %K
- Longer periods (5-7) create smoother signal line
- Common values: 3 (standard), 2 (very fast), 5 (smoother)

**fastd_ma_type**
- 0 = SMA (Simple Moving Average) - standard
- 1 = EMA (Exponential Moving Average) - more weight to recent values
- Other MA types available but SMA is most common

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

high =  [46.08, 46.41, 46.46, 46.57, 46.50, 47.03, 47.35, 47.61,
         48.12, 48.34, 48.50, 48.70, 48.90, 49.10, 49.30]
low =   [44.61, 44.83, 45.64, 45.95, 46.02, 46.50, 47.28, 47.28,
         48.03, 48.21, 48.10, 48.20, 48.40, 48.60, 48.80]
close = [45.42, 45.84, 46.08, 46.46, 46.55, 47.03, 47.28, 47.61,
         48.12, 48.21, 48.30, 48.50, 48.70, 48.90, 49.10]

# Calculate Fast Stochastic (returns two arrays: fastk and fastd)
fastk, fastd = SQA::TAI.stochf(high, low, close,
                                fastk_period: 5,
                                fastd_period: 3)

puts "%K (fast): #{fastk.last.round(2)}"
puts "%D (signal): #{fastd.last.round(2)}"
```

### With Custom Parameters

```ruby
# Very fast settings for scalping
fastk_scalp, fastd_scalp = SQA::TAI.stochf(high, low, close,
                                            fastk_period: 3,
                                            fastd_period: 2)

# Standard fast settings
fastk_std, fastd_std = SQA::TAI.stochf(high, low, close,
                                        fastk_period: 5,
                                        fastd_period: 3)

# Smoother fast stochastic
fastk_smooth, fastd_smooth = SQA::TAI.stochf(high, low, close,
                                              fastk_period: 8,
                                              fastd_period: 5)

puts "Scalping: %K=#{fastk_scalp.last.round(2)}, %D=#{fastd_scalp.last.round(2)}"
puts "Standard: %K=#{fastk_std.last.round(2)}, %D=#{fastd_std.last.round(2)}"
puts "Smooth: %K=#{fastk_smooth.last.round(2)}, %D=#{fastd_smooth.last.round(2)}"
```

## Understanding the Indicator

### What It Measures

Fast Stochastic measures momentum by comparing closing price to recent price range:

- **Price Position**: Where current close is within the recent high-low range
- **Momentum Strength**: How quickly price is moving within its range
- **Overbought/Oversold**: When price is at extremes of its range
- **Momentum Shifts**: Changes in the rate of price movement

STOCHF answers: "Is price at the top or bottom of its recent range, and is momentum shifting?"

### Calculation Method

Fast Stochastic calculation is straightforward:

1. **Calculate %K (Fast Line)**: Compare close to recent high-low range
2. **Calculate %D (Signal Line)**: Moving average of %K
3. **No additional smoothing**: Unlike slow stochastic, %K is not smoothed first

**Formula:**
```
%K = 100 × (Close - Lowest Low) / (Highest High - Lowest Low)

Where:
- Lowest Low = minimum low over fastk_period
- Highest High = maximum high over fastk_period

%D = Moving Average of %K over fastd_period
```

### Indicator Characteristics

- **Range**: 0 to 100 (bounded oscillator)
- **Type**: Momentum oscillator (range-based)
- **Lag**: Very low lag - one of the fastest momentum indicators
- **Best Used**: Short-term trading, quick reversals, scalping
- **Limitations**: More false signals than slow stochastic due to sensitivity

## Interpretation

### Value Ranges

Specific guidance on what different STOCHF values indicate:

- **80-100**: Overbought zone. Price near top of recent range. Potential reversal or consolidation approaching.
- **50-80**: Bullish momentum. Price in upper half of range, upward momentum intact.
- **20-50**: Bearish momentum. Price in lower half of range, downward momentum present.
- **0-20**: Oversold zone. Price near bottom of recent range. Potential bounce or consolidation approaching.

### Key Levels

- **Overbought (80)**: Traditional overbought level. STOCHF > 80 indicates price at top of range. Watch for reversal when %K turns down or crosses below %D.
- **Oversold (20)**: Traditional oversold level. STOCHF < 20 indicates price at bottom of range. Watch for reversal when %K turns up or crosses above %D.
- **Midpoint (50)**: Equilibrium level. STOCHF crossing 50 indicates momentum shift.
- **Extreme Levels (95+/5-)**: Very strong signals. When STOCHF reaches these extremes, reversal probability increases significantly.

**Important**: In strong trends, STOCHF can remain overbought or oversold for extended periods. Adjust thresholds: use 90/10 in strong trends instead of 80/20.

### Signal Interpretation

How to read Fast Stochastic signals:

1. **Crossover Signals**
   - %K crosses above %D: Bullish signal (momentum turning up)
   - %K crosses below %D: Bearish signal (momentum turning down)
   - Crossovers in extreme zones (above 80 or below 20) are strongest

2. **Overbought/Oversold**
   - Entering overbought: Strong momentum, but watch for reversal
   - Leaving overbought: Momentum slowing, potential top
   - Entering oversold: Weak momentum, but watch for bounce
   - Leaving oversold: Momentum recovering, potential bottom

3. **Divergences**
   - Price higher high + STOCHF lower high: Bearish divergence
   - Price lower low + STOCHF higher low: Bullish divergence
   - Most powerful when divergence occurs at extremes

## Trading Signals

### Buy Signals

Specific conditions that generate buy signals:

1. **Primary Signal**: STOCHF in oversold zone (<20) and %K crosses above %D
   - Confirms oversold reversal with momentum shift
   - Best at support levels or in established uptrends

2. **Confirmation Signal**: Both %K and %D cross above 20 together
   - Confirms oversold condition ending
   - Volume confirmation strengthens signal

3. **Divergence Signal**: Price makes lower low but STOCHF makes higher low
   - Bullish divergence indicates weakening downward pressure
   - Strongest when STOCHF forms higher low below 30

**Example Scenario:**
```
When %K crosses above %D in oversold zone (both below 20),
consider long position. Confirm with:
- Price at or near support level
- Volume declining on selloff
- ADX showing weak trend (favors reversal)
- Set stop loss below recent swing low
```

### Sell Signals

Specific conditions that generate sell signals:

1. **Primary Signal**: STOCHF in overbought zone (>80) and %K crosses below %D
   - Confirms overbought reversal with momentum shift
   - Best at resistance levels or in established downtrends

2. **Confirmation Signal**: Both %K and %D cross below 80 together
   - Confirms overbought condition ending
   - Volume confirmation strengthens signal

3. **Divergence Signal**: Price makes higher high but STOCHF makes lower high
   - Bearish divergence indicates weakening upward pressure
   - Strongest when STOCHF forms lower high above 70

**Example Scenario:**
```
When %K crosses below %D in overbought zone (both above 80),
consider short position or exit longs. Confirm with:
- Price at or near resistance level
- Volume declining on rally
- ADX showing weak trend (favors reversal)
- Set stop loss above recent swing high
```

### Divergence Analysis

**Bullish Divergence:**
- **Pattern**: Price makes lower low, STOCHF makes higher low
- **Identification**: Compare price lows with STOCHF lows over 10-20 bars
- **Significance**: Selling momentum weakening despite lower prices
- **Reliability**: High when both %K and %D are below 30
- **Example**: Stock drops to $48, then $46. STOCHF drops to 15, then only to 22 on second low. Reversal likely.

**Bearish Divergence:**
- **Pattern**: Price makes higher high, STOCHF makes lower high
- **Identification**: Compare price highs with STOCHF highs over 10-20 bars
- **Significance**: Buying momentum weakening despite higher prices
- **Reliability**: High when both %K and %D are above 70
- **Example**: Stock rises to $52, then $54. STOCHF rises to 88, then only to 81 on second high. Reversal likely.

## Best Practices

### Optimal Use Cases

When Fast Stochastic works best:

- **Market conditions**: Excellent in ranging/choppy markets. Less reliable in strong trending markets where it stays overbought/oversold. Best with volatility.
- **Time frames**: Outstanding for scalping (1-5 min) and day trading (5-60 min). Also effective on daily charts for swing entries. Less useful on weekly+ timeframes.
- **Asset classes**: Works well for all liquid assets—stocks, forex, futures, crypto. Requires decent volatility. Avoid in very low volatility conditions.

### Combining with Other Indicators

Recommended indicator combinations:

- **With Trend Indicators (MA, ADX)**: Use trend filter to avoid counter-trend trades. Only take STOCHF buy signals in uptrend, sell signals in downtrend. Increases win rate significantly.

- **With Support/Resistance**: STOCHF signals at key price levels are most reliable. Oversold at support = strong buy. Overbought at resistance = strong sell.

- **With Volume**: Declining volume in oversold/overbought zones strengthens reversal signals. Rising volume on STOCHF crossovers confirms momentum shift.

- **With Slow Stochastic**: Compare fast and slow. When both give same signal, probability is higher. When they diverge, fast leads slow.

### Common Pitfalls

What to avoid:

1. **Trading Against Strong Trends**: Taking overbought signals in strong uptrends or oversold signals in strong downtrends leads to early exits and losses. Always check trend first.

2. **Ignoring False Signals**: Fast Stochastic generates many false signals due to high sensitivity. Never trade STOCHF alone—always use confirmation from price action, support/resistance, or other indicators.

3. **Over-trading**: STOCHF can give numerous signals in choppy markets. Be selective. Focus on signals at extremes (80/20) with crossovers, not every minor fluctuation.

4. **Using Fixed Thresholds**: 80/20 levels work in ranging markets but fail in trends. Adjust to 90/10 or 95/5 in strong trends. Adapt to market conditions.

### Parameter Selection Guidelines

How to choose optimal parameters:

- **Short-term trading (scalping/day trading)**:
  - fastk_period: 3-5 for maximum responsiveness
  - fastd_period: 2-3 for quick signal
  - Thresholds: 80/20 or 85/15
  - Focus: Quick reversals, fast entries/exits

- **Medium-term trading (swing trading)**:
  - fastk_period: 5-8 for balance of speed and reliability
  - fastd_period: 3-5 for smoother signals
  - Thresholds: 80/20 (standard)
  - Focus: Multi-day swings, extremes + crossovers

- **High-volatility environments**:
  - fastk_period: 8-10 to filter noise
  - fastd_period: 5-7 for stability
  - Thresholds: 90/10 to reduce false signals

- **Backtesting approach**: Test on historical data for your specific asset and timeframe. Optimize fastk_period for signal clarity and fastd_period for crossover timing.

## Practical Example

Complete trading example with context:

```ruby
require 'sqa/tai'

# Intraday 5-minute data for day trading
high_prices =  [46.08, 46.41, 46.46, 46.57, 46.50, 47.03, 47.35, 47.61,
                48.12, 48.34, 48.50, 48.70, 48.90, 49.10, 49.30, 49.25,
                49.15, 48.90, 48.70, 48.50]
low_prices =   [44.61, 44.83, 45.64, 45.95, 46.02, 46.50, 47.28, 47.28,
                48.03, 48.21, 48.10, 48.20, 48.40, 48.60, 48.80, 48.75,
                48.60, 48.40, 48.20, 48.00]
close_prices = [45.42, 45.84, 46.08, 46.46, 46.55, 47.03, 47.28, 47.61,
                48.12, 48.21, 48.30, 48.50, 48.70, 48.90, 49.10, 49.05,
                48.95, 48.75, 48.55, 48.35]

# Calculate Fast Stochastic and trend filter
fastk, fastd = SQA::TAI.stochf(high_prices, low_prices, close_prices,
                                fastk_period: 5,
                                fastd_period: 3)

sma_20 = SQA::TAI.sma(close_prices, period: 20)

# Current values
current_price = close_prices.last
current_k = fastk.last
previous_k = fastk[-2]
current_d = fastd.last
previous_d = fastd[-2]

# Trend determination
trend = current_price > sma_20.last ? "UPTREND" : "DOWNTREND"

puts "=== Fast Stochastic Day Trading Analysis ==="
puts "Current Price: $#{current_price.round(2)}"
puts "Fast Stoch %K: #{current_k.round(2)}"
puts "Fast Stoch %D: #{current_d.round(2)}"
puts "Trend (20 SMA): #{trend}"
puts

# Trading logic with trend filter
if trend == "UPTREND"
  # In uptrend, only look for buy signals (dip buying)
  if current_k < 20 && current_d < 20
    puts "SIGNAL: OVERSOLD IN UPTREND"

    # Check for bullish crossover
    if previous_k < previous_d && current_k > current_d
      puts "BUY SIGNAL: Bullish crossover in oversold zone"
      puts "Entry: $#{current_price.round(2)}"
      puts "Stop Loss: $#{(current_price * 0.985).round(2)} (1.5% below)"
      puts "Target 1: Previous resistance at $#{high_prices.max.round(2)}"
      puts "Target 2: When STOCHF reaches 80 (overbought)"
      puts "Strategy: Buying the dip in uptrend"
    elsif current_k > previous_k
      puts "WATCH: STOCHF turning up from oversold"
      puts "Wait for %K to cross above %D for confirmation"
    end

  elsif current_k > 80 && current_d > 80
    puts "SIGNAL: OVERBOUGHT IN UPTREND"
    puts "STOCHF: %K=#{current_k.round(2)}, %D=#{current_d.round(2)}"

    if previous_k > previous_d && current_k < current_d
      puts "CAUTION: Bearish crossover in overbought"
      puts "Consider taking profits or tightening stops"
      puts "Pullback likely but uptrend may resume"
    else
      puts "HOLD: Overbought but no reversal yet"
      puts "Trail stops or prepare to take profits"
    end

  elsif previous_k < 50 && current_k > 50
    puts "SIGNAL: MOMENTUM SHIFT UPWARD"
    puts "%K crossed above 50 - bullish acceleration"
    puts "Consider adding to long positions"

  else
    puts "NEUTRAL: STOCHF at #{current_k.round(2)}"
    puts "No clear signal - wait for extremes"
  end

elsif trend == "DOWNTREND"
  # In downtrend, only look for sell signals (rally fading)
  if current_k > 80 && current_d > 80
    puts "SIGNAL: OVERBOUGHT IN DOWNTREND"

    # Check for bearish crossover
    if previous_k > previous_d && current_k < current_d
      puts "SELL SIGNAL: Bearish crossover in overbought zone"
      puts "Entry: Short at $#{current_price.round(2)}"
      puts "Stop Loss: $#{(current_price * 1.015).round(2)} (1.5% above)"
      puts "Target 1: Previous support at $#{low_prices.min.round(2)}"
      puts "Target 2: When STOCHF reaches 20 (oversold)"
      puts "Strategy: Fading the rally in downtrend"
    elsif current_k < previous_k
      puts "WATCH: STOCHF turning down from overbought"
      puts "Wait for %K to cross below %D for confirmation"
    end

  elsif current_k < 20 && current_d < 20
    puts "SIGNAL: OVERSOLD IN DOWNTREND"
    puts "STOCHF: %K=#{current_k.round(2)}, %D=#{current_d.round(2)}"

    if previous_k < previous_d && current_k > current_d
      puts "CAUTION: Bullish crossover in oversold"
      puts "Consider covering shorts or tightening stops"
      puts "Bounce likely but downtrend may resume"
    else
      puts "HOLD SHORTS: Oversold but no reversal yet"
      puts "Trail stops or prepare to cover"
    end

  elsif previous_k > 50 && current_k < 50
    puts "SIGNAL: MOMENTUM SHIFT DOWNWARD"
    puts "%K crossed below 50 - bearish acceleration"
    puts "Consider adding to short positions"

  else
    puts "NEUTRAL: STOCHF at #{current_k.round(2)}"
    puts "No clear signal - wait for extremes"
  end
end

# Divergence detection
puts "\n=== Divergence Check ==="
price_high_recent = close_prices.last(5).max
price_high_prev = close_prices[-10..-6].max
k_high_recent = fastk.last(5).compact.max
k_high_prev = fastk[-10..-6].compact.max

if price_high_recent > price_high_prev && k_high_recent < k_high_prev
  puts "⚠️  BEARISH DIVERGENCE"
  puts "Price: $#{price_high_prev.round(2)} -> $#{price_high_recent.round(2)} (higher)"
  puts "STOCHF: #{k_high_prev.round(2)} -> #{k_high_recent.round(2)} (lower)"
  puts "Momentum weakening - potential reversal"
end
```

## Related Indicators

### Similar Indicators
- **[STOCH (Slow Stochastic)](stoch.md)**: Smoothed version of Fast Stochastic. Slow Stochastic applies additional smoothing to %K, making it less sensitive. Use STOCHF for faster signals, STOCH for fewer false positives.

- **[Williams %R](willr.md)**: Similar calculation but inverted scale (0 to -100). Williams %R and Fast Stochastic give nearly identical signals. STOCHF is more popular and easier to interpret.

- **[RSI (Relative Strength Index)](rsi.md)**: Another momentum oscillator. RSI is smoother and bounded 0-100. STOCHF is more sensitive to short-term changes. Use STOCHF for quick trades, RSI for trend analysis.

### Complementary Indicators
- **[MACD](macd.md)**: Trend-following momentum. Use MACD to identify trend, STOCHF to time entries. MACD bullish + STOCHF oversold crossover = high-probability buy.

- **[Bollinger Bands](../overlap/bbands.md)**: Volatility bands. STOCHF signals at Bollinger Band extremes are particularly strong. Oversold + lower band touch = powerful reversal signal.

- **[Volume](../volume/obv.md)**: Confirms STOCHF signals. STOCHF reversal with high volume = strong signal. STOCHF reversal with low volume = weak signal, possible false.

### Indicator Family
Fast Stochastic belongs to the Stochastic family:
- **Fast Stochastic (STOCHF)**: Raw %K and smoothed %D
- **Slow Stochastic (STOCH)**: Smoothed %K (SlowK) and smoothed %D (SlowD)
- **Full Stochastic**: Fully customizable smoothing parameters

**When to prefer STOCHF**: For short-term trading requiring quick signals. STOCHF excels at catching rapid momentum shifts in fast-moving markets. Best for scalping, day trading, and active swing trading.

## Advanced Topics

### Multi-Timeframe Analysis

Use Fast Stochastic across timeframes for context and confirmation:

- **Higher timeframe STOCHF** (daily) identifies major overbought/oversold conditions
- **Lower timeframe STOCHF** (5-min, 15-min) provides precise entry and exit timing
- Strongest signals when timeframes align (daily oversold + 15-min oversold + crossover)

Example: Daily STOCHF oversold (below 20) while 15-minute STOCHF shows bullish crossover in oversold = high-probability long entry.

### Market Regime Adaptation

Fast Stochastic requires adjustment for different markets:

- **Trending Markets**: Use 90/10 or 95/5 thresholds instead of 80/20. Only trade with trend direction. Ignore counter-trend STOCHF signals.

- **Ranging Markets**: Standard 80/20 thresholds work well. Trade both overbought and oversold signals. STOCHF excels in ranges.

- **High Volatility**: Increase fastk_period to 8-10 and use 85/15 thresholds to reduce whipsaws.

- **Low Volatility**: Decrease to 3-5 period and use 75/25 thresholds for earlier signals. Beware of false signals in very quiet markets.

### Statistical Validation

Fast Stochastic reliability metrics:

- **Success Rate**: Crossovers in extreme zones (80/20) have approximately 55-60% success rate. Improves to 65-70% with trend filter.

- **Best Timeframes**: Most reliable on 5-minute to daily charts. Very short timeframes (<5 min) generate excessive false signals. Weekly+ too laggy.

- **Optimal Parameters**: Studies show 5-period %K with 3-period %D performs best across most markets. Very short or very long periods reduce effectiveness.

- **Signal Timing**: STOCHF typically leads price reversals by 1-5 bars on the timeframe being analyzed. Earlier than slow stochastic but more false signals.

## References

- Lane, George. "Lane's Stochastics" - Original developer of Stochastic Oscillator
- Murphy, John J. "Technical Analysis of the Financial Markets" (1999) - Comprehensive stochastic analysis
- Pring, Martin J. "Technical Analysis Explained" (2002) - Fast vs Slow Stochastic comparison
- [TradingView: Stochastic Educational Guide](https://www.tradingview.com/support/solutions/43000502332-stochastic-stoch/)
- [StockCharts: Stochastic Oscillator](https://school.stockcharts.com/doku.php?id=technical_indicators:stochastic_oscillator_fast_slow_and_full)

## See Also

- [Momentum Indicators Overview](../index.md)
- [STOCH - Slow Stochastic](stoch.md)
- [Williams %R - Similar Oscillator](willr.md)
- [Basic Usage Guide](../../getting-started/basic-usage.md)
- [API Reference](../../api-reference.md)
