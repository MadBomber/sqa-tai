# frozen_string_literal: true

require_relative "lib/sqa/talib/version"

Gem::Specification.new do |spec|
  spec.name         = "sqa-talib"
  spec.version      = SQA::TALib::VERSION
  spec.authors      = ["Dewayne VanHoozer"]
  spec.email        = ["dvanhoozer@gmail.com"]

  spec.summary      = "TA-Lib wrapper for SQA - Technical Analysis Indicators"
  spec.description  = "Ruby wrapper around TA-Lib providing 200+ technical analysis indicators for stock analysis. Part of the SQA (Stock Qualitative Analysis) ecosystem."
  spec.homepage     = "https://github.com/MadBomber/sqa-talib"
  spec.license      = "MIT"

  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"]      = spec.homepage
  spec.metadata["source_code_uri"]   = spec.homepage
  spec.metadata["changelog_uri"]     = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://madbomber.github.io/sqa-talib"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[test/ spec/ features/ .git .github/ docs/])
    end
  end

  spec.require_paths = ["lib"]

  # Core dependency
  spec.add_dependency "ta_lib_ffi", "~> 0.3"

  # Development dependencies
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "minitest-reporters"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "debug"
end
