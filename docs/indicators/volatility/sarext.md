# Parabolic SAR Extended (SAREXT)

The Parabolic SAR Extended (SAREXT) is an advanced version of the standard Parabolic SAR that provides asymmetric control over long and short positions. While the standard SAR uses the same acceleration parameters for both directions, SAREXT allows traders to set different acceleration factors, starting values, and offsets for long versus short positions. This is particularly valuable in markets that exhibit different momentum characteristics in uptrends versus downtrends.

## Usage

```ruby
require 'sqa/tai'

high = [48.70, 48.72, 48.90, 48.87, 48.82, 49.05, 49.20, 49.35, 49.92, 50.19, 50.12, 50.10, 50.00, 49.75, 49.80]
low =  [47.79, 48.14, 48.39, 48.37, 48.24, 48.64, 48.94, 49.03, 49.50, 49.87, 49.20, 49.00, 48.90, 49.00, 49.10]

# Basic usage with defaults (symmetric behavior like standard SAR)
sarext = SQA::TAI.sarext(high, low)

# Asymmetric parameters for different long/short characteristics
sarext = SQA::TAI.sarext(
  high, low,
  start_value: 0.0,
  offset_on_reverse: 0.0,
  accel_init_long: 0.02,    # Initial acceleration for longs
  accel_long: 0.02,         # Acceleration step for longs
  accel_max_long: 0.20,     # Maximum acceleration for longs
  accel_init_short: 0.03,   # Initial acceleration for shorts (more aggressive)
  accel_short: 0.03,        # Acceleration step for shorts
  accel_max_short: 0.25     # Maximum acceleration for shorts
)

puts "Current SAREXT: #{sarext.last.round(2)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `high` | Array | Yes | - | Array of high prices |
| `low` | Array | Yes | - | Array of low prices |
| `start_value` | Float | No | 0.0 | Starting SAR value (0.0 = automatic) |
| `offset_on_reverse` | Float | No | 0.0 | Offset applied when trend reverses |
| `accel_init_long` | Float | No | 0.02 | Initial acceleration factor for long positions |
| `accel_long` | Float | No | 0.02 | Acceleration increment for long positions |
| `accel_max_long` | Float | No | 0.20 | Maximum acceleration for long positions |
| `accel_init_short` | Float | No | 0.02 | Initial acceleration factor for short positions |
| `accel_short` | Float | No | 0.02 | Acceleration increment for short positions |
| `accel_max_short` | Float | No | 0.20 | Maximum acceleration for short positions |

## Returns

Returns an array of SAREXT values. When SAREXT is below price, the trend is up; when above, the trend is down. Values may differ from standard SAR due to asymmetric parameters.

## Interpretation

SAREXT follows the same basic interpretation as standard SAR:
- **SAREXT below price**: Uptrend - hold long positions
- **SAREXT above price**: Downtrend - hold short positions
- **Price crosses SAREXT**: Trend reversal signal

However, with asymmetric parameters:
- Long positions can have tighter or looser stops than shorts
- Reversal sensitivity can differ between bullish and bearish signals
- Stop-loss progression speed can match market characteristics

## Understanding Extended Parameters

### Start Value
The initial SAR value when a new trend begins:
- **0.0 (default)**: Automatically calculated from recent price action
- **Custom value**: Useful for starting SAR at a known support/resistance level
- Rarely changed from default in practice

### Offset on Reverse
An additional offset applied when the trend reverses:
- **0.0 (default)**: No offset
- **Positive value**: Adds buffer space on reversal to avoid premature re-entries
- **Use case**: Volatile markets where whipsaws are common
- Example: 0.01 adds 1% buffer on trend reversals

### Acceleration Parameters (Long vs Short)

The key advantage of SAREXT is independent control of acceleration for longs and shorts:

**Initial Acceleration (accel_init_long/short)**
- Starting acceleration factor when entering a new trend
- Higher values = SAR moves faster initially
- Lower values = More conservative initial stop placement

**Acceleration Step (accel_long/short)**
- How much acceleration increases each period a trend continues
- Higher values = SAR accelerates faster over time
- Lower values = More gradual SAR progression

**Maximum Acceleration (accel_max_long/short)**
- Cap on how fast SAR can move
- Higher values = SAR can catch price more aggressively
- Lower values = More conservative trailing stops

## Example: Basic SAREXT vs Standard SAR

```ruby
high, low, close = load_historical_ohlc('AAPL')

# Standard SAR (symmetric parameters)
sar = SQA::TAI.sar(high, low, acceleration: 0.02, maximum: 0.20)

# SAREXT with same parameters (should match standard SAR)
sarext = SQA::TAI.sarext(
  high, low,
  accel_init_long: 0.02, accel_long: 0.02, accel_max_long: 0.20,
  accel_init_short: 0.02, accel_short: 0.02, accel_max_short: 0.20
)

