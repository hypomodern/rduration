class String
  def to_duration
    Duration.new(self)
  end
end