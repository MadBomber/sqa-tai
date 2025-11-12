# Rate of Change Ratio (ROCR)

The Rate of Change Ratio (ROCR) is a momentum indicator that measures price changes as a ratio rather than a percentage. It calculates the ratio of the current price to the price n periods ago, making it centered around 1.0. Values above 1.0 indicate rising prices, while values below 1.0 indicate falling prices. This ratio-based approach provides a different perspective from percentage-based indicators like ROCP, making it particularly useful for comparing momentum across different price levels and securities.

## Usage

```ruby
require 'sqa/tai'

prices = [100.0, 102.0, 104.0, 103.0, 105.0, 107.0,
          106.0, 108.0, 110.0, 109.0, 111.0, 113.0,
          112.0, 114.0, 116.0, 115.0, 117.0, 119.0]

# Calculate 10-period ROCR
rocr = SQA::TAI.rocr(prices, period: 10)

puts "Current ROCR: #{rocr.last.round(4)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prices` | Array | Yes | - | Array of price values |
| `period` | Integer | No | 10 | Number of periods for calculation |

## Returns

Returns an array of ROCR values typically ranging from 0.8 to 1.2 (representing 80% to 120% price ratios). The first `period` values will be `nil`.

## Interpretation

| ROCR Value | Interpretation |
|------------|----------------|
| > 1.10 | Strong upward momentum (10%+ gain) |
| 1.05-1.10 | Moderate upward momentum (5-10% gain) |
| 1.00-1.05 | Slight upward momentum (0-5% gain) |
| 1.00 | No change - neutral momentum |
| 0.95-1.00 | Slight downward momentum (0-5% loss) |
| 0.90-0.95 | Moderate downward momentum (5-10% loss) |
| < 0.90 | Strong downward momentum (10%+ loss) |

## Formula

```
ROCR = Current Price / Price[n periods ago]

Where:
- Current Price = Latest closing price
- Price[n periods ago] = Closing price n periods back
- Centered at 1.0 (no change)
- > 1.0 indicates price increase
- < 1.0 indicates price decrease
```

## Example: Basic ROCR Trading Signals

```ruby
prices = load_historical_data('AAPL')

rocr_10 = SQA::TAI.rocr(prices, period: 10)
current_rocr = rocr_10.last

case current_rocr
when 0...0.90
  puts "ROCR below 0.90 (#{current_rocr.round(4)}) - Oversold"
  puts "Price down >10% from 10 periods ago - Potential BUY"
when 1.10..Float::INFINITY
  puts "ROCR above 1.10 (#{current_rocr.round(4)}) - Overbought"
  puts "Price up >10% from 10 periods ago - Potential SELL"
when 0.95...1.05
  puts "ROCR neutral (#{current_rocr.round(4)}) - Range-bound"
  puts "Price relatively unchanged"
else
  puts "ROCR at #{current_rocr.round(4)}"
end

# Calculate actual percentage change
percentage_change = ((current_rocr - 1.0) * 100).round(2)
puts "Percentage change: #{percentage_change}%"

# Trend direction
if current_rocr > 1.0
  puts "Bullish momentum - price rising"
elsif current_rocr < 1.0
  puts "Bearish momentum - price falling"
else
  puts "Neutral - no momentum"
end
```

## Example: ROCR Crossover Strategy

```ruby
prices = load_historical_data('TSLA')

rocr = SQA::TAI.rocr(prices, period: 10)

# Track crossovers of the 1.0 line (neutral)
current_rocr = rocr.last
prev_rocr = rocr[-2]
older_rocr = rocr[-3]

# Bullish crossover - ROCR crosses above 1.0
if current_rocr > 1.0 && prev_rocr <= 1.0
  puts "Bullish Crossover!"
  puts "ROCR crossed above 1.0: #{prev_rocr.round(4)} -> #{current_rocr.round(4)}"
  puts "Momentum turning positive - BUY signal"

  # Calculate momentum strength
  momentum_strength = ((current_rocr - 1.0) * 100).round(2)
  puts "Current momentum: +#{momentum_strength}%"
end

# Bearish crossover - ROCR crosses below 1.0
if current_rocr < 1.0 && prev_rocr >= 1.0
  puts "Bearish Crossover!"
  puts "ROCR crossed below 1.0: #{prev_rocr.round(4)} -> #{current_rocr.round(4)}"
  puts "Momentum turning negative - SELL signal"

  momentum_strength = ((1.0 - current_rocr) * 100).round(2)
  puts "Current momentum: -#{momentum_strength}%"
end

# Momentum acceleration
if current_rocr > prev_rocr && prev_rocr > older_rocr
  puts "Accelerating upward momentum"
elsif current_rocr < prev_rocr && prev_rocr < older_rocr
  puts "Accelerating downward momentum"
end
```

