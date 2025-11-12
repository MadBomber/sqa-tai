# MAMA (MESA Adaptive Moving Average)

The MESA Adaptive Moving Average (MAMA) is a sophisticated adaptive moving average developed by John F. Ehlers that automatically adjusts its period based on market phase measurements using MESA (Maximum Entropy Spectral Analysis). Unlike traditional moving averages with fixed periods, MAMA dynamically adapts to changing market conditions, providing faster response during trending markets and smoother behavior during ranging markets.

## Formula

MAMA uses phase rate of change to adjust its smoothing constant dynamically:

1. Calculate Phase Rate of Change using Hilbert Transform
2. Compute adaptive alpha from phase: alpha = fastlimit / (phase_rate + epsilon)
3. Constrain alpha between slowlimit and fastlimit
4. Apply: MAMA = alpha * Price + (1 - alpha) * MAMA_prev
5. FAMA (Following Adaptive MA) uses MAMA as input with further smoothing

The algorithm continuously measures the market's dominant cycle and adjusts the effective period between the fast and slow limits.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prices` | Array<Float> | Yes | - | Array of price values (typically close prices) |
| `fast_limit` | Float | No | 0.5 | Upper limit for adaptation speed (0.01 to 0.99) |
| `slow_limit` | Float | No | 0.05 | Lower limit for adaptation speed (0.01 to 0.99) |

### Parameter Details


**Note**: Array elements should be ordered from oldest to newest (chronological order)

**fast_limit**
- Controls maximum responsiveness during strong trends
- Higher values (0.5-0.9) make MAMA more responsive but noisier
- Lower values (0.3-0.5) provide smoother trending signals
- Default 0.5 provides balanced adaptation

**slow_limit**
- Controls minimum responsiveness during ranging markets
- Higher values (0.1-0.2) maintain some responsiveness in ranges
- Lower values (0.01-0.05) provide maximum smoothing in choppy markets
- Default 0.05 filters most noise in sideways markets

## Returns

Returns a two-element array containing:
1. **MAMA line** - The adaptive moving average
2. **FAMA line** - Following Adaptive Moving Average (smoothed MAMA)

Both arrays will have initial `nil` values while calculations stabilize (typically first 32+ data points).

## Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41,
          46.22, 45.64, 46.21, 46.25, 46.08, 46.46,
          46.82, 47.00, 47.32, 47.20, 47.57, 47.80,
          48.00, 48.15, 48.30, 48.40, 48.55, 48.70,
          48.85, 49.00, 49.15, 49.30, 49.45, 49.60]

# Calculate MAMA with default parameters
mama, fama = SQA::TAI.mama(prices)

# More responsive for short-term trading
mama_fast, fama_fast = SQA::TAI.mama(prices, fast_limit: 0.8, slow_limit: 0.1)

# Smoother for longer-term trends
mama_smooth, fama_smooth = SQA::TAI.mama(prices, fast_limit: 0.4, slow_limit: 0.02)

puts "MAMA: #{mama.last.round(2)}"
puts "FAMA: #{fama.last.round(2)}"
```

## Interpretation

MAMA's adaptive nature makes it superior to fixed-period moving averages in volatile or changing markets:

### Signal Types

- **MAMA crosses above FAMA**: Bullish signal - potential buy
- **MAMA crosses below FAMA**: Bearish signal - potential sell
- **Price above both MAMA and FAMA**: Strong uptrend
- **Price below both MAMA and FAMA**: Strong downtrend
- **MAMA slope**: Indicates trend strength and direction
- **MAMA/FAMA spread**: Wider spread suggests stronger trend momentum

### Adaptive Behavior

- **Trending Markets**: MAMA automatically shortens its effective period, reducing lag
- **Ranging Markets**: MAMA lengthens its effective period, filtering whipsaws
- **Transition Periods**: Smoothly adjusts between market phases
- **Less Lag**: Responds faster than fixed-period MAs in trend changes

## Example: MAMA/FAMA Crossover Trading

```ruby
prices = load_historical_prices('AAPL')
mama, fama = SQA::TAI.mama(prices, fast_limit: 0.5, slow_limit: 0.05)

# Current and previous values
curr_mama = mama.last
prev_mama = mama[-2]
curr_fama = fama.last
prev_fama = fama[-2]
current_price = prices.last

# Detect crossovers
if prev_mama <= prev_fama && curr_mama > curr_fama
  puts "BULLISH CROSSOVER: MAMA crossed above FAMA"
  puts "Signal: BUY"
  puts "Entry price: #{current_price.round(2)}"
