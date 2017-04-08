require_relative '../common/lisp_error.rb'

module Parser
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

    return to_atom('Nil') if list.empty?

    type = case list[0][:val]
    when 'if' 
      'Predicate'
    when 'defvar' 
      'Vardef'
    when 'setf'
      'Setf'
    when 'defun' 
      'Fundef'
    when 'lamdba' 
      'Lambda'
    else 
      'Exp'
    end

    res = { type: 'Sexp', sexp_type: type, args: list }
    res[:val] = list[0] if type == 'Exp'
    res 
  end

  def parse_atom(token)
    to_numeric(token)
  rescue ArgumentError
    case token
    when 'true'
      to_atom('Boolean', true)
    when 'false'
      to_atom('Boolean', false)
    when 'nil'
      to_atom('Nil')
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
    to_atom('Integer', Integer(token))
  end

  def parse_float(token)
    to_atom('Float', Float(token))
  end

  def to_atom(atom_type, val = nil)
    { type: 'Atom', atom_type: atom_type, val: val }
  end
end
