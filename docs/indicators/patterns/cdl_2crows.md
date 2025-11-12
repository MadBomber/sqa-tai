# Two Crows Pattern

The Two Crows is a rare three-candlestick bearish reversal pattern that appears at the top of an uptrend. It consists of a long bullish candle followed by two bearish candles that gap up but fail to hold their gains, suggesting the uptrend is losing momentum.

## Pattern Type

- **Type**: Bearish Reversal
- **Candles Required**: 3
- **Trend Context**: Appears after uptrend
- **Reliability**: Medium to High (when confirmed)
- **Frequency**: Rare

## Usage

```ruby
require 'sqa/tai'

open  = [100.0, 102.0, 104.0, 103.5, 103.0]
high  = [102.5, 105.0, 105.5, 105.0, 104.5]
low   = [99.5, 101.5, 102.5, 102.0, 101.5]
close = [102.0, 104.5, 103.0, 102.5, 101.0]

# Detect Two Crows pattern
pattern = SQA::TAI.cdl_2crows(open, high, low, close)

if pattern.last == -100
  puts "Two Crows detected - Bearish reversal signal!"
end
```

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `open` | Array<Float> | Yes | Array of opening prices |
| `high` | Array<Float> | Yes | Array of high prices |
| `low` | Array<Float> | Yes | Array of low prices |
| `close` | Array<Float> | Yes | Array of closing prices |

## Returns

Returns an array of integers:
- **0**: No Two Crows pattern detected
- **-100**: Two Crows pattern detected (bearish reversal signal)

Note: This pattern only returns bearish signals. There is no bullish equivalent.

## Pattern Recognition Rules

### Three Candle Structure

1. **First Candle**: Long bullish (white) candle in an established uptrend
2. **Second Candle**: Bearish (black) candle that gaps up above first candle's close but closes lower
3. **Third Candle**: Another bearish candle that opens within second candle's body and closes lower, ideally near first candle's close

### Key Characteristics

- First candle shows strong bullish momentum
- Second candle gaps up (bullish gap) but closes bearish
- Third candle continues lower, confirming weakness
- Pattern looks like two crows (bearish candles) sitting on a branch (first bullish candle)
- The failure to hold the gap suggests exhaustion

## Visual Pattern

```
After uptrend:

        [==]     Second candle (gaps up, closes lower)
       [===]     Third candle (continues down)

    [=======]    First candle (long bullish)
     |     |
```

## Interpretation

The Two Crows pattern signals potential trend reversal through:

1. **Gap Failure**: Bulls gap price higher but can't maintain gains
2. **Momentum Shift**: Two consecutive bearish closes after gap
3. **Exhaustion Signal**: Buyers losing control at trend top
4. **Crow Formation**: Pattern name comes from visual of two crows (bearish candles) perched on a tree

### Reliability Factors

| Factor | Low Reliability | Medium Reliability | High Reliability |
|--------|----------------|-------------------|------------------|
| Trend Strength | Weak uptrend | Clear uptrend | Strong uptrend |
| Volume | Decreasing | Normal | Increasing on black candles |
| Gap Size | Small gap | Moderate gap | Large gap that fails |
| Location | Mid-chart | Near resistance | At major resistance |
| Third Candle | Shallow close | Moderate close | Closes near first candle |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

## Example: Two Crows in Uptrend Context

```ruby
open, high, low, close = load_ohlc_data('AAPL')

pattern = SQA::TAI.cdl_2crows(open, high, low, close)
sma_50 = SQA::TAI.sma(close, period: 50)
sma_200 = SQA::TAI.sma(close, period: 200)

if pattern.last == -100
  # Verify uptrend context
  in_uptrend = close[-4] > sma_50[-4] && sma_50[-4] > sma_200[-4]

  if in_uptrend
    puts "Two Crows pattern in strong uptrend!"
    puts "High probability bearish reversal"
    puts "Current price: #{close.last.round(2)}"
    puts "SMA(50): #{sma_50.last.round(2)}"

    # Calculate gap
    gap_size = ((open[-2] - close[-3]) / close[-3] * 100).round(2)
    puts "Gap up size: #{gap_size}%"

    # Check how far third candle retraced
    retrace = ((close[-3] - close.last) / close[-3] * 100).round(2)
    puts "Retracement: #{retrace}%"
  else
    puts "Two Crows but not in clear uptrend"
    puts "Lower reliability - verify context"
  end
end
```

## Example: Two Crows with Volume Analysis

```ruby
open, high, low, close, volume = load_ohlc_volume_data('TSLA')

pattern = SQA::TAI.cdl_2crows(open, high, low, close)

if pattern.last == -100
  # Volume analysis
  vol_first = volume[-3]   # Bullish candle
  vol_second = volume[-2]  # First crow
  vol_third = volume[-1]   # Second crow
  avg_volume = volume[-20..-1].sum / 20.0

  puts "Two Crows Volume Analysis:"
  puts "First candle (bullish): #{vol_first.round(0)}"
  puts "Second candle (crow 1): #{vol_second.round(0)}"
  puts "Third candle (crow 2): #{vol_third.round(0)}"
  puts "Average volume: #{avg_volume.round(0)}"

  # Ideal: Increasing volume on bearish candles
  if vol_second > vol_first && vol_third > vol_second
    puts "\nSTRONG PATTERN: Increasing volume on decline"
    puts "High conviction selling"
  elsif vol_second > avg_volume || vol_third > avg_volume
    puts "\nGOOD PATTERN: Above average volume on crows"
  else
    puts "\nWEAK PATTERN: Low volume"
    puts "Less reliable - wait for confirmation"
  end
end
```

