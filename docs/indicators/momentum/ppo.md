# Percentage Price Oscillator (PPO)

The Percentage Price Oscillator (PPO) measures the percentage difference between two exponential moving averages. Unlike the Absolute Price Oscillator (APO), which shows the absolute point difference, PPO expresses the difference as a percentage of the slower moving average. This percentage-based approach makes PPO values comparable across different securities and price levels, allowing for standardized analysis regardless of whether a stock trades at $10 or $1,000.

## Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41,
          46.22, 45.64, 46.21, 46.25, 46.08, 46.46,
          46.70, 47.00, 47.25, 47.50, 47.35, 47.75]

# Calculate PPO with default periods (12, 26)
ppo = SQA::TAI.ppo(prices, fast_period: 12, slow_period: 26)

puts "Current PPO: #{ppo.last.round(4)}%"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prices` | Array<Float> | Yes | - | Array of price values |
| `fast_period` | Integer | No | 12 | Period for fast EMA |
| `slow_period` | Integer | No | 26 | Period for slow EMA |
| `ma_type` | Integer | No | 0 | Moving average type (0=SMA, 1=EMA, etc.) |

## Returns

Returns an array of PPO values expressed as percentages. The first `slow_period - 1` values will be `nil`. Values typically range between -10% and +10%, though they can exceed these bounds during strong trends.

## Formula

```
PPO = ((Fast EMA - Slow EMA) / Slow EMA) × 100
```

For example, if the 12-period EMA is 46.50 and the 26-period EMA is 45.00:
```
PPO = ((46.50 - 45.00) / 45.00) × 100 = 3.33%
```

## Interpretation

| PPO Value | Interpretation |
|-----------|----------------|
| Positive | Fast MA above slow MA - bullish momentum |
| Negative | Fast MA below slow MA - bearish momentum |
| Zero | Fast MA equals slow MA - neutral |
| Increasing | Momentum strengthening |
| Decreasing | Momentum weakening |

### Signal Strength

- **0 to ±2%**: Weak momentum or consolidation
- **±2% to ±5%**: Moderate momentum
- **±5% to ±10%**: Strong momentum
- **Beyond ±10%**: Extreme momentum (potential reversal zone)

## Why Percentage Matters

The percentage-based calculation provides several key advantages:

### 1. Cross-Security Comparison

PPO allows direct comparison between securities at different price levels:

```ruby
# Stock A trading at $10
stock_a_prices = [9.50, 9.80, 10.00, 10.20, 10.50]
ppo_a = SQA::TAI.ppo(stock_a_prices)

# Stock B trading at $1000
stock_b_prices = [950, 980, 1000, 1020, 1050]
ppo_b = SQA::TAI.ppo(stock_b_prices)

# Both will show similar PPO values (~5%) despite 100x price difference
puts "Stock A PPO: #{ppo_a.last.round(2)}%"
puts "Stock B PPO: #{ppo_b.last.round(2)}%"
```

Both stocks show similar percentage momentum, making them directly comparable for relative strength analysis.

### 2. Historical Consistency

PPO remains consistent across time even as a security's price level changes dramatically:

```ruby
# Early 2010: Stock at $50, APO shows +0.50 points
# Late 2024: Stock at $500, APO shows +5.00 points

# PPO would show similar +1% in both cases
# This allows for consistent historical backtesting
```

### 3. Standardized Thresholds

You can use the same PPO thresholds across all securities:

```ruby
def analyze_momentum(prices)
  ppo = SQA::TAI.ppo(prices)
  current_ppo = ppo.last

  case current_ppo
  when 5..Float::INFINITY
    "Strong bullish momentum (#{current_ppo.round(2)}%)"
  when 2..5
    "Moderate bullish momentum (#{current_ppo.round(2)}%)"
  when -2..2
    "Neutral/Consolidation (#{current_ppo.round(2)}%)"
  when -5..-2
    "Moderate bearish momentum (#{current_ppo.round(2)}%)"
  when -Float::INFINITY..-5
    "Strong bearish momentum (#{current_ppo.round(2)}%)"
  end
end

# Same thresholds work for penny stocks and high-priced stocks
puts analyze_momentum(low_price_stock)
puts analyze_momentum(high_price_stock)
```

## Example: Basic PPO Signals

```ruby
prices = load_historical_prices('AAPL')

ppo = SQA::TAI.ppo(prices, fast_period: 12, slow_period: 26)
current_ppo = ppo.last
previous_ppo = ppo[-2]

# Zero line crossover
if previous_ppo < 0 && current_ppo > 0
  puts "PPO crossed above zero - Bullish signal"
  puts "Momentum shifted from negative to positive"
