# Average Directional Movement Index Rating (ADXR)

The Average Directional Movement Index Rating (ADXR) is a smoothed version of the ADX indicator that reduces volatility and provides a more stable measure of trend strength. ADXR is calculated as the average of the current ADX value and the ADX value from n periods ago (typically 14 periods), making it less susceptible to short-term fluctuations while maintaining the core trend strength analysis capabilities.

## Formula

ADXR is calculated by averaging two ADX values:

```
ADXR = (Current ADX + ADX from n periods ago) / 2
```

Where:
1. Current ADX is calculated using the standard ADX formula
2. Historical ADX is the ADX value from n periods ago (default: 14)
3. The result is the simple average of these two values

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `high` | Array<Float> | Yes | - | Array of high prices |
| `low` | Array<Float> | Yes | - | Array of low prices |
| `close` | Array<Float> | Yes | - | Array of close prices |
| `period` | Integer | No | 14 | Number of periods for both ADX calculation and lookback |

## Returns

Returns an array of ADXR values ranging from 0 to 100. Values will be `nil` until sufficient data is available (requires 2 × period data points).

## Usage

```ruby
require 'sqa/tai'

high =  [48.70, 48.72, 48.90, 48.87, 48.82, 49.05, 49.20, 49.35, 49.92, 50.19, 50.12, 50.10, 50.00, 49.75, 49.80,
         50.00, 50.20, 50.30, 50.50, 50.70, 50.80, 50.90, 51.00, 51.10, 51.20, 51.30, 51.40, 51.50]
low =   [47.79, 48.14, 48.39, 48.37, 48.24, 48.64, 48.94, 49.03, 49.50, 49.87, 49.20, 49.00, 48.90, 49.00, 49.10,
         49.20, 49.30, 49.40, 49.50, 49.60, 49.70, 49.80, 49.90, 50.00, 50.10, 50.20, 50.30, 50.40]
close = [48.20, 48.61, 48.75, 48.63, 48.74, 49.03, 49.07, 49.32, 49.91, 50.13, 49.53, 49.50, 49.25, 49.20, 49.45,
         49.60, 49.80, 50.00, 50.20, 50.40, 50.60, 50.70, 50.90, 51.00, 51.10, 51.20, 51.30, 51.40]

adxr = SQA::TAI.adxr(high, low, close, period: 14)

puts "Current ADXR: #{adxr.last.round(2)}"
```

## Interpretation

ADXR uses the same interpretation thresholds as ADX but provides smoother, more stable readings:

| ADXR Value | Trend Strength | Interpretation |
|------------|----------------|----------------|
| 0-20 | Weak/No trend | Range-bound market, avoid trend strategies |
| 20-25 | Developing trend | Trend beginning to form, watch closely |
| 25-50 | Strong trend | Good conditions for trend-following |
| 50-75 | Very strong trend | Excellent trending environment |
| 75-100 | Extremely strong trend | Rare but powerful directional movement |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

**Key Point**: Like ADX, ADXR measures trend STRENGTH, not direction. Use with directional indicators (+DI, -DI) to determine trend direction.

## ADXR vs ADX: Key Differences

### 1. Smoothness
- **ADX**: More responsive but noisier, reacts quickly to changes
- **ADXR**: Smoother signal, filters out short-term fluctuations
- **Use Case**: Use ADXR when you want to avoid whipsaws in volatile markets

### 2. Signal Timing
- **ADX**: Earlier signals, faster response to trend changes
- **ADXR**: Delayed signals, confirmation comes later
- **Use Case**: Use ADX for early entry, ADXR for confirmation

### 3. Stability
- **ADX**: Can fluctuate significantly day-to-day
- **ADXR**: More stable readings, easier to interpret trends
- **Use Case**: ADXR better for longer-term trend analysis

### 4. False Signals
- **ADX**: More prone to false signals in choppy markets
- **ADXR**: Fewer false signals but may miss quick reversals
- **Use Case**: ADXR preferred in consolidating markets

## Example: ADXR vs ADX Comparison

```ruby
high, low, close = load_historical_ohlc('AAPL')

adx = SQA::TAI.adx(high, low, close, period: 14)
adxr = SQA::TAI.adxr(high, low, close, period: 14)

current_adx = adx.last
current_adxr = adxr.last

puts "ADX:  #{current_adx.round(2)}"
puts "ADXR: #{current_adxr.round(2)}"

# ADXR lags ADX - difference shows momentum
difference = current_adx - current_adxr

if current_adx > 25
  if difference > 5
    puts "ADX rising faster than ADXR - Trend accelerating"
  elsif difference < -5
    puts "ADX falling faster than ADXR - Trend weakening"
  else
    puts "ADX and ADXR aligned - Stable trend"
  end
elsif current_adxr > 25 && current_adx < 25
  puts "Trend losing strength - ADXR still high but ADX declining"
elsif current_adx > 25 && current_adxr < 25
  puts "New trend developing - ADX rising but ADXR catching up"
end
```