## Example: ROCR vs ROCP Comparison

```ruby
prices = load_historical_data('MSFT')

# Calculate both ratio and percentage
rocr = SQA::TAI.rocr(prices, period: 10)
rocp = SQA::TAI.rocp(prices, period: 10)

current_rocr = rocr.last
current_rocp = rocp.last

puts "ROCR: #{current_rocr.round(4)}"
puts "ROCP: #{current_rocp.round(2)}%"

# Convert between formats
rocp_from_rocr = ((current_rocr - 1.0) * 100).round(2)
rocr_from_rocp = (1.0 + current_rocp / 100.0).round(4)

puts "\nConversions:"
puts "ROCR #{current_rocr.round(4)} = #{rocp_from_rocr}% (ROCP equivalent)"
puts "ROCP #{current_rocp.round(2)}% = #{rocr_from_rocp} (ROCR equivalent)"

# Key differences
puts <<~ANALYSIS

  Key Differences:
  ================

  ROCR (Ratio):
  - Value: #{current_rocr.round(4)}
  - Centered at: 1.0
  - Range: Typically 0.8 to 1.2
  - Format: Ratio/multiplier
  - Interpretation: Price is #{current_rocr.round(4)}x the price 10 periods ago

  ROCP (Percentage):
  - Value: #{current_rocp.round(2)}%
  - Centered at: 0.0
  - Range: Typically -20% to +20%
  - Format: Percentage
  - Interpretation: Price changed #{current_rocp.round(2)}% over 10 periods

  When to use ROCR:
  - Comparing momentum across different price levels
  - Ratio-based trading systems
  - Log-scale analysis
  - Multiplicative comparisons

  When to use ROCP:
  - Intuitive percentage understanding
  - Additive comparisons
  - Standard momentum analysis
ANALYSIS
```

## Example: Multi-Period ROCR Analysis

```ruby
prices = load_historical_data('NVDA')

# Calculate multiple periods
rocr_5 = SQA::TAI.rocr(prices, period: 5)
rocr_10 = SQA::TAI.rocr(prices, period: 10)
rocr_20 = SQA::TAI.rocr(prices, period: 20)

# Convert to percentage for easier reading
pct_5 = ((rocr_5.last - 1.0) * 100).round(2)
pct_10 = ((rocr_10.last - 1.0) * 100).round(2)
pct_20 = ((rocr_20.last - 1.0) * 100).round(2)

puts "5-period ROCR: #{rocr_5.last.round(4)} (#{pct_5}%)"
puts "10-period ROCR: #{rocr_10.last.round(4)} (#{pct_10}%)"
puts "20-period ROCR: #{rocr_20.last.round(4)} (#{pct_20}%)"

# Momentum consistency
if rocr_5.last > 1.0 && rocr_10.last > 1.0 && rocr_20.last > 1.0
  puts "\nConsistent upward momentum across all timeframes"
  puts "Strong bullish trend confirmed"

  # Check for acceleration
  if pct_5 > pct_10 && pct_10 > pct_20
    puts "Momentum accelerating (short-term strongest)"
  elsif pct_5 < pct_10 && pct_10 < pct_20
    puts "Momentum decelerating (long-term strongest)"
  end

elsif rocr_5.last < 1.0 && rocr_10.last < 1.0 && rocr_20.last < 1.0
  puts "\nConsistent downward momentum across all timeframes"
  puts "Strong bearish trend confirmed"

  if pct_5 < pct_10 && pct_10 < pct_20
    puts "Momentum accelerating downward"
  elsif pct_5 > pct_10 && pct_10 > pct_20
    puts "Momentum slowing (potential bottoming)"
  end

else
  puts "\nMixed momentum signals"

  # Potential reversal signals
  if rocr_5.last > 1.0 && rocr_20.last < 1.0
    puts "Short-term bullish but long-term bearish"
    puts "Possible bounce in downtrend"
  elsif rocr_5.last < 1.0 && rocr_20.last > 1.0
    puts "Short-term bearish but long-term bullish"
    puts "Possible pullback in uptrend - BUY opportunity"
  end
end
```

## Example: ROCR Trend Strength Analysis

