require_relative 'type.rb'

class Atom < Type
  ATOM_TYPES = {
    integer: 'Integer',
    float: 'Float',
    boolean: 'Boolean',
    nil: 'Nil'
  }

  def initialize(type, value = nil)
    super(type, value: value)
  end

  def to_s
    "#{ATOM_TYPES[type]}: #{value}"
  end
end
