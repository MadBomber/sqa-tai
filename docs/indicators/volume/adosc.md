# ADOSC (Chaikin A/D Oscillator)

## Overview

The Chaikin A/D Oscillator (ADOSC) is a momentum indicator derived from the Accumulation/Distribution Line. Developed by Marc Chaikin, it measures the momentum of money flow by calculating the difference between fast and slow exponential moving averages of the AD Line. ADOSC helps identify changes in accumulation/distribution trends earlier than the AD Line alone, making it useful for spotting potential reversals and confirming price movements.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `high` | Array | Required | Array of high prices for each period |
| `low` | Array | Required | Array of low prices for each period |
| `close` | Array | Required | Array of closing prices for each period |
| `volume` | Array | Required | Array of volume values for each period |
| `fast_period` | Integer | 3 | Period for fast EMA |
| `slow_period` | Integer | 10 | Period for slow EMA |

### Parameter Details


**Note**: Array elements should be ordered from oldest to newest (chronological order)

**high, low, close, volume**
- Same requirements as AD Line (see AD documentation)
- All arrays must be same length
- ADOSC first calculates the AD Line, then applies EMAs

**fast_period**
- Default is 3 periods (Chaikin's original setting)
- Controls the fast EMA applied to the AD Line
- Shorter periods (2) make oscillator more sensitive
- Longer periods (5-7) smooth out noise

**slow_period**
- Default is 10 periods (Chaikin's original setting)
- Controls the slow EMA applied to the AD Line
- Should always be longer than fast_period
- Common alternatives: 8, 12, or 15

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

high   = [48.70, 48.72, 48.90, 48.87, 48.82]
low    = [47.79, 48.14, 48.39, 48.37, 48.24]
close  = [48.20, 48.61, 48.75, 48.63, 48.74]
volume = [10000, 12000, 11500, 13000, 11000]

# Calculate ADOSC with default settings
adosc = SQA::TAI.adosc(high, low, close, volume)

puts "Current ADOSC: #{adosc.last.round(2)}"
```

### With Custom Parameters

```ruby
# More responsive settings
adosc_fast = SQA::TAI.adosc(high, low, close, volume,
                             fast_period: 2, slow_period: 8)

# Smoother settings
adosc_smooth = SQA::TAI.adosc(high, low, close, volume,
                               fast_period: 5, slow_period: 15)
```

## Understanding the Indicator

### What It Measures

ADOSC measures the rate of change in accumulation/distribution:

- **Money Flow Momentum**: How quickly accumulation or distribution is changing
- **Trend Acceleration**: Whether money flow is accelerating or decelerating
- **Divergences**: Early warnings when momentum diverges from price
- **Zero Line Crosses**: Shifts between accumulation and distribution phases

ADOSC answers: "Is money flow accelerating into or out of this security?"

### Calculation Method

ADOSC is calculated in these steps:

1. **Calculate AD Line**: Using standard AD formula (see AD documentation)
2. **Apply Fast EMA**: Calculate fast period EMA of AD Line
3. **Apply Slow EMA**: Calculate slow period EMA of AD Line
4. **Calculate Difference**: Subtract slow EMA from fast EMA

**Formula:**
```
ADOSC = EMA(AD, fast_period) - EMA(AD, slow_period)

Where AD is the Accumulation/Distribution Line
```

### Indicator Characteristics

- **Range**: Unbounded oscillator (can be positive or negative)
- **Type**: Momentum oscillator based on volume
- **Lag**: Moderate (uses EMAs for smoothing)
- **Best Used**: Identifying momentum shifts, divergence analysis, trend confirmation
- **Limitations**: Can whipsaw in ranging markets, requires OHLC + volume data

## Interpretation

### Value Ranges

Understanding ADOSC values:

- **Positive Values**: Fast EMA above slow EMA, indicating accelerating accumulation or buying pressure
- **Negative Values**: Fast EMA below slow EMA, indicating accelerating distribution or selling pressure
- **Near Zero**: Little difference between fast and slow EMAs, weak or changing momentum
- **Increasing Values**: Strengthening buying pressure or accelerating accumulation
- **Decreasing Values**: Strengthening selling pressure or accelerating distribution

### Key Levels

- **Zero Line**: Critical level separating accumulation from distribution
  - Above zero: Bullish momentum (accumulation)
  - Below zero: Bearish momentum (distribution)

- **Zero Line Crosses**:
  - Cross above: Shift from distribution to accumulation (bullish)
  - Cross below: Shift from accumulation to distribution (bearish)

- **Extreme Readings**: Very high or low values indicate strong momentum but may signal overextension

### Signal Interpretation

How to read ADOSC signals:

1. **Momentum Direction**
   - ADOSC rising: Increasing buying pressure
   - ADOSC falling: Increasing selling pressure
   - ADOSC flat: Momentum stable or transitioning

2. **Position Relative to Zero**
   - Above zero: In accumulation phase
   - Below zero: In distribution phase
   - At zero: Neutral or transition point

3. **Divergence Patterns**
   - Price rising, ADOSC falling: Momentum weakening (bearish divergence)
   - Price falling, ADOSC rising: Selling pressure weakening (bullish divergence)

## Trading Signals

### Buy Signals

Specific conditions that generate buy signals:

1. **Primary Signal**: ADOSC crosses above zero line
   - Indicates shift from distribution to accumulation
   - Best when price is in uptrend or near support

2. **Momentum Signal**: ADOSC rising while positive
   - Shows strengthening accumulation
   - Confirms ongoing uptrend

3. **Divergence Signal**: Price makes lower low, ADOSC makes higher low
   - Bullish divergence suggests selling pressure weakening
   - Strongest near oversold price levels

**Example Scenario:**
```
When ADOSC crosses above zero while price is above its 50-day MA:
- Entry: On close above recent resistance
- Confirmation: ADOSC continues rising
- Stop loss: Below recent swing low
- Target: Previous highs or resistance levels
```

### Sell Signals

Specific conditions that generate sell signals:

1. **Primary Signal**: ADOSC crosses below zero line
   - Indicates shift from accumulation to distribution
   - Best when price is in downtrend or near resistance

2. **Momentum Signal**: ADOSC falling while negative
   - Shows strengthening distribution
   - Confirms ongoing downtrend

3. **Divergence Signal**: Price makes higher high, ADOSC makes lower high
   - Bearish divergence suggests buying pressure weakening
   - Strongest near overbought price levels

**Example Scenario:**
```
When ADOSC crosses below zero while price is below its 50-day MA:
- Entry: On close below recent support
- Confirmation: ADOSC continues falling
- Stop loss: Above recent swing high
- Target: Previous lows or support levels
```

### Divergence Analysis

**Bullish Divergence:**
- **Pattern**: Price makes lower low, ADOSC makes higher low or fails to make new low
- **Identification**: Compare recent price lows with ADOSC lows over 20-40 bars
- **Significance**: Distribution phase losing momentum, potential reversal
- **Reliability**: High when ADOSC is below zero and showing clear divergence
- **Example**: Stock falls from $100 to $95 to $92. ADOSC falls from -500 to -800, then only to -600.

**Bearish Divergence:**
- **Pattern**: Price makes higher high, ADOSC makes lower high or fails to make new high
- **Identification**: Compare recent price highs with ADOSC highs over 20-40 bars
- **Significance**: Accumulation phase losing momentum, potential reversal
- **Reliability**: High when ADOSC is above zero and showing clear divergence
- **Example**: Stock rises from $100 to $108 to $112. ADOSC rises from 300 to 600, then only to 450.

## Best Practices

### Optimal Use Cases

When ADOSC works best:

- **Market conditions**: Most effective in trending markets. Generates whipsaws in tight ranges.
- **Time frames**: Works on all timeframes; daily provides best signal quality. 4-hour also reliable.
- **Asset classes**: Excellent for stocks and ETFs with reliable volume. Works for cryptos. Limited use for forex.

### Combining with Other Indicators

Recommended combinations:

- **With Price Action**: Use ADOSC to confirm breakouts, support/resistance tests. ADOSC confirmation increases probability.

- **With Trend Indicators**: Combine with 50/200 MA or MACD. Only take ADOSC signals aligned with major trend.

- **With AD Line**: Use AD Line for overall trend, ADOSC for timing entries/exits within that trend.

### Common Pitfalls

What to avoid:

1. **Trading all zero crosses**: Not all crosses are quality signals. Filter with trend or price action.

2. **Ignoring divergence confirmation**: ADOSC divergences need price confirmation. Don't anticipate reversals.

3. **Wrong parameter settings**: Default 3/10 works well. Over-optimization leads to curve fitting.

4. **Using in low volume**: ADOSC requires reliable volume data. Avoid on thinly traded securities.

### Parameter Selection Guidelines

- **Default (3/10)**: Works well for most situations, recommended starting point
- **Sensitive (2/7)**: For faster signals, use in volatile markets or shorter timeframes
- **Smooth (5/15)**: For slower, more reliable signals, use in less volatile markets
- **Avoid extremes**: Very short or very long periods reduce indicator effectiveness

## Practical Example

Complete trading example:

```ruby
require 'sqa/tai'

# Load historical data
high, low, close, volume = load_ohlc_volume_data('AAPL')

# Calculate ADOSC and supporting indicators
adosc = SQA::TAI.adosc(high, low, close, volume, fast_period: 3, slow_period: 10)
price_ma_50 = SQA::TAI.sma(close, period: 50)

# Current values
current_price = close.last
current_adosc = adosc.last
previous_adosc = adosc[-2]

# Trend determination
trend = current_price > price_ma_50.last ? "UPTREND" : "DOWNTREND"

puts "=== ADOSC Trading Analysis ==="
puts "Current Price: $#{current_price.round(2)}"
puts "Current ADOSC: #{current_adosc.round(2)}"
puts "Price Trend: #{trend}"
puts

# Zero line cross detection
if previous_adosc < 0 && current_adosc >= 0
  puts "BUY SIGNAL: ADOSC crossed above zero"
  puts "Shift from distribution to accumulation"
  if trend == "UPTREND"
    puts "STRONG BUY: Signal aligned with uptrend"
  else
    puts "CAUTION: Signal against trend, wait for confirmation"
  end

elsif previous_adosc > 0 && current_adosc <= 0
  puts "SELL SIGNAL: ADOSC crossed below zero"
  puts "Shift from accumulation to distribution"
  if trend == "DOWNTREND"
    puts "STRONG SELL: Signal aligned with downtrend"
  else
    puts "CAUTION: Signal against trend, wait for confirmation"
  end

else
  # Momentum analysis
  if current_adosc > 0
    if current_adosc > previous_adosc
      puts "BULLISH: ADOSC positive and rising"
      puts "Accumulation accelerating"
    else
      puts "CAUTION: ADOSC positive but falling"
      puts "Accumulation momentum slowing"
    end
  else
    if current_adosc < previous_adosc
      puts "BEARISH: ADOSC negative and falling"
      puts "Distribution accelerating"
    else
      puts "CAUTION: ADOSC negative but rising"
      puts "Distribution momentum slowing"
    end
  end
end

# Divergence detection
puts "\n=== Divergence Check ==="
recent_price_high = close[-20..-1].max
recent_adosc_high = adosc[-20..-1].compact.max
prior_price_high = close[-40..-21].max
prior_adosc_high = adosc[-40..-21].compact.max

if recent_price_high > prior_price_high && recent_adosc_high < prior_adosc_high
  puts "BEARISH DIVERGENCE"
  puts "Price making higher highs, ADOSC not confirming"
  puts "Warning: Accumulation momentum weakening"
end

recent_price_low = close[-20..-1].min
recent_adosc_low = adosc[-20..-1].compact.min
prior_price_low = close[-40..-21].min
prior_adosc_low = adosc[-40..-21].compact.min

if recent_price_low < prior_price_low && recent_adosc_low > prior_adosc_low
  puts "BULLISH DIVERGENCE"
  puts "Price making lower lows, ADOSC not confirming"
  puts "Opportunity: Distribution momentum weakening"
end
```

## Related Indicators

### Similar Indicators
- **[Chaikin Money Flow (CMF)](cmf.md)**: Oscillator version of AD with fixed period. CMF is bounded, ADOSC is not. CMF for overbought/oversold, ADOSC for momentum changes.

### Complementary Indicators
- **[AD Line](ad.md)**: The foundation of ADOSC. Use AD for trend, ADOSC for momentum and timing.
- **[MACD](../momentum/macd.md)**: Similar oscillator structure but price-based. Combining MACD + ADOSC confirms both price and volume momentum.
- **[RSI](../momentum/rsi.md)**: Price momentum oscillator. RSI extremes + ADOSC confirmation = high probability setups.

### Indicator Family
ADOSC is part of the Chaikin volume indicator family:
- **AD Line**: Cumulative money flow
- **ADOSC**: Momentum of money flow
- **Chaikin Money Flow**: Money flow oscillator with fixed period

**When to prefer ADOSC**: For identifying momentum shifts and getting earlier signals than AD Line alone. More responsive than AD Line but less noisy than raw volume.

## Advanced Topics

### Multi-Timeframe Analysis

Using ADOSC across timeframes:

- **Weekly ADOSC**: Identifies major money flow shifts
- **Daily ADOSC**: Provides trade timing and confirmation
- **4-hour ADOSC**: Fine-tunes entries within daily signals

Best signals when timeframes align (weekly ADOSC positive, daily ADOSC crosses above zero).

### Market Regime Adaptation

ADOSC in different conditions:

- **Trending Markets**: ADOSC stays predominantly above/below zero. Focus on momentum (rising/falling) rather than zero crosses.
- **Ranging Markets**: ADOSC oscillates around zero frequently. Reduce position sizes or skip marginal signals.
- **High Volatility**: ADOSC becomes more erratic. Consider using slower settings (5/15) to filter noise.
- **Low Volume**: ADOSC less reliable. Confirm all signals with price action.

### Statistical Validation

ADOSC reliability metrics:

- **Zero Cross Success**: 55-60% win rate standalone, 65-75% when filtered by trend
- **Divergence Reliability**: Bullish divergences work better (70%) than bearish (60%)
- **Best Timeframe**: Daily charts show highest success rates
- **Volume Quality**: Accuracy directly correlates with volume data reliability

## References

- Chaikin, Marc. "Chaikin Analytics" - Original development and applications
- Murphy, John J. "Technical Analysis of the Financial Markets" (1999)
- [StockCharts: Chaikin Oscillator](https://school.stockcharts.com/doku.php?id=technical_indicators:chaikin_oscillator)
- [TradingView: ADOSC Documentation](https://www.tradingview.com/support/solutions/43000594683-chaikin-oscillator/)

## See Also

- [Volume Indicators Overview](../index.md)
- [AD - Accumulation/Distribution Line](ad.md)
- [OBV - On Balance Volume](obv.md)
- [Basic Usage Guide](../../getting-started/basic-usage.md)
