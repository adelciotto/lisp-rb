require 'readline'
require_relative 'interpreter.rb'
require_relative 'common/colorize.rb'
require 'pry'

module Lisp
  PROMPT_TEXT = '>>> '
  EVAL_TEXT = '== '
  private_constant :PROMPT_TEXT, :EVAL_TEXT

  def self.repl
    interpreter = Interpreter.new

    # Store the state of the terminal.
    stty_save = `stty -g`.chomp

    puts 'Press CTRL-C or enter "exit" to quit.'
    begin
      while input = readline_with_history(PROMPT_TEXT)
        raise Interrupt.new if input == 'exit'
        
        next if input.empty?
        result = interpreter.eval_expression(input)
        puts "#{EVAL_TEXT}#{result}".green unless result.nil?
      end
    rescue Interrupt
      puts 'Goodbye.'.green
      system('stty', stty_save) # Restore
      exit
    end
  end

  def self.readline_with_history(prompt)
    input = Readline.readline(prompt, true)
    hist = Readline::HISTORY

    hist.pop if input =~ /^\s*$/ || hist.to_a[-2] == input
    input
  end
end

Lisp.repl
