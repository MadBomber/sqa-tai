# CDL_DOJI (Doji Candlestick Pattern)

## Overview

The Doji is one of the most important single-candlestick patterns in technical analysis, characterized by opening and closing prices that are virtually equal, creating a cross or plus sign shape. This pattern signals market indecision and equilibrium between buyers and sellers, often serving as a precursor to significant price reversals when appearing at key technical levels or after extended trends.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `open` | Array | Required | Array of opening prices for each period |
| `high` | Array | Required | Array of high prices for each period |
| `low` | Array | Required | Array of low prices for each period |
| `close` | Array | Required | Array of closing prices for each period |

### Parameter Details

**open, high, low, close (OHLC Data)**
- All four price arrays must be of equal length
- Each index represents the same time period across all arrays
- Prices should be in chronological order (oldest to newest)
- Minimum of 1 period required, but more periods provide better context
- The pattern detection analyzes the relationship between these prices to identify Doji formations

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

open  = [100.0, 101.5, 102.0, 103.5, 104.0]
high  = [101.5, 103.0, 104.0, 105.0, 105.5]
low   = [99.0, 100.5, 101.5, 102.5, 103.5]
close = [101.0, 101.5, 102.0, 103.5, 104.0]

# Detect Doji patterns
doji = SQA::TAI.cdl_doji(open, high, low, close)

if doji.last != 0
  puts "Doji detected!"
end
```

### Real-World Example with Context

```ruby
# Load historical data for analysis
open, high, low, close = load_ohlc_data('AAPL')

# Detect Doji pattern
doji = SQA::TAI.cdl_doji(open, high, low, close)

# Analyze the most recent candle
if doji.last == 100
  puts "Doji pattern detected on latest candle"
  puts "Open: #{open.last}, Close: #{close.last}"
  puts "High: #{high.last}, Low: #{low.last}"
  puts "Body size: #{(close.last - open.last).abs}"
end
```

## Understanding the Pattern

### What It Measures

The Doji pattern measures market equilibrium and indecision. When buyers and sellers are perfectly balanced, neither can drive the price decisively higher or lower, resulting in the opening and closing prices being nearly identical. This creates a candlestick with little or no body and potentially long shadows extending above and below.

The Doji reveals:
- **Market Indecision**: Equal pressure from bulls and bears
- **Potential Reversal**: Exhaustion of the current trend's momentum
- **Consolidation Phase**: Markets pausing before the next move
- **Key Decision Points**: Critical junctures where trend direction may change

### Pattern Recognition Criteria

For a candle to qualify as a Doji:
1. **Open ≈ Close**: Opening and closing prices must be virtually equal (typically within 0.1% of the price range)
2. **Body Size**: The real body (difference between open and close) should be very small relative to the overall range
3. **Shadows**: Can have upper and/or lower shadows of any length
4. **Context**: Most significant when appearing after a trend or at support/resistance levels

### Pattern Characteristics

- **Range**: Returns 0 (no pattern) or 100 (pattern detected)
- **Type**: Single-candle reversal pattern
- **Lag**: Real-time pattern recognition (no calculation lag)
- **Best Used**: At trend extremes, support/resistance levels, after extended moves
- **Reliability**: Medium to high when confirmed with volume and context

## Interpretation

### Value Ranges

- **0**: No Doji pattern detected in this period
- **100**: Doji pattern detected - indecision present

### Pattern Types

The Doji family includes several variations, each with slightly different implications:

#### Standard Doji
- Open ≈ Close with shadows on both sides
- Indicates pure indecision
- Neutral until context is considered

#### Long-Legged Doji
- Open ≈ Close with long upper and lower shadows
- Shows high volatility and indecision
- Strong rejection of both higher and lower prices
- More significant than standard Doji

#### Gravestone Doji
- Open ≈ Close at the day's low
- Long upper shadow, no lower shadow
- Buyers pushed prices up but failed to hold
- Bearish implications, especially after uptrend

#### Dragonfly Doji
- Open ≈ Close at the day's high
- Long lower shadow, no upper shadow
- Sellers pushed prices down but buyers recovered
- Bullish implications, especially after downtrend

### Market Psychology

The Doji represents a tug-of-war between bulls and bears:

1. **Battle for Control**: Neither side can maintain dominance
2. **Trend Exhaustion**: Previous trend participants losing conviction
3. **Uncertainty**: Market participants unsure of next direction
4. **Potential Shift**: Balance of power may be changing

### Signal Interpretation

**In Uptrend Context:**
- Suggests bullish momentum may be weakening
- Buyers unable to push prices significantly higher
- Potential top formation
- Requires bearish confirmation for reversal signal

**In Downtrend Context:**
- Suggests bearish momentum may be exhausting
- Sellers unable to push prices significantly lower
- Potential bottom formation
- Requires bullish confirmation for reversal signal

**At Support/Resistance:**
- Heightened significance
- Decision point for trend continuation or reversal
- High probability of significant move following confirmation

## Trading Signals

### Buy Signals

Doji patterns generate buy signals under specific conditions:

1. **After Downtrend**
   - Doji appears following declining prices
   - Particularly at support levels
   - RSI in oversold territory (< 30)
   - Confirmed by bullish candle close above Doji high

2. **Dragonfly Doji at Support**
   - Long lower shadow showing rejection of lower prices
   - Close near the high of the session
   - High volume on the shadow
   - Next candle closes above Doji body

**Example Scenario:**
```ruby
if doji[-2] == 100  # Previous candle was Doji
  # Check for bullish confirmation
  if close[-1] > high[-2]  # Confirmation candle broke above Doji high
    puts "Bullish Doji reversal confirmed - BUY signal"
    entry = close[-1]
    stop = low[-2]
    target = entry + (entry - stop) * 2
    puts "Entry: #{entry}, Stop: #{stop}, Target: #{target}"
  end
