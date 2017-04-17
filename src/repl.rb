require 'readline'
require_relative 'interpreter.rb'
require_relative 'common/colorize.rb'

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

  attr_accessor :interpreter, :prompt, :stty_save

  def repl_loop
    puts 'Press CTRL-C or enter "exit" to quit.'
    begin
      while input = readline_with_history
        raise Interrupt.new if input == 'exit'
        next if input.empty?

        expression = interpreter.eval(input)
        print_expression(expression)
      end
    rescue Interrupt
      handle_interrupt
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
