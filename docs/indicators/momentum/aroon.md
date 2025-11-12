# Aroon Indicator (AROON)

The Aroon Indicator is a technical analysis tool that identifies trend changes, measures trend strength, and detects consolidation periods by calculating the time elapsed since the highest high and lowest low within a given period. Developed by Tushar Chande in 1995, the name "Aroon" is derived from the Sanskrit word meaning "dawn's early light," reflecting its purpose of signaling the beginning of new trends.

The indicator consists of two lines:
- **Aroon Up**: Measures time since the period's highest high (indicates uptrend strength)
- **Aroon Down**: Measures time since the period's lowest low (indicates downtrend strength)

Both values oscillate between 0 and 100, providing clear signals about trend direction and strength.

## Usage

```ruby
require 'sqa/tai'

highs = [82.15, 81.89, 83.03, 83.30, 83.85,
         83.90, 83.33, 84.30, 84.84, 85.00,
         85.90, 86.58, 86.98, 88.00, 87.87]

lows = [81.29, 80.64, 81.31, 82.65, 83.07,
        83.11, 82.49, 82.30, 84.15, 84.50,
        85.39, 85.76, 85.87, 87.17, 87.01]

# Calculate 14-period Aroon (default)
aroon_down, aroon_up = SQA::TAI.aroon(highs, lows, period: 14)

puts "Aroon Up: #{aroon_up.last.round(2)}"
puts "Aroon Down: #{aroon_down.last.round(2)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `high` | Array<Float> | Yes | - | Array of high price values |
| `low` | Array<Float> | Yes | - | Array of low price values |
| `period` | Integer | No | 25 | Lookback period for calculation |

## Returns

Returns a two-element array: `[aroon_down, aroon_up]`

Each element is an array of values ranging from 0 to 100:
- **Aroon Up**: 100 means new high just occurred, 0 means no high in entire period
- **Aroon Down**: 100 means new low just occurred, 0 means no low in entire period

The first `period - 1` values will be `nil`.

## Calculation

```
Aroon Up = ((Period - Periods Since Period High) / Period) × 100
Aroon Down = ((Period - Periods Since Period Low) / Period) × 100
```

For a 25-period Aroon:
- If highest high occurred 3 periods ago: Aroon Up = ((25 - 3) / 25) × 100 = 88%
- If lowest low occurred 20 periods ago: Aroon Down = ((25 - 20) / 25) × 100 = 20%

## Interpretation

| Condition | Aroon Up | Aroon Down | Interpretation |
|-----------|----------|------------|----------------|
| Strong Uptrend | 70-100 | 0-30 | Recent highs, strong buying pressure |
| Strong Downtrend | 0-30 | 70-100 | Recent lows, strong selling pressure |
| Consolidation | 0-50 | 0-50 | No clear direction, sideways movement |
| Bullish Crossover | Crosses above | Crosses below | Aroon Up crosses above Aroon Down - uptrend emerging |
| Bearish Crossover | Crosses below | Crosses above | Aroon Down crosses above Aroon Up - downtrend emerging |
| Parallel Movement | Both high | - | Strong trending market (direction depends on which is higher) |
| Parallel Low | Both low | - | Consolidation, potential breakout coming |

### Trend Strength Indicators

- **Aroon Up near 100**: Stock is making new highs regularly - strong uptrend
- **Aroon Down near 100**: Stock is making new lows regularly - strong downtrend
- **Both Aroon lines above 70**: High volatility, strong trend (whichever is higher)
- **Both Aroon lines below 30**: Weak trend, consolidation phase
- **Aroon Up = 100, Aroon Down = 0**: Perfect uptrend condition
- **Aroon Down = 100, Aroon Up = 0**: Perfect downtrend condition

## Example: Basic Aroon Trend Identification

```ruby
highs = load_historical_highs('AAPL')
lows = load_historical_lows('AAPL')

aroon_down, aroon_up = SQA::TAI.aroon(highs, lows, period: 25)

current_up = aroon_up.last
current_down = aroon_down.last

puts <<~ANALYSIS
  Aroon Indicator Analysis
  ========================
  Aroon Up: #{current_up.round(2)}
  Aroon Down: #{current_down.round(2)}

  Trend Assessment:
ANALYSIS

if current_up > 70 && current_down < 30
  puts "Strong UPTREND - Aroon Up dominant"
elsif current_down > 70 && current_up < 30
  puts "Strong DOWNTREND - Aroon Down dominant"
elsif current_up < 50 && current_down < 50
  puts "CONSOLIDATION - Both indicators weak"
elsif (current_up - current_down).abs < 20
  puts "TRANSITIONAL - No clear trend established"
