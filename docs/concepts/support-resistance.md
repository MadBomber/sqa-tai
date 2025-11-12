# Support and Resistance

Support and resistance are fundamental concepts in technical analysis representing price levels where buying or selling pressure tends to overcome opposing forces.

## What is Support?

**Support** is a price level where buying demand is strong enough to prevent the price from falling further.

Think of support as a "floor" under the price:
- Price approaches support and bounces upward
- Buyers outnumber sellers at this level
- Acts as a potential entry point for long positions

## What is Resistance?

**Resistance** is a price level where selling pressure is strong enough to prevent the price from rising further.

Think of resistance as a "ceiling" above the price:
- Price approaches resistance and reverses downward
- Sellers outnumber buyers at this level
- Acts as a potential exit point or short entry

## Identifying Support and Resistance

### Historical Price Levels

```ruby
# Find support - lowest price in recent period
support = low_prices.last(20).min

# Find resistance - highest price in recent period
resistance = high_prices.last(20).max
```

### Round Numbers

Psychological levels often act as support/resistance:
- $50, $100, $1000 (round numbers)
- Previous all-time highs
- 52-week highs/lows

### Moving Averages

Dynamic support/resistance:
```ruby
sma_200 = SQA::TAI.sma(close, period: 200)

# 200-day SMA often acts as major support/resistance
if close.last > sma_200.last
  puts "Price above 200 SMA - bullish"
else
  puts "Price below 200 SMA - bearish"
end
```

### Previous Highs and Lows

- Previous resistance often becomes support after breakout
- Previous support often becomes resistance after breakdown

## Trading with Support and Resistance

### Buying at Support

```ruby
support_level = 48.50

if close.last <= support_level * 1.01  # Within 1% of support
  rsi = SQA::TAI.rsi(close, period: 14)

  if rsi.last < 40
    puts "Buy signal: Price at support + oversold RSI"
    puts "Entry: $#{close.last}"
    puts "Stop: $#{(support_level * 0.98).round(2)}"  # Below support
    puts "Target: $#{resistance_level.round(2)}"
  end
end
```

### Selling at Resistance

```ruby
resistance_level = 52.00

if close.last >= resistance_level * 0.99  # Within 1% of resistance
  rsi = SQA::TAI.rsi(close, period: 14)

  if rsi.last > 60
    puts "Sell signal: Price at resistance + overbought RSI"
    puts "Entry: $#{close.last}"
    puts "Stop: $#{(resistance_level * 1.02).round(2)}"  # Above resistance
    puts "Target: $#{support_level.round(2)}"
  end
end
```

### Breakout Trading

When price breaks through support or resistance:

```ruby
# Breakout above resistance
if close.last > resistance && close[-2] <= resistance
  volume_surge = volume.last > (volume[-20..-2].sum / 19 * 1.5)

  if volume_surge
    puts "Valid breakout above resistance on high volume"
    puts "New support formed at: $#{resistance.round(2)}"
  else
    puts "Weak breakout - low volume, may be false"
  end
end
```

## Support and Resistance Strength

### Multiple Tests

The more times a level is tested without breaking, the stronger it becomes:
- 2 tests: Weak support/resistance
- 3-4 tests: Moderate strength
- 5+ tests: Strong support/resistance

### Volume

Higher volume at a level increases its significance:
```ruby
# Check volume at price level
if price_at_level && volume.last > avg_volume * 1.5
  puts "Strong support/resistance - high volume"
end
```

### Timeframe

Support/resistance on higher timeframes is more significant:
- Monthly levels > Weekly levels > Daily levels

## Role Reversal

Support becomes resistance (and vice versa) after a break:

```ruby
old_resistance = 50.00

# After breakout above
if close.last > old_resistance
  puts "Old resistance at $50 now acts as support"
  puts "Look for pullbacks to $50 for entries"
end
```

## Using SQA::TAI with Support/Resistance

### Pivot Points

```ruby
# Calculate pivot points
typical_price = SQA::TAI.typprice(high, low, close)
pivot = typical_price.last

resistance_1 = (2 * pivot) - low.last
support_1 = (2 * pivot) - high.last

puts "Pivot: $#{pivot.round(2)}"
puts "R1: $#{resistance_1.round(2)}"
puts "S1: $#{support_1.round(2)}"
```

### Bollinger Bands

```ruby
# Bands act as dynamic support/resistance
upper, middle, lower = SQA::TAI.bbands(close, period: 20)

if close.last < lower.last
  puts "Price at lower band (support)"
elsif close.last > upper.last
  puts "Price at upper band (resistance)"
end
```

### ATR for Stop Placement

```ruby
atr = SQA::TAI.atr(high, low, close, period: 14)

# Place stop below support using ATR
stop_distance = 2 * atr.last
stop_loss = support_level - stop_distance

puts "Support: $#{support_level.round(2)}"
puts "Stop Loss: $#{stop_loss.round(2)}"
```

## See Also

- [Basics Guide](../basics.md)
- [Pattern Recognition](../getting-started/pattern-recognition.md)
- [Bollinger Bands](../indicators/overlap/bbands.md)
- [ATR](../indicators/volatility/atr.md)