## Example: ADXR Trend Strength Filter

```ruby
high, low, close = load_historical_ohlc('SPY')

adxr = SQA::TAI.adxr(high, low, close, period: 14)
plus_di = SQA::TAI.plus_di(high, low, close, period: 14)
minus_di = SQA::TAI.minus_di(high, low, close, period: 14)

current_adxr = adxr.last
current_plus = plus_di.last
current_minus = minus_di.last

# ADXR as trend filter - more reliable than ADX alone
if current_adxr > 25
  if current_plus > current_minus
    spread = current_plus - current_minus
    puts "CONFIRMED UPTREND"
    puts "ADXR: #{current_adxr.round(2)}, +DI: #{current_plus.round(2)}, -DI: #{current_minus.round(2)}"
    puts "Directional spread: #{spread.round(2)}"
    puts "Strategy: Buy pullbacks, hold positions"
  else
    spread = current_minus - current_plus
    puts "CONFIRMED DOWNTREND"
    puts "ADXR: #{current_adxr.round(2)}, +DI: #{current_plus.round(2)}, -DI: #{current_minus.round(2)}"
    puts "Directional spread: #{spread.round(2)}"
    puts "Strategy: Sell rallies, maintain shorts"
  end
else
  puts "NO CONFIRMED TREND (ADXR: #{current_adxr.round(2)})"
  puts "Strategy: Range trading, avoid trend-following"
end
```

## Example: ADXR Trend Persistence

```ruby
high, low, close = load_historical_ohlc('TSLA')

adxr = SQA::TAI.adxr(high, low, close, period: 14)

current_adxr = adxr.last
adxr_10_bars_ago = adxr[-10]
adxr_20_bars_ago = adxr[-20]

# Check if ADXR has remained elevated
if current_adxr > 25 && adxr_10_bars_ago > 25 && adxr_20_bars_ago > 25
  puts "SUSTAINED STRONG TREND"
  puts "ADXR has remained above 25 for extended period"
  puts "20 bars ago: #{adxr_20_bars_ago.round(2)}"
  puts "10 bars ago: #{adxr_10_bars_ago.round(2)}"
  puts "Current: #{current_adxr.round(2)}"

  # Analyze trend evolution
  if current_adxr > adxr_10_bars_ago && adxr_10_bars_ago > adxr_20_bars_ago
    puts "Trend STRENGTHENING over time"
  elsif current_adxr < adxr_10_bars_ago && adxr_10_bars_ago < adxr_20_bars_ago
    puts "Trend WEAKENING but still strong"
  else
    puts "Trend strength FLUCTUATING but sustained"
  end
elsif current_adxr > 25 && (adxr_10_bars_ago < 25 || adxr_20_bars_ago < 25)
  puts "NEW TREND EMERGING"
  puts "ADXR recently crossed above 25"
  puts "Monitor for trend confirmation"
end
```

## Example: ADXR with Multiple Timeframes

```ruby
# Daily and weekly data
daily_high, daily_low, daily_close = load_historical_ohlc('MSFT', timeframe: 'daily')
weekly_high, weekly_low, weekly_close = load_historical_ohlc('MSFT', timeframe: 'weekly')

daily_adxr = SQA::TAI.adxr(daily_high, daily_low, daily_close, period: 14)
weekly_adxr = SQA::TAI.adxr(weekly_high, weekly_low, weekly_close, period: 14)

puts "Daily ADXR: #{daily_adxr.last.round(2)}"
puts "Weekly ADXR: #{weekly_adxr.last.round(2)}"

# Strongest trends when both timeframes show strength
if daily_adxr.last > 25 && weekly_adxr.last > 25
  puts "STRONG MULTI-TIMEFRAME TREND"
  puts "Both daily and weekly show trending conditions"
  puts "High probability trend-following opportunities"
elsif daily_adxr.last > 25 && weekly_adxr.last < 25
  puts "SHORT-TERM TREND in longer-term range"
  puts "Use caution - may be counter-trend move"
elsif daily_adxr.last < 25 && weekly_adxr.last > 25
  puts "CONSOLIDATION within larger trend"
  puts "Potential opportunity for trend continuation entries"
else
  puts "NO CLEAR TREND on either timeframe"
  puts "Range-bound conditions"
end
```

## Example: ADXR Divergence Analysis

