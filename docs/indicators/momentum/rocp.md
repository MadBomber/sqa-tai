# Rate of Change Percentage (ROCP)

The Rate of Change Percentage (ROCP) is a momentum oscillator that measures the percentage change in price over a specified period. It is essentially identical to ROC but explicitly emphasizes its percentage-based calculation. ROCP provides a normalized view of momentum that makes it easy to compare across different securities and timeframes.

## Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41,
          46.22, 45.64, 46.21, 46.25]

# Calculate 10-period ROCP
rocp = SQA::TAI.rocp(prices, period: 10)

puts "Current ROCP: #{rocp.last.round(2)}%"
```

## Formula

ROCP = ((Price - Price[n periods ago]) / Price[n periods ago]) * 100

Where:
- Price = Current closing price
- Price[n periods ago] = Closing price n periods back
- Result is expressed as a percentage

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prices` | Array<Float> | Yes | - | Array of price values |
| `period` | Integer | No | 10 | Lookback period for comparison |

## Returns

Returns an array of ROCP values as percentages. The first `period` values will be `nil` as there is insufficient data to calculate the rate of change.

## Interpretation

| ROCP Value | Interpretation |
|------------|----------------|
| > 0% | Price rising - bullish momentum |
| 0% | No change - neutral |
| < 0% | Price falling - bearish momentum |
| > +10% | Strong upward momentum, potential overbought |
| < -10% | Strong downward momentum, potential oversold |
| Extremes (+/-20%) | Very strong momentum, possible reversal |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

### Key Concepts

- **Zero-Line Crossovers**: ROCP crossing above/below zero signals momentum shifts
- **Magnitude**: The larger the absolute value, the stronger the momentum
- **Divergence**: Price making new highs/lows while ROCP doesn't confirms trend weakness
- **Overbought/Oversold**: Extreme positive/negative values suggest potential reversals

## Example: Basic ROCP Trading Signals

```ruby
prices = load_historical_prices('AAPL')

rocp = SQA::TAI.rocp(prices, period: 10)
current_rocp = rocp.last
prev_rocp = rocp[-2]

# Zero-line crossovers
if current_rocp > 0 && prev_rocp <= 0
  puts "ROCP crossed above zero: BUY signal"
  puts "Price is #{current_rocp.round(2)}% above price 10 periods ago"
elsif current_rocp < 0 && prev_rocp >= 0
  puts "ROCP crossed below zero: SELL signal"
  puts "Price is #{current_rocp.abs.round(2)}% below price 10 periods ago"
end

# Extreme values
case current_rocp
when 15..Float::INFINITY
  puts "Strongly overbought (#{current_rocp.round(2)}%) - consider taking profits"
when -Float::INFINITY..-15
  puts "Strongly oversold (#{current_rocp.round(2)}%) - consider buying"
when -5..5
  puts "Neutral momentum (#{current_rocp.round(2)}%)"
else
  puts "Moderate momentum (#{current_rocp.round(2)}%)"
end
```

## Example: ROCP Divergence Detection

```ruby
prices = load_historical_prices('TSLA')
rocp = SQA::TAI.rocp(prices, period: 12)

# Find recent highs in price and ROCP
price_high_1 = prices[-20..-10].max
price_high_2 = prices[-9..-1].max

rocp_high_1 = rocp[-20..-10].compact.max
rocp_high_2 = rocp[-9..-1].compact.max

# Bearish divergence: price makes higher high, ROCP makes lower high
if price_high_2 > price_high_1 && rocp_high_2 < rocp_high_1
  puts "Bearish Divergence detected!"
  puts "Price higher high: #{price_high_1.round(2)} -> #{price_high_2.round(2)}"
  puts "ROCP lower high: #{rocp_high_1.round(2)}% -> #{rocp_high_2.round(2)}%"
  puts "Momentum weakening - potential reversal"
end

# Find recent lows
price_low_1 = prices[-20..-10].min
price_low_2 = prices[-9..-1].min

rocp_low_1 = rocp[-20..-10].compact.min
rocp_low_2 = rocp[-9..-1].compact.min

# Bullish divergence: price makes lower low, ROCP makes higher low
if price_low_2 < price_low_1 && rocp_low_2 > rocp_low_1
  puts "Bullish Divergence detected!"
  puts "Price lower low: #{price_low_1.round(2)} -> #{price_low_2.round(2)}"
  puts "ROCP higher low: #{rocp_low_1.round(2)}% -> #{rocp_low_2.round(2)}%"
  puts "Downward momentum slowing - potential reversal"
end
```

