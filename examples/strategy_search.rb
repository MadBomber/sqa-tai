#!/usr/bin/env ruby
# frozen_string_literal: true

# Search for the trading strategy that best balances profit against risk for
# each stock, and test whether that choice holds up on data it never saw.
#
# Candidates are long-only rules built from sqa-tai indicators: trend
# following (moving averages and crossovers, MACD, ADX/DI, Aroon, parabolic
# SAR, rate of change, TRIX, regression slope, Hilbert trendline, MAMA, OBV,
# Chaikin oscillator, Donchian and Bollinger breakouts), mean reversion (RSI,
# Bollinger bands, stochastics, CCI, Williams %R, MFI, CMO, ultimate
# oscillator, moving-average reversion -- each with and without a 200-day
# trend filter), all 61 candlestick patterns, and buy & hold.
#
# Trading model: a signal on one bar trades at the next bar's open, in whole
# shares, starting from the --cash amount, paying COST per side, with at
# least $1 always left in the bank.
#
# Score (higher is better):
#   mar     compound annual growth / maximum drawdown   (default)
#   sharpe  annualised mean / standard deviation of daily returns
#   return  compound annual growth alone
#
# Method: the bars of each stock's window are split in time.  Every candidate
# is scored on the training part; the winner is then run, with fresh cash,
# on the test part and compared with buy & hold there.  Bars before the
# window still warm up the indicators, and training never starts before bar
# WARMUP, so a stock younger than the window loses its first WARMUP bars.
# The report also shows how the winner ranked among all candidates on the
# test part, and the rank correlation between training and test scores --
# near zero means the training ranking carries no information about the
# future.
#
# usage: examples/strategy_search.rb [options] [TICKER|all] [SCORE] [SPLIT]
#   TICKER = a symbol (detail: its top candidates), or "all" (default)
#   SCORE  = mar | sharpe | return            (default: mar)
#   SPLIT  = fraction of the window used for training (default: 0.7)
#
# options:
#   --window DAYS    search only the last DAYS calendar days before the latest
#                    date in the database (default: 730, two years; "all" for
#                    the whole history).  Training needs MIN_TRAIN (250) bars,
#                    so with SPLIT 0.7 the window must be about 520 days or more.
#   --cash DOLLARS   starting cash for every run (default: 10000)
#   -h, --help       show this help
#
# examples: examples/strategy_search.rb nvda --window 1095
#           examples/strategy_search.rb all sharpe --window all --cash 2500
#
# Reads daily bars from $SQA_DATA_DIR/sqa.db (default ~/sqa_data) via the
# sqlite3 command-line tool.  Educational only -- not investment advice.

require "etc"
require_relative "indicator_vs_profit"

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "sqa/tai"

COST       = 0.0005 # fraction of the trade value paid on each buy and each sell
WARMUP     = 250    # bars skipped before trading starts, so every indicator is ready
MIN_TRIPS  = 10     # round trips a candidate needs on the training part to be eligible
DD_FLOOR   = 0.05   # drawdowns below this count as this, so a near-idle rule cannot win on a tiny denominator
MIN_TRAIN  = 250    # training bars required after the warm-up
SCORES     = %w[mar sharpe return].freeze
TREND_DAYS = 200

CLOSE = %i[close].freeze
HL    = %i[high low].freeze
HLC   = %i[high low close].freeze
HLCV  = %i[high low close volume].freeze
OHLC  = %i[open high low close].freeze

# ---- market data ----------------------------------------------------------

# One ticker's bars as column arrays, plus a cache of indicator outputs
# aligned to those bars (nil where the indicator is still warming up).
class Market
  attr_reader :ticker, :dates, :open, :high, :low, :close, :volume, :size

  def initialize(ticker, rows)
    @ticker = ticker
    @dates  = rows.map { Date.parse(it[0]) }
    @open, @high, @low, @close, @volume = (1..5).map { |column| rows.map { it[column].to_f } }
    @size  = rows.size
    @cache = {}
  end

  # An sqa-tai indicator over the named input columns.  Multi-output
  # indicators come back as an array of aligned arrays.
  def ind(name, inputs, **params)
    @cache[[name, inputs, params]] ||= align(SQA::TAI.public_send(name, *inputs.map { public_send(it) }, **params))
  end

  def align(output) = output.first.is_a?(Array) ? output.map { pad(it) } : pad(output)

  def pad(values) = Array.new(size - values.size) + values
