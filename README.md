# Duration

Provides simple (somewhat naive) Duration parsing from strings. Allows you to compare and modify durations.

## Installation

Add this line to your application's Gemfile:

    gem 'rduration', :require => 'duration'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rduration

## Usage

`duration_spec.rb` has more details about the types of strings this can handle, but here's brief overview:

```ruby
a = Duration.new("01:46:00")
b = Duration.new("25 minutes 17 seconds")
a > b # => true
a - b # => #<Duration:2164349940 @raw="4843">
[b, a].sort # => [a, b]

b.to_clock_format # => "25:17"
```

If you require 'duration/string_ext' then strings gain a new method: `#to_duration`

```ruby
"35m 5s".to_duration # => NoMethodError: undefined method `to_duration' for "35m 5s":String

require 'duration/string_ext'
"35m 5s".to_duration # => #<Duration:2151903540 @raw="35m 5s">

# once you've done this, the arithmetic and comparison stuff works too
"35m 5s".to_duration > "10m" # => true
"35m 5s".to_duration > "50m" # => false
"35m 5s".to_duration + "10m" # => #<Duration:2156162420 @raw="2705">
```

### Formats

Here's a list of formats that will parse:

```
Duration
  #parse
    parses "0" as 0 seconds
    parses "00:00" as 0 seconds
    parses "0 seconds" as 0 seconds
    parses nil as 0 seconds
    parses "45s" as 45 seconds
    parses "45 seconds" as 45 seconds
    parses "00:00:45" as 45 seconds
    parses "45" as 45 seconds
    parses "137s" as 137 seconds
    parses "2m17s" as 137 seconds
    parses "2 minutes 17 seconds" as 137 seconds
    parses "02:17" as 137 seconds
    parses "2:17" as 137 seconds
    parses "1h32m07s" as 5527 seconds
    parses "1:32:07" as 5527 seconds
    parses "92 minutes and 7 seconds" as 5527 seconds
    parses "3d10h15m" as 296100 seconds
    parses "3:10:15:00" as 296100 seconds
    parses "82 hours 15 minutes" as 296100 seconds
```

### Interesting Methods

* `#to_clock_format` leverages `#to_s`'s newfound proc handling powers to format the output. Speaking of...
* `#to_s` takes a proc, and yields the duration in seconds to it. This is useful for output.

## CHANGELOG

* **v0.0.1 Hello World**
  * Handles all of my use cases. Could be better at everything, though :).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Copyright

Copyright (c) 2012 Matt Wilson. See LICENSE for details, but it's MIT.