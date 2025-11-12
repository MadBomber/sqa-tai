# Closing Marubozu Pattern

The Closing Marubozu is a single-candle pattern characterized by a strong directional move with no shadow (or minimal shadow) at the close. A Bullish Closing Marubozu closes at or near the high with little to no upper shadow, showing strong buying pressure through the session. A Bearish Closing Marubozu closes at or near the low with little to no lower shadow, showing strong selling pressure. This pattern is essentially a half-Marubozu, missing a shadow only on the closing side.

## Pattern Type

- **Type**: Continuation/Reversal
- **Candles Required**: 1
- **Trend Context**: Can appear in any trend
- **Reliability**: Moderate
- **Frequency**: Common (8-12%)

## Usage

```ruby
require 'sqa/tai'

# Closing Marubozu example
open  = [95.0, 92.0, 89.5, 88.0, 89.0]
high  = [95.5, 92.5, 91.0, 88.5, 93.0]
low   = [91.0, 88.5, 88.0, 86.0, 88.5]
close = [92.0, 89.0, 91.0, 86.0, 93.0]

# Detect Closing Marubozu pattern
pattern = SQA::TAI.cdl_closingmarubozu(open, high, low, close)

if pattern.last == 100
  puts "Bullish Closing Marubozu - Strong buying to close!"
elsif pattern.last == -100
  puts "Bearish Closing Marubozu - Strong selling to close!"
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
- **0**: No Closing Marubozu pattern detected
- **+100**: Bullish Closing Marubozu (continuation or reversal up)
- **-100**: Bearish Closing Marubozu (continuation or reversal down)

## Pattern Recognition Rules

### Bullish Closing Marubozu (White)

- Body: Long white (bullish) candle
- Close: At or very near the high
- Upper Shadow: None or very small
- Lower Shadow: Present (distinguishes from full Marubozu)
- Opening: Can be anywhere in the range
- Direction: Strong upward momentum to close
- Volume: Higher volume strengthens signal

### Bearish Closing Marubozu (Black)

- Body: Long black (bearish) candle
- Close: At or very near the low
- Lower Shadow: None or very small
- Upper Shadow: Present (distinguishes from full Marubozu)
- Opening: Can be anywhere in the range
- Direction: Strong downward momentum to close
- Volume: Higher volume strengthens signal

### Key Characteristics

- Strong directional close
- No hesitation at closing price
- Shows momentum and commitment
- More reliable with large body
- Volume confirms strength
- Context determines continuation vs reversal
- One shadow distinguishes from full Marubozu
- Closing strength indicates follow-through likely

### Ideal Pattern Features

- **Large body**: Body should be at least 2% of price
- **Minimal closing shadow**: Less than 10% of range
- **Clear opening shadow**: Distinguishes from full Marubozu
- **High volume**: Above average volume validates
- **Trend alignment**: Works best with existing momentum
- **Time of day**: More significant on daily charts


## Visual Pattern

```
Bullish Closing Marubozu:

       [====]        Close at or near high
        |   |        Strong buying to close
        |            Lower shadow present
       [             Open lower in range


Bearish Closing Marubozu:

        |            Upper shadow present
        |   ]        Open higher in range
       [====]        Strong selling to close
                     Close at or near low
```


## Interpretation

The Closing Marubozu shows strong directional momentum into the close, suggesting continuation is likely. A Bullish Closing Marubozu indicates buyers controlled the session finish, potentially signaling more upside. A Bearish Closing Marubozu shows sellers dominated the close, suggesting continued downside. The pattern is stronger with a large body and high volume.

### Reliability Factors


| Factor | Low Reliability | Medium Reliability | High Reliability |
|--------|----------------|-------------------|------------------|
| Body Size | Small | Medium | Large (>2% of price) |
| Shadow | Visible shadow at close | Tiny shadow | No shadow |
| Volume | Below average | Average | Above average |
| Trend | Counter-trend | No clear trend | With trend |
| Prior Action | Choppy | Some direction | Clear momentum |

**Note**: Array elements should be ordered from oldest to newest (chronological order)


## Example: Pattern Detection and Analysis

```ruby
open, high, low, close = load_ohlc_data('AAPL')

