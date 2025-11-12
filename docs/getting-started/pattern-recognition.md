# Pattern Recognition Guide

Learn how to identify and trade candlestick patterns using SQA::TAI. This guide covers the fundamentals of pattern recognition, signal interpretation, and practical trading strategies.

## Introduction to Candlestick Patterns

Candlestick patterns are formations created by one or more candlesticks that provide insights into market psychology and potential price movements. Originating in 18th century Japan, these patterns remain powerful tools for modern traders.

### Why Use Candlestick Patterns?

- **Visual Clarity**: Easy to spot and interpret on charts
- **Market Psychology**: Reveal sentiment shifts between bulls and bears
- **Early Signals**: Often indicate reversals before other indicators
- **Universal Application**: Work across all markets and timeframes
- **Proven History**: Centuries of successful trading applications

## Getting Started with Pattern Recognition

### Basic Pattern Detection

All pattern recognition functions in SQA::TAI follow a consistent API:

```ruby
require 'sqa/tai'

# OHLC data required for all patterns
open  = [100.0, 101.0, 102.0, 101.5, 103.0]
high  = [102.0, 103.0, 104.0, 103.0, 105.0]
low   = [99.5, 100.0, 101.0, 100.5, 102.0]
close = [101.0, 102.0, 101.5, 103.0, 104.0]

# Detect a pattern
result = SQA::TAI.cdl_hammer(open, high, low, close)

# Interpret the signal
signal = result.last
case signal
when 100
  puts "Bullish Hammer detected!"
when -100
  puts "Bearish pattern detected!"
when 0
  puts "No pattern detected"
end
```

### Understanding Pattern Signals

Pattern functions return integer arrays with these values:

| Value | Meaning | Action |
|-------|---------|--------|
| **0** | No pattern detected | Continue monitoring |
| **+100** | Bullish pattern | Consider long positions |
| **-100** | Bearish pattern | Consider short positions |
| **+200/-200** | Strong pattern | Higher confidence signals |

## Pattern Categories

### 1. Single Candlestick Patterns

Formed by one candle, these patterns offer quick signals:

```ruby
# Doji - Indecision
doji = SQA::TAI.cdl_doji(open, high, low, close)

# Hammer - Bullish reversal
hammer = SQA::TAI.cdl_hammer(open, high, low, close)

# Shooting Star - Bearish reversal
shooting_star = SQA::TAI.cdl_shootingstar(open, high, low, close)

# Spinning Top - Indecision
spinning_top = SQA::TAI.cdl_spinningtop(open, high, low, close)
```

**Characteristics**:
- Quick to form (1 candle)
- Less reliable alone
- Best with confirmation
- Good for intraday trading

### 2. Two Candlestick Patterns

More reliable, requiring two consecutive candles:

```ruby
# Engulfing - Strong reversal
engulfing = SQA::TAI.cdl_engulfing(open, high, low, close)

# Harami - Potential reversal
harami = SQA::TAI.cdl_harami(open, high, low, close)

# Piercing Pattern - Bullish reversal
piercing = SQA::TAI.cdl_piercing(open, high, low, close)

# Dark Cloud Cover - Bearish reversal
dark_cloud = SQA::TAI.cdl_darkcloudcover(open, high, low, close)
```

**Characteristics**:
- More reliable than single patterns
- Clearer market intent
- Better risk/reward setups
- Suitable for swing trading

### 3. Three+ Candlestick Patterns

Most reliable, showing sustained market behavior:

```ruby
# Morning Star - Strong bullish reversal
morning_star = SQA::TAI.cdl_morningstar(open, high, low, close)

# Evening Star - Strong bearish reversal
evening_star = SQA::TAI.cdl_eveningstar(open, high, low, close)

# Three White Soldiers - Strong bullish continuation
three_white = SQA::TAI.cdl_3whitesoldiers(open, high, low, close)

# Three Black Crows - Strong bearish continuation
three_black = SQA::TAI.cdl_3blackcrows(open, high, low, close)
```

**Characteristics**:
- Highest reliability
- Best for position trading
- Clearest trend signals
- Lower false signal rate

## Pattern Scanning Strategy

### Scanning Multiple Patterns

```ruby
require 'sqa/tai'

# Load market data
open, high, low, close = load_ohlc_data('AAPL')

# Define patterns to scan
patterns = {
  'Hammer' => :cdl_hammer,
  'Shooting Star' => :cdl_shootingstar,
  'Engulfing' => :cdl_engulfing,
  'Harami' => :cdl_harami,
  'Morning Star' => :cdl_morningstar,
  'Evening Star' => :cdl_eveningstar,
  'Doji' => :cdl_doji,
  'Hanging Man' => :cdl_hangingman
}

# Scan for active patterns
puts "Pattern Scan Results for AAPL"
puts "=" * 50

patterns.each do |name, method|
  result = SQA::TAI.send(method, open, high, low, close)
  signal = result.last

  next if signal == 0

  sentiment = signal > 0 ? "BULLISH" : "BEARISH"
  strength = signal.abs == 200 ? "STRONG" : "MODERATE"

  puts "#{name}: #{sentiment} (#{strength})"
  puts "Signal Value: #{signal}"
  puts ""
end
```

