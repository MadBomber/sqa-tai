# SQA::TALib - Technical Analysis Indicators

[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.1.0-ruby.svg)](https://www.ruby-lang.org/)
[![Gem Version](https://badge.fury.io/rb/sqa-talib.svg)](https://badge.fury.io/rb/sqa-talib)
[![Documentation](https://img.shields.io/badge/docs-mkdocs-blue.svg)](https://madbomber.github.io/sqa-talib)

Ruby wrapper around [TA-Lib](https://ta-lib.org/) providing 200+ battle-tested technical analysis indicators for stock market analysis. Part of the [SQA](https://github.com/MadBomber/sqa) (Stock Qualitative Analysis) ecosystem.

## Features

- 🚀 **200+ Indicators** - Access to all TA-Lib indicators
- ⚡ **Blazing Fast** - C library performance with Ruby convenience
- 🎯 **Clean API** - Simple, intuitive Ruby interface
- 📊 **Comprehensive** - Overlap studies, momentum, volatility, volume, patterns
- ✅ **Well Tested** - Extensive test coverage
- 📚 **Documented** - Full documentation at [madbomber.github.io/sqa-talib](https://madbomber.github.io/sqa-talib)

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
gem 'sqa-talib'
```

Or install directly:
```bash
gem install sqa-talib
```

## Quick Start

```ruby
require 'sqa/talib'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83, 45.10, 45.42, 45.84, 46.08]

# Moving Averages
sma = SQA::TALib.sma(prices, period: 5)
ema = SQA::TALib.ema(prices, period: 5)

# Momentum Indicators
rsi = SQA::TALib.rsi(prices, period: 14)
macd, signal, histogram = SQA::TALib.macd(prices)

# Volatility
upper, middle, lower = SQA::TALib.bbands(prices, period: 20)

# Check if TA-Lib is available
if SQA::TALib.available?
  puts "TA-Lib is ready!"
end
```

## Available Indicators

### Overlap Studies (Moving Averages, Bands)
- **SMA** - Simple Moving Average
- **EMA** - Exponential Moving Average
- **WMA** - Weighted Moving Average
- **BBANDS** - Bollinger Bands
- And many more...

### Momentum Indicators
- **RSI** - Relative Strength Index
- **MACD** - Moving Average Convergence/Divergence
- **STOCH** - Stochastic Oscillator
- **MOM** - Momentum
- And many more...

### Volatility Indicators
- **ATR** - Average True Range
- **TRANGE** - True Range
- **NATR** - Normalized Average True Range
- And many more...

### Volume Indicators
- **OBV** - On Balance Volume
- **AD** - Chaikin A/D Line
- **ADOSC** - Chaikin A/D Oscillator
- And many more...

### Pattern Recognition
- **CDL_DOJI** - Doji
- **CDL_HAMMER** - Hammer
- **CDL_ENGULFING** - Engulfing Pattern
- And 60+ more candlestick patterns...

See [full indicator list](https://madbomber.github.io/sqa-talib/indicators/) in documentation.

## Usage Examples

### Trend Analysis
```ruby
require 'sqa/talib'

# Golden Cross detection
prices = load_stock_prices('AAPL')
sma_50 = SQA::TALib.sma(prices, period: 50)
sma_200 = SQA::TALib.sma(prices, period: 200)

if sma_50.last > sma_200.last
  puts "Golden Cross - Bullish signal!"
end
```

### Momentum Analysis
```ruby
# RSI Overbought/Oversold
prices = load_stock_prices('TSLA')
rsi = SQA::TALib.rsi(prices, period: 14)

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
upper, middle, lower = SQA::TALib.bbands(prices, period: 20, nbdev_up: 2.0, nbdev_down: 2.0)

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

doji = SQA::TALib.cdl_doji(open, high, low, close)
hammer = SQA::TALib.cdl_hammer(open, high, low, close)

puts "Doji detected!" if doji.last != 0
puts "Hammer detected!" if hammer.last != 0
```

## Error Handling

```ruby
begin
  result = SQA::TALib.sma(prices, period: 30)
rescue SQA::TALib::TALibNotInstalledError => e
  puts "Please install TA-Lib: #{e.message}"
rescue SQA::TALib::InvalidParameterError => e
  puts "Invalid parameters: #{e.message}"
end
```

## SQA Ecosystem

`sqa-talib` is part of the SQA project:

- **[sqa](https://github.com/MadBomber/sqa)** - Trading strategy framework
- **[sqa-talib](https://github.com/MadBomber/sqa-talib)** - Technical indicators (this gem)
- **[sqa-cli](https://github.com/MadBomber/sqa-cli)** - Command-line tool with AI integration

## Documentation

Full documentation available at:
- **Online**: [madbomber.github.io/sqa-talib](https://madbomber.github.io/sqa-talib)
- **API Reference**: Detailed method documentation
- **Tutorials**: Getting started guides
- **Examples**: Real-world usage examples

## Development

```bash
git clone https://github.com/MadBomber/sqa-talib.git
cd sqa-talib
bundle install
bundle exec rake test
```

## Testing

```bash
# Run all tests
bundle exec rake test

# Run specific test
bundle exec ruby test/sqa/talib_test.rb
```

## Contributing

Bug reports and pull requests are welcome at https://github.com/MadBomber/sqa-talib.

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

- 📧 Email: dvanhoozer@gmail.com
- 🐛 Issues: [GitHub Issues](https://github.com/MadBomber/sqa-talib/issues)
- 📚 Docs: [Documentation Site](https://madbomber.github.io/sqa-talib)

## Disclaimer

**DO NOT USE** this library for real money trading without thorough testing and professional advice.
This is an educational tool. Trading stocks involves risk of loss.
