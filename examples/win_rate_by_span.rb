#!/usr/bin/env ruby
# frozen_string_literal: true

# Buy-and-hold win rate by holding span.
#
# For every trading day in a ticker's history, buy at the close, hold for the
# given span, sell at the close, and report how often that made money.
#
# usage: examples/win_rate_by_span.rb [TICKER|all] [SPAN...] [FROM]
#   TICKER = a symbol with price history (default: nvda), or "all" for a
#            one-line-per-ticker comparison of every symbol in the database
#   SPAN   = <n>y | <n>m | <n>w | <n>d  (calendar time; default: 1y 6m 3m 6w 3w)
#   FROM   = YYYY-MM-DD; only use bars on or after this date, so every entry
#            and exit falls in that window (default: the whole history)
#
# Reads daily bars from $SQA_DATA_DIR/sqa.db (default ~/sqa_data) via the
# sqlite3 command-line tool.  Educational only -- not investment advice.

require "csv"
require "date"
require "open3"

DB            = File.join(ENV.fetch("SQA_DATA_DIR", File.expand_path("~/sqa_data")), "sqa.db")
DEFAULT_SPANS = %w[1y 6m 3m 6w 3w].freeze
DEEP_DRAWDOWN = -0.2

# Detail-table columns: [heading, statistic, width of the number].
DETAIL_COLUMNS = [
  ["win%", :win_rate, 7], ["median", :median, 7], ["mean", :mean, 7],
  ["avg win", :avg_win, 7], ["avg loss", :avg_loss, 7], ["worst", :min, 7],
  ["best", :max, 7], ["never up%", :never_up, 8], ["dd>=20%", :deep_drawdown, 7]
].freeze

# Comparison-table blocks: [title, statistic, include in the mean row].
COMPARISON_BLOCKS = [
  ["win rate %", :win_rate, true], ["median return %", :median, true], ["worst return %", :min, false]
].freeze

# ---- data access ----------------------------------------------------------

def query(db, sql)
  out, status = Open3.capture2("sqlite3", "-readonly", "-csv", db, sql)
  abort "sqlite3 failed for #{db}" unless status.success?
  CSV.parse(out)
end

# Every ticker that has price history, in alphabetical order.
def all_tickers(db) = query(db, "SELECT DISTINCT ticker FROM prices ORDER BY ticker;").flatten

# [[Date, adjusted close], ...] oldest first.
def load_bars(db, ticker)
  abort "bad ticker #{ticker.inspect}" unless ticker.match?(/\A[a-z0-9.\-^=]+\z/)

  sql = "SELECT timestamp, adj_close_price FROM prices WHERE ticker='#{ticker}' ORDER BY timestamp;"
  query(db, sql).map { |date, close| [Date.parse(date), close.to_f] }
end

# ---- analysis -------------------------------------------------------------

def advance(date, span)
  count = span.to_i
  case span[-1]
  when "y" then date >> (12 * count)
  when "m" then date >> count
  when "w" then date + (7 * count)
  when "d" then date + count
  else abort "bad span #{span.inspect} (want <n>y, <n>m, <n>w or <n>d)"
  end
end

# For each entry bar, the index of the first bar on or after entry date + span
# (nil when the history ends first).
def exit_indexes(dates, span) = dates.map { |date| dates.bsearch_index { it >= advance(date, span) } }

# One hash per entry that has an exit: the return at the exit, plus the best
# and worst closing return seen while holding.
def trade_outcomes(closes, exits)
  exits.each_with_index.filter_map do |exit_at, entry|
    next unless exit_at

    cost   = closes[entry]
    window = closes[(entry + 1)..exit_at]
    { final: (closes[exit_at] / cost) - 1.0, best: (window.max / cost) - 1.0, worst: (window.min / cost) - 1.0 }
  end
end

# Mean of values as a percentage; NaN when there are none (e.g. no losing entries).
def average_pct(values) = values.empty? ? Float::NAN : values.sum / values.size * 100

# Percentage of items for which the block is true.
def share_pct(items, &) = items.count(&) * 100.0 / items.size

def return_stats(returns)
  sorted = returns.sort
  { entries: returns.size, win_rate: share_pct(returns, &:positive?),
    median: sorted[sorted.size / 2] * 100, mean: average_pct(returns),
    min: sorted.first * 100, max: sorted.last * 100,
    avg_win: average_pct(returns.select(&:positive?)),
    avg_loss: average_pct(returns.reject(&:positive?)) }
end

def path_stats(outcomes)
  { never_up: share_pct(outcomes) { !it[:best].positive? },
    deep_drawdown: share_pct(outcomes) { it[:worst] <= DEEP_DRAWDOWN } }
end

