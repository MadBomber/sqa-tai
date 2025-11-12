# CDL_HANGINGMAN (Hanging Man Candlestick Pattern)

## Overview

The Hanging Man is a bearish reversal candlestick pattern that forms during an uptrend. Visually identical to the bullish Hammer pattern, the Hanging Man has a small body at the upper end of the trading range with a long lower shadow. Despite buyers initially pushing prices lower, they managed to recover by the close, but this recovery attempt signals exhaustion and potential weakness in the uptrend rather than strength.

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
- Minimum of 1 period required, but historical context improves pattern reliability
- The pattern detection analyzes price relationships to identify Hanging Man formations

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

open  = [100.0, 102.0, 104.0, 106.0, 108.0]
high  = [101.0, 103.0, 105.0, 107.0, 108.5]
low   = [99.0, 101.5, 103.5, 104.0, 106.0]
close = [100.5, 102.5, 104.5, 106.5, 108.0]

# Detect Hanging Man patterns
hanging_man = SQA::TAI.cdl_hangingman(open, high, low, close)

if hanging_man.last == -100
  puts "Hanging Man detected - Bearish reversal signal!"
end
```

### With Trend Analysis

```ruby
open, high, low, close = load_ohlc_data('AAPL')

hanging_man = SQA::TAI.cdl_hangingman(open, high, low, close)
sma_50 = SQA::TAI.sma(close, period: 50)

if hanging_man.last == -100
  # Verify uptrend context
  in_uptrend = close[-2] > sma_50[-2] && close[-2] > close[-10]

  if in_uptrend
    puts "Hanging Man in uptrend - Strong reversal signal!"
    puts "Current: #{close.last.round(2)}"
    puts "Wait for bearish confirmation candle"
  else
    puts "Hanging Man detected but not in uptrend"
    puts "Less reliable - exercise caution"
  end
end
```

## Understanding the Pattern

### What It Measures

The Hanging Man measures potential exhaustion in an uptrend. Despite its bullish appearance (recovery from lows), the pattern suggests that:

1. **Sellers Are Testing**: Bears attempted to push prices significantly lower
2. **Weak Recovery**: Bulls could only manage to close near the open, not near the highs
3. **Buyer Exhaustion**: The inability to sustain higher prices indicates weakening demand
4. **Momentum Shift**: The balance of power may be shifting from buyers to sellers

The key insight: In a healthy uptrend, any selling pressure should be quickly absorbed. When sellers can drive prices sharply lower (even temporarily), it reveals underlying weakness.

### Pattern Recognition Criteria

For a valid Hanging Man pattern:

1. **Location**: Must appear in an established uptrend (critical difference from Hammer)
2. **Small Body**: Real body at the upper end of the trading range
3. **Long Lower Shadow**: At least 2-3× the height of the body
4. **Little/No Upper Shadow**: Close should be near the high
5. **Body Color**: Can be bullish or bearish, though bearish is more significant

**Visual Pattern:**
```
After uptrend:

  -----  (small body at top)
    |
    |
    |    (long lower shadow - 2-3× body)
    |
    |
