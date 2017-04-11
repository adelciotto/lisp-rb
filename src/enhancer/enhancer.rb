require_relative '../common/constants.rb'
require_relative '../common/lisp_error.rb'
require_relative '../types/atom.rb'

module Enhancer
  include Constants

  def enhance(ast)
    if ast.is_a?(Atom)
      ast
    else
      enhance_sexp(ast)
    end
  end

  private

  def enhance_sexp(ast)
    case ast[:sexp_type]
    when SEXP_TYPES[:default]
      enhance_regular(ast)
    when SEXP_TYPES[:predicate]
      enhance_predicate(ast)
    when SEXP_TYPES[:var_def]
      enhance_vardef(ast)
    when SEXP_TYPES[:var_set]
      enhance_vardef(ast)
    when SEXP_TYPES[:func_def]
      enhance_funcdef(ast)
    when SEXP_TYPES[:lambda]
      enhance_lambda(ast)
    when SEXP_TYPES[:var_let]
      enhance_let(ast)
    when SEXP_TYPES[:func_let]
      enhance_flet(ast)
    else
      ast
    end
  end

  def enhance_regular(node)
    assert_args(node[:args].empty?, 'No arguments for expression')

    node[:sexp_type] = SEXP_TYPES[:builtin] if is_builtin?(node[:value][:value])
    node[:args] = node[:args].drop(1).map { |arg| enhance(arg) }
    node
  end

  def enhance_predicate(node)
    assert_args(node[:args].length <= 1, 'No arguments for if predicate')

    _, test, true_case, false_case = node[:args]
    node[:test] = enhance(test)
    node[:true_case] = enhance(true_case)
    node[:false_case] = false_case.nil? ? Atom.new(:nil) : enhance(false_case)

    node.delete(:args)
    node
  end

  def enhance_vardef(node)
    args = node[:args]
    _, var_name, var_val = args
    assert_vardef(args, 3, var_name)

    node[:var_name] = var_name[:value]
    node[:var_val] = enhance(var_val)
    node.delete(:args)
    node
  end

  def enhance_funcdef(node)
    args = node[:args]
    _, func_name, params, body = args
    assert_funcdef(args, 4, func_name)

    node[:name] = func_name[:value]
    enhance_func(node, params, body)
  end

  def enhance_lambda(node)
    assert_args(node[:args].length < 2, 'Invalid lamdba definition')

    _, params, body = node[:args]
    enhance_func(node, params, body)
  end

  def enhance_let(node)
    assert_args(node[:args].length < 3, 'Incomplete let statement')

    _, arg_exp, body = node[:args]
    node[:vars] = arg_exp[:args].map do |sexp|
      args = sexp[:args]
      var_name, var_val = args
      assert_vardef(args, 2, var_name)

      { name: var_name, value: var_val }
    end
    node[:body] = enhance(body)

    node.delete(:args)
    node
  end

  def enhance_flet(node)
    assert_args(node[:args].length < 3, 'Incomplete flet statement')

    _, arg_exp, body = node[:args]
    node[:funcs] = arg_exp[:args].map do |sexp|
      args = sexp[:args]
      func_name, params, func_body = args
      assert_funcdef(args, 3, func_name)

      res = { type: 'Sexp', sexp_type: SEXP_TYPES[:func_def], name: func_name }
      enhance_func(res, params, func_body)
    end
    node[:body] = enhance(body)

    node.delete(:args)
    node
  end

  def enhance_func(node, params, body)
    node[:params] = params[:args] || []
    node[:body] = enhance(body)

    node.delete(:args)
    node
  end

  def is_builtin?(symbol)
    OPERATORS[symbol] || FUNCTIONS[symbol]
  end

  def assert_vardef(args, assert_len, var_name)
    assert_args(args.length != assert_len, "Variable definition \"#{var_name[:value]}\" has no value")
    assert_args(var_name[:type] == 'Atom', 'Invalid variable name')
  end

  def assert_funcdef(args, assert_len, func_name)
    assert_args(args.length != assert_len, "Function definition \"#{func_name[:value]}\" has no value")
    assert_args(func_name[:type] == 'Atom', 'Invalid function name')
  end

  def assert_args(condition, msg)
    raise LispError.new(msg) if condition
  end
end
