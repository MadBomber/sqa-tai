# Contributing to SQA::TAI

Thank you for your interest in contributing to SQA::TAI! This document provides guidelines for contributing to the project.

## Code of Conduct

We are committed to providing a welcoming and inspiring community for all. Please be respectful and constructive in all interactions.

## How to Contribute

### Reporting Bugs

If you find a bug, please create an issue on GitHub with:

- Clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Ruby version and gem version
- TA-Lib version
- Sample code if applicable

**Example Bug Report:**

```markdown
**Description:** RSI calculation returns nil values

**Steps to Reproduce:**
1. Install gem version X.X.X
2. Run: SQA::TAI.rsi([1,2,3,4,5], period: 14)
3. Observe nil values in output

**Expected:** Array with RSI values
**Actual:** Array with many nil values

**Environment:**
- Ruby: 3.2.0
- sqa-tai: 0.1.0
- TA-Lib: 0.4.0
```

### Suggesting Enhancements

Enhancement suggestions are welcome! Please create an issue with:

- Clear description of the enhancement
- Use case / motivation
- Proposed implementation (if any)
- Examples of how it would be used

### Pull Requests

We love pull requests! Here's the process:

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
4. **Add tests** (required for new features)
5. **Run the test suite**
   ```bash
   bundle exec rake test
   ```
6. **Update documentation** if needed
7. **Commit your changes**
   ```bash
   git commit -m "Add feature: your feature description"
   ```
8. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```
9. **Create a Pull Request** on GitHub

## Development Setup

### Prerequisites

1. **Install TA-Lib C library**

   **macOS:**
   ```bash
   brew install ta-lib
   ```

   **Ubuntu/Debian:**
   ```bash
   wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz
   tar -xzf ta-lib-0.4.0-src.tar.gz
   cd ta-lib/
   ./configure --prefix=/usr
   make
   sudo make install
   ```

2. **Clone the repository**
   ```bash
   git clone https://github.com/MadBomber/sqa-tai.git
   cd sqa-tai
   ```

3. **Install dependencies**
   ```bash
   bundle install
   ```

### Running Tests

Run the full test suite:
```bash
bundle exec rake test
```

Run a specific test file:
```bash
bundle exec ruby test/sqa/tai_test.rb
```

Run tests with coverage:
```bash
COVERAGE=true bundle exec rake test
```

### Code Style

We follow standard Ruby style guidelines:

- Use 2 spaces for indentation
- Keep lines under 120 characters
- Use descriptive variable names
- Add comments for complex logic
- Follow Ruby naming conventions

### Testing Guidelines

- Write tests for all new features
- Ensure existing tests pass
- Aim for high code coverage
- Use descriptive test names
- Test edge cases and error conditions

**Example Test:**

```ruby
require 'test_helper'

class TAITest < Minitest::Test
  def test_sma_calculates_correctly
    prices = [1, 2, 3, 4, 5]
    result = SQA::TAI.sma(prices, period: 3)

    assert_equal 5, result.length
    assert_nil result[0]
    assert_nil result[1]
    assert_in_delta 2.0, result[2], 0.001
    assert_in_delta 3.0, result[3], 0.001
    assert_in_delta 4.0, result[4], 0.001
  end

  def test_sma_handles_insufficient_data
    prices = [1, 2]
    result = SQA::TAI.sma(prices, period: 10)

    assert_equal 2, result.length
    assert result.all?(&:nil?)
  end
end
```

## Documentation

### Code Documentation

- Add YARD documentation comments to all public methods
- Include parameter types and return types
- Provide usage examples

**Example:**

```ruby
# Calculate Simple Moving Average
#
# @param prices [Array<Float>] Array of price values
# @param period [Integer] Number of periods for calculation
# @return [Array<Float, nil>] Array of SMA values (nil for warmup period)
#
# @example Calculate 10-period SMA
#   prices = [44.34, 44.09, 44.15, 43.61, 44.33]
#   sma = SQA::TAI.sma(prices, period: 5)
#   puts sma.last
def sma(prices, period: 30)
  # Implementation
end
```

### User Documentation

When adding features that affect users:

1. Update README.md if needed
2. Add examples to docs/examples/
3. Update indicator documentation in docs/indicators/
4. Add to CHANGELOG.md

### Documentation Style

- Use clear, simple language
- Include code examples
- Explain the "why" not just the "how"
- Link to related documentation

## Project Structure

```
sqa-tai/
├── lib/
│   └── sqa/
│       └── tai.rb            # Main library code
├── test/
│   └── sqa/
│       └── tai_test.rb       # Test files
├── docs/                     # MkDocs documentation
│   ├── index.md
│   ├── getting-started/
│   ├── indicators/
│   └── examples/
├── README.md
├── CHANGELOG.md
├── Gemfile
└── sqa-tai.gemspec
```

## Commit Message Guidelines

Write clear, descriptive commit messages:

- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- First line: brief summary (50 chars or less)
- Blank line
- Detailed description if needed

**Good examples:**
```
Add RSI divergence detection

Implement bullish and bearish RSI divergence detection.
Includes tests and documentation.
```

```
Fix: SMA calculation with insufficient data

Previously returned incorrect nil placement.
Now correctly handles edge cases.
```

## Release Process

(For maintainers)

1. Update version in `lib/sqa/tai/version.rb`
2. Update CHANGELOG.md
3. Commit changes
4. Create git tag: `git tag v0.1.0`
5. Push tag: `git push --tags`
6. Build gem: `gem build sqa-tai.gemspec`
7. Push to RubyGems: `gem push sqa-tai-0.1.0.gem`

## Getting Help

- **Documentation**: [https://madbomber.github.io/sqa-tai](https://madbomber.github.io/sqa-tai)
- **Issues**: [GitHub Issues](https://github.com/MadBomber/sqa-tai/issues)
- **Email**: dvanhoozer@gmail.com

## Recognition

Contributors will be acknowledged in:
- CHANGELOG.md
- GitHub contributors page
- Documentation (for significant contributions)

## License

By contributing to SQA::TAI, you agree that your contributions will be licensed under the MIT License.

## Questions?

Don't hesitate to ask questions by:
- Opening an issue
- Emailing the maintainer
- Starting a discussion on GitHub

We appreciate all contributions, whether it's:
- Reporting bugs
- Suggesting features
- Writing documentation
- Submitting code
- Helping other users

Thank you for making SQA::TAI better!
