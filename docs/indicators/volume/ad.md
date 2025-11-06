# Chaikin Accumulation/Distribution Line (AD)

The Chaikin Accumulation/Distribution Line is a volume-based indicator that measures the cumulative flow of money into and out of a security. It considers both price and volume to assess buying or selling pressure.

## Usage

```ruby
require 'sqa/tai'

# OHLC data + Volume required
high   = [46.08, 46.41, 46.46, 46.57, 46.50, 47.03, 47.35]
low    = [44.61, 44.83, 45.64, 45.95, 46.02, 46.50, 47.28]
close  = [45.42, 45.84, 46.08, 46.46, 46.55, 47.03, 47.28]
volume = [2500, 3200, 2800, 4100, 3500, 4200, 3600]

# Calculate A/D Line
ad = SQA::TAI.ad(high, low, close, volume)

puts "Current A/D: #{ad.last.round(0)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `high` | Array | Yes | - | Array of high prices |
| `low` | Array | Yes | - | Array of low prices |
| `close` | Array | Yes | - | Array of closing prices |
| `volume` | Array | Yes | - | Array of volume values |

## Returns

Returns an array of cumulative Accumulation/Distribution values.

## Formula

```
Money Flow Multiplier = ((Close - Low) - (High - Close)) / (High - Low)
Money Flow Volume = Money Flow Multiplier × Volume
A/D Line = Previous A/D + Current Money Flow Volume
```

Where Money Flow Multiplier ranges from -1 to +1:
- Close near high = ~+1 (accumulation)
- Close near low = ~-1 (distribution)
- Close in middle = ~0 (neutral)

## Interpretation

- **Rising A/D**: Accumulation, buying pressure
- **Falling A/D**: Distribution, selling pressure
- **A/D confirms price**: Healthy trend
- **A/D diverges from price**: Potential reversal warning

## Example: A/D Line Trend Analysis

```ruby
high, low, close, volume = load_ohlc_volume_data('AAPL')

ad = SQA::TAI.ad(high, low, close, volume)

# Calculate A/D moving average
ad_ma = SQA::TAI.sma(ad, period: 20)

current_ad = ad.last
current_ad_ma = ad_ma.last

if current_ad > current_ad_ma
  puts "A/D above 20-day MA: Bullish accumulation"

  # Check trend strength
  if ad[-10..-1].each_cons(2).all? { |a, b| b >= a }
    puts "A/D in strong uptrend - sustained buying pressure"
  end
elsif current_ad < current_ad_ma
  puts "A/D below 20-day MA: Bearish distribution"

  if ad[-10..-1].each_cons(2).all? { |a, b| b <= a }
    puts "A/D in strong downtrend - sustained selling pressure"
  end
end
```

## Example: A/D Divergence Detection

```ruby
high, low, close, volume = load_ohlc_volume_data('TSLA')

ad = SQA::TAI.ad(high, low, close, volume)

# Find recent peaks
price_peak_1_idx = close[-30..-15].index(close[-30..-15].max) - 30
price_peak_2_idx = close[-14..-1].index(close[-14..-1].max) - 14

price_peak_1 = close[price_peak_1_idx]
price_peak_2 = close[price_peak_2_idx]

ad_peak_1 = ad[price_peak_1_idx]
ad_peak_2 = ad[price_peak_2_idx]

# Bearish divergence
if price_peak_2 > price_peak_1 && ad_peak_2 < ad_peak_1
  puts "Bearish Divergence Detected!"
  puts "Price: #{price_peak_1.round(2)} -> #{price_peak_2.round(2)} (higher high)"
  puts "A/D: #{ad_peak_1.round(0)} -> #{ad_peak_2.round(0)} (lower high)"
  puts "Warning: Distribution despite rising prices"
end

# Find recent troughs
price_trough_1_idx = close[-30..-15].index(close[-30..-15].min) - 30
price_trough_2_idx = close[-14..-1].index(close[-14..-1].min) - 14

price_trough_1 = close[price_trough_1_idx]
price_trough_2 = close[price_trough_2_idx]

ad_trough_1 = ad[price_trough_1_idx]
ad_trough_2 = ad[price_trough_2_idx]

# Bullish divergence
if price_trough_2 < price_trough_1 && ad_trough_2 > ad_trough_1
  puts "Bullish Divergence Detected!"
  puts "Price: #{price_trough_1.round(2)} -> #{price_trough_2.round(2)} (lower low)"
  puts "A/D: #{ad_trough_1.round(0)} -> #{ad_trough_2.round(0)} (higher low)"
  puts "Accumulation despite falling prices"
end
```

## Example: Breakout Confirmation

```ruby
high, low, close, volume = load_ohlc_volume_data('MSFT')