## Example: Multi-Timeframe ROCP Analysis

```ruby
prices = load_historical_prices('MSFT')

# Calculate multiple periods
rocp_5 = SQA::TAI.rocp(prices, period: 5)   # Short-term
rocp_10 = SQA::TAI.rocp(prices, period: 10)  # Medium-term
rocp_20 = SQA::TAI.rocp(prices, period: 20)  # Long-term

puts "5-day ROCP: #{rocp_5.last.round(2)}%"
puts "10-day ROCP: #{rocp_10.last.round(2)}%"
puts "20-day ROCP: #{rocp_20.last.round(2)}%"

# All timeframes aligned = strong signal
if rocp_5.last > 5 && rocp_10.last > 5 && rocp_20.last > 5
  puts "All timeframes showing positive momentum - strong uptrend"
  puts "Consider buying or holding long positions"
elsif rocp_5.last < -5 && rocp_10.last < -5 && rocp_20.last < -5
  puts "All timeframes showing negative momentum - strong downtrend"
  puts "Consider selling or shorting"
end

# Divergence between timeframes
if rocp_5.last > 10 && rocp_20.last < 0
  puts "Short-term surge in longer-term downtrend"
  puts "Potential short-term bounce, not trend change"
elsif rocp_5.last < -10 && rocp_20.last > 0
  puts "Short-term dip in longer-term uptrend"
  puts "Potential buying opportunity"
end

# Momentum acceleration
if rocp_5.last > rocp_10.last && rocp_10.last > rocp_20.last
  puts "Accelerating upward momentum across timeframes"
elsif rocp_5.last < rocp_10.last && rocp_10.last < rocp_20.last
  puts "Accelerating downward momentum across timeframes"
end
```

## Example: ROCP with Moving Average

```ruby
prices = load_historical_prices('NVDA')
rocp = SQA::TAI.rocp(prices, period: 10)

# Calculate moving average of ROCP to smooth it
rocp_sma = SQA::TAI.sma(rocp.compact, period: 5)

current_rocp = rocp.last
current_rocp_sma = rocp_sma.last

puts "Current ROCP: #{current_rocp.round(2)}%"
puts "ROCP 5-day average: #{current_rocp_sma.round(2)}%"

# Signal when ROCP crosses its moving average
if current_rocp > current_rocp_sma
  puts "ROCP above its average - momentum strengthening"
else
  puts "ROCP below its average - momentum weakening"
end

# Track ROCP trend
rocp_values = rocp.compact.last(5)
if rocp_values.each_cons(2).all? { |a, b| b > a }
  puts "ROCP rising for 5 periods - building momentum"
elsif rocp_values.each_cons(2).all? { |a, b| b < a }
  puts "ROCP falling for 5 periods - losing momentum"
end
```

## Example: ROCP for Multiple Securities Comparison

```ruby
# Compare momentum across different stocks
securities = ['AAPL', 'MSFT', 'GOOGL', 'AMZN']
rocp_values = {}

securities.each do |symbol|
  prices = load_historical_prices(symbol)
  rocp = SQA::TAI.rocp(prices, period: 10)
  rocp_values[symbol] = rocp.last
end

# Sort by momentum
sorted = rocp_values.sort_by { |k, v| -v }

puts "Momentum Rankings (10-day ROCP):"
sorted.each_with_index do |(symbol, rocp), index|
  puts "#{index + 1}. #{symbol}: #{rocp.round(2)}%"
end

# Identify strongest momentum
strongest = sorted.first
puts "\nStrongest momentum: #{strongest[0]} at #{strongest[1].round(2)}%"

# Identify weakest momentum
weakest = sorted.last
puts "Weakest momentum: #{weakest[0]} at #{weakest[1].round(2)}%"

# Find relative strength opportunities
avg_rocp = rocp_values.values.sum / rocp_values.size
puts "\nAverage momentum: #{avg_rocp.round(2)}%"

rocp_values.each do |symbol, rocp|
  if rocp > avg_rocp + 5
    puts "#{symbol} showing above-average strength"
  elsif rocp < avg_rocp - 5
    puts "#{symbol} showing below-average strength"
  end
end
```

## Advanced Techniques

### 1. ROCP Bands
Create overbought/oversold bands based on historical ROCP values:

