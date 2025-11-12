# CDL_DOJISTAR (Doji Star Candlestick Pattern)

## Overview

The Doji Star is a two or three-candle reversal pattern that combines the indecision of a Doji with gap characteristics. When a Doji forms after a gap following a strong trend, it signals potential exhaustion and reversal. The pattern is particularly powerful when the Doji gaps away from the previous candle's body, creating a "star" appearance that indicates a dramatic shift in market sentiment and momentum.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `open` | Array | Required | Array of opening prices for each period |
| `high` | Array | Required | Array of high prices for each period |
| `low` | Array | Required | Array of low prices for each period |
| `close` | Array | Required | Array of closing prices for each period |

### Parameter Details

**open, high, low, close (OHLC Data)**
- All four price arrays must be of equal length
- Each index represents the same time period across all arrays
- Prices should be in chronological order (oldest to newest)
- Minimum of 2 periods required to detect the pattern
- The pattern analyzes the relationship between consecutive candles to identify Doji Star formations

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

open  = [100.0, 105.0, 106.0, 107.0, 108.0]
high  = [101.0, 106.0, 106.5, 108.0, 109.0]
low   = [99.0, 104.5, 105.5, 106.5, 107.5]
close = [105.0, 105.5, 106.0, 107.5, 108.5]

# Detect Doji Star patterns
doji_star = SQA::TAI.cdl_dojistar(open, high, low, close)

if doji_star.last != 0
  puts "Doji Star detected!"
  if doji_star.last == 100
    puts "Bullish Doji Star - potential upward reversal"
  else
    puts "Bearish Doji Star - potential downward reversal"
  end
end
```

### With Trend Context

```ruby
open, high, low, close = load_ohlc_data('AAPL')

doji_star = SQA::TAI.cdl_dojistar(open, high, low, close)
sma_20 = SQA::TAI.sma(close, period: 20)
rsi = SQA::TAI.rsi(close, period: 14)

if doji_star.last == 100
  # Bullish Doji Star
  if close[-3] < sma_20[-3] && rsi.last < 40
    puts "Bullish Doji Star in downtrend - Strong reversal signal"
    puts "Gap up opening: #{open[-1]} vs prior close: #{close[-2]}"
  end
elsif doji_star.last == -100
  # Bearish Doji Star
  if close[-3] > sma_20[-3] && rsi.last > 60
    puts "Bearish Doji Star in uptrend - Strong reversal signal"
    puts "Gap down opening: #{open[-1]} vs prior close: #{close[-2]}"
  end
end
```

## Understanding the Pattern

### What It Measures

The Doji Star measures critical turning points where market momentum has shifted dramatically. The combination of a strong directional move followed by a gapped Doji reveals:

1. **Trend Exhaustion**: Previous trend has run its course
2. **Momentum Break**: Gap shows final push but Doji shows rejection
3. **Indecision at Extremes**: Uncertainty at potential top or bottom
4. **Reversal Setup**: Market preparing for direction change

The pattern's power comes from the gap itself - it represents an aggressive move by the trending side that immediately meets resistance, creating the Doji's indecision.

### Pattern Recognition Criteria

**Bullish Doji Star (in downtrend):**
1. **First Candle**: Long bearish candle continuing the downtrend
2. **Gap**: Doji gaps down from first candle's body
3. **Doji**: Small body with open ≈ close, showing indecision
4. **Location**: At support level or after extended decline

**Bearish Doji Star (in uptrend):**
1. **First Candle**: Long bullish candle continuing the uptrend
2. **Gap**: Doji gaps up from first candle's body
3. **Doji**: Small body with open ≈ close, showing indecision
4. **Location**: At resistance level or after extended rally

**Visual Pattern:**
```
Bearish Doji Star:        Bullish Doji Star:

      ---  (Doji)                |    (Large down candle)
                                 |
    |                          ---    (Doji - gapped down)
    |    (Large up candle)
    |