puts "Standard SAR: #{sar.last.round(2)}"
puts "SAREXT (symmetric): #{sarext.last.round(2)}"
puts "Should be identical: #{(sar.last - sarext.last).abs < 0.01}"
```

## Example: Asymmetric Parameters for Crypto Markets

```ruby
# Cryptocurrencies often fall faster than they rise
high, low, close = load_historical_ohlc('BTC-USD')

sarext = SQA::TAI.sarext(
  high, low,
  # Conservative longs (slower acceleration)
  accel_init_long: 0.015,
  accel_long: 0.015,
  accel_max_long: 0.15,
  # Aggressive shorts (faster acceleration to protect against dumps)
  accel_init_short: 0.03,
  accel_short: 0.03,
  accel_max_short: 0.30
)

current_price = close.last
current_sarext = sarext.last

if current_price > current_sarext
  puts "LONG POSITION - Conservative trailing stop"
  puts "SAREXT at #{current_sarext.round(2)} (wider stop for volatility)"
else
  puts "SHORT POSITION - Aggressive trailing stop"
  puts "SAREXT at #{current_sarext.round(2)} (tighter stop for quick moves)"
end
```

## Example: Stock Market Asymmetry

```ruby
# Stocks often have slower downtrends than uptrends (sell-offs are gradual)
high, low, close = load_historical_ohlc('SPY')

sarext = SQA::TAI.sarext(
  high, low,
  # Standard longs
  accel_init_long: 0.02,
  accel_long: 0.02,
  accel_max_long: 0.20,
  # Slower shorts (stocks grind down, not crash)
  accel_init_short: 0.01,
  accel_short: 0.01,
  accel_max_short: 0.15
)

current_price = close.last
current_sarext = sarext.last

if current_price > current_sarext
  puts "UPTREND - Standard trailing stop"
else
  puts "DOWNTREND - Wider stop for grinding declines"
  puts "Avoiding premature exits in slow downtrends"
end
```

## Example: Adding Offset for Whipsaw Protection

```ruby
high, low, close = load_historical_ohlc('EURUSD', interval: '1h')

# Add offset on reverse to avoid immediate re-entry
sarext = SQA::TAI.sarext(
  high, low,
  offset_on_reverse: 0.0005,  # 5 pip buffer on forex
  accel_init_long: 0.02,
  accel_long: 0.02,
  accel_max_long: 0.20,
  accel_init_short: 0.02,
  accel_short: 0.02,
  accel_max_short: 0.20
)

prev_price = close[-2]
curr_price = close.last
prev_sarext = sarext[-2]
curr_sarext = sarext.last

# Detect reversal with offset protection
if prev_price < prev_sarext && curr_price > curr_sarext
  puts "BULLISH REVERSAL with #{(curr_sarext - prev_sarext).round(5)} offset buffer"
  puts "Reduces whipsaw risk by requiring clear break"
elsif prev_price > prev_sarext && curr_price < curr_sarext
  puts "BEARISH REVERSAL with #{(prev_sarext - curr_sarext).round(5)} offset buffer"
  puts "Reduces false signals in choppy markets"
end
```

## Example: Institutional Trading Strategy

```ruby
# Large positions need wider stops on entry, tighter on exit
high, low, close = load_historical_ohlc('AAPL')
volume = load_historical_data('AAPL', field: :volume)

sarext = SQA::TAI.sarext(
  high, low,
  # Slower initial acceleration (wider stops for position building)
  accel_init_long: 0.01,
  accel_init_short: 0.01,
  # Faster progression (tighter stops once position established)
  accel_long: 0.03,
  accel_short: 0.03,
  # High maximum (aggressive trailing once in profit)
  accel_max_long: 0.25,
  accel_max_short: 0.25
)

current_price = close.last
current_sarext = sarext.last
avg_volume = volume[-20..-1].sum / 20.0

if current_price > current_sarext
  distance = ((current_price - current_sarext) / current_price * 100)
  puts "LONG POSITION active"
  puts "Stop distance: #{distance.round(2)}%"

  if distance < 2.0
    puts "Initial accumulation phase - wide stop allows position building"
  elsif distance > 5.0
    puts "Established position - stop has tightened significantly"
    puts "Protecting profits with aggressive trailing"
  end
end
```

## Example: Comparing SAREXT Configurations

```ruby
high, low, close = load_historical_ohlc('MSFT')

# Standard SAR
sar_standard = SQA::TAI.sar(high, low, acceleration: 0.02, maximum: 0.20)

# Conservative SAREXT (wider stops)
sarext_conservative = SQA::TAI.sarext(
  high, low,
  accel_init_long: 0.01, accel_long: 0.01, accel_max_long: 0.15,
  accel_init_short: 0.01, accel_short: 0.01, accel_max_short: 0.15
)

