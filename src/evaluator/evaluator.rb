require_relative '../common/builtins.rb'
require_relative '../common/lisp_error.rb'
require_relative '../types/atom.rb'
require_relative '../types/lisp_symbol.rb'
require_relative '../types/expression.rb'
require_relative 'scope.rb'
require_relative 'function.rb'

module Evaluator
  include Builtins

  def evaluate(ast_node, scope = global_scope)
    type = ast_node.class.name
    if type == 'Atom'
      ast_node.value
    elsif type == 'LispSymbol'
      val = ast_node.value
      scope.find(val)[val]
    elsif type == 'Expression'
      evaluate_exp(ast_node, scope)
    else
      ast_node
    end
  end

  private

  def functions
    @functions ||= FUNCTIONS.inject({}) do |res, (key, val)|
      res.merge(key => val)
    end
  end

  def global_scope
    @global_scope ||= Scope.new(initial: OPERATORS.merge(functions))
  end

  def evaluate_exp(ast_node, scope)
    case ast_node.type
    when Expression::TYPES[:default]
      evaluate_func(ast_node, scope)
    when Expression::TYPES[:builtin]
      evaluate_builtin(ast_node, scope)
    when Expression::TYPES[:predicate]
      evaluate_predicate(ast_node, scope)
    when Expression::TYPES[:var_def]
      evaluate_vardef(ast_node)
    when Expression::TYPES[:var_set]
      evaluate_setf(ast_node)
    when Expression::TYPES[:func_def]
      evaluate_fundef(ast_node)
    when Expression::TYPES[:lambda]
      evaluate_lambda(ast_node, scope)
    when Expression::TYPES[:var_let]
      evaluate_let(ast_node, scope)
    when Expression::TYPES[:func_let]
      evaluate_flet(ast_node, scope)
    when Expression::TYPES[:eval]
      evaluate_eval(ast_node, scope)
    when Expression::TYPES[:quote]
      ast_node
    end
  end

  def evaluate_builtin(node, scope)
    func = evaluate(node.symbol, scope)
    args = evaluate_args(node.children, scope)

    func.call(args)
  end

  def evaluate_func(node, scope)
    func = evaluate(node.symbol, scope)
    args = evaluate_args(node.children, scope)

    raise LispError, "\"#{func.name}\" is not a function" unless func.is_a?(Function)
    unless func.params.length == args.length
      raise LispError,
            "Incorrect number of arguments supplied to function \"#{func.name}\"\n"\
            "Expected #{func.params.length}, but receieved #{args.length}"
    end

    evaluate(func.body, Scope.new(param_names: func.params, param_values: args, outer: func.scope))
  end

  def evaluate_predicate(node, scope)
    test, true_case, false_case = node.enhancements.values_at(:test, :true_case, :false_case)
    evaluate(test, scope) ? evaluate(true_case, scope) : evaluate(false_case, scope)
  end

  def evaluate_vardef(node)
    var_name, var_val = node.enhancements.values_at(:var_name, :var_val)
    raise LispError, "#{var_name} is already defined" unless global_scope[var_name].nil?

    global_scope[var_name] = evaluate(var_val, global_scope)
    var_name
  end

  def evaluate_setf(node)
    var_name, var_val = node.enhancements.values_at(:var_name, :var_val)
    raise LispError, "#{var_name} is not defined" if global_scope[var_name].nil?
    global_scope[var_name] = evaluate(var_val, global_scope)
  end

  def evaluate_fundef(node)
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

  def evaluate_eval(node, scope)
    result = evaluate(node.enhancements[:expression], scope)

    return result unless result.is_a?(Expression) && result.type == Expression::TYPES[:quote]
    evaluate_eval(result, scope)
  end

  def evaluate_args(args, scope)
    args.drop(1).map { |arg| evaluate(arg, scope) }
  end
end
