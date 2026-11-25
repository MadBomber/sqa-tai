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
#   same period  indicator and result both over the full history (hindsight)
#   predictive   indicator over [TRAIN_FROM, TEST_FROM), result from TEST_FROM on
#
# Each is reported for all tickers and again without the tickers in SUSPECT,
# whose price history has a known bad bar.
#
# usage: examples/indicator_vs_profit.rb [TRAIN_FROM] [TEST_FROM]
#   TRAIN_FROM = YYYY-MM-DD start of the indicator window (default: 2025-01-01)
#   TEST_FROM  = YYYY-MM-DD start of the trading window   (default: 2026-01-01)
#
# Reads daily bars from $SQA_DATA_DIR/sqa.db (default ~/sqa_data) via the
# sqlite3 command-line tool.  Educational only -- not investment advice.

require_relative "efficiency_ratio"

CHOP_PERIOD = 14
ER_PERIOD   = 10
SUSPECT     = %w[tds].freeze # TDS 2005-05-16 adjusted close jumps 40x in one day
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
def excess_returns(db, ticker, from = nil)
  summary = ticker_summary(db, ticker, SCENARIOS["sma_reversion"].last, DEFAULT_PERIODS, from)
  hold    = BANKROLL * (1 + (summary[:hold_pct] / 100))
  summary[:results].map { Math.log(it[:final] / hold) }
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

def ticker_measures(db, ticker, train_from, test_from)
  bars   = load_hlc(db, ticker)
  closes = bars.map(&:last)
  dates  = bars.map(&:first)
  train  = dates.bsearch_index { it >= train_from }
  test   = dates.bsearch_index { it >= test_from }
  return nil unless train && test && test - train > CHOP_PERIOD

  { ticker:, er_all: mean_er(closes, 0, closes.size - 1), chop_all: mean_chop(bars, 0, bars.size - 1),
    er_train: mean_er(closes, train, test - 1), chop_train: mean_chop(bars, train, test - 1),
    excess_all: excess_returns(db, ticker), excess_test: excess_returns(db, ticker, test_from) }
end

# ---- reporting ------------------------------------------------------------

# [label, indicator key, result key]
CORRELATIONS = [
  ["full-history ER10   vs full history", :er_all, :excess_all],
  ["full-history CHOP14 vs full history", :chop_all, :excess_all],
  ["training ER10   vs test result", :er_train, :excess_test],
  ["training CHOP14 vs test result", :chop_train, :excess_test]
].freeze

def correlation_line(rows, label, indicator, result)
  cells = DEFAULT_PERIODS.each_with_index.map do |period, index|
    rho = spearman(rows.map { it[indicator] }, rows.map { it[result][index] })
    "#{"#{period}-day".rjust(7)} #{format('%+.2f', rho)}"
  end
  "  #{label.ljust(38)}#{cells.join('   ')}"
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

def report(rows, train_from, test_from)
  clean = rows.reject { SUSPECT.include?(it[:ticker]) }
  <<~REPORT
    training window #{train_from} .. #{test_from - 1}, test window #{test_from} on
    excess = log(strategy final / buy & hold final); above 0 the strategy won

    #{correlation_block('all tickers', rows).join("\n")}

    #{correlation_block("without #{SUSPECT.join(', ').upcase}", clean).join("\n")}

    per ticker -- indicators over the training window, excess over the test window:
    #{ticker_table(rows).join("\n")}
  REPORT
end

# ---- command line ---------------------------------------------------------

def run(db, train_from, test_from)
  abort "TRAIN_FROM must be before TEST_FROM" unless train_from < test_from

  report(all_tickers(db).filter_map { ticker_measures(db, it, train_from, test_from) }, train_from, test_from)
end

if $PROGRAM_NAME == __FILE__
  train_from = ARGV[0] ? parse_date(ARGV[0]) : DEFAULT_TRAIN_FROM
  test_from  = ARGV[1] ? parse_date(ARGV[1]) : DEFAULT_TEST_FROM
  puts run(DB, train_from, test_from)
end
