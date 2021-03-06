require_relative 'tokenizer.rb'
require_relative 'parser/parser.rb'
require_relative 'enhancer/enhancer.rb'
require_relative 'evaluator/evaluator.rb'

class Interpreter
  include Tokenizer
  include Parser
  include Enhancer
  include Evaluator

  def eval(exp)
    tokens = tokenize(exp)
    ast = enhance(parse(tokens))
    evaluate(ast)
  end
end
