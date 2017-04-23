require_relative 'tokenizer.rb'
require_relative 'parser/parser.rb'
require_relative 'enhancer/enhancer.rb'
require_relative 'evaluator/evaluator.rb'
require_relative 'common/lisp_error.rb'

class Interpreter
  include Tokenizer, Parser, Enhancer, Evaluator

  def eval(exp)
    tokens = tokenize(exp)
    ast = enhance(parse(tokens))
    evaluate(ast)
  rescue LispError => e
    warn e
  end
end
