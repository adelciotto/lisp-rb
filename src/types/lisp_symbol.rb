class LispSymbol
  attr_reader :value

  def initialize(value = nil)
    @value = value
  end

  def to_s
    "Symbol: #{value}"
  end
end