ad = SQA::TAI.ad(high, low, close, volume)

# Find resistance level
resistance = close[-60..-1].max

if close.last > resistance
  # Price broke resistance - is A/D confirming?
  ad_at_resistance_idx = close[-60..-1].index(resistance) - 60
  ad_at_resistance = ad[ad_at_resistance_idx]

  if ad.last > ad_at_resistance
    puts "Strong Breakout!"
    puts "Price above resistance: #{resistance.round(2)}"
    puts "A/D also making new high: #{ad.last.round(0)} vs #{ad_at_resistance.round(0)}"
    puts "Breakout confirmed by accumulation"
  else
    puts "Weak Breakout"
    puts "Price broke resistance but A/D lagging"
    puts "Lack of volume/money flow confirmation"
  end
end
```

## Example: Comparing A/D with OBV

```ruby
high, low, close, volume = load_ohlc_volume_data('NVDA')

ad = SQA::TAI.ad(high, low, close, volume)
obv = SQA::TAI.obv(close, volume)

# Normalize for comparison (percentage change from start)
ad_start = ad.compact.first
obv_start = obv.compact.first

ad_pct_change = ((ad.last - ad_start) / ad_start.abs) * 100
obv_pct_change = ((obv.last - obv_start) / obv_start.abs) * 100

puts "A/D Change: #{ad_pct_change.round(2)}%"
puts "OBV Change: #{obv_pct_change.round(2)}%"

# A/D is more sophisticated - considers where price closes in range
# OBV only looks at whether price closed up or down
if ad_pct_change > obv_pct_change * 1.2
  puts "A/D shows stronger accumulation than OBV"
  puts "Closes near highs of daily ranges"
elsif ad_pct_change < obv_pct_change * 0.8
  puts "A/D shows weaker accumulation than OBV"
  puts "Despite up days, closes not near highs"
end
```

## Trading Strategies

### 1. Trend Confirmation
```ruby
# Buy when both price and A/D rising
# Sell when both price and A/D falling
```

### 2. Divergence Trading
```ruby
# Bullish: Price down, A/D up
# Bearish: Price up, A/D down
```

### 3. Breakout Validation
```ruby
# Confirm breakouts with A/D making new highs/lows
```

### 4. Money Flow Analysis
```ruby
# Rising A/D = Smart money accumulating
# Falling A/D = Smart money distributing
```

## Key Differences: A/D vs OBV

| Aspect | A/D Line | OBV |
|--------|----------|-----|
| Calculation | Considers close location in range | Only if close up/down |
| Sensitivity | More sensitive to intraday action | Binary (up or down day) |
| Complexity | More sophisticated | Simpler |
| Best For | Detailed volume analysis | General trend confirmation |

## Example: Complete A/D Analysis

```ruby
high, low, close, volume = load_ohlc_volume_data('GOOGL')

ad = SQA::TAI.ad(high, low, close, volume)
ad_ma_20 = SQA::TAI.sma(ad, period: 20)
price_ma_20 = SQA::TAI.sma(close, period: 20)

current_ad = ad.last
current_price = close.last

# Trend alignment
price_above_ma = current_price > price_ma_20.last
ad_above_ma = current_ad > ad_ma_20.last

if price_above_ma && ad_above_ma
  puts "Bullish Alignment: Both price and A/D above 20-day MAs"
  puts "Strong uptrend with buying pressure"
elsif !price_above_ma && !ad_above_ma
  puts "Bearish Alignment: Both price and A/D below 20-day MAs"
  puts "Strong downtrend with selling pressure"
elsif price_above_ma && !ad_above_ma
  puts "Warning: Price above MA but A/D below MA"
  puts "Uptrend not supported by money flow"
elsif !price_above_ma && ad_above_ma
  puts "Potential Reversal: Price below MA but A/D above MA"
  puts "Accumulation during price weakness"
end

# Momentum
ad_5day_change = ad.last - ad[-5]
puts "\n5-day A/D Change: #{ad_5day_change.round(0)}"
puts "Momentum: #{ad_5day_change > 0 ? 'Bullish' : 'Bearish'}"
```

## Advantages

- More sophisticated than OBV
- Considers intraday price action
- Excellent for spotting distribution/accumulation
- Good leading indicator

## Limitations

- Can give false signals in choppy markets
- Cumulative value (can't compare across stocks)
- Requires OHLC data (not just close)
- May lag in fast-moving markets

## Related Indicators

- [On Balance Volume (OBV)](obv.md) - Simpler volume indicator
- [Chaikin Oscillator](obv.md) - A/D Line momentum
- [RSI](../momentum/rsi.md) - Combine for confirmation

## See Also

- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
- [Volume Analysis Example](../../examples/trend-analysis.md)