```ruby
prices = load_historical_data('SPY')

rocr = SQA::TAI.rocr(prices, period: 10)

# Analyze recent ROCR values
recent_rocr = rocr.last(20).compact

# Calculate ROCR statistics
avg_rocr = recent_rocr.sum / recent_rocr.size
max_rocr = recent_rocr.max
min_rocr = recent_rocr.min
current_rocr = recent_rocr.last

puts "ROCR Statistics (Last 20 periods):"
puts "Average: #{avg_rocr.round(4)}"
puts "Max: #{max_rocr.round(4)}"
puts "Min: #{min_rocr.round(4)}"
puts "Current: #{current_rocr.round(4)}"

# Trend strength based on ROCR consistency
above_one = recent_rocr.count { |r| r > 1.0 }
below_one = recent_rocr.count { |r| r < 1.0 }

puts "\nTrend Consistency:"
puts "Periods above 1.0: #{above_one}/20 (#{(above_one/20.0*100).round(1)}%)"
puts "Periods below 1.0: #{below_one}/20 (#{(below_one/20.0*100).round(1)}%)"

case above_one
when 16..20
  puts "Very strong uptrend"
when 12..15
  puts "Strong uptrend"
when 8..11
  puts "Weak uptrend"
when 5..7
  puts "Neutral/choppy"
when 0..4
  puts "Downtrend"
end

# Volatility analysis
rocr_range = max_rocr - min_rocr
puts "\nROCR range: #{rocr_range.round(4)} (#{(rocr_range * 100).round(2)}% volatility)"

if rocr_range > 0.20
  puts "High momentum volatility - trending market"
elsif rocr_range < 0.10
  puts "Low momentum volatility - range-bound market"
end
```

## Example: ROCR Divergence Detection

```ruby
prices = load_historical_data('AAPL')

rocr = SQA::TAI.rocr(prices, period: 10)

# Find recent highs in price and ROCR
price_high_1_idx = prices[-30..-16].each_with_index.max_by { |p, i| p }[1] + prices.size - 30
price_high_2_idx = prices[-15..-1].each_with_index.max_by { |p, i| p }[1] + prices.size - 15

price_high_1 = prices[price_high_1_idx]
price_high_2 = prices[price_high_2_idx]

rocr_high_1 = rocr[price_high_1_idx]
rocr_high_2 = rocr[price_high_2_idx]

# Bearish divergence: price makes higher high, ROCR makes lower high
if price_high_2 > price_high_1 && rocr_high_2 < rocr_high_1
  puts "Bearish Divergence Detected!"
  puts "\nPrice Action:"
  puts "  Previous high: $#{price_high_1.round(2)}"
  puts "  Current high:  $#{price_high_2.round(2)} (+#{((price_high_2/price_high_1 - 1)*100).round(2)}%)"

  puts "\nROCR Action:"
  puts "  Previous high: #{rocr_high_1.round(4)}"
  puts "  Current high:  #{rocr_high_2.round(4)} (#{((rocr_high_2/rocr_high_1 - 1)*100).round(2)}%)"

  puts "\nInterpretation:"
  puts "Price making new highs but momentum weakening"
  puts "Uptrend may be losing strength - potential reversal"
end

# Bullish divergence: price makes lower low, ROCR makes higher low
price_low_1_idx = prices[-30..-16].each_with_index.min_by { |p, i| p }[1] + prices.size - 30
price_low_2_idx = prices[-15..-1].each_with_index.min_by { |p, i| p }[1] + prices.size - 15

price_low_1 = prices[price_low_1_idx]
price_low_2 = prices[price_low_2_idx]

rocr_low_1 = rocr[price_low_1_idx]
rocr_low_2 = rocr[price_low_2_idx]

if price_low_2 < price_low_1 && rocr_low_2 > rocr_low_1
  puts "Bullish Divergence Detected!"
  puts "\nPrice Action:"
  puts "  Previous low: $#{price_low_1.round(2)}"
  puts "  Current low:  $#{price_low_2.round(2)} (#{((price_low_2/price_low_1 - 1)*100).round(2)}%)"

  puts "\nROCR Action:"
  puts "  Previous low: #{rocr_low_1.round(4)}"
  puts "  Current low:  #{rocr_low_2.round(4)} (+#{((rocr_low_2/rocr_low_1 - 1)*100).round(2)}%)"

  puts "\nInterpretation:"
  puts "Price making new lows but momentum improving"
  puts "Downtrend may be losing strength - potential reversal"
end
```

## Example: ROCR Momentum Comparison