elsif previous_ppo > 0 && current_ppo < 0
  puts "PPO crossed below zero - Bearish signal"
  puts "Momentum shifted from positive to negative"
end

# Momentum strength
if current_ppo.abs > 5
  direction = current_ppo > 0 ? "bullish" : "bearish"
  puts "Strong #{direction} momentum: #{current_ppo.round(2)}%"
end
```

## Example: PPO vs APO Comparison

```ruby
# Demonstrate percentage advantage
prices_low = [10, 10.2, 10.5, 10.8, 11.0]  # Low-priced stock
prices_high = [1000, 1020, 1050, 1080, 1100]  # High-priced stock

apo_low = SQA::TAI.apo(prices_low)
apo_high = SQA::TAI.apo(prices_high)

ppo_low = SQA::TAI.ppo(prices_low)
ppo_high = SQA::TAI.ppo(prices_high)

puts <<~COMPARISON
  Low-Priced Stock ($10):
    APO: #{apo_low.last.round(4)} points
    PPO: #{ppo_low.last.round(4)}%

  High-Priced Stock ($1000):
    APO: #{apo_high.last.round(4)} points (100x larger!)
    PPO: #{ppo_high.last.round(4)}% (same as low-priced stock)

  Conclusion: PPO normalizes momentum across price levels
COMPARISON
```

## Example: PPO Divergence

```ruby
prices = load_historical_prices('TSLA')

ppo = SQA::TAI.ppo(prices)

# Find recent price and PPO peaks
price_peak_1 = prices[-20..-10].max
price_peak_2 = prices[-9..-1].max

ppo_peak_1 = ppo[-20..-10].compact.max
ppo_peak_2 = ppo[-9..-1].compact.max

# Bearish divergence: price makes higher high, PPO makes lower high
if price_peak_2 > price_peak_1 && ppo_peak_2 < ppo_peak_1
  puts <<~DIVERGENCE
    Bearish Divergence Detected!
    Price: $#{price_peak_1} -> $#{price_peak_2} (higher high)
    PPO: #{ppo_peak_1.round(2)}% -> #{ppo_peak_2.round(2)}% (lower high)

    Interpretation: Price is rising but momentum is weakening
    Warning: Potential trend reversal ahead
  DIVERGENCE
end

# Bullish divergence: price makes lower low, PPO makes higher low
price_low_1 = prices[-20..-10].min
price_low_2 = prices[-9..-1].min

ppo_low_1 = ppo[-20..-10].compact.min
ppo_low_2 = ppo[-9..-1].compact.min

if price_low_2 < price_low_1 && ppo_low_2 > ppo_low_1
  puts <<~DIVERGENCE
    Bullish Divergence Detected!
    Price: $#{price_low_1} -> $#{price_low_2} (lower low)
    PPO: #{ppo_low_1.round(2)}% -> #{ppo_low_2.round(2)}% (higher low)

    Interpretation: Price is falling but momentum is strengthening
    Opportunity: Potential trend reversal upward
  DIVERGENCE
end
```

## Example: PPO with Signal Line

```ruby
prices = load_historical_prices('MSFT')

ppo = SQA::TAI.ppo(prices)

# Create signal line (9-period EMA of PPO)
signal_line = SQA::TAI.ema(ppo.compact, period: 9)

# Pad signal line to match PPO array size
signal_line = [nil] * (ppo.size - signal_line.size) + signal_line

current_ppo = ppo.last
current_signal = signal_line.last
previous_ppo = ppo[-2]
previous_signal = signal_line[-2]

# PPO/Signal crossover (similar to MACD)
if previous_ppo < previous_signal && current_ppo > current_signal
  puts <<~SIGNAL
    PPO Bullish Crossover
    PPO: #{current_ppo.round(2)}%
    Signal: #{current_signal.round(2)}%
    Action: Consider buying
  SIGNAL
elsif previous_ppo > previous_signal && current_ppo < current_signal
  puts <<~SIGNAL
    PPO Bearish Crossover
    PPO: #{current_ppo.round(2)}%
    Signal: #{current_signal.round(2)}%
    Action: Consider selling
  SIGNAL
end

# Histogram (PPO - Signal)
histogram = current_ppo - current_signal
puts "PPO Histogram: #{histogram.round(2)}%"
```

## Example: Multi-Security Momentum Ranking

```ruby
# PPO excels at ranking momentum across different securities
stocks = ['AAPL', 'GOOGL', 'MSFT', 'TSLA', 'AMZN']

momentum_scores = stocks.map do |ticker|
  prices = load_historical_prices(ticker)
  ppo = SQA::TAI.ppo(prices)

  {
    ticker: ticker,
    price: prices.last,
    ppo: ppo.last.round(2)
  }
end

# Sort by PPO (percentage momentum)
ranked = momentum_scores.sort_by { |s| -s[:ppo] }

