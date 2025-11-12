# Moving Average with Variable Period (MAVP)

The Moving Average with Variable Period (MAVP) is a unique adaptive moving average that allows the smoothing period to change dynamically bar-by-bar based on an input array. Unlike traditional moving averages with fixed periods, MAVP adjusts its responsiveness based on external data such as volatility measurements, cycle periods, or custom adaptive logic.

## Formula

MAVP calculates a moving average where the period varies for each data point:

```
For each bar i:
  Period[i] = periods[i]  (from input array)
  MAVP[i] = MA(prices, Period[i])  (using specified MA type)
```

The moving average type can be any standard MA: SMA, EMA, WMA, DEMA, TEMA, TRIMA, KAMA, MAMA, or T3.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prices` | Array<Float> | Yes | - | Array of price values |
| `periods` | Array<Float> | Yes | - | Array of period values (one per price point) |
| `ma_type` | Integer | No | 0 | MA type: 0=SMA, 1=EMA, 2=WMA, 3=DEMA, 4=TEMA, 5=TRIMA, 6=KAMA, 7=MAMA, 8=T3 |

## Returns

Returns an array of MAVP values. The first several values will be `nil` based on the maximum period value in the periods array.

## Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41,
          46.22, 45.64, 46.21, 46.25, 46.08, 46.46,
          46.82, 47.00, 47.32, 47.20, 47.57, 47.80,
          48.00, 48.15, 48.30, 48.40, 48.55, 48.70]

# Create a variable period array
# For example: shorter periods in high volatility, longer in low volatility
periods = Array.new(prices.size, 10)  # Default to 10
periods[-5..-1] = [15, 18, 20, 18, 15]  # Increase period in recent bars

# Calculate MAVP using SMA (default)
mavp_sma = SQA::TAI.mavp(prices, periods)

# Calculate MAVP using EMA
mavp_ema = SQA::TAI.mavp(prices, periods, ma_type: 1)

puts "Current MAVP (SMA): #{mavp_sma.last.round(2)}"
puts "Current MAVP (EMA): #{mavp_ema.last.round(2)}"
```

## Interpretation

MAVP's adaptive period makes it highly flexible:

- **Variable Responsiveness**: Period adjusts based on input array
- **Adapts to Conditions**: Can use volatility, cycle data, or custom logic
- **Short Periods**: More responsive, tracks price closely
- **Long Periods**: Smoother, filters out noise
- **Period Transitions**: Gradual changes create smooth adaptive behavior

## Example: Volatility-Adaptive MAVP

```ruby
# Use ATR to create volatility-adaptive periods
high, low, close = load_ohlc_data('AAPL')

# Calculate ATR for volatility
atr = SQA::TAI.atr(high, low, close, period: 14)

# Create adaptive periods based on volatility
# High ATR -> shorter period (more responsive)
# Low ATR -> longer period (smoother)
avg_atr = atr.compact.sum / atr.compact.size

periods = atr.map do |atr_val|
  next 20 if atr_val.nil?

  # Scale period inversely with volatility
  # ATR above average -> period 10-15
  # ATR below average -> period 20-30
  if atr_val > avg_atr * 1.5
    10  # High volatility -> fast MA
  elsif atr_val > avg_atr
    15
  elsif atr_val > avg_atr * 0.5
    20
  else
    30  # Low volatility -> slow MA
  end
end

# Calculate volatility-adaptive MAVP
mavp = SQA::TAI.mavp(close, periods, ma_type: 1)  # Using EMA

puts "Current Price: #{close.last.round(2)}"
puts "Current ATR: #{atr.last.round(2)}"
puts "Current Period: #{periods.last}"
puts "MAVP Value: #{mavp.last.round(2)}"
puts "Signal: #{close.last > mavp.last ? 'BULLISH' : 'BEARISH'}"
```

## Example: Cycle-Based MAVP

```ruby
# Use Hilbert Transform Dominant Cycle Period for adaptive periods
prices = load_historical_prices('SPY')

# Get the dominant cycle period
cycle_periods = SQA::TAI.ht_dcperiod(prices)

# Use cycle period directly for MAVP
# This makes the MA adapt to the market's natural cycle
mavp_cycle = SQA::TAI.mavp(prices, cycle_periods, ma_type: 1)

# Also calculate a fixed EMA for comparison
ema_20 = SQA::TAI.ema(prices, period: 20)

puts "Market Analysis:"
puts "Current Price: #{prices.last.round(2)}"
puts "Dominant Cycle: #{cycle_periods.last.round(1)} periods"
puts "Cycle-based MAVP: #{mavp_cycle.last.round(2)}"
puts "Fixed EMA(20): #{ema_20.last.round(2)}"

# Compare responsiveness
if cycle_periods.last < 20
  puts "Market in SHORT cycle - MAVP more responsive than EMA"
elsif cycle_periods.last > 20
  puts "Market in LONG cycle - MAVP smoother than EMA"
else
  puts "Cycle matches EMA period"
end
```