pattern = SQA::TAI.cdl_closingmarubozu(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)
sma_50 = SQA::TAI.sma(close, period: 50)

if pattern.last != 0
  direction = pattern.last > 0 ? "BULLISH" : "BEARISH"
  puts "#{direction} Closing Marubozu detected!"

  # Verify trend context
  if pattern.last > 0
        downtrend = close[-5] < sma_50[-5]
        puts "Reversal from downtrend: \#{downtrend}"
      else
        uptrend = close[-5] > sma_50[-5]
        puts "Reversal from uptrend: \#{uptrend}"
      end

  puts "RSI: #{rsi.last.round(2)}"
  
  if pattern.last > 0 && rsi.last < 30
    puts "OVERSOLD + Closing Marubozu = Strong signal"
  elsif pattern.last < 0 && rsi.last > 70
    puts "OVERBOUGHT + Closing Marubozu = Strong signal"
  end
end
```

## Example: Volume Confirmation

```ruby
open, high, low, close, volume = load_ohlc_volume_data('TSLA')

pattern = SQA::TAI.cdl_closingmarubozu(open, high, low, close)

if pattern.last != 0
  direction = pattern.last > 0 ? "Bullish" : "Bearish"
  puts "#{direction} Closing Marubozu detected"

  # Analyze volume
  avg_vol = volume[-20..-2].sum / 19.0
  current_vol = volume.last

  puts "\nVolume Analysis:"
  puts "Current: #{current_vol.round(0)}"
  puts "Average: #{avg_vol.round(0)}"
  puts "Ratio: #{(current_vol/avg_vol).round(2)}x"

  if current_vol > avg_vol * 1.5
    puts "\nSTRONG VOLUME CONFIRMATION"
    puts "High volume validates the pattern"
  elsif current_vol > avg_vol
    puts "\nGood volume support"
  else
    puts "\nWARNING: Low volume - pattern less reliable"
  end
end
```

## Trading Strategies

### Entry Rules

#### Conservative Entry (Recommended)
```ruby
# Wait for confirmation candle
if pattern[-2] != 0  # Pattern 2 candles ago
  direction = pattern[-2]
  
  if direction > 0  # Bullish
    # Confirm upward momentum
    if close[-1] > close[-2] && close.last >= close[-1]
      puts "Closing Marubozu CONFIRMED"
      entry = close.last
      puts "Enter LONG at #{entry.round(2)}"
    end
  else  # Bearish
    # Confirm downward momentum
    if close[-1] < close[-2] && close.last <= close[-1]
      puts "Closing Marubozu CONFIRMED"
      entry = close.last
      puts "Enter SHORT at #{entry.round(2)}"
    end
  end
end
```

#### Aggressive Entry
```ruby
# Enter immediately on pattern completion
if pattern.last != 0
  direction = pattern.last > 0 ? "LONG" : "SHORT"
  entry = close.last
  
  puts "Closing Marubozu completed - Enter #{direction}"
  puts "Entry: #{entry.round(2)}"
end
```

### Stop Loss Placement

```ruby
if pattern.last != 0
  if pattern.last > 0  # Bullish
    # Stop below pattern low
    pattern_low = low.last
    stop = pattern_low * 0.99  # 1% buffer
    
    puts "Stop loss: #{stop.round(2)}"
    puts "Below pattern low (invalidation point)"
    
  else  # Bearish
    # Stop above pattern high
    pattern_high = high.last
    stop = pattern_high * 1.01  # 1% buffer
    
    puts "Stop loss: #{stop.round(2)}"
    puts "Above pattern high (invalidation point)"
  end
  
  entry = close.last
  risk = (entry - stop).abs
  risk_pct = (risk / entry * 100).round(2)
  puts "Risk: $#{risk.round(2)} (#{risk_pct}%)"
