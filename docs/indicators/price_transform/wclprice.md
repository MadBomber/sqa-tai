# Weighted Close Price (WCLPRICE)

The Weighted Close Price (WCLPRICE) is a price transformation that calculates a close-weighted average of the High, Low, and Close prices, giving double weight to the closing price. This indicator recognizes that the close price represents the final consensus of market participants and carries the most significance for technical analysis and trading decisions.

## Usage

```ruby
require 'sqa/tai'

high =  [48.70, 48.72, 48.90, 48.87, 48.82]
low =   [47.79, 48.14, 48.39, 48.37, 48.24]
close = [48.20, 48.61, 48.75, 48.63, 48.74]

wclprice = SQA::TAI.wclprice(high, low, close)

puts "Current Weighted Close: #{wclprice.last.round(2)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `high` | Array<Float> | Yes | - | Array of high prices for each period |
| `low` | Array<Float> | Yes | - | Array of low prices for each period |
| `close` | Array<Float> | Yes | - | Array of close prices for each period |

## Returns

Returns an array of weighted close price values, one for each input period. Each value is calculated on a bar-by-bar basis with no lookback period required.

## Formula

WCLPRICE = (High + Low + 2 × Close) / 4

Or equivalently:

WCLPRICE = (High + Low + Close + Close) / 4

The close price is counted twice, giving it double the weight of the high or low prices.

## Interpretation

### Why Double Weight for Close?

The close price receives 2x weight because:

1. **Final Market Consensus**: The close represents the final agreed-upon price after all buyers and sellers have had their opportunity to act during the period.

2. **Continuation Price**: The close is the reference point that connects one period to the next, establishing the baseline for gap analysis and price action.

3. **Decision Point**: Most trading strategies use the close as the trigger price for entries, exits, and stop placements.

4. **Settlement Reference**: Clearing and settlement processes typically use closing prices, making them the "official" price of record.

5. **Market Sentiment**: The close reflects where traders were willing to hold positions overnight or into the next period, indicating conviction.

### Price Weight Distribution

| Component | Weight | Percentage |
|-----------|--------|------------|
| High | 1 | 25% |
| Low | 1 | 25% |
| Close | 2 | 50% |
| **Total** | **4** | **100%** |

### Characteristics

- **Close Emphasis**: With 50% weight on close, values gravitate toward closing prices
- **Smoothed Yet Responsive**: Smoother than using close alone, but more responsive than equal-weighted averages
- **Respects Final Sentiment**: Reflects where the market "settled" rather than just range midpoints
- **Better Price Representation**: More accurately represents actual trading conditions than simple averages

## Example: Comparing Price Transformations

```ruby
high =  [50.00, 51.00, 52.00, 51.50, 52.50]
low =   [48.00, 49.00, 50.00, 49.50, 50.50]
close = [48.50, 49.50, 51.50, 51.00, 52.00]

# Calculate different price transformations
medprice = SQA::TAI.medprice(high, low)
typprice = SQA::TAI.typprice(high, low, close)
wclprice = SQA::TAI.wclprice(high, low, close)

puts <<~COMPARISON
  Price Transformation Comparison:

  Latest Bar: H=#{high.last} L=#{low.last} C=#{close.last}

  MEDPRICE: #{medprice.last.round(2)} (ignores close)
  TYPPRICE: #{typprice.last.round(2)} (equal weights)
  WCLPRICE: #{wclprice.last.round(2)} (2x weight on close)

  Close is: #{close.last.round(2)}
  Notice WCLPRICE is closest to close price
COMPARISON
```

## Example: Weighted Close for Pivot Calculations

```ruby
# Use WCLPRICE as base for pivot points
high =  load_historical_data('AAPL', field: :high)
low =   load_historical_data('AAPL', field: :low)
close = load_historical_data('AAPL', field: :close)

wclprice = SQA::TAI.wclprice(high, low, close)

# Calculate pivot point using weighted close
pivot = wclprice.last
range = high.last - low.last

