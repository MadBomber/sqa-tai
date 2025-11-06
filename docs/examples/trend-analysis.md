# Trend Analysis Examples

Learn how to use SQA::TAI indicators to identify and analyze market trends.

## Moving Average Crossover Strategy

One of the most popular trend-following strategies using moving averages.

```ruby
require 'sqa/tai'

# Load historical data
prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83, 45.10, 45.42,
          45.84, 46.08, 46.03, 46.41, 46.22, 45.64, 46.21, 46.25,
          46.08, 46.46, 46.57, 45.95, 46.50, 46.02, 46.55, 47.03,
          47.35, 47.28, 47.61, 48.12, 48.34, 48.21, 48.95, 49.13,
          49.32, 49.78, 50.12, 50.43, 50.21, 50.67, 51.02, 51.35,
          51.78, 52.12, 52.45, 52.89, 53.21, 53.65, 54.02, 54.38,
          54.72, 55.15]

# Calculate fast and slow moving averages
fast_ma = SQA::TAI.sma(prices, period: 10)
slow_ma = SQA::TAI.sma(prices, period: 20)

# Detect crossovers
def detect_crossover(fast, slow)
  return nil if fast[-2].nil? || slow[-2].nil?

  if fast[-2] < slow[-2] && fast[-1] > slow[-1]
    :bullish_crossover
  elsif fast[-2] > slow[-2] && fast[-1] < slow[-1]
    :bearish_crossover
  else
    nil
  end
end

signal = detect_crossover(fast_ma, slow_ma)

case signal
when :bullish_crossover
  puts "Golden Cross: Fast MA crossed above Slow MA - BUY SIGNAL"
  puts "Fast MA: #{fast_ma.last.round(2)}"
  puts "Slow MA: #{slow_ma.last.round(2)}"
when :bearish_crossover
  puts "Death Cross: Fast MA crossed below Slow MA - SELL SIGNAL"
  puts "Fast MA: #{fast_ma.last.round(2)}"
  puts "Slow MA: #{slow_ma.last.round(2)}"
else
  puts "No crossover detected"
end
```

## Trend Strength Analysis

Combine multiple indicators to assess trend strength.

```ruby
require 'sqa/tai'

def analyze_trend_strength(prices)
  # Calculate multiple timeframe MAs
  sma_20 = SQA::TAI.sma(prices, period: 20)
  sma_50 = SQA::TAI.sma(prices, period: 50)
  sma_200 = SQA::TAI.sma(prices, period: 200)

  # Calculate momentum
  rsi = SQA::TAI.rsi(prices, period: 14)
  macd, signal, histogram = SQA::TAI.macd(prices)

  current_price = prices.last

  # Trend direction
  trend = if current_price > sma_20.last &&
             sma_20.last > sma_50.last &&
             sma_50.last > sma_200.last
    :strong_uptrend
  elsif current_price < sma_20.last &&
        sma_20.last < sma_50.last &&
        sma_50.last < sma_200.last
    :strong_downtrend
  elsif current_price > sma_50.last
    :uptrend
  elsif current_price < sma_50.last
    :downtrend
  else
    :sideways
  end

  # Momentum confirmation
  momentum_bullish = rsi.last > 50 && macd.last > signal.last
  momentum_bearish = rsi.last < 50 && macd.last < signal.last

  {
    trend: trend,
    price: current_price.round(2),
    sma_20: sma_20.last.round(2),
    sma_50: sma_50.last.round(2),
    sma_200: sma_200.last.round(2),
    rsi: rsi.last.round(2),
    macd: macd.last.round(4),
    momentum_confirmed: (trend == :strong_uptrend && momentum_bullish) ||
                        (trend == :strong_downtrend && momentum_bearish)
  }
end

# Example usage
prices = (1..100).map { |i| 100 + i * 0.5 + rand(-2.0..2.0) }  # Uptrending prices
analysis = analyze_trend_strength(prices)

puts "Trend Analysis Results:"
puts "=" * 50
puts "Trend: #{analysis[:trend]}"
puts "Current Price: $#{analysis[:price]}"
puts "SMA(20): $#{analysis[:sma_20]}"
puts "SMA(50): $#{analysis[:sma_50]}"
puts "SMA(200): $#{analysis[:sma_200]}"
puts "RSI: #{analysis[:rsi]}"
puts "MACD: #{analysis[:macd]}"
puts "Momentum Confirmed: #{analysis[:momentum_confirmed] ? 'Yes' : 'No'}"
```

## Support and Resistance with Moving Averages

Use moving averages as dynamic support and resistance levels.

```ruby
require 'sqa/tai'

def find_ma_support_resistance(prices)
  ema_20 = SQA::TAI.ema(prices, period: 20)
  ema_50 = SQA::TAI.ema(prices, period: 50)

  current_price = prices.last
  ema_20_val = ema_20.last
  ema_50_val = ema_50.last

  # Determine support/resistance levels
  levels = []

  if current_price > ema_20_val
    levels << { level: ema_20_val, type: :support, ma: "EMA(20)" }
  else
    levels << { level: ema_20_val, type: :resistance, ma: "EMA(20)" }
  end

  if current_price > ema_50_val
    levels << { level: ema_50_val, type: :support, ma: "EMA(50)" }
  else
    levels << { level: ema_50_val, type: :resistance, ma: "EMA(50)" }
  end

  # Distance to levels
  levels.each do |level_info|
    distance = ((current_price - level_info[:level]) / level_info[:level] * 100).abs
    level_info[:distance_pct] = distance.round(2)
    level_info[:price] = level_info[:level].round(2)
  end

  levels.sort_by { |l| l[:distance_pct] }
end

# Example usage
prices = Array.new(60) { |i| 100 + Math.sin(i * 0.1) * 10 + i * 0.1 }
levels = find_ma_support_resistance(prices)

puts "Dynamic Support/Resistance Levels:"
puts "Current Price: $#{prices.last.round(2)}"
puts "\n"

levels.each do |level|
  puts "#{level[:ma]}: $#{level[:price]} (#{level[:type]})"
  puts "  Distance: #{level[:distance_pct]}%"
end
```

