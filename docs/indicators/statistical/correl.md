# CORREL (Pearson's Correlation Coefficient)

## Overview

The Pearson's Correlation Coefficient (CORREL) is a statistical indicator that measures the linear relationship between two price series over a specified period. It quantifies how closely two assets move together, producing values between -1 and +1. This indicator is essential for pair trading, portfolio diversification, and identifying correlation breakdowns that can signal trading opportunities.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `prices1` | Array<Float> | Required | Array of price values for first asset (typically close prices) |
| `prices2` | Array<Float> | Required | Array of price values for second asset (typically close prices) |
| `period` | Integer | 30 | Number of periods over which to calculate correlation |

### Parameter Details


**Note**: Array elements should be ordered from oldest to newest (chronological order)

**prices1**
- First price series for correlation calculation
- Should be synchronized with prices2 (same timestamps)
- Typically closing prices, but can use any price type
- Must have same length as prices2

**prices2**
- Second price series for correlation calculation
- Should be synchronized with prices1 (same timestamps)
- Typically closing prices, but can use any price type
- Must have same length as prices1

**period**
- Lookback window for correlation calculation
- Shorter periods (10-20): More responsive, detects rapid correlation changes
- Medium periods (20-40): Balanced view of correlation stability
- Longer periods (50-100): Stable long-term correlation trends
- Default 30 provides good balance for most pair trading applications

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

# Calculate correlation between two assets
spy_prices = [440.12, 441.35, 439.88, 442.17, 443.50, 442.90, 444.25,
              445.10, 444.75, 446.30, 445.85, 447.20, 446.95, 448.10]

qqq_prices = [368.45, 369.80, 368.20, 370.15, 371.25, 370.85, 372.10,
              372.90, 372.45, 373.80, 373.40, 374.60, 374.35, 375.40]

correlation = SQA::TAI.correl(spy_prices, qqq_prices, period: 10)

# Current correlation value
current_corr = correlation.last
puts "SPY/QQQ Correlation: #{current_corr.round(3)}"

if current_corr > 0.7
  puts "Strong positive correlation - assets moving together"
elsif current_corr < -0.7
  puts "Strong negative correlation - assets moving opposite"
else
  puts "Weak correlation - assets moving independently"
end
```

### Practical Application

```ruby
# Pair trading setup - monitor correlation for trading opportunities
stock_a = [100.0, 101.5, 102.0, 101.0, 102.5, 103.0, 102.5, 104.0,
           105.0, 104.5, 106.0, 105.5, 107.0, 106.5, 108.0]

stock_b = [50.0, 50.8, 51.0, 50.5, 51.2, 51.5, 51.2, 52.0,
           52.5, 52.2, 53.0, 52.7, 53.5, 53.2, 54.0]

# Calculate rolling correlation
correlation = SQA::TAI.correl(stock_a, stock_b, period: 10)

# Track correlation trend
recent_corr = correlation.last(5)
avg_corr = recent_corr.sum / recent_corr.size
current_corr = correlation.last

puts "Average correlation (5-period): #{avg_corr.round(3)}"
puts "Current correlation: #{current_corr.round(3)}"

# Detect correlation breakdown
if avg_corr > 0.8 && current_corr < 0.5
  puts "CORRELATION BREAKDOWN DETECTED"
  puts "Potential pair trading opportunity - investigate spread"
