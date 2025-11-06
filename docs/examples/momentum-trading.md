# Momentum Trading Examples

Examples of using momentum indicators like RSI, MACD, and Stochastic for trading strategies.

## RSI Overbought/Oversold Strategy

Classic RSI trading strategy using 70/30 levels.

```ruby
require 'sqa/tai'

def rsi_strategy(prices)
  rsi = SQA::TAI.rsi(prices, period: 14)
  current_rsi = rsi.last
  current_price = prices.last

  signal = if current_rsi < 30
    { action: :buy, reason: "Oversold (RSI: #{current_rsi.round(2)})" }
  elsif current_rsi > 70
    { action: :sell, reason: "Overbought (RSI: #{current_rsi.round(2)})" }
  else
    { action: :hold, reason: "Neutral (RSI: #{current_rsi.round(2)})" }
  end

  signal.merge(price: current_price.round(2), rsi: current_rsi.round(2))
end

# Generate sample data with oversold/overbought conditions
prices = [50.0, 48.5, 47.0, 45.5, 44.0, 42.5, 41.0, 40.0, 39.0, 38.5,  # Oversold
          40.0, 42.0, 44.0, 46.0, 48.0, 50.0, 52.0, 54.0, 56.0, 58.0]  # Recovery

signal = rsi_strategy(prices)

puts "RSI Strategy Signal:"
puts "Action: #{signal[:action]}"
puts "Reason: #{signal[:reason]}"
puts "Price: $#{signal[:price]}"
```

## MACD Crossover System

Trade based on MACD line crossing the signal line.

```ruby
require 'sqa/tai'

class MACDStrategy
  def initialize(fast: 12, slow: 26, signal: 9)
    @fast = fast
    @slow = slow
    @signal = signal
  end

  def analyze(prices)
    macd, signal, histogram = SQA::TAI.macd(
      prices,
      fast_period: @fast,
      slow_period: @slow,
      signal_period: @signal
    )

    # Check for crossovers
    signal_type = detect_crossover(macd, signal)

    # Histogram momentum
    histogram_momentum = if histogram[-1] > histogram[-2] && histogram[-1] > 0
      :increasing_bullish
    elsif histogram[-1] < histogram[-2] && histogram[-1] < 0
      :increasing_bearish
    elsif histogram[-1] > 0
      :decreasing_bullish
    else
      :decreasing_bearish
    end

    {
      macd: macd.last.round(4),
      signal: signal.last.round(4),
      histogram: histogram.last.round(4),
      crossover: signal_type,
      momentum: histogram_momentum,
      trend: macd.last > 0 ? :bullish : :bearish
    }
  end

  def generate_signal(prices)
    analysis = analyze(prices)

    if analysis[:crossover] == :bullish
      {
        action: :buy,
        strength: analysis[:histogram] > 0 ? :strong : :moderate,
        reason: "MACD bullish crossover"
      }
    elsif analysis[:crossover] == :bearish
      {
        action: :sell,
        strength: analysis[:histogram] < 0 ? :strong : :moderate,
        reason: "MACD bearish crossover"
      }
    elsif analysis[:momentum] == :increasing_bullish && analysis[:trend] == :bullish
      {
        action: :hold_long,
        strength: :moderate,
        reason: "Bullish momentum strengthening"
      }
    elsif analysis[:momentum] == :increasing_bearish && analysis[:trend] == :bearish
      {
        action: :hold_short,
        strength: :moderate,
        reason: "Bearish momentum strengthening"
      }
    else
      {
        action: :hold,
        strength: :weak,
        reason: "No clear signal"
      }
    end
  end

  private

  def detect_crossover(macd, signal)
    return nil if macd[-2].nil? || signal[-2].nil?

    if macd[-2] < signal[-2] && macd[-1] > signal[-1]
      :bullish
    elsif macd[-2] > signal[-2] && macd[-1] < signal[-1]
      :bearish
    else
      nil
    end
  end
end

# Example usage
prices = Array.new(50) { |i| 100 + Math.sin(i * 0.2) * 15 + i * 0.3 }

strategy = MACDStrategy.new
signal = strategy.generate_signal(prices)

puts "MACD Strategy Signal:"
puts "Action: #{signal[:action]}"
puts "Strength: #{signal[:strength]}"
puts "Reason: #{signal[:reason]}"
```

## RSI Divergence Detection

Identify bullish and bearish divergences between price and RSI.

