#!/usr/bin/env ruby
# frozen_string_literal: true

# Simple trading scenarios, each starting with a $10,000 bankroll per stock.
#
# Every scenario builds a signal rule for a lookback period: given the closes
# up to today, the rule returns :buy, :sell or nil.  The simulator trades at
# today's close in whole shares only -- a :buy spends as much cash as whole
# shares allow (when flat), a :sell liquidates the whole position (when
# holding).  Leftover cash stays in the bank; any open position is valued at
# the last close.  Results are compared against buying and holding whole
# shares with the same $10,000.
#
# usage: examples/trading_scenarios.rb [TICKER|all] [PERIOD...] [SCENARIO]
#   TICKER   = a symbol with price history (default: nvda), or "all" for a
#              one-line-per-ticker comparison of every symbol in the database
#   PERIOD   = lookback in trading days (default: 5 10 15)
#   SCENARIO = a scenario name (default: sma_reversion); see SCENARIOS below
#
# Reads daily bars from $SQA_DATA_DIR/sqa.db (default ~/sqa_data) via the
# sqlite3 command-line tool.  Educational only -- not investment advice.

require "csv"
require "date"
require "open3"

DB              = File.join(ENV.fetch("SQA_DATA_DIR", File.expand_path("~/sqa_data")), "sqa.db")
BANKROLL        = 10_000.0
DEFAULT_PERIODS = [5, 10, 15].freeze

# ---- scenarios ------------------------------------------------------------

# Mean of the `period` closes before index `today` (today's close excluded);
# nil until there are that many.
def prior_average(closes, today, period)
  return nil if today < period

  closes[(today - period)...today].sum / period
end

# Buy when the close is below the average of the previous `period` closes,
# sell when it is above.
def sma_reversion_signal(closes, today, period)
  average = prior_average(closes, today, period)
  return nil unless average

  close = closes[today]
  if close < average then :buy
  elsif close > average then :sell
  end
end

# name => [description, builder: period -> rule(closes, today)]
SCENARIOS = {
  "sma_reversion" => ["Buy below / sell above the prior N-day average close",
                      ->(period) { ->(closes, today) { sma_reversion_signal(closes, today, period) } }]
}.freeze

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

# ---- simulation -----------------------------------------------------------

# Account state after acting on one signal at `price`.  Returns
# [cash, shares, trade or nil]; a trade is { side:, index:, shares:, price: }.
def apply_signal(signal, cash, shares, price, index)
  if signal == :buy && shares.zero?
    bought = (cash / price).floor
    return [cash, shares, nil] if bought.zero?

    [cash - (bought * price), bought, { side: :buy, index:, shares: bought, price: }]
  elsif signal == :sell && shares.positive?
    [cash + (shares * price), 0, { side: :sell, index:, shares:, price: }]
  else
    [cash, shares, nil]
  end
end

# Run a signal rule over the closes.  Returns { cash:, shares:, trades: }.
def simulate(closes, rule, bankroll = BANKROLL)
  cash   = bankroll
  shares = 0
  trades = []
  closes.each_index do |today|
    cash, shares, trade = apply_signal(rule.call(closes, today), cash, shares, closes[today], today)
    trades << trade if trade
  end
  { cash:, shares:, trades: }
end

# Pair each buy with the sell that follows it: [[buy, sell], ...].  A final
# unmatched buy (position still open) is left out.
def round_trips(trades) = trades.each_slice(2).select { it.size == 2 }

# Percent gain of each completed round trip.
def trip_returns(trades) = round_trips(trades).map { |buy, sell| ((sell[:price] / buy[:price]) - 1.0) * 100 }

# Value of $bankroll put into whole shares on the first close and held.
def buy_and_hold_value(closes, bankroll = BANKROLL)
  shares = (bankroll / closes.first).floor
  bankroll - (shares * closes.first) + (shares * closes.last)
end

def pct_change(value, bankroll = BANKROLL) = ((value / bankroll) - 1.0) * 100

def mean_or_nil(values) = values.empty? ? nil : values.sum / values.size

# Ending account and trade statistics for one lookback period.
def period_result(closes, rule, period)
  result  = simulate(closes, rule)
  stock   = result[:shares] * closes.last
  final   = result[:cash] + stock
  returns = trip_returns(result[:trades])
  { period:, shares: result[:shares], cash: result[:cash], stock:, final:,
    strategy_pct: pct_change(final), trips: returns.size,
    win_rate: mean_or_nil(returns.map { it.positive? ? 100.0 : 0.0 }),
    avg_trip: mean_or_nil(returns), trades: result[:trades] }
end

# { ticker:, bars:, from:, to:, last_close:, hold_pct:, dates:, results: [period_result...] }
def ticker_summary(db, ticker, builder, periods)
  bars   = load_bars(db, ticker)
  closes = bars.map(&:last)
  return { ticker:, bars: 0 } if closes.empty?

  { ticker:, bars: bars.size, from: bars.first.first, to: bars.last.first, last_close: closes.last,
    hold_pct: pct_change(buy_and_hold_value(closes)), dates: bars.map(&:first),
    results: periods.map { period_result(closes, builder.call(it), it) } }
end

# ---- reporting ------------------------------------------------------------

def money(value) = format("$%.2f", value).gsub(/(\d)(?=(\d{3})+\.)/, '\1,')

