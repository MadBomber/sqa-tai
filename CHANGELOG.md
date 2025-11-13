# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