```

### Pattern Characteristics

- **Range**: Returns -100 (bearish), 0 (no pattern), or 100 (bullish)
- **Type**: Two-candle reversal pattern
- **Lag**: Real-time pattern recognition
- **Best Used**: After strong trends, at support/resistance, with volume confirmation
- **Reliability**: High when combined with trend context and confirmation

## Interpretation

### Value Ranges

- **-100**: Bearish Doji Star - potential downward reversal
- **0**: No Doji Star pattern detected
- **100**: Bullish Doji Star - potential upward reversal

### Market Psychology

**Bullish Doji Star Formation:**
1. **Strong Down Move**: Bears dominate, pushing prices lower
2. **Gap Down Opening**: Bears aggressive, expecting continuation
3. **Doji Forms**: Despite gap, equal buying and selling pressure
4. **Indecision**: Bears cannot follow through despite aggressive start
5. **Reversal Signal**: Selling exhausted, buyers may take control

**Bearish Doji Star Formation:**
1. **Strong Up Move**: Bulls dominate, pushing prices higher
2. **Gap Up Opening**: Bulls aggressive, expecting continuation
3. **Doji Forms**: Despite gap, equal buying and selling pressure
4. **Indecision**: Bulls cannot follow through despite aggressive start
5. **Reversal Signal**: Buying exhausted, sellers may take control

### Signal Interpretation

**Context Matters:**
- Pattern must appear after established trend
- Gap is critical - without gap, it's just a regular Doji
- Strength of prior trend affects reliability
- Distance of gap increases pattern significance

**At Key Technical Levels:**
- Doji Star at support (bullish) = high probability bottom
- Doji Star at resistance (bearish) = high probability top
- Round numbers or psychological levels amplify the signal

## Trading Signals

### Buy Signals (Bullish Doji Star)

Conditions for buy signals:

1. **Classic Setup**
   - Appears after downtrend (3+ bearish candles)
   - Gap down between first candle and Doji
   - Doji shows small body and indecision
   - Third candle confirms with bullish close

2. **High-Probability Setup**
   - At support level or Fibonacci retracement
   - RSI < 30 (oversold)
   - High volume on confirmation candle
   - Third candle closes above Doji high and first candle's close

**Example Scenario:**
```ruby
if doji_star[-2] == 100  # Bullish Doji Star two candles ago
  # Check for bullish confirmation
  if close[-1] > high[-2] && close[-1] > close[-3]
    puts "Bullish Doji Star confirmed - BUY signal"

    entry = close[-1]
    stop = low[-2] - (low[-2] * 0.005)
    risk = entry - stop
    target = entry + (risk * 2.5)

    puts "Entry: $#{entry.round(2)}"
    puts "Stop Loss: $#{stop.round(2)}"
    puts "Target: $#{target.round(2)}"
    puts "Risk:Reward = 1:2.5"
  end
end
```

### Sell Signals (Bearish Doji Star)

Conditions for sell signals:

1. **Classic Setup**
   - Appears after uptrend (3+ bullish candles)
   - Gap up between first candle and Doji
   - Doji shows small body and indecision
   - Third candle confirms with bearish close

2. **High-Probability Setup**
   - At resistance level or Fibonacci extension
   - RSI > 70 (overbought)
   - High volume on confirmation candle
   - Third candle closes below Doji low and first candle's close

**Example Scenario:**
```ruby
if doji_star[-2] == -100  # Bearish Doji Star two candles ago
  # Check for bearish confirmation
  if close[-1] < low[-2] && close[-1] < close[-3]
    puts "Bearish Doji Star confirmed - SELL signal"

    entry = close[-1]
    stop = high[-2] + (high[-2] * 0.005)
    risk = stop - entry
    target = entry - (risk * 2.5)

    puts "Entry: $#{entry.round(2)}"
    puts "Stop Loss: $#{stop.round(2)}"
    puts "Target: $#{target.round(2)}"
    puts "Risk:Reward = 1:2.5"
  end
end
```

### Confirmation Requirements

Essential confirmation factors:

1. **Trend Context**: Clear preceding trend required
2. **Gap Presence**: Must have gap between bodies
3. **Third Candle**: Confirmation candle in reversal direction
4. **Volume**: Increasing volume on confirmation adds conviction
5. **Technical Level**: Support/resistance alignment increases probability

**Advanced Confirmation:**
```ruby
if doji_star[-2].abs == 100
  gap_size = if doji_star[-2] == 100
    open[-2] - close[-3]  # Gap down size
  else
    open[-2] - close[-3]  # Gap up size
  end

  body_size = (close[-2] - open[-2]).abs
  gap_to_body_ratio = gap_size.abs / body_size

  if gap_to_body_ratio > 2
    puts "Strong gap (#{gap_to_body_ratio.round(1)}x body) - High probability pattern"
  elsif gap_to_body_ratio > 1
    puts "Moderate gap - Good setup"
  else
    puts "Small gap - Lower reliability"
  end
