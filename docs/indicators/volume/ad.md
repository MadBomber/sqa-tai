# AD (Chaikin Accumulation/Distribution Line)

## Overview

The Chaikin Accumulation/Distribution Line (AD) is a cumulative volume-based indicator that measures the flow of money into and out of a security. Developed by Marc Chaikin, it uses both price location within the bar's range and volume to determine whether a security is being accumulated (bought) or distributed (sold). Unlike simple volume indicators, AD considers where the price closes within the period's range, making it more sophisticated for identifying true buying or selling pressure.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `high` | Array | Required | Array of high prices for each period |
| `low` | Array | Required | Array of low prices for each period |
| `close` | Array | Required | Array of closing prices for each period |
| `volume` | Array | Required | Array of volume values for each period |

### Parameter Details


**Note**: Array elements should be ordered from oldest to newest (chronological order)

**high**
- The highest price reached during each period
- Must have same length as other price arrays
- Required for calculating the price range and money flow multiplier
- Essential for determining how close the close price is to the high

**low**
- The lowest price reached during each period
- Must have same length as other price arrays
- Required for calculating the price range and money flow multiplier
- Essential for determining how close the close price is to the low

**close**
- The final price at the end of each period
- Must have same length as other price arrays
- Critical for determining accumulation or distribution
- Position within high-low range determines the money flow multiplier

**volume**
- The trading volume for each period
- Must have same length as price arrays
- Weights the money flow by actual trading activity
- Higher volume periods have greater impact on the cumulative line

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

# OHLC data + Volume required
high   = [46.08, 46.41, 46.46, 46.57, 46.50, 47.03, 47.35]
low    = [44.61, 44.83, 45.64, 45.95, 46.02, 46.50, 47.28]
close  = [45.42, 45.84, 46.08, 46.46, 46.55, 47.03, 47.28]
volume = [2500, 3200, 2800, 4100, 3500, 4200, 3600]

# Calculate A/D Line
ad = SQA::TAI.ad(high, low, close, volume)

puts "Current A/D: #{ad.last.round(0)}"
```

### Trend Analysis

```ruby
# Analyze A/D trend with moving average
high, low, close, volume = load_ohlc_volume_data('AAPL')

ad = SQA::TAI.ad(high, low, close, volume)
ad_ma = SQA::TAI.sma(ad, period: 20)

if ad.last > ad_ma.last
  puts "A/D above MA: Accumulation phase"
else
  puts "A/D below MA: Distribution phase"
end
```

## Understanding the Indicator

### What It Measures

The AD Line measures the cumulative flow of money based on where prices close within their daily range:

- **Money Flow Direction**: Whether buyers or sellers are in control
- **Volume Confirmation**: If price moves are supported by volume
- **Accumulation vs Distribution**: Whether smart money is buying or selling
- **Trend Strength**: If price trends are supported by volume flow

AD answers the question: "Is volume flowing into or out of this security, and does it confirm the price action?"

### Calculation Method

The AD Line is calculated using a multi-step process:

1. **Calculate Money Flow Multiplier**: Determines where the close is within the period's range
2. **Calculate Money Flow Volume**: Multiplies the multiplier by the period's volume
3. **Accumulate**: Adds the money flow volume to the running total

**Formula:**
```
Money Flow Multiplier = ((Close - Low) - (High - Close)) / (High - Low)
Money Flow Volume = Money Flow Multiplier × Volume
A/D Line = Previous A/D + Current Money Flow Volume