# Support and resistance levels
r1 = (2 * pivot) - low.last
s1 = (2 * pivot) - high.last
r2 = pivot + range
s2 = pivot - range

puts <<~PIVOTS
  Weighted Close Pivot Analysis:

  Weighted Close (Pivot): #{pivot.round(2)}

  Resistance 2: #{r2.round(2)}
  Resistance 1: #{r1.round(2)}
  Pivot Point:  #{pivot.round(2)}
  Support 1:    #{s1.round(2)}
  Support 2:    #{s2.round(2)}

  Using weighted close gives more weight to final sentiment
PIVOTS
```

## Example: WCLPRICE vs Close Price Divergence

```ruby
high =  load_historical_data('TSLA', field: :high)
low =   load_historical_data('TSLA', field: :low)
close = load_historical_data('TSLA', field: :close)

wclprice = SQA::TAI.wclprice(high, low, close)

# Compare weighted close to actual close
last_10_bars = (0...10).map do |i|
  idx = -10 + i
  wcl = wclprice[idx]
  cls = close[idx]
  diff = ((cls - wcl) / wcl * 100).round(2)

  {
    bar: i + 1,
    weighted: wcl.round(2),
    close: cls.round(2),
    diff_pct: diff
  }
end

last_10_bars.each do |bar|
  status = if bar[:diff_pct] > 1
    "Close > WCL by #{bar[:diff_pct]}% - Strong close"
  elsif bar[:diff_pct] < -1
    "Close < WCL by #{bar[:diff_pct]}% - Weak close"
  else
    "Close ≈ WCL - Balanced"
  end

  puts "Bar #{bar[:bar]}: WCL=#{bar[:weighted]} Close=#{bar[:close]} #{status}"
end
```

## Example: Smoothed Price Input for Indicators

```ruby
# Use WCLPRICE as smoothed input to other indicators
high =  load_historical_data('MSFT', field: :high)
low =   load_historical_data('MSFT', field: :low)
close = load_historical_data('MSFT', field: :close)

wclprice = SQA::TAI.wclprice(high, low, close)

# Calculate moving averages on weighted close
sma_close = SQA::TAI.sma(close, period: 20)
sma_wcl = SQA::TAI.sma(wclprice, period: 20)

# Weighted close MA will be smoother
puts <<~SMOOTHING
  Moving Average Comparison (20 periods):

  SMA on Close:          #{sma_close.last.round(2)}
  SMA on Weighted Close: #{sma_wcl.last.round(2)}

  The weighted close reduces noise from extreme highs/lows
  while maintaining the importance of closing prices
SMOOTHING

# Calculate RSI on weighted close for smoother signals
rsi_close = SQA::TAI.rsi(close, period: 14)
rsi_wcl = SQA::TAI.rsi(wclprice, period: 14)

puts <<~RSI
  RSI Comparison (14 periods):

  RSI on Close:          #{rsi_close.last.round(2)}
  RSI on Weighted Close: #{rsi_wcl.last.round(2)}

  Weighted close RSI can reduce false signals
RSI
```

## Example: Trend Analysis with Weighted Close

```ruby
high =  load_historical_data('SPY', field: :high)
low =   load_historical_data('TSLA', field: :low)
close = load_historical_data('SPY', field: :close)

wclprice = SQA::TAI.wclprice(high, low, close)

# Calculate trend using weighted close
sma_fast = SQA::TAI.sma(wclprice, period: 10)
sma_slow = SQA::TAI.sma(wclprice, period: 30)

current_wcl = wclprice.last
current_fast = sma_fast.last
current_slow = sma_slow.last

if current_fast > current_slow && current_wcl > current_fast
  puts <<~TREND
    Strong Uptrend Confirmed:

    Weighted Close: #{current_wcl.round(2)}
    Fast SMA (10):  #{current_fast.round(2)}
    Slow SMA (30):  #{current_slow.round(2)}

    Price above both moving averages with bullish alignment
  TREND