```ruby
require 'sqa/tai'

def find_divergence(prices, lookback: 20)
  rsi = SQA::TAI.rsi(prices, period: 14)

  # Find recent peaks and troughs
  price_peak_idx = find_peak_index(prices, lookback)
  rsi_peak_idx = find_peak_index(rsi.compact, lookback)

  price_trough_idx = find_trough_index(prices, lookback)
  rsi_trough_idx = find_trough_index(rsi.compact, lookback)

  divergences = []

  # Bearish divergence: price higher high, RSI lower high
  if price_peak_idx && rsi_peak_idx
    price_current_peak = prices[-1..-lookback/2].max
    price_prev_peak = prices[-lookback..-(lookback/2+1)].max

    rsi_current_peak = rsi.compact[-1..-lookback/2].max
    rsi_prev_peak = rsi.compact[-lookback..-(lookback/2+1)].max

    if price_current_peak > price_prev_peak && rsi_current_peak < rsi_prev_peak
      divergences << {
        type: :bearish,
        reason: "Price higher high but RSI lower high"
      }
    end
  end

  # Bullish divergence: price lower low, RSI higher low
  if price_trough_idx && rsi_trough_idx
    price_current_trough = prices[-1..-lookback/2].min
    price_prev_trough = prices[-lookback..-(lookback/2+1)].min

    rsi_current_trough = rsi.compact[-1..-lookback/2].min
    rsi_prev_trough = rsi.compact[-lookback..-(lookback/2+1)].min

    if price_current_trough < price_prev_trough && rsi_current_trough > rsi_prev_trough
      divergences << {
        type: :bullish,
        reason: "Price lower low but RSI higher low"
      }
    end
  end

  divergences
end

def find_peak_index(data, lookback)
  recent_data = data.compact.last(lookback)
  return nil if recent_data.length < lookback
  recent_data.index(recent_data.max)
end

def find_trough_index(data, lookback)
  recent_data = data.compact.last(lookback)
  return nil if recent_data.length < lookback
  recent_data.index(recent_data.min)
end

# Example: Create data with bearish divergence
prices = Array.new(40) { |i| 100 + i * 2 }  # Uptrend
# Add a peak, then higher peak with weakening momentum
prices += [175, 178, 180, 178, 176, 174, 172, 170, 168, 166]

divergences = find_divergence(prices, lookback: 20)

if divergences.any?
  puts "Divergences Detected:"
  divergences.each do |div|
    puts "#{div[:type].to_s.capitalize} Divergence: #{div[:reason]}"
  end
else
  puts "No divergences detected"
end
```

## Multi-Indicator Momentum System

Combine RSI, MACD, and Momentum for stronger signals.

```ruby
require 'sqa/tai'

class MultiMomentumSystem
  def analyze(prices)
    # Calculate indicators
    rsi = SQA::TAI.rsi(prices, period: 14)
    macd, signal, histogram = SQA::TAI.macd(prices)
    mom = SQA::TAI.mom(prices, period: 10)

    # Individual signals
    rsi_signal = get_rsi_signal(rsi.last)
    macd_signal = get_macd_signal(macd.last, signal.last)
    mom_signal = get_mom_signal(mom.last)

    # Combine signals
    bullish_count = [rsi_signal, macd_signal, mom_signal].count(:bullish)
    bearish_count = [rsi_signal, macd_signal, mom_signal].count(:bearish)

    overall_signal = if bullish_count >= 2
      :buy
    elsif bearish_count >= 2
      :sell
    else
      :hold
    end

    {
      signal: overall_signal,
      confidence: [bullish_count, bearish_count].max,
      indicators: {
        rsi: { value: rsi.last.round(2), signal: rsi_signal },
        macd: { value: macd.last.round(4), signal: macd_signal },
        momentum: { value: mom.last.round(2), signal: mom_signal }
      }
    }
  end

  private

  def get_rsi_signal(rsi_value)
    if rsi_value < 30
      :bullish
    elsif rsi_value > 70
      :bearish
    else
      :neutral
    end
  end

  def get_macd_signal(macd_value, signal_value)
    if macd_value > signal_value
      :bullish
    elsif macd_value < signal_value
      :bearish
    else
      :neutral
    end
  end

  def get_mom_signal(mom_value)
    if mom_value > 0
      :bullish
    elsif mom_value < 0
      :bearish
    else
      :neutral
    end
  end
end

# Example usage
prices = Array.new(30) { |i| 100 + i * 0.5 + rand(-2.0..2.0) }

system = MultiMomentumSystem.new
analysis = system.analyze(prices)

puts "Multi-Indicator Momentum Analysis:"
puts "Overall Signal: #{analysis[:signal]}"
puts "Confidence: #{analysis[:confidence]}/3 indicators agree"
puts "\nIndividual Indicators:"
puts "RSI (#{analysis[:indicators][:rsi][:value]}): #{analysis[:indicators][:rsi][:signal]}"
puts "MACD (#{analysis[:indicators][:macd][:value]}): #{analysis[:indicators][:macd][:signal]}"
puts "Momentum (#{analysis[:indicators][:momentum][:value]}): #{analysis[:indicators][:momentum][:signal]}"
```

## Stochastic Oscillator Strategy

Use Stochastic for entry timing in trending markets.