elsif prev_mama >= prev_fama && curr_mama < curr_fama
  puts "BEARISH CROSSOVER: MAMA crossed below FAMA"
  puts "Signal: SELL/SHORT"
  puts "Entry price: #{current_price.round(2)}"
end

# Check trend strength
spread = ((curr_mama - curr_fama).abs / curr_mama * 100).round(2)
puts "MAMA/FAMA spread: #{spread}%"

if spread > 1.0
  puts "Strong trend momentum"
elsif spread < 0.3
  puts "Weak trend - potential ranging market"
end
```

## Example: Adaptive Support and Resistance

```ruby
prices = load_historical_prices('TSLA')
mama, fama = SQA::TAI.mama(prices)

current_price = prices.last
mama_value = mama.last
fama_value = fama.last

# MAMA acts as dynamic support in uptrends
if current_price > mama_value && mama_value > fama_value
  distance_to_mama = ((current_price - mama_value) / current_price * 100).round(2)

  puts "UPTREND: Price above MAMA"
  puts "MAMA acting as dynamic support at #{mama_value.round(2)}"
  puts "Distance to support: #{distance_to_mama}%"

  if distance_to_mama < 1.0
    puts "Price near MAMA support - potential bounce point"
  elsif distance_to_mama > 5.0
    puts "Price extended above MAMA - possible pullback"
  end
end

# MAMA acts as dynamic resistance in downtrends
if current_price < mama_value && mama_value < fama_value
  distance_to_mama = ((mama_value - current_price) / current_price * 100).round(2)

  puts "DOWNTREND: Price below MAMA"
  puts "MAMA acting as dynamic resistance at #{mama_value.round(2)}"
  puts "Distance to resistance: #{distance_to_mama}%"

  if distance_to_mama < 1.0
    puts "Price near MAMA resistance - potential rejection point"
  end
end
```

## Example: Trend Confirmation System

```ruby
prices = load_historical_prices('SPY')
mama, fama = SQA::TAI.mama(prices)

current_price = prices.last
mama_curr = mama.last
mama_prev = mama[-5]  # 5 periods ago
fama_curr = fama.last
fama_prev = fama[-5]

# Calculate slopes
mama_slope = mama_curr - mama_prev
fama_slope = fama_curr - fama_prev

# Trend strength analysis
mama_rising = mama_slope > 0
fama_rising = fama_slope > 0
price_above_mama = current_price > mama_curr
price_above_fama = current_price > fama_curr

puts <<~TREND_ANALYSIS
  === MAMA Trend Analysis ===
  Current Price: #{current_price.round(2)}
  MAMA: #{mama_curr.round(2)} (#{mama_rising ? 'Rising' : 'Falling'})
  FAMA: #{fama_curr.round(2)} (#{fama_rising ? 'Rising' : 'Falling'})
TREND_ANALYSIS

if mama_rising && fama_rising && price_above_mama && price_above_fama
  puts "\nSTRONG UPTREND CONFIRMED"
  puts "- Both MAMA and FAMA rising"
  puts "- Price above both adaptive MAs"
  puts "- High probability continuation"
elsif !mama_rising && !fama_rising && !price_above_mama && !price_above_fama
  puts "\nSTRONG DOWNTREND CONFIRMED"
  puts "- Both MAMA and FAMA falling"
  puts "- Price below both adaptive MAs"
  puts "- High probability continuation"
elsif mama_rising && !fama_rising
  puts "\nEARLY TREND CHANGE - Potential reversal forming"
  puts "- MAMA turning before FAMA"
  puts "- Watch for FAMA confirmation"
else
  puts "\nCONSOLIDATION/TRANSITION - No clear trend"
  puts "- Mixed signals between MAMA and FAMA"
  puts "- Wait for clearer alignment"
end
```

## Example: Multi-Parameter Comparison

```ruby
prices = load_historical_prices('NVDA')

# Fast adaptation - responsive to quick changes
mama_fast, fama_fast = SQA::TAI.mama(prices, fast_limit: 0.8, slow_limit: 0.1)

# Standard adaptation - balanced approach
mama_std, fama_std = SQA::TAI.mama(prices, fast_limit: 0.5, slow_limit: 0.05)

# Slow adaptation - smooth trending
mama_slow, fama_slow = SQA::TAI.mama(prices, fast_limit: 0.3, slow_limit: 0.02)

current_price = prices.last

puts <<~COMPARISON
  === MAMA Parameter Comparison ===
  Current Price: #{current_price.round(2)}

  Fast MAMA (0.8/0.1): #{mama_fast.last.round(2)}
  Standard MAMA (0.5/0.05): #{mama_std.last.round(2)}
  Slow MAMA (0.3/0.02): #{mama_slow.last.round(2)}