Where Money Flow Multiplier ranges from -1 to +1:
- Close near high = ~+1 (accumulation)
- Close near low = ~-1 (distribution)
- Close in middle = ~0 (neutral)
```

**Example Calculation:**
If High=50, Low=45, Close=49, Volume=1000:
- Money Flow Multiplier = ((49-45) - (50-49)) / (50-45) = 3/5 = 0.6
- Money Flow Volume = 0.6 × 1000 = 600
- AD Line increases by 600

### Indicator Characteristics

- **Range**: Unbounded (can be any value, positive or negative)
- **Type**: Cumulative volume indicator
- **Lag**: Low to moderate (responds to price/volume immediately)
- **Best Used**: Trending markets, divergence analysis, confirming breakouts
- **Limitations**: Cumulative nature means absolute values can't be compared across securities

## Interpretation

### Value Ranges

Understanding AD Line values:

- **Rising AD Line**: Indicates accumulation with buying pressure dominating. Volume is flowing into the security as prices close near highs.
- **Falling AD Line**: Indicates distribution with selling pressure dominating. Volume is flowing out as prices close near lows.
- **Flat AD Line**: Indicates balance or neutral money flow. Neither buyers nor sellers have clear control.

**Important**: AD is cumulative and unbounded, so absolute values are not meaningful. Focus on the direction and changes in the line rather than specific numbers.

### Key Patterns

- **AD Confirms Price Trend**: When both price and AD move in same direction, trend is healthy and supported by volume
- **Bullish Divergence**: Price makes lower low, AD makes higher low - suggests selling pressure weakening
- **Bearish Divergence**: Price makes higher high, AD makes lower high - suggests buying pressure weakening
- **AD Leading Price**: AD changes direction before price, providing early warning of potential reversal

### Signal Interpretation

How to read the AD Line's signals:

1. **Trend Confirmation**
   - Price rising, AD rising: Strong uptrend with accumulation
   - Price falling, AD falling: Strong downtrend with distribution
   - Both moving together: High confidence in trend continuation

2. **Divergence Warnings**
   - Price makes new high, AD doesn't: Warning of weak buying, potential top
   - Price makes new low, AD doesn't: Warning of weak selling, potential bottom
   - Divergences work best when price is at extremes or key levels

3. **Breakout Confirmation**
   - Price breaks resistance, AD breaks to new high: Validated breakout
   - Price breaks support, AD breaks to new low: Validated breakdown
   - Lack of AD confirmation: Suspect breakout, likely false signal

## Trading Signals

### Buy Signals

Specific conditions that generate buy signals:

1. **Primary Signal**: AD Line crosses above its moving average
   - Confirms shift from distribution to accumulation
   - Best when price is in uptrend or breaking resistance

2. **Divergence Signal**: Price makes lower low, AD makes higher low
   - Bullish divergence indicates weakening selling pressure
   - Strongest when occurring near support levels
   - Requires confirmation from price action

3. **Breakout Confirmation**: Price breaks above resistance AND AD breaks to new high
   - Validates breakout with volume support
   - High probability of sustained move

**Example Scenario:**
```
When price breaks above resistance at $100 and AD Line simultaneously
makes a new high, consider a long position:
- Entry: $100.50 (above resistance)
- Stop loss: $97.50 (below breakout level)
- Target: Based on prior range or resistance levels
```

### Sell Signals

Specific conditions that generate sell signals:

1. **Primary Signal**: AD Line crosses below its moving average
   - Confirms shift from accumulation to distribution
   - Best when price is in downtrend or breaking support

2. **Divergence Signal**: Price makes higher high, AD makes lower high
   - Bearish divergence indicates weakening buying pressure
   - Strongest when occurring near resistance levels
   - Requires confirmation from price action

3. **Breakdown Confirmation**: Price breaks below support AND AD breaks to new low
   - Validates breakdown with volume support
   - High probability of continued decline

**Example Scenario:**
```
When price makes new high at $115 but AD Line fails to make new high
(bearish divergence), consider closing longs or initiating shorts:
- Wait for price confirmation (break below support)
- Entry: After break of nearest support
- Stop loss: Above recent high
- Target: Based on divergence magnitude
```

### Divergence Analysis

**Bullish Divergence:**
- **Pattern**: Price makes lower lows, AD makes higher lows
- **Identification**: Compare price troughs with AD troughs over 20-60 bars
- **Significance**: Sellers losing control despite lower prices, potential reversal ahead
- **Reliability**: High when combined with oversold conditions or major support
- **Example**: Stock drops from $100 to $90, then to $85. AD drops from 50000 to 45000, then only to 47000.

**Bearish Divergence:**
- **Pattern**: Price makes higher highs, AD makes lower highs
- **Identification**: Compare price peaks with AD peaks over 20-60 bars
- **Significance**: Buyers losing control despite higher prices, potential reversal ahead
- **Reliability**: High when combined with overbought conditions or major resistance
- **Example**: Stock rises from $100 to $110, then to $115. AD rises from 50000 to 60000, then only to 58000.

## Best Practices

### Optimal Use Cases

When AD works best:

- **Market conditions**: Most effective in trending markets. Ranging markets produce less meaningful signals as money flow oscillates.
- **Time frames**: Works on all timeframes but most reliable on daily and weekly charts. Intraday can be noisy.
- **Asset classes**: Excellent for stocks and ETFs where volume is meaningful. Less reliable for forex (no centralized volume). Works well for cryptocurrencies with reliable volume data.

### Combining with Other Indicators

Recommended indicator combinations:

- **With Trend Indicators**: Use with moving averages or MACD to confirm trend direction. Only take AD signals aligned with the major trend.

- **With Price Patterns**: AD is powerful for confirming breakouts, head and shoulders patterns, and double tops/bottoms. Look for AD confirmation before entering.

- **With OBV**: Compare AD with On Balance Volume for comprehensive volume analysis. AD is more sophisticated (considers close location), OBV is simpler (just direction).

### Common Pitfalls

What to avoid:

1. **Comparing absolute values across securities**: AD is cumulative and starting point is arbitrary. Only compare direction and changes, not absolute numbers.

2. **Ignoring price action**: AD divergences need price confirmation. Don't trade divergences alone without waiting for price reversal signal.

3. **Using in ranging markets**: AD oscillates in choppy markets, generating many false signals. Works best in clear trends.

4. **Expecting immediate results**: AD is sometimes a leading indicator, but divergences can persist for extended periods. Be patient and wait for confirmation.

### Parameter Selection Guidelines

AD has no adjustable parameters, but you can optimize how you use it:

- **Moving Average Period**: Apply 10-20 period MA to AD for trend identification
  - 10-period: More responsive, catches changes faster
  - 20-period: Smoother, fewer false signals
  - 50-period: Long-term trend identification

- **Divergence Lookback**: When scanning for divergences
  - Short-term: 20-30 bars for swing trading
  - Medium-term: 40-60 bars for position trading
  - Long-term: 100+ bars for major trend changes

## Practical Example

Complete trading example with context:

```ruby
require 'sqa/tai'