# Statistics for one holding span, or nil when the history is shorter than the span.
def analyze(dates, closes, span)
  outcomes = trade_outcomes(closes, exit_indexes(dates, span))
  return nil if outcomes.empty?

  return_stats(outcomes.map { it[:final] }).merge(path_stats(outcomes))
end

# The bars dated on or after `from` (all of them when from is nil).
def bars_since(bars, from) = from ? bars.drop_while { |date, _| date < from } : bars

# { ticker:, bars:, from:, to:, stats: [analyze result or nil per span] }
def ticker_summary(db, ticker, spans, from = nil)
  bars   = bars_since(load_bars(db, ticker), from)
  dates  = bars.map(&:first)
  closes = bars.map(&:last)
  { ticker:, bars: bars.size, from: dates.first, to: dates.last,
    stats: spans.map { analyze(dates, closes, it) } }
end

# ---- reporting ------------------------------------------------------------

# A number to one decimal, right-aligned; "n/a" when there is no value.
def cell(value, width = 7) = (value ? format("%.1f", value) : "n/a").rjust(width)

def detail_row(span, stats)
  return "#{span.ljust(6)} #{'0'.rjust(7)}  (not enough history)" unless stats

  values = DETAIL_COLUMNS.map { |_, key, width| "#{cell(stats[key], width)}%" }
  [span.ljust(6), stats[:entries].to_s.rjust(7), *values].join(" ")
end

# Detailed table: one row per span for a single ticker.
def detail_report(summary, spans)
  headings = DETAIL_COLUMNS.map { |title, _, width| title.rjust(width + 1) }
  [
    "#{summary[:ticker].upcase}  #{summary[:bars]} bars  #{summary[:from]} .. #{summary[:to]}",
    ["hold".ljust(6), "entries".rjust(7), *headings].join(" "),
    *spans.zip(summary[:stats]).map { |span, stats| detail_row(span, stats) }
  ].join("\n")
end

# One statistic across every span, as fixed-width columns.
def span_cells(stats, key) = stats.map { cell(it&.fetch(key)) }.join

# Mean of a statistic across tickers for each span, skipping tickers without enough history.
def column_means(summaries, span_count, key)
  (0...span_count).map do |index|
    values = summaries.filter_map { it[:stats][index]&.fetch(key) }
    values.empty? ? nil : values.sum / values.size
  end
end

def ticker_label(summary) = "#{summary[:ticker].upcase.ljust(6)} #{summary[:bars].to_s.rjust(5)} #{summary[:from]}"

def comparison_row(summary)
  [ticker_label(summary), *COMPARISON_BLOCKS.map { |_, key, _| span_cells(summary[:stats], key) }].join(" | ")
end

def comparison_header(spans)
  columns = spans.map { it.rjust(7) }.join
  label   = "#{'ticker'.ljust(6)} #{'bars'.rjust(5)} #{'from'.ljust(10)}"
  [[" " * label.size, *COMPARISON_BLOCKS.map { |title, _, _| title.center(columns.size) }].join(" | "),
   [label, *COMPARISON_BLOCKS.map { columns }].join(" | ")]
end

def comparison_means(summaries, span_count)
  blocks = COMPARISON_BLOCKS.select(&:last).map do |_, key, _|
    column_means(summaries, span_count, key).map { cell(it) }.join
  end
  ["mean of #{summaries.size} tickers".ljust(23), *blocks].join(" | ")
end

# Comparison table: one row per ticker, sorted by win rate on the first span.
def comparison_report(summaries, spans)
  ranked = summaries.sort_by { -(it[:stats].first&.fetch(:win_rate) || -1) }
  [*comparison_header(spans), *ranked.map { comparison_row(it) }, comparison_means(summaries, spans.size)].join("\n")
end

# ---- command line ---------------------------------------------------------

def run(db, ticker, spans, from = nil)
  if ticker == "all"
    summaries = all_tickers(db).map { ticker_summary(db, it, spans, from) }.reject { it[:bars].zero? }
    return comparison_report(summaries, spans)
  end

  summary = ticker_summary(db, ticker, spans, from)
  abort "no price history for #{ticker.upcase} #{"on or after #{from} " if from}in #{db}" if summary[:bars].zero?
  detail_report(summary, spans)
end

def parse_date(text)
  Date.iso8601(text)
rescue Date::Error
  abort "bad date #{text.inspect} (want YYYY-MM-DD)"
end

# Split arguments after the ticker into [spans, from date or nil].
def parse_options(args)
  dates, spans = args.partition { it.match?(/\A\d{4}-\d{2}-\d{2}\z/) }
  [spans.empty? ? DEFAULT_SPANS : spans, dates.first&.then { parse_date(it) }]
end

puts run(DB, (ARGV[0] || "nvda").downcase, *parse_options(ARGV[1..].to_a)) if $PROGRAM_NAME == __FILE__
