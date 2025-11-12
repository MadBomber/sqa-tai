# Beta Coefficient (BETA)

The Beta Coefficient measures the volatility and systematic risk of a security or portfolio relative to a benchmark (typically a market index). Beta quantifies how much a security's price moves in relation to overall market movements, making it a crucial metric for risk assessment and portfolio construction.

## Usage

```ruby
require 'sqa/tai'

# Stock and benchmark prices (e.g., AAPL vs S&P 500)
stock_prices = [150.0, 152.5, 151.0, 153.5, 155.0, 154.0,
                156.5, 158.0, 157.0, 159.5, 161.0, 160.0,
                162.5, 164.0, 163.0, 165.5, 167.0, 166.0]

benchmark_prices = [4200, 4220, 4215, 4235, 4250, 4245,
                    4260, 4275, 4270, 4285, 4300, 4295,
                    4310, 4325, 4320, 4335, 4350, 4345]

# Calculate 14-period Beta
beta = SQA::TAI.beta(stock_prices, benchmark_prices, period: 14)

puts "Current Beta: #{beta.last.round(2)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prices1` | Array<Float> | Yes | - | Array of stock/security prices |
| `prices2` | Array<Float> | Yes | - | Array of benchmark prices (market index) |
| `period` | Integer | No | 5 | Lookback period for calculation |

## Returns

Returns an array of beta coefficient values. The first `period` values will be `nil`. Beta can be any real number:
- Positive values: Moves with the market
- Negative values: Moves opposite to the market
- Zero: Independent of market movements

## Interpretation

| Beta Range | Interpretation | Volatility | Risk Profile |
|------------|----------------|------------|--------------|
| β > 1.5 | Highly aggressive | Very high volatility | High risk/high reward |
| β = 1.0 - 1.5 | Aggressive | Above market volatility | Above-average risk |
| β = 1.0 | Market neutral | Same as market | Average risk |
| β = 0.5 - 1.0 | Defensive | Below market volatility | Below-average risk |
| β = 0.0 - 0.5 | Highly defensive | Low volatility | Low risk/low reward |
| β ≈ 0 | Market independent | No correlation | Diversification benefit |
| β < 0 | Inverse | Negative correlation | Hedge position |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

### Detailed Beta Values

| Beta | Meaning | Example |
|------|---------|---------|
| 2.0 | Moves 2x the market | If market rises 1%, stock rises 2% |
| 1.5 | 50% more volatile | If market rises 1%, stock rises 1.5% |
| 1.0 | Moves with market | If market rises 1%, stock rises 1% |
| 0.5 | 50% less volatile | If market rises 1%, stock rises 0.5% |
| 0.0 | No correlation | Stock moves independently of market |
| -0.5 | Moves opposite | If market rises 1%, stock falls 0.5% |
| -1.0 | Perfect inverse | If market rises 1%, stock falls 1% |

## Example: Basic Beta Analysis

```ruby
stock_prices = load_historical_prices('TSLA')
spy_prices = load_historical_prices('SPY')  # S&P 500 ETF

beta = SQA::TAI.beta(stock_prices, spy_prices, period: 60)
current_beta = beta.last

puts <<~ANALYSIS
  Stock Beta Analysis:
  Beta: #{current_beta.round(2)}

  Risk Profile: #{
    case current_beta
    when 1.5..Float::INFINITY then "Highly Aggressive - High Risk"
    when 1.0...1.5 then "Aggressive - Above Average Risk"
    when 0.5...1.0 then "Defensive - Below Average Risk"
    when 0.0...0.5 then "Highly Defensive - Low Risk"
    when -Float::INFINITY...0.0 then "Inverse - Hedge Position"
    end
  }

  Interpretation:
  #{
    if current_beta > 1
      "Stock is #{((current_beta - 1) * 100).round(0)}% more volatile than the market"
    elsif current_beta < 1 && current_beta > 0
      "Stock is #{((1 - current_beta) * 100).round(0)}% less volatile than the market"
    elsif current_beta < 0
      "Stock moves inversely to the market (hedge)"
    else
      "Stock moves independently of the market"
    end
  }
ANALYSIS
```

