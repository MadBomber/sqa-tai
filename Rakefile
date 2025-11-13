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
    Dir.glob("docs/indicators/**/*.md").sort.each do |file|
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
          if line.start_with?("# ")
            name = line.gsub(/^#\s*/, "").strip
            # Remove content after parentheses if present
            name = name.split("(").first.strip if name.include?("(")
            break
          end
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