end
```

## Best Practices

### Optimal Use Cases

The Doji Star works best when:

**Market Conditions:**
- After extended trends (5+ candles same direction)
- At clearly defined support or resistance
- Following parabolic moves or blow-off tops/bottoms
- When momentum indicators show extremes or divergence

**Time Frames:**
- Daily charts: Most reliable and traditional
- Weekly charts: Rare but extremely significant
- 4-hour charts: Good for swing trading
- Intraday: Less reliable, requires strict confirmation

**Asset Classes:**
- Stocks: Excellent, especially at earnings or news events
- Indices: Very reliable for major reversals
- Forex: Good with major pairs at key levels
- Commodities: Effective after supply/demand shocks

### Combining with Other Indicators

**With Moving Averages:**
```ruby
doji_star = SQA::TAI.cdl_dojistar(open, high, low, close)
ema_20 = SQA::TAI.ema(close, period: 20)
ema_50 = SQA::TAI.ema(close, period: 50)

if doji_star.last == 100
  # Bullish Doji Star
  if close[-3] < ema_20[-3] && ema_20.last > ema_50.last
    puts "Bullish Doji Star with MA crossover - Strong buy setup"
  end
elsif doji_star.last == -100
  # Bearish Doji Star
  if close[-3] > ema_20[-3] && ema_20.last < ema_50.last
    puts "Bearish Doji Star with MA crossover - Strong sell setup"
  end
end
```

**With RSI:**
```ruby
doji_star = SQA::TAI.cdl_dojistar(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)

if doji_star.last == 100 && rsi.last < 30
  puts "Bullish Doji Star + Oversold RSI - STRONG BUY"
elsif doji_star.last == -100 && rsi.last > 70
  puts "Bearish Doji Star + Overbought RSI - STRONG SELL"
end
```

**With Support/Resistance:**
```ruby
doji_star = SQA::TAI.cdl_dojistar(open, high, low, close)

# Find key levels
resistance = high[-60..-3].max
support = low[-60..-3].min

if doji_star.last == 100
  distance_to_support = ((low[-2] - support) / support * 100).abs
  if distance_to_support < 2
    puts "Bullish Doji Star AT SUPPORT - High probability"
  end
elsif doji_star.last == -100
  distance_to_resistance = ((high[-2] - resistance) / resistance * 100).abs
  if distance_to_resistance < 2
    puts "Bearish Doji Star AT RESISTANCE - High probability"
  end
end
```

### Common Pitfalls

1. **No Gap Present**
   - Pattern requires gap between bodies
   - Without gap, it's just a regular Doji
   - Overlapping bodies = invalid pattern

2. **Trading Without Confirmation**
   - Never enter on Doji Star formation alone
   - Wait for third candle to validate direction
   - Premature entry leads to whipsaws

3. **Ignoring Trend Context**
   - Pattern only valid after established trend
   - Mid-consolidation Doji Stars are unreliable
   - Trend strength affects pattern reliability

4. **Wrong Stop Placement**
   - Stop should be beyond Doji's extreme
   - Too tight = premature exit
   - Too wide = poor risk:reward

### Parameter Selection Guidelines

**Day Trading:**
- Use 1-hour or 4-hour charts minimum
- Require immediate confirmation
- Tighter stops (1-2% beyond extremes)
- Be cautious of false gaps in illiquid hours

**Swing Trading:**
- Use daily charts for best results
- Allow 1-2 days for confirmation
- Stops 2-3% beyond pattern extremes
- Optimal risk:reward ratios

**Position Trading:**
- Use daily or weekly charts
- Wait for full week confirmation on weekly patterns
- Wider stops (5-7%) on weekly timeframes
- Major trend reversals possible

## Practical Example

Complete Doji Star trading system:

```ruby
require 'sqa/tai'

# Load data
open, high, low, close, volume = load_ohlc_volume_data('NVDA')

# Calculate indicators
doji_star = SQA::TAI.cdl_dojistar(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)
ema_20 = SQA::TAI.ema(close, period: 20)
ema_50 = SQA::TAI.ema(close, period: 50)
volume_sma = SQA::TAI.sma(volume, period: 20)