## Example: Portfolio Beta Construction

```ruby
# Portfolio allocation
portfolio = {
  'TSLA' => { weight: 0.20, prices: load_prices('TSLA') },
  'AAPL' => { weight: 0.30, prices: load_prices('AAPL') },
  'JNJ'  => { weight: 0.25, prices: load_prices('JNJ') },
  'GLD'  => { weight: 0.15, prices: load_prices('GLD') },
  'TLT'  => { weight: 0.10, prices: load_prices('TLT') }
}

spy_prices = load_prices('SPY')

# Calculate individual betas
portfolio_beta = 0.0

portfolio.each do |ticker, data|
  beta = SQA::TAI.beta(data[:prices], spy_prices, period: 252)
  stock_beta = beta.last
  weighted_beta = stock_beta * data[:weight]

  portfolio_beta += weighted_beta

  puts "#{ticker}: Beta=#{stock_beta.round(2)}, Weight=#{(data[:weight]*100).round(0)}%, Contribution=#{weighted_beta.round(2)}"
end

puts <<~PORTFOLIO

  Portfolio Summary:
  Overall Beta: #{portfolio_beta.round(2)}

  Risk Profile: #{
    if portfolio_beta > 1.2
      "Aggressive - Outperforms in bull markets, underperforms in bear markets"
    elsif portfolio_beta > 0.8
      "Balanced - Moves roughly with the market"
    else
      "Defensive - Better downside protection, lower upside potential"
    end
  }

  Expected Movement:
  If market rises 10%, portfolio expected to rise #{(portfolio_beta * 10).round(1)}%
  If market falls 10%, portfolio expected to fall #{(portfolio_beta * 10).round(1)}%
PORTFOLIO
```

## Example: Beta-Based Market Strategy

```ruby
stock_prices = load_prices('NVDA')
spy_prices = load_prices('SPY')

beta = SQA::TAI.beta(stock_prices, spy_prices, period: 60)
current_beta = beta.last

# Market trend detection
sma_200 = SQA::TAI.sma(spy_prices, period: 200)
market_trend = spy_prices.last > sma_200.last ? :bullish : :bearish

puts <<~STRATEGY
  Market-Based Beta Strategy:

  Market Trend: #{market_trend.to_s.upcase}
  Stock Beta: #{current_beta.round(2)}

  Trading Strategy:
STRATEGY

case market_trend
when :bullish
  if current_beta > 1.5
    puts "  Action: OVERWEIGHT - High beta stock in bull market"
    puts "  Rationale: Maximize upside capture"
    puts "  Target allocation: 150% of benchmark weight"
  elsif current_beta > 1.0
    puts "  Action: MARKET WEIGHT - Moderate beta"
    puts "  Rationale: Participate in upside with reasonable risk"
    puts "  Target allocation: 100% of benchmark weight"
  else
    puts "  Action: UNDERWEIGHT - Low beta in bull market"
    puts "  Rationale: Look for higher beta opportunities"
    puts "  Target allocation: 50% of benchmark weight"
  end

when :bearish
  if current_beta < 0.5
    puts "  Action: OVERWEIGHT - Low beta stock in bear market"
    puts "  Rationale: Defensive positioning for downside protection"
    puts "  Target allocation: 150% of benchmark weight"
  elsif current_beta < 1.0
    puts "  Action: MARKET WEIGHT - Moderate defensive position"
    puts "  Rationale: Balance protection with opportunity"
    puts "  Target allocation: 100% of benchmark weight"
  else
    puts "  Action: UNDERWEIGHT - High beta in bear market"
    puts "  Rationale: Reduce exposure to volatility"
    puts "  Target allocation: 25-50% of benchmark weight"
  end
end
```

## Example: Beta for Hedging

