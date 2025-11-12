# Dragonfly Doji Pattern

## Overview

The Dragonfly Doji is a single-candlestick bullish reversal pattern that appears at the bottom of downtrends. It has a distinctive T-shape with a long lower shadow and virtually no upper shadow or body, indicating strong buyer rejection of lower prices and potential trend reversal. This pattern shows that sellers pushed price significantly lower during the session, but buyers rallied strongly to close near the open and high.

## Pattern Type

- **Type**: Bullish Reversal
- **Candles Required**: 1
- **Trend Context**: Appears after downtrend
- **Reliability**: Medium to High (when confirmed)
- **Frequency**: Rare

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

open  = [100.0, 98.0, 95.0, 92.0, 90.0]
high  = [101.0, 99.0, 96.0, 93.0, 90.5]
low   = [98.0, 95.0, 91.0, 87.0, 85.0]
close = [99.0, 96.0, 92.0, 90.2, 90.3]

# Detect Dragonfly Doji pattern
pattern = SQA::TAI.cdl_dragonflydoji(open, high, low, close)

if pattern.last == 100
  puts "Dragonfly Doji detected - Bullish reversal signal!"
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
- **0**: No Dragonfly Doji pattern detected
- **100**: Dragonfly Doji pattern detected (bullish reversal signal)

Note: This pattern only returns bullish signals. There is no bearish equivalent (see Gravestone Doji for bearish variant).

## Pattern Recognition Rules

### Structure Requirements

1. **Body**: Very small or nonexistent (open ≈ close)
2. **Upper Shadow**: None or very small
3. **Lower Shadow**: Long (at least 2-3× the body size)
4. **Shape**: Distinctive "T" or dragonfly shape
5. **Context**: Forms after downtrend or at support

### Key Characteristics

- Open and close are at or very near the session high
- Long lower shadow shows strong rejection of lower prices
- Sellers pushed price down but buyers completely reversed the move
- No upper shadow indicates buyers maintained control through close
- The longer the lower shadow, the more bullish the signal

## Visual Pattern

```
After downtrend:

   _      Open/Close at high (small or no body)
   |
   |
   |
   |
   |      Long lower shadow (rejection of lower prices)
```

## Understanding the Pattern

### What It Measures

The Dragonfly Doji measures:
- **Seller Exhaustion**: Bears pushed down but couldn't hold
- **Buyer Strength**: Bulls reversed entire session's decline
- **Price Rejection**: Strong rejection of lower price levels
- **Potential Reversal**: Shift in control from sellers to buyers

### Pattern Psychology

1. **Session Opens**: Price opens in downtrend
2. **Selling Pressure**: Bears push price significantly lower
3. **Buyer Entry**: Bulls step in aggressively at lower levels
4. **Complete Reversal**: Buyers push price all the way back to open/high
5. **Closing Strength**: Session closes at high, showing buyer control

### Pattern Characteristics

- **Range**: Returns 0 (not present) or 100 (bullish)
- **Type**: Bullish reversal pattern
- **Lag**: Real-time single-candle pattern
- **Best Used**: After downtrends at support levels

## Interpretation

### Pattern Signals

**Bullish Dragonfly Doji (100)**
- Appears after downtrend or at support
- Long lower shadow shows seller exhaustion
- Close at high shows buyer strength
- Indicates potential bottom formation
- Strong reversal signal when confirmed

### Reliability Factors

| Factor | Low Reliability | Medium Reliability | High Reliability |
|--------|----------------|-------------------|------------------|
| Trend Context | Sideways | Downtrend | Strong downtrend |
| Lower Shadow | 2× body | 3× body | 4×+ body |
| Volume | Low | Normal | High volume |
| Location | Mid-chart | Swing low | Major support |
| Body Size | Medium | Small | Perfect doji |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

## Trading Signals

### Buy Signals

**Primary Signal:**
1. Dragonfly Doji forms after downtrend
2. Long lower shadow (3×+ body length)
3. Open and close near session high
4. Preferably at support level