### Multi-Market Scanner

```ruby
require 'sqa/tai'

symbols = ['AAPL', 'MSFT', 'GOOGL', 'TSLA', 'NVDA']

puts "Market-Wide Pattern Scanner"
puts "=" * 60

symbols.each do |symbol|
  open, high, low, close = load_ohlc_data(symbol)

  # Scan for strong reversal patterns
  hammer = SQA::TAI.cdl_hammer(open, high, low, close)
  engulfing = SQA::TAI.cdl_engulfing(open, high, low, close)
  morning_star = SQA::TAI.cdl_morningstar(open, high, low, close)

  signals = []
  signals << "Hammer" if hammer.last == 100
  signals << "Bullish Engulfing" if engulfing.last == 100
  signals << "Morning Star" if morning_star.last == 100

  if signals.any?
    puts "\n#{symbol} - Bullish Patterns Detected:"
    signals.each { |s| puts "  - #{s}" }
  end
end
```

## Pattern Confirmation Techniques

### 1. Trend Context Confirmation

```ruby
# Load data
open, high, low, close = load_ohlc_data('MSFT')

# Identify trend
sma_50 = SQA::TAI.sma(close, period: 50)
sma_200 = SQA::TAI.sma(close, period: 200)

trend = if close.last > sma_50.last && sma_50.last > sma_200.last
  "UPTREND"
elsif close.last < sma_50.last && sma_50.last < sma_200.last
  "DOWNTREND"
else
  "SIDEWAYS"
end

# Detect reversal pattern
hammer = SQA::TAI.cdl_hammer(open, high, low, close)

# Pattern context matters
if hammer.last == 100
  if trend == "DOWNTREND"
    puts "STRONG SIGNAL: Bullish hammer in downtrend"
    puts "High probability reversal setup"
  elsif trend == "UPTREND"
    puts "WEAK SIGNAL: Bullish hammer in uptrend"
    puts "May be continuation, not reversal"
  end
end
```

### 2. Volume Confirmation

```ruby
# Load data with volume
open, high, low, close, volume = load_ohlc_volume('TSLA')

# Calculate average volume
avg_volume = volume[-20..-1].sum / 20.0

# Detect pattern
engulfing = SQA::TAI.cdl_engulfing(open, high, low, close)

if engulfing.last != 0
  pattern_type = engulfing.last > 0 ? "Bullish" : "Bearish"
  volume_ratio = volume.last / avg_volume

  puts "#{pattern_type} Engulfing Pattern"
  puts "Volume Ratio: #{volume_ratio.round(2)}x average"

  if volume_ratio > 1.5
    puts "CONFIRMED: High volume supports pattern"
  elsif volume_ratio < 0.8
    puts "WEAK: Low volume, pattern less reliable"
  else
    puts "NEUTRAL: Normal volume"
  end
end
```

### 3. Momentum Confirmation

```ruby
# Load data
open, high, low, close = load_ohlc_data('NVDA')

# Detect pattern
morning_star = SQA::TAI.cdl_morningstar(open, high, low, close)

# Check momentum
rsi = SQA::TAI.rsi(close, period: 14)
macd, signal, hist = SQA::TAI.macd(close)

if morning_star.last == 100
  puts "Morning Star Pattern Detected"

  # Momentum confirmation
  confirmations = 0
  confirmations += 1 if rsi.last < 40  # Oversold
  confirmations += 1 if macd.last > signal.last  # MACD bullish
  confirmations += 1 if hist.last > hist[-1]  # MACD histogram rising

  puts "Confirmations: #{confirmations}/3"

  if confirmations >= 2
    puts "STRONG BUY: Pattern + momentum aligned"
  elsif confirmations == 1
    puts "MODERATE: Some confirmation"
  else
    puts "WEAK: No momentum confirmation"
  end
end
```

### 4. Support/Resistance Confirmation

```ruby
# Identify support level
def find_support(low_prices, lookback = 20)
  low_prices[-lookback..-1].min
end

# Load data
open, high, low, close = load_ohlc_data('AAPL')

# Find support
support = find_support(low)

# Detect hammer
hammer = SQA::TAI.cdl_hammer(open, high, low, close)

if hammer.last == 100
  distance_from_support = ((low.last - support) / support * 100).round(2)

  puts "Hammer Pattern Detected"
  puts "Distance from Support: #{distance_from_support}%"

  if distance_from_support.abs < 1.0
    puts "EXCELLENT: Pattern at key support"
    puts "Very high probability setup"
  elsif distance_from_support.abs < 3.0
    puts "GOOD: Pattern near support"
  else
    puts "NEUTRAL: No support nearby"
  end
end
```