end
```

### Profit Targets

```ruby
if pattern.last != 0
  entry = close.last
  
  if pattern.last > 0  # Bullish
    pattern_low = low.last
    stop = pattern_low * 0.99
    risk = entry - stop
    
    # Risk-based targets
    target_1 = entry + (risk * 2)
    target_2 = entry + (risk * 3)
    target_3 = entry + (risk * 4)
    
    puts "Bullish Targets:"
    puts "T1 (2R): #{target_1.round(2)}"
    puts "T2 (3R): #{target_2.round(2)}"
    puts "T3 (4R): #{target_3.round(2)}"
    
  else  # Bearish
    pattern_high = high.last
    stop = pattern_high * 1.01
    risk = stop - entry
    
    # Risk-based targets
    target_1 = entry - (risk * 2)
    target_2 = entry - (risk * 3)
    target_3 = entry - (risk * 4)
    
    puts "Bearish Targets:"
    puts "T1 (2R): #{target_1.round(2)}"
    puts "T2 (3R): #{target_2.round(2)}"
    puts "T3 (4R): #{target_3.round(2)}"
  end
end
```

## Example: Complete Trading System

```ruby
open, high, low, close, volume = load_ohlc_volume_data('GOOGL')

pattern = SQA::TAI.cdl_closingmarubozu(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)
sma_20 = SQA::TAI.sma(close, period: 20)
sma_50 = SQA::TAI.sma(close, period: 50)

if pattern.last != 0
  direction = pattern.last > 0 ? "BULLISH" : "BEARISH"

  puts "#{direction} Closing Marubozu Pattern Analysis"
  puts "=" * 60

  # 1. Trend context
  if pattern.last > 0
    downtrend = close[-5] < sma_20[-5] && sma_20[-5] < sma_50[-5]
    extended = close[-10] > close[-5]
    context_score = downtrend && extended
    puts "Downtrend context: #{context_score}"
  else
    uptrend = close[-5] > sma_20[-5] && sma_20[-5] > sma_50[-5]
    extended = close[-5] > close[-10]
    context_score = uptrend && extended
    puts "Uptrend context: #{context_score}"
  end

  # 2. Volume
  avg_vol = volume[-20..-2].sum / 19.0
  high_volume = volume.last > avg_vol * 1.3
  puts "Volume confirmation: #{high_volume}"

  # 3. RSI extreme
  if pattern.last > 0
    extreme = rsi[-2] < 30
    puts "Oversold: #{extreme}"
  else
    extreme = rsi[-2] > 70
    puts "Overbought: #{extreme}"
  end

  # Calculate trade setup
  entry = close.last
  if pattern.last > 0
    pattern_low = low.last
    stop = pattern_low * 0.99
    risk = entry - stop
    target = entry + (risk * 2.5)
  else
    pattern_high = high.last
    stop = pattern_high * 1.01
    risk = stop - entry
    target = entry - (risk * 2.5)
  end

  rr = ((target - entry).abs / risk).round(1)

  puts "\nTrade Setup:"
  puts "Entry: $#{entry.round(2)}"
  puts "Stop: $#{stop.round(2)}"
  puts "Target: $#{target.round(2)}"
  puts "R:R: 1:#{rr}"

  if context_score && (high_volume || extreme)
    puts "\n*** HIGH QUALITY SETUP ***"
  end
end
```

## Example: Shadow Analysis

```ruby
open, high, low, close = load_ohlc_data('MSFT')

pattern = SQA::TAI.cdl_closingmarubozu(open, high, low, close)

if pattern.last != 0
  # Analyze shadow characteristics
  body = (close.last - open.last).abs
  total_range = high.last - low.last

  if pattern.last > 0  # Bullish
    upper_shadow = high.last - close.last
    lower_shadow = open.last - low.last

    puts "Bullish Closing Marubozu Analysis:"
    puts "Body: $#{body.round(2)} (#{(body/total_range*100).round(1)}%)"
    puts "Upper shadow: $#{upper_shadow.round(2)} (#{(upper_shadow/total_range*100).round(1)}%)"
    puts "Lower shadow: $#{lower_shadow.round(2)} (#{(lower_shadow/total_range*100).round(1)}%)"

    if upper_shadow < total_range * 0.05
      puts "\nExcellent - Minimal upper shadow"
    elsif upper_shadow < total_range * 0.1
      puts "\nGood - Small upper shadow"
    else
      puts "\nWARNING - Upper shadow may be too large"
    end

  else  # Bearish
    upper_shadow = high.last - open.last
    lower_shadow = close.last - low.last

    puts "Bearish Closing Marubozu Analysis:"
    puts "Body: $#{body.round(2)} (#{(body/total_range*100).round(1)}%)"
    puts "Upper shadow: $#{upper_shadow.round(2)} (#{(upper_shadow/total_range*100).round(1)}%)"
    puts "Lower shadow: $#{lower_shadow.round(2)} (#{(lower_shadow/total_range*100).round(1)}%)"

    if lower_shadow < total_range * 0.05
      puts "\nExcellent - Minimal lower shadow"
    elsif lower_shadow < total_range * 0.1
      puts "\nGood - Small lower shadow"
    else
      puts "\nWARNING - Lower shadow may be too large"
    end
  end