else
  puts "MODERATE TREND - Monitor for strengthening/weakening"
end
```

## Example: Aroon Crossover Strategy

```ruby
highs = load_historical_highs('TSLA')
lows = load_historical_lows('TSLA')

aroon_down, aroon_up = SQA::TAI.aroon(highs, lows, period: 25)

# Detect crossovers
signals = []

aroon_up.each_with_index do |up, i|
  next if i < 1 || up.nil?

  prev_up = aroon_up[i - 1]
  down = aroon_down[i]
  prev_down = aroon_down[i - 1]

  next if prev_up.nil? || down.nil? || prev_down.nil?

  # Bullish crossover: Aroon Up crosses above Aroon Down
  if prev_up < prev_down && up > down
    signals << {
      index: i,
      type: 'BUY',
      aroon_up: up.round(2),
      aroon_down: down.round(2),
      strength: up - down
    }
  # Bearish crossover: Aroon Down crosses above Aroon Up
  elsif prev_down < prev_up && down > up
    signals << {
      index: i,
      type: 'SELL',
      aroon_up: up.round(2),
      aroon_down: down.round(2),
      strength: down - up
    }
  end
end

# Display recent signals
puts "Recent Aroon Crossover Signals:"
signals.last(5).each do |signal|
  puts "#{signal[:type]} signal at index #{signal[:index]}"
  puts "  Aroon Up: #{signal[:aroon_up]}, Aroon Down: #{signal[:aroon_down]}"
  puts "  Signal Strength: #{signal[:strength].round(2)}"
end
```

## Example: Consolidation Breakout Detection

```ruby
highs = load_historical_highs('NVDA')
lows = load_historical_lows('NVDA')

aroon_down, aroon_up = SQA::TAI.aroon(highs, lows, period: 25)

# Look for consolidation followed by breakout
consolidation_threshold = 30
breakout_threshold = 70

aroon_up.each_with_index do |up, i|
  next if i < 5 || up.nil?

  down = aroon_down[i]
  next if down.nil?

  # Check if we were in consolidation for the past 3-5 periods
  was_consolidating = (i-4..i-1).all? do |j|
    aroon_up[j] && aroon_down[j] &&
    aroon_up[j] < consolidation_threshold &&
    aroon_down[j] < consolidation_threshold
  end

  if was_consolidating
    # Check for breakout
    if up > breakout_threshold && down < consolidation_threshold
      puts "BULLISH BREAKOUT detected at index #{i}"
      puts "  Aroon moved from consolidation to strong uptrend"
      puts "  Current: Up=#{up.round(2)}, Down=#{down.round(2)}"
    elsif down > breakout_threshold && up < consolidation_threshold
      puts "BEARISH BREAKDOWN detected at index #{i}"
      puts "  Aroon moved from consolidation to strong downtrend"
      puts "  Current: Up=#{up.round(2)}, Down=#{down.round(2)}"
    end
  end
end
```

## Example: Aroon Trend Strength Filter

```ruby
highs = load_historical_highs('MSFT')
lows = load_historical_lows('MSFT')
closes = load_historical_closes('MSFT')

aroon_down, aroon_up = SQA::TAI.aroon(highs, lows, period: 25)

# Calculate trend strength score
current_up = aroon_up.last
current_down = aroon_down.last

# Trend strength scoring (0-100)
if current_up > current_down
  trend_strength = current_up - current_down
  trend_direction = "BULLISH"
else
  trend_strength = current_down - current_up
  trend_direction = "BEARISH"
end

puts <<~TREND_REPORT
  Trend Strength Analysis
  =======================
  Direction: #{trend_direction}
  Strength Score: #{trend_strength.round(2)}/100

  Aroon Up: #{current_up.round(2)}
  Aroon Down: #{current_down.round(2)}

  Assessment:
TREND_REPORT

case trend_strength
when 80..100
  puts "VERY STRONG trend - High conviction trades"
when 60..79
  puts "STRONG trend - Favorable conditions"
when 40..59
  puts "MODERATE trend - Proceed with caution"
when 20..39
  puts "WEAK trend - Consider waiting for clarity"
when 0..19
  puts "NO CLEAR TREND - Avoid trend-following strategies"
end
```

## Example: Parallel Aroon Movement Analysis

```ruby
highs = load_historical_highs('AMD')
lows = load_historical_lows('AMD')

aroon_down, aroon_up = SQA::TAI.aroon(highs, lows, period: 25)

