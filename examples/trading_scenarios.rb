#!/usr/bin/env ruby
# frozen_string_literal: true

# Simple trading scenarios, each starting with the same cash per stock
# (default $10,000).
#
# Every scenario builds a signal rule for a number N (usually a lookback in
# trading days): given the closes up to today, the rule returns :buy, :sell or
# nil.  The simulator trades at today's close in whole shares only -- a :buy
# spends as much cash as whole shares allow while leaving at least $1 in the
# bank (when flat), a :sell liquidates the whole position (when holding).
# Leftover cash stays in the bank; any open position is valued at the last
# close.  There are no trading costs.  Results are compared against buying
# and holding whole shares with the same starting cash.
#
# Scenarios (N defaults in brackets):
#   sma_reversion        buy below / sell above the prior N-day average [5 10 15]
#   sma_trend            buy above / sell below the prior N-day average [50 100 200]
#   sma_cross            hold while the N-day average is above the 4N-day one [10 20 50]
#   breakout             buy a new N-day high, sell a new N/2-day low [20 55 100]
#   momentum             hold while the close is above the close N days ago [63 126 252]
#   rsi_reversion        buy when the N-day RSI is under 30, sell over 70 [2 5 14]
#   bollinger_reversion  buy under the lower N-day band, sell over the average [10 20 50]
#   macd                 hold while MACD (fast N) is above its signal line [6 12 24]
#   turn_of_month        buy a month's last day, sell the next month's Nth day [1 3 5]
#   sell_in_may          hold the N months starting in November [4 6 8]
# All work from one stock's daily closes (and dates).  Strategies that rank
# many stocks against each other, pair two stocks, or need fundamentals or
# earnings dates do not fit this one-stock simulator and are not here.
#
# usage: examples/trading_scenarios.rb [options] [TICKER|all] [N...] [FROM] [SCENARIO]
#   TICKER   = a symbol with price history (default: nvda), or "all" for a
#              one-line-per-ticker comparison of every symbol in the database
#   N        = one or more values for the scenario's number (default: see above)
#   FROM     = YYYY-MM-DD; start trading (and buy & hold) on the first bar on
#              or after this date, instead of using --window.  Closes before
#              the start still feed the rule, so signals start at once.
#   SCENARIO = a scenario name (default: sma_reversion)
#
# options:
#   --window DAYS    trade only the last DAYS calendar days before the latest
#                    date in the database (default: 730, two years); "all"
#                    trades the whole history
#   --cash DOLLARS   starting cash in the bank (default: 10000)
#   -h, --help       show this help
#
# examples: examples/trading_scenarios.rb amd momentum --window 365
#           examples/trading_scenarios.rb all breakout 20 55 --cash 2500
#           examples/trading_scenarios.rb nvda sma_trend --window all
#
# Reads daily bars from $SQA_DATA_DIR/sqa.db (default ~/sqa_data) via the
# sqlite3 command-line tool.  Educational only -- not investment advice.

require "csv"
require "date"
require "open3"
require_relative "demo_options"

DB              = File.join(ENV.fetch("SQA_DATA_DIR", File.expand_path("~/sqa_data")), "sqa.db")
BANKROLL        = 10_000.0 # default starting cash; MIN_BANK (demo_options.rb) is the floor
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

# :buy for a positive value, :sell for a negative one, nil for zero or nil.
def side(value)
  return nil unless value

  if value.positive? then :buy
  elsif value.negative? then :sell
  end
end

# Mean of the `period` closes ending at index `today` (today's close included);
# nil until there are that many.
def average_through(closes, today, period)
  return nil if today + 1 < period

  closes[(today - period + 1)..today].sum / period
end

# Trend following: buy when the close is above the average of the previous
# `period` closes, sell when it is below (Faber's 200-day rule, on daily bars).
def sma_trend_signal(closes, today, period)
  average = prior_average(closes, today, period)
  average && side(closes[today] - average)
