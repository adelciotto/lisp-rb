class LispSymbol
  attr_accessor :value

  def initialize(value = nil)
    @value = value
  end

  def to_s
    "Symbol: #{value}"
  end
end