```ruby
prices = load_historical_prices('SPY')
rocp = SQA::TAI.rocp(prices, period: 10)

# Calculate dynamic bands from 100-period history
rocp_history = rocp.compact.last(100)
upper_band = rocp_history.max * 0.8  # 80% of maximum
lower_band = rocp_history.min * 0.8  # 80% of minimum

current_rocp = rocp.last

if current_rocp > upper_band
  puts "ROCP above upper band (#{upper_band.round(2)}%)"
  puts "Overbought - potential reversal"
elsif current_rocp < lower_band
  puts "ROCP below lower band (#{lower_band.round(2)}%)"
  puts "Oversold - potential reversal"
end
```

### 2. ROCP Histogram
Track the rate of change of ROCP itself:

```ruby
rocp = SQA::TAI.rocp(prices, period: 10)
rocp_compact = rocp.compact

# Calculate ROCP momentum (difference between periods)
rocp_histogram = []
rocp_compact.each_cons(2) do |prev, curr|
  rocp_histogram << curr - prev
end

if rocp_histogram.last > 0
  puts "ROCP momentum increasing (#{rocp_histogram.last.round(2)}%)"
  puts "Acceleration phase"
else
  puts "ROCP momentum decreasing (#{rocp_histogram.last.round(2)}%)"
  puts "Deceleration phase"
end
```

### 3. Volatility-Adjusted ROCP
Normalize ROCP by volatility for better comparison:

```ruby
prices = load_historical_prices('BTC-USD')
rocp = SQA::TAI.rocp(prices, period: 10)

# Calculate standard deviation (simple volatility measure)
rocp_compact = rocp.compact.last(20)
mean = rocp_compact.sum / rocp_compact.size
variance = rocp_compact.map { |x| (x - mean) ** 2 }.sum / rocp_compact.size
std_dev = Math.sqrt(variance)

# Volatility-adjusted ROCP (like a z-score)
adjusted_rocp = (rocp.last - mean) / std_dev

puts "Raw ROCP: #{rocp.last.round(2)}%"
puts "Volatility (std dev): #{std_dev.round(2)}%"
puts "Adjusted ROCP: #{adjusted_rocp.round(2)} standard deviations"

if adjusted_rocp > 2
  puts "Unusually strong momentum (>2 std dev)"
elsif adjusted_rocp < -2
  puts "Unusually weak momentum (<-2 std dev)"
end
```

### 4. Sector Rotation with ROCP
Use ROCP to identify sector rotation:

```ruby
sectors = {
  'Technology' => 'XLK',
  'Finance' => 'XLF',
  'Healthcare' => 'XLV',
  'Energy' => 'XLE',
  'Consumer' => 'XLY'
}

sector_momentum = {}

sectors.each do |name, etf|
  prices = load_historical_prices(etf)
  rocp = SQA::TAI.rocp(prices, period: 20)
  sector_momentum[name] = rocp.last
end

# Identify rotating capital
sorted = sector_momentum.sort_by { |k, v| -v }

puts "Sector Momentum (20-day ROCP):"
sorted.each do |sector, rocp|
  strength = case rocp
    when 10..Float::INFINITY then "Very Strong"
    when 5..10 then "Strong"
    when -5..5 then "Neutral"
    when -10..-5 then "Weak"
    else "Very Weak"
  end

  puts "#{sector}: #{rocp.round(2)}% - #{strength}"
end

puts "\nCapital flowing INTO: #{sorted.first[0]}"
puts "Capital flowing OUT OF: #{sorted.last[0]}"
```

## Example: ROCP Mean Reversion Strategy

