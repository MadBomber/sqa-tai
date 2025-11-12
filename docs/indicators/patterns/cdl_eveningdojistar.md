# CDL_EVENINGDOJISTAR (Evening Doji Star)

## Overview

The Evening Doji Star is a three-candle bearish reversal pattern that typically appears at the top of an uptrend. It consists of a long bullish candle, followed by a doji that gaps up, and then a long bearish candle that closes well into the body of the first candle. This pattern signals potential trend exhaustion and a shift from bullish to bearish sentiment, warning traders of an imminent downward reversal.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `open` | Array<Float> | Required | Array of opening prices for each period |
| `high` | Array<Float> | Required | Array of high prices for each period |
| `low` | Array<Float> | Required | Array of low prices for each period |
| `close` | Array<Float> | Required | Array of closing prices for each period |
| `penetration` | Float | 0.3 | Percentage of penetration of the third candle into the first candle's body (0.0 to 1.0) |

### Parameter Details


**Note**: Array elements should be ordered from oldest to newest (chronological order)

**open**
- Opening price for each trading period
- Must be same length as high, low, and close arrays
- Used to determine candle body direction and size

**high**
- Highest price reached during each trading period
- Must be same length as other price arrays
- Critical for identifying gaps and upper shadows

**low**
- Lowest price reached during each trading period
- Must be same length as other price arrays
- Used to identify shadow lengths and gap characteristics

**close**
- Closing price for each trading period
- Must be same length as other price arrays
- Used to determine candle body direction and pattern completion

**penetration**
- Controls how far the third candle must close into the first candle's body
- Default 0.3 means 30% penetration required
- Higher values (e.g., 0.5) make pattern detection more strict
- Lower values (e.g., 0.1) make pattern detection more lenient

## Usage

### Basic Usage

```ruby
require 'sqa/tai'

# Price data arrays showing uptrend and reversal
open  = [45.0, 47.0, 48.5, 48.6, 46.5]
high  = [47.5, 48.8, 48.7, 48.8, 46.8]
low   = [45.0, 46.8, 48.4, 48.5, 44.5]
close = [47.0, 48.5, 48.6, 48.5, 45.0]

result = SQA::TAI.cdl_eveningdojistar(open, high, low, close)
puts "Pattern Signal: #{result.last}"
```

### With Custom Penetration

```ruby
# More strict pattern detection with 50% penetration
result = SQA::TAI.cdl_eveningdojistar(
  open,
  high,
  low,
  close,
  penetration: 0.5
)

# Check for pattern detection
if result.last == -100
  puts "Bearish Evening Doji Star detected!"
end
```

### Real-Time Pattern Monitoring

```ruby
# Monitor multiple periods for pattern emergence
open  = [42.0, 44.0, 46.0, 48.0, 49.5, 49.6, 47.5]
high  = [44.5, 46.5, 48.5, 49.8, 49.8, 49.8, 47.8]
low   = [42.0, 43.8, 45.8, 47.8, 49.3, 49.4, 45.5]
close = [44.0, 46.0, 48.0, 49.5, 49.6, 49.5, 46.0]

result = SQA::TAI.cdl_eveningdojistar(open, high, low, close)

result.each_with_index do |signal, index|
  if signal == -100
    puts "Bearish pattern detected at period #{index}"
    puts "Entry: #{close[index]}, Previous high: #{high[index-1]}"
  end
end
```

## Understanding the Indicator

### What It Measures

The Evening Doji Star pattern measures potential reversal points at the end of bullish trends. It identifies a specific three-candle sequence that suggests buyers are losing control and sellers may be entering the market. The pattern is valuable because:

- It shows indecision (doji) after a strong bullish move, indicating buyer exhaustion
- The gap up followed by a gap down demonstrates a dramatic shift in sentiment
- The strong bearish third candle confirms seller commitment
- It provides an early warning of potential trend reversal at market tops

### Pattern Formation

The pattern requires three consecutive candles in this specific sequence:

1. **First Candle (Bullish)**: A long bullish candle showing strong buying pressure, typically near the peak of an uptrend. The candle should have a substantial body with close significantly above open.

2. **Second Candle (Doji)**: A doji candle that gaps up from the first candle's close. The doji indicates market indecision with opening and closing prices nearly equal. This shows buyers are losing momentum.

