# Midpoint Price (MIDPRICE)

The Midpoint Price (MIDPRICE) indicator calculates the average of the highest high and lowest low over a specified period. It represents the midpoint of the recent price range and serves as a dynamic equilibrium level for the asset.

Unlike MIDPOINT which uses a single price series, MIDPRICE specifically uses the high and low prices to define the range boundaries, making it particularly useful for identifying the center of trading ranges and potential support/resistance levels.

## Usage

```ruby
require 'sqa/tai'

# OHLC data required
high = [50.5, 51.2, 52.1, 51.8, 52.5, 53.0, 52.8, 53.5, 54.2, 53.8,
        54.5, 55.0, 54.7, 55.5, 56.2]
low  = [48.5, 49.0, 50.2, 49.8, 50.5, 51.2, 50.8, 52.0, 52.5, 52.2,
        53.0, 53.5, 53.2, 54.0, 54.5]

# Calculate 14-period MIDPRICE
midprice = SQA::TAI.midprice(high, low, period: 14)

puts "Current MIDPRICE: #{midprice.last.round(2)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `high` | Array<Float> | Yes | - | Array of high prices |
| `low` | Array<Float> | Yes | - | Array of low prices |
| `period` | Integer | No | 14 | Number of periods for calculation |

## Returns

Returns an array of MIDPRICE values. The first `period - 1` values will be `nil`.

## Formula

```
MIDPRICE = (Highest High + Lowest Low) / 2

Where:
  Highest High = Maximum high over the period
  Lowest Low = Minimum low over the period
```

## Interpretation

The MIDPRICE indicator provides several key insights:

- **Range Center**: Represents the equilibrium point of the recent price range
- **Price Above MIDPRICE**: Indicates price is in the upper half of the range (bullish bias)
- **Price Below MIDPRICE**: Indicates price is in the lower half of the range (bearish bias)
- **Price at MIDPRICE**: Suggests a balanced market with no clear directional bias
- **Dynamic Support/Resistance**: Acts as a pivot point within the range
- **Mean Reversion**: Price tends to gravitate toward the MIDPRICE in ranging markets

### Trading Signals

- **Buy Signal**: Price bounces from below when approaching MIDPRICE in uptrend
- **Sell Signal**: Price rejects from above when approaching MIDPRICE in downtrend
- **Range Trading**: Buy near range lows, sell near range highs, with MIDPRICE as pivot
- **Breakout**: Strong move through MIDPRICE may signal trend continuation

## Example: Range Trading with MIDPRICE

```ruby
high, low, close = load_ohlc_data('AAPL')

midprice = SQA::TAI.midprice(high, low, period: 14)
current_price = close.last
current_midprice = midprice.last

# Calculate range boundaries
lookback = 14
highest_high = high[-lookback..-1].max
lowest_low = low[-lookback..-1].min
range_size = highest_high - lowest_low

# Determine position within range
position_in_range = (current_price - lowest_low) / range_size * 100

puts "Current Price: $#{current_price.round(2)}"
puts "MIDPRICE: $#{current_midprice.round(2)}"
puts "Range: $#{lowest_low.round(2)} - $#{highest_high.round(2)}"
puts "Position in Range: #{position_in_range.round(1)}%"

# Trading zones
if position_in_range < 30
  puts "Status: Lower third of range (potential BUY zone)"
elsif position_in_range > 70
  puts "Status: Upper third of range (potential SELL zone)"
else
  puts "Status: Middle of range (WAIT for better position)"
end

# Check relationship to MIDPRICE
if current_price > current_midprice
  distance = ((current_price / current_midprice - 1) * 100).round(2)
  puts "Price #{distance}% above MIDPRICE (bullish bias)"
else
  distance = ((1 - current_price / current_midprice) * 100).round(2)
  puts "Price #{distance}% below MIDPRICE (bearish bias)"
