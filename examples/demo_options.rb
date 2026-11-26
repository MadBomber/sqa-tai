# frozen_string_literal: true

# Command-line options shared by the demo programs in this directory.
#
#   -h, --help        print the program's header comment and exit
#   --window DAYS     analyse only the DAYS calendar days before the latest
#                     date in the database -- on the view that what a stock
#                     did years ago says little about what it does today
#                     (default: DEFAULT_WINDOW = 730, two years; "all" for
#                     the whole history)
#   --cash DOLLARS    starting cash in the bank (default $10,000); trades buy
#                     whole shares only and never take the bank below MIN_BANK
#
# Each program declares which of --window and --cash apply to it; the help
# text is the comment block at the top of the program, so it stays in step
# with the source.

require "date"
require "optparse"

MIN_BANK       = 1.0 # a purchase never takes the bank below one dollar
DEFAULT_WINDOW = 730 # calendar days analysed when neither --window nor a FROM date is given

# The comment block at the top of a script, without the leading "# ".
def header_comment(path)
  lines = File.foreach(path).drop_while { it.start_with?("#!", "# frozen_string_literal") || it.strip.empty? }
  lines.take_while { it.start_with?("#") }.map { it.sub(/\A# ?/, "") }.join
end

# A whole number of days, at least 1, or :all for the whole history.
def window_days(text)
  return :all if text.casecmp?("all")

  days = Integer(text, 10)
  abort "--window must be at least 1 day" unless days.positive?
  days
rescue ArgumentError
  abort "bad --window #{text.inspect} (want a whole number of days, or all)"
end

# A dollar amount such as 10000, 10,000 or $2500.50, more than MIN_BANK.
def cash_amount(text, floor = MIN_BANK)
  amount = Float(text.delete(",$_"))
  abort "--cash must be more than $#{format('%.2f', floor)}" unless amount > floor
  amount
rescue ArgumentError
  abort "bad --cash #{text.inspect} (want a dollar amount, e.g. 10000)"
end

# Remove the --options from `args`, leaving the positional arguments, and
# return the chosen ones as { window: days or :all, cash: dollars }.  --help
# prints the header comment of `script` and exits.  A block can declare more
# options: it gets the OptionParser and the options hash to fill.
def parse_demo_options(args, script, window: false, cash: false)
  options = {}
  OptionParser.new do |opts|
    opts.on("-h", "--help") do
      print header_comment(script)
      exit
    end
    opts.on("--window DAYS") { options[:window] = window_days(it) } if window
    opts.on("--cash DOLLARS") { options[:cash] = cash_amount(it) } if cash
    yield opts, options if block_given?
  end.parse!(args)
  options
rescue OptionParser::ParseError => e
  abort "#{e.message} (try --help)"
end

# The first date to analyse, or nil for the whole history:
#   from given    -> from (a Date)
#   window :all   -> nil
#   otherwise     -> `window` days (default DEFAULT_WINDOW) before the latest
#                    stored day, which the block supplies only when needed
def analysis_start(from, window)
  abort "give either a FROM date or --window, not both" if from && window
  return from if from
  return nil if window == :all

  yield - (window || DEFAULT_WINDOW)
end
