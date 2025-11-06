<div align="center">
  <h1>SQA::TAI - Technical Analysis Indicators</h1>

  <p>Ruby wrapper around [TA-Lib](https://ta-lib.org/) providing **136 technical analysis indicators** for stock market analysis.<br/>
      Part of the [SQA](https://github.com/MadBomber/sqa) (Simple Qualitative Analysis) ecosystem.</p>
</div>

<table>
<tr>
<td width="30%" valign="middle" align="center">
  <img src="docs/assets/images/sqa-tai.jpg" alt="Ruby Turns Information into Knowledge" width="80%">
  <br/>
</td>
<td width="70%" valign="top">

## Features

- 🚀 **136 Indicators** - Comprehensive coverage with 94% of trading-relevant TA-Lib indicators
- ⚡ **Blazing Fast** - C library performance with Ruby convenience
- 🎯 **Clean API** - Simple, intuitive Ruby interface with keyword arguments
- 📊 **Comprehensive** - Overlap studies, momentum, volatility, volume, cycles, stats, patterns
- 🔌 **Easy Integration** - Works seamlessly with existing Ruby trading tools
- ✅ **Well Tested** - 73 tests, 332 assertions, 100% passing
- 📚 **Documented** - Full documentation at [madbomber.github.io/sqa-tai](https://madbomber.github.io/sqa-tai)
- 🔧 **Bug Fixed** - Includes monkey patch for ta_lib_ffi 0.3.0 multi-array parameter bug

</td>
</tr>
</table>

## Prerequisites

**TA-Lib C library must be installed** before using this gem.

### macOS
```bash
brew install ta-lib
```

### Ubuntu/Debian
```bash
wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz
tar -xzf ta-lib-0.4.0-src.tar.gz
cd ta-lib/
./configure --prefix=/usr
make
sudo make install
```

### Windows
Download and install from [ta-lib.org](https://ta-lib.org/hdr_dw.html)

## Installation

Add to your Gemfile:
```ruby
gem 'sqa-tai'
```

Or install directly:
```bash
gem install sqa-tai
```

## Quick Start

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83, 45.10, 45.42, 45.84, 46.08]

# Moving Averages
sma = SQA::TAI.sma(prices, period: 5)
ema = SQA::TAI.ema(prices, period: 5)

# Momentum Indicators
rsi = SQA::TAI.rsi(prices, period: 14)
macd, signal, histogram = SQA::TAI.macd(prices)

# Volatility
upper, middle, lower = SQA::TAI.bbands(prices, period: 20)

# Check if TA-Lib is available
if SQA::TAI.available?
  puts "TA-Lib is ready!"
end
```

## Available Indicators (136 Total)

### Overlap Studies (15)
- **SMA, EMA, WMA** - Moving Averages
- **DEMA, TEMA, TRIMA** - Advanced Moving Averages
- **KAMA, T3, MAMA** - Adaptive Moving Averages
- **BBANDS** - Bollinger Bands
- **SAREXT, HT_TRENDLINE** - Trend indicators
- **MIDPOINT, MIDPRICE, MAVP** - Price calculations

### Momentum Indicators (30)
- **RSI** - Relative Strength Index
- **MACD, MACDEXT, MACDFIX** - MACD variants
- **STOCH, STOCHF, STOCHRSI** - Stochastic variants
- **MOM** - Momentum
- **CCI** - Commodity Channel Index
- **WILLR** - Williams' %R
- **ROC, ROCP, ROCR, ROCR100** - Rate of Change variants
- **PPO, APO** - Price Oscillators
- **ADX, ADXR, DX** - Directional Movement
- **AROON, AROONOSC** - Aroon indicators
- **BOP** - Balance of Power
- **CMO** - Chande Momentum Oscillator
- **MFI** - Money Flow Index
- **PLUS_DI, MINUS_DI, PLUS_DM, MINUS_DM** - Directional indicators
- **TRIX** - Triple Smooth EMA
- **ULTOSC** - Ultimate Oscillator

### Volatility Indicators (4)
- **ATR** - Average True Range
- **NATR** - Normalized Average True Range
- **TRANGE** - True Range
- **SAR** - Parabolic SAR

### Volume Indicators (3)
- **OBV** - On Balance Volume
- **AD** - Chaikin A/D Line
- **ADOSC** - Chaikin A/D Oscillator

### Price Transform (4)
- **AVGPRICE** - Average Price
- **MEDPRICE** - Median Price
- **TYPPRICE** - Typical Price
- **WCLPRICE** - Weighted Close Price

### Cycle Indicators (5)
- **HT_DCPERIOD** - Hilbert Transform - Dominant Cycle Period
- **HT_TRENDMODE** - Hilbert Transform - Trend vs Cycle Mode
- **HT_DCPHASE** - Hilbert Transform - Dominant Cycle Phase
- **HT_PHASOR** - Hilbert Transform - Phasor Components
- **HT_SINE** - Hilbert Transform - SineWave

### Statistical Functions (9)
- **CORREL** - Pearson's Correlation Coefficient
- **BETA** - Beta Coefficient
- **VAR** - Variance
- **STDDEV** - Standard Deviation
- **LINEARREG** - Linear Regression
- **LINEARREG_ANGLE, LINEARREG_INTERCEPT, LINEARREG_SLOPE** - Linear Regression components
- **TSF** - Time Series Forecast

### Pattern Recognition (61)
- **Basic Patterns**: Doji, Hammer, Engulfing, Hanging Man, Shooting Star
- **Star Patterns**: Morning Star, Evening Star, Morning Doji Star, Evening Doji Star
- **Reversal Patterns**: Harami, Piercing, Dark Cloud Cover, Inverted Hammer
- **Continuation Patterns**: Three White Soldiers, Three Black Crows, Rising/Falling Three Methods
- **Complex Patterns**: Abandoned Baby, Kicking, Unique 3 River, Tristar
- And 40+ more candlestick patterns...

See [full indicator list](https://madbomber.github.io/sqa-tai/indicators/) in documentation.

## Usage Examples

### Trend Analysis
```ruby
require 'sqa/tai'

# Golden Cross detection
prices = load_stock_prices('AAPL')
sma_50 = SQA::TAI.sma(prices, period: 50)
sma_200 = SQA::TAI.sma(prices, period: 200)

if sma_50.last > sma_200.last
  puts "Golden Cross - Bullish signal!"
end
```

### Momentum Analysis
```ruby
# RSI Overbought/Oversold
prices = load_stock_prices('TSLA')
rsi = SQA::TAI.rsi(prices, period: 14)

case rsi.last
when 0...30
  puts "Oversold - Potential buy"
when 70..100
  puts "Overbought - Potential sell"
else
  puts "Neutral"
end
```

### Volatility Analysis
```ruby
# Bollinger Bands
prices = load_stock_prices('MSFT')
upper, middle, lower = SQA::TAI.bbands(prices, period: 20, nbdev_up: 2.0, nbdev_down: 2.0)

current_price = prices.last
if current_price > upper.last
  puts "Price above upper band - overbought"
elsif current_price < lower.last
  puts "Price below lower band - oversold"
end
```

### Pattern Recognition
```ruby
# Candlestick patterns
open   = [100, 102, 101, 99, 98]
high   = [103, 105, 104, 102, 101]
low    = [99, 101, 100, 97, 96]
close  = [102, 103, 100, 98, 99]

doji = SQA::TAI.cdl_doji(open, high, low, close)
hammer = SQA::TAI.cdl_hammer(open, high, low, close)

puts "Doji detected!" if doji.last != 0
puts "Hammer detected!" if hammer.last != 0
```

## Error Handling

```ruby
begin
  result = SQA::TAI.sma(prices, period: 30)
rescue SQA::TAI::TAINotInstalledError => e
  puts "Please install TA-Lib: #{e.message}"
rescue SQA::TAI::InvalidParameterError => e
  puts "Invalid parameters: #{e.message}"
end
```

## SQA Ecosystem

`sqa-tai` is part of the SQA project:

- **[sqa](https://github.com/MadBomber/sqa)** - Trading strategy framework
- **[sqa-tai](https://github.com/MadBomber/sqa-tai)** - Technical indicators (this gem)
- **[sqa-cli](https://github.com/MadBomber/sqa-cli)** - Command-line tool with AI integration

## Documentation

Full documentation available at:
- **Online**: [madbomber.github.io/sqa-tai](https://madbomber.github.io/sqa-tai)
- **API Reference**: Detailed method documentation
- **Tutorials**: Getting started guides
- **Examples**: Real-world usage examples

## Development

```bash
git clone https://github.com/MadBomber/sqa-tai.git
cd sqa-tai
bundle install
bundle exec rake test
```

## Testing

```bash
# Run all tests
bundle exec rake test

# Run specific test
bundle exec ruby test/sqa/tai_test.rb
```

## Contributing

Bug reports and pull requests are welcome at https://github.com/MadBomber/sqa-tai.

1. Fork it
2. Create your feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Create new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).

## Acknowledgments

- [TA-Lib](https://ta-lib.org/) - The underlying C library
- [ta_lib_ffi](https://github.com/TA-Lib/ta-lib-ruby) - Ruby FFI wrapper

## Support

- 🐛 Issues: [GitHub Issues](https://github.com/MadBomber/sqa-tai/issues)
- 📚 Docs: [Documentation Site](https://madbomber.github.io/sqa-tai)