end
```

## Understanding the Indicator

### What It Measures

CORREL measures **the strength and direction of the linear relationship** between two price series. It answers the question: "How closely do these two assets move together?"

The correlation coefficient ranges from -1 to +1:
- **+1**: Perfect positive correlation (assets move in lockstep)
- **0**: No correlation (assets move independently)
- **-1**: Perfect negative correlation (assets move in opposite directions)

### Why It's Important

Understanding correlation between assets is crucial for:

**Portfolio Management:**
- Diversification: Lower correlation reduces portfolio risk
- Risk assessment: High correlation increases concentration risk
- Hedging: Negative correlation provides natural hedges

**Pair Trading:**
- Identify cointegrated pairs with high correlation
- Detect temporary correlation breakdowns for mean reversion trades
- Monitor correlation stability for pair selection

**Market Analysis:**
- Sector rotation: Correlation shifts indicate changing market dynamics
- Risk-on/risk-off: Correlation patterns reveal market sentiment
- Intermarket relationships: Bonds, currencies, commodities

### Calculation Method

The Pearson correlation coefficient is calculated using the formula:

```
r = Σ[(Xi - X̄)(Yi - Ȳ)] / sqrt[Σ(Xi - X̄)² × Σ(Yi - Ȳ)²]
```

Where:
- Xi, Yi = Individual price values for assets 1 and 2
- X̄, Ȳ = Mean prices over the period
- Σ = Sum over the period

**Step-by-step process:**

1. **Calculate means** of both price series over the period
2. **Compute deviations** from mean for each price point
3. **Calculate covariance** (product of deviations)
4. **Calculate standard deviations** for each series
5. **Divide covariance by product of standard deviations**
6. **Result is correlation coefficient** between -1 and +1

**Key Concept:**
The correlation coefficient is normalized, meaning it measures relationship strength independent of the actual price levels or volatility of the assets.

### Indicator Characteristics

- **Range**: -1.0 to +1.0
- **Type**: Statistical, relationship indicator
- **Lag**: Moderate - requires lookback period to calculate
- **Best Used**: All market conditions, especially for relative value trading

## Interpretation

### Value Ranges

Understanding correlation strength:

- **Perfect Positive Correlation (+0.90 to +1.00)**
  - Assets move almost identically
  - Common in same-sector stocks or index vs constituents
  - Limited diversification benefit
  - Strong pair trading candidates

- **Strong Positive Correlation (+0.70 to +0.89)**
  - Assets generally move together
  - Some independent price action
  - Moderate diversification benefit
  - Good for momentum pair trades

- **Moderate Positive Correlation (+0.40 to +0.69)**
  - Noticeable relationship but significant independence
  - Better diversification benefit
  - Less reliable for pair trading
  - Consider spread volatility

- **Weak Correlation (-0.39 to +0.39)**
  - Assets move mostly independently
  - Good diversification benefit
  - Poor pair trading candidates
  - Focus on individual asset analysis

- **Moderate Negative Correlation (-0.69 to -0.40)**
  - Assets tend to move in opposite directions
  - Natural hedging characteristics
  - Interesting for spread trading
  - Risk-on/risk-off dynamics

- **Strong Negative Correlation (-0.89 to -0.70)**
  - Assets consistently move opposite
  - Excellent hedging properties
  - Consider inverse pair trades
  - Common in gold vs stocks, bonds vs stocks

- **Perfect Negative Correlation (-1.00 to -0.90)**
  - Assets move in exact opposite directions
  - Rare in practice
  - Perfect hedge if maintained
  - Usually synthetic (leveraged ETFs)

### Correlation Changes

**Increasing Correlation:**
When correlation coefficient rises over time:
- Assets becoming more synchronized
- Sector or market-wide forces strengthening
- Diversification benefit decreasing
- Increased systemic risk

**Decreasing Correlation:**
When correlation coefficient falls over time:
- Assets diverging in behavior
- Company-specific factors dominating
- Diversification benefit increasing
- Potential pair trading opportunities

**Correlation Breakdown:**
Rapid drop from high to low correlation:
- Unexpected divergence in historically correlated assets
- Often signals fundamental change in one asset
- Prime opportunity for mean reversion trades (if temporary)
- Or signal to exit pair trade (if permanent)

### Stability Analysis

- **Stable correlation** (changes gradually): Reliable relationship for trading
- **Volatile correlation** (rapid swings): Unstable relationship, use with caution
- **Trending correlation** (steady increase/decrease): Changing market regime

## Trading Signals

### Pair Trading Setup

**Classic Pair Trading Strategy:**

```ruby
# Identify highly correlated pair
stock_a_prices = [...]  # Your data
stock_b_prices = [...]  # Your data

# Calculate correlation
correlation = SQA::TAI.correl(stock_a_prices, stock_b_prices, period: 60)
current_corr = correlation.last

# Qualify pair for trading
if current_corr > 0.80
  puts "PAIR QUALIFIED: Correlation = #{current_corr.round(3)}"

  # Calculate price spread
  spread = stock_a_prices.zip(stock_b_prices).map { |a, b| a - b }

  # Calculate spread statistics
  spread_mean = spread.sum / spread.size
  spread_stddev = Math.sqrt(spread.map { |x| (x - spread_mean)**2 }.sum / spread.size)

  current_spread = spread.last
  z_score = (current_spread - spread_mean) / spread_stddev

  puts "Spread Z-Score: #{z_score.round(2)}"

  # Generate signals based on spread
  if z_score > 2.0
    puts "SELL SIGNAL: Spread overextended"
    puts "Action: Short Stock A, Long Stock B"
  elsif z_score < -2.0
    puts "BUY SIGNAL: Spread overextended"
    puts "Action: Long Stock A, Short Stock B"
  elsif z_score.abs < 0.5
    puts "EXIT SIGNAL: Spread returned to mean"
  end
