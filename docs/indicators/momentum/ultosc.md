# Ultimate Oscillator (ULTOSC)

Combines short, intermediate, and long-term momentum.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `high` | Array<Float> | Yes | - | Array of high values |
| `low` | Array<Float> | Yes | - | Array of low values |
| `close` | Array<Float> | Yes | - | Array of close values |
| `period1` | Integer | No | 7 | Period1 |
| `period2` | Integer | No | 14 | Period2 |
| `period3` | Integer | No | 28 | Period3 |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

## Returns

Returns an array of indicator values.

## Usage

```ruby
require 'sqa/tai'

# Example usage
result = SQA::TAI.ultosc(prices)

puts "Current value: #{result.last.round(2)}"
```

## Interpretation

Please refer to technical analysis resources for interpretation guidelines for this indicator.

## Related Indicators

- [Back to Indicators](../index.md)
- [Momentum Indicators Overview](../index.md)

## See Also

- [Back to Indicators](../index.md)
