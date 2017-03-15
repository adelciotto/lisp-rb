require 'bigdecimal'
require 'readline'

class LispError < StandardError
  def initialize(type, msg='Parse Error')
    msg = "#{type}: #{msg}"
    super(msg)
  end
end

class Scope
  def initialize(params=[], args=[], outer=nil, initial: {})
    @data = initial.merge(Hash[params.zip(args)])
    @outer = outer
  end

  def find(var)
    if data.has_key?(var)
      data
    else
      raise LispError.new('Evaluate Error', "Cannot evaluate #{var}") if outer.nil?
      outer.find(var)
    end
  end

  def [](key)
    data[key]
  end

  def []=(key, val)
    data[key] = val
  end

  private 
  attr_accessor :data, :outer
end

class Function
  def initialize(params, body, scope)
    @params = params
    @body = body
    @scope = scope
  end

  def method_missing(symbol, args)
    evaluate(body, Scope.new(params, args, scope))
  end

  private 
  attr_accessor :params, :body, :scope
end

def global_scope
  ops = [:+, :-, :*, :/, :>, :>=, :<, :<=, :==, :%, :**]
  ops.inject({}) do |res, op| 
    res.merge({ op.to_s => -> (args) { args.reduce(op) } })
  end
end

def tokenize(program)
  program
    .gsub(/\(/, ' ( ')
    .gsub(/\)/, ' ) ')
    .split
end

def to_numeric(str)
  num = BigDecimal.new(str)
  num.frac == 0 ? num.to_i : num.to_f
end

def parse_token(token)
  to_numeric(token)
rescue ArgumentError
  case token
  when 'true'
    true
  when 'false'
    false
  when 'nil'
    nil
  else
    token
  end
end

def parse(tokens)
  raise LispError.new('Parse Error', 'Unexpected EOF') if tokens.empty?

  token = tokens.shift
  case token
  when '('
    list = []
    until tokens[0] == ')' do list << parse(tokens) end
    tokens.shift
    list
  when ')'
    raise LispError.new('Parse Error', 'No matching opening brace "("')
  else
    parse_token(token)
  end
end

def is_if?(exp)
  exp[0] == 'if'
end

def is_def?(exp)
  exp[0] == 'def'
end

def is_lambda?(exp)
  exp[0] == 'lambda' || exp[0] == '=>'
end

def enhance(exp, scope)
  if exp.nil?
    nil
  elsif exp == 'exit'
    exp = [['exit']]
  elsif exp.is_a? Array
    exp.empty? ? nil : exp
  else
    exp
  end
end

def evaluate(exp, scope)
  if exp.nil?
    nil 
  elsif exp.is_a? String
    scope.find(exp)[exp]
  elsif is_if?(exp)
    _, test, true_case, false_case = exp
    res = evaluate(test, scope) ? true_case : false_case
    evaluate(res, scope)
  elsif is_def?(exp)
    _, var, res = exp
    scope[var] = evaluate(res, scope)
  elsif is_lambda?(exp) 
    _, params, body = exp
    Function.new(params, body, scope)
  elsif exp[0] == 'exit'
    exit
  elsif exp.is_a? Array
    if exp.length == 1
      evaluate(exp [0], scope)
    else
      func = evaluate(exp[0], scope)
      args = exp.drop(1).map { |arg| evaluate(arg, scope) }
      func.(args)
    end
  else
    exp
  end
end

def repl
  scope = Scope.new(initial: global_scope)
  begin
    while buf = Readline.readline('lisp.rb> ', true)
      begin
        next if buf.empty?
        exp = parse(tokenize(buf))
        result = evaluate(enhance(exp, scope), scope)

        puts "--> #{result}"
      rescue LispError => e
        puts "--> #{e.message}"
      end
    end
  rescue Interrupt
    exit
  end
end

repl