end

# Moving-average crossover: buy while the `period`-day average is above the
# average four times as long, sell while below (50 gives the 50/200 "golden
# cross").
def sma_cross_signal(closes, today, period)
  slow = average_through(closes, today, period * 4)
  slow && side(average_through(closes, today, period) - slow)
end

# Channel breakout (Donchian / Turtle rules, on closes): buy on a close above
# the highest of the previous `period` closes, sell on a close below the
# lowest of the previous period/2 closes.
def breakout_signal(closes, today, period)
  return nil if today < period

  exit_span = [period / 2, 1].max
  close     = closes[today]
  if close > closes[(today - period)...today].max then :buy
  elsif close < closes[(today - exit_span)...today].min then :sell
  end
end

# Time-series momentum: buy while the close is above the close `period` days
# ago, sell while below (252 is the usual 12 months).
def momentum_signal(closes, today, period)
  return nil if today < period

  side(closes[today] - closes[today - period])
end

# Relative strength index over the last `period` close-to-close changes,
# using plain averages of the gains and losses (Cutler's form of Wilder's
# RSI); nil until there are enough bars or when the price has not moved.
def simple_rsi(closes, today, period)
  return nil if today < period

  changes = closes[(today - period)..today].each_cons(2).map { |before, after| after - before }
  gains   = changes.select(&:positive?).sum
  moved   = changes.sum(&:abs)
  moved.zero? ? nil : 100.0 * gains / moved
end

RSI_LOW  = 30.0
RSI_HIGH = 70.0

# RSI mean reversion: buy when the `period`-day RSI is below RSI_LOW, sell
# when it is above RSI_HIGH.
def rsi_reversion_signal(closes, today, period)
  rsi = simple_rsi(closes, today, period)
  return nil unless rsi

  if rsi < RSI_LOW then :buy
  elsif rsi > RSI_HIGH then :sell
  end
end

BAND_WIDTH = 2.0 # Bollinger band distance from the average, in standard deviations

# [average, standard deviation] of the `period` closes ending at `today`; nil
# until there are that many.
def band_stats(closes, today, period)
  average = average_through(closes, today, period)
  return nil unless average

  window = closes[(today - period + 1)..today]
  [average, Math.sqrt(window.sum { (it - average)**2 } / period)]
end

# Bollinger band reversion: buy on a close below the lower band, sell on a
# close above the middle band (the `period`-day average).
def bollinger_reversion_signal(closes, today, period)
  average, deviation = band_stats(closes, today, period)
  return nil unless average

  close = closes[today]
  if close < average - (BAND_WIDTH * deviation) then :buy
  elsif close > average then :sell
  end
end

# Exponential moving average of every value, seeded with the first one.
def ema_series(values, period)
  weight = 2.0 / (period + 1)
  values.each_with_object([]) { |value, out| out << (out.empty? ? value : out.last + (weight * (value - out.last))) }
end

# [fast, slow, signal] spans in the classic 12/26/9 proportions for a fast span.
def macd_spans(period) = [period, [(period * 26 / 12.0).round, period + 1].max, [(period * 9 / 12.0).round, 1].max]

# MACD line minus its signal line for every bar.
def macd_gaps(closes, fast, slow, signal)
  line = ema_series(closes, fast).zip(ema_series(closes, slow)).map { |quick, slack| quick - slack }
  line.zip(ema_series(line, signal)).map { |macd, trigger| macd - trigger }
end

# MACD rule: buy while the MACD line is above its signal line, sell while
# below.  The gaps are worked out once per closes array, then looked up.
def macd_rule(period)
  fast, slow, signal = macd_spans(period)
  cache = {}.compare_by_identity
  lambda do |closes, today|
    next nil if today < slow + signal

    cache.clear unless cache.key?(closes)
    side((cache[closes] ||= macd_gaps(closes, fast, slow, signal))[today])
  end
end