end

def load_market(db, ticker)
  abort "bad ticker #{ticker.inspect}" unless ticker.match?(/\A[a-z0-9.\-^=]+\z/)

  sql = "SELECT timestamp, open_price, high_price, low_price, adj_close_price, volume FROM prices " \
        "WHERE ticker='#{ticker}' ORDER BY timestamp;"
  Market.new(ticker, query(db, sql))
end

# ---- signals --------------------------------------------------------------
#
# A signal is one value per bar: 1 = want to be long, 0 = want to be flat,
# nil = no opinion (keep the current position).

def level(series, index) = series.is_a?(Numeric) ? series : series[index]

# Long while a is above b, flat while below.  b may be a number.
def above(first, second)
  first.each_with_index.map do |value, index|
    other = level(second, index)
    next nil unless value && other

    if value > other then 1
    elsif value < other then 0
    end
  end
end

# Mean reversion: go long below `buy_below`, go flat above `sell_above`.
def swing(values, buy_below, sell_above)
  values.each_with_index.map do |value, index|
    low  = level(buy_below, index)
    high = level(sell_above, index)
    next nil unless value && low && high

    if value < low then 1
    elsif value > high then 0
    end
  end
end

# Breakout: go long above `buy_above`, go flat below `sell_below`.
def breakout(values, buy_above, sell_below)
  values.each_with_index.map do |value, index|
    high = level(buy_above, index)
    low  = level(sell_below, index)
    next nil unless value && low && high

    if value > high then 1
    elsif value < low then 0
    end
  end
end

# The series one bar earlier.
def lag(values) = [nil] + values[0...-1]

# Highest (:max) or lowest (:min) of the `period` values before each bar.
def prior_extreme(values, period, pick)
  values.each_index.map { |index| index >= period ? values[(index - period)...index].public_send(pick) : nil }
end

# Drops entries (1) made while the close is not above its trend line; exits pass through.
def trend_filtered(signal, close, trend)
  signal.each_with_index.map do |want, index|
    blocked = want == 1 && !(trend[index] && close[index] > trend[index])
    blocked ? nil : want
  end
end

# Candlestick pattern: long on a bullish signal, flat on a bearish one or after `hold` bars.
def pattern_signal(values, hold)
  exit_at = nil
  values.each_with_index.map do |value, index|
    if value.to_i.positive?
      exit_at = index + hold
      1
    elsif value.to_i.negative? || (exit_at && index >= exit_at)
      exit_at = nil
      0
    end
  end
end

# Directional movement: long when +DI leads and ADX shows a trend, flat when -DI leads.
def adx_signal(adx, plus, minus, threshold)
  adx.each_index.map do |index|
    next nil unless adx[index] && plus[index] && minus[index]

    if plus[index] > minus[index] && adx[index] > threshold then 1
    elsif plus[index] < minus[index] then 0
    end
  end
end

# ---- strategy catalog -----------------------------------------------------

Strategy = Data.define(:name, :family, :build)

def strategy(family, name, &build) = Strategy.new(name:, family:, build:)

MA_KINDS     = %i[sma ema wma dema tema trima kama].freeze
MA_PERIODS   = [10, 20, 50, 100, 200].freeze
CROSS_PAIRS  = [5, 10, 20, 50].product([20, 50, 100, 200]).select { |fast, slow| fast < slow }.freeze
MACD_SETS    = [[12, 26, 9], [8, 17, 9], [5, 35, 5], [19, 39, 9]].freeze
RSI_BANDS    = { 2 => [[5, 70], [10, 70], [10, 90], [15, 60]], 5 => [[20, 60], [25, 70], [30, 50]],
                 14 => [[30, 50], [30, 70], [35, 60], [40, 60]] }.freeze

def ma_trend_strategies
  MA_KINDS.product(MA_PERIODS).map do |kind, period|
    strategy(:trend, "close > #{kind}(#{period})") { |m| above(m.close, m.ind(kind, CLOSE, period:)) }
  end
end