# Load historical data
high, low, close, volume = load_ohlc_volume_data('AAPL')

# Calculate AD and supporting indicators
ad = SQA::TAI.ad(high, low, close, volume)
ad_ma_20 = SQA::TAI.sma(ad, period: 20)
price_ma_50 = SQA::TAI.sma(close, period: 50)

# Current values
current_price = close.last
current_ad = ad.last
price_trend = current_price > price_ma_50.last ? "UPTREND" : "DOWNTREND"

puts "=== AD Line Trading Analysis ==="
puts "Current Price: $#{current_price.round(2)}"
puts "Current AD: #{current_ad.round(0)}"
puts "Price Trend: #{price_trend}"
puts

# Trend alignment analysis
ad_above_ma = current_ad > ad_ma_20.last
price_above_ma = current_price > price_ma_50.last

if price_above_ma && ad_above_ma
  puts "STRONG BULL SIGNAL: Both price and AD above their MAs"
  puts "Healthy uptrend supported by accumulation"
  puts "Strategy: Hold longs, look for dip entries"

elsif !price_above_ma && !ad_above_ma
  puts "STRONG BEAR SIGNAL: Both price and AD below their MAs"
  puts "Healthy downtrend supported by distribution"
  puts "Strategy: Avoid longs, consider shorts on rallies"

elsif price_above_ma && !ad_above_ma
  puts "WARNING: Price above MA but AD below MA"
  puts "Uptrend not supported by money flow"
  puts "Strategy: Take profits, avoid new longs"

elsif !price_above_ma && ad_above_ma
  puts "POTENTIAL REVERSAL: Price below MA but AD above MA"
  puts "Accumulation occurring during weakness"
  puts "Strategy: Watch for price trend change"
end

# Divergence detection
puts "\n=== Divergence Analysis ==="
recent_price_high = close[-30..-1].max
recent_price_low = close[-30..-1].min
recent_ad_high = ad[-30..-1].max
recent_ad_low = ad[-30..-1].min

prior_price_high = close[-60..-31].max
prior_price_low = close[-60..-31].min
prior_ad_high = ad[-60..-31].max
prior_ad_low = ad[-60..-31].min

# Bearish divergence check
if recent_price_high > prior_price_high && recent_ad_high < prior_ad_high
  puts "BEARISH DIVERGENCE DETECTED"
  puts "Price: #{prior_price_high.round(2)} -> #{recent_price_high.round(2)} (higher)"
  puts "AD: #{prior_ad_high.round(0)} -> #{recent_ad_high.round(0)} (lower)"
  puts "Action: Consider profit taking or short positions"