# True when the bar at `today` is the last one of its calendar month.  The
# final bar of the history is never counted, since the next one is unknown.
def month_end?(dates, today)
  following = dates[today + 1]
  !following.nil? && following.month != dates[today].month
end

# 1 for the first trading day of its month, 2 for the second, ...
def trading_day_of_month(dates, today)
  month = dates[today].month
  count = 1
  count += 1 while today >= count && dates[today - count].month == month
  count
end

# Turn of the month: buy at the close of a month's last trading day, sell at
# the close of the next month's `period`-th trading day.
def turn_of_month_signal(dates, today, period)
  if month_end?(dates, today) then :buy
  elsif trading_day_of_month(dates, today) == period then :sell
  end
end

# The `count` calendar months starting with November: 6 -> [11, 12, 1, 2, 3, 4].
def winter_months(count) = (0...count).map { ((10 + it) % 12) + 1 }

# "Sell in May": hold through the `period` months starting in November, stay
# in cash for the rest of the year.
def sell_in_may_signal(dates, today, period)
  winter_months([period, 12].min).include?(dates[today].month) ? :buy : :sell
end

# Scenario builders: (period, dates) -> rule(closes, today).  `signal` names a
# method taking (closes, today, period) or, for calendar rules, (dates, today, period).
def price_scenario(signal) = ->(period, _dates) { ->(closes, today) { send(signal, closes, today, period) } }
def calendar_scenario(signal) = ->(period, dates) { ->(_closes, today) { send(signal, dates, today, period) } }

# name => [description, builder: (period, dates) -> rule(closes, today)]
SCENARIOS = {
  "sma_reversion" => ["Buy below / sell above the prior N-day average close", price_scenario(:sma_reversion_signal)],
  "sma_trend" => ["Trend following: buy above / sell below the prior N-day average close", price_scenario(:sma_trend_signal)],
  "sma_cross" => ["Crossover: hold while the N-day average is above the 4N-day average", price_scenario(:sma_cross_signal)],
  "breakout" => ["Channel breakout: buy a new N-day high close, sell a new N/2-day low close", price_scenario(:breakout_signal)],
  "momentum" => ["Time-series momentum: hold while the close is above the close N days ago", price_scenario(:momentum_signal)],
  "rsi_reversion" => ["RSI reversion: buy when the N-day RSI is below 30, sell above 70", price_scenario(:rsi_reversion_signal)],
  "bollinger_reversion" => ["Bollinger reversion: buy below the lower N-day band, sell above the N-day average",
                            price_scenario(:bollinger_reversion_signal)],
  "macd" => ["MACD: hold while the MACD line (fast N, slow 26N/12) is above its 9N/12 signal line",
             ->(period, _dates) { macd_rule(period) }],
  "turn_of_month" => ["Turn of the month: buy the last trading day, sell the Nth trading day of the next month",
                      calendar_scenario(:turn_of_month_signal)],
  "sell_in_may" => ["Sell in May: hold for the N months starting in November, cash otherwise",
                    calendar_scenario(:sell_in_may_signal)]
}.freeze

# Lookback periods used when none are given; scenarios not listed use DEFAULT_PERIODS.
SCENARIO_PERIODS = {
  "sma_trend" => [50, 100, 200], "sma_cross" => [10, 20, 50], "breakout" => [20, 55, 100],
  "momentum" => [63, 126, 252], "rsi_reversion" => [2, 5, 14], "bollinger_reversion" => [10, 20, 50],
  "macd" => [6, 12, 24], "turn_of_month" => [1, 3, 5], "sell_in_may" => [4, 6, 8]
}.freeze

# ---- data access ----------------------------------------------------------

def query(db, sql)
  out, status = Open3.capture2("sqlite3", "-readonly", "-csv", db, sql)
  abort "sqlite3 failed for #{db}" unless status.success?
  CSV.parse(out)
end