3. **Third Candle (Bearish)**: A long bearish candle that gaps down from the doji and closes well into the first candle's body (controlled by the penetration parameter). This confirms sellers have taken control.

**Key Characteristics:**
- The doji must gap away from both the first and third candles
- The third candle should close at least 30% (default) into the first candle's body
- The gaps demonstrate dramatic sentiment shifts
- All three candles should show clear directional intent or indecision

### Indicator Characteristics

- **Range**: Returns integer values: 0 (no pattern), -100 (bearish pattern detected)
- **Type**: Pattern recognition, reversal indicator
- **Lag**: None - identifies patterns as they complete (requires three candles)
- **Best Used**: At the end of established uptrends, overbought conditions
- **Reliability**: Moderate to high when confirmed with other indicators
- **Time Frame**: Works on all time frames; more reliable on daily and weekly charts

## Interpretation

### Signal Values

The indicator returns specific integer values:

- **-100 (Bearish Signal)**: Evening Doji Star pattern detected
  - Indicates potential bearish reversal
  - Suggests uptrend may be ending
  - Sellers are overwhelming buyers
  - Consider short positions or exit longs with confirmation

- **0 (No Pattern)**: No Evening Doji Star pattern at this position
  - Pattern requirements not met
  - Continue monitoring other indicators
  - Wait for pattern completion or other signals

### Pattern Strength Indicators

Assess the reliability of the pattern by examining:

1. **Prior Trend Strength**
   - Pattern is most reliable after extended uptrends
   - Multiple bullish candles before pattern increases significance
   - Weaker after sideways or choppy price action

2. **Doji Quality**
   - Smaller doji body indicates stronger indecision
   - Long shadows on doji show battle between buyers and sellers
   - Doji at resistance level increases pattern reliability

3. **Third Candle Penetration**
   - Deeper penetration into first candle = stronger reversal signal
   - Close below first candle's midpoint is particularly bearish
   - Higher volume on third candle confirms conviction

4. **Gap Sizes**
   - Larger gaps indicate more dramatic sentiment shift
   - Visible gaps on charts are more psychologically significant
   - Gap down on third candle especially important

### Context Considerations

- **Location**: Most effective at established resistance levels or after euphoric rallies
- **Volume**: Increasing volume on third candle confirms reversal strength
- **Market Condition**: Works best in trending markets, less reliable in ranging markets
- **Time Frame**: Higher time frames (daily, weekly) provide more reliable signals

## Trading Signals

### Sell Signals

Primary conditions for entering short positions or exiting longs:

1. **Pattern Confirmation**
   - All three candles meet Evening Doji Star criteria
   - Signal value = -100
   - Doji clearly gaps from both first and third candles

2. **Entry Criteria**
   - Exit longs on close of third candle or
   - Enter shorts after confirmation: break below third candle's low
   - More conservative: wait for next candle to close lower

3. **Additional Confirmation Factors**
   - Pattern forms at known resistance level
   - RSI or other oscillators show overbought conditions
   - Volume increases on third candle
   - Prior uptrend was extended and clear

**Example Scenario:**
```ruby
# After extended uptrend, pattern detected at resistance
if result.last == -100 &&
   rsi.last > 70 &&  # Overbought
   close.last < resistance_level &&  # Below resistance
   volume.last > volume[-2]  # Increasing volume

  entry_price = close.last
  stop_loss = high[-2] + (atr.last * 1.5)  # Above doji high
  target = entry_price - ((stop_loss - entry_price) * 2)  # 2:1 reward/risk

  puts "SELL Signal: Enter at #{entry_price}"
  puts "Stop Loss: #{stop_loss}"
  puts "Target: #{target}"
end
```

### Position Management

**Stop Loss Placement:**
- Conservative: Above the high of the doji (second candle)
- Aggressive: Above the high of the third candle
- ATR-based: 1.5-2x ATR above entry point

**Take Profit Targets:**
- First target: Recent support level or 1:1 reward/risk
- Second target: Next major support or 2:1 reward/risk
- Trailing stop: After first target hit, trail with 2x ATR

**Position Sizing:**
- Risk 1-2% of capital per trade
- Calculate position size based on stop loss distance
- Reduce size if pattern appears in choppy/ranging market

### Exit Signals for Short Positions