elsif current_fast < current_slow && current_wcl < current_fast
  puts <<~TREND
    Strong Downtrend Confirmed:

    Weighted Close: #{current_wcl.round(2)}
    Fast SMA (10):  #{current_fast.round(2)}
    Slow SMA (30):  #{current_slow.round(2)}

    Price below both moving averages with bearish alignment
  TREND
end
```

## Advanced Techniques

### 1. Weighted Close for Gap Analysis

When analyzing gaps, weighted close provides better context:
- **Gap Up**: If WCLPRICE < Close, shows strength (closed near highs)
- **Gap Down**: If WCLPRICE > Close, shows weakness (closed near lows)

### 2. Range Contraction Detection

Compare WCLPRICE to MEDPRICE:
- When they converge, range is contracting
- When they diverge, indicates directional bias

### 3. Multiple Timeframe Analysis

Use WCLPRICE across timeframes:
- Daily WCLPRICE for swing trades
- Hourly WCLPRICE for day trades
- 15-min WCLPRICE for scalping

### 4. Weighted Close Crossovers

Monitor WCLPRICE crossing moving averages:
- More reliable than close-only signals
- Reduces whipsaw in choppy markets
- Better confirmation of trend changes

## Common Use Cases

| Use Case | Why WCLPRICE Works |
|----------|-------------------|
| **Pivot Points** | Emphasizes actual settlement prices |
| **Moving Averages** | Smoother than close, more relevant than typical |
| **Indicator Input** | Reduces noise while respecting close |
| **Support/Resistance** | Reflects true market consensus |
| **Trend Following** | Weights the most important price |
| **Mean Reversion** | Better measure of fair value |

## Comparison: Price Transformation Methods

| Method | Formula | Close Weight | Best For |
|--------|---------|--------------|----------|
| **MEDPRICE** | (H + L) / 2 | 0% | Simple range midpoint |
| **TYPPRICE** | (H + L + C) / 3 | 33% | Balanced view with close |
| **WCLPRICE** | (H + L + 2C) / 4 | 50% | Close-weighted analysis |
| **Close Only** | C | 100% | Pure closing action |

### When to Use Each

- **MEDPRICE**: When close is unreliable or you want pure range
- **TYPPRICE**: When all three prices deserve equal consideration
- **WCLPRICE**: When close matters most but you want smoothing (most common)
- **Close Only**: When you need pure closing momentum

## Key Advantages

1. **Respects Market Consensus**: 50% weight on close reflects real market sentiment
2. **Smoother Than Close Alone**: Reduces impact of closing price spikes
3. **More Relevant Than Equal Weights**: Close price deserves more weight
4. **Standard in Many Indicators**: Widely used in pivot calculations
5. **Reduces Noise**: Smooths price action while maintaining directional bias
6. **Better for Backtesting**: More representative of actual trading prices

## Limitations

1. **Still Lags Price**: Like all averages, lags actual price movement
2. **Gap Sensitivity**: Large gaps can skew weighted close values
3. **Not All Markets**: Some markets don't have meaningful high/low ranges
4. **Closing Price Bias**: Assumes close is always most important (not always true)

## Trading Applications

### Entry Signals
- Price crosses above/below WCLPRICE moving average
- WCLPRICE confirms breakout when it crosses key levels
- Use for stop placement at WCLPRICE - (2 × ATR)

### Exit Signals
- Close below WCLPRICE in uptrend signals weakness
- WCLPRICE breaks support/resistance first = early warning
- Trail stops using WCLPRICE smoothing

### Position Sizing
- Distance from WCLPRICE to entry determines risk
- WCLPRICE volatility influences position size
- Use WCLPRICE ATR for dynamic sizing

## Related Indicators

- [MEDPRICE](medprice.md) - Median Price (no close weight)
- [TYPPRICE](typprice.md) - Typical Price (equal weights)
- [AVGPRICE](avgprice.md) - Average Price (includes open)
- [SMA](../overlap/sma.md) - Often calculated on WCLPRICE
<!-- TODO: Create example file -->
- Pivot Points - Uses weighted close

## See Also

- [Back to Indicators](../index.md)
- [Price Transform Overview](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