```ruby
# Compare momentum across different securities
prices_aapl = load_historical_data('AAPL')
prices_msft = load_historical_data('MSFT')
prices_googl = load_historical_data('GOOGL')

rocr_aapl = SQA::TAI.rocr(prices_aapl, period: 10)
rocr_msft = SQA::TAI.rocr(prices_msft, period: 10)
rocr_googl = SQA::TAI.rocr(prices_googl, period: 10)

stocks = {
  'AAPL'  => { rocr: rocr_aapl.last, price: prices_aapl.last },
  'MSFT'  => { rocr: rocr_msft.last, price: prices_msft.last },
  'GOOGL' => { rocr: rocr_googl.last, price: prices_googl.last }
}

puts "10-Period Momentum Comparison:"
puts "=" * 60

sorted_stocks = stocks.sort_by { |name, data| -data[:rocr] }

sorted_stocks.each_with_index do |(name, data), index|
  pct_change = ((data[:rocr] - 1.0) * 100).round(2)

  puts "\n#{index + 1}. #{name}"
  puts "   ROCR: #{data[:rocr].round(4)}"
  puts "   Change: #{pct_change}%"
  puts "   Price: $#{data[:price].round(2)}"

  case data[:rocr]
  when 1.10..Float::INFINITY
    puts "   Status: Strong momentum"
  when 1.05...1.10
    puts "   Status: Moderate momentum"
  when 1.00...1.05
    puts "   Status: Slight momentum"
  when 0.95...1.00
    puts "   Status: Slight weakness"
  when 0.90...0.95
    puts "   Status: Moderate weakness"
  else
    puts "   Status: Strong weakness"
  end
end

# Trading recommendation
best_stock = sorted_stocks.first
worst_stock = sorted_stocks.last

puts <<~SUMMARY

  Trading Summary:
  ================

  Strongest: #{best_stock[0]} with ROCR of #{best_stock[1][:rocr].round(4)}
  Weakest: #{worst_stock[0]} with ROCR of #{worst_stock[1][:rocr].round(4)}

  ROCR is ideal for cross-asset momentum comparison because:
  - Ratio format normalizes across different price levels
  - Easy to compare stocks at $10 vs $1000
  - Clear threshold at 1.0 for positive/negative momentum
SUMMARY
```

## Advanced Techniques

### 1. Ratio-Based Position Sizing
Use ROCR values to dynamically size positions:
- ROCR 1.10+ = Reduce position (strong momentum may reverse)
- ROCR 0.90- = Increase position (oversold, potential bounce)
- ROCR near 1.0 = Standard position size

### 2. Log-Scale Analysis
ROCR is natural for log-scale charts:
- log(ROCR) = log(price_now) - log(price_then)
- Useful for long-term trend analysis
- Equal percentage moves appear equal on log scale

### 3. Momentum Bands
Create dynamic bands around 1.0:
- Upper band: 1.0 + (2 * ROCR_std_dev)
- Lower band: 1.0 - (2 * ROCR_std_dev)
- Extreme values signal reversals

### 4. ROCR Rate of Change
Calculate the rate of change of ROCR itself:
- ROCR_ROC = Current_ROCR / Previous_ROCR
- Measures momentum acceleration
- Values > 1.0 = accelerating momentum

## Example: Advanced ROCR Trading System

