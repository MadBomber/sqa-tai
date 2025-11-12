# Statistical Indicators

Statistical indicators apply mathematical and statistical functions to price data to identify trends, measure correlation, and forecast future price movements. These indicators use regression analysis, standard deviation, and other statistical methods.

## Available Statistical Indicators

### [Beta (BETA)](beta.md)
Measures correlation between a security and the overall market.

### [Correlation (CORREL)](correl.md)
Pearson's Correlation Coefficient between two price series.

### [Linear Regression (LINEARREG)](linearreg.md)
Fits a linear regression line through price data.

### [Linear Regression Angle (LINEARREG_ANGLE)](linearreg_angle.md)
Angle of the linear regression line in degrees.

### [Linear Regression Intercept (LINEARREG_INTERCEPT)](linearreg_intercept.md)
Y-intercept of the linear regression line.

### [Linear Regression Slope (LINEARREG_SLOPE)](linearreg_slope.md)
Slope of the linear regression line.

### [Standard Deviation (STDDEV)](stddev.md)
Measures price volatility using statistical standard deviation.

### [Time Series Forecast (TSF)](tsf.md)
Projects future prices based on linear regression.

### [Variance (VAR)](var.md)
Measures price dispersion (variance).

## Common Usage

```ruby
require 'sqa/tai'

close = [45.0, 46.0, 45.5, 47.0, 46.5, 48.0, 47.5]

# Linear regression
linearreg = SQA::TAI.linearreg(close, period: 14)

# Standard deviation
stddev = SQA::TAI.stddev(close, period: 14)

# Correlation between two series
correl = SQA::TAI.correl(series1, series2, period: 30)
```

## See Also

- [All Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
