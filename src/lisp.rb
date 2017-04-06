require 'readline'
require_relative 'interpreter.rb'

module Lisp
  PROMPT_TEXT = '>>> '
  EVAL_TEXT = ' => '
  private_constant :PROMPT_TEXT, :EVAL_TEXT

  def Lisp.repl
    interpreter = Interpreter.new

    puts 'Press CTRL-C or enter "exit" to quit.'
    begin
      while input = Readline.readline(PROMPT_TEXT)
        raise Interrupt.new if input == 'exit'
        
        next if input.empty?
        result = interpreter.eval_expression(input)
        puts "#{EVAL_TEXT}#{result}" unless result.nil?
      end
    rescue Interrupt
      puts 'Goodbye.'
      exit
    end
  end
end

Lisp.repl