```ruby
prices = load_historical_prices('QQQ')
rocp = SQA::TAI.rocp(prices, period: 10)

# Calculate mean and standard deviation
rocp_history = rocp.compact.last(100)
mean_rocp = rocp_history.sum / rocp_history.size
std_dev = Math.sqrt(
  rocp_history.map { |x| (x - mean_rocp) ** 2 }.sum / rocp_history.size
)

current_rocp = rocp.last
z_score = (current_rocp - mean_rocp) / std_dev

puts "Mean ROCP: #{mean_rocp.round(2)}%"
puts "Current ROCP: #{current_rocp.round(2)}%"
puts "Z-Score: #{z_score.round(2)}"

# Mean reversion signals
if z_score < -2
  puts "ROCP 2+ std dev below mean"
  puts "Extreme oversold - mean reversion BUY"
  puts "Expected return to #{mean_rocp.round(2)}%"
elsif z_score > 2
  puts "ROCP 2+ std dev above mean"
  puts "Extreme overbought - mean reversion SELL"
  puts "Expected return to #{mean_rocp.round(2)}%"
elsif z_score.abs < 0.5
  puts "ROCP near mean - no clear signal"
end

# Calculate potential price targets based on mean reversion
current_price = prices.last
if z_score < -2
  # If ROCP returns to mean, price would be:
  expected_rocp = mean_rocp
  target_price = current_price * (1 + expected_rocp/100) / (1 + current_rocp/100)
  puts "Price target if ROCP reverts to mean: #{target_price.round(2)}"
  puts "Potential gain: #{((target_price - current_price) / current_price * 100).round(2)}%"
end
```

## Example: ROCP with Volume Confirmation

```ruby
prices = load_historical_prices('AAPL')
volumes = load_historical_volumes('AAPL')

rocp = SQA::TAI.rocp(prices, period: 10)

# Calculate volume rate of change
volume_rocp = SQA::TAI.rocp(volumes, period: 10)

current_rocp = rocp.last
current_vol_rocp = volume_rocp.last

puts "Price ROCP: #{current_rocp.round(2)}%"
puts "Volume ROCP: #{current_vol_rocp.round(2)}%"

# Strong signals when both align
if current_rocp > 5 && current_vol_rocp > 10
  puts "Price rising with expanding volume - strong BUY"
  puts "Momentum confirmed by volume"
elsif current_rocp < -5 && current_vol_rocp > 10
  puts "Price falling with expanding volume - strong SELL"
  puts "Downward momentum confirmed"
elsif current_rocp > 5 && current_vol_rocp < -10
  puts "Price rising but volume declining - weak signal"
  puts "Caution: Momentum not confirmed"
elsif current_rocp < -5 && current_vol_rocp < -10
  puts "Price falling but volume declining - weak signal"
  puts "Downward momentum may be exhausting"
end
```

## Common Settings

| Period | Use Case | Typical Range |
|--------|----------|---------------|
| 5 | Day trading, short-term momentum | -15% to +15% |
| 9-10 | Short-term trading (most common) | -12% to +12% |
| 12-14 | Standard trading | -10% to +10% |
| 20-25 | Swing trading, longer-term | -8% to +8% |
| 50 | Position trading, major trends | -5% to +5% |

## Interpretation Guidelines by Period

### Short-term (5-10 days)
- Extreme: +/-15%
- Strong: +/-10%
- Moderate: +/-5%
- Neutral: +/-2%

### Medium-term (10-20 days)
- Extreme: +/-12%
- Strong: +/-8%
- Moderate: +/-4%
- Neutral: +/-2%

### Long-term (20+ days)
- Extreme: +/-8%
- Strong: +/-5%
- Moderate: +/-3%
- Neutral: +/-1%

## Strengths and Limitations

### Strengths
- Easy to interpret (percentage-based)
- Comparable across securities
- Unbounded (can capture extreme moves)
- Leading indicator (anticipates trend changes)
- Simple calculation

### Limitations
- Can remain overbought/oversold for extended periods
- No fixed boundaries (unlike RSI 0-100)
- Sensitive to price spikes/gaps
- Requires context for interpretation
- Lagging by design (lookback period)

## Tips for Using ROCP

1. **Use with confirmation**: Combine with volume, trend indicators, or support/resistance
2. **Adjust period to timeframe**: Shorter periods for day trading, longer for swing trading
3. **Watch divergence**: More reliable than absolute levels
4. **Consider volatility**: High-volatility stocks have wider typical ranges
5. **Multiple timeframes**: Confirm signals across different periods
6. **Relative strength**: Compare ROCP across securities for relative momentum
7. **Mean reversion**: Calculate historical mean for context
8. **Zero-line**: Crossing zero is often more significant than extreme values

## Related Indicators

- [ROC](roc.md) - Rate of Change (identical calculation)
- [ROCR](rocr.md) - Rate of Change Ratio (ratio format)
- [ROCR100](rocr100.md) - Rate of Change Ratio 100 Scale
- [MOM](mom.md) - Momentum (absolute change)
- [RSI](rsi.md) - Relative Strength Index (bounded 0-100)

## See Also

- [Back to Indicators](../index.md)
- [Momentum Indicators Overview](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
