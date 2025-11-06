# SQA::TAI - Technical Analysis Indicators

Welcome to **SQA::TAI**, a Ruby wrapper around the legendary [TA-Lib](https://ta-lib.org/) C library, providing 200+ battle-tested technical analysis indicators.

## Overview

SQA::TAI is part of the [SQA (Simple Qualitative Analysis)](https://github.com/MadBomber/sqa) ecosystem, focusing on providing fast, reliable technical indicators for stock market analysis.

## Features

- **200+ Indicators** - Complete access to TA-Lib's comprehensive indicator library
- **Blazing Fast** - C library performance with Ruby convenience
- **Clean API** - Simple, intuitive interface with keyword arguments
- **Well Tested** - Extensive test coverage
- **Type Safe** - Parameter validation and error handling

## Quick Example

```ruby
require 'sqa/tai'

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

## Indicator Categories

### Overlap Studies
Moving averages and bands for trend analysis:

- [SMA](indicators/overlap/sma.md) - Simple Moving Average
- [EMA](indicators/overlap/ema.md) - Exponential Moving Average
- [BBANDS](indicators/overlap/bbands.md) - Bollinger Bands

### Momentum Indicators
Measure rate of price change:

- [RSI](indicators/momentum/rsi.md) - Relative Strength Index
- [MACD](indicators/momentum/macd.md) - Moving Average Convergence/Divergence
- [STOCH](indicators/momentum/stoch.md) - Stochastic Oscillator

### Volatility Indicators
Measure price volatility:

- [ATR](indicators/volatility/atr.md) - Average True Range
- [TRANGE](indicators/volatility/trange.md) - True Range

### Volume Indicators
Analyze trading volume:

- [OBV](indicators/volume/obv.md) - On Balance Volume
- [AD](indicators/volume/ad.md) - Chaikin A/D Line

### Pattern Recognition
Identify candlestick patterns:

- [Doji](indicators/patterns/doji.md)
- [Hammer](indicators/patterns/hammer.md)
- [Engulfing](indicators/patterns/engulfing.md)

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
