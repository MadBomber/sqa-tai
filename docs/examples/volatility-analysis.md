# Volatility Analysis Examples

Examples of using volatility indicators like ATR and Bollinger Bands for risk management and trading.

## ATR-Based Position Sizing

Use Average True Range to calculate appropriate position sizes.

```ruby
require 'sqa/tai'

def calculate_position_size(high, low, close, account_value, risk_per_trade_pct: 1.0, atr_multiplier: 2.0)
  # Calculate ATR
  atr = SQA::TAI.atr(high, low, close, period: 14)
  current_atr = atr.last
  current_price = close.last

  # Calculate risk amount
  risk_amount = account_value * (risk_per_trade_pct / 100.0)

  # Stop distance based on ATR
  stop_distance = current_atr * atr_multiplier

  # Calculate position size
  shares = (risk_amount / stop_distance).floor

  # Calculate actual investment
  investment = shares * current_price

  # Calculate percentage of account
  account_pct = (investment / account_value * 100).round(2)

  {
    shares: shares,
    price: current_price.round(2),
    investment: investment.round(2),
    account_pct: account_pct,
    atr: current_atr.round(2),
    stop_distance: stop_distance.round(2),
    stop_price: (current_price - stop_distance).round(2),
    risk_amount: risk_amount.round(2)
  }
end

# Example usage
length = 30
high = Array.new(length) { |i| 100 + i * 0.5 + rand(1.0..3.0) }
low = high.map { |h| h - rand(2.0..4.0) }
close = low.zip(high).map { |l, h| l + (h - l) * rand(0.4..0.6) }

position = calculate_position_size(high, low, close, 100_000, risk_per_trade_pct: 1.0)

puts "ATR-Based Position Sizing:"
puts "=" * 50
puts "Account Value: $100,000"
puts "Risk per Trade: 1% ($#{position[:risk_amount]})"
puts "\nPosition Details:"
puts "Shares: #{position[:shares]}"
puts "Entry Price: $#{position[:price]}"
puts "Investment: $#{position[:investment]} (#{position[:account_pct]}% of account)"
puts "\nRisk Management:"
puts "ATR: $#{position[:atr]}"
puts "Stop Distance: $#{position[:stop_distance]} (2× ATR)"
puts "Stop Loss Price: $#{position[:stop_price]}"
```

## Bollinger Bands Mean Reversion

Trade the extremes of Bollinger Bands for mean reversion.

```ruby
require 'sqa/tai'

class BollingerBandsStrategy
  def initialize(period: 20, std_dev: 2.0)
    @period = period
    @std_dev = std_dev
  end

  def analyze(prices)
    upper, middle, lower = SQA::TAI.bbands(
      prices,
      period: @period,
      nbdev_up: @std_dev,
      nbdev_down: @std_dev
    )

    current_price = prices.last
    upper_val = upper.last
    middle_val = middle.last
    lower_val = lower.last

    # Calculate %B (position within bands)
    percent_b = ((current_price - lower_val) / (upper_val - lower_val) * 100).round(2)

    # Calculate bandwidth
    bandwidth = ((upper_val - lower_val) / middle_val * 100).round(2)

    # Generate signal
    signal = if current_price <= lower_val
      :buy  # Price at/below lower band - oversold
    elsif current_price >= upper_val
      :sell  # Price at/above upper band - overbought
    elsif percent_b >= 45 && percent_b <= 55
      :close  # Near middle band - take profits
    else
      :hold
    end

    {
      signal: signal,
      price: current_price.round(2),
      upper: upper_val.round(2),
      middle: middle_val.round(2),
      lower: lower_val.round(2),
      percent_b: percent_b,
      bandwidth: bandwidth
    }
  end

  def backtest(prices, initial_capital: 10_000)
    capital = initial_capital
    position = 0
    entry_price = 0
    trades = []

    ([@period, prices.length - 1].max..prices.length - 1).each do |i|
      current_prices = prices[0..i]
      analysis = analyze(current_prices)

      case analysis[:signal]
      when :buy
        if position == 0
          shares = (capital / analysis[:price]).floor
          position = shares
          entry_price = analysis[:price]
          capital -= shares * analysis[:price]

          trades << {
            action: :buy,
            price: analysis[:price],
            shares: shares,
            percent_b: analysis[:percent_b]
          }
        end
      when :sell, :close
        if position > 0
          exit_value = position * analysis[:price]
          profit = (analysis[:price] - entry_price) * position
          capital += exit_value

          trades << {
            action: :sell,
            price: analysis[:price],
            shares: position,
            profit: profit.round(2),
            percent_b: analysis[:percent_b]
          }

          position = 0
        end
      end
    end

    # Close open position
    if position > 0
      capital += position * prices.last
    end

    {
      initial_capital: initial_capital,
      final_capital: capital.round(2),
      return_pct: ((capital / initial_capital - 1) * 100).round(2),
      num_trades: trades.length,
      trades: trades
    }
  end
end

# Example: Generate mean-reverting prices
prices = [100.0]
50.times do |i|
  # Mean-reverting random walk
  mean = 100
  prices << prices.last + (mean - prices.last) * 0.1 + rand(-3.0..3.0)
end

strategy = BollingerBandsStrategy.new(period: 20, std_dev: 2.0)

# Current analysis
current = strategy.analyze(prices)
puts "Bollinger Bands Analysis:"
puts "Signal: #{current[:signal]}"
puts "Price: $#{current[:price]}"
puts "Upper Band: $#{current[:upper]}"
puts "Middle Band: $#{current[:middle]}"
puts "Lower Band: $#{current[:lower]}"
puts "%B: #{current[:percent_b]}%"
puts "Bandwidth: #{current[:bandwidth]}%"

# Backtest
puts "\nBacktest Results:"
results = strategy.backtest(prices)
puts "Return: #{results[:return_pct]}%"
puts "Trades: #{results[:num_trades]}"
```

