#!/usr/bin/env ruby
# frozen_string_literal: true

# Do the efficiency ratio and the Choppiness Index tell us where the
# sma_reversion scenario (trading_scenarios.rb) will beat buy & hold?
#
# For every ticker, measures the strategy's excess over buy & hold as
# log(strategy final value / buy & hold final value) -- above 0 the strategy
# won -- for each lookback period, and ranks it against:
#
#   ER10    mean rolling 10-day Kaufman efficiency ratio (low = choppy)
#   CHOP14  mean 14-day Choppiness Index (high = choppy):
#           100 * log10(sum of true ranges / (highest high - lowest low)) / log10(14)
#
# using Spearman rank correlation, in two ways:
#
#   same period  indicator and result both over the --window (hindsight)
#   predictive   indicator over [TRAIN_FROM, TEST_FROM), result from TEST_FROM on
#
# Each is reported for all tickers and, when SUSPECT lists any tickers whose
# price history has a known bad bar, again without them.
#
# usage: examples/indicator_vs_profit.rb [options] [TRAIN_FROM] [TEST_FROM]
#   TRAIN_FROM = YYYY-MM-DD start of the indicator window (default: 2025-01-01)
#   TEST_FROM  = YYYY-MM-DD start of the trading window   (default: 2026-01-01)
#
# options:
#   --window DAYS    limit the same-period comparison to the last DAYS calendar
#                    days before the latest date in the database (default: 730,
#                    two years; "all" for the full history); the predictive
#                    one keeps its own dates
#   --cash DOLLARS   starting cash for every strategy run (default: 10000)
#   -h, --help       show this help
#
# example: examples/indicator_vs_profit.rb --window 1095 2025-06-01 2026-03-01
#
# Reads daily bars from $SQA_DATA_DIR/sqa.db (default ~/sqa_data) via the
# sqlite3 command-line tool.  Educational only -- not investment advice.

require_relative "efficiency_ratio"

CHOP_PERIOD = 14
ER_PERIOD   = 10
SUSPECT     = %w[].freeze # lowercase tickers to also report without, e.g. %w[tds]
DEFAULT_TRAIN_FROM = Date.new(2025, 1, 1)
DEFAULT_TEST_FROM  = Date.new(2026, 1, 1)

# ---- data access ----------------------------------------------------------

# [[Date, high, low, adjusted close], ...] oldest first.
def load_hlc(db, ticker)
  abort "bad ticker #{ticker.inspect}" unless ticker.match?(/\A[a-z0-9.\-^=]+\z/)

  sql = "SELECT timestamp, high_price, low_price, adj_close_price FROM prices WHERE ticker='#{ticker}' " \
        "ORDER BY timestamp;"
  query(db, sql).map { |date, high, low, close| [Date.parse(date), high.to_f, low.to_f, close.to_f] }
end

# ---- indicators -----------------------------------------------------------

# True range of each bar after the first: max(high, prior close) - min(low, prior close).
def true_ranges(bars)
  bars.each_cons(2).map { |(_, _, _, prior), (_, high, low, _)| [high, prior].max - [low, prior].min }
end

# Choppiness Index of one window of bars and its true ranges.
def choppiness(window, ranges)
  span = window.map { it[1] }.max - window.map { it[2] }.min
  return nil unless span.positive?

  100 * Math.log10(ranges.sum / span) / Math.log10(window.size)
end

# Mean Choppiness Index over every window that lies inside bars[first..last]
# (the first true range needs the close of bars[first], so windows end at
# first + period or later).
def mean_chop(bars, first, last, period = CHOP_PERIOD)
  ranges = true_ranges(bars) # ranges[i] belongs to bars[i + 1]
  values = ((first + period)..last).filter_map do |t|
    choppiness(bars[(t - period + 1)..t], ranges[(t - period)...t])
  end
  mean(values)
end

# Mean rolling efficiency ratio over closes[first..last].
def mean_er(closes, first, last, period = ER_PERIOD) = mean(rolling_er(closes[first..last], period))

# ---- strategy result ------------------------------------------------------

# log(strategy final / buy & hold final) per lookback period, trading from `from` on.
def excess_returns(db, ticker, from = nil, bankroll = BANKROLL)
  summary = ticker_summary(db, ticker, SCENARIOS["sma_reversion"].last, DEFAULT_PERIODS, from, bankroll:)
  summary[:results].map { Math.log(it[:final] / summary[:hold_value]) }
end

# ---- statistics -----------------------------------------------------------

# Rank of each value (0 = smallest), in the original order.
def ranks(values)
  values.each_with_index.sort_by(&:first).each_with_index.with_object(Array.new(values.size)) do |((_, at), rank), out|
    out[at] = rank.to_f
  end
end

def pearson(xs, ys)
  mx  = mean(xs)
  my  = mean(ys)
  cov = xs.zip(ys).sum { |x, y| (x - mx) * (y - my) }
  cov / Math.sqrt(xs.sum { (it - mx)**2 } * ys.sum { (it - my)**2 })
