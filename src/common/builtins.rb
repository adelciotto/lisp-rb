require_relative 'lisp_error.rb'
require 'pry'

module Builtins
  OPERATORS = {
    '+' => ->(args) { operator_fn(:+, args, 0, 0) },
    '-' => ->(args) { operator_fn(:-, args, 1) },
    '*' => ->(args) { operator_fn(:*, args, 0, 1) },
    '/' => ->(args) { operator_fn(:/, args, 1) },
    '>=' => ->(args) { operator_fn(:>=, args, 1, true) },
    '<=' => ->(args) { operator_fn(:<=, args, 1, true) },
    '>' => ->(args) { operator_fn(:>, args, 1, true) },
    '<' => ->(args) { operator_fn(:<, args, 1, true) },
    '==' => ->(args) { operator_fn(:==, args, 1, true) },
    '%' => ->(args) { operator_fn(:%, args, 2) },
    '**' => ->(args) { operator_fn(:%, args, 1) }
  }.freeze
  FUNCTIONS = {
    'exit' => ->(_) { raise Interrupt },
    'and' => ->(args) { args.all? },
    'or' => ->(args) { args.any? }
  }.freeze

  def self.operator_fn(op, args, min_args, default_result = nil)
    len = args.length
    raise LispError, "Too few arguments given to #{op}" unless len >= min_args || min_args == 0

    return default_result unless len > min_args || default_result.nil?
    args.reduce(op)
  end
end
