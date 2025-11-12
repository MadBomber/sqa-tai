# Variance (VAR)

The Variance indicator measures the dispersion of price returns around their mean, representing volatility squared. It quantifies how much prices fluctuate from the average, providing a statistical measure of risk and uncertainty in asset prices.

## Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41,
          46.22, 45.64, 46.21, 46.25, 46.08, 46.46]

# Calculate 5-period variance
variance = SQA::TAI.var(prices, period: 5)

debug_me "Current variance: #{variance.last.round(4)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prices` | Array<Float> | Yes | - | Array of price values |
| `period` | Integer | No | 5 | Number of periods for calculation |
| `nbdev` | Float/Array | No | 1.0 | Number of standard deviations (for advanced calculations) |

## Returns

Returns an array of variance values. The first `period-1` values will be `nil`. Variance is always non-negative, with higher values indicating greater dispersion/volatility.

## Formula

```
Variance = Σ(Price - Mean)² / N

Where:
  - N = number of periods
  - Mean = average price over period
  - Variance = VAR
  - Standard Deviation = √Variance
```

## Interpretation

| Variance Level | Interpretation | Risk Assessment |
|----------------|----------------|-----------------|
| High Variance | Large price swings, high volatility | Higher risk, wider stops needed |
| Low Variance | Stable prices, low volatility | Lower risk, tighter stops possible |
| Rising Variance | Volatility expanding | Risk increasing, position size down |
| Falling Variance | Volatility contracting | Risk decreasing, may increase size |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

## Example: Variance-Based Risk Assessment

```ruby
prices = load_historical_prices('AAPL')

# Calculate variance with different periods
var_short = SQA::TAI.var(prices, period: 5)
var_medium = SQA::TAI.var(prices, period: 20)
var_long = SQA::TAI.var(prices, period: 60)

current_var = var_short.last
medium_var = var_medium.last
long_var = var_long.last

# Compare current variance to longer-term averages
if current_var > medium_var * 2
  debug_me "HIGH RISK: Variance spike detected!"
  debug_me "Current variance: #{current_var.round(4)}"
  debug_me "20-period variance: #{medium_var.round(4)}"
  debug_me "Risk level: ELEVATED - Consider reducing position size"
elsif current_var < medium_var * 0.5
  debug_me "LOW RISK: Variance compression detected"
  debug_me "Current variance: #{current_var.round(4)}"
  debug_me "20-period variance: #{medium_var.round(4)}"
  debug_me "Risk level: LOW - Market is quiet"
else
  debug_me "NORMAL RISK: Variance in typical range"
  debug_me "Current variance: #{current_var.round(4)}"
end
```

## Example: Position Sizing Based on Variance

```ruby
prices = load_historical_prices('TSLA')

variance = SQA::TAI.var(prices, period: 20)
stddev = SQA::TAI.stddev(prices, period: 20)

current_price = prices.last
current_variance = variance.last
current_stddev = stddev.last

# Risk parameters
account_value = 100_000
risk_per_trade = account_value * 0.02  # 2% risk

# Average variance over last 60 days for comparison
avg_variance = variance.compact[-60..-1].sum / 60.0

# Adjust position size based on current vs average variance
variance_ratio = current_variance / avg_variance

if variance_ratio > 2.0
  # High volatility - reduce position size
  risk_adjustment = 0.5  # Cut risk in half
  adjusted_risk = risk_per_trade * risk_adjustment

  debug_me <<~HEREDOC
    HIGH VOLATILITY REGIME
    Current variance: #{current_variance.round(4)}
    Average variance: #{avg_variance.round(4)}
    Variance ratio: #{variance_ratio.round(2)}x
    Reducing position size by 50%
    Risk allocation: $#{adjusted_risk.round(2)} (was $#{risk_per_trade.round(2)})
  HEREDOC
elsif variance_ratio < 0.5
  # Low volatility - can increase position size slightly
  risk_adjustment = 1.25  # Increase risk by 25%
  adjusted_risk = risk_per_trade * risk_adjustment

  debug_me <<~HEREDOC
    LOW VOLATILITY REGIME
    Current variance: #{current_variance.round(4)}
    Average variance: #{avg_variance.round(4)}
    Variance ratio: #{variance_ratio.round(2)}x
    Increasing position size by 25%
    Risk allocation: $#{adjusted_risk.round(2)} (was $#{risk_per_trade.round(2)})
  HEREDOC
else
  # Normal volatility
  adjusted_risk = risk_per_trade

  debug_me <<~HEREDOC
    NORMAL VOLATILITY REGIME
    Current variance: #{current_variance.round(4)}
    Average variance: #{avg_variance.round(4)}
    Variance ratio: #{variance_ratio.round(2)}x
    Using standard position size
    Risk allocation: $#{adjusted_risk.round(2)}
  HEREDOC
end

# Calculate position size using standard deviation (√variance)
stop_distance = current_stddev * 2  # 2 standard deviations
position_size = adjusted_risk / stop_distance

debug_me <<~HEREDOC
  POSITION DETAILS
  Entry price: $#{current_price.round(2)}
  Stop distance: $#{stop_distance.round(2)} (2σ)
  Position size: #{position_size.round(0)} shares
  Total value: $#{(position_size * current_price).round(2)}
  Stop loss: $#{(current_price - stop_distance).round(2)}
HEREDOC
```

