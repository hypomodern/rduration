class Duration
  module Arithmatic
    def + other_duration
      raise StandardError.new("Cannot add #{other_duration.class} to #{self}") unless other_duration.respond_to?(:to_i)
      other_duration = other_duration.to_duration if other_duration.respond_to?(:to_duration)
      Duration.new(self.to_i + other_duration.to_i)
    end

    def - other_duration
      raise StandardError.new("Cannot subtract #{other_duration.class} from #{self}") unless other_duration.respond_to?(:to_i)
      other_duration = other_duration.to_duration if other_duration.respond_to?(:to_duration)
      Duration.new(self.to_i - other_duration.to_i)
    end
  end
end