def cross_strategies
  %i[sma ema].product(CROSS_PAIRS).map do |kind, (fast, slow)|
    strategy(:trend, "#{kind}(#{fast}) > #{kind}(#{slow})") do |m|
      above(m.ind(kind, CLOSE, period: fast), m.ind(kind, CLOSE, period: slow))
    end
  end
end

def macd_strategies
  MACD_SETS.flat_map do |fast, slow, signal|
    params = { fast_period: fast, slow_period: slow, signal_period: signal }
    label  = "macd(#{fast},#{slow},#{signal})"
    [strategy(:trend, "#{label} > signal") { |m| above(*m.ind(:macd, CLOSE, **params).first(2)) },
     strategy(:trend, "#{label} > 0") { |m| above(m.ind(:macd, CLOSE, **params).first, 0) }]
  end
end

def directional_strategies
  adx = [7, 14, 21].product([15, 20, 25]).map do |period, threshold|
    strategy(:trend, "+DI > -DI(#{period}) & adx > #{threshold}") do |m|
      adx_signal(*%i[adx plus_di minus_di].map { m.ind(it, HLC, period:) }, threshold)
    end
  end
  aroon = [14, 25, 50].product([0, 50]).map do |period, threshold|
    strategy(:trend, "aroonosc(#{period}) > #{threshold} / < #{-threshold}") do |m|
      breakout(m.ind(:aroonosc, HL, period:), threshold, -threshold)
    end
  end
  sar = [0.01, 0.02, 0.04].map do |acceleration|
    strategy(:trend, "close > sar(#{acceleration})") { |m| above(m.close, m.ind(:sar, HL, acceleration:)) }
  end
  adx + aroon + sar
end

def momentum_strategies
  list = [10, 20, 60, 120, 250].map do |period|
    strategy(:trend, "roc(#{period}) > 0") { |m| above(m.ind(:roc, CLOSE, period:), 0) }
  end
  list += [9, 15, 30].map { |period| strategy(:trend, "trix(#{period}) > 0") { |m| above(m.ind(:trix, CLOSE, period:), 0) } }
  list += [14, 50, 100].map do |period|
    strategy(:trend, "linearreg_slope(#{period}) > 0") { |m| above(m.ind(:linearreg_slope, CLOSE, period:), 0) }
  end
  list += [14, 21].map { |period| strategy(:trend, "rsi(#{period}) > 50") { |m| above(m.ind(:rsi, CLOSE, period:), 50) } }
  list << strategy(:trend, "close > ht_trendline") { |m| above(m.close, m.ind(:ht_trendline, CLOSE)) }
  list << strategy(:trend, "mama > fama") { |m| above(*m.ind(:mama, CLOSE).first(2)) }
end

def volume_strategies
  obv = [20, 50, 100].map do |period|
    strategy(:trend, "obv > sma(obv,#{period})") do |m|
      balance = m.ind(:obv, %i[close volume])
      above(balance, m.pad(SQA::TAI.sma(balance, period:)))
    end
  end
  obv << strategy(:trend, "adosc(3,10) > 0") { |m| above(m.ind(:adosc, HLCV, fast_period: 3, slow_period: 10), 0) }
end

def breakout_strategies
  donchian = [20, 55, 100].product([10, 20, 50]).map do |enter, leave|
    strategy(:breakout, "close > #{enter}-day high / < #{leave}-day low") do |m|
      breakout(m.close, prior_extreme(m.high, enter, :max), prior_extreme(m.low, leave, :min))
    end
  end
  bands = [1.5, 2.0].map do |width|
    strategy(:breakout, "close > bbands(20,#{width}) upper / < middle") do |m|
      upper, middle, = m.ind(:bbands, CLOSE, period: 20, nbdev_up: width, nbdev_down: width)
      breakout(m.close, upper, middle)
    end
  end
  cci = strategy(:breakout, "cci(20) > 100 / < -100") { |m| breakout(m.ind(:cci, HLC, period: 20), 100, -100) }
  [*donchian, *bands, cci]
end

