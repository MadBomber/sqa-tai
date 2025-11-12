# Technical Indicators

SQA::TAI provides access to 200+ technical analysis indicators from the TA-Lib C library. All indicators are accessible through simple, intuitive Ruby methods.

## Indicator Categories

### Overlap Studies

Moving averages and bands that overlay price charts:

- [Simple Moving Average (SMA)](overlap/sma.md)
- [Exponential Moving Average (EMA)](overlap/ema.md)
- [Weighted Moving Average (WMA)](overlap/wma.md)
- [Bollinger Bands (BBANDS)](overlap/bbands.md)

### Momentum Indicators

Measure the rate of price change:

- [Relative Strength Index (RSI)](momentum/rsi.md)
- [Moving Average Convergence/Divergence (MACD)](momentum/macd.md)
- [Stochastic Oscillator (STOCH)](momentum/stoch.md)
- [Momentum (MOM)](momentum/mom.md)

### Volatility Indicators

Measure market volatility and price range:

- [Average True Range (ATR)](volatility/atr.md)
- [True Range (TRANGE)](volatility/trange.md)

### Volume Indicators

Analyze trading volume:

- [On Balance Volume (OBV)](volume/obv.md)
- [Chaikin A/D Line (AD)](volume/ad.md)

### Pattern Recognition

Identify candlestick patterns:

- [Doji](patterns/cdl_doji.md)
- [Hammer](patterns/cdl_hammer.md)
- [Engulfing Pattern](patterns/cdl_engulfing.md)
- [View All Patterns](patterns/index.md)

### Cycle Indicators

Hilbert Transform indicators for cycle analysis:

- [HT Dominant Cycle Period](cycle/ht_dcperiod.md)
- [HT Trend vs Cycle Mode](cycle/ht_trendmode.md)
- [View All Cycle Indicators](cycle/index.md)

### Price Transform Indicators

Transform OHLC data into representative prices:

- [Typical Price](price_transform/typprice.md)
- [Weighted Close Price](price_transform/wclprice.md)
- [View All Price Transforms](price_transform/index.md)

### Statistical Indicators

Statistical functions for trend analysis:

- [Linear Regression](statistical/linearreg.md)
- [Standard Deviation](statistical/stddev.md)
- [View All Statistical Indicators](statistical/index.md)

## Usage Overview

All indicators follow a consistent API pattern:

```ruby
require 'sqa/tai'

# Single input, single output
result = SQA::TAI.sma(prices, period: 10)

# Single input, multiple outputs
upper, middle, lower = SQA::TAI.bbands(prices, period: 20)

# Multiple inputs (OHLC data)
atr = SQA::TAI.atr(high, low, close, period: 14)
```

## Common Parameters

Most indicators accept these standard parameters:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `period` | Time period for calculation | Varies by indicator |
| `ma_type` | Moving average type (0=SMA, 1=EMA, etc.) | 0 (SMA) |
| `nbdev_up` | Standard deviations for upper band | 2.0 |
| `nbdev_down` | Standard deviations for lower band | 2.0 |

## Return Values

- Single output indicators return an array
- Multiple output indicators return multiple arrays
- Arrays may contain `nil` values for the warmup period
- Use `.compact` to filter out `nil` values
- Use `.last` to get the most recent value

## Best Practices

1. **Ensure sufficient data** - Most indicators need a warmup period
2. **Handle nil values** - Check for nil before using values
3. **Validate parameters** - Use appropriate period lengths for your timeframe
4. **Combine indicators** - Use multiple indicators for confirmation
5. **Backtest strategies** - Always test before live trading

## Example: Multi-Indicator Analysis

```ruby
require 'sqa/tai'

# Load historical data
prices = load_stock_data('AAPL')

# Trend: Moving averages
sma_20 = SQA::TAI.sma(prices, period: 20)
sma_50 = SQA::TAI.sma(prices, period: 50)

# Momentum: RSI
rsi = SQA::TAI.rsi(prices, period: 14)

# Volatility: Bollinger Bands
upper, middle, lower = SQA::TAI.bbands(prices, period: 20)

# Analyze current conditions
current_price = prices.last
current_rsi = rsi.last

if current_price > sma_20.last && current_price > sma_50.last
  puts "Uptrend confirmed"
end

if current_rsi < 30
  puts "Oversold condition"
elsif current_rsi > 70
  puts "Overbought condition"
end

if current_price < lower.last
  puts "Price below lower Bollinger Band"
end
```

## See Also

- [Basic Usage Guide](../getting-started/basic-usage.md)
- [API Reference](../api-reference.md)
- [Examples](../examples/trend-analysis.md)
