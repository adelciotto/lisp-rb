require_relative 'lisp_error.rb'

module Builtins
  OPERATORS = {
    '+' => ->(args) { operator_fn(:+, args, 0, nil, 0) },
    '-' => ->(args) { operator_fn(:-, args, 1) },
    '*' => ->(args) { operator_fn(:*, args, 0, nil, 1) },
    '/' => ->(args) { operator_fn(:/, args, 1) },
    '%' => ->(args) { operator_fn(:%, args, 2) },
    '**' => ->(args) { operator_fn(:**, args, 1) },
    '>=' => ->(args) { operator_fn(:>=, args, 2, 2) },
    '<=' => ->(args) { operator_fn(:<=, args, 2, 2) },
    '>' => ->(args) { operator_fn(:>, args, 2, 2) },
    '<' => ->(args) { operator_fn(:<, args, 2, 2) },
    '==' => ->(args) { operator_fn(:==, args, 2) }
  }.freeze
  FUNCTIONS = {
    'exit' => ->(_) { raise Interrupt },
    'and' => ->(args) { args.all? },
    'or' => ->(args) { args.any? }
  }.freeze

  def self.operator_fn(op, args, min_args, max_args = nil, default_result = nil)
    len = args.length
    raise LispError, "Too few arguments given to #{op}" unless len >= min_args || min_args == 0
    raise LispError, "Too many arguments given to #{op}" unless max_args.nil? || len <= max_args

    return default_result unless len > min_args || default_result.nil?
    args.reduce(op)
  end
end