# Every ticker that has price history, in alphabetical order.
def all_tickers(db) = query(db, "SELECT DISTINCT ticker FROM prices ORDER BY ticker;").flatten

# The latest day stored for any ticker.
def latest_day(db) = Date.parse(query(db, "SELECT MAX(timestamp) FROM prices;").flatten.first)

# [[Date, adjusted close], ...] oldest first.
def load_bars(db, ticker)
  abort "bad ticker #{ticker.inspect}" unless ticker.match?(/\A[a-z0-9.\-^=]+\z/)

  sql = "SELECT timestamp, adj_close_price FROM prices WHERE ticker='#{ticker}' ORDER BY timestamp;"
  query(db, sql).map { |date, close| [Date.parse(date), close.to_f] }
end

# ---- simulation -----------------------------------------------------------

# Most whole shares `cash` can buy at `price` while leaving at least
# MIN_BANK in the bank -- a purchase that would take the balance below a
# dollar buys one share fewer.
def affordable_shares(cash, price, min_bank = MIN_BANK)
  spendable = cash - min_bank
  return 0 unless spendable.positive? && price.positive?

  (spendable / price).floor
end

# Account state after acting on one signal at `price`.  Returns
# [cash, shares, trade or nil]; a trade is { side:, index:, shares:, price: }.
# The bank always keeps at least MIN_BANK.
def apply_signal(signal, cash, shares, price, index)
  if signal == :buy && shares.zero?
    bought = affordable_shares(cash, price)
    return [cash, shares, nil] if bought.zero?

    [cash - (bought * price), bought, { side: :buy, index:, shares: bought, price: }]
  elsif signal == :sell && shares.positive?
    [cash + (shares * price), 0, { side: :sell, index:, shares:, price: }]
  else
    [cash, shares, nil]
  end
end

# Run a signal rule over the closes from index `start` on.  Returns
# { cash:, shares:, trades: }.
def simulate(closes, rule, start = 0, bankroll = BANKROLL)
  cash   = bankroll
  shares = 0
  trades = []
  (start...closes.size).each do |today|
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

# Value of $bankroll put into whole shares at the close of index `start` and held.
def buy_and_hold_value(closes, start = 0, bankroll = BANKROLL)
  entry  = closes[start]
  shares = affordable_shares(bankroll, entry)
  bankroll - (shares * entry) + (shares * closes.last)
end

def pct_change(value, bankroll = BANKROLL) = ((value / bankroll) - 1.0) * 100

def mean_or_nil(values) = values.empty? ? nil : values.sum / values.size

# Ending account and trade statistics for one lookback period.
def period_result(closes, rule, period, start = 0, bankroll = BANKROLL)
  result  = simulate(closes, rule, start, bankroll)
  stock   = result[:shares] * closes.last
  final   = result[:cash] + stock
  returns = trip_returns(result[:trades])
  { period:, shares: result[:shares], cash: result[:cash], stock:, final:,
    strategy_pct: pct_change(final, bankroll), trips: returns.size,
    win_rate: mean_or_nil(returns.map { it.positive? ? 100.0 : 0.0 }),
    avg_trip: mean_or_nil(returns), trades: result[:trades] }
end

# Index of the first bar on or after `from` (0 when from is nil; nil when none).
def start_index(dates, from) = from ? dates.bsearch_index { it >= from } : 0

# { ticker:, bars:, from:, to:, last_close:, bankroll:, hold_value:, hold_pct:,
#   dates:, results: [period_result...] }.  `bars` counts only the traded
# bars, from the start date on.
def ticker_summary(db, ticker, builder, periods, from = nil, bankroll: BANKROLL)
  bars   = load_bars(db, ticker)
  dates  = bars.map(&:first)
  closes = bars.map(&:last)
  start  = start_index(dates, from)
  return { ticker:, bars: 0 } unless start

  hold_value = buy_and_hold_value(closes, start, bankroll)
  { ticker:, bars: bars.size - start, from: dates[start], to: dates.last, last_close: closes.last,
    bankroll:, hold_value:, hold_pct: pct_change(hold_value, bankroll), dates:,
    results: periods.map { period_result(closes, builder.call(it, dates), it, start, bankroll) } }
