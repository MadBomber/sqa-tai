# API Reference

Complete API reference for SQA::TALib.

## Module Methods

### `SQA::TALib.available?`

Check if TA-Lib C library is available.

**Returns:** `Boolean`

```ruby
if SQA::TALib.available?
  puts "TA-Lib is ready"
end
```

### `SQA::TALib.check_available!`

Verify TA-Lib is available, raise error if not.

**Raises:** `SQA::TALib::TALibNotInstalledError`

```ruby
SQA::TALib.check_available!
# Raises error if TA-Lib not found
```

## Overlap Studies

### `SQA::TALib.sma(prices, period:)`

Simple Moving Average.

**Parameters:**
- `prices` (Array<Float>) - Price data
- `period` (Integer) - Time period (default: 30)

**Returns:** Array<Float>

```ruby
sma = SQA::TALib.sma(prices, period: 20)
```

### `SQA::TALib.ema(prices, period:)`

Exponential Moving Average.

**Parameters:**
- `prices` (Array<Float>) - Price data
- `period` (Integer) - Time period (default: 30)

**Returns:** Array<Float>

```ruby
ema = SQA::TALib.ema(prices, period: 20)
```

### `SQA::TALib.wma(prices, period:)`

Weighted Moving Average.

**Parameters:**
- `prices` (Array<Float>) - Price data
- `period` (Integer) - Time period (default: 30)

**Returns:** Array<Float>

```ruby
wma = SQA::TALib.wma(prices, period: 20)
```

### `SQA::TALib.bbands(prices, period:, nbdev_up:, nbdev_down:)`

Bollinger Bands.

**Parameters:**
- `prices` (Array<Float>) - Price data
- `period` (Integer) - Time period (default: 5)
- `nbdev_up` (Float) - Upper deviation (default: 2.0)
- `nbdev_down` (Float) - Lower deviation (default: 2.0)

**Returns:** Array<Array<Float>> - [upper, middle, lower]

```ruby
upper, middle, lower = SQA::TALib.bbands(
  prices,
  period: 20,
  nbdev_up: 2.0,
  nbdev_down: 2.0
)
```

## Momentum Indicators

### `SQA::TALib.rsi(prices, period:)`

Relative Strength Index.

**Parameters:**
- `prices` (Array<Float>) - Price data
- `period` (Integer) - Time period (default: 14)

**Returns:** Array<Float> - Values between 0-100

```ruby
rsi = SQA::TALib.rsi(prices, period: 14)
```

### `SQA::TALib.macd(prices, fast_period:, slow_period:, signal_period:)`

Moving Average Convergence/Divergence.

**Parameters:**
- `prices` (Array<Float>) - Price data
- `fast_period` (Integer) - Fast period (default: 12)
- `slow_period` (Integer) - Slow period (default: 26)
- `signal_period` (Integer) - Signal period (default: 9)

**Returns:** Array<Array<Float>> - [macd, signal, histogram]

```ruby
macd, signal, histogram = SQA::TALib.macd(prices)

# With custom periods
macd, signal, histogram = SQA::TALib.macd(
  prices,
  fast_period: 12,
  slow_period: 26,
  signal_period: 9
)
```

### `SQA::TALib.stoch(high, low, close, fastk_period:, slowk_period:, slowd_period:)`

Stochastic Oscillator.

**Parameters:**
- `high` (Array<Float>) - High prices
- `low` (Array<Float>) - Low prices
- `close` (Array<Float>) - Close prices
- `fastk_period` (Integer) - Fast K period (default: 5)
- `slowk_period` (Integer) - Slow K period (default: 3)
- `slowd_period` (Integer) - Slow D period (default: 3)

**Returns:** Array<Array<Float>> - [slowk, slowd]

```ruby
slowk, slowd = SQA::TALib.stoch(high, low, close)
```

### `SQA::TALib.mom(prices, period:)`

Momentum.

**Parameters:**
- `prices` (Array<Float>) - Price data
- `period` (Integer) - Time period (default: 10)

**Returns:** Array<Float>

```ruby
mom = SQA::TALib.mom(prices, period: 10)
```

## Volatility Indicators

### `SQA::TALib.atr(high, low, close, period:)`

Average True Range.

**Parameters:**
- `high` (Array<Float>) - High prices
- `low` (Array<Float>) - Low prices
- `close` (Array<Float>) - Close prices
- `period` (Integer) - Time period (default: 14)

**Returns:** Array<Float>

```ruby
atr = SQA::TALib.atr(high, low, close, period: 14)
```

### `SQA::TALib.trange(high, low, close)`

True Range.

**Parameters:**
- `high` (Array<Float>) - High prices
- `low` (Array<Float>) - Low prices
- `close` (Array<Float>) - Close prices

**Returns:** Array<Float>

```ruby
tr = SQA::TALib.trange(high, low, close)
```

## Volume Indicators

### `SQA::TALib.obv(close, volume)`

On Balance Volume.

**Parameters:**
- `close` (Array<Float>) - Close prices
- `volume` (Array<Float>) - Volume data

**Returns:** Array<Float>

```ruby
obv = SQA::TALib.obv(close, volume)
```

### `SQA::TALib.ad(high, low, close, volume)`

Chaikin A/D Line.

**Parameters:**
- `high` (Array<Float>) - High prices
- `low` (Array<Float>) - Low prices
- `close` (Array<Float>) - Close prices
- `volume` (Array<Float>) - Volume data

**Returns:** Array<Float>

```ruby
ad = SQA::TALib.ad(high, low, close, volume)
```

## Pattern Recognition

### `SQA::TALib.cdl_doji(open, high, low, close)`

Doji candlestick pattern.

**Parameters:**
- `open` (Array<Float>) - Open prices
- `high` (Array<Float>) - High prices
- `low` (Array<Float>) - Low prices
- `close` (Array<Float>) - Close prices

**Returns:** Array<Integer> - Values: -100, 0, or 100

```ruby
doji = SQA::TALib.cdl_doji(open, high, low, close)
```

### `SQA::TALib.cdl_hammer(open, high, low, close)`

Hammer candlestick pattern.

**Returns:** Array<Integer> - Values: -100, 0, or 100

```ruby
hammer = SQA::TALib.cdl_hammer(open, high, low, close)
```

### `SQA::TALib.cdl_engulfing(open, high, low, close)`

Engulfing candlestick pattern.

**Returns:** Array<Integer> - Values: -100, 0, or 100

```ruby
engulfing = SQA::TALib.cdl_engulfing(open, high, low, close)
```

## Exceptions

### `SQA::TALib::Error`

Base error class for all SQA::TALib errors.

### `SQA::TALib::TALibNotInstalledError`

Raised when TA-Lib C library is not installed or not found.

### `SQA::TALib::InvalidParameterError`

Raised when invalid parameters are provided to an indicator function.

**Common causes:**
- Empty or nil price array
- Period larger than data size
- Negative period values
- Non-array parameters

```ruby
begin
  SQA::TALib.sma([], period: 5)
rescue SQA::TALib::InvalidParameterError => e
  puts e.message
  # => "Prices array cannot be empty"
end
```