end
```

## Example: MIDPRICE Mean Reversion Strategy

```ruby
high, low, close = load_ohlc_data('MSFT')

midprice = SQA::TAI.midprice(high, low, period: 20)
atr = SQA::TAI.atr(high, low, close, period: 14)

current_price = close.last
current_midprice = midprice.last
current_atr = atr.last

# Calculate distance from MIDPRICE in ATR units
distance_atr = (current_price - current_midprice) / current_atr

puts "Current Price: $#{current_price.round(2)}"
puts "MIDPRICE: $#{current_midprice.round(2)}"
puts "Distance: #{distance_atr.round(2)} ATR"

# Mean reversion signals
if distance_atr < -1.5
  puts "\nMEAN REVERSION BUY SIGNAL"
  puts "Price significantly below MIDPRICE"
  entry = current_price
  target = current_midprice
  stop = current_price - (0.5 * current_atr)
  puts "Entry: $#{entry.round(2)}"
  puts "Target (MIDPRICE): $#{target.round(2)}"
  puts "Stop: $#{stop.round(2)}"
  puts "Potential Gain: $#{(target - entry).round(2)}"
elsif distance_atr > 1.5
  puts "\nMEAN REVERSION SELL SIGNAL"
  puts "Price significantly above MIDPRICE"
  entry = current_price
  target = current_midprice
  stop = current_price + (0.5 * current_atr)
  puts "Entry: $#{entry.round(2)}"
  puts "Target (MIDPRICE): $#{target.round(2)}"
  puts "Stop: $#{stop.round(2)}"
  puts "Potential Gain: $#{(entry - target).round(2)}"
else
  puts "\nPrice within normal range of MIDPRICE - NO SIGNAL"
end
```

## Example: MIDPRICE Breakout Detection

```ruby
high, low, close = load_ohlc_data('TSLA')

# Multiple timeframe MIDPRICE
midprice_short = SQA::TAI.midprice(high, low, period: 10)
midprice_medium = SQA::TAI.midprice(high, low, period: 20)
midprice_long = SQA::TAI.midprice(high, low, period: 50)

current_price = close.last

# Check alignment
short_mp = midprice_short.last
medium_mp = midprice_medium.last
long_mp = midprice_long.last

puts "Current Price: $#{current_price.round(2)}"
puts "10-period MIDPRICE: $#{short_mp.round(2)}"
puts "20-period MIDPRICE: $#{medium_mp.round(2)}"
puts "50-period MIDPRICE: $#{long_mp.round(2)}"

# Trend detection through MIDPRICE alignment
if short_mp > medium_mp && medium_mp > long_mp && current_price > short_mp
  puts "\nSTRONG BULLISH SETUP"
  puts "All MIDPRICE levels aligned upward"
  puts "Price above short-term MIDPRICE"
  puts "Consider long positions on pullbacks to MIDPRICE"
elsif short_mp < medium_mp && medium_mp < long_mp && current_price < short_mp
  puts "\nSTRONG BEARISH SETUP"
  puts "All MIDPRICE levels aligned downward"
  puts "Price below short-term MIDPRICE"
  puts "Consider short positions on rallies to MIDPRICE"
else
  puts "\nRANGING MARKET"
  puts "MIDPRICE levels not aligned"
  puts "Use mean reversion strategies"
end
```

## Example: MIDPRICE Support and Resistance

```ruby
high, low, close = load_ohlc_data('NVDA')

midprice = SQA::TAI.midprice(high, low, period: 20)

# Track MIDPRICE touches
touches = []
lookback = 50

(lookback..close.length-1).each do |i|
  next if midprice[i].nil?

  # Check if price touched MIDPRICE (within 0.5%)
  mp = midprice[i]
  tolerance = mp * 0.005

  if (low[i] - tolerance <= mp) && (high[i] + tolerance >= mp)
    # Determine if it acted as support or resistance
    prior_close = close[i-1]
    current_close = close[i]

    if prior_close < mp && current_close > mp
      touches << { index: i, type: 'support', price: mp }
    elsif prior_close > mp && current_close < mp
      touches << { index: i, type: 'resistance', price: mp }
    end
  end
