# Technical Analysis Basics

A foundational guide to understanding technical analysis concepts used throughout the SQA::TAI library.

## What is Technical Analysis?

Technical analysis is the study of historical price and volume data to forecast future price movements. Unlike fundamental analysis which examines company financials, technical analysis focuses solely on price action and market behavior.

### Core Principles

1. **Price Discounts Everything**: All information is reflected in the price
2. **Price Moves in Trends**: Markets trend more often than they range
3. **History Tends to Repeat**: Human psychology creates repeating patterns

## Basic Concepts

### Price Data (OHLC)

Every trading period has four key prices:

```ruby
open  = [50.0, 51.0, 52.0]  # Opening price
high  = [51.5, 52.5, 53.0]  # Highest price
low   = [49.5, 50.5, 51.5]  # Lowest price
close = [51.0, 52.0, 52.5]  # Closing price
```

**Understanding OHLC**:
- **Open**: First traded price of the period
- **High**: Highest price during the period
- **Low**: Lowest price during the period
- **Close**: Last traded price of the period (most important)

### Candlesticks

Visual representation of OHLC data:

```
      High
       |
    |-----|    Body (Open to Close)
    |     |
    |-----|
       |
      Low
```

**Candlestick Colors**:
- **Bullish (Green/White)**: Close > Open (prices rose)
- **Bearish (Red/Black)**: Close < Open (prices fell)

### Trends

Market direction over time:

**Uptrend**: Higher highs and higher lows
```
      /\    /\
     /  \  /  \
    /    \/    \
```

**Downtrend**: Lower highs and lower lows
```
\    /\    /
 \  /  \  /
  \/    \/
```

**Sideways**: No clear direction, ranging between support and resistance

### Support and Resistance

**Support**: Price level where buying pressure overcomes selling pressure
- Acts as a "floor" for prices
- Price tends to bounce up from support

**Resistance**: Price level where selling pressure overcomes buying pressure
- Acts as a "ceiling" for prices
- Price tends to reverse down at resistance

## Using SQA::TAI

### Basic Indicator Usage

```ruby
require 'sqa/tai'

# Load price data
close_prices = [44.34, 44.09, 44.15, 43.61, 44.33,
                44.83, 45.10, 45.42, 45.84, 46.08]

# Calculate a simple moving average
sma = SQA::TAI.sma(close_prices, period: 5)

puts "SMA: #{sma.last}"
# Output: SMA: 45.156
```

### Working with Multiple Outputs

Some indicators return multiple arrays:

```ruby
# Bollinger Bands returns 3 arrays
upper, middle, lower = SQA::TAI.bbands(close_prices, period: 20)

puts "Upper Band: #{upper.last}"
puts "Middle Band: #{middle.last}"
puts "Lower Band: #{lower.last}"
```

### Handling Nil Values

Indicators need warmup periods:

```ruby
prices = [10, 11, 12, 13, 14]
sma = SQA::TAI.sma(prices, period: 5)

# First 4 values will be nil (warmup period)
puts sma.inspect
# => [nil, nil, nil, nil, 12.0]

# Get only valid values
valid_sma = sma.compact
puts valid_sma.last  # Most recent valid value
```

## Common Indicator Types

### Trend Indicators

Identify market direction:
- [Moving Averages (SMA, EMA)](indicators/overlap/sma.md)
- [MACD](indicators/momentum/macd.md)
- [ADX](indicators/momentum/adx.md)

### Momentum Indicators

Measure rate of price change:
- [RSI](indicators/momentum/rsi.md)
- [Stochastic](indicators/momentum/stoch.md)
- [CCI](indicators/momentum/cci.md)

### Volatility Indicators

Measure price variation:
- [Bollinger Bands](indicators/overlap/bbands.md)
- [ATR](indicators/volatility/atr.md)
- [Standard Deviation](indicators/statistical/stddev.md)

### Volume Indicators

Analyze trading volume:
- [OBV](indicators/volume/obv.md)
- [A/D Line](indicators/volume/ad.md)
- [Money Flow Index](indicators/momentum/mfi.md)

## Essential Technical Analysis Concepts

### Moving Averages

Average price over a period, smoothing out noise:

```ruby
# 20-period Simple Moving Average
sma_20 = SQA::TAI.sma(close, period: 20)

# Price above MA = uptrend
# Price below MA = downtrend
```

### Crossovers

When two indicators cross, signaling potential trades:

```ruby
# Golden Cross (bullish)
sma_50 = SQA::TAI.sma(close, period: 50)
sma_200 = SQA::TAI.sma(close, period: 200)

if sma_50.last > sma_200.last && sma_50[-2] <= sma_200[-2]
  puts "Golden Cross - Bullish signal"
end
```

### Overbought/Oversold

When price has moved too far, too fast:

```ruby
rsi = SQA::TAI.rsi(close, period: 14)

if rsi.last > 70
  puts "Overbought - potential reversal down"
elsif rsi.last < 30
  puts "Oversold - potential reversal up"
end
```

### Divergence

When price and indicator disagree:

```ruby
# Bearish divergence
if close.last > close[-10] && rsi.last < rsi[-10]
  puts "Bearish divergence - price up, RSI down"
  puts "Potential trend reversal"
end
```

## Trading Strategy Basics

### Entry Signals

Combine multiple indicators:

```ruby
# Trend + Momentum + Pattern
ema_20 = SQA::TAI.ema(close, period: 20)
rsi = SQA::TAI.rsi(close, period: 14)
macd, signal, hist = SQA::TAI.macd(close)

# All aligned for long entry
if close.last > ema_20.last &&    # Uptrend
   rsi.last > 50 && rsi.last < 70 &&  # Strong but not overbought
   macd.last > signal.last          # MACD bullish
  puts "Strong buy setup"
end
```

### Risk Management

Always use stop losses:

```ruby
entry_price = close.last
atr = SQA::TAI.atr(high, low, close, period: 14)

# Stop loss 2 ATR below entry
stop_loss = entry_price - (2 * atr.last)

# Target 3 ATR above entry (1:1.5 risk:reward)
take_profit = entry_price + (3 * atr.last)

puts "Entry: $#{entry_price.round(2)}"
puts "Stop: $#{stop_loss.round(2)}"
puts "Target: $#{take_profit.round(2)}"
```

### Position Sizing

Risk only 1-2% per trade:

```ruby
account_size = 10000
risk_per_trade = 0.02  # 2%
risk_amount = account_size * risk_per_trade

stop_distance = entry_price - stop_loss
shares = (risk_amount / stop_distance).floor

puts "Position size: #{shares} shares"
puts "Risk: $#{risk_amount}"
```

## Best Practices

### 1. Use Multiple Timeframes

Analyze larger timeframe first:
- Daily chart: Identify overall trend
- 4-hour chart: Find entry points
- 1-hour chart: Fine-tune timing

### 2. Confirm Signals

Don't act on single indicator:
- Trend confirmation (moving averages)
- Momentum confirmation (RSI, MACD)
- Volume confirmation (OBV, volume)
- Pattern confirmation (candlesticks)

### 3. Manage Risk

Every trade should have:
- Predetermined stop loss
- Position size calculated on risk
- Take profit target
- Risk/reward ratio of 1:2 or better

### 4. Keep a Trading Journal

Track:
- Entry and exit prices
- Indicators used
- Why you entered the trade
- What went right/wrong
- Lessons learned

## Common Mistakes to Avoid

1. **Overtrading**: Not every signal is worth trading
2. **No Stop Loss**: Always protect your capital
3. **Fighting the Trend**: Trade with the trend, not against it
4. **Overleveraging**: Risk too much on single trades
5. **Indicator Overload**: Too many indicators create confusion
6. **Ignoring Volume**: Volume validates price movements
7. **Emotional Trading**: Stick to your system

## Timeframes

Different timeframes for different styles:

| Timeframe | Trading Style | Hold Time |
|-----------|--------------|-----------|
| 1-5 min | Scalping | Minutes |
| 15-60 min | Day Trading | Hours |
| 4-hour, Daily | Swing Trading | Days to weeks |
| Weekly, Monthly | Position Trading | Months to years |

## Getting Started

### 1. Learn the Basics
- Read [Getting Started Guide](getting-started/quick-start.md)
- Understand [Pattern Recognition](getting-started/pattern-recognition.md)
- Study [Indicator Categories](indicators/index.md)

### 2. Practice
- Use historical data for backtesting
- Paper trade before using real money
- Start with simple strategies

### 3. Build Your System
- Choose 2-3 complementary indicators
- Define clear entry and exit rules
- Test on different market conditions
- Track performance

## Resources

### Documentation
- [Indicator Reference](indicators/index.md)
- [API Documentation](api-reference.md)
- [Pattern Recognition Guide](getting-started/pattern-recognition.md)

### Learning Path
1. **Beginner**: SMA, RSI, MACD, basic candlesticks
2. **Intermediate**: Bollinger Bands, Stochastic, ADX, pattern combinations
3. **Advanced**: Cycle analysis, multi-timeframe strategies, custom systems

## Example: Complete Analysis

```ruby
require 'sqa/tai'

# Load data
open, high, low, close, volume = load_market_data('AAPL')

# Trend Analysis
sma_20 = SQA::TAI.sma(close, period: 20)
sma_50 = SQA::TAI.sma(close, period: 50)
trend = close.last > sma_50.last ? "Uptrend" : "Downtrend"

# Momentum
rsi = SQA::TAI.rsi(close, period: 14)
macd, signal, hist = SQA::TAI.macd(close)

# Volatility
atr = SQA::TAI.atr(high, low, close, period: 14)
upper, middle, lower = SQA::TAI.bbands(close, period: 20)

# Volume
obv = SQA::TAI.obv(close, volume)

puts "Technical Analysis Summary"
puts "=" * 50
puts "Trend: #{trend}"
puts "Price: $#{close.last.round(2)}"
puts "SMA(20): $#{sma_20.last.round(2)}"
puts "SMA(50): $#{sma_50.last.round(2)}"
puts "RSI(14): #{rsi.last.round(2)}"
puts "MACD: #{macd.last.round(2)}"
puts "ATR(14): $#{atr.last.round(2)}"
puts "BB Position: #{((close.last - lower.last) / (upper.last - lower.last) * 100).round(0)}%"

# Trading Decision
if trend == "Uptrend" &&
   rsi.last > 40 && rsi.last < 70 &&
   macd.last > signal.last &&
   obv.last > obv[-5]
  puts "\nSignal: STRONG BUY"
  puts "Confluence of trend, momentum, and volume"
end
```

## Next Steps

- [Quick Start Guide](getting-started/quick-start.md)
- [Pattern Recognition](getting-started/pattern-recognition.md)
- [Browse All Indicators](indicators/index.md)
- [View Code Examples](getting-started/basic-usage.md)