**Confirmation Signal:**
```ruby
# Wait for bullish confirmation candle
if pattern[-2] == 100  # Dragonfly two bars ago
  if close[-1] > close[-2] && close[-1] > open[-1]
    puts "Dragonfly Doji CONFIRMED"
    puts "Enter LONG on bullish confirmation"
  end
end
```

**Entry Criteria:**
- Enter on close of confirmation candle
- Confirmation closes above dragonfly high
- Stop below dragonfly low
- Volume increases on confirmation

### Divergence Analysis

**With RSI:**
```ruby
# Bullish divergence + Dragonfly = very strong signal
if pattern.last == 100
  # Price making lower low but RSI higher low = bullish divergence
  if low.last < low[-10] && rsi.last > rsi[-10]
    puts "Bullish Divergence + Dragonfly Doji"
    puts "Very strong reversal signal"
  end
end
```

## Best Practices

### Optimal Use Cases

**Best Conditions:**
- Forms after extended downtrend
- At major support levels
- With oversold RSI (<30)
- High volume on the doji
- Long lower shadow (3×+ body)
- Perfect doji (open = close)

**Time Frames:**
- Daily charts: Most reliable
- 4-hour charts: Good reliability
- Hourly charts: Moderate (needs confirmation)
- Weekly charts: Very reliable but rare

### Combining with Other Indicators

**With RSI:**
```ruby
dragonfly = SQA::TAI.cdl_dragonflydoji(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)

if dragonfly.last == 100
  if rsi.last < 30
    puts "Dragonfly Doji + Oversold RSI"
    puts "High probability reversal setup"
  elsif rsi.last < 40
    puts "Dragonfly Doji + Low RSI"
    puts "Good reversal signal"
  end
end
```

**With Support Levels:**
```ruby
dragonfly = SQA::TAI.cdl_dragonflydoji(open, high, low, close)

if dragonfly.last == 100
  # Find recent support
  support = close[-60..-1].min
  near_support = (close.last - support).abs < support * 0.02

  if near_support
    puts "Dragonfly Doji AT SUPPORT"
    puts "High probability reversal zone"
  end
end
```

**With Moving Averages:**
```ruby
dragonfly = SQA::TAI.cdl_dragonflydoji(open, high, low, close)
sma_200 = SQA::TAI.sma(close, period: 200)

if dragonfly.last == 100
  near_200sma = (close.last - sma_200.last).abs < sma_200.last * 0.02

  if near_200sma
    puts "Dragonfly Doji at 200 SMA"
    puts "Major support level test"
  end
end
```

### Common Pitfalls

1. **Trading Without Downtrend**
   - Pattern needs downtrend context
   - In uptrend, it's just a doji
   - Verify trend before trading

2. **No Confirmation Wait**
   - Pattern is setup, not entry
   - Wait for confirmation candle
   - Reduces false signals significantly

3. **Ignoring Shadow Length**
   - Longer shadow = stronger signal
   - Short shadow = weaker signal
   - Measure shadow-to-body ratio

4. **Poor Risk Management**
   - Must use stop below low
   - Calculate position size on risk
   - Don't over-leverage

### Parameter Selection Guidelines

**For Different Trading Styles:**

**Day Trading (1-hour to 4-hour):**
- Strict confirmation required
- Use intraday support levels
- Tighter stops needed
- Quick profit taking

**Swing Trading (Daily):**
- Standard approach works well
- Daily confirmation ideal
- 2-5 day holding typical
- Target 2-4R moves

**Position Trading (Weekly):**
- Very high reliability
- Major trend reversals
- Weekly confirmation
- Hold weeks to months

## Practical Examples

### Example 1: Dragonfly Doji at Support