end

puts "MIDPRICE Touch Analysis (last #{lookback} periods):"
puts "Total touches: #{touches.length}"
puts "Support touches: #{touches.count { |t| t[:type] == 'support' }}"
puts "Resistance touches: #{touches.count { |t| t[:type] == 'resistance' }}"

# Recent behavior
recent_touches = touches.last(5)
puts "\nRecent MIDPRICE interactions:"
recent_touches.each do |touch|
  puts "Period #{touch[:index]}: #{touch[:type].upcase} at $#{touch[:price].round(2)}"
end

# Current status
current_mp = midprice.last
current_price = close.last
if current_price > current_mp
  puts "\nCurrent: Price trading above MIDPRICE ($#{current_mp.round(2)})"
  puts "Watch MIDPRICE as potential support on pullback"
else
  puts "\nCurrent: Price trading below MIDPRICE ($#{current_mp.round(2)})"
  puts "Watch MIDPRICE as potential resistance on rally"
end
```

## Example: Range Contraction/Expansion

```ruby
high, low, close = load_ohlc_data('SPY')

period = 20
midprice = SQA::TAI.midprice(high, low, period: period)

# Calculate range size over time
range_sizes = high.each_with_index.map do |h, i|
  next nil if i < period - 1

  lookback_high = high[(i-period+1)..i]
  lookback_low = low[(i-period+1)..i]

  lookback_high.max - lookback_low.min
end

# Find average range
avg_range = range_sizes.compact[-50..-1].sum / 50.0
current_range = range_sizes.last

puts "Range Analysis:"
puts "Current Range: $#{current_range.round(2)}"
puts "50-period Average Range: $#{avg_range.round(2)}"

range_ratio = current_range / avg_range
puts "Range Ratio: #{range_ratio.round(2)}"

if range_ratio < 0.7
  puts "\nRANGE CONTRACTION"
  puts "Range #{((1 - range_ratio) * 100).round(0)}% below average"
  puts "Potential for volatility expansion ahead"
  puts "Strategy: Prepare for breakout, use tight stops"

  # Calculate potential breakout levels
  current_mp = midprice.last
  breakout_up = current_mp + (avg_range / 2)
  breakout_down = current_mp - (avg_range / 2)

  puts "Watch for breakout above: $#{breakout_up.round(2)}"
  puts "Watch for breakdown below: $#{breakout_down.round(2)}"

elsif range_ratio > 1.3
  puts "\nRANGE EXPANSION"
  puts "Range #{((range_ratio - 1) * 100).round(0)}% above average"
  puts "High volatility period"
  puts "Strategy: Expect mean reversion toward MIDPRICE"
else
  puts "\nNORMAL RANGE"
  puts "Standard trading range"
  puts "Strategy: Use standard range trading around MIDPRICE"
end
```

## Example: MIDPRICE vs MIDPOINT Comparison

```ruby
high, low, close = load_ohlc_data('AAPL')

midprice = SQA::TAI.midprice(high, low, period: 14)
midpoint = SQA::TAI.midpoint(close, period: 14)

current_price = close.last
current_midprice = midprice.last
current_midpoint = midpoint.last

puts "Comparison of MIDPRICE vs MIDPOINT:"
puts "Current Price: $#{current_price.round(2)}"
puts "MIDPRICE (High/Low midpoint): $#{current_midprice.round(2)}"
puts "MIDPOINT (Close midpoint): $#{current_midpoint.round(2)}"
puts "Difference: $#{(current_midprice - current_midpoint).round(2)}"

# The difference reveals range characteristics
if current_midprice > current_midpoint
  puts "\nMIDPRICE > MIDPOINT:"
  puts "Highs are more elevated relative to lows"
  puts "Suggests bullish bias in recent range"