## Complete Pattern Trading System

Here's a comprehensive example integrating multiple confirmation techniques:

```ruby
require 'sqa/tai'

class PatternTradingSystem
  def initialize(symbol)
    @symbol = symbol
    @open, @high, @low, @close, @volume = load_ohlc_volume(symbol)
  end

  def analyze
    puts "=" * 70
    puts "Pattern Analysis: #{@symbol}"
    puts "=" * 70

    # Step 1: Market Context
    analyze_market_context

    # Step 2: Pattern Detection
    patterns = detect_patterns

    # Step 3: Confirmation Analysis
    patterns.each do |pattern|
      analyze_pattern_with_confirmation(pattern)
    end
  end

  private

  def analyze_market_context
    sma_50 = SQA::TAI.sma(@close, period: 50)
    sma_200 = SQA::TAI.sma(@close, period: 200)
    atr = SQA::TAI.atr(@high, @low, @close, period: 14)
    atr_pct = (atr.last / @close.last * 100).round(2)

    @trend = if @close.last > sma_50.last && sma_50.last > sma_200.last
      "UPTREND"
    elsif @close.last < sma_50.last && sma_50.last < sma_200.last
      "DOWNTREND"
    else
      "SIDEWAYS"
    end

    @avg_volume = @volume[-20..-1].sum / 20.0

    puts "\n1. Market Context"
    puts "   Trend: #{@trend}"
    puts "   Price: $#{@close.last.round(2)}"
    puts "   Volatility (ATR): #{atr_pct}%"
    puts "   Avg Volume: #{@avg_volume.round(0)}"
  end

  def detect_patterns
    patterns = []

    # Define patterns to check
    pattern_checks = {
      'Hammer' => [:cdl_hammer, :bullish],
      'Hanging Man' => [:cdl_hangingman, :bearish],
      'Shooting Star' => [:cdl_shootingstar, :bearish],
      'Engulfing' => [:cdl_engulfing, :either],
      'Harami' => [:cdl_harami, :either],
      'Morning Star' => [:cdl_morningstar, :bullish],
      'Evening Star' => [:cdl_eveningstar, :bearish],
      'Doji' => [:cdl_doji, :indecision]
    }

    puts "\n2. Pattern Detection"

    pattern_checks.each do |name, (method, direction)|
      result = SQA::TAI.send(method, @open, @high, @low, @close)
      signal = result.last

      next if signal == 0

      patterns << {
        name: name,
        signal: signal,
        direction: direction,
        sentiment: signal > 0 ? :bullish : :bearish
      }

      puts "   ✓ #{name} detected (#{signal})"
    end

    puts "   Found #{patterns.length} active pattern(s)" if patterns.empty?

    patterns
  end

  def analyze_pattern_with_confirmation(pattern)
    puts "\n" + "=" * 70
    puts "Pattern: #{pattern[:name]}"
    puts "Signal: #{pattern[:signal]} (#{pattern[:sentiment].to_s.upcase})"
    puts "=" * 70

    score = 0
    max_score = 6

    # Confirmation 1: Trend Context
    puts "\n▸ Trend Context:"
    if @trend == "UPTREND" && pattern[:sentiment] == :bullish
      score += 2
      puts "  ✓ Bullish pattern in uptrend (continuation)"
    elsif @trend == "DOWNTREND" && pattern[:sentiment] == :bullish
      score += 2
      puts "  ✓✓ Bullish pattern in downtrend (reversal) - STRONG"
    elsif @trend == "DOWNTREND" && pattern[:sentiment] == :bearish
      score += 2
      puts "  ✓ Bearish pattern in downtrend (continuation)"
    elsif @trend == "UPTREND" && pattern[:sentiment] == :bearish
      score += 2
      puts "  ✓✓ Bearish pattern in uptrend (reversal) - STRONG"
    else
      puts "  - Neutral trend context"
    end

    # Confirmation 2: Volume
    puts "\n▸ Volume Confirmation:"
    volume_ratio = @volume.last / @avg_volume
    if volume_ratio > 1.5
      score += 2
      puts "  ✓✓ High volume (#{volume_ratio.round(2)}x) - STRONG"
    elsif volume_ratio > 1.0
      score += 1
      puts "  ✓ Above average volume (#{volume_ratio.round(2)}x)"
    else
      puts "  - Below average volume (#{volume_ratio.round(2)}x)"
    end

    # Confirmation 3: Momentum
    puts "\n▸ Momentum Confirmation:"
    rsi = SQA::TAI.rsi(@close, period: 14)
    macd, signal_line, hist = SQA::TAI.macd(@close)

    if pattern[:sentiment] == :bullish
      if rsi.last < 40
        score += 1
        puts "  ✓ RSI oversold (#{rsi.last.round(2)})"
      end
      if macd.last > signal_line.last
        score += 1
        puts "  ✓ MACD bullish"
      end
    elsif pattern[:sentiment] == :bearish
      if rsi.last > 60
        score += 1
        puts "  ✓ RSI overbought (#{rsi.last.round(2)})"
      end
      if macd.last < signal_line.last
        score += 1
        puts "  ✓ MACD bearish"
      end
    end

    # Final Assessment
    puts "\n" + "-" * 70
    puts "SCORE: #{score}/#{max_score}"

    if score >= 5
      puts "RATING: ★★★★★ EXCELLENT - High probability setup"
      generate_trade_plan(pattern, :high)
    elsif score >= 3
      puts "RATING: ★★★☆☆ GOOD - Moderate probability"
      generate_trade_plan(pattern, :moderate)
    else
      puts "RATING: ★☆☆☆☆ WEAK - Low probability"
      puts "Action: Wait for better confirmation"
    end
  end

  def generate_trade_plan(pattern, confidence)
    puts "\n▸ Trade Plan:"

    atr = SQA::TAI.atr(@high, @low, @close, period: 14)
    current_price = @close.last

    if pattern[:sentiment] == :bullish
      entry = current_price
      stop = current_price - (2 * atr.last)
      target1 = current_price + (2 * atr.last)
      target2 = current_price + (3 * atr.last)

      puts "  Direction: LONG"
      puts "  Entry: $#{entry.round(2)}"
      puts "  Stop Loss: $#{stop.round(2)} (-#{((entry - stop) / entry * 100).round(2)}%)"
      puts "  Target 1: $#{target1.round(2)} (+#{((target1 - entry) / entry * 100).round(2)}%)"
      puts "  Target 2: $#{target2.round(2)} (+#{((target2 - entry) / entry * 100).round(2)}%)"
    else
      entry = current_price
      stop = current_price + (2 * atr.last)
      target1 = current_price - (2 * atr.last)
      target2 = current_price - (3 * atr.last)

      puts "  Direction: SHORT"
      puts "  Entry: $#{entry.round(2)}"
      puts "  Stop Loss: $#{stop.round(2)} (+#{((stop - entry) / entry * 100).round(2)}%)"
      puts "  Target 1: $#{target1.round(2)} (-#{((entry - target1) / entry * 100).round(2)}%)"
      puts "  Target 2: $#{target2.round(2)} (-#{((entry - target2) / entry * 100).round(2)}%)"
    end

    position_size = if confidence == :high
      "100% of normal size"
    elsif confidence == :moderate
      "50-75% of normal size"
    else
      "25-50% of normal size"
    end

    puts "  Position Size: #{position_size}"
  end
end

# Run the system
system = PatternTradingSystem.new('AAPL')
system.analyze
```