```

### Pattern Characteristics

- **Range**: Returns 0 (no pattern) or -100 (bearish Hanging Man detected)
- **Type**: Single-candle bearish reversal pattern
- **Lag**: Real-time pattern recognition (no calculation lag)
- **Best Used**: In established uptrends, at resistance levels, after strong rallies
- **Reliability**: Medium to high with proper confirmation and context

## Interpretation

### Value Ranges

- **0**: No Hanging Man pattern detected
- **-100**: Hanging Man pattern detected - potential bearish reversal signal

### Market Psychology

The Hanging Man tells a story of failed bullishness:

**During the Session:**
1. **Opening**: Price opens near recent highs
2. **Mid-Session Selloff**: Strong selling pressure drives prices sharply lower
3. **Recovery Attempt**: Bulls fight back, pushing prices higher
4. **Weak Close**: Despite recovery, close is only near the open, not at new highs

**What It Means:**
- Buyers losing control - couldn't maintain upward momentum
- Sellers showing strength - able to drive significant intraday decline
- Market indecision - equilibrium between bulls and bears
- Potential top formation - uptrend may be exhausting

### Signal Interpretation

**Context Is Critical:**

The identical pattern has opposite meanings in different contexts:
- **In Uptrend** = Hanging Man (bearish)
- **In Downtrend** = Hammer (bullish)

**After Strong Uptrend:**
- Hanging Man suggests rally exhaustion
- Buyers unable to push to new highs
- Sellers testing lower prices successfully
- Increased probability of reversal

**At Resistance:**
- Pattern significance amplified
- Bulls failed to break through resistance
- Sellers defending key level
- High-probability reversal zone

## Trading Signals

### Sell Signals

The Hanging Man generates sell signals when:

1. **Classic Setup**
   - Appears after 3+ days of rising prices
   - Long lower shadow (2-3× body size)
   - Close near the high but not at new highs
   - Confirmed by next day's bearish candle

2. **High-Probability Setup**
   - At resistance level
   - RSI > 60 (overbought territory)
   - High volume on the Hanging Man day
   - Bearish confirmation closes below Hanging Man body

**Example Scenario:**
```ruby
if hanging_man[-2] == -100  # Previous candle was Hanging Man
  # Wait for bearish confirmation
  if close[-1] < close[-2]  # Confirmation candle closed lower
    puts "Hanging Man confirmed by bearish follow-through"

    entry = close[-1]
    stop = high[-2]
    risk = stop - entry
    target = entry - (risk * 2)

    puts "SHORT Entry: #{entry.round(2)}"
    puts "Stop Loss: #{stop.round(2)}"
    puts "Target: #{target.round(2)}"
    puts "Risk:Reward = 1:2"
  end
end
```

### Confirmation Requirements

Never trade a Hanging Man without confirmation:

1. **Trend Context**: Must be in uptrend
2. **Confirmation Candle**: Next candle should close lower (preferably below Hanging Man body)
3. **Volume**: Higher volume increases reliability
4. **Technical Level**: Appearance at resistance adds significance
5. **Momentum**: Overbought RSI or bearish MACD divergence

**Conservative Confirmation:**
```ruby
if hanging_man[-2] == -100
  confirmation_close = close[-1]
  hanging_man_body = [open[-2], close[-2]].min

  # Strong confirmation = close below entire Hanging Man body
  if confirmation_close < hanging_man_body
    puts "STRONG confirmation - High probability short"
  elsif confirmation_close < close[-2]
    puts "Weak confirmation - Use caution"
  else
    puts "No confirmation - Pattern failed"
  end
end
```

### False Signal Recognition

Avoid these false signals:

**Pattern Failure Indicators:**
- Next candle closes higher (bullish continuation)
- Appears mid-trend without resistance
- Very low volume on pattern day
- Short lower shadow (< 2× body)
- Not in uptrend context

## Best Practices

### Optimal Use Cases

The Hanging Man works best when:

**Market Conditions:**
- After extended uptrend (5+ days)
- At clearly defined resistance levels
- Following parabolic price moves
- When momentum indicators show divergence

**Time Frames:**
- Daily charts: Most reliable
- Weekly charts: Very significant (rare but powerful)
- 4-hour charts: Good for swing trading
- Intraday (< 1 hour): Higher false signal rate

**Asset Classes:**
- Stocks: Excellent, especially at previous highs
- Indices: Reliable for market tops
- Commodities: Effective after strong rallies
- Crypto: Works but needs larger confirmation due to volatility

### Combining with Other Indicators

**With Resistance Levels:**
```ruby
hanging_man = SQA::TAI.cdl_hangingman(open, high, low, close)

# Find recent resistance
resistance = high[-60..-2].max

if hanging_man.last == -100
  distance = ((close.last - resistance) / resistance * 100).abs

  if distance < 2  # Within 2% of resistance
    puts "Hanging Man AT RESISTANCE!"
    puts "High probability reversal zone"
  end
end
```

**With RSI:**
```ruby
hanging_man = SQA::TAI.cdl_hangingman(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)

if hanging_man.last == -100
  if rsi.last > 70
    puts "Hanging Man + Overbought RSI - STRONG SELL"
  elsif rsi.last > 60
    puts "Hanging Man + High RSI - Good setup"
  else
    puts "Hanging Man without overbought - Lower probability"
  end
