require_relative '../common/lisp_error.rb'
require_relative '../common/constants.rb'
require_relative '../types/atom.rb'
require_relative '../types/lisp_symbol.rb'
require_relative 'scope.rb'
require_relative 'function.rb'

module Evaluator
  include Constants

  def evaluate(ast, scope)
    # TODO: Encapsulate Atom and SExp in classes.
    if ast.is_a?(Atom)
      ast.value
    elsif ast.is_a?(LispSymbol)
      val = ast.value
      scope.find(val)[val]
    elsif ast[:type] == 'Sexp'
      evaluate_sexp(ast, scope)
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

  def evaluate_sexp(ast, scope)
    case ast[:sexp_type]
    when SEXP_TYPES[:default]
      evaluate_func(ast, scope)
    when SEXP_TYPES[:builtin]
      evaluate_builtin(ast, scope)
    when SEXP_TYPES[:predicate]
      evaluate_predicate(ast, scope)
    when SEXP_TYPES[:var_def]
      evaluate_vardef(ast, scope)
    when SEXP_TYPES[:var_set]
      evaluate_setf(ast, scope)
    when SEXP_TYPES[:func_def]
      evaluate_fundef(ast, scope)
    when SEXP_TYPES[:lambda]
      evaluate_lambda(ast, scope)
    when SEXP_TYPES[:var_let]
      evaluate_let(ast, scope)
    when SEXP_TYPES[:func_let]
      evaluate_flet(ast, scope)
    end
  end

  def evaluate_builtin(ast, scope)
    func = evaluate(ast[:value], scope)
    args = evaluate_args(ast[:args], scope)

    func.(args)
  end

  def evaluate_func(ast, scope)
    func = evaluate(ast[:value], scope)
    args = evaluate_args(ast[:args], scope)

    raise LispError.new("\"#{func.name}\" is not a function") unless func.is_a?(Function)
    raise LispError.new(
      "Incorrect number of arguments supplied to function \"#{func.name}\"\n"\
      "Expected #{func.params.length}, but receieved #{args.length}"
    ) unless func.params.length == args.length

    evaluate(func.body, Scope.new(param_names: func.params, param_values: args, outer: func.scope))
  end

  def evaluate_predicate(ast, scope)
    test, true_case, false_case = ast.values_at(:test, :true_case, :false_case)
    evaluate(test, scope) ? evaluate(true_case, scope) : evaluate(false_case, scope)
  end

  def evaluate_vardef(ast, scope)
    var_name, var_val = ast.values_at(:var_name, :var_val)
    raise LispError.new("#{var_name} is already defined") unless global_scope[var_name].nil?

    global_scope[var_name] = evaluate(var_val, global_scope)
    var_name
  end

  def evaluate_setf(ast, scope)
    var_name, var_val = ast.values_at(:var_name, :var_val)
    raise LispError.new("#{var_name} is not defined") if global_scope[var_name].nil?
    global_scope[var_name] = evaluate(var_val, global_scope)
  end

  def evaluate_fundef(ast, scope)
    name, params, body = ast.values_at(:name, :params, :body)
    global_scope[name] = Function.new(name, params, body, global_scope)
  end

  def evaluate_lambda(ast, scope)
    params, body = ast.values_at(:params, :body)
    Function.new('lambda', params, body, scope)
  end

  def evaluate_let(ast, scope)
    vars, body = ast.values_at(:vars, :body)

    names = vars.map { |var| var[:name] }
    values = vars.map { |var| evaluate(var[:value], scope) }
    lexical_scope = Scope.new(param_names: names, param_values: values, outer: scope)
    evaluate(body, lexical_scope)
  end

  def evaluate_flet(ast, scope)
    funcs, body = ast.values_at(:funcs, :body)
    lexical_scope = Scope.new(outer: scope)

    names = funcs.map { |func| func[:name] }
    values = funcs.map { |func| evaluate(func, lexical_scope) }
    evaluate(body, lexical_scope.with_data(names, values))
  end

  def evaluate_args(args, scope)
    args.map { |arg| evaluate(arg, scope) }
  end
end
