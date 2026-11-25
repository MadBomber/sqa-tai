#!/usr/bin/env ruby
# frozen_string_literal: true

# Download new symbols from Yahoo Finance and write the SQL that adds them
# to the price database, in the same form as the bars already there:
# split- and dividend-adjusted, with open/high/low scaled by the same factor
# Yahoo applied to the close, and prices rounded to six decimals.
#
# The database itself is not changed -- review the report, back the database
# up, then apply the SQL.  Symbols already in the database are skipped.
#
# For every symbol the report shows the largest one-day rise and fall of the
# adjusted close and flags three signs of bad data:
#   - a "dividend" worth more than BIG_DIVIDEND of the prior close (the TDS
#     error, see fix_tds.rb -- though real spin-offs trip it too)
#   - a one-day move beyond JUMP_UP / JUMP_DOWN (real spikes trip it too)
#   - more than STALE_SHARE of the bars having zero volume, which usually
#     means placeholder prices from before the stock really traded
# A flag is a prompt to look, not proof of an error.  When a symbol's early
# history is unreliable, give it a start date to load only the bars from
# that date on -- the checks then cover only those bars.
#
# usage: examples/add_stocks.rb OUT.sql SYMBOL[:YYYY-MM-DD] [SYMBOL[:YYYY-MM-DD]...]
#        cp $SQA_DATA_DIR/sqa.db $SQA_DATA_DIR/sqa.db.before-add
#        sqlite3 $SQA_DATA_DIR/sqa.db < OUT.sql
#
# Reads $SQA_DATA_DIR/sqa.db (default ~/sqa_data) via the sqlite3
# command-line tool.  Educational only -- not investment advice.

require "time"
require_relative "fetch_yahoo"
require_relative "trading_scenarios"

SOURCE       = "yahoo_finance"
BIG_DIVIDEND = 0.2 # a dividend above this share of the prior close is flagged
JUMP_UP      = 2.5 # a close-to-close ratio above this is flagged
JUMP_DOWN    = 0.4 # ... or below this
STALE_SHARE  = 0.05 # more than this share of zero-volume bars is flagged
PAUSE        = 0.5 # seconds between downloads

# ---- the download ---------------------------------------------------------

# [[date, open, high, low, close, volume], ...] adjusted, oldest first.
# Bars missing a price or volume are dropped; a result with no bars gives [].
def adjusted_bars(result)
  return [] unless result["timestamp"]

  quote    = result.dig("indicators", "quote", 0)
  adjusted = result.dig("indicators", "adjclose", 0, "adjclose") || quote["close"]
  result["timestamp"].each_index.filter_map do |index|
    close = quote["close"][index]
    next unless close&.positive? && adjusted[index] && quote["open"][index] && quote["volume"][index]

    factor = adjusted[index] / close
    prices = %w[open high low].map { (quote[it][index] * factor).round(6) }
    [iso_day(result["timestamp"][index]), *prices, adjusted[index].round(6), quote["volume"][index].to_i]
  end
end

# { date => raw (unadjusted for dividends) close }.
def raw_closes(result)
  closes = result.dig("indicators", "quote", 0, "close")
  result["timestamp"].each_index.filter_map { closes[it] && [iso_day(result["timestamp"][it]), closes[it]] }.to_h
end

# ---- checks ---------------------------------------------------------------

# [[date, amount, share of the prior close], ...] for dividends on or after
# `from` that are above the limit.
def big_dividends(result, from, limit = BIG_DIVIDEND)
  closes = raw_closes(result)
  days   = closes.keys
  dividends(result).filter_map do |date, amount|
    at = days.bsearch_index { it >= date }
    next unless date > from && at&.positive?

    share = amount / closes[days[at - 1]]
    [date, amount, share] if share > limit
  end
end

# A note when too many bars have zero volume, else nil.
def stale_note(bars, limit = STALE_SHARE)
  idle = bars.select { it[5].zero? }
  return nil unless idle.size > bars.size * limit

  "#{idle.size} of #{bars.size} bars have zero volume (last on #{idle.last[0]})"
end