## Example: Custom Adaptive Logic

```ruby
prices = load_historical_prices('TSLA')

# Create custom adaptive periods based on price momentum
periods = []
base_period = 20

prices.each_with_index do |price, i|
  if i < 10
    periods << base_period
    next
  end

  # Calculate 10-bar momentum
  momentum = ((price - prices[i-10]) / prices[i-10] * 100).abs

  # Adjust period based on momentum
  # High momentum -> shorter period (follow trends)
  # Low momentum -> longer period (filter noise)
  if momentum > 5.0
    periods << 10  # Strong move -> fast MA
  elsif momentum > 2.0
    periods << 15
  elsif momentum > 1.0
    periods << 20
  else
    periods << 30  # Slow market -> slow MA
  end
end

mavp = SQA::TAI.mavp(prices, periods, ma_type: 1)

puts "Current Momentum: #{(((prices.last - prices[-11]) / prices[-11]) * 100).round(2)}%"
puts "Adaptive Period: #{periods.last}"
puts "MAVP: #{mavp.last.round(2)}"
```

## Example: Multi-Condition Adaptive Periods

```ruby
high, low, close = load_ohlc_data('NVDA')

# Combine multiple factors for period selection
atr = SQA::TAI.atr(high, low, close, period: 14)
adx = SQA::TAI.adx(high, low, close, period: 14)

periods = []

close.each_with_index do |price, i|
  if i < 14 || atr[i].nil? || adx[i].nil?
    periods << 20
    next
  end

  # Factor 1: Volatility (ATR)
  avg_atr = atr.compact[0..i].sum / atr.compact[0..i].size
  high_vol = atr[i] > avg_atr * 1.2

  # Factor 2: Trend Strength (ADX)
  strong_trend = adx[i] > 25

  # Factor 3: Price momentum
  momentum = i >= 10 ? ((price - close[i-10]) / close[i-10] * 100).abs : 0
  high_momentum = momentum > 3.0

  # Combine conditions
  if strong_trend && high_momentum
    periods << 10  # Strong trending market -> fast MA
  elsif strong_trend && !high_vol
    periods << 15  # Trending but calm -> medium-fast MA
  elsif high_vol && !strong_trend
    periods << 30  # Volatile but no trend -> slow MA
  else
    periods << 20  # Default
  end
end

mavp = SQA::TAI.mavp(close, periods, ma_type: 1)

puts <<~OUTPUT
  Market State Analysis:
  ATR: #{atr.last.round(2)} (Volatility)
  ADX: #{adx.last.round(2)} (Trend Strength)
  Adaptive Period: #{periods.last}
  MAVP: #{mavp.last.round(2)}
  Price: #{close.last.round(2)}
  Position: #{close.last > mavp.last ? 'Above MAVP (Bullish)' : 'Below MAVP (Bearish)'}
OUTPUT
```

## Example: Stepped Period Zones

```ruby
prices = load_historical_prices('MSFT')

# Create stepped zones based on price action
periods = []
lookback = 20

prices.each_with_index do |price, i|
  if i < lookback
    periods << 20
    next
  end

  # Check where price is relative to recent range
  recent_high = prices[(i-lookback)..i].max
  recent_low = prices[(i-lookback)..i].min
  range_position = (price - recent_low) / (recent_high - recent_low)

  # Period zones based on range position
  case range_position
  when 0.0..0.2
    periods << 30  # Bottom zone -> slow MA (support area)
  when 0.2..0.4
    periods << 20  # Lower zone
  when 0.4..0.6
    periods << 15  # Mid zone -> responsive
  when 0.6..0.8
    periods << 20  # Upper zone
  else
    periods << 30  # Top zone -> slow MA (resistance area)
  end
end

mavp = SQA::TAI.mavp(prices, periods, ma_type: 0)  # SMA

# Detect crossovers
if prices[-2] <= mavp[-2] && prices.last > mavp.last
  puts "BULLISH CROSSOVER detected"
  puts "Period at crossover: #{periods.last}"
end
```

## Example: MAVP Trading System