def pct(value, width = 8, sign: true)
  return "n/a".rjust(width) unless value

  format(sign ? "%+.1f%%" : "%.1f%%", value).rjust(width)
end

# [heading, value formatter, width]
DETAIL_COLUMNS = [
  ["days", ->(r) { r[:period].to_s }, 4],
  ["shares held", ->(r) { r[:shares].to_s }, 11],
  ["bank (cash)", ->(r) { money(r[:cash]) }, 14],
  ["stock value", ->(r) { money(r[:stock]) }, 15],
  ["total value", ->(r) { money(r[:final]) }, 15],
  ["return", ->(r) { pct(r[:strategy_pct]) }, 10],
  ["trips", ->(r) { r[:trips].to_s }, 6],
  ["win%", ->(r) { pct(r[:win_rate], sign: false) }, 7],
  ["avg trip", ->(r) { pct(r[:avg_trip]) }, 9]
].freeze

def table_line(cells) = cells.zip(DETAIL_COLUMNS).map { |text, (_, _, width)| text.rjust(width) }.join("  ")

# The last few trades of one period, oldest first, to show what the rule did.
def recent_trades(summary, result, count = 4)
  result[:trades].last(count).map do |trade|
    date = summary[:dates][trade[:index]]
    "    #{date}  #{trade[:side].to_s.ljust(4)} #{trade[:shares].to_s.rjust(7)} @ #{money(trade[:price]).rjust(10)}"
  end
end

# Detailed report for a single ticker: one row per lookback period.
def detail_report(summary, name, description)
  results = summary[:results]
  trades  = results.flat_map { ["  #{it[:period]}-day:", *recent_trades(summary, it)] }
  <<~REPORT
    #{summary[:ticker].upcase}  #{summary[:bars]} bars  #{summary[:from]} .. #{summary[:to]}  last close #{money(summary[:last_close])}
    scenario: #{name} -- #{description}
    starting bankroll #{money(BANKROLL)}   buy & hold return #{pct(summary[:hold_pct]).strip}

    #{table_line(DETAIL_COLUMNS.map(&:first))}
    #{results.map { |result| table_line(DETAIL_COLUMNS.map { |_, fmt, _| fmt.call(result) }) }.join("\n")}

    last trades:
    #{trades.join("\n")}
  REPORT
end

# Comparison cells for one period: shares, bank cash, total value, return.
PERIOD_WIDTHS = [8, 15, 15, 11].freeze

def period_cells(result)
  [result[:shares].to_s, money(result[:cash]), money(result[:final]), pct(result[:strategy_pct])]
    .zip(PERIOD_WIDTHS).map { |text, width| text.rjust(width) }.join
end

def comparison_header(periods)
  block  = %w[shares bank total return].zip(PERIOD_WIDTHS).map { |text, width| text.rjust(width) }.join
  label  = "#{'ticker'.ljust(6)} #{'buy&hold'.rjust(11)}"
  titles = periods.map { "#{it}-day average".center(block.size) }
  [[" " * label.size, *titles].join(" | "), [label, *periods.map { block }].join(" | ")]
end

def comparison_row(summary)
  [
    "#{summary[:ticker].upcase.ljust(6)} #{pct(summary[:hold_pct], 11)}",
    *summary[:results].map { period_cells(it) }
  ].join(" | ")
end

# How many tickers each period's strategy beat buy & hold on.
def beat_counts(summaries, periods)
  periods.each_with_index.map do |period, index|
    beat = summaries.count { it[:results][index][:strategy_pct] > it[:hold_pct] }
    "#{period}-day beat buy & hold on #{beat} of #{summaries.size}"
  end.join(";  ")
end

# Comparison table: one row per ticker, ranked by the first period's total value.
def comparison_report(summaries, periods, name, description)
  usable = summaries.reject { it[:bars].zero? }
  [
    "scenario: #{name} -- #{description}  (#{money(BANKROLL)} per stock, whole shares)",
    *comparison_header(periods),
    *usable.sort_by { -it[:results].first[:final] }.map { comparison_row(it) },
    beat_counts(usable, periods)
  ].join("\n")
end

# ---- command line ---------------------------------------------------------

# Split arguments after the ticker into [periods, scenario name].
def parse_options(args)
  periods, names = args.partition { it.match?(/\A\d+\z/) }
  periods = periods.map(&:to_i)
  abort "periods must be at least 1" if periods.any?(&:zero?)
  [periods.empty? ? DEFAULT_PERIODS : periods, names.first || SCENARIOS.keys.first]
end

def run(db, ticker, periods, scenario)
  description, builder = SCENARIOS.fetch(scenario) do
    abort "unknown scenario #{scenario.inspect} (have: #{SCENARIOS.keys.join(', ')})"
  end
  if ticker == "all"
    summaries = all_tickers(db).map { ticker_summary(db, it, builder, periods) }
    return comparison_report(summaries, periods, scenario, description)
  end

  summary = ticker_summary(db, ticker, builder, periods)
  abort "no price history for #{ticker.upcase} in #{db}" if summary[:bars].zero?
  detail_report(summary, scenario, description)
end

puts run(DB, (ARGV[0] || "nvda").downcase, *parse_options(ARGV[1..].to_a)) if $PROGRAM_NAME == __FILE__