```ruby
require 'sqa/tai'

open, high, low, close = load_ohlc_data('AAPL')

pattern = SQA::TAI.cdl_dragonflydoji(open, high, low, close)
sma_50 = SQA::TAI.sma(close, period: 50)

if pattern.last == 100
  # Verify downtrend
  in_downtrend = close[-2] < sma_50[-2] && close[-2] < close[-20]

  # Find support
  support = close[-60..-1].min
  near_support = (low.last - support).abs < support * 0.02

  # Calculate shadow length
  body = (close.last - open.last).abs
  lower_shadow = open.last - low.last
  shadow_ratio = body > 0 ? lower_shadow / body : 999

  if in_downtrend && near_support && shadow_ratio > 3
    puts "Strong Dragonfly Doji Setup!"
    puts "Current: #{close.last.round(2)}"
    puts "Support: #{support.round(2)}"
    puts "Shadow ratio: #{shadow_ratio.round(1)}:1"
    puts "Lower shadow: #{lower_shadow.round(2)}"
    puts "\nWait for bullish confirmation"
  end
end
```

### Example 2: Dragonfly with RSI

```ruby
open, high, low, close = load_ohlc_data('TSLA')

pattern = SQA::TAI.cdl_dragonflydoji(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)

if pattern.last == 100
  puts "Dragonfly Doji Pattern"
  puts "RSI: #{rsi.last.round(2)}"

  if rsi.last < 30
    puts "\nOVERSOLD + Dragonfly Doji"
    puts "Very strong reversal signal"
    puts "High probability long setup"
  elsif rsi.last < 40
    puts "\nLow RSI + Dragonfly Doji"
    puts "Good reversal signal"
  else
    puts "\nDragonfly but RSI not oversold"
    puts "Moderate probability"
  end

  # Shadow analysis
  body = (close.last - open.last).abs
  lower_shadow = [open.last, close.last].min - low.last

  puts "\nShadow Length: #{lower_shadow.round(2)}"
  puts "Body Size: #{body.round(2)}"

  if body < lower_shadow * 0.1
    puts "Excellent doji (tiny body)"
  end
end
```

### Example 3: Dragonfly with Volume

```ruby
open, high, low, close, volume = load_ohlc_volume_data('NVDA')

pattern = SQA::TAI.cdl_dragonflydoji(open, high, low, close)

if pattern.last == 100
  avg_volume = volume[-20..-1].sum / 20.0
  current_volume = volume.last

  puts "Dragonfly Doji Volume Analysis"
  puts "Current volume: #{current_volume.round(0)}"
  puts "Average volume: #{avg_volume.round(0)}"
  puts "Ratio: #{(current_volume / avg_volume).round(2)}×"

  if current_volume > avg_volume * 2
    puts "\nVERY HIGH VOLUME"
    puts "Strong buying pressure at lows"
    puts "Excellent reversal signal"
  elsif current_volume > avg_volume * 1.3
    puts "\nABOVE AVERAGE VOLUME"
    puts "Good buying interest"
  else
    puts "\nLOW VOLUME"
    puts "Weaker signal - need confirmation"
  end
end
```

### Example 4: Complete Trading System

