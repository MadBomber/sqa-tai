# NATR (Normalized Average True Range)

## Overview

The Normalized Average True Range (NATR) is a volatility indicator that expresses the Average True Range (ATR) as a percentage of the closing price. By normalizing ATR, NATR allows traders to compare volatility across different securities regardless of their price levels, making it ideal for portfolio analysis, cross-asset comparisons, and relative volatility assessments. A stock trading at $10 with an ATR of $0.50 has the same NATR as a stock at $100 with an ATR of $5.00 (both 5%).

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `high` | Array | Required | Array of high prices for each period |
| `low` | Array | Required | Array of low prices for each period |
| `close` | Array | Required | Array of closing prices for each period |
| `period` | Integer | 14 | Number of periods for ATR calculation |

### Parameter Details

**high, low, close**
- Same requirements as ATR calculation
- Must have same length
- Need sufficient data (at least period + 1 values)
- NATR first calculates ATR, then normalizes by close price

**period**
- Default is 14 periods (Wilder's original ATR setting)
- Represents lookback period for averaging true range
- Shorter periods (7-10): More responsive to recent volatility changes
- Longer periods (21-30): Smoother, better for long-term volatility assessment
- Common settings:
  - Day trading: 7-10 periods
  - Swing trading: 14 periods (standard)
  - Position trading: 21-30 periods

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

high  = [48.70, 48.72, 48.90, 48.87, 48.82, 49.05, 49.20, 49.35,
         49.92, 50.19, 50.12, 50.10, 50.00, 49.75, 49.80]
low   = [47.79, 48.14, 48.39, 48.37, 48.24, 48.64, 48.94, 49.03,
         49.50, 49.87, 49.20, 49.00, 48.90, 49.00, 49.10]
close = [48.20, 48.61, 48.75, 48.63, 48.74, 49.03, 49.07, 49.32,
         49.91, 50.13, 49.53, 49.50, 49.25, 49.20, 49.45]

# Calculate NATR with default 14-period setting
natr = SQA::TAI.natr(high, low, close, period: 14)

puts "Current NATR: #{natr.last.round(2)}%"
```

### With Custom Parameters

```ruby
# Short-term volatility (7-period)
natr_short = SQA::TAI.natr(high, low, close, period: 7)

# Long-term volatility (21-period)
natr_long = SQA::TAI.natr(high, low, close, period: 21)

puts "7-day NATR: #{natr_short.last.round(2)}%"
puts "14-day NATR: #{natr.last.round(2)}%"
puts "21-day NATR: #{natr_long.last.round(2)}%"
```

### Comparing Multiple Assets

```ruby
# Compare volatility across different securities
symbols = ['AAPL', 'GOOGL', 'TSLA', 'SPY']

volatility_comparison = symbols.map do |symbol|
  high, low, close = load_ohlc_data(symbol)
  natr = SQA::TAI.natr(high, low, close, period: 14)

  {
    symbol: symbol,
    price: close.last.round(2),
    natr: natr.last.round(2)
  }
end

# Sort by volatility (highest to lowest)
volatility_comparison.sort_by { |v| -v[:natr] }.each do |data|
  puts "#{data[:symbol]}: #{data[:natr]}% (Price: $#{data[:price]})"
end
```

## Understanding the Indicator

### What It Measures

NATR measures volatility relative to price level:

- **Relative Volatility**: Percentage-based volatility that's comparable across assets
- **Price-Adjusted Risk**: How much an asset moves relative to its price
- **Normalized Comparison**: Enables direct comparison between $10 and $1000 stocks
- **Portfolio Balancing**: Helps identify which positions have similar risk profiles

NATR answers: "What percentage of its price does this security typically move per period?"

### Calculation Method

NATR is calculated in two steps:

1. **Calculate ATR**: Standard Average True Range over the specified period
2. **Normalize by Close**: Divide ATR by current close price and multiply by 100

**Formula:**
```
NATR = (ATR / Close) × 100

Where:
- ATR = Average True Range over period
- Close = Current closing price
- Result expressed as percentage
```

**Example Calculation:**
```
Stock A: Price = $100, ATR = $3.00
NATR = (3.00 / 100) × 100 = 3.0%

Stock B: Price = $20, ATR = $0.60
NATR = (0.60 / 20) × 100 = 3.0%

Both stocks have same relative volatility despite different prices
```

### Indicator Characteristics

- **Range**: Unbounded positive percentage (typically 0.5% to 10%+)
- **Type**: Volatility measure, normalized oscillator
- **Lag**: Moderate (inherits ATR's smoothing lag)
- **Best Used**: Cross-asset comparisons, portfolio construction, relative risk assessment
- **Limitations**: Doesn't indicate direction, requires multiple assets for context

## Interpretation

### Value Ranges

Understanding NATR percentages:

- **Below 1%**: Very low volatility, stable price action. Common for utility stocks, bonds, stable large-caps.
- **1-2%**: Low to moderate volatility. Typical for established blue-chip stocks in normal conditions.
- **2-4%**: Moderate to elevated volatility. Common for growth stocks, mid-caps, or markets with some uncertainty.
- **4-7%**: High volatility. Seen in small-caps, growth stocks during earnings, or market stress periods.
- **Above 7%**: Very high volatility. Typical for speculative stocks, during major news, or market crashes.

**Context Matters**: Compare NATR to the asset's historical range and peer group averages.

### Key Patterns

- **Rising NATR**: Volatility expanding, risk increasing, uncertainty growing
- **Falling NATR**: Volatility contracting, risk decreasing, price stabilizing
- **Stable NATR**: Consistent volatility environment
- **NATR Spikes**: Sudden volatility events (earnings, news, market shocks)
- **Relative NATR**: High NATR vs peers suggests higher risk/reward potential

### Signal Interpretation

How to use NATR signals:

1. **Portfolio Risk Management**
   - High NATR assets: Reduce position size to maintain consistent portfolio risk
   - Low NATR assets: Can increase position size for balanced exposure
   - Target equal risk contribution across positions

2. **Asset Selection**
   - Compare NATR within sector to find outliers
   - High NATR = higher risk but potentially higher returns
   - Low NATR = lower risk but potentially lower returns
   - Match NATR to risk tolerance

3. **Market Regime Identification**
   - Rising NATR across market = increasing uncertainty
   - Falling NATR across market = stabilizing conditions
   - Divergent NATR = sector rotation or stock-specific issues

## Trading Signals

### Position Sizing Based on NATR

NATR is primarily used for risk management rather than entry/exit signals:

1. **Equal Risk Position Sizing**
   ```ruby
   # Size positions inversely to NATR for equal risk
   account_risk = 10000  # Risk $10k on this trade
   natr = 3.5  # 3.5% NATR

   # Stop loss at 2x NATR
   stop_distance_pct = natr * 2  # 7%
   position_value = account_risk / (stop_distance_pct / 100)

   shares = (position_value / current_price).floor
   ```

2. **Volatility Filtering**
   - Only trade assets with NATR in acceptable range
   - Example: Only trade stocks with 2-5% NATR
   - Avoids extremely volatile (whipsaw) or dead (no movement) stocks

3. **Dynamic Stop Losses**
   - Use NATR to set percentage-based stops
   - High NATR = wider stops, Low NATR = tighter stops
   - Example: Stop = 2 × NATR percentage

### Risk Adjustment Signals

**High NATR Alert (Above 6%):**
- Reduce position size by 30-50%
- Widen stop losses to avoid normal volatility
- Consider options strategies instead of stock
- Monitor more frequently for sudden moves

**Low NATR Alert (Below 1%):**
- Can increase position size moderately
- Tighten stop losses (less room needed)
- Suitable for larger positions
- Less frequent monitoring needed

**NATR Spike (2x average):**
- Volatility event occurring
- Avoid new entries until stabilization
- Widen existing stops temporarily
- May signal earnings, news, or market event

## Best Practices

### Optimal Use Cases

When NATR works best:

- **Portfolio construction**: Creating balanced risk exposure across multiple assets
- **Position sizing**: Determining appropriate position sizes based on volatility
- **Asset comparison**: Comparing relative volatility across different price levels
- **Risk management**: Setting stops and targets based on normalized volatility
- **Sector rotation**: Identifying changing volatility patterns by sector

### Combining with Other Indicators

Recommended combinations:

- **With ATR**: Use NATR for comparison, ATR for absolute dollar risk on specific positions

- **With RSI/MACD**: Combine NATR (volatility) with momentum indicators for complete picture
  - High NATR + oversold RSI = high-risk reversal opportunity
  - Low NATR + strong MACD = stable trending opportunity

- **With Bollinger Bands**: NATR confirms Band width changes
  - Rising NATR + expanding Bands = confirmed volatility increase
  - Falling NATR + contracting Bands = consolidation phase

### Common Pitfalls

What to avoid:

1. **Using as entry/exit signal**: NATR measures volatility, not direction. Don't use crosses or levels as trade signals.

2. **Ignoring historical context**: 3% NATR means different things for tech stocks vs utilities. Always compare to historical norms.

3. **Not adjusting for market conditions**: During market stress, "normal" NATR levels shift higher across all assets.

4. **Comparing across asset classes**: Don't compare stock NATR to forex or commodity NATR directly.

### Parameter Selection Guidelines

- **Short-term traders (day trading)**: 7-10 period NATR for recent volatility
- **Swing traders**: 14 period NATR (standard) for medium-term volatility
- **Position traders**: 21-30 period NATR for longer-term volatility profile
- **Backtesting**: Use period matching your typical holding period

## Practical Example

Complete portfolio risk management example:

```ruby
require 'sqa/tai'

# Portfolio of different stocks
portfolio = [
  { symbol: 'AAPL', shares: 100, price: 175.0 },
  { symbol: 'TSLA', shares: 50, price: 250.0 },
  { symbol: 'KO', shares: 200, price: 60.0 },
  { symbol: 'SPY', shares: 150, price: 450.0 }
]

# Calculate NATR for each position
portfolio.each do |position|
  high, low, close = load_ohlc_data(position[:symbol])
  natr = SQA::TAI.natr(high, low, close, period: 14)
  atr = SQA::TAI.atr(high, low, close, period: 14)

  position[:natr] = natr.last
  position[:atr] = atr.last
  position[:value] = position[:shares] * position[:price]
  position[:dollar_risk] = position[:shares] * (2 * atr.last)  # 2xATR stop
  position[:pct_risk] = (position[:dollar_risk] / position[:value]) * 100
end

puts "=== Portfolio Risk Analysis ==="
puts

portfolio.each do |pos|
  puts "#{pos[:symbol]}:"
  puts "  Position Value: $#{pos[:value].round(0)}"
  puts "  NATR: #{pos[:natr].round(2)}%"
  puts "  Dollar Risk (2xATR stop): $#{pos[:dollar_risk].round(0)}"
  puts "  % Risk of Position: #{pos[:pct_risk].round(2)}%"
  puts
end

# Identify high and low volatility positions
high_vol = portfolio.select { |p| p[:natr] > 4.0 }
low_vol = portfolio.select { |p| p[:natr] < 2.0 }

puts "High Volatility Positions (>4% NATR):"
high_vol.each { |p| puts "  #{p[:symbol]}: #{p[:natr].round(2)}%" }

puts "\nLow Volatility Positions (<2% NATR):"
low_vol.each { |p| puts "  #{p[:symbol]}: #{p[:natr].round(2)}%" }

# Calculate total portfolio dollar risk
total_risk = portfolio.sum { |p| p[:dollar_risk] }
total_value = portfolio.sum { |p| p[:value] }
portfolio_risk_pct = (total_risk / total_value) * 100

puts "\nPortfolio Summary:"
puts "  Total Value: $#{total_value.round(0)}"
puts "  Total Dollar Risk: $#{total_risk.round(0)}"
puts "  Portfolio Risk %: #{portfolio_risk_pct.round(2)}%"
```

## Related Indicators

### Similar Indicators
- **[Average True Range (ATR)](atr.md)**: The foundation of NATR. ATR for absolute dollar risk, NATR for relative percentage risk.

- **[Bollinger Band Width](../overlap/bbands.md)**: Another normalized volatility measure. Band Width uses standard deviation, NATR uses average true range.

### Complementary Indicators
- **[ATR](atr.md)**: Use together - NATR for comparison, ATR for position-specific risk calculations

- **[Standard Deviation](../statistical/stddev.md)**: Alternative volatility measure. NATR captures gaps and full range, StdDev focuses on close-to-close changes

### Indicator Family
NATR is part of the volatility measurement family:
- **True Range**: Single period volatility
- **ATR**: Average volatility in dollars
- **NATR**: Average volatility as percentage
- **Bollinger Bands**: Volatility bands around price

**When to prefer NATR**: For comparing volatility across different price levels, portfolio risk management, and cross-asset analysis. Use NATR when you need to answer "which asset is more volatile relative to its price?"

## Advanced Topics

### Multi-Timeframe Volatility Analysis

Using NATR across timeframes:

- **Daily NATR**: Standard reference for volatility
- **Weekly NATR**: Long-term volatility regime
- **Hourly NATR**: Intraday volatility patterns

Mismatches can reveal important insights (e.g., low daily NATR but high hourly NATR suggests intraday chop within tight daily range).

### Market Regime Adaptation

NATR in different market conditions:

- **Bull Markets**: Average NATR tends lower as prices grind higher
- **Bear Markets**: Average NATR spikes as fear drives volatility
- **Crisis Periods**: NATR can exceed 10-15% even for large-caps
- **Low Volatility Regimes**: NATR under 1% common for indexes and blue-chips

### Statistical Validation

NATR characteristics:

- **Mean Reversion**: High NATR tends to revert to average over time
- **Typical Ranges**: Most stocks have 1-5% NATR in normal conditions
- **Extreme Values**: NATR above 10% suggests special situation (earnings, news, crisis)
- **Correlation**: Rising NATR often coincides with downtrends (volatility and price negatively correlated)

## References

- Wilder, J. Welles Jr. "New Concepts in Technical Trading Systems" (1978) - ATR foundation
- [StockCharts: ATR and NATR](https://school.stockcharts.com/doku.php?id=technical_indicators:average_true_range_atr)
- [TradingView: NATR Documentation](https://www.tradingview.com/support/solutions/43000502332-normalized-average-true-range-natr/)

## See Also

- [Volatility Indicators Overview](../index.md)
- [ATR - Average True Range](atr.md)
- [TRANGE - True Range](trange.md)
- [Basic Usage Guide](../../getting-started/basic-usage.md)