# Aggressive SAREXT (tighter stops)
sarext_aggressive = SQA::TAI.sarext(
  high, low,
  accel_init_long: 0.03, accel_long: 0.03, accel_max_long: 0.30,
  accel_init_short: 0.03, accel_short: 0.03, accel_max_short: 0.30
)

# Asymmetric SAREXT (different long/short)
sarext_asymmetric = SQA::TAI.sarext(
  high, low,
  accel_init_long: 0.015, accel_long: 0.015, accel_max_long: 0.15,
  accel_init_short: 0.025, accel_short: 0.025, accel_max_short: 0.25
)

current_price = close.last

puts "Current Price: #{current_price.round(2)}"
puts "Standard SAR: #{sar_standard.last.round(2)}"
puts "Conservative SAREXT: #{sarext_conservative.last.round(2)} (widest stop)"
puts "Aggressive SAREXT: #{sarext_aggressive.last.round(2)} (tightest stop)"
puts "Asymmetric SAREXT: #{sarext_asymmetric.last.round(2)} (balanced)"

# Calculate stop distances
puts "\nStop Distances:"
[
  ['Standard', sar_standard.last],
  ['Conservative', sarext_conservative.last],
  ['Aggressive', sarext_aggressive.last],
  ['Asymmetric', sarext_asymmetric.last]
].each do |name, sar_value|
  distance = ((current_price - sar_value).abs / current_price * 100)
  puts "#{name}: #{distance.round(2)}%"
end
```

## When to Use Asymmetric Acceleration

### 1. Market Structure Differences
**Use faster short acceleration when:**
- Markets tend to crash/dump quickly (crypto, small caps)
- Bear markets are violent and fast
- You need tight stops to limit downside risk

**Use faster long acceleration when:**
- Markets rally strongly (momentum stocks, IPOs)
- Bull runs are explosive
- You want to capture upward momentum aggressively

### 2. Risk Management Preferences
**Conservative longs + Aggressive shorts:**
- Risk-averse approach
- Willing to hold longs through volatility
- Quick to exit shorts to avoid unlimited risk

**Aggressive longs + Conservative shorts:**
- Aggressive trader profile
- Chase momentum on longs
- Patient with shorts in grinding downtrends

### 3. Asset Class Characteristics
| Asset Class | Long Accel | Short Accel | Reasoning |
|-------------|------------|-------------|-----------|
| Large Cap Stocks | Standard (0.02/0.20) | Slower (0.01/0.15) | Slow grinds down |
| Crypto | Conservative (0.015/0.15) | Aggressive (0.03/0.30) | Fast crashes |
| Forex | Symmetric (0.02/0.20) | Symmetric (0.02/0.20) | Balanced moves |
| Small Caps | Aggressive (0.03/0.25) | Aggressive (0.03/0.25) | High volatility both ways |
| Commodities | Depends | Depends | Market-specific |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

### 4. Position Size Considerations
**Larger positions:**
- Use lower initial acceleration (wider entry stops)
- Use higher acceleration step (faster tightening)
- Allows position building without premature stops

**Smaller positions:**
- Can use standard parameters
- Less slippage risk on stops
- More flexibility to re-enter

## Advanced Techniques

### 1. Dynamic Parameter Selection
Adjust SAREXT parameters based on market conditions:
```ruby
atr = SQA::TAI.atr(high, low, close, period: 14)
volatility = atr.last / close.last

if volatility > 0.03  # High volatility (>3%)
  accel_long = 0.01   # Wider stops
  accel_max_long = 0.15
else  # Low volatility
  accel_long = 0.03   # Tighter stops
  accel_max_long = 0.25
end
```

### 2. Combining with Trend Filters
Use SAREXT with ADX to avoid choppy markets:
```ruby
adx = SQA::TAI.adx(high, low, close, period: 14)

if adx.last > 25  # Strong trend
  # Use SAREXT for trend following
  sarext = SQA::TAI.sarext(high, low, accel_long: 0.02, accel_max_long: 0.20)
else
  # Skip trading or use different strategy
  puts "ADX below 25 - market too choppy for SAR"
end
```

### 3. Multi-Timeframe SAREXT
Use different parameters on different timeframes:
```ruby
# Daily: Conservative for position management
sarext_daily = SQA::TAI.sarext(
  high_daily, low_daily,
  accel_long: 0.01, accel_max_long: 0.15
)