def band_reversion_strategies
  sma = [5, 10, 15, 20].map do |period|
    strategy(:reversion, "close < prior sma(#{period}) / >") do |m|
      average = lag(m.ind(:sma, CLOSE, period:))
      swing(m.close, average, average)
    end
  end
  bands = [10, 20].product([1.5, 2.0, 2.5], [1, 0]).map do |period, width, exit_line|
    strategy(:reversion, "close < bbands(#{period},#{width}) lower / > #{%w[upper middle][exit_line]}") do |m|
      lines = m.ind(:bbands, CLOSE, period:, nbdev_up: width, nbdev_down: width)
      swing(m.close, lines[2], lines[exit_line])
    end
  end
  sma + bands
end

# [label, indicator, inputs, params, buy below, sell above]
OSCILLATORS = [
  *RSI_BANDS.flat_map { |period, bands| bands.map { |low, high| ["rsi(#{period})", :rsi, CLOSE, { period: }, low, high] } },
  *[5, 14].product([[-100, 100], [-150, 0]]).map { |p, (lo, hi)| ["cci(#{p})", :cci, HLC, { period: p }, lo, hi] },
  ["cci(20)", :cci, HLC, { period: 20 }, -100, 100],
  *[5, 14].product([[-80, -20], [-90, -10]]).map { |p, (lo, hi)| ["willr(#{p})", :willr, HLC, { period: p }, lo, hi] },
  *[5, 14].product([[20, 80], [30, 70]]).map { |p, (lo, hi)| ["mfi(#{p})", :mfi, HLCV, { period: p }, lo, hi] },
  *[[-50, 50], [-30, 30]].map { |lo, hi| ["cmo(14)", :cmo, CLOSE, { period: 14 }, lo, hi] },
  *[[30, 70], [35, 65]].map { |lo, hi| ["ultosc", :ultosc, HLC, {}, lo, hi] }
].freeze

def oscillator_strategies
  list = OSCILLATORS.map do |label, name, inputs, params, low, high|
    strategy(:reversion, "#{label} < #{low} / > #{high}") { |m| swing(m.ind(name, inputs, **params), low, high) }
  end
  list += [5, 14].product([[20, 80], [10, 90]]).map do |fastk, (low, high)|
    strategy(:reversion, "stoch(#{fastk}) < #{low} / > #{high}") do |m|
      swing(m.ind(:stoch, HLC, fastk_period: fastk).first, low, high)
    end
  end
  list << strategy(:reversion, "stochrsi(14) < 20 / > 80") { |m| swing(m.ind(:stochrsi, CLOSE, period: 14).first, 20, 80) }
end

# Every reversion rule again, entering only while the close is above its 200-day average.
def trend_filtered_strategies(rules)
  rules.map do |rule|
    strategy(:filtered, "#{rule.name} & close > sma(#{TREND_DAYS})") do |m|
      trend_filtered(rule.build.call(m), m.close, m.ind(:sma, CLOSE, period: TREND_DAYS))
    end
  end
end

def pattern_strategies
  names = SQA::TAI::PatternRecognition.instance_methods.grep(/\Acdl_/).sort
  names.product([5, 10]).map do |name, hold|
    strategy(:pattern, "#{name} hold #{hold}") { |m| pattern_signal(m.ind(name, OHLC), hold) }
  end
end

def buy_and_hold = strategy(:baseline, "buy & hold") { |m| Array.new(m.size, 1) }

def catalog
  reversion = band_reversion_strategies + oscillator_strategies
  [buy_and_hold, *ma_trend_strategies, *cross_strategies, *macd_strategies, *directional_strategies,
   *momentum_strategies, *volume_strategies, *breakout_strategies, *reversion,
   *trend_filtered_strategies(reversion), *pattern_strategies]
end

# ---- simulation -----------------------------------------------------------