else
  puts "Pair not suitable - correlation too weak: #{current_corr.round(3)}"
end
```

### Correlation Breakdown Trading

**Entry Signals:**

1. **Mean Reversion Entry**
   - Historical correlation > 0.75
   - Current correlation drops below 0.50
   - Verify correlation drop is temporary, not fundamental
   - Enter spread trade expecting correlation to recover

2. **Divergence Trade**
   - Long-term correlation stable and high
   - Short-term divergence in price action
   - One asset lags the other's move
   - Trade the laggard to catch up

**Example Strategy:**
```ruby
# Monitor correlation stability
long_correlation = SQA::TAI.correl(prices1, prices2, period: 60)
short_correlation = SQA::TAI.correl(prices1, prices2, period: 10)

long_corr = long_correlation.last
short_corr = short_correlation.last

puts "Long-term correlation (60): #{long_corr.round(3)}"
puts "Short-term correlation (10): #{short_corr.round(3)}"

# Detect breakdown
if long_corr > 0.75 && short_corr < 0.50
  puts "CORRELATION BREAKDOWN DETECTED"

  # Calculate which asset is outlier
  returns1 = prices1.each_cons(2).map { |a, b| (b - a) / a }
  returns2 = prices2.each_cons(2).map { |a, b| (b - a) / a }

  recent_return1 = returns1.last(5).sum
  recent_return2 = returns2.last(5).sum

  if recent_return1 > recent_return2 + 0.02
    puts "Asset 1 outperforming - consider shorting Asset 1 / buying Asset 2"
  elsif recent_return2 > recent_return1 + 0.02
    puts "Asset 2 outperforming - consider buying Asset 1 / shorting Asset 2"
  end

  puts "Expected correlation reversion within 20-30 periods"
end
```

### Sector Rotation Trading

**Use correlation to identify sector shifts:**

```ruby
# Compare individual stock to sector ETF
stock_prices = [...]
sector_etf_prices = [...]

correlation = SQA::TAI.correl(stock_prices, sector_etf_prices, period: 30)
corr_trend = correlation.last(10)

# Calculate correlation trend
recent_corr = corr_trend.last
past_corr = corr_trend.first

if recent_corr > past_corr + 0.20
  puts "INCREASING CORRELATION: Stock becoming sector-driven"
  puts "Strategy: Use sector momentum for stock direction"
elsif recent_corr < past_corr - 0.20
  puts "DECREASING CORRELATION: Stock developing independent story"
  puts "Strategy: Focus on stock-specific fundamentals"
end
```

### Portfolio Hedging

**Identify hedging opportunities:**

```ruby
# Find negative correlation for hedging
portfolio_prices = [...]  # Your portfolio value
hedge_candidate = [...]   # Potential hedge (e.g., VIX, gold, bonds)

correlation = SQA::TAI.correl(portfolio_prices, hedge_candidate, period: 40)
current_corr = correlation.last

if current_corr < -0.60
  puts "HEDGE CANDIDATE IDENTIFIED"
  puts "Correlation: #{current_corr.round(3)}"
  puts "Strong negative correlation provides downside protection"

  # Calculate hedge ratio
  portfolio_stddev = calculate_stddev(portfolio_prices)
  hedge_stddev = calculate_stddev(hedge_candidate)

  hedge_ratio = current_corr * (portfolio_stddev / hedge_stddev)
  puts "Suggested hedge ratio: #{hedge_ratio.abs.round(3)}"
  puts "For $100k portfolio, hedge with $#{(100000 * hedge_ratio.abs).round(0)} of hedge asset"
end
```

## Best Practices

### Optimal Use Cases

**When CORREL works best:**
- **Liquid pairs**: High-volume stocks or ETFs
- **Same market hours**: Both assets trade simultaneously
- **Similar sectors**: Related industries or asset classes
- **Daily to weekly timeframes**: More stable correlations than intraday
- **Established relationships**: Historical precedent for correlation

**Less effective in:**
- Very short timeframes (< 5 minutes) - too much noise
- Low-liquidity assets - correlation may be spurious
- Fundamentally unrelated assets - correlation likely random
- Crisis periods - correlations converge to 1 (all assets fall together)

### Combining with Other Indicators

**With Spread Analysis:**
```ruby
# Correlation + spread for complete pair trading view
correlation = SQA::TAI.correl(prices1, prices2, period: 30)

