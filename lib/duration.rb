require "duration/version"
require "duration/arithmetic"

class Duration
  attr_accessor :raw

  include Comparable
  include Arithmetic

  def initialize input
    self.raw = input.to_s
  end

  def parse
    @parsed ||= count normalize_input
  end
  alias_method :to_i, :parse

  def normalize_input input = raw.dup
    input = condense_duration_tokens input # => '92 m and 7 s'
    input = strip_useless_words input # => '92 m 7 s'
    input = intelligently_space input # => '92m 7s'
    convert_to_normal_form input # '92:07' => '92m 7s'
  end

  def condense_duration_tokens input = raw.dup
    input.gsub(/(#{DURATIONS.keys.join("|")})/, DURATIONS)
  end

  def strip_useless_words input = raw.dup
    input.gsub(/[[:alpha:]]{2,}/, "").gsub(/[^\ddhms:]/, " ").squeeze(" ")
  end

  def intelligently_space input = raw.dup
    input.gsub(/\s/, "").gsub(/([[:alpha:]])(?=[[:digit:]])/, '\1 ')
  end

  def convert_to_normal_form input = raw.dup
    return input unless input =~ /:/ || input !~ /[[:alpha:]]/
    split = input.split(":").reverse
    split.zip(UNITS).reverse.map { |unit| unit.join("") }.join(" ")
  end

  def count input = normalize_input
    input.split(" ").inject(0) do |accum, token|
      _, amount, type = token.split(/([[:digit:]]+)(?=[[:alpha:]])/)
      accum += STANDARD_CONVERSION[type] * amount.to_i
      accum
    end
  end

  def to_clock_format
    to_s proc { |s|
      a = STANDARD_CONVERSION.values.dup
      [(s / a[3]), (s % a[3] / a[2]), (s % a[2] / a[1]), (s % a[1])].
        each_with_index.
        reject { |value, index| index < 2 && value == 0 }.
        map { |value| "%02d" % value }.
        join(":")
    }
  end

  def to_s formatter = nil
    formatter ? formatter.call(parse) : "#<Duration:#{self.object_id} @raw=#{raw.inspect} @clock=#{to_clock_format.inspect}>"
  end

  UNITS = ['s', 'm', 'h', 'd']

  DURATIONS = {
    'seconds' => 's',
    'minutes' => 'm',
    'hours'   => 'h',
    'days'    => 'd',
    'sec'     => 's',
    'hrs'     => 'h',
    'mins'    => 'm'
  }
  DURATIONS.default_proc = proc { |hash, key| hash[key] = "" }

  STANDARD_CONVERSION = {
    's' => 1,
    'm' => 60,
    'h' => 3600,
    'd' => 86_400
  }

  # Comparable Protocol:
  def <=> other_thing
    other_thing = other_thing.to_duration if other_thing.respond_to?(:to_duration)
    self.to_i <=> other_thing.to_i
  end
end