COMPARISON

# Check agreement across timeframes
fast_above = current_price > mama_fast.last
std_above = current_price > mama_std.last
slow_above = current_price > mama_slow.last

if fast_above && std_above && slow_above
  puts "\nUNIVERSAL UPTREND - All MAMA settings bullish"
  puts "Highest confidence long signal"
elsif !fast_above && !std_above && !slow_above
  puts "\nUNIVERSAL DOWNTREND - All MAMA settings bearish"
  puts "Highest confidence short signal"
else
  puts "\nMIXED SIGNALS - Use standard MAMA for primary guidance"
end
```

## Example: MAMA with Price Action Confirmation

```ruby
prices = load_historical_prices('MSFT')
mama, fama = SQA::TAI.mama(prices)

# Get recent price action
recent_high = prices[-10..-1].max
recent_low = prices[-10..-1].min
current_price = prices.last
mama_value = mama.last
fama_value = fama.last

# Bullish setup
if mama_value > fama_value  # MAMA above FAMA (uptrend)
  if current_price <= mama_value && current_price >= fama_value
    puts "BULLISH PULLBACK SETUP"
    puts "Price between MAMA and FAMA in uptrend"
    puts "Support zone: #{fama_value.round(2)} - #{mama_value.round(2)}"
    puts "Look for bullish price action reversal patterns"
  end

  if current_price > recent_high && mama_value > fama_value
    puts "BULLISH BREAKOUT"
    puts "New high with MAMA/FAMA confirming uptrend"
    puts "Strong momentum continuation signal"
  end
end

# Bearish setup
if mama_value < fama_value  # MAMA below FAMA (downtrend)
  if current_price >= mama_value && current_price <= fama_value
    puts "BEARISH RALLY SETUP"
    puts "Price between MAMA and FAMA in downtrend"
    puts "Resistance zone: #{mama_value.round(2)} - #{fama_value.round(2)}"
    puts "Look for bearish price action reversal patterns"
  end

  if current_price < recent_low && mama_value < fama_value
    puts "BEARISH BREAKDOWN"
    puts "New low with MAMA/FAMA confirming downtrend"
    puts "Strong momentum continuation signal"
  end
end
```

## Example: MAMA Adaptive Period Estimation

```ruby
prices = load_historical_prices('BTC-USD')
mama, fama = SQA::TAI.mama(prices, fast_limit: 0.5, slow_limit: 0.05)

# Estimate effective period from MAMA behavior
# Compare MAMA responsiveness to known period MAs
ema_10 = SQA::TAI.ema(prices, period: 10)
ema_20 = SQA::TAI.ema(prices, period: 20)
ema_50 = SQA::TAI.ema(prices, period: 50)

mama_value = mama.last
distance_10 = (mama_value - ema_10.last).abs
distance_20 = (mama_value - ema_20.last).abs
distance_50 = (mama_value - ema_50.last).abs

# Find closest match
min_distance = [distance_10, distance_20, distance_50].min

effective_period = case min_distance
when distance_10 then "~10 periods (fast adaptation)"
when distance_20 then "~20 periods (moderate adaptation)"
when distance_50 then "~50 periods (slow adaptation)"
end

puts <<~ANALYSIS
  === MAMA Adaptive Period Analysis ===
  MAMA currently behaving like: #{effective_period}

  This suggests the market is currently:
ANALYSIS

if min_distance == distance_10
  puts "- In a strong trending phase (short effective period)"
  puts "- High volatility and directional movement"
  puts "- MAMA is maximally responsive"
elsif min_distance == distance_50
  puts "- In a ranging or choppy phase (long effective period)"
  puts "- Lower volatility and sideways movement"
  puts "- MAMA is maximally smooth"
else
  puts "- In a transitional phase (medium effective period)"
  puts "- Moderate volatility with developing trend"
  puts "- MAMA is moderately adaptive"