# Calculate spread
spread = prices1.zip(prices2).map { |a, b| a - b }
spread_sma = SQA::TAI.sma(spread, period: 20)
spread_stddev = SQA::TAI.stddev(spread, period: 20)

# Bollinger Bands on spread
upper_band = spread_sma.zip(spread_stddev).map { |m, s| m + (2 * s) }
lower_band = spread_sma.zip(spread_stddev).map { |m, s| m - (2 * s) }

current_spread = spread.last
current_upper = upper_band.last
current_lower = lower_band.last
current_corr = correlation.last

if current_corr > 0.75
  if current_spread > current_upper
    puts "SELL SPREAD: High correlation + spread at upper band"
  elsif current_spread < current_lower
    puts "BUY SPREAD: High correlation + spread at lower band"
  end
end
```

**With Beta Analysis:**
```ruby
# Correlation tells you relationship strength, beta tells you magnitude
correlation = SQA::TAI.correl(stock_prices, market_prices, period: 60)
beta = SQA::TAI.beta(stock_prices, market_prices, period: 60)

current_corr = correlation.last
current_beta = beta.last

puts "Correlation: #{current_corr.round(3)}"
puts "Beta: #{current_beta.round(3)}"

if current_corr > 0.70
  if current_beta > 1.2
    puts "High correlation + high beta = Amplified market moves"
    puts "Strategy: Use for leveraged market exposure"
  elsif current_beta < 0.8
    puts "High correlation + low beta = Defensive with market"
    puts "Strategy: Use for lower-risk market participation"
  end
end
```

**With Cointegration Tests:**
```ruby
# Correlation measures relationship, cointegration measures mean reversion
# High correlation is necessary but not sufficient for pair trading
# Need to verify cointegration separately (ADF test, etc.)

correlation = SQA::TAI.correl(prices1, prices2, period: 60)

if correlation.last > 0.80
  puts "High correlation detected: #{correlation.last.round(3)}"
  puts "Next step: Perform cointegration test (ADF/Johansen)"
  puts "Only trade pairs that are both correlated AND cointegrated"
end
```

### Common Pitfalls

1. **Confusing Correlation with Causation**
   - Correlation does not imply one asset causes the other to move
   - Both may respond to common external factors
   - Use correlation for relationship measurement, not explanation

2. **Ignoring Changing Correlations**
   - Correlation is not static - it changes over time
   - Market regime changes alter correlations
   - Crisis periods see correlations spike (diversification fails when needed most)
   - Always monitor correlation stability

3. **Using Only Correlation for Pair Trading**
   - High correlation doesn't guarantee mean reversion
   - Must also check cointegration
   - Need to verify spreads are stationary
   - Correlation alone is insufficient

4. **Period Selection Issues**
   - Too short: Noisy, unreliable correlations
   - Too long: Misses recent regime changes
   - Use multiple periods for comprehensive view
   - Typical range: 20-60 periods

5. **Spurious Correlations**
   - Random correlations can appear with enough data
   - Verify with economic logic
   - Test across different time periods
   - Don't trade based on correlation alone

### Parameter Selection Guidelines

**For Day Trading:**
- Use very short periods (5-20)
- Monitor intraday correlation changes
- Focus on highly liquid pairs
- Expect more volatile correlations

**For Swing Trading:**
- Use medium periods (20-40)
- Look for multi-day correlation stability
- Focus on established sector relationships
- Balance responsiveness with stability

**For Position Trading:**
- Use longer periods (40-100)
- Focus on long-term correlation trends
- Suitable for portfolio hedging decisions
- More stable but slower to adapt

**For Pair Trading:**
- Use multiple periods: 20, 40, 60
- Require correlation > 0.75 on 60-period
- Monitor 20-period for entry timing
- Longer periods for pair selection, shorter for trade timing

## Practical Example

Complete pair trading system example:

```ruby
require 'sqa/tai'