# Check for Doji Star pattern
if doji_star[-2].abs == 100
  puts "Doji Star Pattern Analysis"
  puts "=" * 60

  pattern_type = doji_star[-2] == 100 ? "Bullish" : "Bearish"
  puts "Pattern Type: #{pattern_type} Doji Star"

  # Trend analysis
  if pattern_type == "Bullish"
    trend_candles = close[-8..-3].select { |c| c < close[-9] }.count
    in_downtrend = trend_candles >= 4
    puts "In Downtrend: #{in_downtrend ? 'Yes' : 'No'} (#{trend_candles}/5 down candles)"
  else
    trend_candles = close[-8..-3].select { |c| c > close[-9] }.count
    in_uptrend = trend_candles >= 4
    puts "In Uptrend: #{in_uptrend ? 'Yes' : 'No'} (#{trend_candles}/5 up candles)"
  end

  # Gap analysis
  gap_size = (open[-2] - close[-3]).abs
  gap_percent = (gap_size / close[-3] * 100).round(2)
  puts "Gap Size: $#{gap_size.round(2)} (#{gap_percent}%)"

  # Doji characteristics
  doji_body = (close[-2] - open[-2]).abs
  doji_range = high[-2] - low[-2]
  body_to_range = (doji_body / doji_range * 100).round(1)
  puts "Doji Body/Range: #{body_to_range}% (smaller is better)"

  # RSI check
  rsi_val = rsi[-2]
  if pattern_type == "Bullish"
    rsi_status = rsi_val < 30 ? "Oversold - Excellent" : (rsi_val < 40 ? "Low - Good" : "Neutral")
  else
    rsi_status = rsi_val > 70 ? "Overbought - Excellent" : (rsi_val > 60 ? "High - Good" : "Neutral")
  end
  puts "RSI: #{rsi_val.round(2)} (#{rsi_status})"

  # Volume
  vol_ratio = volume[-2] / volume_sma[-2]
  puts "Volume: #{vol_ratio.round(2)}x average"

  # Key levels
  resistance = high[-60..-3].max
  support = low[-60..-3].min

  if pattern_type == "Bullish"
    distance = ((low[-2] - support) / support * 100).abs
    at_level = distance < 3
    puts "Distance to Support: #{distance.round(2)}% #{at_level ? '(AT SUPPORT)' : ''}"
  else
    distance = ((high[-2] - resistance) / resistance * 100).abs
    at_level = distance < 3
    puts "Distance to Resistance: #{distance.round(2)}% #{at_level ? '(AT RESISTANCE)' : ''}"
  end

  # Confirmation check
  has_confirmation = if pattern_type == "Bullish"
    close[-1] > high[-2] && close[-1] > close[-3]
  else
    close[-1] < low[-2] && close[-1] < close[-3]
  end

  puts "\nConfirmation: #{has_confirmation ? 'YES' : 'WAITING'}"

  # Scoring system
  score = 0
  score += 2 if (pattern_type == "Bullish" && in_downtrend) || (pattern_type == "Bearish" && in_uptrend)
  score += 1 if gap_percent > 0.5
  score += 1 if body_to_range < 20
  score += 1 if (pattern_type == "Bullish" && rsi_val < 40) || (pattern_type == "Bearish" && rsi_val > 60)
  score += 1 if vol_ratio > 1.2
  score += 1 if at_level
  score += 2 if has_confirmation

  puts "\nSetup Quality Score: #{score}/9"

  # Trade execution
  if has_confirmation && score >= 7
    if pattern_type == "Bullish"
      entry = close[-1]
      stop = low[-2] - (low[-2] * 0.008)
      risk = entry - stop
      target = entry + (risk * 3)

      puts "\n*** STRONG BULLISH SETUP - BUY SIGNAL ***"
      puts "Entry: $#{entry.round(2)}"
      puts "Stop Loss: $#{stop.round(2)}"
      puts "Target: $#{target.round(2)}"
      puts "Risk: $#{risk.round(2)} (#{((risk/entry)*100).round(2)}%)"
      puts "Reward: $#{(target-entry).round(2)} (#{(((target-entry)/entry)*100).round(2)}%)"
      puts "R:R = 1:3"

    else
      entry = close[-1]
      stop = high[-2] + (high[-2] * 0.008)
      risk = stop - entry
      target = entry - (risk * 3)

      puts "\n*** STRONG BEARISH SETUP - SELL SIGNAL ***"
      puts "Entry: $#{entry.round(2)}"
      puts "Stop Loss: $#{stop.round(2)}"
      puts "Target: $#{target.round(2)}"
      puts "Risk: $#{risk.round(2)} (#{((risk/entry)*100).round(2)}%)"
      puts "Reward: $#{(entry-target).round(2)} (#{(((entry-target)/entry)*100).round(2)}%)"
      puts "R:R = 1:3"
    end

  elsif score >= 5
    puts "\nDECENT SETUP (Score: #{score}/9)"
    puts "Consider: Reduced position size or wait for better confirmation"

  else
    puts "\nLOW PROBABILITY SETUP (Score: #{score}/9)"
    puts "Recommendation: Skip this trade"
  end