end
```

## Advantages Over Fixed-Period Moving Averages

1. **Automatic Adaptation**: Adjusts period based on market phase without manual intervention
2. **Reduced Whipsaws**: Lengthens period during ranging markets to filter noise
3. **Faster Trend Response**: Shortens period during trending markets for timely signals
4. **Phase Detection**: Built-in market phase analysis through MESA technology
5. **Dual Confirmation**: MAMA/FAMA pair provides both signal and confirmation
6. **Universal Application**: Works across all markets, timeframes, and volatility regimes

## MAMA vs Other Adaptive MAs

| Feature | MAMA | KAMA | Standard EMA |
|---------|------|------|--------------|
| Adaptation Method | Phase rate (MESA) | Efficiency Ratio | Fixed alpha |
| Speed | Phase-dependent | Volatility-dependent | Constant |
| Lag | Minimal in trends | Low in trends | Moderate |
| Noise Filtering | Excellent | Good | Fair |
| Complexity | High | Moderate | Low |
| Best For | All market phases | Trending markets | Stable trends |

## Common Parameter Settings

| Setting | Fast Limit | Slow Limit | Use Case |
|---------|-----------|------------|----------|
| Aggressive | 0.8 | 0.1 | Day trading, scalping, high-frequency signals |
| Standard | 0.5 | 0.05 | Swing trading, default balanced approach |
| Conservative | 0.3 | 0.02 | Position trading, long-term trends |
| Custom Trend | 0.6 | 0.03 | Optimized for strong trending markets |
| Custom Range | 0.4 | 0.08 | Optimized for choppy ranging markets |

## Best Practices

1. **Use MAMA/FAMA Crossovers**: Primary signal generation method
2. **Confirm with Price Action**: Combine with support/resistance and patterns
3. **Consider Market Phase**: MAMA works best when phase detection is accurate (requires sufficient data)
4. **Wait for Confirmation**: Use FAMA to confirm MAMA signals, reducing false entries
5. **Minimum Data Requirement**: Use at least 32+ data points, preferably 63+ for stability
6. **Combine with Volume**: Confirm crossover signals with volume analysis
7. **Avoid in Extremely Choppy Markets**: Even adaptive MAs struggle with pure noise
8. **Use Appropriate Timeframe**: Works across timeframes but test settings for your specific use case

## Limitations

1. **Computational Complexity**: More complex than traditional MAs, requires more processing
2. **Initial Instability**: First 32+ values may be unreliable during calculation warm-up
3. **Not Predictive**: Adapts to current phase but doesn't forecast future phase changes
4. **Occasional Lag**: Still has some lag in rapid trend reversals
5. **Parameter Sensitivity**: Fast/slow limits need adjustment for different market characteristics
6. **Black Box Component**: Phase detection algorithm is not transparent

## Market Applications

### Day Trading
- Use aggressive settings (0.8/0.1) for quick entries/exits
- Combine with volume and momentum indicators
- Watch for MAMA/FAMA alignment on multiple intraday timeframes

### Swing Trading
- Use standard settings (0.5/0.05) for balanced signals
- Use MAMA as dynamic support/resistance
- Confirm crossovers with daily trend direction

### Position Trading
- Use conservative settings (0.3/0.02) for major trend changes
- Combine with weekly/monthly trend analysis
- Use MAMA slope for trend strength assessment

### Trend Following
- Enter on MAMA/FAMA crossovers in direction of higher timeframe
- Use pullbacks to MAMA as entry opportunities
- Exit when price crosses below FAMA in uptrend (or above in downtrend)

## Related Indicators

- [KAMA](../overlap/kama.md) - Kaufman Adaptive Moving Average
- [EMA](../overlap/ema.md) - Exponential Moving Average
- [DEMA](../overlap/dema.md) - Double Exponential Moving Average
- [T3](../overlap/t3.md) - Tillson T3 Moving Average
- [HT_TRENDLINE](ht_trendline.md) - Hilbert Transform Trendline
- [HT_DCPERIOD](../cycle/ht_dcperiod.md) - Hilbert Transform Dominant Cycle Period
- [HT_SINE](../cycle/ht_sine.md) - Hilbert Transform Sine Wave

## Technical Background

MAMA was developed by John F. Ehlers and introduced in his book "Rocket Science for Traders: Digital Signal Processing Applications". It represents a significant advancement in moving average technology by:

- Applying Maximum Entropy Spectral Analysis (MESA) to financial markets
- Using Hilbert Transform mathematics for phase detection
- Creating an adaptive smoothing constant based on dominant cycle measurements
- Providing a following moving average (FAMA) for signal confirmation

The indicator is part of Ehlers' broader work on applying digital signal processing (DSP) techniques to trading, which includes cycle analysis, phase detection, and adaptive filtering.

## Further Reading

- "Rocket Science for Traders" by John F. Ehlers - Original MAMA presentation
- "Cybernetic Analysis for Stocks and Futures" by John F. Ehlers - Advanced applications
- "MESA and Trading Market Cycles" by John F. Ehlers - MESA theory fundamentals
- "Digital Signal Processing" - General DSP principles applied to markets

## See Also

- [Back to Indicators](../index.md)
- [Volatility Indicators Overview](../index.md)
- [Cycle Indicators](../cycle/index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
