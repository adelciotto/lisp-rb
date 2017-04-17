require_relative 'repl.rb'

module Lisp
  def self.repl
    Repl.new
  end
end

Lisp.repl
