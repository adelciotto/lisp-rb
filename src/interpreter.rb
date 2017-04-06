require_relative 'tokenizer.rb'
require_relative 'parser/parser.rb'
require_relative 'enhancer/enhancer.rb'
require_relative 'evaluator/evaluator.rb'
require_relative 'common/constants.rb'
require_relative 'common/lisp_error.rb'
require 'pry'

class Interpreter
  include Constants, Tokenizer, Parser, Enhancer, Evaluator

  def eval_expression(exp)
    tokens = tokenize(exp)
    ast = enhance(parse(tokens))
    evaluate(ast, scope)
  rescue LispError => e
    puts e
  end

  private

  def scope
    @scope ||= Scope.new(initial: global_scope)
  end

  def global_scope
    @global_scope ||= OPERATORS.inject({}) do |res, (key, val)| 
      res.merge({ key => -> (args) { args.reduce(val) } })
    end
  end

end