end

# Bullish divergence check
if recent_price_low < prior_price_low && recent_ad_low > prior_ad_low
  puts "BULLISH DIVERGENCE DETECTED"
  puts "Price: #{prior_price_low.round(2)} -> #{recent_price_low.round(2)} (lower)"
  puts "AD: #{prior_ad_low.round(0)} -> #{recent_ad_low.round(0)} (higher)"
  puts "Action: Watch for price reversal, consider long positions"
end

# Money flow momentum
ad_5day_change = ad.last - ad[-5]
puts "\n=== Short-term Money Flow ==="
puts "5-day AD Change: #{ad_5day_change.round(0)}"
if ad_5day_change > 0
  puts "Recent money flow: BULLISH (accumulation)"
else
  puts "Recent money flow: BEARISH (distribution)"
end
```

## Related Indicators

### Similar Indicators
- **[On Balance Volume (OBV)](obv.md)**: Simpler volume indicator that adds/subtracts entire volume based on price direction. OBV is easier to understand but less sophisticated than AD. Use OBV for simple confirmation, AD for detailed analysis.

- **[Money Flow Index (MFI)](../momentum/mfi.md)**: Similar concept but expressed as an oscillator (0-100). MFI includes volume in RSI-like calculation. Use MFI for overbought/oversold, AD for trend and divergence.

### Complementary Indicators
- **[MACD](../momentum/macd.md)**: Trend-following momentum indicator. Use MACD for trend direction, AD for volume confirmation.

- **[RSI](../momentum/rsi.md)**: Momentum oscillator. Combine RSI extremes with AD divergences for high-probability setups.

- **[Moving Averages](../overlap/sma.md)**: Apply MAs to both price and AD to identify trend alignment and divergences.

### Indicator Family
AD belongs to the volume flow indicator family:
- **AD (Chaikin)**: Considers close location within range
- **OBV**: Simple binary (up day/down day)
- **Chaikin Money Flow**: AD expressed as oscillator
- **Money Flow Index**: Volume-weighted RSI

**When to prefer AD**: For detailed volume flow analysis, identifying divergences, and confirming breakouts. AD's consideration of close location makes it more nuanced than OBV.

## Advanced Topics

### Multi-Timeframe Analysis

Use AD across multiple timeframes for comprehensive analysis:

- **Daily AD**: Shows intermediate trend and money flow direction
- **Weekly AD**: Identifies major accumulation/distribution phases
- **Intraday AD**: Provides entry timing (though noisier)

Strongest signals occur when multiple timeframes align (e.g., weekly AD rising, daily AD rising, confirms strong accumulation).

### Market Regime Adaptation

AD behavior in different market conditions:

- **Bull Markets**: AD tends to rise steadily. Pullbacks with flat/rising AD are buying opportunities.
- **Bear Markets**: AD tends to fall steadily. Rallies with flat/falling AD are selling opportunities.
- **Ranging Markets**: AD oscillates, less useful. Focus more on divergences at range extremes.
- **High Volatility**: AD becomes more erratic. Use longer MAs (30-50 period) to smooth the signal.

### Statistical Validation

AD reliability considerations:

- **Divergence Success Rate**: Studies show AD divergences have 60-70% success rate when confirmed by price action
- **Lead Time**: AD often leads price by 3-10 bars, providing early warning
- **Best with Volume**: Works best on high-volume securities where volume data is reliable and meaningful
- **Confirmation Importance**: Waiting for price confirmation of AD signals improves success rate from ~50% to 70%+

## References

- Chaikin, Marc. "The Chaikin Oscillator" - Original development by Marc Chaikin
- Murphy, John J. "Technical Analysis of the Financial Markets" (1999) - Comprehensive coverage of volume indicators
- [StockCharts: Accumulation/Distribution Line](https://school.stockcharts.com/doku.php?id=technical_indicators:accumulation_distribution_line)
- [TradingView: AD Line Guide](https://www.tradingview.com/support/solutions/43000501640-accumulation-distribution-adl/)

## See Also

- [Volume Indicators Overview](../index.md)
- [ADOSC - Chaikin A/D Oscillator](adosc.md)
- [OBV - On Balance Volume](obv.md)
- [Basic Usage Guide](../../getting-started/basic-usage.md)