Conditions for closing short positions:

1. **Stop Loss Triggers**
   - Price closes above stop loss level
   - Subsequent bullish engulfing pattern forms
   - Break above doji's high with volume

2. **Take Profit Conditions**
   - Price reaches predetermined target levels
   - Strong support level reached
   - Bullish reversal pattern forms at support

3. **Pattern Failure Signs**
   - Fourth candle closes above third candle with high volume
   - Price fails to move lower after pattern
   - Bullish candlestick pattern forms immediately after

## Best Practices

### Optimal Use Cases

The Evening Doji Star works best in these conditions:

**Market Conditions:**
- Clear uptrend preceding the pattern (at least 5-10 bullish candles)
- Overbought conditions per momentum indicators
- Market approaching major resistance levels
- Low volatility on doji, increasing volatility on third candle

**Time Frames:**
- Daily charts: Most reliable and widely recognized
- Weekly charts: Stronger signals, fewer occurrences
- 4-hour charts: Good for swing trading
- Intraday (< 1 hour): Less reliable, more false signals

**Asset Classes:**
- Stocks: Highly effective, especially large-cap stocks
- Forex: Works well on major pairs with sufficient liquidity
- Commodities: Reliable on liquid contracts
- Cryptocurrencies: Can work but volatility creates false signals

### Combining with Other Indicators

Enhance reliability by confirming with complementary indicators:

**With Trend Indicators:**
- **Moving Averages**: Pattern near 200-day MA resistance increases reliability
- **MACD**: Bearish divergence or histogram turning negative confirms reversal
- **ADX**: Low ADX suggests trend change possible; pattern helps identify direction

**With Momentum Indicators:**
- **RSI**: Pattern + RSI > 70 = high probability reversal
- **Stochastic**: Overbought stochastic crossing down confirms pattern
- **CCI**: Emerging from overbought territory strengthens signal

**With Volume Indicators:**
- **Volume**: Third candle volume > average confirms conviction
- **OBV**: Falling OBV confirms distribution despite rising prices
- **Volume Profile**: Pattern at high volume resistance node more significant

**With Support/Resistance:**
- **Fibonacci Retracements**: Pattern at 38.2% or 50% retracement highly significant
- **Pivot Points**: Pattern at daily/weekly pivot resistance adds conviction
- **Horizontal Resistance**: Historical resistance level validates reversal potential

### Common Pitfalls

Avoid these mistakes when trading Evening Doji Star patterns:

1. **Ignoring Prior Trend**
   - Pattern requires established uptrend to be valid
   - Appearing in downtrend or sideways market reduces reliability
   - Always confirm preceding bullish trend over multiple periods

2. **Trading Without Confirmation**
   - Don't enter on second candle expecting doji
   - Wait for third candle completion
   - Consider waiting for fourth candle to confirm reversal

3. **Poor Risk Management**
   - Pattern can fail; always use stop losses
   - Don't risk more than 2% of capital on single trade
   - Account for gap risk, especially in volatile markets

4. **Neglecting Volume Analysis**
   - Low volume on third candle suggests weak conviction
   - Declining volume through pattern reduces reliability
   - Always check volume confirms price action

5. **Time Frame Mismatch**
   - Using pattern on 5-minute chart with daily trend analysis
   - Ensure time frame of pattern matches trading style
   - Higher time frames provide more reliable signals

6. **Over-optimization of Penetration Parameter**
   - Don't adjust penetration based on historical data mining
   - Stick to default 0.3 or adjust slightly based on asset volatility
   - Over-optimization leads to curve fitting and poor future performance

### Parameter Selection Guidelines

Choose optimal parameters based on trading style:

**Short-term Trading (Day Trading):**
- Use 5-15 minute charts cautiously
- Penetration: 0.4-0.5 (more strict) to reduce false signals
- Require additional confirmation (volume, momentum)
- Tighter stops due to noise in intraday data

**Medium-term Trading (Swing Trading):**
- Use 4-hour to daily charts (recommended)
- Penetration: 0.3 (default) works well
- Balance between sensitivity and reliability
- Hold positions for multiple days to weeks

**Long-term Trading (Position Trading):**
- Use daily to weekly charts
- Penetration: 0.2-0.3 (slightly looser) to catch all major reversals
- Fewer signals but higher reliability
- Combine with fundamental analysis