# Hourly: Aggressive for tactical entries/exits
sarext_hourly = SQA::TAI.sarext(
  high_hourly, low_hourly,
  accel_long: 0.03, accel_max_long: 0.30
)
```

### 4. Optimization for Specific Assets
Backtest to find optimal asymmetric parameters:
```ruby
# Example optimization results for BTC
# Win rate: 58%, Profit factor: 1.8
sarext_btc_optimized = SQA::TAI.sarext(
  high, low,
  accel_init_long: 0.018,
  accel_long: 0.018,
  accel_max_long: 0.16,
  accel_init_short: 0.028,
  accel_short: 0.028,
  accel_max_short: 0.28
)
```

## Common Configuration Patterns

### Pattern 1: Risk-Averse Trader
```ruby
sarext = SQA::TAI.sarext(
  high, low,
  accel_init_long: 0.01,    # Wide stops on longs
  accel_long: 0.01,
  accel_max_long: 0.15,
  accel_init_short: 0.03,   # Tight stops on shorts
  accel_short: 0.03,
  accel_max_short: 0.25,
  offset_on_reverse: 0.001  # Buffer against whipsaws
)
```

### Pattern 2: Momentum Trader
```ruby
sarext = SQA::TAI.sarext(
  high, low,
  accel_init_long: 0.03,    # Tight stops, chase momentum
  accel_long: 0.03,
  accel_max_long: 0.30,
  accel_init_short: 0.03,   # Symmetrical aggression
  accel_short: 0.03,
  accel_max_short: 0.30
)
```

### Pattern 3: Position Trader
```ruby
sarext = SQA::TAI.sarext(
  high, low,
  accel_init_long: 0.005,   # Very wide initial stops
  accel_long: 0.01,         # Gradual tightening
  accel_max_long: 0.10,     # Conservative max
  accel_init_short: 0.005,
  accel_short: 0.01,
  accel_max_short: 0.10
)
```

### Pattern 4: Scalper/Day Trader
```ruby
sarext = SQA::TAI.sarext(
  high, low,
  accel_init_long: 0.05,    # Very tight stops
  accel_long: 0.05,
  accel_max_long: 0.40,     # Aggressive max
  accel_init_short: 0.05,
  accel_short: 0.05,
  accel_max_short: 0.40,
  offset_on_reverse: 0.0    # No buffer needed in liquid markets
)
```

## SAREXT vs Standard SAR

| Feature | Standard SAR | SAREXT |
|---------|-------------|---------|
| Parameters | 2 (acceleration, maximum) | 10+ (separate long/short control) |
| Long/Short Settings | Symmetric (same for both) | Asymmetric (independent control) |
| Complexity | Simple, easy to understand | Complex, requires optimization |
| Best For | General trading, beginners | Advanced traders, specific markets |
| Optimization | Limited (2 parameters) | Extensive (many combinations) |
| Customization | Low | High |
| Market Adaptation | Fixed behavior | Can match market characteristics |
| Backtesting Time | Fast | Slower (more parameters) |

## Advantages of SAREXT

1. **Market-Specific Tuning**: Match acceleration to actual market behavior
2. **Risk Management Flexibility**: Different stops for longs vs shorts
3. **Asymmetric Trading**: Reflect that markets rise and fall differently
4. **Institutional Capability**: Complex position management strategies
5. **Optimization Potential**: More parameters to fit historical data
6. **Whipsaw Control**: Offset parameter reduces false signals

## Disadvantages of SAREXT

1. **Increased Complexity**: Many more parameters to understand and optimize
2. **Overfitting Risk**: Easy to over-optimize on historical data
3. **Harder to Test**: More combinations require extensive backtesting
4. **Not Standard**: Most literature covers standard SAR only
5. **Parameter Sensitivity**: Small changes can significantly impact results

## Best Practices

1. **Start with standard SAR**: Use symmetric parameters first
2. **Document market behavior**: Analyze if long/short characteristics differ
3. **Test incrementally**: Change one parameter set at a time
4. **Use walk-forward testing**: Avoid overfitting to historical data
5. **Monitor performance**: Track if asymmetric parameters actually help
6. **Consider simplicity**: Don't use SAREXT just because it's "advanced"
7. **Match time horizon**: Faster parameters for shorter timeframes
8. **Asset class research**: Study how your specific market moves

## When NOT to Use SAREXT

1. **Symmetric markets**: Forex majors, large-cap indexes
2. **Learning SAR**: Start with standard SAR first
3. **Lack of data**: Need sufficient history to optimize parameters
4. **Simple strategies**: Don't add complexity unnecessarily
5. **Short backtesting**: Insufficient data to validate asymmetric benefits

## Related Indicators

- [SAR](sar.md) - Standard Parabolic SAR (simpler, symmetric parameters)
- [ATR](atr.md) - Average True Range (volatility for parameter selection)
- [ADX](../momentum/adx.md) - Trend strength (filter for SAR usage)

## See Also

- [Back to Indicators](../index.md)
- [Volatility Indicators Overview](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