end
```

### Sell Signals

Doji patterns generate sell signals under these conditions:

1. **After Uptrend**
   - Doji appears following rising prices
   - Particularly at resistance levels
   - RSI in overbought territory (> 70)
   - Confirmed by bearish candle close below Doji low

2. **Gravestone Doji at Resistance**
   - Long upper shadow showing rejection of higher prices
   - Close near the low of the session
   - High volume on the shadow
   - Next candle closes below Doji body

**Example Scenario:**
```ruby
if doji[-2] == 100  # Previous candle was Doji
  # Check for bearish confirmation
  if close[-1] < low[-2]  # Confirmation candle broke below Doji low
    puts "Bearish Doji reversal confirmed - SELL signal"
    entry = close[-1]
    stop = high[-2]
    target = entry - (stop - entry) * 2
    puts "Entry: #{entry}, Stop: #{stop}, Target: #{target}"
  end
end
```

### Confirmation Requirements

Never trade a Doji in isolation. Require:

1. **Trend Context**: Clear preceding trend
2. **Next Candle Confirmation**: Price action validates the reversal
3. **Volume**: Higher than average volume adds conviction
4. **Technical Level**: Alignment with support, resistance, or moving averages
5. **Momentum Indicators**: RSI, MACD showing divergence or extremes

## Best Practices

### Optimal Use Cases

The Doji works best in these scenarios:

**Market Conditions:**
- After extended trends (3+ days in same direction)
- At clearly defined support or resistance zones
- During periods of high volume
- At the end of strong momentum moves

**Time Frames:**
- Daily charts: Most reliable
- Weekly charts: Very significant signals
- 4-hour charts: Good for swing trading
- Intraday (< 1 hour): Less reliable, need multiple confirmations

**Asset Classes:**
- Stocks: Excellent reliability
- Forex: Good with major pairs
- Commodities: Effective at key levels
- Cryptocurrencies: Requires larger confirmation candles due to volatility

### Combining with Other Indicators

**With Trend Indicators:**
```ruby
doji = SQA::TAI.cdl_doji(open, high, low, close)
sma_50 = SQA::TAI.sma(close, period: 50)
sma_200 = SQA::TAI.sma(close, period: 200)

if doji.last == 100
  if close[-2] > sma_50[-2] && close[-2] > sma_200[-2]
    puts "Doji in uptrend - watch for bearish reversal"
  elsif close[-2] < sma_50[-2] && close[-2] < sma_200[-2]
    puts "Doji in downtrend - watch for bullish reversal"
  end
end
```

**With Momentum Indicators:**
```ruby
doji = SQA::TAI.cdl_doji(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)