end
```

## Example: Timeframe Alignment

```ruby
# Check pattern across multiple timeframes
require 'sqa/tai'

def analyze_timeframes(symbol)
  daily_data = load_ohlc_data(symbol, '1d')
  hourly_data = load_ohlc_data(symbol, '1h')

  daily_pattern = SQA::TAI.cdl_closingmarubozu(
    daily_data[:open], daily_data[:high],
    daily_data[:low], daily_data[:close]
  )

  hourly_pattern = SQA::TAI.cdl_closingmarubozu(
    hourly_data[:open], hourly_data[:high],
    hourly_data[:low], hourly_data[:close]
  )

  if daily_pattern.last != 0
    daily_direction = daily_pattern.last > 0 ? "BULLISH" : "BEARISH"
    puts "Daily: #{daily_direction} Closing Marubozu"

    # Check last 8 hours for alignment
    recent_hourly = hourly_pattern[-8..-1]
    aligned_signals = recent_hourly.count { |p| p == daily_pattern.last }

    puts "Hourly alignment: #{aligned_signals}/8 candles"

    if aligned_signals >= 5
      puts "\nSTRONG TIMEFRAME ALIGNMENT"
      puts "Multiple timeframes confirm direction"
    elsif aligned_signals >= 3
      puts "\nGood timeframe alignment"
    else
      puts "\nWeak alignment - be cautious"
    end
  end
end