end
```

## Related Indicators

### Similar Patterns

- **[Doji](cdl_doji.md)**: Single-candle indecision pattern without gap requirement
- **[Morning Star](cdl_morningstar.md)**: Three-candle bullish reversal with Doji as middle candle
- **[Evening Star](cdl_eveningstar.md)**: Three-candle bearish reversal with Doji as middle candle
- **[Abandoned Baby](cdl_abandonedbaby.md)**: Rare gapped Doji pattern with gaps on both sides

### Complementary Patterns

- **[Engulfing](cdl_engulfing.md)**: Strong two-candle reversal pattern
- **[Harami](cdl_harami.md)**: Two-candle pattern showing momentum shift
- **[Piercing Line](cdl_piercing.md)**: Bullish two-candle reversal
- **[Dark Cloud Cover](cdl_darkcloudcover.md)**: Bearish two-candle reversal

### Pattern Family

The Doji Star is part of the star pattern family:
- **Doji Star**: Reversal pattern with gapped Doji
- **Morning Star**: Bullish reversal with small-bodied middle candle
- **Evening Star**: Bearish reversal with small-bodied middle candle
- **Abandoned Baby**: Rare pattern with gaps on both sides of Doji

## Advanced Topics

### Multi-Timeframe Analysis

Increase probability by confirming across timeframes:

```ruby
# Daily Doji Star - primary signal
daily_doji_star = SQA::TAI.cdl_dojistar(daily_open, daily_high, daily_low, daily_close)

# Weekly trend - larger context
weekly_trend = weekly_close.last > weekly_sma50.last ? "up" : "down"

# 4-hour confirmation - precise timing
hourly_confirmation = if daily_doji_star.last == 100
  hourly_close.last > hourly_high[-5]
else
  hourly_close.last < hourly_low[-5]
end

if daily_doji_star.last.abs == 100
  puts "Daily Doji Star detected"
  puts "Weekly trend: #{weekly_trend}"
  puts "4-hour confirmation: #{hourly_confirmation ? 'Yes' : 'Pending'}"

  if (daily_doji_star.last == 100 && weekly_trend == "down") ||
     (daily_doji_star.last == -100 && weekly_trend == "up")
    puts "High probability major reversal setup!"
  end
end
```

### Market Regime Adaptation

**Trending Markets:**
- Doji Star highly reliable as reversal
- Strong confirmation candles expected
- Larger price targets justified

**Ranging Markets:**
- Doji Star at range boundaries
- Expect smaller reversals
- Quick profit-taking recommended

**High Volatility:**
- Larger gaps common
- Wider stops required
- Pattern remains valid but needs larger confirmation

### Statistical Validation

Research and backtesting indicate:
- **Success Rate**: 65-70% with proper confirmation
- **Best Performance**: At support/resistance with RSI extremes
- **Gap Impact**: Larger gaps (>1%) improve success by 15-20%
- **Volume**: High volume increases reliability by 20%
- **Confirmation**: Third candle confirmation adds 25-30% to success rate

## References

- Nison, Steve. "Japanese Candlestick Charting Techniques" - Comprehensive star pattern analysis
- Bulkowski, Thomas N. "Encyclopedia of Candlestick Charts" - Statistical performance data
- Morris, Gregory L. "Candlestick Charting Explained" - Practical trading applications
- [StockCharts.com - Doji Star](https://stockcharts.com/school/doku.php?id=chart_school:chart_analysis:introduction_to_candlesticks) - Educational resource

## See Also

- [Candlestick Pattern Overview](../patterns/index.md)
- [Doji Pattern](cdl_doji.md)
- [Morning Star Pattern](cdl_morningstar.md)
- [Evening Star Pattern](cdl_eveningstar.md)
- [Abandoned Baby Pattern](cdl_abandonedbaby.md)
- [RSI Indicator](../momentum/rsi.md)