```ruby
open, high, low, close, volume = load_ohlc_volume_data('MSFT')

pattern = SQA::TAI.cdl_dragonflydoji(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)
sma_50 = SQA::TAI.sma(close, period: 50)
sma_200 = SQA::TAI.sma(close, period: 200)

if pattern[-2] == 100  # Pattern formed two bars ago
  # Check for confirmation
  confirmed = close[-1] > close[-2] && close[-1] > open[-1]

  if confirmed
    puts "Dragonfly Doji CONFIRMED!"
    puts "=" * 50

    # Downtrend verification
    in_downtrend = close[-3] < sma_50[-3]

    # RSI check
    rsi_val = rsi[-2]
    oversold = rsi_val < 40

    # Volume check
    avg_vol = volume[-20..-2].sum / 19.0
    high_volume = volume[-2] > avg_vol * 1.5

    # Support check
    support = close[-60..-1].min
    at_support = (low[-2] - support).abs < support * 0.03

    # Shadow quality
    body = (close[-2] - open[-2]).abs
    lower_shadow = [open[-2], close[-2]].min - low[-2]
    strong_shadow = lower_shadow > body * 3

    # Doji quality
    perfect_doji = body < (high[-2] - low[-2]) * 0.1

    # Score the setup
    score = 0
    score += 1 if in_downtrend
    score += 1 if oversold
    score += 1 if high_volume
    score += 1 if at_support
    score += 1 if strong_shadow
    score += 1 if perfect_doji

    puts "Setup Analysis:"
    puts "Downtrend: #{in_downtrend ? '✓' : '✗'}"
    puts "Oversold RSI: #{oversold ? '✓' : '✗'} (#{rsi_val.round(2)})"
    puts "High Volume: #{high_volume ? '✓' : '✗'}"
    puts "At Support: #{at_support ? '✓' : '✗'}"
    puts "Strong Shadow: #{strong_shadow ? '✓' : '✗'} (#{(lower_shadow/body).round(1)}×)"
    puts "Perfect Doji: #{perfect_doji ? '✓' : '✗'}"
    puts "\nSetup Score: #{score}/6"

    if score >= 4
      # Calculate trade parameters
      entry = close[-1]
      stop = low[-2] * 0.995  # 0.5% below dragonfly low
      risk = entry - stop
      target = entry + (risk * 3)

      puts "\n*** HIGH PROBABILITY LONG SETUP ***"
      puts "Entry: #{entry.round(2)}"
      puts "Stop Loss: #{stop.round(2)}"
      puts "Target: #{target.round(2)}"
      puts "Risk: $#{risk.round(2)} (#{(risk/entry*100).round(2)}%)"
      puts "Reward: $#{(target-entry).round(2)}"
      puts "R:R Ratio: 1:3"

      # Position sizing
      account_size = 100000
      risk_percent = 0.01
      risk_amount = account_size * risk_percent
      shares = (risk_amount / risk).floor

      puts "\nPosition Sizing:"
      puts "Account: $#{account_size}"
      puts "Risk per trade: 1% = $#{risk_amount.round(2)}"
      puts "Shares: #{shares}"
      puts "Total position: $#{(shares * entry).round(2)}"

    elsif score >= 3
      puts "\nDECENT SETUP - Consider reduced size"
    else
      puts "\nLOW PROBABILITY - Skip this trade"
    end
  else
    puts "Dragonfly Doji waiting for confirmation..."
  end
end
```

## Trading Strategies

### Conservative Entry (Recommended)

```ruby
# Wait for confirmation candle
if pattern[-2] == 100
  if close[-1] > high[-2]  # Broke above dragonfly high
    entry = close.last
    stop = low[-2] * 0.995
    puts "Enter LONG at #{entry.round(2)}"
    puts "Stop at #{stop.round(2)}"
  end
end
```

### Aggressive Entry

```ruby
# Enter on dragonfly close (higher risk)
if pattern.last == 100
  entry = close.last
  stop = low.last * 0.995
  puts "Enter LONG at #{entry.round(2)}"
  puts "Stop at #{stop.round(2)}"
  puts "WARNING: No confirmation"
end
```

### Stop Loss Placement

```ruby
if pattern.last == 100
  # Stop below dragonfly low
  stop = low.last * 0.995  # 0.5% buffer
  puts "Stop loss: #{stop.round(2)}"
  puts "Rationale: Below rejection low"

  # Calculate risk
  entry = close.last
  risk = entry - stop
  risk_percent = (risk / entry) * 100
  puts "Risk: #{risk_percent.round(2)}%"
end
```

### Profit Targets