## Example: Volatility Regime Detection

```ruby
prices = load_historical_prices('SPY')

variance = SQA::TAI.var(prices, period: 20)

# Calculate rolling statistics on variance
recent_variance = variance.compact[-60..-1]
mean_variance = recent_variance.sum / recent_variance.length
stddev_variance = Math.sqrt(
  recent_variance.map { |v| (v - mean_variance) ** 2 }.sum / recent_variance.length
)

current_var = variance.last

# Classify volatility regime
if current_var > mean_variance + (2 * stddev_variance)
  regime = "EXTREME HIGH"
  color = :red
  action = "Defensive - reduce exposure, tighten stops"
elsif current_var > mean_variance + stddev_variance
  regime = "ELEVATED"
  color = :yellow
  action = "Cautious - reduce position sizes"
elsif current_var < mean_variance - stddev_variance
  regime = "LOW"
  color = :green
  action = "Opportunistic - can increase exposure"
else
  regime = "NORMAL"
  color = :blue
  action = "Standard risk management"
end

debug_me <<~HEREDOC
  VOLATILITY REGIME ANALYSIS
  Current variance: #{current_var.round(4)}
  Mean variance (60d): #{mean_variance.round(4)}
  StdDev of variance: #{stddev_variance.round(4)}

  Regime: #{regime}
  Recommended action: #{action}

  Z-Score: #{((current_var - mean_variance) / stddev_variance).round(2)}
HEREDOC
```

## Example: Comparing Risk Across Assets

```ruby
# Compare variance across different assets for portfolio allocation
symbols = ['AAPL', 'MSFT', 'TSLA', 'SPY', 'TLT']

risk_analysis = symbols.map do |symbol|
  prices = load_historical_prices(symbol)
  variance = SQA::TAI.var(prices, period: 20)
  stddev = SQA::TAI.stddev(prices, period: 20)

  current_price = prices.last
  current_variance = variance.last
  current_stddev = stddev.last

  # Normalize by price (coefficient of variation)
  cv = (current_stddev / current_price) * 100  # As percentage

  {
    symbol: symbol,
    price: current_price.round(2),
    variance: current_variance.round(4),
    stddev: current_stddev.round(2),
    cv_percent: cv.round(2)
  }
end

# Sort by coefficient of variation (relative risk)
debug_me "COMPARATIVE RISK ANALYSIS (20-day period)\n"
debug_me "=" * 70

risk_analysis.sort_by { |d| d[:cv_percent] }.each do |data|
  debug_me <<~HEREDOC
    #{data[:symbol]}:
      Price: $#{data[:price]}
      Variance: #{data[:variance]}
      Std Dev: $#{data[:stddev]}
      Coefficient of Variation: #{data[:cv_percent]}% (relative risk)

  HEREDOC
end

# Determine portfolio allocation based on variance
total_cv = risk_analysis.sum { |d| d[:cv_percent] }

debug_me "\nRISK-ADJUSTED ALLOCATION (Inverse Variance Weighting):\n"
risk_analysis.each do |data|
  # Inverse of CV for allocation (lower risk = higher allocation)
  inverse_cv = 1.0 / data[:cv_percent]
  total_inverse = risk_analysis.sum { |d| 1.0 / d[:cv_percent] }
  allocation = (inverse_cv / total_inverse) * 100

  debug_me "#{data[:symbol]}: #{allocation.round(1)}% (lower variance = higher allocation)"
end
```

## Example: Variance Breakout Trading

```ruby
prices = load_historical_prices('NVDA')

variance = SQA::TAI.var(prices, period: 20)
stddev = SQA::TAI.stddev(prices, period: 20)

# Calculate variance of variance (second moment)
var_history = variance.compact[-60..-1]
avg_variance = var_history.sum / var_history.length

current_var = variance.last
current_price = prices.last

# Detect variance breakouts (volatility expansion)
if current_var > avg_variance * 2.0
  debug_me <<~HEREDOC
    VARIANCE BREAKOUT DETECTED!
    Current variance: #{current_var.round(4)}
    60-day avg variance: #{avg_variance.round(4)}
    Ratio: #{(current_var / avg_variance).round(2)}x

    INTERPRETATION:
    - Volatility is expanding rapidly
    - Expect larger price swings
    - Potential trend change or acceleration
    - Use wider stops
    - Consider reducing position size
    - Look for directional breakout
  HEREDOC

  # Calculate recommended stop based on expanded volatility
  expanded_stop = current_price - (3 * stddev.last)  # 3σ for high vol
  debug_me "Recommended stop loss: $#{expanded_stop.round(2)} (3σ)"

elsif current_var < avg_variance * 0.3
  debug_me <<~HEREDOC
    VARIANCE COMPRESSION DETECTED!
    Current variance: #{current_var.round(4)}
    60-day avg variance: #{avg_variance.round(4)}
    Ratio: #{(current_var / avg_variance).round(2)}x

    INTERPRETATION:
    - Volatility is contracting
    - Market is consolidating
    - Potential breakout pending
    - Good time to establish positions
    - Use tighter stops
    - Wait for directional move
  HEREDOC

  # Tighter stops during compression
  compressed_stop = current_price - (1.5 * stddev.last)  # 1.5σ for low vol
  debug_me "Recommended stop loss: $#{compressed_stop.round(2)} (1.5σ)"
end
```