## Volatility Breakout Detection

Identify when volatility expands after consolidation.

```ruby
require 'sqa/tai'

def detect_volatility_breakout(high, low, close, lookback: 20)
  atr = SQA::TAI.atr(high, low, close, period: 14)

  # Calculate ATR statistics
  recent_atr = atr.compact.last(lookback)
  avg_atr = recent_atr.sum / recent_atr.length
  min_atr = recent_atr.min
  current_atr = atr.last

  # Volatility squeeze: ATR near lows
  in_squeeze = current_atr < avg_atr * 0.7

  # Volatility expansion: ATR breaking out
  breakout = current_atr > avg_atr * 1.5

  # Calculate price movement
  price_range_pct = ((high.last - low.last) / close.last * 100).round(2)

  status = if breakout
    :expanding
  elsif in_squeeze
    :contracting
  else
    :normal
  end

  {
    status: status,
    current_atr: current_atr.round(2),
    avg_atr: avg_atr.round(2),
    atr_ratio: (current_atr / avg_atr).round(2),
    price_range_pct: price_range_pct,
    action: determine_action(status, price_range_pct, close[-2], close[-1])
  }
end

def determine_action(status, range_pct, prev_close, current_close)
  if status == :contracting
    "Watch for breakout - volatility compressing"
  elsif status == :expanding && current_close > prev_close
    "Bullish breakout - consider long positions"
  elsif status == :expanding && current_close < prev_close
    "Bearish breakout - consider short positions"
  else
    "Normal volatility - no specific action"
  end
end

# Generate data with volatility squeeze then expansion
high = Array.new(30) { |i| 100 + rand(0.5..1.5) }  # Low volatility
high += Array.new(10) { |i| 101 + i * 2 + rand(1.0..4.0) }  # Expanding

low = high.map.with_index { |h, i| i < 30 ? h - rand(0.5..1.0) : h - rand(2.0..5.0) }
close = low.zip(high).map { |l, h| l + (h - l) * rand(0.3..0.7) }

result = detect_volatility_breakout(high, low, close, lookback: 20)

puts "Volatility Breakout Detection:"
puts "Status: #{result[:status]}"
puts "Current ATR: $#{result[:current_atr]}"
puts "Average ATR: $#{result[:avg_atr]}"
puts "ATR Ratio: #{result[:atr_ratio]}x"
puts "Price Range: #{result[:price_range_pct]}%"
puts "\nRecommendation: #{result[:action]}"
```

## ATR Trailing Stop Loss

Implement a dynamic stop loss that adapts to volatility.