end

def spearman(xs, ys) = pearson(ranks(xs), ranks(ys))

# ---- per-ticker measurements ----------------------------------------------

# Indicators and strategy results for one ticker, or nil when it lacks the
# bars.  The same-period measures cover bars from `from` on (nil: all of them).
def ticker_measures(db, ticker, train_from, test_from, from: nil, bankroll: BANKROLL)
  bars   = load_hlc(db, ticker)
  closes = bars.map(&:last)
  dates  = bars.map(&:first)
  first  = start_index(dates, from)
  train  = dates.bsearch_index { it >= train_from }
  test   = dates.bsearch_index { it >= test_from }
  return nil unless first && train && test && test - train > CHOP_PERIOD && bars.size - first > CHOP_PERIOD

  last = bars.size - 1
  { ticker:, er_all: mean_er(closes, first, last), chop_all: mean_chop(bars, first, last),
    er_train: mean_er(closes, train, test - 1), chop_train: mean_chop(bars, train, test - 1),
    excess_all: excess_returns(db, ticker, from, bankroll), excess_test: excess_returns(db, ticker, test_from, bankroll) }
end

# ---- reporting ------------------------------------------------------------

# [label, indicator key, result key]
CORRELATIONS = [
  ["same-period ER10   vs same-period result", :er_all, :excess_all],
  ["same-period CHOP14 vs same-period result", :chop_all, :excess_all],
  ["training ER10   vs test result", :er_train, :excess_test],
  ["training CHOP14 vs test result", :chop_train, :excess_test]
].freeze

def correlation_line(rows, label, indicator, result)
  cells = DEFAULT_PERIODS.each_with_index.map do |period, index|
    rho = spearman(rows.map { it[indicator] }, rows.map { it[result][index] })
    "#{"#{period}-day".rjust(7)} #{format('%+.2f', rho)}"
  end
  "  #{label.ljust(42)}#{cells.join('   ')}"
end

def correlation_block(name, rows)
  ["#{name} (#{rows.size} tickers): Spearman rank correlation with strategy excess over buy & hold",
   *CORRELATIONS.map { |label, indicator, result| correlation_line(rows, label, indicator, result) }]
end

def best_period(excess) = DEFAULT_PERIODS[excess.each_with_index.max_by(&:first).last]

def ticker_line(row)
  excess = row[:excess_test].map { format("%+.2f", it).rjust(6) }.join(" ")
  [row[:ticker].upcase.ljust(6), format("%.3f", row[:er_train]).rjust(8), format("%.1f", row[:chop_train]).rjust(8),
   " | #{excess} | ", "#{best_period(row[:excess_test])}-day"].join(" ")
end

# Per-ticker table, choppiest first by training-window CHOP14.
def ticker_table(rows)
  heading = "#{'ticker'.ljust(6)} #{'ER10'.rjust(8)} #{'CHOP14'.rjust(8)}  | " \
            "#{DEFAULT_PERIODS.map { "#{it}d".rjust(6) }.join(' ')} |  best"
  [heading, *rows.sort_by { -it[:chop_train] }.map { ticker_line(it) }]
end

# The correlation block for all tickers, plus one without the suspect tickers
# when there are any.
def correlation_blocks(rows, suspect = SUSPECT)
  blocks = [correlation_block("all tickers", rows)]
  unless suspect.empty?
    clean = rows.reject { suspect.include?(it[:ticker]) }
    blocks << correlation_block("without #{suspect.join(', ').upcase}", clean)
  end
  blocks.map { it.join("\n") }.join("\n\n")
end

def report(rows, train_from, test_from, from = nil)
  <<~REPORT
    same period: #{from ? "#{from} on" : 'each full history'}
    training window #{train_from} .. #{test_from - 1}, test window #{test_from} on
    excess = log(strategy final / buy & hold final); above 0 the strategy won

    #{correlation_blocks(rows)}

    per ticker -- indicators over the training window, excess over the test window:
    #{ticker_table(rows).join("\n")}
  REPORT
end

# ---- command line ---------------------------------------------------------

def run(db, train_from, test_from, from: nil, bankroll: BANKROLL)
  abort "TRAIN_FROM must be before TEST_FROM" unless train_from < test_from

  rows = all_tickers(db).filter_map { ticker_measures(db, it, train_from, test_from, from:, bankroll:) }
  report(rows, train_from, test_from, from)
end

if $PROGRAM_NAME == __FILE__
  options    = parse_demo_options(ARGV, __FILE__, window: true, cash: true)
  train_from = ARGV[0] ? parse_date(ARGV[0]) : DEFAULT_TRAIN_FROM
  test_from  = ARGV[1] ? parse_date(ARGV[1]) : DEFAULT_TEST_FROM
  from       = analysis_start(nil, options[:window]) { latest_day(DB) }
  puts run(DB, train_from, test_from, from:, bankroll: options.fetch(:cash, BANKROLL))
end