**Backtesting Guidelines:**
- Test default parameters first (penetration = 0.3)
- Vary penetration from 0.2 to 0.5 in 0.1 increments
- Evaluate win rate, profit factor, and drawdown
- Choose parameters that work across multiple assets
- Avoid parameters that work for only one specific period

## Practical Example

Complete trading scenario with context:

```ruby
require 'sqa/tai'

# Historical price data showing uptrend
open  = [40.0, 42.0, 44.0, 46.0, 48.0, 49.5, 50.0, 49.6, 47.5, 46.0, 45.0]
high  = [42.5, 44.5, 46.5, 48.5, 50.0, 50.2, 50.2, 49.8, 47.8, 46.5, 45.5]
low   = [40.0, 41.8, 43.8, 45.8, 47.8, 49.3, 49.8, 49.4, 45.5, 44.5, 44.0]
close = [42.0, 44.0, 46.0, 48.0, 49.5, 50.0, 49.6, 49.5, 46.0, 44.8, 44.5]

# Calculate pattern with default penetration
pattern = SQA::TAI.cdl_eveningdojistar(open, high, low, close)

# Calculate supporting indicators
rsi = SQA::TAI.rsi(close, time_period: 14)
sma_50 = SQA::TAI.sma(close, time_period: 50)

# Analyze most recent signal
current_signal = pattern.last
previous_signals = pattern[-4..-2]

if current_signal == -100
  puts "=" * 50
  puts "EVENING DOJI STAR PATTERN DETECTED"
  puts "=" * 50

  # Pattern details
  puts "\nPattern Structure:"
  puts "  First Candle (Bullish): Open #{open[-3]}, Close #{close[-3]}"
  puts "  Doji Candle: Open #{open[-2]}, Close #{close[-2]}"
  puts "  Third Candle (Bearish): Open #{open[-1]}, Close #{close[-1]}"

  # Calculate pattern metrics
  first_body = (close[-3] - open[-3]).abs
  doji_body = (open[-2] - close[-2]).abs
  third_body = (open[-1] - close[-1]).abs
  penetration_pct = (close[-3] - close[-1]) / first_body

  puts "\nPattern Metrics:"
  puts "  First candle body: #{first_body.round(2)}"
  puts "  Doji body: #{doji_body.round(2)}"
  puts "  Third candle body: #{third_body.round(2)}"
  puts "  Penetration: #{(penetration_pct * 100).round(1)}%"

  # Confirmation factors
  puts "\nConfirmation Analysis:"
  puts "  Current RSI: #{rsi.last.round(2)}"
  puts "  RSI Status: #{rsi.last > 70 ? 'OVERBOUGHT ✓' : 'Not overbought'}"
  puts "  50-day SMA: #{sma_50.last.round(2)}"
  puts "  Price vs SMA: #{close.last > sma_50.last ? 'Above (reversal setup) ✓' : 'Below'}"

  # Trend confirmation
  uptrend_confirmed = close[-6..-4].all? { |c| c < close[-3] }
  puts "  Prior uptrend: #{uptrend_confirmed ? 'Confirmed ✓' : 'Weak'}"

  # Trading decision
  puts "\nTrading Decision:"

  if rsi.last > 65 && close.last > sma_50.last && uptrend_confirmed
    # Calculate position parameters
    entry = close.last
    stop_loss = high[-2] * 1.02  # 2% above doji high
    risk_amount = stop_loss - entry
    target_1 = entry - (risk_amount * 1.5)  # 1.5:1 R/R
    target_2 = entry - (risk_amount * 3.0)  # 3:1 R/R

    puts "  STRONG SELL SIGNAL - Multiple confirmations"
    puts "\nTrade Setup:"
    puts "  Entry Price: $#{entry.round(2)}"
    puts "  Stop Loss: $#{stop_loss.round(2)} (Risk: $#{risk_amount.round(2)})"
    puts "  Target 1 (50% position): $#{target_1.round(2)}"
    puts "  Target 2 (50% position): $#{target_2.round(2)}"
    puts "  Risk/Reward: 1:1.5 and 1:3"

    # Position sizing example (for $10,000 account, 2% risk)
    account_size = 10000
    risk_per_trade = account_size * 0.02
    position_size = (risk_per_trade / risk_amount).to_i

    puts "\nPosition Sizing (2% risk on $#{account_size} account):"
    puts "  Shares to short: #{position_size}"
    puts "  Total position value: $#{(position_size * entry).round(2)}"
    puts "  Maximum risk: $#{risk_per_trade.round(2)}"

    puts "\nFor long holders:"
    puts "  Consider exiting or tightening stops"
    puts "  Pattern suggests trend reversal imminent"

  elsif rsi.last > 60
    puts "  MODERATE SELL SIGNAL - Consider smaller position"
    puts "  Suggestion: Wait for additional confirmation or enter with 50% position"

  else
    puts "  WEAK SIGNAL - Pattern present but confirmations lacking"
    puts "  Suggestion: Monitor for additional confirmation before entry"
  end

elsif pattern[-2] == -100
  puts "Pattern detected in previous period - Monitor position"
  puts "Current price: #{close.last}"
  puts "Entry was: #{close[-2]}"
  puts "Profit/Loss: #{((close[-2] - close.last) / close[-2] * 100).round(2)}%"

else
  # No pattern - continue monitoring
  if close.last > close[-1] && close[-1] > close[-2]
    puts "Uptrend continuing - Watch for Evening Doji Star formation"
    puts "Current price: #{close.last}"
    puts "RSI: #{rsi.last.round(2)}"
  end
end
```

