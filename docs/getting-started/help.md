# Help System

The SQA::TAI help system provides programmatic access to comprehensive documentation for all 139 technical analysis indicators. Instead of searching through documentation manually, you can query indicator information directly from your code and get instant access to detailed guides, parameters, usage examples, and trading signals.

## Overview

The help system returns URLs to the online documentation hosted at [madbomber.github.io/sqa-tai](https://madbomber.github.io/sqa-tai). This approach keeps the gem lightweight while providing flexible access to rich, detailed documentation that includes:

- Indicator overview and history
- Parameter descriptions with defaults and ranges
- Calculation methods and formulas
- Interpretation guidelines
- Trading signals (buy/sell conditions)
- Best practices and common pitfalls
- Related indicators
- Practical examples

## Basic Usage

### Get Help for a Single Indicator

The simplest way to access help is to call `SQA::TAI.help` with an indicator name:

```ruby
require 'sqa/tai'

# Returns a HelpResource object
help = SQA::TAI.help(:sma)

# Access the documentation URL
puts help.url
# => https://madbomber.github.io/sqa-tai/indicators/overlap/sma/

# Get the indicator name
puts help.name
# => "SMA"

# Get the category
puts help.category
# => :overlap_studies

# Convert to string (returns URL)
puts help.to_s
# => https://madbomber.github.io/sqa-tai/indicators/overlap/sma/
```

### Open Documentation in Browser

Quickly open the documentation in your default web browser:

```ruby
# Open documentation and return HelpResource
SQA::TAI.help(:rsi, open: true)

# Or open from an existing HelpResource
help = SQA::TAI.help(:macd)
help.open
```

This automatically detects your operating system and uses the appropriate command (`open` on macOS, `xdg-open` on Linux, `start` on Windows).

### Get Documentation as Different Formats

The help method supports multiple return formats:

```ruby
# Default: Returns HelpResource object
help = SQA::TAI.help(:ema)

# As URI object
uri = SQA::TAI.help(:ema, format: :uri)
uri.host  # => "madbomber.github.io"
uri.path  # => "/sqa-tai/indicators/overlap/ema/"

# As Hash
info = SQA::TAI.help(:bbands, format: :hash)
# => {
#      name: "BBANDS",
#      category: :overlap_studies,
#      url: "https://madbomber.github.io/sqa-tai/indicators/overlap/bbands/"
#    }
```

## Advanced Features

### Search for Indicators

Search across all indicator names to find what you need:

```ruby
# Search returns a hash of matching indicators with their URLs
results = SQA::TAI.help(search: "momentum")
# => {
#      mom: "https://madbomber.github.io/sqa-tai/indicators/momentum/mom/",
#      cmo: "https://madbomber.github.io/sqa-tai/indicators/momentum/cmo/",
#      imi: "https://madbomber.github.io/sqa-tai/indicators/momentum/imi/",
#      ...
#    }

# Search is case-insensitive and matches indicator names or descriptions
oscillators = SQA::TAI.help(search: "oscillator")
moving_averages = SQA::TAI.help(search: "ma")
```

### List Indicators by Category

Get all indicators in a specific category:

```ruby
# Available categories:
# - :overlap_studies
# - :momentum_indicators
# - :volatility_indicators
# - :volume_indicators
# - :price_transform
# - :cycle_indicators
# - :statistical_functions
# - :pattern_recognition

momentum = SQA::TAI.help(category: :momentum_indicators)
# => {
#      rsi: "https://...",
#      macd: "https://...",
#      stoch: "https://...",
#      ...
#    }

patterns = SQA::TAI.help(category: :pattern_recognition)
# => {
#      cdl_doji: "https://...",
#      cdl_hammer: "https://...",
#      cdl_engulfing: "https://...",
#      ...
#    }
```

### List All Indicators

Get a complete list of all 139 available indicators:

```ruby
all_indicators = SQA::TAI.help(:all)
# => {
#      sma: "https://...",
#      ema: "https://...",
#      rsi: "https://...",
#      ... (139 total)
#    }

# Useful for building documentation or exploration tools
puts "Available indicators: #{all_indicators.size}"
all_indicators.each do |indicator, url|
  puts "#{indicator}: #{url}"
end
```

## HelpResource Object

The `HelpResource` object provides several useful methods:

### Properties

```ruby
help = SQA::TAI.help(:atr)

help.indicator  # => :atr (Symbol)
help.name      # => "ATR" (String)
help.category  # => :volatility_indicators (Symbol)
help.url       # => "https://..." (String)
```

### Methods

```ruby
# Get URI object for advanced URL manipulation
help.uri
# => #<URI::HTTPS https://madbomber.github.io/sqa-tai/indicators/volatility/atr/>

# Open in browser
help.open
# => Opens documentation in default browser, returns self

# Fetch documentation content
html_content = help.fetch
# => Returns raw HTML content of the page (requires 'net/http')

# String representation
help.to_s
# => "https://madbomber.github.io/sqa-tai/indicators/volatility/atr/"

# Inspect for debugging
help.inspect
# => "#<SQA::TAI::HelpResource atr (volatility_indicators): https://...>"
```

## Practical Examples

### Interactive Indicator Explorer

Build a simple command-line tool to explore indicators:

```ruby
require 'sqa/tai'

def explore_indicator(name)
  help = SQA::TAI.help(name.to_sym)

  puts "=" * 60
  puts "Indicator: #{help.name}"
  puts "Category:  #{help.category}"
  puts "URL:       #{help.url}"
  puts "=" * 60
  puts "\nOpening documentation in browser..."
  help.open
rescue ArgumentError => e
  puts "Error: #{e.message}"
  puts "\nDid you mean one of these?"

  # Search for similar indicators
  results = SQA::TAI.help(search: name)
  results.keys.first(5).each do |indicator|
    puts "  - #{indicator}"
  end
end

# Usage
explore_indicator("macd")
```

### Documentation Validator

Verify that all indicators have documentation:

```ruby
require 'sqa/tai'
require 'net/http'

all_indicators = SQA::TAI.help(:all)

puts "Checking documentation for #{all_indicators.size} indicators..."

all_indicators.each do |indicator, url|
  uri = URI(url)
  response = Net::HTTP.get_response(uri)

  if response.code == "200"
    puts "✓ #{indicator}"
  else
    puts "✗ #{indicator} - HTTP #{response.code}"
  end
end
```

### Category Summary

Generate a summary of indicators by category:

```ruby
require 'sqa/tai'

categories = [
  :overlap_studies,
  :momentum_indicators,
  :volatility_indicators,
  :volume_indicators,
  :price_transform,
  :cycle_indicators,
  :statistical_functions,
  :pattern_recognition
]

puts "SQA::TAI Indicator Summary"
puts "=" * 60

categories.each do |category|
  indicators = SQA::TAI.help(category: category)
  puts "\n#{category.to_s.split('_').map(&:capitalize).join(' ')}: #{indicators.size}"
  puts "-" * 60

  indicators.keys.first(5).each do |indicator|
    puts "  • #{indicator}"
  end

  if indicators.size > 5
    puts "  ... and #{indicators.size - 5} more"
  end
end
```

### Integration with Web Application

Use the help system in a Rails or Sinatra app:

```ruby
# Rails controller
class IndicatorsController < ApplicationController
  def show
    indicator = params[:id].to_sym
    @help = SQA::TAI.help(indicator)

    # Redirect to documentation
    redirect_to @help.url
  rescue ArgumentError
    render status: :not_found, json: { error: "Indicator not found" }
  end

  def search
    query = params[:q]
    @results = SQA::TAI.help(search: query)

    render json: @results
  end
end
```

## Error Handling

The help system raises `ArgumentError` if you request an unknown indicator:

```ruby
begin
  SQA::TAI.help(:nonexistent_indicator)
rescue ArgumentError => e
  puts e.message
  # => "Unknown indicator: nonexistent_indicator"

  # Show available indicators
  puts "\nAvailable indicators:"
  SQA::TAI.help(:all).keys.first(10).each do |indicator|
    puts "  - #{indicator}"
  end
end
```

## Maintenance

### Regenerating Help Data

If you add new documentation files or update indicator names, regenerate the help data:

```bash
rake help:generate
```

This task:
1. Scans all `docs/indicators/**/*.md` files
2. Extracts metadata (name, category, path)
3. Generates `lib/sqa/tai/help_data.rb` with indicator mappings
4. Maps 139 indicators automatically

The generated file is tracked in git and included in the gem, so end users don't need to run this task.

### How It Works

The help system consists of three components:

1. **HelpResource Class** (`lib/sqa/tai/help.rb`)
   - Encapsulates indicator documentation metadata
   - Provides methods for accessing and opening documentation

2. **Help Data** (`lib/sqa/tai/help_data.rb`)
   - Auto-generated mapping of indicators to documentation
   - Contains name, category, and path for each indicator

3. **Help Method** (`lib/sqa/tai.rb`)
   - Class method `SQA::TAI.help` provides the public API
   - Handles querying, searching, and filtering

## See Also

- [Basic Usage](basic-usage.md) - Introduction to using indicators
- [API Reference](../api-reference.md) - Complete method documentation
- [Indicators Overview](../indicators/index.md) - Browse all indicators
- [Pattern Recognition](pattern-recognition.md) - Candlestick patterns guide
