require_relative '../common/constants.rb'
require_relative '../common/lisp_error.rb'

module Enhancer
  include Constants

  def enhance(ast)
    if ast[:type] == 'Sexp'
      enhance_sexp(ast)
    else
      ast
    end
  end

  private

  def enhance_sexp(ast)
    case ast[:sexp_type]
    when 'Exp'
      enhance_regular(ast)
    when 'Predicate'
      enhance_predicate(ast)
    when 'Vardef'
      enhance_vardef(ast)
    when 'Setf'
      enhance_vardef(ast)
    when 'Fundef'
      enhance_funcdef(ast)
    when 'Lambda'
      enhance_lambda(ast)
    when 'Let'
      enhance_let(ast)
    else
      ast
    end
  end

  def enhance_regular(node)
    assert_args(node[:args].empty?, 'No arguments for expression')

    node[:sexp_type] = 'Binaryop' unless OPERATORS[node[:val][:val]].nil?
    node[:args] = node[:args].drop(1).map { |arg| enhance(arg) }
    node
  end

  def enhance_predicate(node)
    assert_args(node[:args].length <= 1, 'No arguments for if predicate')

    _, test, true_case, false_case = node[:args]
    node[:test] = enhance(test)
    node[:true_case] = enhance(true_case)
    node[:false_case] = false_case.nil? ? { type: 'Atom', atom_type: 'Nil' } : enhance(false_case)

    node.delete(:args)
    node
  end

  def enhance_vardef(node)
    args = node[:args]
    _, var_name, var_val = args
    assert_vardef(args, 3, var_name)

    node[:var_name] = var_name[:val]
    node[:var_val] = enhance(var_val)
    node.delete(:args)
    node
  end

  def enhance_funcdef(node)
    assert_args(node[:args].length < 3, 'Invalid function definition')

    _, func_name, params, body = node[:args]
    node[:func_name] = func_name[:val]
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
    node[:var_bindings] = arg_exp[:args].map do |sexp|
      args = sexp[:args]
      var_name, var_val = args
      assert_vardef(args, 2, var_name)

      { var_name: var_name, var_val: var_val }
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

  def assert_vardef(args, assert_len, var_name)
    assert_args(args.length != assert_len, "Variable definition \"#{var_name[:val]}\" has no value")
    assert_args(var_name[:type] == 'Atom', 'Invalid variable name')
  end

  def assert_args(condition, msg)
    raise LispError.new(msg) if condition
  end
end
