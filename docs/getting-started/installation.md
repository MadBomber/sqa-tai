# Installation

This guide will help you install SQA::TAI and its dependencies.

## Prerequisites

SQA::TAI requires:

- Ruby >= 3.1.0
- TA-Lib C library >= 0.4.0

## Step 1: Install TA-Lib C Library

The TA-Lib C library must be installed before the Ruby gem.

### macOS

Using Homebrew:

```bash
brew install ta-lib
```

### Ubuntu/Debian

Build from source:

```bash
# Download TA-Lib
wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz
tar -xzf ta-lib-0.4.0-src.tar.gz
cd ta-lib/

# Build and install
./configure --prefix=/usr
make
sudo make install

# Update library cache
sudo ldconfig
```

### CentOS/RHEL/Fedora

```bash
# Download and extract
wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz
tar -xzf ta-lib-0.4.0-src.tar.gz
cd ta-lib/

# Build and install
./configure --prefix=/usr
make
sudo make install

# Update library cache
sudo ldconfig
```

### Windows

1. Download the MSI installer from [ta-lib.org](https://ta-lib.org/hdr_dw.html)
2. Run the installer
3. Add TA-Lib to your PATH

## Step 2: Install Ruby Gem

### Using Bundler (Recommended)

Add to your `Gemfile`:

```ruby
gem 'sqa-tai'
```

Then run:

```bash
bundle install
```

### Using RubyGems

```bash
gem install sqa-tai
```

## Verify Installation

Test that everything is working:

```ruby
require 'sqa/tai'

# Check if TA-Lib is available
if SQA::TAI.available?
  puts "✓ TA-Lib is installed and ready!"
  puts "Version: #{SQA::TAI::VERSION}"
else
  puts "✗ TA-Lib C library not found"
end

# Try a simple calculation
prices = [10, 11, 12, 13, 14, 15]
sma = SQA::TAI.sma(prices, period: 3)
puts "SMA test: #{sma}"
```

## Troubleshooting

### "TA-Lib not found" Error

If you get a "TA-Lib not installed" error:

1. **Verify TA-Lib is installed**:
   ```bash
   # On Unix/Linux/macOS
   ldconfig -p | grep talib
   # Should show: libta_lib.so
   ```

2. **Check library path**:
   ```bash
   # Find where TA-Lib was installed
   sudo find / -name "libta_lib.so*" 2>/dev/null
   ```

3. **Set library path** (if needed):
   ```bash
   export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
   ```

### Permission Errors

If you get permission errors during installation:

```bash
# Use sudo for system installation
sudo gem install sqa-tai

# Or use a Ruby version manager (recommended)
rbenv install 3.3.0
rbenv global 3.3.0
gem install sqa-tai
```

### Build Failures on Linux

If compilation fails:

```bash
# Install build tools
sudo apt-get install build-essential

# Or on CentOS/RHEL
sudo yum groupinstall "Development Tools"
```

## Next Steps

- [Quick Start Guide](quick-start.md)
- [Basic Usage](basic-usage.md)
- [API Reference](../api-reference.md)
