require_relative '../common/util.rb'

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
    syntax(children)
  end

  def syntax(children)
    exp_syntax = children.inject('') do |result, child|
      if child.is_a?(LispSymbol)
        "#{result} #{child}"
      else
        "#{result} (#{child.symbol} #{syntax(child.children)})"
      end
    end

    Util.strip_extra_whitespace(exp_syntax)
  end
end
