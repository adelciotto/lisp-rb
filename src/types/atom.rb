require_relative 'lisp_symbol.rb'

class Atom < LispSymbol
  attr_reader :type

  ATOM_TYPES = {
    integer: 'Integer',
    float: 'Float',
    boolean: 'Boolean',
    nil: 'Nil'
  }.freeze

  def initialize(type, value = nil)
    super(value)
    @type = type
  end

  def to_s
    "#{ATOM_TYPES[type]}: #{value}"
  end
end