```ruby
# Portfolio to hedge
portfolio_value = 1_000_000
portfolio_prices = load_portfolio_prices('MY_PORTFOLIO')
spy_prices = load_prices('SPY')

# Calculate portfolio beta
portfolio_beta = SQA::TAI.beta(portfolio_prices, spy_prices, period: 60).last

puts <<~HEDGE
  Portfolio Hedging Analysis:

  Portfolio Value: $#{portfolio_value.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}
  Portfolio Beta: #{portfolio_beta.round(2)}

  Hedge Requirements:
HEDGE

if portfolio_beta > 1.0
  # Need to hedge more than portfolio value
  hedge_ratio = portfolio_beta
  hedge_value = portfolio_value * hedge_ratio

  puts "  High Beta Portfolio - Requires enhanced hedge"
  puts "  Hedge Ratio: #{hedge_ratio.round(2)}"
  puts "  SPY Short Position Needed: $#{hedge_value.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  puts "  SPY Shares to Short: #{(hedge_value / spy_prices.last).round(0)}"

elsif portfolio_beta < 1.0 && portfolio_beta > 0
  # Need to hedge less than portfolio value
  hedge_ratio = portfolio_beta
  hedge_value = portfolio_value * hedge_ratio

  puts "  Low Beta Portfolio - Requires reduced hedge"
  puts "  Hedge Ratio: #{hedge_ratio.round(2)}"
  puts "  SPY Short Position Needed: $#{hedge_value.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  puts "  SPY Shares to Short: #{(hedge_value / spy_prices.last).round(0)}"

else
  puts "  Portfolio beta near zero or negative - Review hedge strategy"
end
```

## Example: Multi-Period Beta Analysis

```ruby
stock_prices = load_prices('AMZN')
spy_prices = load_prices('SPY')

# Calculate different period betas
beta_30d = SQA::TAI.beta(stock_prices, spy_prices, period: 30).last
beta_90d = SQA::TAI.beta(stock_prices, spy_prices, period: 90).last
beta_252d = SQA::TAI.beta(stock_prices, spy_prices, period: 252).last

puts <<~MULTIPERIOD
  Multi-Period Beta Analysis:

  30-Day Beta:  #{beta_30d.round(2)} (Short-term volatility)
  90-Day Beta:  #{beta_90d.round(2)} (Medium-term trend)
  252-Day Beta: #{beta_252d.round(2)} (Long-term characteristic)

  Beta Stability: #{
    if (beta_30d - beta_252d).abs < 0.2
      "STABLE - Consistent risk profile across timeframes"
    elsif beta_30d > beta_252d + 0.3
      "INCREASING - Short-term volatility rising"
    else
      "DECREASING - Short-term volatility falling"
    end
  }

  Risk Assessment:
  - Current positioning reflects #{beta_30d > 1 ? 'aggressive' : 'defensive'} short-term behavior
  - Historical baseline shows #{beta_252d > 1 ? 'aggressive' : 'defensive'} long-term character
  #{
    if (beta_30d - beta_252d).abs > 0.5
      "- WARNING: Significant beta shift detected - review position sizing"
    else
      "- Risk profile stable - maintain current strategy"
    end
  }
MULTIPERIOD
```

## Advanced Techniques

### 1. Rolling Beta Analysis
Track how beta changes over time to identify regime changes:
```ruby
stock_prices = load_prices('NFLX')
spy_prices = load_prices('SPY')

# Calculate rolling 60-day beta
rolling_betas = []
60.upto(stock_prices.length - 1) do |i|
  beta = SQA::TAI.beta(
    stock_prices[i-60..i],
    spy_prices[i-60..i],
    period: 60
  ).last
  rolling_betas << beta
end

avg_beta = rolling_betas.sum / rolling_betas.length
current_beta = rolling_betas.last

if current_beta > avg_beta * 1.3
  puts "Beta spike detected - increased market sensitivity"
elsif current_beta < avg_beta * 0.7
  puts "Beta drop detected - reduced market correlation"
end
```

