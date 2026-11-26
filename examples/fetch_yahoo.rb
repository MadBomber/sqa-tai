#!/usr/bin/env ruby
# frozen_string_literal: true

# Download a symbol's full daily price history from Yahoo Finance's public
# chart API, including its dividend and split events, save the raw JSON and
# summarise the events.
#
# Useful for checking a suspicious price jump: an adjustment error shows up
# here as an event on the jump date (see fix_tds.rb), while a real move has
# none.
#
# usage: examples/fetch_yahoo.rb [options] SYMBOL OUT.json [MIN_DIVIDEND]
#   SYMBOL       = ticker symbol, e.g. TDS
#   OUT.json     = where to save the raw chart response
#   MIN_DIVIDEND = list dividends of at least this many dollars (default: 1)
#
# options:
#   -h, --help   show this help
#
# Educational only -- not investment advice.

require "json"
require "net/http"
require "uri"
require_relative "demo_options"

CHART_URL = "https://query1.finance.yahoo.com/v8/finance/chart/"

# `from` is the first moment wanted, in seconds since 1970 (default: everything).
def chart_uri(symbol, now = Time.now, from = 0)
  uri = URI("#{CHART_URL}#{URI.encode_www_form_component(symbol)}")
  uri.query = URI.encode_www_form("period1" => from.to_i, "period2" => now.to_i, "interval" => "1d", "events" => "div,split")
  uri
end

# The raw chart response body for a symbol.
def download_chart(symbol)
  response = Net::HTTP.get_response(chart_uri(symbol), "User-Agent" => "Mozilla/5.0")
  abort "Yahoo Finance answered #{response.code} for #{symbol}" unless response.is_a?(Net::HTTPSuccess)
  response.body
end

# The first chart result in a response body.
def chart_result(body)
  json = JSON.parse(body)
  json.dig("chart", "result", 0) or abort "no chart data: #{json.dig('chart', 'error')}"
end

def iso_day(timestamp) = Time.at(timestamp.to_i).utc.strftime("%Y-%m-%d")

# [[date, split ratio], ...] oldest first.
def splits(result)
  (result.dig("events", "splits") || {}).values.sort_by { it["date"] }.map { [iso_day(it["date"]), it["splitRatio"]] }
end

# [[date, amount], ...] oldest first.
def dividends(result)
  (result.dig("events", "dividends") || {}).values.sort_by { it["date"] }.map { [iso_day(it["date"]), it["amount"]] }
end

def event_lines(events) = events.empty? ? ["  (none)"] : events.map { |date, value| "  #{date}  #{value}" }

def summary(result, min_dividend)
  days  = result["timestamp"]
  all   = dividends(result)
  large = all.select { |_, amount| amount >= min_dividend }
  [
    "bars: #{days.size}  #{iso_day(days.first)} .. #{iso_day(days.last)}",
    "splits:", *event_lines(splits(result)),
    "dividends: #{all.size}; those of at least $#{min_dividend}:", *event_lines(large)
  ].join("\n")
end

if $PROGRAM_NAME == __FILE__
  parse_demo_options(ARGV, __FILE__)
  symbol, out, min_dividend = ARGV
  abort "usage: #{$PROGRAM_NAME} SYMBOL OUT.json [MIN_DIVIDEND] (try --help)" unless symbol && out

  body = download_chart(symbol)
  File.write(out, body)
  puts summary(chart_result(body), (min_dividend || 1).to_f)
end
