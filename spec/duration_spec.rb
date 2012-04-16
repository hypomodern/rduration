require 'spec_helper'

describe Duration do
  describe "#initialize" do
    it "stores the raw input string in an attribute called #raw" do
      d = Duration.new("00:01")
      d.raw.should == "00:01"
    end
    it "coerces the input to a string" do
      d = Duration.new(nil)
      d.raw.should == ""
    end
  end

  describe "#parse" do
    expected_second_values_and_their_strings = {
      0       => [ '0', '00:00', '0 seconds', nil ],
      45      => [ '45s', '45 seconds', '00:00:45', '45' ],
      137     => [ '137s', '2m17s', '2 minutes 17 seconds', '02:17', '2:17' ],
      5_527   => [ '1h32m07s', '1:32:07', '92 minutes and 7 seconds' ],
      296_100 => [  '3d10h15m', '3:10:15:00', '82 hours 15 minutes' ]
    }
    expected_second_values_and_their_strings.each do |(expected, inputs)|
      inputs.each do |possible_input|
        it "parses #{possible_input.inspect} as #{expected} seconds" do
          Duration.new(possible_input).parse.should == expected
        end
      end
    end
  end

  describe "#to_i" do
    it "is an alias for #parse" do
      Duration.new('45s').to_i.should == 45
    end
  end

  describe "#normalize_input" do
    normal_form_and_variants = {
      '45s'            => [ '45s', '45 seconds', '45' ],
      '00h 00m 45s'    => ['00:00:45'],
      '2m 17s'         => [ '2m17s', '2 minutes 17 seconds', '2:17','2m 17s' ],
      '137s'           => ['137s'],
      '1h 32m 07s'     => [ '1h32m07s', '1:32:07', '1h 32m 07s'  ],
      '3d 10h 15m 00s' => [ '3d10h15m00s', '3:10:15:00', '3d 10h 15m 00s' ],
      '82h 15m'        => ['82 hours, 15 minutes'],
      '92m 7s'         => ['92 minutes and 7 seconds']
    }
    normal_form_and_variants.each do |(expected, inputs)|
      inputs.each do |input|
        it "normalizes #{input.inspect} to #{expected.inspect}" do
          Duration.new(input).normalize_input.should == expected
        end
      end
    end
    it "doesn't modify the #raw attibute" do
      input = '92 minutes and 7 seconds'
      Duration.new(input).tap { |s| s.normalize_input }.raw.should == input
    end
  end

  describe "#condense_duration_tokens" do
    forms_to_condense = {
      '2 minutes 17 seconds' => '2 m 17 s',
      '3 days 10 hours 15 minutes' => '3 d 10 h 15 m',
      '2:17' => '2:17'
    }
    forms_to_condense.each do |(input, expectation)|
      it "converts #{input.inspect} into #{expectation.inspect}" do
        Duration.new(input).condense_duration_tokens.should == expectation
      end
    end
  end

  describe "#strip_useless_words" do
    forms_with_useless_words = {
      '92 m and 7 s' => '92 m 7 s',
      '3 d, 8 h, and 11 m' => '3 d 8 h 11 m',
      '3m + 18s' => '3m 18s',
      '2:17' => '2:17'
    }
    forms_with_useless_words.each do |(input, expectation)|
      it "converts #{input.inspect} to #{expectation.inspect}" do
        Duration.new(input).strip_useless_words.should == expectation
      end
    end
  end

  describe "#intelligently_space" do
    spaced_out_forms = {
      '1h32m07s' => '1h 32m 07s',
      '92 m 7 s' => '92m 7s',
      '3 d 8 h 11 m' => '3d 8h 11m',
      '3m 18s' => '3m 18s',
      '2:17' => '2:17'
    }
    spaced_out_forms.each do |(input, expectation)|
      it "converts #{input.inspect} to #{expectation.inspect}" do
        Duration.new(input).intelligently_space.should == expectation
      end
    end
  end

  describe "#convert_to_normal_form" do
    clock_forms = {
      '1:32:07'     => '1h 32m 07s',
      '92:07'       => '92m 07s',
      '03:08:11:00' => '03d 08h 11m 00s',
      '03:00'       => '03m 00s',
      '2m 17s'      => '2m 17s',
      '45'          => '45s'
    }
    clock_forms.each do |(input, expectation)|
      it "converts #{input.inspect} to #{expectation.inspect}" do
        Duration.new(input).convert_to_normal_form.should == expectation
      end
    end
  end

  describe "#count" do
    normalized_inputs = {
      '1h 32m 07s'      => 5527,
      '03d 08h 11m 00s' => 288660,
      '42m 3s'          => 2523
    }
    normalized_inputs.each do |(input, expectation)|
      it "counts the number of seconds in #{input.inspect} as #{expectation.inspect}" do
        Duration.new(input).count.should == expectation
      end
    end
  end

  describe "#to_clock_format" do
    clocks = {
      0       => '00:00',
      45      => '00:45',
      137     => '02:17',
      5_527   => '01:32:07',
      296_100 => '03:10:15:00'
    }
    clocks.each do |seconds, formatted|
      it "outputs #{formatted.inspect} given #{seconds} seconds" do
        Duration.new(seconds).to_clock_format.should == formatted
      end
    end
  end

  describe "#to_s" do
    context "but with a formatter proc/lambda" do
      it "calls the formatter, yielding the current number of seconds" do
        formatted = Duration.new(500).to_s proc { |s| "Mein formatt sagt #{s}" }
        formatted.should == "Mein formatt sagt 500"
      end
    end
    it "just returns something like #to_s normally does" do
      d = Duration.new(500)
      d.to_s.should == "#<Duration:#{d.object_id} @raw=\"500\" @clock=\"08:20\">"
    end
  end

  describe "Comparable compatibility" do
    describe "#<=>" do
      it "compares Durations based on their #to_i values" do
        ( Duration.new("01:04:55") > Duration.new("55m 3s") ).should be_true
        ( Duration.new("55m 3s") > Duration.new("30 minutes and 14 seconds") ).should be_true
        ( Duration.new("04:22") > Duration.new("75") ).should be_true
      end
    end
  end

  describe "basic maths" do
    let(:a) { Duration.new("55 seconds") }
    let(:b) { Duration.new("1m 10s") }
    describe "#+" do
      it "returns a new Duration..." do
        added = a + b
        added.should be_a_kind_of(Duration)
        [a.object_id, b.object_id].should_not include(added.object_id)
      end
      it "sums the two Durations by seconds" do
        added = a+b
        added.to_i.should == 125
        added.to_clock_format.should == "02:05"
      end
    end
    describe "#-" do
      it "returns a new Duration..." do
        difference = b - a
        difference.should be_a_kind_of(Duration)
        [a.object_id, b.object_id].should_not include(difference.object_id)
      end
      it "subtracts the two Durations by seconds" do
        difference = b - a
        difference.to_i.should == 15
        difference.to_clock_format.should == "00:15"
      end
    end
  end

end