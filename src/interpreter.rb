require_relative 'tokenizer.rb'
require_relative 'parser/parser.rb'
require_relative 'enhancer/enhancer.rb'
require_relative 'evaluator/evaluator.rb'
require_relative 'common/constants.rb'
require_relative 'common/lisp_error.rb'

class Interpreter
  include Constants, Tokenizer, Parser, Enhancer, Evaluator

  def eval_expression(exp)
    tokens = tokenize(exp)
    ast = enhance(parse(tokens))
    evaluate(ast, global_scope)
  rescue LispError => e
    puts e
  end

  private

  def global_scope
    @global_scope ||= Scope.new(initial: operators.merge(functions))
  end

  def operators
    OPERATORS.inject({}) do |res, (key, val)| 
      res.merge({ key => -> (args) { args.reduce(val) } })
    end
  end

  def functions
    FUNCTIONS.inject({}) do |res, (key, val)|
      res.merge({ key => val })
    end
  end
end
