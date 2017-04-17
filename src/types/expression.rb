class Expression
  attr_accessor :type, :children, :symbol, :enhancements

  TYPES = {
    default: 'Exp',
    predicate: 'Predicate',
    var_def: 'Vardef',
    var_set: 'Setf',
    func_def: 'Funcdef',
    lambda: 'Lambda',
    var_let: 'Let',
    func_let: 'Flet',
    builtin: 'Builtin',
    eval: 'Eval',
    quote: 'Quote'
  }

  def initialize(type, children = [], symbol = nil)
    @type = type
    @children = children
    @symbol = symbol
    @enhancements = {}
  end

  def to_s
    "Expression: #{type}"
  end
end
