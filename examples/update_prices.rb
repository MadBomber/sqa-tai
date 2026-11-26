#!/usr/bin/env ruby
# frozen_string_literal: true

# Bring the price database up to date: for every ticker whose history stops
# before today, download the bars since its last stored day from Yahoo
# Finance and add the ones for the weekdays that are missing.
#
# New bars are stored in the same form as the old ones (see add_stocks.rb):
# split- and dividend-adjusted, six decimals.  That form has a catch -- when
# a stock pays a dividend or splits, Yahoo rescales every EARLIER adjusted
# price.  So each download starts at the last stored day and that day's close
# is compared with the stored one:
#   - same close            -> the new bars are simply appended
#   - different, and Yahoo lists a split or dividend since then
#                           -> the ticker's stored history is rescaled by the
#                              ratio (volume too, for a split), then the new
#                              bars are appended.  History is rescaled rather
#                              than downloaded again so hand-made corrections
#                              (trimmed starts, ignored dividends) survive.
#   - different, no event   -> the ticker is flagged and left alone
#
# A bar for a trading session still in progress is not stored.  A missing
# weekday with no bar from Yahoo (a market holiday, or prices not published
# yet) is reported and tried again on the next run.  Only days after a
# ticker's last stored bar are filled, not older gaps.
#
# usage: examples/update_prices.rb [--dry-run] [TICKER...]
#   --dry-run  = report what would change without writing to the database
#   TICKER...  = update only these tickers (default: every ticker stored)
#
# Reads and writes $SQA_DATA_DIR/sqa.db (default ~/sqa_data) via the sqlite3
# command-line tool; all changes are made in one transaction.
# Educational only -- not investment advice.

require "date"
require_relative "add_stocks"

TOLERANCE = 1e-4 # relative difference in the last stored close that still counts as "same"
ATTEMPTS  = 2    # downloads tried per ticker before giving up on it

# ---- what is missing --------------------------------------------------------

# [[ticker, last stored day, close on that day], ...] in alphabetical order.
def last_bars(db)
  sql = "SELECT ticker, MAX(timestamp), close_price FROM prices GROUP BY ticker ORDER BY ticker;"
  query(db, sql).map { |ticker, day, close| [ticker, day, close.to_f] }
end

# The weekdays after `last` ("YYYY-MM-DD") up to and including `today` (a Date).
def missing_weekdays(last, today)
  ((Date.parse(last) + 1)..today).reject { it.saturday? || it.sunday? }.map(&:to_s)
end

# ---- the download -----------------------------------------------------------

def day_start(day) = Time.utc(*day.split("-").map(&:to_i)).to_i

# The chart result for a symbol from `from_day` on, or nil when Yahoo has none
# or cannot be reached.  Unlike download_chart this never aborts, so one bad
# ticker does not stop the whole update.
def recent_result(symbol, from_day, now = Time.now, attempts = ATTEMPTS)
  response = Net::HTTP.get_response(chart_uri(symbol, now, day_start(from_day)), "User-Agent" => "Mozilla/5.0")
  return JSON.parse(response.body).dig("chart", "result", 0) if response.is_a?(Net::HTTPSuccess)
  return nil if attempts <= 1 || response.is_a?(Net::HTTPNotFound)

  sleep PAUSE * 4
  recent_result(symbol, from_day, now, attempts - 1)
rescue SocketError, SystemCallError, Timeout::Error, OpenSSL::SSL::SSLError, JSON::ParserError
  nil
end

# `bars` without the bar of a regular session that has not ended yet.
def completed_bars(result, bars, now = Time.now)
  session = result.dig("meta", "currentTradingPeriod", "regular")
  return bars unless session && now.to_i < session["end"].to_i

  open_day = iso_day(session["start"])
  bars.reject { it[0] == open_day }
end

# ---- the price basis --------------------------------------------------------

# Descriptions of the splits and dividends dated after `last`.
def gap_events(result, last)
  found = splits(result).map { |day, ratio| [day, "split #{ratio}"] } +
          dividends(result).map { |day, amount| [day, "dividend #{amount}"] }
  found.select { |day, _| day > last }.sort.map { |day, what| "#{what} on #{day}" }
end

# What the splits dated after `last` do to earlier share volumes: 4.0 for a 4:1 split.
def volume_factor(result, last)
  (result.dig("events", "splits") || {}).values
                                        .select { iso_day(it["date"]) > last }
                                        .reduce(1.0) { |factor, split| factor * split["numerator"] / split["denominator"] }
end

def same_basis?(ratio, tolerance = TOLERANCE) = (ratio - 1.0).abs <= tolerance

# SQL that rescales a ticker's bars up to `last` by `ratio` (and volumes by `volumes`).
def rescale_sql(ticker, last, ratio, volumes = 1.0)
  prices = %w[open_price high_price low_price close_price adj_close_price].map { "#{it} = ROUND(#{it} * #{ratio}, 6)" }
  prices << "volume = CAST(ROUND(volume * #{volumes}) AS INTEGER)" unless same_basis?(volumes)
  "UPDATE prices SET #{prices.join(', ')} WHERE ticker = #{quoted(ticker)} AND timestamp <= #{quoted(last)};"
end

# ---- one ticker -------------------------------------------------------------

