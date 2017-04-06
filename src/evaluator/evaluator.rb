require_relative '../common/lisp_error.rb'
require_relative 'scope.rb'
require_relative 'function.rb'

module Evaluator
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

  private

  def evaluate_sexp(ast, scope)
    case ast[:sexp_type]
    when 'Exp'
      evaluate_func(ast, scope)
    when 'Binaryop'
      evaluate_binaryop(ast, scope)
    when 'Predicate'
      test, true_case, false_case = ast.values_at(:test, :true_case, :false_case)
      evaluate(test, scope) ? evaluate(true_case, scope) : evaluate(false_case, scope)
    when 'Vardef'
      var_name, var_val = ast.values_at(:var_name, :var_val)
      scope[var_name] = evaluate(var_val, scope)
    when 'Fundef'
      func_name, params, body = ast.values_at(:func_name, :params, :body)
      scope[func_name] = Function.new(params, body, scope)
    when 'lambda'
      ast
    end
  end

  def evaluate_binaryop(ast, scope)
    func = evaluate(ast[:val], scope)
    args = evaluate_args(ast[:args], scope)
    func.(args)
  end

  def evaluate_func(ast, scope)
    func = evaluate(ast[:val], scope)
    args = evaluate_args(ast[:args], scope)
    evaluate(func.body, Scope.new(func.params, args, func.scope))
  end

  def evaluate_args(args, scope)
    args.map { |arg| evaluate(arg, scope) }
  end
end