```ruby
require 'sqa/tai'

class ATRTrailingStop
  def initialize(atr_multiplier: 2.0)
    @atr_multiplier = atr_multiplier
    @stop_loss = nil
  end

  def calculate_stop(high, low, close, position_type: :long)
    atr = SQA::TAI.atr(high, low, close, period: 14)
    current_atr = atr.last
    current_price = close.last

    if position_type == :long
      # Long position: stop below price
      new_stop = current_price - (current_atr * @atr_multiplier)

      # Only move stop up, never down
      @stop_loss = [@stop_loss || new_stop, new_stop].max
    else
      # Short position: stop above price
      new_stop = current_price + (current_atr * @atr_multiplier)

      # Only move stop down, never up
      @stop_loss = [@stop_loss || new_stop, new_stop].min
    end

    {
      current_price: current_price.round(2),
      stop_loss: @stop_loss.round(2),
      distance: ((current_price - @stop_loss).abs).round(2),
      distance_pct: (((current_price - @stop_loss).abs / current_price) * 100).round(2),
      atr: current_atr.round(2)
    }
  end

  def reset
    @stop_loss = nil
  end
end

# Simulate a trending market with trailing stop
length = 50
high = Array.new(length) { |i| 100 + i * 0.8 + rand(0.5..2.0) }
low = high.map { |h| h - rand(1.0..3.0) }
close = low.zip(high).map { |l, h| l + (h - l) * rand(0.4..0.6) }

trailing_stop = ATRTrailingStop.new(atr_multiplier: 2.0)

puts "ATR Trailing Stop Example (Long Position):"
puts "=" * 50

# Show trailing stop every 10 bars
[10, 20, 30, 40, 50].each do |bar|
  h = high[0..bar]
  l = low[0..bar]
  c = close[0..bar]

  stop_info = trailing_stop.calculate_stop(h, l, c, position_type: :long)

  puts "\nBar #{bar}:"
  puts "Price: $#{stop_info[:current_price]}"
  puts "Trailing Stop: $#{stop_info[:stop_loss]}"
  puts "Distance: $#{stop_info[:distance]} (#{stop_info[:distance_pct]}%)"
  puts "ATR: $#{stop_info[:atr]}"
end
```

## Bollinger Band Squeeze

Detect low volatility periods that often precede large moves.

```ruby
require 'sqa/tai'

def detect_bb_squeeze(prices, lookback: 20)
  upper, middle, lower = SQA::TAI.bbands(prices, period: 20)

  # Calculate bandwidth
  bandwidths = []
  upper.each_with_index do |u, i|
    next unless u && middle[i] && lower[i]
    bw = (u - lower[i]) / middle[i] * 100
    bandwidths << bw
  end

  return nil if bandwidths.empty?

  # Current bandwidth
  current_bw = bandwidths.last

  # Historical bandwidth stats
  recent_bw = bandwidths.last(lookback)
  avg_bw = recent_bw.sum / recent_bw.length
  min_bw = recent_bw.min

  # Squeeze: bandwidth in lowest 20%
  squeeze_threshold = avg_bw * 0.8
  in_squeeze = current_bw < squeeze_threshold

  # Breaking out of squeeze
  breaking_out = bandwidths[-2] < squeeze_threshold && current_bw >= squeeze_threshold

  {
    in_squeeze: in_squeeze,
    breaking_out: breaking_out,
    current_bandwidth: current_bw.round(2),
    avg_bandwidth: avg_bw.round(2),
    bandwidth_percentile: ((current_bw / avg_bw) * 100).round(0),
    price: prices.last.round(2),
    upper_band: upper.last.round(2),
    lower_band: lower.last.round(2)
  }
end

# Generate data with squeeze
prices = [100.0]
# Consolidation phase (squeeze)
20.times { prices << prices.last + rand(-0.5..0.5) }
# Breakout phase
15.times { |i| prices << prices.last + 1.5 + rand(-0.5..0.5) }

squeeze_info = detect_bb_squeeze(prices, lookback: 20)

puts "Bollinger Band Squeeze Analysis:"
puts "=" * 50
puts "In Squeeze: #{squeeze_info[:in_squeeze] ? 'Yes' : 'No'}"
puts "Breaking Out: #{squeeze_info[:breaking_out] ? 'YES - Take action!' : 'No'}"
puts "Current Bandwidth: #{squeeze_info[:current_bandwidth]}%"
puts "Average Bandwidth: #{squeeze_info[:avg_bandwidth]}%"
puts "Bandwidth Percentile: #{squeeze_info[:bandwidth_percentile]}%"
puts "\nPrice: $#{squeeze_info[:price]}"
puts "Upper Band: $#{squeeze_info[:upper_band]}"
puts "Lower Band: $#{squeeze_info[:lower_band]}"

if squeeze_info[:in_squeeze]
  puts "\n⚠️  Squeeze active - expect breakout soon!"
elsif squeeze_info[:breaking_out]
  puts "\n🚀 Breakout in progress - enter trade!"
end
```