if doji.last == 100
  if rsi.last > 70
    puts "Doji + Overbought RSI - strong sell setup"
  elsif rsi.last < 30
    puts "Doji + Oversold RSI - strong buy setup"
  end
end
```

**With Volume:**
```ruby
doji = SQA::TAI.cdl_doji(open, high, low, close)
volume_sma = SQA::TAI.sma(volume, period: 20)

if doji.last == 100 && volume.last > volume_sma.last * 1.5
  puts "Doji with high volume - increased significance"
end
```

### Common Pitfalls

1. **Trading Without Confirmation**
   - Never enter immediately on Doji formation
   - Wait for next candle to validate direction
   - Premature entries lead to whipsaws

2. **Ignoring Context**
   - Doji in sideways market = low reliability
   - Doji mid-trend = often just pause, not reversal
   - Must appear at significant technical juncture

3. **No Volume Analysis**
   - Low volume Doji = weak signal
   - High volume Doji = strong conviction
   - Volume validates the indecision

4. **Wrong Time Frame**
   - Too short = noise and false signals
   - Too long = slow to react
   - Daily charts optimal for most traders

### Parameter Selection Guidelines

**Day Trading:**
- Use 15-minute or 1-hour charts
- Require tight stops (within Doji range)
- Need immediate confirmation (next 1-2 candles)
- Higher false signal rate

**Swing Trading:**
- Use daily charts primarily
- Allow 2-3 candles for confirmation
- Stop loss beyond Doji high/low
- Better reliability

**Position Trading:**
- Use daily or weekly charts
- Wait for full week of confirmation
- Wider stops acceptable
- Highest reliability but fewer signals

## Practical Example

Complete Doji trading system with confirmation:

```ruby
require 'sqa/tai'

# Load data
open, high, low, close, volume = load_ohlc_volume_data('GOOGL')

# Calculate indicators
doji = SQA::TAI.cdl_doji(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)
sma_50 = SQA::TAI.sma(close, period: 50)
volume_sma = SQA::TAI.sma(volume, period: 20)

# Check for Doji on previous candle
if doji[-2] == 100
  puts "Doji Pattern Analysis"
  puts "=" * 50

  # Determine trend context
  trend = close[-3] > sma_50[-3] ? "Uptrend" : "Downtrend"
  puts "Trend Context: #{trend}"

  # Check RSI
  rsi_val = rsi[-2]
  rsi_extreme = if rsi_val > 70
    "Overbought"
  elsif rsi_val < 30
    "Oversold"
  else
    "Neutral"
  end
  puts "RSI: #{rsi_val.round(2)} (#{rsi_extreme})"

  # Check volume
  vol_ratio = volume[-2] / volume_sma[-2]
  puts "Volume: #{vol_ratio > 1.3 ? 'High' : 'Normal'} (#{vol_ratio.round(2)}x avg)"

  # Find support/resistance
  recent_high = high[-60..-2].max
  recent_low = low[-60..-2].min
  at_resistance = (high[-2] - recent_high).abs < recent_high * 0.02
  at_support = (low[-2] - recent_low).abs < recent_low * 0.02

  if at_resistance
    puts "Location: Near Resistance (#{recent_high.round(2)})"
  elsif at_support
    puts "Location: Near Support (#{recent_low.round(2)})"
  else
    puts "Location: Mid-range"
  end

  # Check for confirmation
  confirmation = nil
  if close[-1] > high[-2]
    confirmation = "Bullish"
  elsif close[-1] < low[-2]
    confirmation = "Bearish"
  end

  if confirmation
    puts "\nCONFIRMATION: #{confirmation} breakout"

    # Calculate trade parameters
    if confirmation == "Bullish" && trend == "Downtrend" && rsi_val < 40
      entry = close[-1]
      stop = low[-2] - (low[-2] * 0.005)
      risk = entry - stop
      target = entry + (risk * 2.5)

      puts "\nBUY SIGNAL"
      puts "Entry: $#{entry.round(2)}"
      puts "Stop Loss: $#{stop.round(2)}"
      puts "Target: $#{target.round(2)}"
      puts "Risk: $#{risk.round(2)}"
      puts "Reward:Risk = 2.5:1"

    elsif confirmation == "Bearish" && trend == "Uptrend" && rsi_val > 60
      entry = close[-1]
      stop = high[-2] + (high[-2] * 0.005)
      risk = stop - entry
      target = entry - (risk * 2.5)

      puts "\nSELL SIGNAL"
      puts "Entry: $#{entry.round(2)}"
      puts "Stop Loss: $#{stop.round(2)}"
      puts "Target: $#{target.round(2)}"
      puts "Risk: $#{risk.round(2)}"
      puts "Reward:Risk = 2.5:1"
    end
  else
    puts "\nWaiting for confirmation candle..."
  end
