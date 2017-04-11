class Type
  attr_accessor :type, :value

  def initialize(type, value: nil, raw_value: nil)
    @type = type
    @value = value
    @raw_value = raw_value
  end

  private
  attr_accessor :raw_value
end
