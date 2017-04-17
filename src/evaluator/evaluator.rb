require_relative '../common/lisp_error.rb'
require_relative '../common/constants.rb'
require_relative '../types/atom.rb'
require_relative '../types/lisp_symbol.rb'
require_relative '../types/expression.rb'
require_relative 'scope.rb'
require_relative 'function.rb'

module Evaluator
  include Constants

  def evaluate(ast_node, scope, eval_quote = false)
    type = ast_node.class.name
    if type == 'Atom'
      ast_node.value
    elsif type == 'LispSymbol'
      val = ast_node.value
      scope.find(val)[val]
    elsif type == 'Expression'
      evaluate_exp(ast_node, scope, eval_quote)
    else
      ast
    end
  end

  def global_scope
    @global_scope ||= Scope.new(initial: operators.merge(functions))
  end

  private

  def operators
    @operators ||= OPERATORS.inject({}) do |res, (key, val)| 
      res.merge({ key => -> (args) { args.reduce(val) } })
    end
  end

  def functions
    @functions ||= FUNCTIONS.inject({}) do |res, (key, val)|
      res.merge({ key => val })
    end
  end

  def evaluate_exp(ast_node, scope, eval_quote = false)
    case ast_node.type
    when Expression::TYPES[:default]
      evaluate_func(ast_node, scope)
    when Expression::TYPES[:builtin]
      evaluate_builtin(ast_node, scope)
    when Expression::TYPES[:predicate]
      evaluate_predicate(ast_node, scope)
    when Expression::TYPES[:var_def]
      evaluate_vardef(ast_node, scope)
    when Expression::TYPES[:var_set]
      evaluate_setf(ast_node, scope)
    when Expression::TYPES[:func_def]
      evaluate_fundef(ast_node, scope)
    when Expression::TYPES[:lambda]
      evaluate_lambda(ast_node, scope)
    when Expression::TYPES[:var_let]
      evaluate_let(ast_node, scope)
    when Expression::TYPES[:func_let]
      evaluate_flet(ast_node, scope)
    when Expression::TYPES[:eval]
      evaluate(ast_node.enhancements[:expression], scope, true)
    when Expression::TYPES[:quote]
      eval_quote ? evaluate(ast_node.children[1], scope) : ast_node
    end
  end

  def evaluate_builtin(node, scope)
    func = evaluate(node.symbol, scope)
    args = evaluate_args(node.children, scope)

    func.(args)
  end

  def evaluate_func(node, scope)
    func = evaluate(node.symbol, scope)
    args = evaluate_args(node.children, scope)

    raise LispError.new("\"#{func.name}\" is not a function") unless func.is_a?(Function)
    raise LispError.new(
      "Incorrect number of arguments supplied to function \"#{func.name}\"\n"\
      "Expected #{func.params.length}, but receieved #{args.length}"
    ) unless func.params.length == args.length

    evaluate(func.body, Scope.new(param_names: func.params, param_values: args, outer: func.scope))
  end

  def evaluate_predicate(node, scope)
    test, true_case, false_case = node.enhancements.values_at(:test, :true_case, :false_case)
    evaluate(test, scope) ? evaluate(true_case, scope) : evaluate(false_case, scope)
  end

  def evaluate_vardef(node, scope)
    var_name, var_val = node.enhancements.values_at(:var_name, :var_val)
    raise LispError.new("#{var_name} is already defined") unless global_scope[var_name].nil?

    global_scope[var_name] = evaluate(var_val, global_scope)
    var_name
  end

  def evaluate_setf(node, scope)
    var_name, var_val = node.enhancements.values_at(:var_name, :var_val)
    raise LispError.new("#{var_name} is not defined") if global_scope[var_name].nil?
    global_scope[var_name] = evaluate(var_val, global_scope)
  end

  def evaluate_fundef(node, scope)
    name, params, body = node.enhancements.values_at(:name, :params, :body)
    global_scope[name] = Function.new(name, params, body, global_scope)
  end

  def evaluate_lambda(node, scope)
    params, body = node.enhancements.values_at(:params, :body)
    Function.new('lambda', params, body, scope)
  end

  def evaluate_let(node, scope)
    vars, body = node.enhancements.values_at(:vars, :body)

    names = vars.map { |var| var[:name] }
    values = vars.map { |var| evaluate(var[:value], scope) }
    lexical_scope = Scope.new(param_names: names, param_values: values, outer: scope)
    evaluate(body, lexical_scope)
  end

  def evaluate_flet(node, scope)
    funcs, body = node.enhancements.values_at(:funcs, :body)
    lexical_scope = Scope.new(outer: scope)

    names = funcs.map { |func| func.enhancements[:name] }
    values = funcs.map { |func| evaluate(func, lexical_scope) }
    evaluate(body, lexical_scope.with_data(names, values))
  end

  def evaluate_args(args, scope)
    args.map { |arg| evaluate(arg, scope) }
  end
end