end
```

**With Volume:**
```ruby
hanging_man = SQA::TAI.cdl_hangingman(open, high, low, close)
volume_avg = volume[-20..-1].sum / 20.0

if hanging_man.last == -100
  if volume.last > volume_avg * 1.5
    puts "Hanging Man with HIGH VOLUME - Significant"
  else
    puts "Hanging Man with normal/low volume - Less reliable"
  end
end
```

### Common Pitfalls

1. **Trading Without Uptrend**
   - Pattern only valid after uptrend
   - In downtrend, it's a bullish Hammer
   - Context determines meaning

2. **No Confirmation Wait**
   - Immediate entry = high whipsaw risk
   - Always wait for bearish confirmation
   - Confirmation dramatically improves success rate

3. **Ignoring Shadow Length**
   - Short shadow = weak pattern
   - Long shadow (3×+ body) = stronger signal
   - Shadow length indicates selling pressure magnitude

4. **Wrong Stop Placement**
   - Stop too tight = premature exit
   - Stop should be above Hanging Man high
   - Allow for normal volatility

### Parameter Selection Guidelines

**Day Trading (15min - 1hr):**
- Higher false signal rate
- Require immediate confirmation
- Tight stops (1-2% above high)
- Multiple timeframe confirmation

**Swing Trading (Daily charts):**
- Best reliability
- Wait for daily confirmation candle
- Stops 2-3% above Hanging Man high
- Optimal risk:reward ratios

**Position Trading (Weekly charts):**
- Very rare but highly significant
- Wait for weekly confirmation
- Wider stops acceptable (5-7%)
- Major trend reversals

## Practical Example

Complete Hanging Man trading system:

```ruby
require 'sqa/tai'

# Load data
open, high, low, close, volume = load_ohlc_volume_data('TSLA')

# Calculate indicators
hanging_man = SQA::TAI.cdl_hangingman(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)
sma_50 = SQA::TAI.sma(close, period: 50)
volume_sma = SQA::TAI.sma(volume, period: 20)

# Check previous candle for Hanging Man
if hanging_man[-2] == -100
  puts "Hanging Man Pattern Analysis"
  puts "=" * 50

  # Trend context
  in_uptrend = close[-3] > sma_50[-3] && close[-3] > close[-8]
  puts "In Uptrend: #{in_uptrend ? 'Yes' : 'No'}"

  # RSI check
  rsi_val = rsi[-2]
  overbought = rsi_val > 60
  puts "RSI: #{rsi_val.round(2)} (Overbought: #{overbought})"

  # Volume check
  vol_ratio = volume[-2] / volume_sma[-2]
  high_volume = vol_ratio > 1.3
  puts "Volume: #{vol_ratio.round(2)}x avg (High: #{high_volume})"

  # Shadow length check
  body = (close[-2] - open[-2]).abs
  lower_shadow = [open[-2], close[-2]].min - low[-2]
  shadow_ratio = lower_shadow / body
  strong_shadow = shadow_ratio >= 2.5
  puts "Lower Shadow: #{shadow_ratio.round(1)}x body (Strong: #{strong_shadow})"

  # Resistance check
  resistance = high[-60..-2].max
  at_resistance = (high[-2] - resistance).abs < resistance * 0.03
  puts "At Resistance: #{at_resistance ? 'Yes' : 'No'}"

  # Confirmation check
  confirmation = close[-1] < close[-2]
  strong_confirmation = close[-1] < [open[-2], close[-2]].min

  if confirmation
    puts "\nConfirmation: #{strong_confirmation ? 'STRONG' : 'Weak'}"
  else
    puts "\nNo Confirmation - Pattern Failed"
  end

  # Scoring system
  score = 0
  score += 1 if in_uptrend
  score += 1 if overbought
  score += 1 if high_volume
  score += 1 if strong_shadow
  score += 1 if at_resistance
  score += 1 if strong_confirmation

  puts "\nSetup Score: #{score}/6"

  # Trade decision
  if score >= 5 && confirmation
    entry = close[-1]
    stop = high[-2] + (high[-2] * 0.005)
    risk = stop - entry
    target = entry - (risk * 2.5)

    puts "\n*** HIGH PROBABILITY SHORT SETUP ***"
    puts "Entry: $#{entry.round(2)}"
    puts "Stop Loss: $#{stop.round(2)}"
    puts "Target: $#{target.round(2)}"
    puts "Risk: $#{risk.round(2)} (#{((risk/entry)*100).round(2)}%)"
    puts "Reward: $#{(entry-target).round(2)} (#{(((entry-target)/entry)*100).round(2)}%)"
    puts "R:R = 1:2.5"

  elsif score >= 4
    puts "\nDECENT SETUP - Consider reduced position size"
  elsif score >= 3
    puts "\nMARGINAL SETUP - High risk"
  else
    puts "\nLOW PROBABILITY - Skip this trade"
  end