```ruby
if pattern.last == 100
  entry = close.last
  stop = low.last * 0.995
  risk = entry - stop

  # Multiple targets
  target_1 = entry + (risk * 1.5)
  target_2 = entry + (risk * 2.5)
  target_3 = entry + (risk * 4.0)

  puts "Profit Targets:"
  puts "T1 (1.5R): #{target_1.round(2)} - 50% position"
  puts "T2 (2.5R): #{target_2.round(2)} - 30% position"
  puts "T3 (4R): #{target_3.round(2)} - 20% position"

  # Or target resistance
  resistance = close[-60..-1].max
  puts "Resistance target: #{resistance.round(2)}"
end
```

## Pattern Statistics

### Frequency
- **Occurrence**: Rare (< 2% of candles)
- **Best Timeframes**: Daily, Weekly
- **Markets**: All markets (stocks, forex, crypto, commodities)

### Success Rate
- **With confirmation**: 65-75% success rate
- **Without confirmation**: 45-55% success rate
- **At support**: 75-85% success rate
- **With oversold RSI**: 70-80% success rate

### Average Move
- **Typical bounce**: 5-15% from low
- **Major reversals**: 20-50% possible
- **Time to target**: 5-20 candles (varies by timeframe)

## Pattern Quality Checklist

### Strong Dragonfly Doji (Higher Probability)
- [ ] Forms after clear downtrend (20+ candles)
- [ ] Long lower shadow (3×+ body length)
- [ ] Perfect doji (open ≈ close)
- [ ] No or tiny upper shadow
- [ ] High volume on pattern day
- [ ] At major support level
- [ ] RSI < 30 (oversold)
- [ ] Bullish confirmation candle

### Weak Dragonfly Doji (Lower Probability)
- No clear downtrend
- Short lower shadow (< 2× body)
- Large body
- Upper shadow present
- Low volume
- Mid-range location
- Neutral RSI
- No confirmation

## Common Mistakes

1. **Trading Without Downtrend Context**
   - Pattern requires downtrend
   - In uptrend, just a doji
   - Verify trend first

2. **No Confirmation**
   - Most critical mistake
   - Significantly reduces success rate
   - Always wait for confirmation

3. **Ignoring Shadow Length**
   - Shadow length indicates strength
   - Short shadow = weak signal
   - Need 3×+ body for quality

4. **Poor Stop Placement**
   - Stop must be below low
   - Pattern invalidated if low breaks
   - Use proper buffer (0.5-1%)

5. **Wrong Body Assessment**
   - Must be very small body
   - Open and close must be near equal
   - Large body = not dragonfly

## Related Patterns

### Similar Bullish Patterns
- [Hammer](cdl_hammer.md) - Similar but body not at top
- [Inverted Hammer](cdl_invertedhammer.md) - Long upper shadow instead
- [Morning Star](cdl_morningstar.md) - Three-candle reversal

### Doji Family
- [Doji Star](cdl_dojistar.md) - Doji that gaps from trend
- [Gravestone Doji](cdl_gravestonedoji.md) - Bearish opposite
- [Long-Legged Doji](cdl_longleggeddoji.md) - Long shadows both ways

### Opposite Pattern
- [Gravestone Doji](cdl_gravestonedoji.md) - Bearish reversal with long upper shadow

## Key Takeaways

1. **T-Shape is Key**: Long lower shadow + small body at top = dragonfly
2. **Downtrend Required**: Only valid as reversal in downtrend
3. **Confirmation Critical**: Wait for bullish candle to confirm
4. **Shadow Length Matters**: Longer shadow = stronger signal
5. **Support Amplifies**: Pattern strongest at support levels
6. **Volume Confirms**: High volume adds conviction
7. **Stop Below Low**: Pattern fails if low breaks

## See Also

- [Gravestone Doji](cdl_gravestonedoji.md) - Bearish opposite
- [Hammer Pattern](cdl_hammer.md) - Similar bullish reversal
- [Doji Star](cdl_dojistar.md) - Two-candle doji reversal
- [Morning Star](cdl_morningstar.md) - Three-candle reversal
- [Pattern Recognition Overview](index.md)
- [Back to Indicators](../index.md)
