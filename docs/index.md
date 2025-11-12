<div align="center">
  <h1>SQA::TAI - Technical Analysis Indicators</h1>

  <p>Ruby wrapper around the legendary <a href="https://ta-lib.org/">TA-Lib</a> C library, providing <strong>132 technical analysis indicators</strong> with a clean Ruby API.<br/>
      Part of the <a href="https://github.com/MadBomber/sqa">SQA</a> (Simple Qualitative Analysis) ecosystem.</p>
</div>

<table>
<tr>
<td width="30%" valign="middle" align="center">
  <img src="assets/images/sqa.jpg" alt="SQA - Simple Qualitative Analysis" width="80%">
</td>
<td width="70%" valign="top">

<h2>Features</h2>
📊 **132 Indicators** - Comprehensive coverage with 94% of trading-relevant TA-Lib indicators<br/>
⚡ **Blazing Fast** - C library performance with Ruby convenience<br/>
🎯 **Clean API** - Simple, intuitive interface with keyword arguments<br/>
✅ **Well Tested** - 73 tests, 332 assertions, comprehensive coverage<br/>
🔒 **Type Safe** - Parameter validation and error handling<br/>
🐛 **Bug Fixed** - Includes monkey patch for ta_lib_ffi 0.3.0 multi-array parameter bug<br/>

</td>
</tr>
</table>

## Quick Example

```ruby
require 'sqa/tai'

# NOTE: All arrays passed to the TA-Lib functions
#       are in ascending order oldest data to newest

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08]

# Calculate indicators
sma = SQA::TAI.sma(prices, period: 5)
rsi = SQA::TAI.rsi(prices, period: 14)
upper, middle, lower = SQA::TAI.bbands(prices, period: 20)

puts "SMA: #{sma.last}"
puts "RSI: #{rsi.last}"
```

## Installation

First, install the TA-Lib C library:

=== "macOS"
    ```bash
    brew install ta-lib
    ```

=== "Ubuntu/Debian"
    ```bash
    wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz
    tar -xzf ta-lib-0.4.0-src.tar.gz
    cd ta-lib/
    ./configure --prefix=/usr
    make
    sudo make install
    ```