# [largest [date, ratio], smallest [date, ratio]] of close-to-close ratios.
def extreme_moves(bars)
  ratios = bars.each_cons(2).map { |before, after| [after[0], after[4] / before[4]] }
  [ratios.max_by(&:last), ratios.min_by(&:last)]
end

def flags(result, bars)
  up, down = extreme_moves(bars)
  list = big_dividends(result, bars.first[0]).map do |date, amount, share|
    "dividend #{amount} on #{date} = #{(share * 100).round}% of price"
  end
  list << "rose #{up.last.round(2)}x on #{up.first}" if up.last > JUMP_UP
  list << "fell to #{down.last.round(2)}x on #{down.first}" if down.last < JUMP_DOWN
  list << stale_note(bars)
  list.compact
end

# ---- SQL ------------------------------------------------------------------

def quoted(text) = "'#{text.to_s.gsub("'", "''")}'"

def stock_sql(ticker, meta, now)
  "INSERT INTO stocks (ticker, name, exchange, source, overview, indicators, updated_at) VALUES " \
    "(#{quoted(ticker)}, #{quoted(meta['longName'] || meta['shortName'])}, #{quoted(meta['fullExchangeName'])}, " \
    "#{quoted(SOURCE)}, '{}', '{}', #{quoted(now)});"
end

def price_sql(ticker, bar)
  date, open, high, low, close, volume = bar
  "INSERT INTO prices VALUES (#{quoted(ticker)}, #{quoted(date)}, #{open}, #{high}, #{low}, #{close}, #{close}, #{volume});"
end

def symbol_sql(ticker, meta, bars, now) = [stock_sql(ticker, meta, now), *bars.map { price_sql(ticker, it) }]

# ---- command line ---------------------------------------------------------

def report_line(symbol, meta, bars, notes)
  up, down = extreme_moves(bars)
  line = "#{symbol.ljust(6)} #{bars.size.to_s.rjust(6)}  #{bars.first[0]} .. #{bars.last[0]}  " \
         "max #{format('%.2f', up.last)}x  min #{format('%.2f', down.last)}x  #{meta['longName'] || meta['shortName']}"
  [line, *notes.map { "         ** #{it}" }]
end

# "SU:1997-01-01" -> ["SU", "1997-01-01"]; "su" -> ["SU", nil].
def parse_spec(spec)
  symbol, from = spec.split(":", 2)
  abort "bad start date in #{spec.inspect} (want SYMBOL:YYYY-MM-DD)" if from && !from.match?(/\A\d{4}-\d{2}-\d{2}\z/)
  [symbol.upcase, from]
end

# [report lines, SQL lines] for one symbol, keeping only bars on or after `from`.
def add_symbol(symbol, from, now)
  result = chart_result(download_chart(symbol))
  bars   = adjusted_bars(result)
  bars   = bars.drop_while { it[0] < from } if from
  return [["#{symbol.ljust(6)} no usable bars"], []] if bars.size < 2

  meta = result["meta"] || {}
  [report_line(symbol, meta, bars, flags(result, bars)), symbol_sql(symbol.downcase, meta, bars, now)]
end

def run_add(db, out, specs, now = Time.now.utc.iso8601)
  existing = all_stock_tickers(db)
  lines    = []
  sql      = ["BEGIN;"]
  specs.map { parse_spec(it) }.uniq(&:first).each do |symbol, from|
    next lines << "#{symbol.ljust(6)} already in the database -- skipped" if existing.include?(symbol.downcase)

    report, statements = add_symbol(symbol, from, now)
    lines.concat(report)
    sql.concat(statements)
    sleep PAUSE
  end
  File.write(out, "#{[*sql, 'COMMIT;'].join("\n")}\n")
  [*lines, "#{sql.count { it.start_with?('INSERT INTO stocks') }} symbols, #{sql.size - 1} statements written to #{out}"].join("\n")
end

def all_stock_tickers(db) = query(db, "SELECT ticker FROM stocks;").flatten

if $PROGRAM_NAME == __FILE__
  out, *symbols = ARGV
  abort "usage: #{$PROGRAM_NAME} OUT.sql SYMBOL[:YYYY-MM-DD] [SYMBOL[:YYYY-MM-DD]...]" if out.nil? || symbols.empty?

  puts run_add(DB, out, symbols)
end