elsif current_midprice < current_midpoint
  puts "\nMIDPRICE < MIDPOINT:"
  puts "Lows are more depressed relative to highs"
  puts "Suggests bearish bias in recent range"
else
  puts "\nMIDPRICE = MIDPOINT:"
  puts "Symmetric range, no directional bias"
end

# Trading implications
if current_price > current_midprice && current_price > current_midpoint
  puts "\nPrice above both: Strong bullish position"
elsif current_price < current_midprice && current_price < current_midpoint
  puts "\nPrice below both: Strong bearish position"
elsif current_price > current_midprice && current_price < current_midpoint
  puts "\nPrice between indicators: Mixed signals, wait for clarity"
elsif current_price < current_midprice && current_price > current_midpoint
  puts "\nPrice between indicators: Mixed signals, wait for clarity"
end
```

## Common Uses

### 1. Range Midpoint Trading
```ruby
# Buy near lows, sell near highs, pivot at MIDPRICE
if current_price < midprice && position_in_range < 30
  signal = :buy
elsif current_price > midprice && position_in_range > 70
  signal = :sell
end
```

### 2. Mean Reversion
```ruby
# Trade when price deviates significantly from MIDPRICE
deviation = (current_price - midprice) / atr
entry_signal = deviation.abs > 1.5
```

### 3. Dynamic Support/Resistance
```ruby
# Use MIDPRICE as pivot for support/resistance
if price_above_midprice
  role = :support  # MIDPRICE acts as support
else
  role = :resistance  # MIDPRICE acts as resistance
end
```

### 4. Breakout Confirmation
```ruby
# Confirm breakout when price clears MIDPRICE with momentum
breakout = close > midprice && close > prior_high
```

## MIDPRICE Period Settings

| Period | Use Case | Characteristics |
|--------|----------|-----------------|
| 5-10 | Short-term | Very responsive, frequent signals |
| 14-20 | Standard | Balanced view, most common |
| 30-50 | Medium-term | Smoother, less noise |
| 100+ | Long-term | Major range levels |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

## MIDPRICE vs Similar Indicators

| Indicator | Input | Use Case | Key Difference |
|-----------|-------|----------|----------------|
| MIDPRICE | High/Low | Range midpoint | Uses extreme prices |
| MIDPOINT | Close | Price midpoint | Uses closing prices only |
| SMA | Close | Trend following | Moving average vs midpoint |
| MEDPRICE | High/Low | Daily midpoint | Single period vs range |

## Advantages

- Simple and intuitive calculation
- Clearly defines range center
- Works well in ranging markets
- Non-lagging within the defined period
- Useful for both support/resistance and mean reversion
- Objective measure of range equilibrium

## Limitations

- Less effective in strong trending markets
- Doesn't account for volume or momentum
- Can change significantly with new highs/lows
- May generate false signals during consolidation
- Requires range-bound conditions for best results
- Period selection significantly affects behavior

## Tips for Using MIDPRICE

1. **Combine with Volatility**: Use ATR to measure distance from MIDPRICE
2. **Multiple Timeframes**: Compare short and long-term MIDPRICE for context
3. **Range Confirmation**: Verify price is actually ranging before using
4. **Volume Analysis**: Confirm signals with volume at MIDPRICE levels
5. **Trend Filter**: Best used when price is not in strong directional trend
6. **Adjust Period**: Shorter periods for day trading, longer for swing trading

## Related Indicators

- [Midpoint (MIDPOINT)](midpoint.md) - Uses closing prices instead of high/low
- [Median Price (MEDPRICE)](../price_transform/medprice.md) - Single period high/low average
- [Average True Range (ATR)](atr.md) - Measure deviation from MIDPRICE
- [Bollinger Bands](../overlap/bbands.md) - Envelope around moving average

## See Also

- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
<!-- TODO: Create example file -->
- Range Trading Strategies