# Historical price data for two correlated stocks
# Example: XLE (Energy ETF) and CVX (Chevron)
xle_prices = [
  78.50, 79.20, 78.90, 79.80, 80.50, 80.20, 81.00, 81.50,
  81.20, 82.00, 82.50, 82.20, 83.00, 82.70, 83.50, 83.20,
  84.00, 84.50, 84.20, 85.00, 85.50, 85.20, 86.00, 85.70,
  86.50, 86.20, 87.00, 87.50, 87.20, 88.00, 88.50, 88.20,
  89.00, 88.70, 89.50, 89.20, 90.00, 89.70, 90.50, 90.20,
  91.00, 90.70, 91.50, 91.20, 92.00, 91.70, 92.50, 92.20,
  93.00, 92.70, 93.50, 93.20, 94.00, 93.70, 94.50, 94.20,
  95.00, 94.70, 95.50, 95.20, 96.00
]

cvx_prices = [
  145.00, 146.50, 145.80, 147.20, 148.50, 148.00, 149.50, 150.20,
  149.80, 151.00, 151.80, 151.20, 152.50, 152.00, 153.20, 152.80,
  154.00, 154.80, 154.20, 155.50, 156.20, 155.80, 157.00, 156.50,
  157.80, 157.20, 158.50, 159.20, 158.80, 160.00, 160.80, 160.20,
  161.50, 161.00, 162.20, 161.80, 163.00, 162.50, 163.80, 163.20,
  164.50, 164.00, 165.20, 164.80, 166.00, 165.50, 166.80, 166.20,
  167.50, 167.00, 168.20, 167.80, 169.00, 168.50, 169.80, 169.20,
  170.50, 170.00, 171.20, 170.80, 172.00
]

# Step 1: Calculate correlation across multiple periods
long_correlation = SQA::TAI.correl(xle_prices, cvx_prices, period: 60)
medium_correlation = SQA::TAI.correl(xle_prices, cvx_prices, period: 30)
short_correlation = SQA::TAI.correl(xle_prices, cvx_prices, period: 10)

long_corr = long_correlation.last
medium_corr = medium_correlation.last
short_corr = short_correlation.last

puts "=== CORRELATION ANALYSIS ==="
puts "Long-term (60): #{long_corr.round(3)}"
puts "Medium-term (30): #{medium_corr.round(3)}"
puts "Short-term (10): #{short_corr.round(3)}"
puts ""

# Step 2: Qualify pair for trading
if long_corr > 0.75
  puts "PAIR QUALIFIED: Strong long-term correlation"
  puts ""

  # Step 3: Calculate spread
  spread = xle_prices.zip(cvx_prices).map { |xle, cvx| xle - (cvx * 0.55) } # Ratio adjusted

  # Step 4: Spread statistics
  spread_mean = spread.last(30).sum / 30.0
  spread_values = spread.last(30)
  spread_stddev = Math.sqrt(
    spread_values.map { |x| (x - spread_mean)**2 }.sum / 30.0
  )

  current_spread = spread.last
  z_score = (current_spread - spread_mean) / spread_stddev

  puts "=== SPREAD ANALYSIS ==="
  puts "Current spread: #{current_spread.round(3)}"
  puts "30-period mean: #{spread_mean.round(3)}"
  puts "Standard deviation: #{spread_stddev.round(3)}"
  puts "Z-Score: #{z_score.round(2)}"
  puts ""

  # Step 5: Check for correlation breakdown opportunity
  if long_corr > 0.75 && short_corr < 0.50
    puts "=== CORRELATION BREAKDOWN DETECTED ==="
    puts "This may be a mean reversion opportunity"
    puts ""
  end

  # Step 6: Generate trading signals
  puts "=== TRADING SIGNALS ==="

  if z_score > 2.0
    stop_loss_z = z_score + 0.5
    take_profit_z = 0.0

    puts "SELL SPREAD SIGNAL"
    puts "Action: Short XLE / Long CVX"
    puts "Rationale: Spread #{z_score.round(2)} std devs above mean"
    puts "Entry Z-Score: #{z_score.round(2)}"
    puts "Stop Loss Z-Score: #{stop_loss_z.round(2)}"
    puts "Take Profit Z-Score: #{take_profit_z.round(2)}"
    puts "Expected duration: 10-20 periods for mean reversion"

  elsif z_score < -2.0
    stop_loss_z = z_score - 0.5
    take_profit_z = 0.0

    puts "BUY SPREAD SIGNAL"
    puts "Action: Long XLE / Short CVX"
    puts "Rationale: Spread #{z_score.abs.round(2)} std devs below mean"
    puts "Entry Z-Score: #{z_score.round(2)}"
    puts "Stop Loss Z-Score: #{stop_loss_z.round(2)}"
    puts "Take Profit Z-Score: #{take_profit_z.round(2)}"
    puts "Expected duration: 10-20 periods for mean reversion"

  elsif z_score.abs < 0.5
    puts "EXIT SIGNAL: Spread near mean"
    puts "Close any open positions - spread has reverted"

  else
    puts "NO SIGNAL: Spread at #{z_score.round(2)} std devs"
    puts "Wait for |Z-Score| > 2.0 for entry"
  end

  # Step 7: Risk assessment
  puts ""
  puts "=== RISK ASSESSMENT ==="

  if short_corr < 0.50 && long_corr > 0.75
    puts "WARNING: Short-term correlation breakdown"
    puts "Risk: Pair relationship may be unstable"
    puts "Recommendation: Reduce position size by 50%"
  elsif short_corr > 0.70
    puts "STABLE: Short and long correlations aligned"
    puts "Risk: Normal pair trading risk"
    puts "Recommendation: Use standard position size"
  end

  # Calculate position sizing
  portfolio_value = 100000
  risk_per_trade = 0.02 # 2% risk

  # Risk based on stop loss
  risk_amount = portfolio_value * risk_per_trade
  stop_distance = spread_stddev * 0.5 # 0.5 std dev stop

  xle_position_size = risk_amount / stop_distance
  cvx_position_size = xle_position_size * 0.55 # Ratio adjusted

  puts ""
  puts "=== POSITION SIZING ==="
  puts "Portfolio value: $#{portfolio_value}"
  puts "Risk per trade: #{(risk_per_trade * 100).round(1)}%"
  puts "XLE position: #{xle_position_size.round(0)} shares"
  puts "CVX position: #{cvx_position_size.round(0)} shares"

