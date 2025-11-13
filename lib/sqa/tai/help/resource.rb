# frozen_string_literal: true

require "uri"

module SQA
  module TAI
    module Help
      # Represents help documentation for a specific indicator
      class Resource
        attr_reader :indicator, :name, :category, :url

        def initialize(indicator, name, category, path)
          @indicator = indicator
          @name = name
          @category = category
          @url = "#{BASE_URL}/#{path}/"
        end

        # Returns URI object for the documentation URL
        # @return [URI::HTTPS]
        def uri
          @uri ||= URI.parse(@url)
        end

        # Opens the documentation URL in the default browser
        # @return [Resource] self for chaining
        def open
          if RbConfig::CONFIG["host_os"] =~ /darwin/
            system("open", @url)
          elsif RbConfig::CONFIG["host_os"] =~ /linux|bsd/
            system("xdg-open", @url)
          elsif RbConfig::CONFIG["host_os"] =~ /mswin|mingw|cygwin/
            system("start", @url)
          else
            warn "Unable to open browser on this platform"
          end
          self
        end

        # Fetches the documentation content from the URL
        # @return [String] HTML content of the documentation page
        def fetch
          require "net/http"
          Net::HTTP.get(uri)
        end

        # Returns formatted help information
        # @return [String]
        def to_s
          category_label = @category.to_s.split('_').map(&:capitalize).join(' ')
          <<~HELP
            Indicator: #{@indicator.to_s.upcase} (#{@name})
            Category:  #{category_label}
            Website:   #{@url}
          HELP
        end

        # Returns detailed information about the help resource
        # @return [String]
        def inspect
          "#<SQA::TAI::Help::Resource #{indicator} (#{category}): #{url}>"
        end
      end
    end
  end
end