puts "Momentum Rankings (PPO):"
puts "=" * 40
ranked.each_with_index do |stock, index|
  puts "#{index + 1}. #{stock[:ticker]}: #{stock[:ppo]}% (Price: $#{stock[:price]})"
end

puts "\nTop momentum plays: #{ranked.first(2).map { |s| s[:ticker] }.join(', ')}"
```

## Example: Overbought/Oversold with PPO

```ruby
prices = load_historical_prices('SPY')

ppo = SQA::TAI.ppo(prices)

# Calculate PPO statistical bounds
recent_ppo = ppo.last(50).compact
ppo_mean = recent_ppo.sum / recent_ppo.size
ppo_std = Math.sqrt(recent_ppo.map { |x| (x - ppo_mean)**2 }.sum / recent_ppo.size)

upper_band = ppo_mean + (2 * ppo_std)
lower_band = ppo_mean - (2 * ppo_std)

current_ppo = ppo.last

puts <<~ANALYSIS
  PPO Statistical Analysis:
  Current PPO: #{current_ppo.round(2)}%
  Mean: #{ppo_mean.round(2)}%
  Std Dev: #{ppo_std.round(2)}%
  Upper Band (+2σ): #{upper_band.round(2)}%
  Lower Band (-2σ): #{lower_band.round(2)}%
ANALYSIS

if current_ppo > upper_band
  puts "PPO above upper band - Overbought condition"
  puts "Momentum may be overextended"
elsif current_ppo < lower_band
  puts "PPO below lower band - Oversold condition"
  puts "Potential reversal opportunity"
end
```

## Trading Strategies

### 1. Zero-Line Strategy
- **Buy**: PPO crosses above zero (bullish momentum begins)
- **Sell**: PPO crosses below zero (bearish momentum begins)

### 2. Signal Line Strategy
- **Buy**: PPO crosses above its signal line
- **Sell**: PPO crosses below its signal line

### 3. Divergence Strategy
- **Buy**: Bullish divergence (price makes lower low, PPO makes higher low)
- **Sell**: Bearish divergence (price makes higher high, PPO makes lower high)

### 4. Extreme Readings
- **Take Profits**: PPO exceeds ±10% (momentum overextension)
- **Avoid**: PPO near zero (weak momentum, choppy conditions)

## Advanced Techniques

### 1. PPO Trend Filter

Use PPO as a trend filter for other strategies:

```ruby
ppo = SQA::TAI.ppo(prices)

if ppo.last > 0
  puts "Bullish trend - only take long positions"
elsif ppo.last < 0
  puts "Bearish trend - only take short positions"
end
```

### 2. PPO Rate of Change

Monitor how fast PPO is changing:

```ruby
ppo = SQA::TAI.ppo(prices)
ppo_change = ppo.last - ppo[-5]

if ppo_change > 2
  puts "Rapidly accelerating momentum - strong trend"
elsif ppo_change < -2
  puts "Rapidly decelerating momentum - trend exhaustion"
end
```

### 3. Multi-Timeframe PPO

```ruby
daily_prices = load_historical_prices('AAPL', timeframe: 'daily')
weekly_prices = load_historical_prices('AAPL', timeframe: 'weekly')

daily_ppo = SQA::TAI.ppo(daily_prices)
weekly_ppo = SQA::TAI.ppo(weekly_prices)

# Strongest signals when both timeframes align
if daily_ppo.last > 0 && weekly_ppo.last > 0
  puts "Multi-timeframe bullish - high conviction buy"
elsif daily_ppo.last < 0 && weekly_ppo.last < 0
  puts "Multi-timeframe bearish - high conviction sell"
end
```

## Common Settings

| Fast | Slow | Use Case |
|------|------|----------|
| 12 | 26 | Standard (MACD equivalent) |
| 9 | 18 | More responsive for short-term trading |
| 20 | 40 | Smoother for swing trading |
| 5 | 35 | Aggressive crossover system |

## PPO vs APO: When to Use Each

**Use PPO when:**
- Comparing momentum across different securities
- Analyzing stocks at vastly different price levels
- Building universal trading strategies
- Conducting historical analysis across time periods
- Ranking relative strength

**Use APO when:**
- Analyzing a single security in isolation
- Need actual point values for position sizing
- Working with absolute price movements
- Calculating precise entry/exit points

## Related Indicators

- [APO](apo.md) - Absolute price oscillator (point-based version)
- [MACD](macd.md) - Similar momentum oscillator with histogram
- [RSI](rsi.md) - Bounded momentum oscillator
- [ROC](roc.md) - Rate of change (another percentage indicator)

## See Also

- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
- [Momentum Trading Example](../../examples/momentum-trading.md)