### 2. Sector Beta Comparison
Compare individual stock beta to sector beta:
```ruby
stock_beta = SQA::TAI.beta(stock_prices, spy_prices, period: 252).last
sector_beta = SQA::TAI.beta(sector_etf_prices, spy_prices, period: 252).last

relative_beta = stock_beta / sector_beta

if relative_beta > 1.2
  puts "Stock is significantly more volatile than its sector"
elsif relative_beta < 0.8
  puts "Stock is defensive relative to its sector"
end
```

### 3. Beta-Adjusted Performance
Calculate risk-adjusted returns:
```ruby
stock_return = ((stock_prices.last - stock_prices.first) / stock_prices.first) * 100
market_return = ((spy_prices.last - spy_prices.first) / spy_prices.first) * 100
stock_beta = SQA::TAI.beta(stock_prices, spy_prices, period: 60).last

expected_return = market_return * stock_beta
excess_return = stock_return - expected_return

puts "Stock Return: #{stock_return.round(2)}%"
puts "Expected Return (based on beta): #{expected_return.round(2)}%"
puts "Alpha (Excess Return): #{excess_return.round(2)}%"
```

### 4. Down-Market Beta
Calculate beta specifically during market declines:
```ruby
# Separate up and down market periods
down_stock_prices = []
down_spy_prices = []

spy_prices.each_with_index do |price, i|
  next if i == 0
  if price < spy_prices[i-1]  # Market down day
    down_stock_prices << stock_prices[i]
    down_spy_prices << price
  end
end

down_beta = SQA::TAI.beta(down_stock_prices, down_spy_prices, period: 30).last
full_beta = SQA::TAI.beta(stock_prices, spy_prices, period: 60).last

puts "Full-Period Beta: #{full_beta.round(2)}"
puts "Down-Market Beta: #{down_beta.round(2)}"

if down_beta > full_beta * 1.2
  puts "WARNING: Stock is significantly more volatile during declines"
elsif down_beta < full_beta * 0.8
  puts "POSITIVE: Stock shows resilience during market declines"
end
```

## Portfolio Applications

### High Beta Strategy (Bull Market)
- Target beta: 1.3 - 1.8
- Focus: Growth stocks, tech, small-caps
- Market view: Strong uptrend expected
- Risk: High volatility, larger drawdowns

### Low Beta Strategy (Bear Market or Uncertainty)
- Target beta: 0.4 - 0.7
- Focus: Utilities, consumer staples, bonds
- Market view: Decline or consolidation expected
- Risk: Lower returns in bull markets

### Market Neutral Strategy
- Target beta: 0.0 - 0.2
- Focus: Long/short combinations
- Market view: Stock picking, not market timing
- Risk: Position-specific risk only

### Smart Beta Strategy
- Adjust beta based on market conditions
- High beta in confirmed uptrends
- Low beta in downtrends or high volatility
- Rebalance quarterly or on trend changes

## Common Settings

| Period | Use Case | Typical Beta Range |
|--------|----------|-------------------|
| 30 | Short-term trading | More volatile, 0.5-2.0 |
| 60 | Medium-term positioning | Moderate stability, 0.6-1.8 |
| 252 | Annual analysis (standard) | Most stable, 0.7-1.5 |
| 504 | Long-term investing | Very stable, 0.8-1.3 |

## Limitations and Considerations

1. **Historical Measure**: Beta is backward-looking and may not predict future behavior
2. **Market Conditions**: Beta can change during market regime changes
3. **Linear Assumption**: Assumes linear relationship between stock and market
4. **Benchmark Selection**: Different benchmarks yield different betas
5. **Time Period**: Longer periods provide stability, shorter periods show current behavior
6. **Company Changes**: Mergers, business model shifts can alter beta
7. **Not Absolute Risk**: Only measures systematic (market) risk, not total risk

## Related Indicators

- [CORREL](correl.md) - Correlation coefficient between securities
- [STDDEV](stddev.md) - Standard deviation for volatility measurement
- [VAR](var.md) - Variance calculation
- [LINEARREG](linearreg.md) - Linear regression analysis

## See Also

- [Back to Indicators](../index.md)
- [Statistical Indicators Overview](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