def label(ticker) = ticker.upcase.ljust(7)

def skipped(ticker, why) = { status: :skipped, sql: [], bars: 0, lines: ["#{label(ticker)} ** skipped: #{why}"] }

def touch_sql(ticker, stamp) = "UPDATE stocks SET updated_at = #{quoted(stamp)} WHERE ticker = #{quoted(ticker)};"

# Report lines for a ticker that gains `fresh` bars; `absent` are the missing
# weekdays Yahoo had no bar for, `rescaled` a note when history was rescaled.
def update_lines(ticker, fresh, absent, rescaled)
  days = fresh.size == 1 ? fresh[0][0] : "#{fresh.first[0]} .. #{fresh.last[0]}"
  line = "#{label(ticker)} +#{fresh.size}  #{days}  close #{format('%.2f', fresh.last[4])}"
  line += "  (no bar for #{absent.join(', ')})" unless absent.empty?
  [line, rescaled && "        ** #{rescaled}"].compact
end

# The plan for one ticker given its download: { status:, sql:, bars:, lines: }.
#   last, stored_close = the ticker's last stored day and that day's close
#   today              = last calendar day to store (a Date)
#   stamp              = value for stocks.updated_at
def plan_update(ticker, last, stored_close, result, today, now, stamp)
  bars   = completed_bars(result, adjusted_bars(result), now)
  anchor = bars.find { it[0] == last } or
    return skipped(ticker, "Yahoo has no bar for #{last}, the last stored day, so the price basis cannot be checked")
  fresh = bars.select { it[0] > last && it[0] <= today.to_s }
  return { status: :none, sql: [], bars: 0, lines: ["#{label(ticker)} no new bars since #{last}"] } if fresh.empty?

  ratio  = anchor[4] / stored_close
  events = gap_events(result, last)
  if !same_basis?(ratio) && events.empty?
    return skipped(ticker, "Yahoo's close for #{last} is #{anchor[4]} but #{stored_close} is stored, with no split or dividend since")
  end

  rescale = same_basis?(ratio) ? [] : [rescale_sql(ticker, last, ratio, volume_factor(result, last))]
  note    = rescale.empty? ? nil : "history through #{last} rescaled by #{ratio.round(6)} (#{events.join('; ')})"
  absent  = missing_weekdays(last, today) - fresh.map(&:first)
  { status: :updated, bars: fresh.size, lines: update_lines(ticker, fresh, absent, note),
    sql: [*rescale, *fresh.map { price_sql(ticker, it) }, touch_sql(ticker, stamp)] }
end

# Download and plan one ticker.
def update_ticker(ticker, last, stored_close, today, now)
  result = recent_result(ticker.upcase, last, now)
  return skipped(ticker, "no answer from Yahoo") unless result

  plan_update(ticker, last, stored_close, result, today, now, now.utc.iso8601)
end

# ---- the database -----------------------------------------------------------

# Run the statements in one transaction; nothing is kept if any of them fails.
def apply_sql(db, statements)
  script = "#{['BEGIN;', *statements, 'COMMIT;'].join("\n")}\n"
  out, status = Open3.capture2e("sqlite3", "-bail", db, stdin_data: script)
  abort "sqlite3 failed for #{db}, nothing was changed:\n#{out}" unless status.success?
end

# ---- command line -----------------------------------------------------------

# [dry_run, tickers] from the command-line arguments.
def parse_update_args(args)
  flags, tickers = args.partition { it.start_with?("--") }
  abort "usage: #{$PROGRAM_NAME} [--dry-run] [TICKER...]" unless (flags - ["--dry-run"]).empty?
  [flags.include?("--dry-run"), tickers.map(&:downcase)]
end

# The stored tickers to update; unknown names in `wanted` abort.
def chosen_rows(rows, wanted)
  return rows if wanted.empty?

  unknown = wanted - rows.map(&:first)
  abort "not in the database: #{unknown.join(', ')} (add new symbols with add_stocks.rb)" unless unknown.empty?
  rows.select { wanted.include?(it[0]) }
end

def update_summary(plans, current, dry_run)
  counts  = plans.map { it[:status] }.tally
  bars    = plans.sum { it[:bars] }
  outcome = dry_run ? "dry run -- database not changed" : "database updated"
  "#{current} already up to date, #{counts.fetch(:updated, 0)} updated (#{bars} bars), " \
    "#{counts.fetch(:none, 0)} with no new bars, #{counts.fetch(:skipped, 0)} skipped -- #{outcome}"
end

# Update the chosen tickers, yielding each report line as it is ready, and
# return the summary line.
def run_update(db, wanted, dry_run, today = Date.today, now = Time.now)
  behind, current = chosen_rows(last_bars(db), wanted).partition { |_, last, _| missing_weekdays(last, today).any? }
  plans = behind.map do |ticker, last, close|
    plan = update_ticker(ticker, last, close, today, now)
    plan[:lines].each { yield it }
    sleep PAUSE
    plan
  end
  statements = plans.flat_map { it[:sql] }
  apply_sql(db, statements) unless dry_run || statements.empty?
  update_summary(plans, current.size, dry_run)
end

if $PROGRAM_NAME == __FILE__
  dry_run, wanted = parse_update_args(ARGV)
  puts run_update(DB, wanted, dry_run) { puts it }
end