# Running account for one simulation.
class Account
  attr_reader :cash, :shares, :trips, :wins, :max_drawdown, :held_bars, :bars

  def initialize(bankroll, cost)
    @cash = bankroll
    @cost = cost
    @shares = @trips = @wins = @held_bars = @bars = 0
    @peak = @last_equity = bankroll
    @max_drawdown = @sum = @sum_squares = 0.0
  end

  # Act on yesterday's signal at today's open.
  def trade(want, price)
    if want == 1 && @shares.zero? then buy(price)
    elsif want&.zero? && @shares.positive? then sell(price)
    end
  end

  def buy(price)
    count = affordable_shares(@cash, price * (1 + @cost))
    return if count.zero?

    @entry_cash = @cash
    @cash -= count * price * (1 + @cost)
    @shares = count
  end

  def sell(price)
    @cash += @shares * price * (1 - @cost)
    @shares = 0
    @trips += 1
    @wins += 1 if @cash > @entry_cash
  end

  # Record the day's closing equity.
  def mark(close)
    equity = @cash + (@shares * close)
    change = (equity / @last_equity) - 1.0
    @sum += change
    @sum_squares += change * change
    @last_equity = equity
    @peak = equity if equity > @peak
    @max_drawdown = [@max_drawdown, 1.0 - (equity / @peak)].max
    @held_bars += 1 if @shares.positive?
    @bars += 1
  end

  def equity = @last_equity

  # Annualised mean / standard deviation of the daily returns.
  def sharpe
    mean = @sum / @bars
    deviation = Math.sqrt([(@sum_squares / @bars) - (mean * mean), 0.0].max)
    deviation.positive? ? mean / deviation * Math.sqrt(252) : 0.0
  end
end

# Trade a signal over bars first..last from a fresh bankroll.  Returns
# { final:, total:, cagr:, max_dd:, sharpe:, exposure:, trips:, win_rate: }.
def simulate(market, signal, first, last, cost: COST, bankroll: BANKROLL)
  account = Account.new(bankroll, cost)
  (first..last).each do |bar|
    account.trade(signal[bar - 1], market.open[bar]) if bar.positive?
    account.mark(market.close[bar])
  end
  years = [(market.dates[last] - market.dates[first]).to_f / 365.25, 1.0 / 365.25].max
  metrics(account, years, bankroll)
end

def metrics(account, years, bankroll)
  growth = account.equity / bankroll
  { final: account.equity, total: growth - 1.0, cagr: (growth**(1.0 / years)) - 1.0,
    max_dd: account.max_drawdown, sharpe: account.sharpe, exposure: account.held_bars.to_f / account.bars,
    trips: account.trips, win_rate: account.trips.zero? ? nil : account.wins.to_f / account.trips }
end

# Profit-against-risk score of one result; higher is better.
def score(result, kind)
  case kind
  when "sharpe" then result[:sharpe]
  when "return" then result[:cagr]
  else result[:cagr].positive? ? result[:cagr] / [result[:max_dd], DD_FLOOR].max : result[:cagr]
  end
end

# ---- search ---------------------------------------------------------------

# Index of the first test bar: `fraction` of the way through bars first..size-1.
def split_index(size, fraction, first = 0) = first + ((size - first) * fraction).to_i

# [first training bar, first test bar] for a market whose window starts at
# `from` (nil: the whole history), or nil when no bar is on or after `from`.
# Training starts at the window but never before the warm-up ends.
def search_bounds(market, fraction, from = nil)
  first = start_index(market.dates, from) or return nil
  [[WARMUP, first].max, split_index(market.size, fraction, first)]
end

# One row per candidate that could be computed, training on bars
# train_start...split and testing on the rest:
# { name:, family:, train:, test:, train_score:, test_score: }.
def evaluate(market, strategies, kind, (train_start, split), bankroll: BANKROLL)
  strategies.filter_map do |candidate|
    signal = candidate.build.call(market)
    train  = simulate(market, signal, train_start, split - 1, bankroll:)
    test   = simulate(market, signal, split, market.size - 1, bankroll:)
    { name: candidate.name, family: candidate.family, train:, test:,
      train_score: score(train, kind), test_score: score(test, kind) }
  rescue SQA::TAI::Error, ArgumentError, NoMethodError
    nil
  end
end

def eligible?(row) = row[:family] == :baseline || row[:train][:trips] >= MIN_TRIPS

# Ranks with ties sharing their average rank.
def average_ranks(values)
  order = values.each_with_index.sort_by(&:first)
  ranks = Array.new(values.size)
  order.chunk_while { |a, b| a.first == b.first }.reduce(0) do |start, group|
    shared = start + ((group.size - 1) / 2.0)
    group.each { |pair| ranks[pair.last] = shared }
    start + group.size
  end
  ranks