else
  puts "PAIR NOT SUITABLE"
  puts "Reason: Long-term correlation too weak (#{long_corr.round(3)})"
  puts "Requirement: Correlation > 0.75 for pair trading"
end

# Step 8: Monitor correlation stability
puts ""
puts "=== CORRELATION STABILITY ==="

recent_corrs = long_correlation.last(10)
corr_stddev = Math.sqrt(
  recent_corrs.map { |c| (c - recent_corrs.sum/10.0)**2 }.sum / 10.0
)
corr_cv = corr_stddev / (recent_corrs.sum / 10.0)

if corr_cv < 0.10
  puts "STABLE: Correlation coefficient of variation = #{corr_cv.round(3)}"
  puts "Pair relationship is reliable"
else
  puts "UNSTABLE: Correlation coefficient of variation = #{corr_cv.round(3)}"
  puts "WARNING: Pair relationship is volatile - trade with caution"
end
```

## Related Indicators

### Statistical Family

- **[BETA](beta.md)**: Measures systematic risk and return sensitivity
- **[VAR](var.md)**: Sample variance for volatility measurement
- **[STDDEV](stddev.md)**: Standard deviation for dispersion analysis
- **[TSF](tsf.md)**: Time series forecast for trend projection
- **[LINEARREG](linearreg.md)**: Linear regression for trend analysis

### Complementary Indicators

- **[ATR](../volatility/atr.md)**: Use for volatility-adjusted position sizing
- **[BBANDS](../overlap/bbands.md)**: Apply to spread for entry/exit signals
- **[RSI](../momentum/rsi.md)**: Additional confirmation for pair divergence
- **[ADX](../momentum/adx.md)**: Measure trend strength in spread

### Alternative Correlation Approaches

While CORREL uses Pearson's coefficient, consider:
- Spearman rank correlation (for non-linear relationships)
- Rolling correlations with varying windows
- Conditional correlations (regime-dependent)
- Dynamic Conditional Correlation (DCC-GARCH)

## Advanced Topics

### Multi-Asset Correlation Analysis

```ruby
# Analyze correlation matrix for portfolio
assets = {
  'SPY' => spy_prices,
  'TLT' => tlt_prices,
  'GLD' => gld_prices,
  'USO' => uso_prices
}

puts "=== CORRELATION MATRIX ==="
puts "        " + assets.keys.join("    ")