```ruby
high, low, close = load_ohlc_data('QQQ')

# Build adaptive periods from volatility
atr = SQA::TAI.atr(high, low, close, period: 14)
avg_atr = atr.compact.sum / atr.compact.size

periods = atr.map do |val|
  next 20 if val.nil?
  val > avg_atr ? 12 : 25  # Binary: fast in volatility, slow in calm
end

mavp = SQA::TAI.mavp(close, periods, ma_type: 1)

# Generate signals
signals = []

close.each_with_index do |price, i|
  next if mavp[i].nil? || i < 1

  prev_price = close[i-1]
  prev_mavp = mavp[i-1]
  curr_mavp = mavp[i]

  # Bullish crossover
  if prev_price <= prev_mavp && price > curr_mavp
    signals << {
      index: i,
      type: 'BUY',
      price: price,
      mavp: curr_mavp,
      period: periods[i]
    }
  # Bearish crossover
  elsif prev_price >= prev_mavp && price < curr_mavp
    signals << {
      index: i,
      type: 'SELL',
      price: price,
      mavp: curr_mavp,
      period: periods[i]
    }
  end
end

# Display recent signals
puts "Recent Trading Signals:"
signals.last(5).each do |sig|
  puts "#{sig[:type]} at $#{sig[:price].round(2)} (MAVP: #{sig[:mavp].round(2)}, Period: #{sig[:period]})"
end

# Current status
puts "\nCurrent Status:"
puts "Price: $#{close.last.round(2)}"
puts "MAVP: $#{mavp.last.round(2)}"
puts "Period: #{periods.last}"
puts "Trend: #{close.last > mavp.last ? 'BULLISH' : 'BEARISH'}"
```

## MA Type Options

MAVP supports all standard moving average types:

| MA Type | Value | Description |
|---------|-------|-------------|
| SMA | 0 | Simple Moving Average (default) |
| EMA | 1 | Exponential Moving Average |
| WMA | 2 | Weighted Moving Average |
| DEMA | 3 | Double Exponential MA |
| TEMA | 4 | Triple Exponential MA |
| TRIMA | 5 | Triangular Moving Average |
| KAMA | 6 | Kaufman Adaptive MA |
| MAMA | 7 | MESA Adaptive MA |
| T3 | 8 | Tillson T3 |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

## Common Period Sources

### 1. Volatility-Based
```ruby
# ATR for volatility
atr = SQA::TAI.atr(high, low, close, period: 14)
periods = atr.map { |v| v.nil? ? 20 : (v > avg_atr ? 10 : 30) }
```

### 2. Cycle-Based
```ruby
# Dominant cycle period
periods = SQA::TAI.ht_dcperiod(prices)
```

### 3. Momentum-Based
```ruby
# ROC for momentum
roc = SQA::TAI.roc(prices, period: 10)
periods = roc.map { |v| v.nil? ? 20 : (v.abs > 5 ? 10 : 30) }
```

### 4. Trend Strength
```ruby
# ADX for trend strength
adx = SQA::TAI.adx(high, low, close, period: 14)
periods = adx.map { |v| v.nil? ? 20 : (v > 25 ? 12 : 28) }
```

## Best Practices

1. **Smooth Period Changes**: Avoid dramatic period jumps; use gradual transitions
2. **Set Bounds**: Keep periods within reasonable range (e.g., 5-50)
3. **Test Logic**: Backtest your adaptive period logic before live trading
4. **Combine Factors**: Use multiple indicators for period determination
5. **Use Appropriate MA Type**: EMA for trends, SMA for support/resistance

## Advantages

- **Maximum Flexibility**: Period adapts to any custom logic
- **Responsive to Conditions**: Adjusts automatically to market changes
- **Multi-Factor**: Can combine multiple indicators for period selection
- **Reduces Whipsaws**: Slower periods in choppy markets
- **Catches Trends**: Faster periods in trending markets

## Limitations

- **Complexity**: Requires good understanding of period logic
- **Optimization Risk**: Easy to over-optimize period selection
- **Calculation Overhead**: More complex than fixed-period MAs
- **Look-Ahead Bias**: Period array must be generated properly
- **Requires External Data**: Needs additional indicators for period selection

## Use Cases

1. **Volatility-Adaptive Systems**: Adjust to market volatility automatically
2. **Cycle-Based Trading**: Follow market's natural cycle rhythms
3. **Multi-Timeframe Analysis**: Adapt period to timeframe characteristics
4. **Regime Detection**: Different periods for trending vs ranging markets
5. **Custom Strategies**: Implement proprietary adaptive logic

## Related Indicators

- [ATR](atr.md) - Use for volatility-based periods
- [HT_DCPERIOD](../cycle/ht_dcperiod.md) - Dominant cycle period for cycle-based MAVP
- [ADX](../momentum/adx.md) - Trend strength for period selection
- [KAMA](../overlap/kama.md) - Another adaptive moving average
- [MAMA](mama.md) - MESA Adaptive Moving Average
- [EMA](../overlap/ema.md) - Standard exponential moving average

## See Also

- [Back to Indicators](../index.md)
- [Volatility Indicators Overview](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