```ruby
require 'sqa/tai'

def stochastic_strategy(high, low, close)
  # Calculate Stochastic
  slowk, slowd = SQA::TAI.stoch(high, low, close)

  # Calculate trend
  sma_50 = SQA::TAI.sma(close, period: 50)
  trend = close.last > sma_50.last ? :up : :down

  current_k = slowk.last
  current_d = slowd.last
  prev_k = slowk[-2]
  prev_d = slowd[-2]

  # Detect crossovers
  bullish_cross = prev_k < prev_d && current_k > current_d
  bearish_cross = prev_k > prev_d && current_k < current_d

  # Generate signals based on trend
  if trend == :up && bullish_cross && current_k < 20
    {
      action: :buy,
      strength: :strong,
      reason: "Stochastic bullish crossover in oversold zone (uptrend)",
      k: current_k.round(2),
      d: current_d.round(2)
    }
  elsif trend == :down && bearish_cross && current_k > 80
    {
      action: :sell,
      strength: :strong,
      reason: "Stochastic bearish crossover in overbought zone (downtrend)",
      k: current_k.round(2),
      d: current_d.round(2)
    }
  elsif bullish_cross
    {
      action: :buy,
      strength: :moderate,
      reason: "Stochastic bullish crossover",
      k: current_k.round(2),
      d: current_d.round(2)
    }
  elsif bearish_cross
    {
      action: :sell,
      strength: :moderate,
      reason: "Stochastic bearish crossover",
      k: current_k.round(2),
      d: current_d.round(2)
    }
  else
    {
      action: :hold,
      strength: :none,
      reason: "No clear signal",
      k: current_k.round(2),
      d: current_d.round(2)
    }
  end
end

# Generate sample OHLC data
length = 60
high = Array.new(length) { |i| 100 + i * 0.3 + rand(0..2.0) }
low = high.map { |h| h - rand(1.0..3.0) }
close = low.zip(high).map { |l, h| l + (h - l) * rand(0.3..0.7) }

signal = stochastic_strategy(high, low, close)

puts "Stochastic Strategy Signal:"
puts "Action: #{signal[:action]}"
puts "Strength: #{signal[:strength]}"
puts "Reason: #{signal[:reason]}"
puts "Stochastic K: #{signal[:k]}"
puts "Stochastic D: #{signal[:d]}"
```

## Momentum Breakout System

Combine momentum with price breakouts for high-probability trades.

```ruby
require 'sqa/tai'

def momentum_breakout(prices, volume, lookback: 20)
  # Find resistance
  resistance = prices[-lookback..-1].max

  # Calculate momentum
  rsi = SQA::TAI.rsi(prices, period: 14)
  macd, signal, histogram = SQA::TAI.macd(prices)

  # Volume analysis
  avg_volume = volume[-lookback..-1].sum / lookback.to_f
  volume_surge = volume.last > avg_volume * 1.5

  current_price = prices.last

  # Breakout conditions
  price_breakout = current_price > resistance
  momentum_positive = rsi.last > 50 && macd.last > signal.last

  if price_breakout && momentum_positive && volume_surge
    {
      signal: :strong_buy,
      reason: "Price breakout with momentum and volume confirmation",
      price: current_price.round(2),
      resistance: resistance.round(2),
      rsi: rsi.last.round(2),
      volume_ratio: (volume.last / avg_volume).round(2)
    }
  elsif price_breakout && momentum_positive
    {
      signal: :buy,
      reason: "Price breakout with momentum (low volume)",
      price: current_price.round(2),
      resistance: resistance.round(2),
      rsi: rsi.last.round(2),
      volume_ratio: (volume.last / avg_volume).round(2)
    }
  else
    {
      signal: :hold,
      reason: "No breakout or momentum confirmation",
      price: current_price.round(2),
      resistance: resistance.round(2),
      rsi: rsi.last.round(2),
      volume_ratio: (volume.last / avg_volume).round(2)
    }
  end
end

# Example usage
prices = Array.new(50) { |i| 100 + i * 0.2 + rand(-1.0..1.0) }
# Add breakout
prices += [115, 118, 120, 122, 125]

volume = Array.new(50) { 1000 + rand(-200..200) }
# Volume surge on breakout
volume += [1800, 2200, 2500, 2100, 1900]

result = momentum_breakout(prices, volume, lookback: 20)

puts "Momentum Breakout Analysis:"
puts "Signal: #{result[:signal]}"
puts "Reason: #{result[:reason]}"
puts "Price: $#{result[:price]} (Resistance: $#{result[:resistance]})"
puts "RSI: #{result[:rsi]}"
puts "Volume Ratio: #{result[:volume_ratio]}x"
```

## See Also

- [Trend Analysis Examples](trend-analysis.md)
- [Volatility Analysis Examples](volatility-analysis.md)
- [RSI Indicator](../indicators/momentum/rsi.md)
- [MACD Indicator](../indicators/momentum/macd.md)
- [Stochastic Indicator](../indicators/momentum/stoch.md)
