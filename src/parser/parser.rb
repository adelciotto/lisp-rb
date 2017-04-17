require_relative '../common/lisp_error.rb'
require_relative '../common/constants.rb'
require_relative '../types/atom.rb'
require_relative '../types/lisp_symbol.rb'
require_relative '../types/expression.rb'

module Parser
  include Constants

  EXP_TOKENS_MAP = {
    'if' => Expression::TYPES[:predicate],
    'defvar' => Expression::TYPES[:var_def],
    'setf' => Expression::TYPES[:var_set],
    'defun' => Expression::TYPES[:func_def],
    'lambda' => Expression::TYPES[:lambda],
    'let' => Expression::TYPES[:var_let],
    'flet' => Expression::TYPES[:func_let],
    'eval' => Expression::TYPES[:eval],
    'quote' => Expression::TYPES[:quote]
  }

  def parse(tokens)
    raise LispError.new('Unexpected EOF') if tokens.empty?

    token = tokens.shift
    case token
    when '('
      parse_exp(token, tokens)
    when ')'
      # TODO: Look into highlighting parts of the exp to more easily expose errors.
      raise LispError.new('No matching opening brace "("')
    else
      parse_atom(token)
    end
  end

  private

  def parse_exp(curr_token, tokens)
    list = []
    until tokens[0] == ')' do 
      list << parse(tokens)
    end
    tokens.shift

    return Atom.new(:nil) if list.empty?

    symbol = list[0].is_a?(Expression) ? list[0].symbol : list[0]
    type = EXP_TOKENS_MAP[symbol.value] || Expression::TYPES[:default]
    Expression.new(type, list, symbol)
  end

  def parse_atom(token)
    to_numeric(token)
  rescue ArgumentError
    case token
    when 'true'
      Atom.new(:boolean, true)
    when 'false'
      Atom.new(:boolean, false)
    when 'nil'
      Atom.new(:nil)
    else 
      LispSymbol.new(token)
    end
  end

  def to_numeric(token)
    parse_integer(token)
  rescue ArgumentError
    parse_float(token)
  end

  def parse_integer(token)
    Atom.new(:integer, Integer(token))
  end

  def parse_float(token)
    Atom.new(:float, Float(token))
  end
end