```ruby
prices = load_historical_data('QQQ')

# Multiple period ROCR
rocr_5 = SQA::TAI.rocr(prices, period: 5)
rocr_10 = SQA::TAI.rocr(prices, period: 10)
rocr_20 = SQA::TAI.rocr(prices, period: 20)

current_price = prices.last
current_rocr_5 = rocr_5.last
current_rocr_10 = rocr_10.last
current_rocr_20 = rocr_20.last

# Calculate ROCR momentum acceleration
rocr_momentum = current_rocr_5 / rocr_5[-2] if rocr_5[-2] && rocr_5[-2] != 0

puts "Advanced ROCR Analysis:"
puts "=" * 60

puts "\nCurrent Price: $#{current_price.round(2)}"
puts "\nMomentum Ratios:"
puts "5-period ROCR:  #{current_rocr_5.round(4)} (#{((current_rocr_5 - 1.0)*100).round(2)}%)"
puts "10-period ROCR: #{current_rocr_10.round(4)} (#{((current_rocr_10 - 1.0)*100).round(2)}%)"
puts "20-period ROCR: #{current_rocr_20.round(4)} (#{((current_rocr_20 - 1.0)*100).round(2)}%)"

if rocr_momentum
  puts "\nMomentum Acceleration: #{rocr_momentum.round(4)}"
  if rocr_momentum > 1.02
    puts "Momentum accelerating strongly"
  elsif rocr_momentum < 0.98
    puts "Momentum decelerating rapidly"
  end
end

# Trading signals with confidence levels
signals = []

# Signal 1: All periods aligned
if current_rocr_5 > 1.05 && current_rocr_10 > 1.05 && current_rocr_20 > 1.05
  signals << { type: 'SELL', confidence: 'HIGH', reason: 'All periods overbought' }
elsif current_rocr_5 < 0.95 && current_rocr_10 < 0.95 && current_rocr_20 < 0.95
  signals << { type: 'BUY', confidence: 'HIGH', reason: 'All periods oversold' }
end

# Signal 2: Short-term reversal in long-term trend
if current_rocr_5 < 0.95 && current_rocr_20 > 1.0
  signals << { type: 'BUY', confidence: 'MEDIUM', reason: 'Short-term pullback in uptrend' }
elsif current_rocr_5 > 1.05 && current_rocr_20 < 1.0
  signals << { type: 'SELL', confidence: 'MEDIUM', reason: 'Short-term bounce in downtrend' }
end

# Signal 3: Crossover of 1.0
if current_rocr_10 > 1.0 && rocr_10[-2] <= 1.0
  signals << { type: 'BUY', confidence: 'MEDIUM', reason: '10-period crossed above 1.0' }
elsif current_rocr_10 < 1.0 && rocr_10[-2] >= 1.0
  signals << { type: 'SELL', confidence: 'MEDIUM', reason: '10-period crossed below 1.0' }
end

# Display signals
if signals.any?
  puts "\nTrading Signals:"
  signals.each_with_index do |signal, i|
    puts "\n#{i+1}. #{signal[:type]} Signal (#{signal[:confidence]} confidence)"
    puts "   Reason: #{signal[:reason]}"
  end
else
  puts "\nNo clear signals - market neutral"
end

# Position sizing recommendation
avg_rocr = (current_rocr_5 + current_rocr_10 + current_rocr_20) / 3
position_multiplier = case avg_rocr
                      when 1.10..Float::INFINITY then 0.5
                      when 1.05...1.10 then 0.75
                      when 0.95...1.05 then 1.0
                      when 0.90...0.95 then 1.25
                      else 1.5
                      end

puts "\nPosition Sizing:"
puts "Average ROCR: #{avg_rocr.round(4)}"
puts "Position multiplier: #{position_multiplier}x"
puts "Recommendation: Use #{(position_multiplier * 100).round(0)}% of standard position size"
```

## Common Settings

| Period | Use Case |
|--------|----------|
| 5 | Short-term momentum, day trading |
| 10 | Standard setting (most common) |
| 12 | Monthly trading (business days) |
| 20 | Swing trading (1 month) |
| 50 | Position trading (2-3 months) |

## ROCR vs ROCP: Key Differences

| Feature | ROCR | ROCP |
|---------|------|------|
| Format | Ratio (multiplier) | Percentage |
| Center Point | 1.0 | 0.0 |
| Typical Range | 0.8 to 1.2 | -20% to +20% |
| Formula | price / price[n] | (price - price[n]) / price[n] * 100 |
| Interpretation | Multiplicative | Additive |
| Best For | Cross-security comparison | Single security analysis |
| Visual Scale | Log-friendly | Linear |
| Calculation | Division | Percentage change |

### Conversion Formulas
```ruby
# Convert ROCR to ROCP
rocp = (rocr - 1.0) * 100

# Convert ROCP to ROCR
rocr = 1.0 + (rocp / 100.0)

# Examples:
# ROCR 1.10 = 10% ROCP
# ROCR 0.90 = -10% ROCP
# ROCR 1.00 = 0% ROCP
```

## Common Pitfalls

1. **Zero or Negative Prices**: ROCR fails with zero/negative prices (division issues)
   - Solution: Use ROCP for such cases or check data validity

2. **Confusing Interpretation**: ROCR 1.10 means 10% gain, not 110%
   - Remember: ROCR = ratio, subtract 1.0 to get percentage

3. **Scale Differences**: ROCR appears smaller in magnitude than ROCP
   - ROCR 1.05 = 5% gain (looks like 1% to beginners)
   - Always convert for clear percentage understanding

4. **Period Selection**: Wrong period misses momentum
   - Test multiple periods for your timeframe
   - Shorter periods = more sensitive, more noise

## Related Indicators

- [ROCP](rocp.md) - Rate of Change Percentage (companion indicator)
- [MOM](mom.md) - Momentum (absolute price change)
- [RSI](rsi.md) - Relative Strength Index
- [ROC](roc.md) - Generic Rate of Change

## See Also

- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
- [Momentum Trading Examples](../../examples/momentum-trading.md)