end

def rank_correlation(first, second) = pearson(average_ranks(first), average_ranks(second))

# Share of the other candidates that `row` beat on the test score.
def test_percentile(row, rows)
  others = rows.reject { it.equal?(row) }
  others.count { it[:test_score] < row[:test_score] } * 100.0 / others.size
end

# Search result for one market, or { ticker:, skipped: reason }.
def search(market, fraction, kind, from: nil, bankroll: BANKROLL)
  ticker = market.ticker
  bounds = search_bounds(market, fraction, from) or return { ticker:, skipped: "no bars on or after #{from}" }
  train_start, split = bounds
  if split - train_start < MIN_TRAIN
    return { ticker:, skipped: "#{[split - train_start, 0].max} training bars after the warm-up, needs #{MIN_TRAIN}" }
  end

  rows  = evaluate(market, catalog, kind, bounds, bankroll:).select { eligible?(it) }
  best  = rows.max_by { it[:train_score] }
  { ticker:, bars: market.size - train_start, train_from: market.dates[train_start], test_from: market.dates[split],
    to: market.dates.last, rows:, best:, hold: rows.find { it[:family] == :baseline },
    percentile: test_percentile(best, rows), rho: rank_correlation(rows.map { it[:train_score] }, rows.map { it[:test_score] }) }
end

# Run the block in a forked process; returns a pipe that yields its marshalled result.
def fork_result
  reader, writer = IO.pipe
  fork do
    reader.close
    writer.write(Marshal.dump(yield))
    writer.close
  end
  writer.close
  reader
end

# Run `search` for every market, one forked process each, a few at a time.
# The markets are loaded by the caller, so only one process reads the database.
def search_all(markets, fraction, kind, from: nil, bankroll: BANKROLL, workers: Etc.nprocessors)
  markets.each_slice(workers).flat_map do |group|
    pipes   = group.map { |market| fork_result { search(market, fraction, kind, from:, bankroll:) } }
    results = pipes.map { Marshal.load(it.read) } # rubocop:disable Security/MarshalLoad -- our own child processes
    Process.waitall
    results
  end
end

# ---- reporting ------------------------------------------------------------

def percent(value, width = 7) = format("%+.1f%%", value * 100).rjust(width)

def number(value, width = 6) = format("%.2f", value).rjust(width)

def result_cells(result, value) = "#{percent(result[:cagr], 8)} #{percent(-result[:max_dd], 7)} #{number(value)}"

# Did the chosen strategy beat buy & hold on the test part, by score?
def beat_hold?(found) = found[:best][:test_score] > found[:hold][:test_score]

def summary_row(found)
  best = found[:best]
  hold = found[:hold]
  [found[:ticker].upcase.ljust(6), best[:name][0, 46].ljust(46),
   result_cells(best[:train], best[:train_score]), result_cells(best[:test], best[:test_score]),
   result_cells(hold[:test], hold[:test_score]), (beat_hold?(found) ? "yes" : "no").ljust(4),
   format("%.0f", found[:percentile]).rjust(4), format("%+.2f", found[:rho]).rjust(6)].join(" | ")
end

def summary_header(kind)
  cells = "#{'CAGR'.rjust(8)} #{'max DD'.rjust(7)} #{kind.rjust(6)}"
  groups = ["chosen, training", "chosen, test", "buy & hold, test"].map { it.center(cells.size) }
  [[" " * 6, " " * 46, *groups, " " * 4, " " * 4, " " * 6].join(" | "),
   ["ticker", "strategy chosen on the training part".ljust(46), cells, cells, cells, "beat", "pct", "rho".rjust(6)].join(" | ")]
end

def median(values) = values.sort[values.size / 2]

def summary_footer(found)
  count = found.size
  lower = found.count { it[:best][:test][:max_dd] < it[:hold][:test][:max_dd] }
  more  = found.count { it[:best][:test][:cagr] > it[:hold][:test][:cagr] }
  <<~FOOTER
    on the test part the chosen strategy beat buy & hold by score on #{found.count { beat_hold?(it) }} of #{count} tickers,
    had a smaller maximum drawdown on #{lower} of #{count}, and a higher annual return on #{more} of #{count}
    median test percentile of the chosen strategy: #{format('%.0f', median(found.map { it[:percentile] }))} (50 = no better than a random candidate)
    mean training-vs-test rank correlation: #{format('%+.2f', mean(found.map { it[:rho] }))} (0 = the training ranking says nothing about the test part)
  FOOTER
