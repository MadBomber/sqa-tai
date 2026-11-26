#!/usr/bin/env ruby
# frozen_string_literal: true

# Kaufman efficiency ratio per ticker, next to how often the sma_reversion
# scenario in trading_scenarios.rb beat buy & hold.
#
#   ER = |close[t] - close[t-n]| / sum(|close[i] - close[i-1]|) over the n steps
#
# Reported as the mean of the rolling n-day ER across the whole history
# (1 = every move in the same direction, 0 = pure back-and-forth), plus the
# whole-history ER and the daily volatility of returns.  For a random walk
# the expected rolling ER is about 1 / sqrt(n): 0.447, 0.316, 0.258 for
# n = 5, 10, 15.  The whole-history ER shrinks as the history grows, so it
# does not compare across tickers of different ages.
#
# usage: examples/efficiency_ratio.rb
#
# Reads daily bars from $SQA_DATA_DIR/sqa.db (default ~/sqa_data) via the
# sqlite3 command-line tool.  Educational only -- not investment advice.

require_relative "trading_scenarios"

WINDOWS = [5, 10, 15].freeze

# Rolling n-step efficiency ratios; windows with no movement are skipped.
def rolling_er(closes, window)
  moves  = closes.each_cons(2).map { |a, b| (b - a).abs }
  prefix = moves.each_with_object([0.0]) { |m, acc| acc << (acc.last + m) }
  (window...closes.size).filter_map do |t|
    path = prefix[t] - prefix[t - window]
    (closes[t] - closes[t - window]).abs / path if path.positive?
  end
end

def mean(values) = values.sum / values.size

def daily_volatility(closes)
  returns = closes.each_cons(2).map { |a, b| (b / a) - 1.0 }
  avg = mean(returns)
  Math.sqrt(returns.sum { (it - avg)**2 } / (returns.size - 1)) * 100
end

# The row for one ticker, or nil when its history is too short (or too flat)
# to give a ratio for every window.
def ticker_row(db, ticker)
  closes = load_bars(db, ticker).map(&:last)
  ratios = WINDOWS.map { rolling_er(closes, it) }
  return nil if ratios.any?(&:empty?)

  summary = ticker_summary(db, ticker, SCENARIOS["sma_reversion"].last, DEFAULT_PERIODS)
  beat    = summary[:results].count { it[:strategy_pct] > summary[:hold_pct] }
  { ticker:, bars: closes.size, ers: ratios.map { mean(it) },
    whole: rolling_er(closes, closes.size - 1).first, vol: daily_volatility(closes), beat: }
end

# [rows, tickers left out for lack of history].
def ticker_rows(db, tickers)
  rows = tickers.to_h { [it, ticker_row(db, it)] }
  [rows.values.compact, rows.select { |_, row| row.nil? }.keys]
end

# ---- reporting ------------------------------------------------------------

def header_line
  ["ticker".ljust(6), "bars".rjust(5), *WINDOWS.map { "ER #{it}d".rjust(7) },
   "ER whole".rjust(9), "vol/day".rjust(8), "beat b&h"].join("  ")
end

def row_line(row)
  [row[:ticker].upcase.ljust(6), row[:bars].to_s.rjust(5), *row[:ers].map { format("%.3f", it).rjust(7) },
   format("%.4f", row[:whole]).rjust(9), "#{format('%.2f', row[:vol])}%".rjust(8), "#{row[:beat]} of 3"].join("  ")
end

# Mean 10-day ER of a group of rows, or "n/a" when the group is empty.
def group_er(rows) = rows.empty? ? "n/a" : format("%.3f", mean(rows.map { it[:ers][1] }))

# Table sorted choppiest first (lowest 10-day ER), then the mean ER of the
# tickers where the strategy ever beat buy & hold versus where it never did.
# `skipped` lists the tickers left out for lack of history.
def report(rows, skipped = [])
  sorted = rows.sort_by { it[:ers][1] }
  won, lost = rows.partition { it[:beat].positive? }
  omitted = skipped.empty? ? "" : "left out, fewer than #{WINDOWS.max + 1} bars: #{skipped.map(&:upcase).join(', ')}\n"
  <<~REPORT
    #{header_line}
    #{sorted.map { row_line(it) }.join("\n")}

    mean 10-day ER where the strategy beat buy & hold at least once: #{group_er(won)} (#{won.size} tickers)
    mean 10-day ER where it never did:                              #{group_er(lost)} (#{lost.size} tickers)
    #{omitted}
  REPORT
end

puts report(*ticker_rows(DB, all_tickers(DB))) if $PROGRAM_NAME == __FILE__