```ruby
high, low, close = load_historical_ohlc('NVDA')

adxr = SQA::TAI.adxr(high, low, close, period: 14)
prices = close

# Find recent highs in price and ADXR
price_high_recent = prices.last(20).max
price_high_previous = prices[-40..-21].max

adxr_at_recent_high = adxr[prices.rindex(price_high_recent)]
adxr_at_previous_high = adxr[prices[-40..-21].index(price_high_previous) - 40]

# Bearish divergence: price makes higher high, ADXR makes lower high
if price_high_recent > price_high_previous &&
   adxr_at_recent_high < adxr_at_previous_high &&
   adxr_at_previous_high > 25
  puts "BEARISH DIVERGENCE DETECTED"
  puts "Price higher high: #{price_high_previous.round(2)} -> #{price_high_recent.round(2)}"
  puts "ADXR lower high: #{adxr_at_previous_high.round(2)} -> #{adxr_at_recent_high.round(2)}"
  puts "Trend strength weakening despite price gains"
  puts "Warning: Potential trend exhaustion"
end

# Bullish divergence: price makes lower low, ADXR rising
price_low_recent = prices.last(20).min
price_low_previous = prices[-40..-21].min

adxr_at_recent_low = adxr[prices.rindex(price_low_recent)]
adxr_at_previous_low = adxr[prices[-40..-21].index(price_low_previous) - 40]

if price_low_recent < price_low_previous &&
   adxr_at_recent_low > adxr_at_previous_low
  puts "BULLISH DIVERGENCE DETECTED"
  puts "Price lower low: #{price_low_previous.round(2)} -> #{price_low_recent.round(2)}"
  puts "ADXR higher low: #{adxr_at_previous_low.round(2)} -> #{adxr_at_recent_low.round(2)}"
  puts "Trend strength building despite price decline"
  puts "Potential trend reversal developing"
end
```

## Common Settings

| Period | ADX Responsiveness | ADXR Smoothness | Use Case |
|--------|-------------------|-----------------|----------|
| 7 | Very responsive | Moderately smooth | Short-term trading |
| 14 | Standard (Wilder's) | Good balance | Most trading styles |
| 21 | Less responsive | Very smooth | Swing trading |
| 28 | Slow | Extremely smooth | Position trading |

## Trading Strategies

### 1. ADXR as Confirmation Filter
- Enter trend trades only when ADXR > 25
- Reduces false breakouts in ranging markets
- More reliable than ADX alone due to smoothing

### 2. ADXR Crossover with ADX
- When ADX crosses above ADXR: Trend accelerating
- When ADX crosses below ADXR: Trend decelerating
- Use with directional indicators for entry/exit

### 3. ADXR Threshold Strategy
```ruby
# Only trade when ADXR confirms sustained trend
if adxr.last > 25 && adxr[-5] > 25
  # Trend confirmed for multiple periods
  # Execute trend-following strategy
end
```

### 4. ADXR Range Exit
```ruby
# Exit trend positions when ADXR falls below threshold
if adxr.last < 20 && position_open
  puts "ADXR dropping below 20 - trend weakening"
  puts "Consider exiting trend-following positions"
end
```

## Advantages of ADXR over ADX

1. **Reduced Whipsaws**: Smoothing reduces false signals in volatile markets
2. **Better Confirmation**: Requires sustained trend strength before signaling
3. **Stable Readings**: Easier to interpret and act upon
4. **Less Noise**: Filters out short-term market fluctuations
5. **Trend Persistence**: Better for identifying lasting trends vs temporary moves

## Disadvantages of ADXR vs ADX

1. **Delayed Signals**: Slower to react to trend changes
2. **Missed Opportunities**: May miss quick reversals or short-term trends
3. **Late Exits**: Trend may weaken significantly before ADXR reflects it
4. **Less Sensitive**: Not ideal for short-term or day trading
5. **Requires More Data**: Needs double the periods for calculation

## When to Use ADXR vs ADX

**Use ADXR when:**
- Trading longer timeframes (4H, daily, weekly)
- Market is choppy and ADX gives false signals
- You want confirmation of sustained trends
- You prefer fewer but higher-quality signals
- Building position trading strategies

**Use ADX when:**
- Day trading or short-term trading
- Need early trend detection
- Market is clean and trending well
- Quick reaction time is essential
- Scalping or rapid position changes

**Use Both when:**
- You want both early detection (ADX) and confirmation (ADXR)
- Creating multi-indicator strategies
- ADX-ADXR crossovers provide additional signals
- Analyzing trend acceleration/deceleration

## Related Indicators

- [ADX](adx.md) - Parent indicator, more responsive version
- [PLUS_DI](plus_di.md) - Positive Directional Indicator (shows uptrend strength)
- [MINUS_DI](minus_di.md) - Negative Directional Indicator (shows downtrend strength)
- [DX](dx.md) - Directional Movement Index (base calculation for ADX/ADXR)
- [ATR](../volatility/atr.md) - Average True Range (related volatility measure)

## See Also

- [Back to Indicators](../index.md)
- [Momentum Indicators Overview](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
<!-- TODO: Create example file -->
- Trend Trading Example