## Example: Two Crows at Resistance

```ruby
open, high, low, close = load_ohlc_data('MSFT')

pattern = SQA::TAI.cdl_2crows(open, high, low, close)

# Find resistance
resistance = close[-120..-1].max

if pattern.last == -100
  distance_from_resistance = ((high[-2] - resistance) / resistance * 100).abs

  if distance_from_resistance < 2  # Within 2% of resistance
    puts "Two Crows AT MAJOR RESISTANCE!"
    puts "Resistance level: #{resistance.round(2)}"
    puts "Pattern high: #{high[-2].round(2)}"
    puts "Current close: #{close.last.round(2)}"
    puts "\nFailed breakout - sellers defending resistance"
    puts "HIGH PROBABILITY reversal setup"
  end
end
```

## Example: Two Crows with RSI Confirmation

```ruby
open, high, low, close = load_ohlc_data('NVDA')

pattern = SQA::TAI.cdl_2crows(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)

if pattern.last == -100
  rsi_at_pattern = rsi[-3]  # RSI at first candle
  rsi_current = rsi.last

  puts "Two Crows Pattern with RSI:"
  puts "RSI at pattern start: #{rsi_at_pattern.round(2)}"
  puts "Current RSI: #{rsi_current.round(2)}"

  if rsi_at_pattern > 70
    puts "\nOVERBOUGHT RSI + Two Crows"
    puts "Multiple bearish signals - Strong SELL setup"
  elsif rsi_at_pattern > 60
    puts "\nElevated RSI + Two Crows"
    puts "Good reversal confirmation"
  else
    puts "\nTwo Crows without overbought RSI"
    puts "Moderate signal strength"
  end
end
```

## Trading Strategies

### Entry Rules

#### Conservative Entry (Recommended)
```ruby
# Wait for confirmation candle after pattern
if pattern[-2] == -100  # Pattern two candles ago
  if close[-1] < close[-2]  # Confirmation: another bearish close
    puts "Two Crows CONFIRMED - Enter SHORT"
    entry = close.last
    puts "Entry: #{entry.round(2)}"
  end
end
```

#### Aggressive Entry
```ruby
# Enter on pattern completion (third candle close)
if pattern.last == -100
  entry = close.last
  puts "Two Crows completed - Enter SHORT at #{entry.round(2)}"
  puts "Higher risk - no confirmation"
end
```

### Stop Loss Placement

```ruby
if pattern.last == -100
  # Stop above the gap high (second candle's high)
  stop = high[-2]
  stop_with_buffer = stop * 1.01  # 1% buffer

  puts "Stop loss: #{stop_with_buffer.round(2)}"
  puts "Rationale: Above gap high - pattern invalidated if exceeded"

  # Alternative: Stop above first candle high
  alt_stop = high[-3] * 1.01
  puts "Alternative stop (wider): #{alt_stop.round(2)}"
end
```

### Profit Targets

```ruby
if pattern.last == -100
  entry = close.last
  stop = high[-2] * 1.01
  risk = stop - entry

  # Multiple targets
  target_1 = entry - (risk * 1.5)  # 1.5:1 R:R
  target_2 = entry - (risk * 2.5)  # 2.5:1 R:R
  target_3 = entry - (risk * 4.0)  # 4:1 R:R

  puts "Profit Targets:"
  puts "T1 (1.5:1): #{target_1.round(2)}"
  puts "T2 (2.5:1): #{target_2.round(2)}"
  puts "T3 (4:1): #{target_3.round(2)}"

  # Or target previous support
  support = close[-60..-1].min
  puts "Support target: #{support.round(2)}"
end
```

## Example: Complete Trading System

