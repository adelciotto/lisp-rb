require_relative '../common/lisp_error.rb'
require_relative '../common/constants.rb'
require_relative 'scope.rb'
require_relative 'function.rb'

module Evaluator
  include Constants

  def evaluate(ast, scope)
    # TODO: Encapsulate Atom and SExp in classes.
    case ast[:type]
    when 'Symbol'
      val = ast[:val]
      scope.find(val)[val]
    when 'Atom'
      ast[:val]
    when 'Sexp'
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
    func = evaluate(ast[:val], scope)
    args = evaluate_args(ast[:args], scope)

    func.(args)
  end

  def evaluate_func(ast, scope)
    func = evaluate(ast[:val], scope)
    args = evaluate_args(ast[:args], scope)

    raise LispError.new("\"#{func.name}\" is not a function") unless func.is_a?(Function)
    raise LispError.new(
      "Incorrect number of arguments supplied to function \"#{func.name}\"\n"\
      "Expected #{func.params.length}, but receieved #{args.length}"
    ) unless func.params.length == args.length

    evaluate(func.body, Scope.new(params: func.params, args: args, outer: func.scope))
  end

  def evaluate_predicate(ast, scope)
    test, true_case, false_case = ast.values_at(:test, :true_case, :false_case)
    evaluate(test, scope) ? evaluate(true_case, scope) : evaluate(false_case, scope)
  end

  def evaluate_vardef(ast, scope)
    var_name, var_val = ast.values_at(:var_name, :var_val)
    raise LispError.new("#{var_name} is already defined") unless scope[var_name].nil?

    global_scope[var_name] = evaluate(var_val, scope)
    var_name
  end

  def evaluate_setf(ast, scope)
    var_name, var_val = ast.values_at(:var_name, :var_val)
    raise LispError.new("#{var_name} is not defined") if scope[var_name].nil?
    global_scope[var_name] = evaluate(var_val, scope)
  end

  def evaluate_fundef(ast, scope)
    name, params, body = ast.values_at(:name, :params, :body)
    global_scope[name] = Function.new(name, params, body, scope)
  end

  def evaluate_lambda(ast, scope)
    params, body = ast.values_at(:params, :body)
    Function.new('lambda', params, body, scope)
  end

  def evaluate_let(ast, scope)
    vars, body = ast.values_at(:vars, :body)

    params = vars.map { |var| var[:name] }
    args = vars.map { |var| evaluate(var[:val], scope) }
    evaluate(body, Scope.new(params: params, args: args, outer: scope))
  end

  def evaluate_flet(ast, scope)
    funcs, body = ast.values_at(:funcs, :body)

    params = funcs.map { |func| func[:name] }
    args = funcs.map { |func| evaluate(func, scope) }
    evaluate(body, Scope.new(params: params, args: args, outer: scope))
  end

  def evaluate_args(args, scope)
    args.map { |arg| evaluate(arg, scope) }
  end
end
