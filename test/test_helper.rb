# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "sqa/talib"
require "minitest/autorun"
require "minitest/reporters"

Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new]

# Sample test data
module TestData
  PRICES = [
    44.34, 44.09, 44.15, 43.61, 44.33, 44.83, 45.10, 45.42, 45.84, 46.08,
    45.89, 46.03, 45.61, 46.28, 46.28, 46.00, 46.03, 46.41, 46.22, 45.64,
    46.21, 46.25, 45.71, 46.45, 45.78, 45.35, 44.03, 44.18, 44.22, 44.57
  ].freeze

  OPEN = [44.0, 44.1, 44.2, 43.5, 44.0, 44.5, 45.0, 45.3, 45.7, 46.0].freeze
  HIGH = [44.5, 44.3, 44.4, 44.0, 44.5, 45.0, 45.5, 45.8, 46.2, 46.3].freeze
  LOW = [43.8, 43.9, 43.9, 43.3, 43.8, 44.3, 44.8, 45.1, 45.5, 45.8].freeze
  CLOSE = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83, 45.10, 45.42, 45.84, 46.08].freeze
  VOLUME = [1000, 1100, 1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900].freeze
end
