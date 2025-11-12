# Parabolic SAR (Stop and Reverse)

The Parabolic SAR (Stop and Reverse) is a trend-following indicator that provides entry and exit points. It appears as dots above or below price, indicating the direction of the trend and potential reversal points.

## Formula

SAR is calculated using an acceleration factor that increases as the trend develops:
- If long: SAR = Prior SAR + AF * (Prior EP - Prior SAR)
- If short: SAR = Prior SAR - AF * (Prior SAR - Prior EP)

Where EP is the Extreme Point (highest high or lowest low) and AF is the Acceleration Factor.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `high` | Array<Float> | Yes | - | Array of high prices |
| `low` | Array<Float> | Yes | - | Array of low prices |
| `acceleration` | Float | No | 0.02 | Acceleration factor |
| `maximum` | Float | No | 0.20 | Maximum acceleration |

## Returns

Returns an array of SAR values. When SAR is below price, the trend is up; when above, the trend is down.

## Usage

```ruby
require 'sqa/tai'

high = [48.70, 48.72, 48.90, 48.87, 48.82, 49.05, 49.20, 49.35, 49.92, 50.19, 50.12, 50.10, 50.00, 49.75, 49.80]
low =  [47.79, 48.14, 48.39, 48.37, 48.24, 48.64, 48.94, 49.03, 49.50, 49.87, 49.20, 49.00, 48.90, 49.00, 49.10]

sar = SQA::TAI.sar(high, low)

puts "Current SAR: #{sar.last.round(2)}"
```

## Interpretation

- **SAR below price**: Uptrend - hold long positions
- **SAR above price**: Downtrend - hold short positions
- **Price crosses SAR**: Trend reversal signal

## Example: SAR Trend Following

```ruby
high, low, close = load_historical_ohlc('AAPL')
sar = SQA::TAI.sar(high, low)

current_price = close.last
current_sar = sar.last

if current_price > current_sar
  puts "UPTREND - Price above SAR (#{current_sar.round(2)})"
  puts "Hold long / Look for buy opportunities"
else
  puts "DOWNTREND - Price below SAR (#{current_sar.round(2)})"
  puts "Hold short / Look for sell opportunities"
end
```

## Example: SAR Reversal Detection

```ruby
high, low, close = load_historical_ohlc('SPY')
sar = SQA::TAI.sar(high, low, acceleration: 0.02, maximum: 0.20)

prev_price = close[-2]
curr_price = close.last
prev_sar = sar[-2]
curr_sar = sar.last

# Bullish reversal
if prev_price < prev_sar && curr_price > curr_sar
  puts "BULLISH REVERSAL - Price crossed above SAR"
  puts "New uptrend beginning - BUY signal"
# Bearish reversal
elsif prev_price > prev_sar && curr_price < curr_sar
  puts "BEARISH REVERSAL - Price crossed below SAR"
  puts "New downtrend beginning - SELL signal"
end
```

## Acceleration Factor Guidelines

- **Default (0.02, 0.20)**: Standard settings for most markets
- **More sensitive (0.03, 0.25)**: Faster reversals, more signals
- **Less sensitive (0.01, 0.15)**: Slower reversals, fewer signals

## Common Settings

| Accel | Maximum | Use Case |
|-------|---------|----------|
| 0.02 | 0.20 | Standard (Wilder's original) |
| 0.01 | 0.15 | Trending markets |
| 0.03 | 0.25 | Volatile markets |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

## Best Practices

1. Works best in trending markets
2. Can produce whipsaws in sideways markets
3. Use with trend filters (ADX, moving averages)
4. SAR provides stop-loss levels naturally

## Related Indicators

- [SAREXT](sarext.md) - Parabolic SAR Extended
- [ADX](../momentum/adx.md) - Trend strength filter

## See Also

- [Back to Indicators](../index.md)
- [Volatility Indicators Overview](../index.md)