# Analyze parallel movement patterns
aroon_up.each_with_index do |up, i|
  next if i < 3 || up.nil?

  down = aroon_down[i]
  next if down.nil?

  # Check for parallel movement in last 3 periods
  parallel_high = (i-2..i).all? { |j| aroon_up[j] > 70 && aroon_down[j] > 70 }
  parallel_low = (i-2..i).all? { |j| aroon_up[j] < 30 && aroon_down[j] < 30 }

  if parallel_high
    if up > down
      puts "STRONG UPTREND with high volatility at index #{i}"
      puts "  Both Aroon lines elevated - trend is well established"
    else
      puts "STRONG DOWNTREND with high volatility at index #{i}"
      puts "  Both Aroon lines elevated - trend is well established"
    end
  elsif parallel_low
    puts "CONSOLIDATION ZONE detected at index #{i}"
    puts "  Both Aroon lines weak - prepare for potential breakout"
    puts "  Current: Up=#{up.round(2)}, Down=#{down.round(2)}"
  end
end
```

## Advanced Techniques

### 1. Multi-Timeframe Aroon Analysis
Compare Aroon readings across different timeframes (daily, weekly) to confirm trend strength and direction.

### 2. Aroon with Volume Confirmation
Combine Aroon signals with volume analysis - strong trends should show increasing volume on breakouts.

### 3. Aroon Oscillator
Calculate `Aroon Up - Aroon Down` to create a single oscillator ranging from -100 to +100:
- Positive values indicate uptrend
- Negative values indicate downtrend
- Zero line crossovers signal trend changes

### 4. Dynamic Period Adjustment
Use shorter periods (14) for volatile markets and longer periods (50) for smoother trend identification.

### 5. Aroon Extremes
Pay special attention when either line reaches 100 - indicates a very recent high/low and strong momentum.

## Example: Comprehensive Aroon Trading System

```ruby
highs = load_historical_highs('GOOGL')
lows = load_historical_lows('GOOGL')
closes = load_historical_closes('GOOGL')

aroon_down, aroon_up = SQA::TAI.aroon(highs, lows, period: 25)
sma = SQA::TAI.sma(closes, period: 50)

current_up = aroon_up.last
current_down = aroon_down.last
current_price = closes.last
current_sma = sma.last

puts <<~SYSTEM
  Comprehensive Aroon Trading System
  ==================================
  Price: #{current_price.round(2)}
  50-SMA: #{current_sma.round(2)}
  Aroon Up: #{current_up.round(2)}
  Aroon Down: #{current_down.round(2)}

  Trading Decision:
SYSTEM

# Long entry conditions
if current_price > current_sma && current_up > 70 && current_down < 30
  puts "STRONG BUY - All conditions aligned"
  puts "  - Price above 50-SMA (uptrend confirmed)"
  puts "  - Aroon Up > 70 (recent highs)"
  puts "  - Aroon Down < 30 (no recent lows)"

# Short entry conditions
elsif current_price < current_sma && current_down > 70 && current_up < 30
  puts "STRONG SELL - All conditions aligned"
  puts "  - Price below 50-SMA (downtrend confirmed)"
  puts "  - Aroon Down > 70 (recent lows)"
  puts "  - Aroon Up < 30 (no recent highs)"

# Consolidation exit
elsif current_up < 30 && current_down < 30
  puts "EXIT positions - Consolidation detected"
  puts "  - Both Aroon lines weak"
  puts "  - Trend momentum fading"

# Trend reversal warning
elsif current_up > 50 && current_down > 50
  puts "CAUTION - High volatility period"
  puts "  - Both Aroon lines elevated"
  puts "  - Wait for clear direction"
else
  puts "HOLD - No clear signal"
end
```

## Common Settings

| Period | Use Case | Characteristics |
|--------|----------|-----------------|
| 14 | Short-term trading | More sensitive, frequent signals |
| 25 | Standard setting | Balanced sensitivity and reliability |
| 50 | Long-term trends | Smoother, fewer false signals |
| 70 | Position trading | Very stable, major trends only |

## Advantages and Limitations

### Advantages
- Simple to interpret (0-100 scale)
- Identifies both trend direction and strength
- Works well in trending markets
- Clear crossover signals
- Effective at detecting consolidation periods

### Limitations
- Can generate false signals in choppy markets
- Lagging indicator - signals come after trend starts
- Less effective in ranging markets
- Requires confirmation from other indicators
- May miss the very beginning of trends

## Related Indicators

- [Aroon Oscillator](aroonosc.md) - Single-line version of Aroon
- [ADX](adx.md) - Trend strength measurement
- [MACD](macd.md) - Momentum and trend direction
- [RSI](rsi.md) - Overbought/oversold conditions
- [DMI](plus_di.md) - Directional movement

## See Also

- [Back to Indicators](../index.md)
- [Momentum Indicators Overview](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
<!-- TODO: Create example file -->
- Trend Trading Strategies
