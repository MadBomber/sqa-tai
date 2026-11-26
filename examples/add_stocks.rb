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
# adjusted close and flags four signs of bad data:
#   - a split and a sizeable "dividend" on the same date -- Yahoo counting one
#     distribution twice, which makes every earlier price too small (the TDS
#     error, see fix_tds.rb)
#   - a "dividend" worth more than BIG_DIVIDEND of the prior close (real
#     spin-offs trip it too)
#   - a one-day move beyond JUMP_UP / JUMP_DOWN (real spikes trip it too)
#   - more than STALE_SHARE of the bars having zero volume, which usually
#     means placeholder prices from before the stock really traded
# A flag is a prompt to look, not proof of an error.  Two remedies:
#   SYMBOL:YYYY-MM-DD   load only the bars from that date on, when the early
#                       history is unreliable (the checks then cover only those)
#   SYMBOL~YYYY-MM-DD   ignore the dividend on that date: every earlier bar is
#                       rescaled as if Yahoo had not applied it
# Both can be combined, e.g. XYZ:1990-01-01~2005-05-16.
#
# usage: examples/add_stocks.rb [options] OUT.sql SPEC [SPEC...]
#        cp $SQA_DATA_DIR/sqa.db $SQA_DATA_DIR/sqa.db.before-add
#        sqlite3 $SQA_DATA_DIR/sqa.db < OUT.sql
#   OUT.sql = where to write the SQL
#   SPEC    = SYMBOL[:YYYY-MM-DD][~YYYY-MM-DD], see above
#
# options:
#   -h, --help   show this help
#
# Reads $SQA_DATA_DIR/sqa.db (default ~/sqa_data) via the sqlite3
# command-line tool.  Educational only -- not investment advice.

require "time"
require_relative "fetch_yahoo"
require_relative "trading_scenarios"

SOURCE       = "yahoo_finance"
BIG_DIVIDEND = 0.2  # a dividend above this share of the prior close is flagged
TWIN_SHARE   = 0.05 # a dividend above this share, on a split date, is flagged as a possible double count
JUMP_UP      = 2.5  # a close-to-close ratio above this is flagged
JUMP_DOWN    = 0.4  # ... or below this
STALE_SHARE  = 0.05 # more than this share of zero-volume bars is flagged
PAUSE        = 0.5  # seconds between downloads
SPEC         = /\A(?<symbol>[^:~]+)(?::(?<from>\d{4}-\d{2}-\d{2}))?(?:~(?<ignore>\d{4}-\d{2}-\d{2}))?\z/

# ---- the download ---------------------------------------------------------

# { date => raw (unadjusted for dividends) close }.
def raw_closes(result)
  closes = result.dig("indicators", "quote", 0, "close")
  result["timestamp"].each_index.filter_map { closes[it] && [iso_day(result["timestamp"][it]), closes[it]] }.to_h
end

# [[date, amount, share of the prior close], ...] for every dividend that has a prior bar.
def dividend_shares(result)
  closes = raw_closes(result)
  days   = closes.keys
  dividends(result).filter_map do |date, amount|
    at = days.bsearch_index { it >= date }
    [date, amount, amount / closes[days[at - 1]]] if at&.positive?
  end
end

# The factor Yahoo applied to every bar before `date` for the dividend paid
# that day: 1 - dividend / prior close.
def dividend_factor(result, date)
  found = dividend_shares(result).find { |day, _, _| day == date } or abort "no dividend on #{date} to ignore"
  1.0 - found.last
end

# [[date, open, high, low, close, volume], ...] adjusted, oldest first.
# Bars missing a price or volume are dropped; a result with no bars gives [].
# With `ignore`, the dividend on that date is left out of the adjustment.
def adjusted_bars(result, ignore = nil)
  return [] unless result["timestamp"]

  quote    = result.dig("indicators", "quote", 0)
  adjusted = result.dig("indicators", "adjclose", 0, "adjclose") || quote["close"]
  undo     = ignore ? dividend_factor(result, ignore) : 1.0
  result["timestamp"].each_index.filter_map do |index|
    close = quote["close"][index]
    next unless close&.positive? && adjusted[index] && quote["open"][index] && quote["volume"][index]

    day    = iso_day(result["timestamp"][index])
    factor = adjusted[index] / close / (ignore && day < ignore ? undo : 1.0)
    prices = %w[open high low close].map { (quote[it][index] * factor).round(6) }
    [day, *prices, quote["volume"][index].to_i]
  end