end
```

## Related Indicators

### Similar Patterns

- **[Spinning Top](cdl_spinningtop.md)**: Small body with shadows on both sides, similar indecision but body can be colored
- **[Hammer](cdl_hammer.md)**: Bullish reversal with small body and long lower shadow
- **[Shooting Star](cdl_shootingstar.md)**: Bearish reversal with small body and long upper shadow

### Complementary Patterns

- **[Morning Star](cdl_morningstar.md)**: Three-candle bullish reversal often featuring a Doji as middle candle
- **[Evening Star](cdl_eveningstar.md)**: Three-candle bearish reversal often featuring a Doji as middle candle
- **[Harami](cdl_harami.md)**: Two-candle pattern showing indecision similar to Doji

### Pattern Family

The Doji is part of the single-candle reversal pattern family:
- **Doji**: Open = Close, pure indecision
- **Gravestone Doji**: Bearish variant with long upper shadow
- **Dragonfly Doji**: Bullish variant with long lower shadow
- **Long-Legged Doji**: High volatility variant with long shadows on both sides

## Advanced Topics

### Multi-Timeframe Analysis

For higher probability trades, analyze Doji patterns across multiple timeframes:

```ruby
# Daily chart - primary signal
daily_doji = SQA::TAI.cdl_doji(daily_open, daily_high, daily_low, daily_close)

# Weekly chart - confirm larger trend
weekly_doji = SQA::TAI.cdl_doji(weekly_open, weekly_high, weekly_low, weekly_close)

# 4-hour chart - entry timing
hourly_doji = SQA::TAI.cdl_doji(hourly_open, hourly_high, hourly_low, hourly_close)

if daily_doji.last == 100 && weekly_trend == "down"
  puts "Daily Doji in weekly downtrend - watch for bullish reversal"
  puts "Use 4-hour chart for precise entry timing"
end
```

### Market Regime Adaptation

**Trending Markets:**
- Doji more reliable as reversal signal
- Wait for strong confirmation
- Tighter stops acceptable

**Ranging Markets:**
- Doji less reliable (constant indecision)
- Require additional confirmation
- Focus on Doji at range boundaries

**High Volatility:**
- Expect longer shadows on Doji
- Require wider stops
- Pattern still valid but need larger confirmation

### Statistical Validation

Research indicates:
- **Success Rate**: 60-65% with proper confirmation
- **Best Performance**: After trends of 5+ days in same direction
- **Volume Impact**: High volume Doji 15-20% more reliable
- **Time Frame**: Daily charts 10-15% more reliable than intraday
- **Confirmation**: Waiting for confirmation increases success by 25-30%

## References

- Nison, Steve. "Japanese Candlestick Charting Techniques" - The definitive guide to candlestick patterns including the Doji
- Bulkowski, Thomas N. "Encyclopedia of Candlestick Charts" - Statistical analysis of Doji reliability
- Morris, Gregory L. "Candlestick Charting Explained" - Practical application of Doji patterns
- [StockCharts.com - Doji](https://stockcharts.com/school/doku.php?id=chart_school:chart_analysis:introduction_to_candlesticks#doji) - Online reference and examples

## See Also

- [Candlestick Pattern Overview](../patterns/index.md)
- [Dragonfly Doji Pattern](cdl_dragonflydoji.md)
- [Gravestone Doji Pattern](cdl_gravestonedoji.md)
- [Doji Star Pattern](cdl_dojistar.md)
- [Morning Star Pattern](cdl_morningstar.md)
- [Evening Star Pattern](cdl_eveningstar.md)
- [RSI Indicator](../momentum/rsi.md)
