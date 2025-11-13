# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Help system for accessing indicator documentation (`SQA::TAI.help`)
  - Returns URLs to online documentation for any indicator
  - Supports searching by name, filtering by category, and listing all indicators
  - Auto-generated from mkdocs documentation files via `rake help:generate`
  - Flexible API returns HelpResource objects with URL, name, and category
  - Optional browser integration to open documentation directly
  - Zeitwerk-compatible file structure with `help.rb` and `help_resource.rb`

## [0.1.1] 2025-11-13
### Added
- Intraday Momentum Index (IMI) indicator
- GitHub Actions workflow to automatically deploy documentation to GitHub Pages
- Indicator template markdown file for documentation
- Chronological ordering note to indicator documentation

### Fixed
- Hash return format handling from newer ta_lib_ffi versions
- Image alignment and naming in README
- API reference documentation formatting and index links

### Changed
- Refactored library code into modular structure with 8 focused modules organized by indicator category
  - `lib/sqa/tai/overlap_studies.rb` - Moving averages and bands
  - `lib/sqa/tai/momentum_indicators.rb` - Momentum and oscillator indicators
  - `lib/sqa/tai/volatility_indicators.rb` - Volatility and range indicators
  - `lib/sqa/tai/volume_indicators.rb` - Volume-based indicators
  - `lib/sqa/tai/price_transform.rb` - Price transformation functions
  - `lib/sqa/tai/cycle_indicators.rb` - Hilbert Transform cycle indicators
  - `lib/sqa/tai/statistical_functions.rb` - Statistical analysis functions
  - `lib/sqa/tai/pattern_recognition.rb` - Candlestick pattern recognition
- Refactored test suite to mirror lib directory organization with 8 modular test files
- Reduced main `lib/sqa/tai.rb` from 1,851 lines to 67 lines (96% reduction)
- Reduced main `test/sqa/tai_test.rb` to core tests only, extracted 72 tests into category-specific files
- Updated indicator count to 132
- Reorganized README sections
- Improved SQA name from "Stock Qualitative Analysis" to "Simple Qualitative Analysis"
- Updated gemspec description

## [0.1.0] - 2025-11-06

### Added
- Initial release of sqa-tai
- Ruby wrapper around ta_lib_ffi
- 200+ technical analysis indicators from TA-Lib
- Overlap studies: SMA, EMA, WMA, BBANDS
- Momentum indicators: RSI, MACD, STOCH, MOM
- Volatility indicators: ATR, TRANGE
- Volume indicators: OBV, AD
- Pattern recognition: Doji, Hammer, Engulfing
- Clean Ruby API with keyword arguments
- Comprehensive error handling
- Parameter validation
- Full test coverage
- Complete documentation site

### Notes
- Extracted from original [sqa](https://github.com/MadBomber/sqa) gem
- Part of SQA ecosystem refactoring
- Requires TA-Lib C library >= 0.4.0
- Requires Ruby >= 3.1.0

[Unreleased]: https://github.com/MadBomber/sqa-tai/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/MadBomber/sqa-tai/releases/tag/v0.1.0