## Related Indicators

### Similar Patterns

- **[Evening Star](cdl_eveningstar.md)**: Similar three-candle bearish reversal pattern but with a small real body instead of doji on second candle. Evening Doji Star is generally considered slightly more reliable due to the doji showing stronger indecision.

- **[Abandoned Baby](cdl_abandonedbaby.md)**: More rare and reliable version with gaps on both sides of the doji. Requires complete gap isolation of middle candle, making it stronger but less frequent.

- **[Dark Cloud Cover](cdl_darkcloudcover.md)**: Two-candle bearish reversal pattern. Simpler than Evening Doji Star but may provide earlier signals with potentially lower reliability.

### Complementary Patterns

- **[Bearish Engulfing](cdl_engulfing.md)**: Can follow Evening Doji Star to provide additional confirmation of reversal. The combination of both patterns significantly increases probability of successful reversal.

- **[Shooting Star](cdl_shootingstar.md)**: Single candle pattern that can appear as the third candle in Evening Doji Star. Recognizing shooting star characteristics strengthens the overall signal.

- **[Morning Doji Star](cdl_morningdojistar.md)**: The bullish counterpart to Evening Doji Star, appearing at bottoms. Understanding both patterns provides complete reversal recognition capability.

### Pattern Family

The Evening Doji Star belongs to the **Star Pattern Family**:

- **Evening Star**: Uses small real body instead of doji
- **Evening Doji Star**: Features doji for stronger indecision signal
- **Morning Star**: Bullish reversal at bottoms
- **Morning Doji Star**: Bullish reversal with doji

**Evolutionary Relationship:**
The Evening Doji Star is considered an evolution of the Evening Star pattern, with the doji providing a more specific indication of market indecision. Japanese candlestick analysis traditionally views the doji as a more significant reversal indicator than a small real body.

**When to prefer Evening Doji Star:**
- When seeking higher probability (though less frequent) reversal signals
- In markets where doji patterns have proven historically reliable
- When risk management requires high-confidence entry signals

**When to use Evening Star instead:**
- For more frequent trading opportunities
- In less liquid markets where true dojis rarely form
- When backtesting shows Evening Star provides better results for specific asset

## Advanced Topics

### Multi-Timeframe Analysis

Enhance pattern reliability using multiple timeframes:

**Primary Timeframe Strategy:**
1. Identify Evening Doji Star on daily chart (primary trading timeframe)
2. Confirm weekly chart shows uptrend and overbought conditions
3. Use 4-hour chart for precise entry timing after pattern completion
4. Monitor 1-hour chart for early exit signals if pattern fails

**Timeframe Confluence:**
- Pattern on daily + weekly chart = very high probability signal
- Pattern on daily, waiting for 4-hour confirmation = reduced risk entry
- Pattern on 4-hour aligned with daily resistance = good swing trade setup

