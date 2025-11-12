# Adaptive Indicator Examples

Examples of adaptive indicators that adjust to market conditions.

## Adaptive Moving Average

```ruby
require 'sqa/tai'

# KAMA - Kaufman Adaptive Moving Average
def adaptive_ma_example(close)
  kama = SQA::TAI.kama(close, period: 10)

  # KAMA adapts to volatility
  # Faster in trending markets, slower in choppy markets

  if close.last > kama.last
    puts "Price above adaptive MA - bullish"
  else
    puts "Price below adaptive MA - bearish"
  end

  kama
end
```

## Adaptive Period Based on Volatility

```ruby
def adaptive_period_strategy(high, low, close)
  # Use ATR to determine market volatility
  atr = SQA::TAI.atr(high, low, close, period: 14)
  atr_pct = (atr.last / close.last * 100)

  # Adjust indicator period based on volatility
  period = if atr_pct > 3.0
    10  # Use shorter period in volatile markets
  elsif atr_pct > 1.5
    20  # Medium period
  else
    30  # Longer period in calm markets
  end

  # Apply adaptive period to RSI
  rsi = SQA::TAI.rsi(close, period: period)

  {
    atr_pct: atr_pct.round(2),
    period: period,
    rsi: rsi.last.round(2)
  }
end
```

## See Also

- [Basics](../basics.md)
- [KAMA](../indicators/overlap/kama.md)
- [ATR](../indicators/volatility/atr.md)