end

# What the training and test parts are drawn from, for the report heading.
def search_scope(from) = from ? "the bars from #{from} on (never before bar #{WARMUP})" : "each history after a #{WARMUP}-bar warm-up"

def summary_report(results, kind, fraction, from = nil, bankroll = BANKROLL)
  found, skipped = results.partition { it[:best] }
  [
    "score: #{kind}; training on the first #{(fraction * 100).round}% of #{search_scope(from)}, " \
    "testing on the rest; cost #{COST * 100}% per side; starting cash #{money(bankroll)}",
    "beat = chosen strategy scored above buy & hold on the test part; pct = share of candidates it beat there",
    *summary_header(kind), *found.map { summary_row(it) }, summary_footer(found),
    *skipped.map { "skipped #{it[:ticker].upcase}: #{it[:skipped]}" }
  ].join("\n")
end

def detail_row(row)
  [row[:name][0, 52].ljust(52), result_cells(row[:train], row[:train_score]), row[:train][:trips].to_s.rjust(5),
   result_cells(row[:test], row[:test_score]), row[:test][:trips].to_s.rjust(5),
   "#{format('%.0f', row[:test][:exposure] * 100)}%".rjust(5)].join(" | ")
end

def detail_table(title, rows, kind)
  cells = "#{'CAGR'.rjust(8)} #{'max DD'.rjust(7)} #{kind.rjust(6)}"
  [title, [" " * 52, "training: #{cells}"[-cells.size..], "trips", "test: #{cells}"[-cells.size..], "trips", "in mkt"].join(" | "),
   *rows.map { detail_row(it) }]
end

def detail_report(found, kind, top = 12)
  rows = found[:rows]
  <<~REPORT
    #{found[:ticker].upcase}  #{found[:bars]} bars; training #{found[:train_from]} .. #{found[:test_from] - 1}, test #{found[:test_from]} .. #{found[:to]}
    #{rows.size} eligible candidates; score: #{kind}; training-vs-test rank correlation #{format('%+.2f', found[:rho])}

    #{detail_table("top #{top} on the training part:", rows.max_by(top) { it[:train_score] }, kind).join("\n")}

    #{detail_table('buy & hold:', [found[:hold]], kind).join("\n")}

    #{detail_table("top #{top} on the test part (hindsight -- not knowable in advance):", rows.max_by(top) { it[:test_score] }, kind).join("\n")}
  REPORT
end

# ---- command line ---------------------------------------------------------

# Split arguments after the ticker into [score kind, training fraction].
def parse_search_options(args)
  numbers, names = args.partition { it.match?(/\A0?\.\d+\z/) }
  kind = names.first || SCORES.first
  abort "unknown score #{kind.inspect} (have: #{SCORES.join(', ')})" unless SCORES.include?(kind)
  [kind, (numbers.first || 0.7).to_f]
end

def run_search(db, ticker, kind, fraction, from: nil, bankroll: BANKROLL)
  if ticker == "all"
    markets = all_tickers(db).map { load_market(db, it) }
    return summary_report(search_all(markets, fraction, kind, from:, bankroll:), kind, fraction, from, bankroll)
  end

  market = load_market(db, ticker)
  abort "no price history for #{ticker.upcase} in #{db}" unless market.size.positive?
  found = search(market, fraction, kind, from:, bankroll:)
  abort "#{ticker.upcase}: #{found[:skipped]}" if found[:skipped]
  detail_report(found, kind)
end

if $PROGRAM_NAME == __FILE__
  options        = parse_demo_options(ARGV, __FILE__, window: true, cash: true)
  kind, fraction = parse_search_options(ARGV[1..].to_a)
  from           = analysis_start(nil, options[:window]) { latest_day(DB) }
  puts run_search(DB, (ARGV[0] || "all").downcase, kind, fraction, from:, bankroll: options.fetch(:cash, BANKROLL))
end