end

# ---- reporting ------------------------------------------------------------

def money(value) = format("$%.2f", value).gsub(/(\d)(?=(\d{3})+\.)/, '\1,')

def pct(value, width = 8, sign: true)
  return "n/a".rjust(width) unless value

  format(sign ? "%+.1f%%" : "%.1f%%", value).rjust(width)
end

# [heading, value formatter, width]
DETAIL_COLUMNS = [
  ["N", ->(r) { r[:period].to_s }, 4],
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
  trades  = results.flat_map { ["  N = #{it[:period]}:", *recent_trades(summary, it)] }
  <<~REPORT
    #{summary[:ticker].upcase}  #{summary[:bars]} bars  #{summary[:from]} .. #{summary[:to]}  last close #{money(summary[:last_close])}
    scenario: #{name} -- #{description}
    starting cash #{money(summary[:bankroll])}   buy & hold return #{pct(summary[:hold_pct]).strip}

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
  titles = periods.map { "N = #{it}".center(block.size) }
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
    "N = #{period} beat buy & hold on #{beat} of #{summaries.size}"
  end.join(";  ")
end

# Comparison table: one row per ticker, ranked by the first period's total value.
def comparison_report(summaries, periods, name, description, from = nil, bankroll = BANKROLL)
  usable = summaries.reject { it[:bars].zero? }
  [
    "scenario: #{name} -- #{description}  (#{money(bankroll)} per stock, whole shares)",
    "trading from #{from || 'the start of each history'} through #{usable.map { it[:to] }.max}",
    *comparison_header(periods),
    *usable.sort_by { -it[:results].first[:final] }.map { comparison_row(it) },
    beat_counts(usable, periods)
  ].join("\n")
end

# ---- command line ---------------------------------------------------------

DATE_ARG = /\A\d{4}-\d{2}-\d{2}\z/

def parse_date(text)
  Date.iso8601(text)
rescue Date::Error
  abort "bad date #{text.inspect} (want YYYY-MM-DD)"
end

# Split arguments after the ticker into [periods, from date or nil, scenario name].
def parse_options(args)
  dates, rest    = args.partition { it.match?(DATE_ARG) }
  periods, names = rest.partition { it.match?(/\A\d+\z/) }
  periods = periods.map(&:to_i)
  abort "periods must be at least 1" if periods.any?(&:zero?)
  name = names.first || SCENARIOS.keys.first
  [periods.empty? ? SCENARIO_PERIODS.fetch(name, DEFAULT_PERIODS) : periods, dates.first&.then { parse_date(it) }, name]
end

def run(db, ticker, periods, from, scenario, bankroll: BANKROLL)
  description, builder = SCENARIOS.fetch(scenario) do
    abort "unknown scenario #{scenario.inspect} (have: #{SCENARIOS.keys.join(', ')})"
  end
  if ticker == "all"
    summaries = all_tickers(db).map { ticker_summary(db, it, builder, periods, from, bankroll:) }
    return comparison_report(summaries, periods, scenario, description, from, bankroll)
  end

  summary = ticker_summary(db, ticker, builder, periods, from, bankroll:)
  abort "no price history for #{ticker.upcase} #{"on or after #{from} " if from}in #{db}" if summary[:bars].zero?
  detail_report(summary, scenario, description)
end

if $PROGRAM_NAME == __FILE__
  options = parse_demo_options(ARGV, __FILE__, window: true, cash: true)
  periods, from, scenario = parse_options(ARGV[1..].to_a)
  from = analysis_start(from, options[:window]) { latest_day(DB) }
  puts run(DB, (ARGV[0] || "nvda").downcase, periods, from, scenario, bankroll: options.fetch(:cash, BANKROLL))
end