=== "Windows"
    Download from [ta-lib.org](https://ta-lib.org/hdr_dw.html)

Then install the gem:

```bash
gem install sqa-tai
```

## Indicator Categories (132 Total)

### Overlap Studies (15)
Moving averages and bands for trend analysis:

- [SMA](indicators/overlap/sma.md) - Simple Moving Average
- [EMA](indicators/overlap/ema.md) - Exponential Moving Average
- [WMA](indicators/overlap/wma.md) - Weighted Moving Average
- [DEMA](indicators/overlap/dema.md) - Double Exponential Moving Average
- [TEMA](indicators/overlap/tema.md) - Triple Exponential Moving Average
- [TRIMA](indicators/overlap/trima.md) - Triangular Moving Average
- [KAMA](indicators/overlap/kama.md) - Kaufman Adaptive Moving Average
- [T3](indicators/overlap/t3.md) - Triple Exponential Moving Average (T3)
- [BBANDS](indicators/overlap/bbands.md) - Bollinger Bands
- [SAREXT](indicators/volatility/sarext.md) - Parabolic SAR Extended
- [HT_TRENDLINE](indicators/volatility/ht_trendline.md) - Hilbert Transform Instantaneous Trendline
- [MAMA](indicators/volatility/mama.md) - MESA Adaptive Moving Average
- [MAVP](indicators/volatility/mavp.md) - Moving Average with Variable Period
- [MIDPOINT](indicators/volatility/midpoint.md) - Midpoint over period
- [MIDPRICE](indicators/volatility/midprice.md) - Midpoint Price over period

### Momentum Indicators (30)
Measure rate of price change:

- [RSI](indicators/momentum/rsi.md) - Relative Strength Index
- [MACD](indicators/momentum/macd.md) - Moving Average Convergence/Divergence
- [STOCH](indicators/momentum/stoch.md) - Stochastic Oscillator
- [MOM](indicators/momentum/mom.md) - Momentum
- [CCI](indicators/momentum/cci.md) - Commodity Channel Index
- [WILLR](indicators/momentum/willr.md) - Williams' %R
- [ROC](indicators/momentum/roc.md) - Rate of Change
- [ROCP](indicators/momentum/rocp.md) - Rate of Change Percentage
- [ROCR](indicators/momentum/rocr.md) - Rate of Change Ratio
- [PPO](indicators/momentum/ppo.md) - Percentage Price Oscillator
- [ADX](indicators/momentum/adx.md) - Average Directional Index
- [ADXR](indicators/momentum/adxr.md) - Average Directional Movement Index Rating
- [APO](indicators/momentum/apo.md) - Absolute Price Oscillator
- [AROON](indicators/momentum/aroon.md) - Aroon Indicator
- [AROONOSC](indicators/momentum/aroonosc.md) - Aroon Oscillator
- [BOP](indicators/momentum/bop.md) - Balance of Power
- [CMO](indicators/momentum/cmo.md) - Chande Momentum Oscillator
- [DX](indicators/momentum/dx.md) - Directional Movement Index
- [MACDEXT](indicators/momentum/macdext.md) - MACD with Controllable MA Type
- [MACDFIX](indicators/momentum/macdfix.md) - MACD Fix 12/26
- [MFI](indicators/momentum/mfi.md) - Money Flow Index
- [MINUS_DI](indicators/momentum/minus_di.md) - Minus Directional Indicator
- [MINUS_DM](indicators/momentum/minus_dm.md) - Minus Directional Movement
- [PLUS_DI](indicators/momentum/plus_di.md) - Plus Directional Indicator
- [PLUS_DM](indicators/momentum/plus_dm.md) - Plus Directional Movement
- [ROCR100](indicators/momentum/rocr100.md) - Rate of Change Ratio 100 scale
- [STOCHF](indicators/momentum/stochf.md) - Stochastic Fast
- [STOCHRSI](indicators/momentum/stochrsi.md) - Stochastic RSI
- [TRIX](indicators/momentum/trix.md) - 1-day ROC of Triple Smooth EMA
- [ULTOSC](indicators/momentum/ultosc.md) - Ultimate Oscillator

### Volatility Indicators (4)
Measure price volatility:

- [ATR](indicators/volatility/atr.md) - Average True Range
- [NATR](indicators/volatility/natr.md) - Normalized Average True Range
- [TRANGE](indicators/volatility/trange.md) - True Range
- [SAR](indicators/volatility/sar.md) - Parabolic SAR

### Volume Indicators (3)
Analyze trading volume:

- [OBV](indicators/volume/obv.md) - On Balance Volume
- [AD](indicators/volume/ad.md) - Chaikin A/D Line
- [ADOSC](indicators/volume/adosc.md) - Chaikin A/D Oscillator

### Price Transform (4)
Price averaging and transformation:

- [AVGPRICE](indicators/price_transform/avgprice.md) - Average Price
- [MEDPRICE](indicators/price_transform/medprice.md) - Median Price
- [TYPPRICE](indicators/price_transform/typprice.md) - Typical Price
- [WCLPRICE](indicators/price_transform/wclprice.md) - Weighted Close Price

### Cycle Indicators (5)
Identify market cycles:

- [HT_DCPERIOD](indicators/cycle/ht_dcperiod.md) - Hilbert Transform - Dominant Cycle Period
- [HT_TRENDMODE](indicators/cycle/ht_trendmode.md) - Hilbert Transform - Trend vs Cycle Mode
- [HT_DCPHASE](indicators/cycle/ht_dcphase.md) - Hilbert Transform - Dominant Cycle Phase
- [HT_PHASOR](indicators/cycle/ht_phasor.md) - Hilbert Transform - Phasor Components
- [HT_SINE](indicators/cycle/ht_sine.md) - Hilbert Transform - SineWave

### Statistical Functions (9)
Statistical analysis and regression:

- [CORREL](indicators/statistical/correl.md) - Pearson's Correlation Coefficient
- [BETA](indicators/statistical/beta.md) - Beta Coefficient
- [VAR](indicators/statistical/var.md) - Variance
- [STDDEV](indicators/statistical/stddev.md) - Standard Deviation
- [LINEARREG](indicators/statistical/linearreg.md) - Linear Regression
- [LINEARREG_ANGLE](indicators/statistical/linearreg_angle.md) - Linear Regression Angle
- [LINEARREG_INTERCEPT](indicators/statistical/linearreg_intercept.md) - Linear Regression Intercept
- [LINEARREG_SLOPE](indicators/statistical/linearreg_slope.md) - Linear Regression Slope
- [TSF](indicators/statistical/tsf.md) - Time Series Forecast

### Pattern Recognition (61)
Identify candlestick patterns:

- [Doji](indicators/patterns/cdl_doji.md) - Doji Pattern
- [Hammer](indicators/patterns/cdl_hammer.md) - Hammer Pattern
- [Engulfing](indicators/patterns/cdl_engulfing.md) - Engulfing Pattern
- [Morning Star](indicators/patterns/cdl_morningstar.md) - Morning Star Pattern
- [Evening Star](indicators/patterns/cdl_eveningstar.md) - Evening Star Pattern
- [Harami](indicators/patterns/cdl_harami.md) - Harami Pattern
- [Piercing](indicators/patterns/cdl_piercing.md) - Piercing Pattern
- [Shooting Star](indicators/patterns/cdl_shootingstar.md) - Shooting Star Pattern
- [Marubozu](indicators/patterns/cdl_marubozu.md) - Marubozu Pattern
- [Spinning Top](indicators/patterns/cdl_spinningtop.md) - Spinning Top Pattern
- [Dragonfly Doji](indicators/patterns/cdl_dragonflydoji.md) - Dragonfly Doji Pattern
- [Gravestone Doji](indicators/patterns/cdl_gravestonedoji.md) - Gravestone Doji Pattern
- [Two Crows](indicators/patterns/cdl_2crows.md) - Two Crows Pattern
- [Three Black Crows](indicators/patterns/cdl_3blackcrows.md) - Three Black Crows Pattern
- [Three Inside](indicators/patterns/cdl_3inside.md) - Three Inside Up/Down Pattern
- [Three Line Strike](indicators/patterns/cdl_3linestrike.md) - Three Line Strike Pattern
- [Three Outside](indicators/patterns/cdl_3outside.md) - Three Outside Up/Down Pattern
- [Three White Soldiers](indicators/patterns/cdl_3whitesoldiers.md) - Three Advancing White Soldiers
- [Dark Cloud Cover](indicators/patterns/cdl_darkcloudcover.md) - Dark Cloud Cover Pattern
- [Abandoned Baby](indicators/patterns/cdl_abandonedbaby.md) - Abandoned Baby Pattern
- [Hanging Man](indicators/patterns/cdl_hangingman.md) - Hanging Man Pattern
- [Inverted Hammer](indicators/patterns/cdl_invertedhammer.md) - Inverted Hammer Pattern
- [Kicking](indicators/patterns/cdl_kicking.md) - Kicking Pattern
- [Morning Doji Star](indicators/patterns/cdl_morningdojistar.md) - Morning Doji Star Pattern
- [Evening Doji Star](indicators/patterns/cdl_eveningdojistar.md) - Evening Doji Star Pattern
- [High Wave](indicators/patterns/cdl_highwave.md) - High-Wave Candle Pattern
- [Hikkake](indicators/patterns/cdl_hikkake.md) - Hikkake Pattern
- [Rickshaw Man](indicators/patterns/cdl_rickshawman.md) - Rickshaw Man Pattern
- [Takuri](indicators/patterns/cdl_takuri.md) - Takuri (Dragonfly Doji with very long lower shadow)
- [Tristar](indicators/patterns/cdl_tristar.md) - Tristar Pattern
- [Three Stars In The South](indicators/patterns/cdl_3starsinsouth.md) - Three Stars In The South Pattern
- [Advance Block](indicators/patterns/cdl_advanceblock.md) - Advance Block Pattern
- [Belt-hold](indicators/patterns/cdl_belthold.md) - Belt-hold Pattern
- [Breakaway](indicators/patterns/cdl_breakaway.md) - Breakaway Pattern
- [Closing Marubozu](indicators/patterns/cdl_closingmarubozu.md) - Closing Marubozu Pattern
- [Concealing Baby Swallow](indicators/patterns/cdl_concealbabyswall.md) - Concealing Baby Swallow Pattern
- [Counterattack](indicators/patterns/cdl_counterattack.md) - Counterattack Pattern
- [Doji Star](indicators/patterns/cdl_dojistar.md) - Doji Star Pattern
- [Gap Side-by-Side White](indicators/patterns/cdl_gapsidesidewhite.md) - Gap Side-by-Side White Pattern
- [Harami Cross](indicators/patterns/cdl_haramicross.md) - Harami Cross Pattern
- [Modified Hikkake](indicators/patterns/cdl_hikkakemod.md) - Modified Hikkake Pattern
- [Homing Pigeon](indicators/patterns/cdl_homingpigeon.md) - Homing Pigeon Pattern
- [Identical Three Crows](indicators/patterns/cdl_identical3crows.md) - Identical Three Crows Pattern
- [In-Neck](indicators/patterns/cdl_inneck.md) - In-Neck Pattern
- [Kicking by Length](indicators/patterns/cdl_kickingbylength.md) - Kicking by Length Pattern
- [Ladder Bottom](indicators/patterns/cdl_ladderbottom.md) - Ladder Bottom Pattern
- [Long Legged Doji](indicators/patterns/cdl_longleggeddoji.md) - Long Legged Doji Pattern
- [Long Line](indicators/patterns/cdl_longline.md) - Long Line Candle Pattern
- [Matching Low](indicators/patterns/cdl_matchinglow.md) - Matching Low Pattern
- [Mat Hold](indicators/patterns/cdl_mathold.md) - Mat Hold Pattern
- [On-Neck](indicators/patterns/cdl_onneck.md) - On-Neck Pattern
- [Rising/Falling Three Methods](indicators/patterns/cdl_risefall3methods.md) - Rising/Falling Three Methods Pattern
- [Separating Lines](indicators/patterns/cdl_separatinglines.md) - Separating Lines Pattern
- [Short Line](indicators/patterns/cdl_shortline.md) - Short Line Candle Pattern
- [Stalled Pattern](indicators/patterns/cdl_stalledpattern.md) - Stalled Pattern
- [Stick Sandwich](indicators/patterns/cdl_sticksandwich.md) - Stick Sandwich Pattern
- [Tasuki Gap](indicators/patterns/cdl_tasukigap.md) - Tasuki Gap Pattern
- [Thrusting](indicators/patterns/cdl_thrusting.md) - Thrusting Pattern
- [Unique 3 River](indicators/patterns/cdl_unique3river.md) - Unique 3 River Pattern
- [Upside Gap Two Crows](indicators/patterns/cdl_upsidegap2crows.md) - Upside Gap Two Crows Pattern
- [Upside/Downside Gap Three Methods](indicators/patterns/cdl_xsidegap3methods.md) - Upside/Downside Gap Three Methods Pattern

## SQA Ecosystem

SQA::TAI is part of a larger ecosystem:

- **[sqa](https://github.com/MadBomber/sqa)** - Trading strategy framework
- **[sqa-tai](https://github.com/MadBomber/sqa-tai)** - Technical indicators (this gem)
- **[sqa-cli](https://github.com/MadBomber/sqa-cli)** - CLI tool with AI integration

## Next Steps

- [Installation Guide](getting-started/installation.md)
- [Quick Start Tutorial](getting-started/quick-start.md)
- [API Reference](api-reference.md)
- [Examples](examples/trend-analysis.md)

## Support

- **GitHub**: [Issues](https://github.com/MadBomber/sqa-tai/issues)
- **Email**: dvanhoozer@gmail.com

## License

MIT License - see [LICENSE](https://github.com/MadBomber/sqa-tai/blob/main/LICENSE) for details.