end

# ---- checks ---------------------------------------------------------------

# Notes for dividends after `from` that look wrong: on a split date (a
# possible double count) or simply very large.  The ignored date is skipped.
def dividend_notes(result, from, ignore)
  split_ratios = splits(result).to_h
  dividend_shares(result).filter_map do |date, amount, share|
    next unless date > from && date != ignore

    if split_ratios[date] && share > TWIN_SHARE
      "split #{split_ratios[date]} and dividend #{amount} both on #{date} -- possible double count (try ~#{date})"
    elsif share > BIG_DIVIDEND
      "dividend #{amount} on #{date} = #{(share * 100).round}% of price"
    end
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

def flags(result, bars, ignore = nil)
  up, down = extreme_moves(bars)
  list = dividend_notes(result, bars.first[0], ignore)
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

# "SU:1997-01-01" -> { symbol: "SU", from: "1997-01-01", ignore: nil }.
def parse_spec(spec)
  match = SPEC.match(spec) or abort "bad spec #{spec.inspect} (want SYMBOL[:YYYY-MM-DD][~YYYY-MM-DD])"
  { symbol: match[:symbol].upcase, from: match[:from], ignore: match[:ignore] }
end

def report_line(spec, meta, bars, notes)
  up, down = extreme_moves(bars)
  line = "#{spec[:symbol].ljust(6)} #{bars.size.to_s.rjust(6)}  #{bars.first[0]} .. #{bars.last[0]}  " \
         "max #{format('%.2f', up.last)}x  min #{format('%.2f', down.last)}x  #{meta['longName'] || meta['shortName']}"
  ignored = spec[:ignore] && "         ignoring the dividend on #{spec[:ignore]}"
  [line, ignored, *notes.map { "         ** #{it}" }].compact
end

# [report lines, SQL lines] for one symbol spec.
def add_symbol(spec, now)
  result = chart_result(download_chart(spec[:symbol]))
  bars   = adjusted_bars(result, spec[:ignore])
  bars   = bars.drop_while { it[0] < spec[:from] } if spec[:from]
  return [["#{spec[:symbol].ljust(6)} no usable bars"], []] if bars.size < 2

  meta = result["meta"] || {}
  [report_line(spec, meta, bars, flags(result, bars, spec[:ignore])), symbol_sql(spec[:symbol].downcase, meta, bars, now)]
end

def all_stock_tickers(db) = query(db, "SELECT ticker FROM stocks;").flatten

def run_add(db, out, specs, now = Time.now.utc.iso8601)
  existing = all_stock_tickers(db)
  lines    = []
  sql      = ["BEGIN;"]
  specs.map { parse_spec(it) }.uniq { it[:symbol] }.each do |spec|
    next lines << "#{spec[:symbol].ljust(6)} already in the database -- skipped" if existing.include?(spec[:symbol].downcase)

    report, statements = add_symbol(spec, now)
    lines.concat(report)
    sql.concat(statements)
    sleep PAUSE
  end
  File.write(out, "#{[*sql, 'COMMIT;'].join("\n")}\n")
  [*lines, "#{sql.count { it.start_with?('INSERT INTO stocks') }} symbols, #{sql.size - 1} statements written to #{out}"].join("\n")
end

if $PROGRAM_NAME == __FILE__
  parse_demo_options(ARGV, __FILE__)
  out, *specs = ARGV
  abort "usage: #{$PROGRAM_NAME} OUT.sql SYMBOL[:YYYY-MM-DD][~YYYY-MM-DD] ... (try --help)" if out.nil? || specs.empty?

  puts run_add(DB, out, specs)
end
