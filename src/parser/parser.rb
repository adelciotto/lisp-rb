require_relative '../common/lisp_error.rb'
require_relative '../common/constants.rb'

module Parser
  include Constants

  SEXP_TOKENS_MAP = {
    'if' => SEXP_TYPES[:predicate],
    'defvar' => SEXP_TYPES[:var_def],
    'setf' => SEXP_TYPES[:var_set],
    'defun' => SEXP_TYPES[:func_def],
    'lambda' => SEXP_TYPES[:lambda],
    'let' => SEXP_TYPES[:var_let],
    'flet' => SEXP_TYPES[:func_let]
  }

  def parse(tokens)
    raise LispError.new('Unexpected EOF') if tokens.empty?

    token = tokens.shift
    case token
    when '('
      parse_sexp(token, tokens)
    when ')'
      # TODO: Look into highlighting parts of the exp to more easily expose errors.
      raise LispError.new('No matching opening brace "("')
    else
      parse_atom(token)
    end
  end

  private

  def parse_sexp(curr_token, tokens)
    list = []
    until tokens[0] == ')' do 
      list << parse(tokens)
    end
    tokens.shift

    return to_atom(ATOM_TYPES[:nil]) if list.empty?

    type = SEXP_TOKENS_MAP[list[0][:val]] || SEXP_TYPES[:default]
    res = { type: 'Sexp', sexp_type: type, args: list }
    res[:val] = list[0] if type == SEXP_TYPES[:default]
    res 
  end

  def parse_atom(token)
    to_numeric(token)
  rescue ArgumentError
    case token
    when 'true'
      to_atom(ATOM_TYPES[:boolean], true)
    when 'false'
      to_atom(ATOM_TYPES[:boolean], false)
    when 'nil'
      to_atom(ATOM_TYPES[:nil])
    else 
      { type: 'Symbol', val: token }
    end
  end

  def to_numeric(token)
    parse_integer(token)
  rescue ArgumentError
    parse_float(token)
  end

  def parse_integer(token)
    to_atom(ATOM_TYPES[:integer], Integer(token))
  end

  def parse_float(token)
    to_atom(ATOM_TYPES[:float], Float(token))
  end

  def to_atom(atom_type, val = nil)
    { type: 'Atom', atom_type: atom_type, val: val }
  end
end