end
```

## Related Indicators

### Similar Patterns

- **[Hammer](cdl_hammer.md)**: Identical shape but appears in downtrend (bullish)
- **[Shooting Star](cdl_shootingstar.md)**: Bearish reversal with long upper shadow
- **[Inverted Hammer](cdl_invertedhammer.md)**: Bullish reversal with long upper shadow

### Complementary Patterns

- **[Evening Star](cdl_eveningstar.md)**: Three-candle bearish reversal pattern
- **[Bearish Engulfing](cdl_engulfing.md)**: Strong two-candle bearish reversal
- **[Dark Cloud Cover](cdl_darkcloudcover.md)**: Two-candle bearish reversal at tops

### Pattern Family

The Hanging Man belongs to the hammer family:
- **Hammer**: Bullish (in downtrend)
- **Hanging Man**: Bearish (in uptrend)
- **Inverted Hammer**: Bullish (in downtrend)
- **Shooting Star**: Bearish (in uptrend)

## Advanced Topics

### Multi-Timeframe Analysis

```ruby
# Daily Hanging Man
daily_hm = SQA::TAI.cdl_hangingman(daily_open, daily_high, daily_low, daily_close)

# Weekly trend context
weekly_uptrend = weekly_close.last > weekly_sma50.last

# 4-hour confirmation timing
hourly_breakdown = hourly_close.last < hourly_support

if daily_hm.last == -100 && weekly_uptrend
  puts "Daily Hanging Man in weekly uptrend - Major reversal potential"

  if hourly_breakdown
    puts "4-hour breakdown confirms - High probability short"
  end
end
```

### Market Regime Adaptation

**Bull Market:**
- Hanging Man more significant
- Major trend reversals possible
- Larger position sizes justified

**Bear Market Rallies:**
- Hanging Man ends counter-trend rallies
- Quick, sharp reversals
- Excellent risk:reward setups

**Ranging Market:**
- Hanging Man at range top
- Good for swing trades
- Smaller moves expected

### Statistical Validation

Research and backtesting show:
- **Success Rate**: 55-60% with confirmation, 40-45% without
- **Best Performance**: At resistance with RSI > 65
- **Volume Impact**: High volume increases success by 15-20%
- **Confirmation**: Improves win rate by 20-25%
- **Time Frame**: Daily charts 12-18% more reliable than hourly

## References

- Nison, Steve. "Japanese Candlestick Charting Techniques" - Comprehensive coverage of Hanging Man pattern
- Bulkowski, Thomas N. "Encyclopedia of Candlestick Charts" - Statistical analysis showing ~60% success rate
- Morris, Gregory L. "Candlestick Charting Explained" - Practical applications in modern markets
- [StockCharts.com - Hanging Man](https://stockcharts.com/school/doku.php?id=chart_school:chart_analysis:candlestick_pattern_dictionary#hammer_pattern_bullish_reversal) - Educational resource

## See Also

- [Candlestick Pattern Overview](../patterns/index.md)
- [Hammer Pattern](cdl_hammer.md) - Bullish counterpart
- [Shooting Star Pattern](cdl_shootingstar.md) - Similar bearish reversal
- [Evening Star Pattern](cdl_eveningstar.md) - Multi-candle bearish reversal
- [RSI Indicator](../momentum/rsi.md)
- [Support and Resistance](../../concepts/support-resistance.md)
