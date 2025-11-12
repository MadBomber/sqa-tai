# Commodity Channel Index (CCI)

The Commodity Channel Index (CCI) is a versatile momentum oscillator that measures the deviation of price from its statistical mean. Originally developed for commodities, it's now widely used across all markets to identify cyclical trends and overbought/oversold conditions.

## Formula

CCI = (Typical Price - SMA of Typical Price) / (0.015 * Mean Deviation)

Where Typical Price = (High + Low + Close) / 3

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `high` | Array<Float> | Yes | - | Array of high prices |
| `low` | Array<Float> | Yes | - | Array of low prices |
| `close` | Array<Float> | Yes | - | Array of close prices |
| `period` | Integer | No | 14 | Number of periods for calculation |

## Returns

Returns an array of CCI values. Values typically range from -100 to +100, but can exceed these levels during strong trends.

## Usage

```ruby
require 'sqa/tai'

high =  [48.70, 48.72, 48.90, 48.87, 48.82, 49.05, 49.20, 49.35, 49.92, 50.19, 50.12, 50.10, 50.00, 49.75, 49.80]
low =   [47.79, 48.14, 48.39, 48.37, 48.24, 48.64, 48.94, 49.03, 49.50, 49.87, 49.20, 49.00, 48.90, 49.00, 49.10]
close = [48.20, 48.61, 48.75, 48.63, 48.74, 49.03, 49.07, 49.32, 49.91, 50.13, 49.53, 49.50, 49.25, 49.20, 49.45]

# Calculate 14-period CCI (default)
cci = SQA::TAI.cci(high, low, close, period: 14)

puts "Current CCI: #{cci.last.round(2)}"
```

## Interpretation

| CCI Value | Interpretation |
|-----------|----------------|
| Above +100 | Overbought - strong uptrend |
| 0 to +100 | Bullish zone |
| 0 | Neutral - at mean |
| 0 to -100 | Bearish zone |
| Below -100 | Oversold - strong downtrend |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

## Example: CCI Trading Signals

```ruby
high, low, close = load_historical_ohlc('AAPL')
cci = SQA::TAI.cci(high, low, close, period: 20)

current_cci = cci.last
previous_cci = cci[-2]

# Overbought/Oversold signals
if current_cci > 100
  puts "CCI Overbought (#{current_cci.round(2)}) - Watch for reversal"
elsif current_cci < -100
  puts "CCI Oversold (#{current_cci.round(2)}) - Watch for reversal"
end

# Zero-line crossovers
if previous_cci < 0 && current_cci > 0
  puts "CCI crossed above zero - Bullish signal"
elsif previous_cci > 0 && current_cci < 0
  puts "CCI crossed below zero - Bearish signal"
end

# +100/-100 level crossovers
if previous_cci < 100 && current_cci > 100
  puts "CCI entered overbought zone - Strong momentum"
elsif previous_cci > -100 && current_cci < -100
  puts "CCI entered oversold zone - Strong momentum down"
end
```

## Example: CCI Divergence

```ruby
high, low, close = load_historical_ohlc('SPY')
cci = SQA::TAI.cci(high, low, close, period: 14)

# Find recent highs
price_high_1 = close[-20..-10].max
price_high_2 = close[-9..-1].max

cci_high_1 = cci[-20..-10].compact.max
cci_high_2 = cci[-9..-1].compact.max

# Bearish divergence
if price_high_2 > price_high_1 && cci_high_2 < cci_high_1
  puts "BEARISH DIVERGENCE"
  puts "Price making higher highs, CCI making lower highs"
  puts "Potential trend reversal"
end

# Bullish divergence
price_low_1 = close[-20..-10].min
price_low_2 = close[-9..-1].min

cci_low_1 = cci[-20..-10].compact.min
cci_low_2 = cci[-9..-1].compact.min

if price_low_2 < price_low_1 && cci_low_2 > cci_low_1
  puts "BULLISH DIVERGENCE"
  puts "Price making lower lows, CCI making higher lows"
  puts "Potential trend reversal"
end
```

## Example: CCI Trend Identification

```ruby
high, low, close = load_historical_ohlc('MSFT')
cci = SQA::TAI.cci(high, low, close, period: 20)

# Count bars above/below key levels
last_20_cci = cci.last(20).compact

bars_above_100 = last_20_cci.count { |v| v > 100 }
bars_below_minus_100 = last_20_cci.count { |v| v < -100 }
bars_above_zero = last_20_cci.count { |v| v > 0 }

if bars_above_100 > 10
  puts "Strong uptrend - CCI consistently above +100"
elsif bars_below_minus_100 > 10
  puts "Strong downtrend - CCI consistently below -100"
elsif bars_above_zero > 15
  puts "Moderate uptrend - CCI mostly positive"
elsif bars_above_zero < 5
  puts "Moderate downtrend - CCI mostly negative"
else
  puts "Ranging market - CCI oscillating around zero"
end
```

## Common Settings

| Period | Use Case |
|--------|----------|
| 14 | Standard setting for most trading |
| 20 | Smoother, fewer signals |
| 30 | Longer-term trend identification |
| 40 | Very smooth, major trends only |

## Trading Strategies

### 1. Basic Overbought/Oversold
- Buy when CCI crosses below -100 then back above
- Sell when CCI crosses above +100 then back below

### 2. Zero-Line Strategy
- Buy when CCI crosses above 0 (uptrend confirmation)
- Sell when CCI crosses below 0 (downtrend confirmation)

### 3. Trend Following
- Only long trades when CCI > 0
- Only short trades when CCI < 0

## Related Indicators

- [RSI](rsi.md) - Relative Strength Index
- [STOCH](stoch.md) - Stochastic Oscillator
- [MFI](mfi.md) - Money Flow Index
- [WILLR](willr.md) - Williams %R

## See Also

- [Back to Indicators](../index.md)
- [Momentum Indicators Overview](../index.md)