## Best Practices

### 1. Never Trade Patterns Alone

Always confirm patterns with:
- Trend analysis
- Volume
- Momentum indicators
- Support/Resistance levels

### 2. Wait for Confirmation

Don't enter immediately on pattern detection. Wait for:
- Next candle closing in pattern direction
- Volume increase
- Break of key levels

### 3. Use Proper Risk Management

- Always use stop losses
- Risk only 1-2% per trade
- Calculate position size based on stop distance
- Have predefined profit targets

### 4. Consider Context

Patterns are more reliable when they:
- Form at key support/resistance
- Appear after strong trends
- Occur on higher timeframes
- Align with overall market direction

### 5. Track Performance

Keep a trading journal:
- Which patterns work best
- What confirmation methods help most
- Win rate by pattern type
- Adjust strategy based on results

## Common Mistakes to Avoid

1. **Overtrading**: Not every pattern is worth trading
2. **Ignoring Trend**: Fighting the overall trend reduces success
3. **No Confirmation**: Trading patterns without supporting evidence
4. **Poor Risk Management**: Not using stops or risking too much
5. **Cherry Picking**: Only seeing patterns you want to see

## Next Steps

1. **Practice Pattern Recognition**: Study historical charts
2. **Paper Trade**: Test strategies without real money
3. **Start Small**: Begin with proven high-probability patterns
4. **Keep Learning**: Study why patterns succeed or fail
5. **Build Systems**: Automate scanning and analysis

## See Also

- [Candlestick Patterns Index](../indicators/patterns/index.md)
- [Basic Usage Guide](basic-usage.md)
- [API Reference](../api-reference.md)
- [Indicator Categories](../indicators/index.md)