## Example: Rolling Variance for Trend Analysis

```ruby
prices = load_historical_prices('BTC-USD')

# Calculate variance with multiple periods
var_5 = SQA::TAI.var(prices, period: 5)
var_20 = SQA::TAI.var(prices, period: 20)
var_60 = SQA::TAI.var(prices, period: 60)

# Analyze variance trend
recent_var_5 = var_5.compact.last(10)
var_trend = if recent_var_5.last > recent_var_5.first * 1.5
  "INCREASING"
elsif recent_var_5.last < recent_var_5.first * 0.67
  "DECREASING"
else
  "STABLE"
end

debug_me <<~HEREDOC
  VARIANCE TREND ANALYSIS

  Current Variance (5-day): #{var_5.last.round(4)}
  Current Variance (20-day): #{var_20.last.round(4)}
  Current Variance (60-day): #{var_60.last.round(4)}

  Short-term trend: #{var_trend}

  MARKET REGIME:
HEREDOC

if var_5.last > var_20.last && var_20.last > var_60.last
  debug_me "  - Accelerating volatility across all timeframes"
  debug_me "  - Risk is increasing"
  debug_me "  - Consider defensive positioning"
elsif var_5.last < var_20.last && var_20.last < var_60.last
  debug_me "  - Volatility declining across all timeframes"
  debug_me "  - Risk is decreasing"
  debug_me "  - Market stabilizing"
else
  debug_me "  - Mixed volatility signals"
  debug_me "  - Monitor for regime change"
end
```

## Common Period Settings

| Period | Use Case | Risk Context |
|--------|----------|--------------|
| 5 | Short-term volatility | Day trading, quick moves |
| 10 | Swing trading | Multi-day holds |
| 20 | Standard (monthly) | Position trading |
| 60 | Quarterly trends | Long-term risk assessment |
| 252 | Annual variance | Portfolio management |

## Risk Management Applications

### 1. Dynamic Stop Losses
```ruby
# Adjust stop loss based on current variance
stop_multiplier = current_var > avg_var ? 3.0 : 2.0
stop_loss = entry - (stop_multiplier * Math.sqrt(current_var))
```

### 2. Position Sizing
```ruby
# Inverse variance weighting
position_size = (risk_capital / current_var) * scale_factor
```

### 3. Portfolio Allocation
```ruby
# Lower variance assets get higher allocation
weight = (1.0 / variance) / total_inverse_variance
```

### 4. Volatility Filters
```ruby
# Only trade when variance is in acceptable range
trade_ok = current_var.between?(min_var, max_var)
```

## Relationship to Other Indicators

Variance is the foundation for many other statistical measures:

- **Standard Deviation (STDDEV)**: √Variance - more intuitive scale
- **Coefficient of Variation**: (StdDev / Mean) × 100 - relative risk
- **Bollinger Bands**: Price ± (N × StdDev)
- **Value at Risk (VaR)**: Uses variance for risk estimation
- **Sharpe Ratio**: Return / StdDev - risk-adjusted return

## Advantages

- Mathematically rigorous measure of dispersion
- Foundation for many risk metrics
- Useful for portfolio theory and optimization
- Works across all asset classes and timeframes
- Quantifies uncertainty objectively

## Limitations

- Squared units (less intuitive than standard deviation)
- Assumes normal distribution (real markets have fat tails)
- Backward-looking (uses historical data)
- Sensitive to outliers
- Doesn't distinguish between upside and downside volatility

## Best Practices

1. **Use with Standard Deviation**: Variance and StdDev complement each other
2. **Compare Relatively**: Look at variance ratios, not absolute values
3. **Multiple Timeframes**: Check variance across different periods
4. **Normalize by Price**: Use coefficient of variation for cross-asset comparison
5. **Combine with Trend**: Variance tells magnitude, not direction
6. **Regular Recalibration**: Update risk models as market regimes change

## Related Indicators

- [STDDEV](stddev.md) - Square root of variance (same scale as price)
- [ATR](../volatility/atr.md) - Alternative volatility measure
- [BBANDS](../overlap/bbands.md) - Uses standard deviation
- [BETA](beta.md) - Relative variance to market

## See Also

- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
- [Statistical Indicators Overview](../index.md)