analyze_timeframes('AAPL')
```

## Pattern Statistics

### Frequency
- **Occurrence**: Common (8-12%)
- **Best Timeframes**: Daily and intraday charts
- **Markets**: All liquid markets

### Success Rate
- **Perfect pattern**: 70-75%
- **Good pattern**: 60-70%
- **With confirmation**: 72-80%
- **At support/resistance**: 75-82%

### Average Move
- **Initial move**: 5-12%
- **Major reversals**: 15-30%
- **Time to target**: 8-20 candles

## Best Practices

### Do's
1. Verify body size is significant
2. Check for minimal shadow at close
3. Confirm with volume
4. Consider trend context
5. Wait for confirmation if unsure
6. Use proper stop loss
7. Look for pattern at key levels
8. Combine with momentum indicators
9. Check timeframe alignment
10. Monitor for follow-through

### Don'ts
1. Don't trade small-bodied versions
2. Don't ignore closing shadow size
3. Don't skip volume analysis
4. Don't trade without trend context
5. Don't use tight stops initially
6. Don't ignore larger timeframe
7. Don't overtrade the pattern
8. Don't confuse with full Marubozu
9. Don't chase after big moves
10. Don't skip risk management

## Common Mistakes

1. **Ignoring body size**: Small bodies are weak signals
2. **Accepting large closing shadow**: Must close at/near extreme
3. **No volume check**: Volume validates the move
4. **Wrong context**: Trend context affects interpretation
5. **Poor stop placement**: Use logical invalidation points
6. **Confusing with Marubozu**: This has one shadow, Marubozu has none
7. **Overtrading**: Wait for quality setups
8. **No confirmation**: Pattern stronger with follow-through
9. **Ignoring opening shadow**: Must have shadow on opening side
10. **Missing trend analysis**: Context determines significance

## Pattern Variations

### Perfect Closing Marubozu
- Large body (>3% of price)
- Minimal closing shadow (<5% of range)
- Clear opening shadow present
- High volume (>1.5x average)
- Strong trend context
- **Success Rate**: 78-85%

### Good Closing Marubozu
- Medium body (1.5-3% of price)
- Small closing shadow (<10% of range)
- Opening shadow visible
- Above average volume
- Clear market direction
- **Success Rate**: 68-78%

### Weak Closing Marubozu
- Small body (<1.5% of price)
- Larger closing shadow (10-15% of range)
- Unclear opening shadow
- Low volume
- Choppy market context
- **Success Rate**: 55-68%

## Advanced Concepts

### Pattern Quality Scorer

```ruby
def score_closing_marubozu(open, high, low, close, volume)
  return 0 if pattern.last == 0

  score = 0
  direction = pattern.last > 0 ? 1 : -1

  # Body size (0-3 points)
  body = (close.last - open.last).abs
  body_pct = body / close.last * 100

  score += 3 if body_pct > 3.0    # Large body
  score += 2 if body_pct > 2.0    # Medium body
  score += 1 if body_pct > 1.5    # Acceptable body

  # Closing shadow (0-3 points)
  total_range = high.last - low.last

  if direction > 0  # Bullish
    closing_shadow = high.last - close.last
  else  # Bearish
    closing_shadow = close.last - low.last
  end

  shadow_pct = total_range > 0 ? closing_shadow / total_range * 100 : 100

  score += 3 if shadow_pct < 5     # Minimal shadow
  score += 2 if shadow_pct < 10    # Small shadow
  score += 1 if shadow_pct < 15    # Acceptable shadow

  # Volume (0-2 points)
  avg_vol = volume[-20..-2].sum / 19.0
  vol_ratio = volume.last / avg_vol

  score += 2 if vol_ratio > 1.5
  score += 1 if vol_ratio > 1.2

  # Trend context (0-2 points)
  sma_20 = close[-20..-1].sum / 20.0
  if direction > 0
    score += 2 if close[-2] < sma_20  # Reversal from down
    score += 1 if close[-2] > sma_20  # Continuation up
  else
    score += 2 if close[-2] > sma_20  # Reversal from up
    score += 1 if close[-2] < sma_20  # Continuation down
  end

  score  # 0-10
end
```

### Multi-Pattern Analysis

```ruby
open, high, low, close = load_ohlc_data('NVDA')

closing_marubozu = SQA::TAI.cdl_closingmarubozu(open, high, low, close)
marubozu = SQA::TAI.cdl_marubozu(open, high, low, close)
belt_hold = SQA::TAI.cdl_belthold(open, high, low, close)

if closing_marubozu.last != 0
  puts "Closing Marubozu detected"

  # Check related patterns
  related_patterns = []
  related_patterns << "Full Marubozu" if marubozu.last != 0
  related_patterns << "Belt Hold" if belt_hold.last != 0

  if related_patterns.any?
    puts "Also detected: #{related_patterns.join(', ')}"
    puts "\nMULTIPLE STRONG PATTERNS CONFIRM"
    puts "Very high probability setup"
  end
end
```

### Risk Management Calculator

```ruby
def calculate_position_size(entry, stop, account_size, risk_pct)
  risk_amount = account_size * (risk_pct / 100.0)
  risk_per_share = (entry - stop).abs
  shares = (risk_amount / risk_per_share).floor

  {
    shares: shares,
    position_value: shares * entry,
    risk_amount: risk_amount,
    risk_per_share: risk_per_share,
    position_pct: (shares * entry / account_size * 100).round(2)
  }
end

# Example usage
if pattern.last != 0
  entry = close.last
  stop = pattern.last > 0 ? low.last * 0.99 : high.last * 1.01

  position = calculate_position_size(entry, stop, 100000, 2.0)

  puts "Position Sizing (2% risk):"
  puts "Shares: #{position[:shares]}"
  puts "Position value: $#{position[:position_value].round(2)}"
  puts "Risk amount: $#{position[:risk_amount].round(2)}"
  puts "Risk per share: $#{position[:risk_per_share].round(2)}"
  puts "Position size: #{position[:position_pct]}% of account"
end
```

## Market Context Analysis

### Support and Resistance

```ruby
open, high, low, close = load_ohlc_data('AAPL')

