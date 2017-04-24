require 'readline'
require_relative '../common/lisp_error.rb'
require_relative '../interpreter.rb'
require_relative '../common/colorize.rb'

class Repl
  PROMPT_TEXT = '>>> '
  EVAL_TEXT = '== '
  private_constant :PROMPT_TEXT, :EVAL_TEXT

  def initialize(prompt = PROMPT_TEXT)
    @interpreter = Interpreter.new
    @prompt = prompt

    # Store the state of the terminal.
    @stty_save = `stty -g`.chomp

    repl_loop
  end

  private

  attr_reader :interpreter, :prompt, :stty_save

  def repl_loop
    puts 'Welcome to lisp.rb'.green
    puts "Press #{'CTRL-C'.green} or enter #{'exit'.green} to quit."
    begin
      while input = readline_with_history
        raise Interrupt.new if input == 'exit'
        next if input.empty?

        evaluate(input)
      end
    rescue Interrupt
      handle_interrupt
    end
  end

  def evaluate(input)
    begin
      expression = interpreter.eval(input)
    rescue LispError => e
      warn e
    ensure
      print_expression(expression)
    end
  end

  def print_expression(expression)
    str = expression.nil? ? 'nil' : expression
    puts "#{EVAL_TEXT}#{str}".green
  end

  def handle_interrupt
    puts 'Goodbye.'.green

    # Restore the state of the terminal
    system('stty', stty_save)
    exit
  end
  
  def readline_with_history
    input = Readline.readline(prompt, true)
    hist = Readline::HISTORY

    hist.pop if input =~ /^\s*$/ || hist.to_a[-2] == input
    input
  end
end
