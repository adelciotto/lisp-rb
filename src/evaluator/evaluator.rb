require_relative '../common/lisp_error.rb'
require_relative '../common/constants.rb'
require_relative 'scope.rb'
require_relative 'function.rb'

module Evaluator
  include Constants

  def evaluate(ast, scope)
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
    when 'Exp'
      evaluate_func(ast, scope)
    when 'Builtin'
      evaluate_builtin(ast, scope)
    when 'Predicate'
      evaluate_predicate(ast, scope)
    when 'Vardef'
      evaluate_vardef(ast, scope)
    when 'Setf'
      evaluate_setf(ast, scope)
    when 'Fundef'
      evaluate_fundef(ast, scope)
    when 'Lambda'
      evaluate_lambda(ast, scope)
    when 'Let'
      evaluate_let(ast, scope)
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
    func_name, params, body = ast.values_at(:func_name, :params, :body)
    global_scope[func_name] = Function.new(func_name, params, body, scope)
  end

  def evaluate_lambda(ast, scope)
    params, body = ast.values_at(:params, :body)
    Function.new('lambda', params, body, scope)
  end

  def evaluate_let(ast, scope)
    var_bindings, body = ast.values_at(:var_bindings, :body)

    params = var_bindings.map { |var_binding| var_binding[:var_name] }
    args = var_bindings.map { |var_binding| evaluate(var_binding[:var_val], scope) }
    evaluate(body, Scope.new(params: params, args: args, outer: scope))
  end

  def evaluate_args(args, scope)
    args.map { |arg| evaluate(arg, scope) }
  end
end