**Example Multi-Timeframe Approach:**
```ruby
# Check daily for pattern
daily_pattern = SQA::TAI.cdl_eveningdojistar(daily_open, daily_high, daily_low, daily_close)

# Confirm weekly trend
weekly_sma = SQA::TAI.sma(weekly_close, time_period: 20)
weekly_uptrend = weekly_close.last > weekly_sma.last

# Entry on 4-hour confirmation
if daily_pattern.last == -100 && weekly_uptrend
  # Monitor 4-hour chart for entry trigger
  four_hour_pattern = SQA::TAI.cdl_eveningdojistar(h4_open, h4_high, h4_low, h4_close)
  # Enter when 4-hour also shows pattern or bearish confirmation
end
```

### Market Regime Adaptation

Pattern behavior varies by market condition:

**Trending Markets (ADX > 25):**
- Pattern most reliable after strong trends
- Higher success rate in established uptrends
- Use standard penetration (0.3) and standard confirmation

**Ranging Markets (ADX < 20):**
- Pattern less reliable, many false signals
- Increase penetration to 0.4-0.5 for stricter detection
- Require additional confirmation from oscillators
- Consider reducing position size

**High Volatility (ATR increasing):**
- Gaps more common, patterns form more frequently
- May need wider stops to avoid premature exit
- Pattern completion may span more time
- Confirm with volume to separate noise from signal

**Low Volatility (ATR decreasing):**
- True gaps less likely, doji may be weak
- Pattern may signal imminent volatility expansion
- Earlier entry can capture larger moves
- Tighter stops appropriate

### Statistical Validation

Understanding pattern reliability through statistical analysis:

**Historical Success Rates:**
- Academic studies show 60-65% success rate in trending markets
- Success rate drops to 45-50% in ranging markets
- Daily timeframe shows better results than intraday
- Confirmation with RSI > 70 increases success to 70-75%

**Backtesting Considerations:**
```ruby
# Example backtesting framework
def backtest_evening_doji_star(price_data, start_date, end_date)
  trades = []

  price_data.each_with_index do |data, i|
    next if i < 3  # Need at least 3 candles

    pattern = SQA::TAI.cdl_eveningdojistar(
      data[:open], data[:high], data[:low], data[:close]
    )

    if pattern[i] == -100
      entry = data[:close][i]
      stop = data[:high][i-1] * 1.02
      target = entry - ((stop - entry) * 2)

      # Track trade through subsequent data
      trades << {
        entry: entry,
        stop: stop,
        target: target,
        date: data[:date][i]
      }
    end
  end

  # Analyze results
  analyze_trades(trades)
end
```

**Key Metrics to Track:**
- Win rate (% of profitable trades)
- Average win vs average loss
- Profit factor (gross profit / gross loss)
- Maximum drawdown
- Sharpe ratio
- Pattern frequency vs opportunity cost

**Optimization Tips:**
- Test across multiple assets and market conditions
- Avoid over-fitting to specific time periods
- Include transaction costs in calculations
- Account for slippage, especially on gaps
- Consider different penetration parameters systematically

## References

- **"Japanese Candlestick Charting Techniques" by Steve Nison**: The definitive Western text on candlestick patterns, includes detailed coverage of Evening Doji Star pattern with historical context and trading applications.

- **"Technical Analysis of the Financial Markets" by John Murphy**: Comprehensive technical analysis reference with section on candlestick patterns and their integration with Western technical analysis.

- **"Encyclopedia of Candlestick Charts" by Thomas Bulkowski**: Statistical analysis of candlestick pattern performance, including success rates and failure rates for Evening Doji Star in various market conditions.

- **Original Japanese Candlestick Research**: Pattern originated in 18th century Japanese rice trading, documented in various historical texts on Sakata's Five Methods.

- **Online Resources**:
  - StockCharts.com Candlestick Pattern Reference
  - Investopedia Technical Analysis Guide
  - TradingView Pattern Recognition Tools

## See Also

- [Candlestick Patterns Overview](index.md)
- [Morning Doji Star - Bullish Counterpart](cdl_morningdojistar.md)
- [Evening Star - Similar Pattern](cdl_eveningstar.md)
- [Doji - Foundation Pattern](cdl_doji.md)
- [Pattern Recognition Strategy Guide](../index.md)
- [API Reference](../../api-reference.md)