pattern = SQA::TAI.cdl_closingmarubozu(open, high, low, close)

if pattern.last != 0
  # Find recent support/resistance levels
  lookback = 60

  # Resistance levels
  resistance_levels = []
  high[-lookback..-1].each_with_index do |h, i|
    if i > 0 && i < lookback - 1
      if h > high[-lookback + i - 1] && h > high[-lookback + i + 1]
        resistance_levels << h
      end
    end
  end

  # Support levels
  support_levels = []
  low[-lookback..-1].each_with_index do |l, i|
    if i > 0 && i < lookback - 1
      if l < low[-lookback + i - 1] && l < low[-lookback + i + 1]
        support_levels << l
      end
    end
  end

  current = close.last

  # Find nearest levels
  above = resistance_levels.select { |r| r > current }.min
  below = support_levels.select { |s| s < current }.max

  puts "Closing Marubozu at Key Level Analysis:"
  puts "Current: $#{current.round(2)}"
  puts "Nearest resistance: $#{above.round(2) if above}"
  puts "Nearest support: $#{below.round(2) if below}"

  if pattern.last > 0 && below
    dist_to_support = ((current - below) / current * 100).round(2)
    puts "\nBullish pattern #{dist_to_support}% above support"

    if dist_to_support < 2
      puts "STRONG - Pattern at support"
    end
  elsif pattern.last < 0 && above
    dist_to_resistance = ((above - current) / current * 100).round(2)
    puts "\nBearish pattern #{dist_to_resistance}% below resistance"

    if dist_to_resistance < 2
      puts "STRONG - Pattern at resistance"
    end
  end
end
```

### Volatility Context

```ruby
open, high, low, close = load_ohlc_data('TSLA')

pattern = SQA::TAI.cdl_closingmarubozu(open, high, low, close)
atr = SQA::TAI.atr(high, low, close, period: 14)

if pattern.last != 0
  # Measure pattern size vs volatility
  body = (close.last - open.last).abs
  avg_atr = atr[-20..-2].sum / 19.0

  body_vs_atr = (body / avg_atr).round(2)

  puts "Closing Marubozu Volatility Analysis:"
  puts "Pattern body: $#{body.round(2)}"
  puts "Average ATR: $#{avg_atr.round(2)}"
  puts "Body is #{body_vs_atr}x ATR"

  if body_vs_atr > 2.0
    puts "\nEXTREMELY STRONG - Body >2x ATR"
    puts "Exceptional momentum"
  elsif body_vs_atr > 1.5
    puts "\nVERY STRONG - Body >1.5x ATR"
    puts "Strong momentum"
  elsif body_vs_atr > 1.0
    puts "\nGOOD - Body >1x ATR"
    puts "Decent momentum"
  else
    puts "\nWEAK - Body <1x ATR"
    puts "Below average move"
  end

  # Adjust stops based on volatility
  if pattern.last > 0
    stop = low.last - (avg_atr * 0.5)
  else
    stop = high.last + (avg_atr * 0.5)
  end

  puts "\nVolatility-adjusted stop: $#{stop.round(2)}"
end
```

## Related Patterns

### Similar Patterns
- [Marubozu](cdl_marubozu.md)
- [Belt Hold](cdl_belthold.md)
- [Long Line](cdl_longline.md)

### Component Patterns
- [Long Line](cdl_longline.md)
- [Marubozu](cdl_marubozu.md)

## Key Takeaways

1. **Strong close** - no hesitation at session end
2. **One shadow** - distinguishes from full Marubozu
3. **Body size matters** - larger is stronger
4. **Volume confirms** - high volume validates
5. **Context dependent** - can signal continuation or reversal
6. **Momentum indicator** - shows strength into close
7. **Reliable with confirmation** - better with follow-through
8. **Common pattern** - appears frequently
9. **Use stops** - always protect positions
10. **Combine indicators** - use with RSI, MA, volume

## See Also

- [Pattern Recognition Overview](index.md)
- [Back to Indicators](../index.md)
- [Marubozu](cdl_marubozu.md)
- [Belt Hold](cdl_belthold.md)