```ruby
open, high, low, close, volume = load_ohlc_volume_data('GOOGL')

pattern = SQA::TAI.cdl_2crows(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)
sma_50 = SQA::TAI.sma(close, period: 50)
sma_200 = SQA::TAI.sma(close, period: 200)

if pattern.last == -100
  puts "Two Crows Pattern Detected"
  puts "=" * 50

  # 1. Trend verification
  in_uptrend = close[-4] > sma_50[-4] && sma_50[-4] > sma_200[-4]

  # 2. RSI check
  rsi_overbought = rsi[-3] > 60

  # 3. Volume analysis
  avg_vol = volume[-20..-1].sum / 20.0
  vol_increasing = volume[-2] > volume[-3] && volume[-1] > avg_vol

  # 4. Resistance check
  resistance = close[-120..-1].max
  near_resistance = (high[-2] - resistance).abs < resistance * 0.03

  # 5. Gap analysis
  gap_size = ((open[-2] - close[-3]) / close[-3] * 100)
  significant_gap = gap_size > 1.0

  # 6. Retracement check
  retraced_well = close.last < (close[-3] + (high[-2] - close[-3]) * 0.5)

  # Calculate score
  score = 0
  score += 1 if in_uptrend
  score += 1 if rsi_overbought
  score += 1 if vol_increasing
  score += 1 if near_resistance
  score += 1 if significant_gap
  score += 1 if retraced_well

  puts "Setup Analysis:"
  puts "In uptrend: #{in_uptrend} (#{score >= 1 ? '✓' : '✗'})"
  puts "RSI overbought: #{rsi_overbought} (RSI: #{rsi[-3].round(2)})"
  puts "Volume increasing: #{vol_increasing}"
  puts "Near resistance: #{near_resistance}"
  puts "Significant gap: #{significant_gap} (#{gap_size.round(2)}%)"
  puts "Good retracement: #{retraced_well}"
  puts "\nSetup Score: #{score}/6"

  if score >= 4
    entry = close.last
    stop = high[-2] * 1.01
    risk = stop - entry
    target = entry - (risk * 3)

    puts "\n*** HIGH PROBABILITY SHORT SETUP ***"
    puts "Entry: #{entry.round(2)}"
    puts "Stop: #{stop.round(2)}"
    puts "Target: #{target.round(2)}"
    puts "Risk: $#{risk.round(2)}"
    puts "Reward: $#{(entry - target).round(2)}"
    puts "R:R Ratio: 1:3"

    # Position sizing
    account_size = 100000
    risk_percent = 0.01  # 1% account risk
    risk_amount = account_size * risk_percent
    shares = (risk_amount / risk).floor
    puts "\nPosition Size: #{shares} shares"
    puts "Total risk: $#{risk_amount.round(2)} (1% of account)"
  elsif score >= 3
    puts "\nDECENT SETUP - Consider reduced position size"
  else
    puts "\nLOW PROBABILITY - Skip this trade"
  end
end
```

## Pattern Statistics

### Frequency
- **Occurrence**: Rare (appears less than 1% of the time)
- **Best Timeframes**: Daily, Weekly (more reliable)
- **Markets**: Works on all markets (stocks, forex, crypto)

### Success Rate
- **With confirmation**: 65-75% success rate
- **Without confirmation**: 45-55% success rate
- **At resistance**: 70-80% success rate
- **With volume**: 68-78% success rate

### Average Move
- **Typical decline**: 5-15% from pattern high
- **Major reversals**: 20-40% decline possible
- **Time to target**: 2-10 candles (varies by timeframe)

## Best Practices

### Do's
1. Wait for established uptrend before taking signal
2. Verify gap is significant (at least 1-2%)
3. Look for increasing volume on bearish candles
4. Trade near resistance levels for best results
5. Wait for confirmation candle in choppy markets
6. Use with overbought RSI for stronger signal
7. Calculate risk/reward before entry

### Don'ts
1. Don't trade pattern in downtrend or sideways market
2. Don't ignore volume (low volume = low reliability)
3. Don't enter without proper stop loss
4. Don't chase if pattern is too far from resistance
5. Don't trade if gap is tiny (< 0.5%)
6. Don't ignore broader market context
7. Don't risk more than 1-2% of account

## Common Mistakes

1. **Trading without uptrend**: Pattern requires uptrend context
2. **Ignoring the gap**: Gap failure is crucial to pattern
3. **Poor stop placement**: Must be above gap high
4. **No confirmation**: Better results with fourth candle confirmation
5. **Confusing with Three Black Crows**: Different patterns

## Related Patterns

### Similar Bearish Patterns
- [Three Black Crows](cdl_3blackcrows.md) - Three consecutive bearish candles
- [Evening Star](cdl_eveningstar.md) - Three-candle reversal with star
- [Dark Cloud Cover](cdl_darkcloudcover.md) - Two-candle bearish reversal
- [Advance Block](cdl_advanceblock.md) - Three-candle topping pattern

### Opposite Pattern
- **Bullish Variant**: No direct bullish equivalent
- Consider: [Three White Soldiers](cdl_3whitesoldiers.md) for bullish reversal

## Pattern Variations

### Strong Two Crows
- Large gap (2%+)
- Third candle closes below first candle's midpoint
- High volume on both crows
- Appears at major resistance

### Weak Two Crows
- Small gap (< 1%)
- Third candle doesn't retrace much
- Low or declining volume
- No clear resistance level

## Key Takeaways

1. **Rare but reliable** when all conditions align
2. **Gap failure** is the critical element
3. **Uptrend context** is mandatory for validity
4. **Confirmation helps** reduce false signals
5. **Volume matters** - increases reliability significantly
6. **Resistance confluence** improves success rate
7. **Risk management** is essential - use stops

## See Also

- [Three Black Crows](cdl_3blackcrows.md)
- [Evening Star](cdl_eveningstar.md)
- [Dark Cloud Cover](cdl_darkcloudcover.md)
- [Pattern Recognition Overview](../index.md)
- [Back to Indicators](../index.md)