## Complete Volatility-Based Trading System

Combine multiple volatility indicators for a complete system.

```ruby
require 'sqa/tai'

class VolatilityTradingSystem
  def analyze(high, low, close, prices)
    # Calculate indicators
    atr = SQA::TAI.atr(high, low, close, period: 14)
    upper, middle, lower = SQA::TAI.bbands(prices, period: 20)

    # ATR analysis
    recent_atr = atr.compact.last(20)
    avg_atr = recent_atr.sum / recent_atr.length
    atr_ratio = atr.last / avg_atr

    # Bollinger Bands analysis
    bandwidth = (upper.last - lower.last) / middle.last * 100
    percent_b = (close.last - lower.last) / (upper.last - lower.last) * 100

    # Volatility state
    volatility_state = if atr_ratio < 0.7
      :low
    elsif atr_ratio > 1.5
      :high
    else
      :normal
    end

    # Generate signals
    signal = generate_signal(
      volatility_state,
      close.last,
      upper.last,
      middle.last,
      lower.last,
      percent_b,
      bandwidth
    )

    {
      signal: signal,
      volatility: volatility_state,
      atr: atr.last.round(2),
      atr_ratio: atr_ratio.round(2),
      bandwidth: bandwidth.round(2),
      percent_b: percent_b.round(0),
      price: close.last.round(2),
      upper: upper.last.round(2),
      middle: middle.last.round(2),
      lower: lower.last.round(2)
    }
  end

  private

  def generate_signal(vol_state, price, upper, middle, lower, percent_b, bandwidth)
    if vol_state == :low && bandwidth < 10
      {
        action: :wait,
        reason: "Low volatility squeeze - wait for breakout",
        setup: "Prepare for volatility expansion"
      }
    elsif vol_state == :high && price > upper
      {
        action: :sell,
        reason: "High volatility + overbought",
        setup: "Mean reversion trade"
      }
    elsif vol_state == :high && price < lower
      {
        action: :buy,
        reason: "High volatility + oversold",
        setup: "Mean reversion trade"
      }
    elsif vol_state == :normal && percent_b < 5
      {
        action: :buy,
        reason: "Price at lower band in normal volatility",
        setup: "Mean reversion with tight stop"
      }
    elsif vol_state == :normal && percent_b > 95
      {
        action: :sell,
        reason: "Price at upper band in normal volatility",
        setup: "Mean reversion with tight stop"
      }
    else
      {
        action: :hold,
        reason: "No clear setup",
        setup: "Monitor for opportunities"
      }
    end
  end
end

# Generate sample data
length = 50
high = Array.new(length) { |i| 100 + Math.sin(i * 0.15) * 10 + i * 0.2 + rand(0.5..2.0) }
low = high.map { |h| h - rand(1.5..3.5) }
close = low.zip(high).map { |l, h| l + (h - l) * rand(0.3..0.7) }

system = VolatilityTradingSystem.new
analysis = system.analyze(high, low, close, close)

puts "Volatility Trading System Analysis:"
puts "=" * 50
puts "Volatility State: #{analysis[:volatility]}"
puts "ATR: $#{analysis[:atr]} (#{analysis[:atr_ratio]}x average)"
puts "Bandwidth: #{analysis[:bandwidth]}%"
puts "%B: #{analysis[:percent_b]}%"
puts "\nPrice: $#{analysis[:price]}"
puts "Upper Band: $#{analysis[:upper]}"
puts "Middle Band: $#{analysis[:middle]}"
puts "Lower Band: $#{analysis[:lower]}"
puts "\nSignal:"
puts "Action: #{analysis[:signal][:action]}"
puts "Reason: #{analysis[:signal][:reason]}"
puts "Setup: #{analysis[:signal][:setup]}"
```

## See Also

- [Trend Analysis Examples](trend-analysis.md)
- [Momentum Trading Examples](momentum-trading.md)
- [ATR Indicator](../indicators/volatility/atr.md)
- [Bollinger Bands](../indicators/overlap/bbands.md)
