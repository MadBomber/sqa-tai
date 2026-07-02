# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
  t.warning = false
end

task default: :test

desc "Check code style with RuboCop"
task :rubocop do
  sh "bundle exec rubocop --format simple"
end

desc "Auto-correct RuboCop offenses"
task :rubocop_fix do
  sh "bundle exec rubocop -A"
end

desc "Check code complexity with Flog (warn >=20, fail >=50)"
task :flog_check do
  require "flog"

  warn_threshold = 20.0
  fail_threshold = 50.0

  flogger = Flog.new(all: true)
  flogger.flog(*Dir.glob("lib/**/*.rb"))

  warnings = []
  failures = []

  flogger.each_by_score do |method, score|
    next if method.end_with?("#none")

    if score > fail_threshold
      failures << "#{format("%.1f", score)}: #{method}"
    elsif score > warn_threshold
      warnings << "#{format("%.1f", score)}: #{method}"
    end
  end

  unless warnings.empty?
    puts "\nFlog warnings (#{warn_threshold}–#{fail_threshold}) — target for future refactoring:"
    warnings.each { |v| puts "  #{v}" }
  end

  if failures.empty?
    puts "\nFlog: no methods exceed the failure threshold (>=#{fail_threshold})"
  else
    puts "\nFlog failures (>=#{fail_threshold}) — must be refactored:"
    failures.each { |v| puts "  #{v}" }
    abort "\nFlog quality gate failed: #{failures.size} method(s) exceed #{fail_threshold}"
  end
end

desc "Check for structural code duplication with Flay (mass >= 50)"
task :flay_check do
  require "flay"

  mass_threshold = 50

  flay = Flay.new(mass: mass_threshold, diff: false, verbose: false, summary: false, timeout: 60)
  flay.process(*Dir.glob("lib/**/*.rb"))
  flay.analyze

  if flay.hashes.empty?
    puts "\nFlay: no structural duplication detected (mass >= #{mass_threshold})"
  else
    puts "\nFlay found structural duplication (mass >= #{mass_threshold}):"
    flay.report
    abort "\nFlay quality gate failed: #{flay.hashes.length} pattern(s) detected"
  end
end

desc "Run all quality checks: tests (with coverage), Flog, and Flay"
task :quality do
  results = {}

  puts "\n#{"=" * 60}"
  puts "Quality Gate: Tests + Coverage"
  puts "=" * 60
  results[:tests] = system("bundle exec rake test") ? :pass : :fail

  puts "\n#{"=" * 60}"
  puts "Quality Gate: Flog Complexity"
  puts "=" * 60
  results[:flog] = system("bundle exec rake flog_check") ? :pass : :fail

  puts "\n#{"=" * 60}"
  puts "Quality Gate: Flay Duplication"
  puts "=" * 60
  results[:flay] = system("bundle exec rake flay_check") ? :pass : :fail

  puts "\n#{"=" * 60}"
  puts "Quality Summary"
  puts "=" * 60
  results.each do |gate, status|
    icon = status == :pass ? "PASS" : "FAIL"
    puts "  [#{icon}] #{gate}"
  end
  puts "=" * 60

  abort "\nQuality gate failed" if results.values.any?(:fail)
  puts "\nAll quality gates passed."
end

namespace :help do
  desc "Generate help mappings from documentation files"
  task :generate do
    require "fileutils"

    indicators = {}
    category_mapping = {
      "overlap" => :overlap_studies,
      "momentum" => :momentum_indicators,
      "volatility" => :volatility_indicators,
      "volume" => :volume_indicators,
      "price_transform" => :price_transform,
      "statistical" => :statistical_functions,
      "cycle" => :cycle_indicators,
      "patterns" => :pattern_recognition
    }

    # Scan docs directory
    Dir.glob("docs/indicators/**/*.md").each do |file|
      next if file.include?("index.md")

      # Extract indicator name from filename
      indicator = File.basename(file, ".md").to_sym

      # Extract category from path
      path_category = File.dirname(file).split("/").last
      category = category_mapping[path_category] || path_category.to_sym

      # Read first heading for name
      name = nil
      File.open(file, "r") do |f|
        f.each_line do |line|
          next unless line.start_with?("# ")
          name = line.gsub(/^#\s*/, "").strip
          # Remove content after parentheses if present
          name = name.split("(").first.strip if name.include?("(")
          break
        end
      end

      # Build path relative to docs/
      path = file.gsub("docs/", "").gsub(".md", "")

      indicators[indicator] = {
        name: name || indicator.to_s.upcase,
        category: category,
        path: path
      }
    end

    # Convert to JSON-friendly format (strings instead of symbols)
    json_data = indicators.transform_keys(&:to_s).transform_values do |meta|
      {
        "name" => meta[:name],
        "category" => meta[:category].to_s,
        "path" => meta[:path]
      }
    end

    # Write to JSON file
    require "json"
    json_output = JSON.pretty_generate(json_data)
    File.write("lib/sqa/tai/help/data.json", json_output)
    puts "✓ Generated help data for #{indicators.size} indicators"
    puts "  File: lib/sqa/tai/help/data.json"
  end
end
