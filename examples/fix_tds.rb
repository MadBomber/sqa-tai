#!/usr/bin/env ruby
# frozen_string_literal: true

# Repair the TDS price history after a download from Yahoo Finance.
#
# On 2005-05-16 TDS distributed one Special Common share per share held.
# Yahoo lists that event twice: as a 10000:5125 split (correct) and again as
# a $34.29623 cash "dividend" on a $35 stock (wrong).  Yahoo scales every bar
# before an ex-dividend date by (1 - dividend / prior close), so the bogus
# entry makes every adjusted price before 2005-05-16 about 40.78x too small
# and leaves a one-day 40x jump in the series.  A fresh download has the same
# error, so re-downloading TDS reintroduces it.
#
# This program recomputes every bar before the ex-date from a Yahoo download
# with that one factor divided back out, and writes the result as SQL.  It
# does not change the database itself, and it reports whether the database
# still has the bad bar.  Once repaired there is no need to apply the SQL
# again: Yahoo's numbers differ in their last digits from one download to the
# next, so a second application rewrites the same bars with differences in
# the sixth decimal place (under 0.001%).  Those are harmless as prices, but
# a backtest that compares a close with an average of nearly equal closes can
# flip a signal on them, so results may shift.
#
# usage: examples/fetch_yahoo.rb TDS tds.json
#        examples/fix_tds.rb [options] tds.json fix_tds.sql
#        cp $SQA_DATA_DIR/sqa.db $SQA_DATA_DIR/sqa.db.before-tds-fix
#        sqlite3 $SQA_DATA_DIR/sqa.db < fix_tds.sql
#
# options:
#   -h, --help   show this help
#
# Reads $SQA_DATA_DIR/sqa.db (default ~/sqa_data) via the sqlite3
# command-line tool.  Educational only -- not investment advice.

require_relative "fetch_yahoo"
require_relative "trading_scenarios"

TICKER         = "tds"
EX_DATE        = "2005-05-16"
BOGUS_DIVIDEND = 34.29623
JUMP_LIMIT     = 2.0 # a close-to-close ratio above this across the ex-date means "not repaired"

# ---- the download ---------------------------------------------------------

# { dates:, open:, high:, low:, close:, adjusted: } column arrays, oldest first.
def chart_columns(result)
  quote = result.dig("indicators", "quote", 0)
  { dates: result["timestamp"].map { iso_day(it) }, open: quote["open"], high: quote["high"],
    low: quote["low"], close: quote["close"], adjusted: result.dig("indicators", "adjclose", 0, "adjclose") }
end

# The factor the bogus dividend applied to every bar before index `ex`.
def bogus_factor(columns, ex, dividend = BOGUS_DIVIDEND) = 1.0 - (dividend / columns[:close][ex - 1])

# The discontinuity in Yahoo's adjustment factor across index `ex`.
def observed_factor(columns, ex)
  before = columns[:adjusted][ex - 1] / columns[:close][ex - 1]
  after  = columns[:adjusted][ex] / columns[:close][ex]
  before / after
end

# Aborts unless the download still carries the bogus dividend and its factor
# explains the whole discontinuity (i.e. no real dividend shares the date).
def verify_download(result, columns, ex)
  listed = dividends(result).find { |date, _| date == EX_DATE }
  abort "bogus dividend not found on #{EX_DATE}; Yahoo may have fixed its data" unless listed
  abort "dividend on #{EX_DATE} is #{listed.last}, expected #{BOGUS_DIVIDEND}" if (listed.last - BOGUS_DIVIDEND).abs > 1e-6

  formula = bogus_factor(columns, ex)
  seen    = observed_factor(columns, ex)
  abort "factor mismatch: formula #{formula} vs observed #{seen}" if ((formula / seen) - 1).abs > 1e-3
end

# Corrected [open, high, low, close] for bar `index`, rounded as the loader does.
def corrected_bar(columns, index, factor)
  scale = columns[:adjusted][index] / columns[:close][index] / factor
  %i[open high low close].map { (columns[it][index] * scale).round(6) }
end

# ---- the database ---------------------------------------------------------

# { date => close } for every stored bar before the ex-date.
def stored_closes(db)
  sql = "SELECT timestamp, close_price FROM prices WHERE ticker='#{TICKER}' AND timestamp < '#{EX_DATE}' " \
        "ORDER BY timestamp;"
  query(db, sql).to_h { |date, close| [date, close.to_f] }
end

# Close-to-close ratio across the ex-date in the database (about 40.8 when
# the bad bar is present, about 1 when repaired).
def stored_jump(db)
  sql = "SELECT close_price FROM prices WHERE ticker='#{TICKER}' AND timestamp <= '#{EX_DATE}' " \
        "ORDER BY timestamp DESC LIMIT 2;"
  at, before = query(db, sql).flatten.map(&:to_f)
  at / before
end

def update_sql(date, bar)
  open, high, low, close = bar
  "UPDATE prices SET open_price=#{open}, high_price=#{high}, low_price=#{low}, close_price=#{close}, " \
    "adj_close_price=#{close} WHERE ticker='#{TICKER}' AND timestamp='#{date}';"
end

# The whole repair as one transaction.
def repair_sql(columns, ex, factor)
  updates = (0...ex).map { update_sql(columns[:dates][it], corrected_bar(columns, it, factor)) }
  ["BEGIN;", *updates, "COMMIT;"].join("\n")
end

# ---- command line ---------------------------------------------------------

def status_line(jump)
  state = jump > JUMP_LIMIT ? "NOT repaired -- apply the SQL" : "already repaired -- no need to apply the SQL"
  "database close-to-close ratio across #{EX_DATE}: #{jump.round(3)}  (#{state})"
end

def run(db, json_path, out)
  result  = chart_result(File.read(json_path))
  columns = chart_columns(result)
  ex      = columns[:dates].index(EX_DATE) or abort "no bar on #{EX_DATE} in #{json_path}"
  verify_download(result, columns, ex)
  abort "dates before #{EX_DATE} differ between download and database" unless stored_closes(db).keys == columns[:dates][0...ex]

  factor = bogus_factor(columns, ex)
  File.write(out, "#{repair_sql(columns, ex, factor)}\n")
  <<~REPORT
    bogus factor #{factor.round(6)} (prices before #{EX_DATE} are #{(1 / factor).round(2)}x too small in Yahoo's data)
    #{ex} bars, #{columns[:dates].first} .. #{columns[:dates][ex - 1]}, written to #{out}
    #{status_line(stored_jump(db))}
  REPORT
end

if $PROGRAM_NAME == __FILE__
  parse_demo_options(ARGV, __FILE__)
  json_path, out = ARGV
  abort "usage: #{$PROGRAM_NAME} TDS.json OUT.sql (try --help)" unless json_path && out

  puts run(DB, json_path, out)
end