assets.each do |name1, prices1|
  row = "#{name1}   "
  assets.each do |name2, prices2|
    corr = SQA::TAI.correl(prices1, prices2, period: 60).last
    row += "#{corr.round(2)}  "
  end
  puts row
end

# Identify best diversification pairs
# Look for correlations near 0 or negative
```

### Time-Varying Correlation

```ruby
# Track how correlation changes over time
correlation_series = SQA::TAI.correl(prices1, prices2, period: 30)

# Calculate correlation trend
recent_trend = correlation_series.last(10)
older_trend = correlation_series[-20..-11]

recent_avg = recent_trend.sum / recent_trend.size
older_avg = older_trend.sum / older_trend.size

correlation_change = recent_avg - older_avg

if correlation_change > 0.15
  puts "RISING CORRELATION: Assets converging (+#{correlation_change.round(3)})"
  puts "Implication: Reduced diversification benefit"
elsif correlation_change < -0.15
  puts "FALLING CORRELATION: Assets diverging (#{correlation_change.round(3)})"
  puts "Implication: Increased diversification benefit or breakdown"
end
```

### Correlation-Based Portfolio Optimization

```ruby
# Find optimal portfolio weights using correlation
# Lower correlation = better diversification = higher allocation

asset_returns = {
  'Asset A' => [0.01, 0.02, -0.01, 0.03],
  'Asset B' => [-0.01, 0.01, 0.02, -0.02]
}

correlation = SQA::TAI.correl(
  asset_returns['Asset A'],
  asset_returns['Asset B'],
  period: 30
).last

# Simple allocation based on correlation
if correlation < 0.30
  puts "Low correlation - equal weight portfolio optimal"
  puts "Asset A: 50%, Asset B: 50%"
elsif correlation > 0.70
  puts "High correlation - concentrated portfolio acceptable"
  puts "Consider single asset or reduce allocation to weaker performer"
end
```

### Statistical Significance Testing

```ruby
# Test if correlation is statistically significant
# Rule of thumb: For 95% confidence, need |r| > 2/sqrt(n)

correlation = SQA::TAI.correl(prices1, prices2, period: 30)
current_corr = correlation.last
n = 30 # sample size

critical_value = 2.0 / Math.sqrt(n)

puts "Correlation: #{current_corr.round(3)}"
puts "Critical value (95% confidence): #{critical_value.round(3)}"

if current_corr.abs > critical_value
  puts "STATISTICALLY SIGNIFICANT: Correlation is likely real"
else
  puts "NOT SIGNIFICANT: Correlation may be random noise"
  puts "Need larger sample or stronger correlation"
end
```

### Crisis Alpha - Correlation in Extreme Markets

```ruby
# Detect correlation regime shifts during volatility spikes
normal_correlation = SQA::TAI.correl(prices1, prices2, period: 60)
recent_correlation = SQA::TAI.correl(prices1, prices2, period: 10)

# Calculate volatility
returns = prices1.each_cons(2).map { |a, b| (b - a) / a }
recent_volatility = Math.sqrt(returns.last(10).map { |r| r**2 }.sum / 10)
normal_volatility = Math.sqrt(returns.map { |r| r**2 }.sum / returns.size)

if recent_volatility > normal_volatility * 2.0
  puts "=== HIGH VOLATILITY REGIME ==="
  puts "Recent vol: #{(recent_volatility * 100).round(2)}%"
  puts "Normal vol: #{(normal_volatility * 100).round(2)}%"

  if recent_correlation.last > normal_correlation.last + 0.20
    puts "WARNING: Correlation spike during stress"
    puts "Diversification benefits reduced in crisis"
    puts "Consider reducing overall exposure"
  end
end
```

## References

- **"Quantitative Trading"** by Ernest Chan - Chapter on pair trading and correlation
- **"Algorithmic Trading"** by Ernest Chan - Statistical arbitrage using correlation
- **"Pairs Trading: Quantitative Methods and Analysis"** by Ganapathy Vidyamurthy
- **"Active Portfolio Management"** by Grinold & Kahn - Correlation in portfolio construction
- **Original Research**: Karl Pearson (1896) - Mathematical theory of correlation
- **TA-Lib Documentation**: [CORREL Function](https://ta-lib.org/function.html?name=CORREL)

## See Also

- [Statistical Indicators Overview](../index.md)
<!-- TODO: Create example file -->
- Pair Trading Guide
<!-- TODO: Create example file -->
- Portfolio Optimization
- [API Reference](../../api-reference.md)