## Triple Moving Average System

A complete trading system using three moving averages.

```ruby
require 'sqa/tai'

class TripleMASystem
  def initialize(fast_period: 10, medium_period: 20, slow_period: 50)
    @fast_period = fast_period
    @medium_period = medium_period
    @slow_period = slow_period
  end

  def analyze(prices)
    fast = SQA::TAI.ema(prices, period: @fast_period)
    medium = SQA::TAI.ema(prices, period: @medium_period)
    slow = SQA::TAI.ema(prices, period: @slow_period)

    current_price = prices.last
    fast_val = fast.last
    medium_val = medium.last
    slow_val = slow.last

    # Determine trend alignment
    bullish_alignment = fast_val > medium_val && medium_val > slow_val
    bearish_alignment = fast_val < medium_val && medium_val < slow_val

    # Entry signals
    signal = if bullish_alignment && current_price > fast_val
      :strong_buy
    elsif bearish_alignment && current_price < fast_val
      :strong_sell
    elsif fast_val > medium_val && current_price > fast_val
      :buy
    elsif fast_val < medium_val && current_price < fast_val
      :sell
    else
      :hold
    end

    {
      signal: signal,
      price: current_price.round(2),
      fast: fast_val.round(2),
      medium: medium_val.round(2),
      slow: slow_val.round(2),
      alignment: bullish_alignment ? :bullish : (bearish_alignment ? :bearish : :mixed)
    }
  end

  def backtest(prices, initial_capital: 10000)
    capital = initial_capital
    position = 0
    entry_price = 0
    trades = []

    ([@slow_period, prices.length - 1].max..prices.length - 1).each do |i|
      current_prices = prices[0..i]
      analysis = analyze(current_prices)

      if position == 0 && [:buy, :strong_buy].include?(analysis[:signal])
        # Enter long
        shares = (capital / analysis[:price]).floor
        position = shares
        entry_price = analysis[:price]
        capital -= shares * analysis[:price]

        trades << {
          action: :buy,
          price: analysis[:price],
          shares: shares,
          capital: capital
        }
      elsif position > 0 && [:sell, :strong_sell].include?(analysis[:signal])
        # Exit long
        exit_value = position * analysis[:price]
        capital += exit_value
        profit = (analysis[:price] - entry_price) * position

        trades << {
          action: :sell,
          price: analysis[:price],
          shares: position,
          profit: profit.round(2),
          capital: capital.round(2)
        }

        position = 0
      end
    end

    # Close any open position
    if position > 0
      exit_value = position * prices.last
      capital += exit_value
    end

    {
      initial_capital: initial_capital,
      final_capital: capital.round(2),
      total_return: ((capital / initial_capital - 1) * 100).round(2),
      trades: trades
    }
  end
end

# Example usage
prices = Array.new(200) { |i| 100 + Math.sin(i * 0.05) * 20 + i * 0.15 + rand(-2.0..2.0) }

system = TripleMASystem.new(fast_period: 10, medium_period: 20, slow_period: 50)

# Current analysis
current_analysis = system.analyze(prices)
puts "Current Market Analysis:"
puts "Signal: #{current_analysis[:signal]}"
puts "Price: $#{current_analysis[:price]}"
puts "Fast EMA: $#{current_analysis[:fast]}"
puts "Medium EMA: $#{current_analysis[:medium]}"
puts "Slow EMA: $#{current_analysis[:slow]}"
puts "Alignment: #{current_analysis[:alignment]}"

# Backtest results
puts "\nBacktest Results:"
results = system.backtest(prices, initial_capital: 10000)
puts "Initial Capital: $#{results[:initial_capital]}"
puts "Final Capital: $#{results[:final_capital]}"
puts "Total Return: #{results[:total_return]}%"
puts "Number of Trades: #{results[:trades].length}"
```

## Trend Following with ADX

Use the Average Directional Index (ADX) to measure trend strength (if available in TA-Lib).

```ruby
require 'sqa/tai'

# Simplified trend strength based on moving averages
def calculate_trend_strength(prices)
  sma_20 = SQA::TAI.sma(prices, period: 20)
  sma_50 = SQA::TAI.sma(prices, period: 50)

  # Calculate slope of 20-day MA
  ma_slope = sma_20.compact.last(5).each_cons(2).map { |a, b| b - a }.sum

  # Calculate distance between MAs
  ma_distance = ((sma_20.last - sma_50.last) / sma_50.last * 100).abs

  strength = if ma_distance > 5 && ma_slope.abs > 1
    :strong
  elsif ma_distance > 2 && ma_slope.abs > 0.5
    :moderate
  else
    :weak
  end

  {
    strength: strength,
    ma_distance_pct: ma_distance.round(2),
    ma_slope: ma_slope.round(4)
  }
end

# Example usage
prices = Array.new(100) { |i| 100 + i * 0.8 + rand(-1.0..1.0) }  # Strong uptrend
strength = calculate_trend_strength(prices)

puts "Trend Strength Analysis:"
puts "Strength: #{strength[:strength]}"
puts "MA Distance: #{strength[:ma_distance_pct]}%"
puts "MA Slope: #{strength[:ma_slope]}"
```

## See Also

- [Momentum Trading Examples](momentum-trading.md)
- [Volatility Analysis Examples](volatility-analysis.md)
- [Indicators Reference](../indicators/index.md)
- [Basic Usage Guide](../getting-started/basic-usage.md)
