require 'spec_helper'
require 'duration/string_ext'

describe String do
  describe "#to_duration" do
    it "returns a duration object" do
      duration = "2 hours 5 minutes".to_duration
      duration.should be_a_kind_of(Duration)
    end
  end

end