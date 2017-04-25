require_relative '../common/builtins.rb'
require_relative '../common/lisp_error.rb'
require_relative '../types/atom.rb'
require_relative '../types/lisp_symbol.rb'
require_relative '../types/expression.rb'

module Enhancer
  include Builtins

  def enhance(ast_node)
    type = ast_node.class.name
    if type == 'Atom' || type == 'LispSymbol'
      ast_node
    elsif type == 'Expression'
      enhance_exp(ast_node)
    end
  end

  private

  def enhance_exp(ast_node)
    case ast_node.type
    when Expression::TYPES[:default]
      enhance_regular(ast_node)
    when Expression::TYPES[:predicate]
      enhance_predicate(ast_node)
    when Expression::TYPES[:var_def]
      enhance_vardef(ast_node)
    when Expression::TYPES[:var_set]
      enhance_vardef(ast_node)
    when Expression::TYPES[:func_def]
      enhance_funcdef(ast_node)
    when Expression::TYPES[:lambda]
      enhance_lambda(ast_node)
    when Expression::TYPES[:var_let]
      enhance_let(ast_node)
    when Expression::TYPES[:func_let]
      enhance_flet(ast_node)
    when Expression::TYPES[:eval]
      enhance_eval(ast_node)
    when Expression::TYPES[:quote]
      ast_node.enhancements[:expression] = enhance(ast_node.children[1])
      ast_node
    else
      ast_node
    end
  end

  def enhance_regular(node)
    raise LispError, 'Illegal function call' if node.children[0].is_a?(Atom)

    node.type = Expression::TYPES[:builtin] if builtin?(node.symbol.value)
    node.children.each { |child| enhance(child) }
    node
  end

  def enhance_predicate(node)
    children = node.children
    assert_args(children.length < 2, 'No arguments for if predicate')

    _, test, true_case, false_case = node.children
    node.enhancements[:test] = enhance(test)
    node.enhancements[:true_case] = enhance(true_case)
    node.enhancements[:false_case] = false_case.nil? ? Atom.new(:nil) : enhance(false_case)

    node
  end

  def enhance_vardef(node)
    args = node.children
    _, var_name, var_val = args
    assert_vardef(args, 3, var_name)

    node.enhancements[:var_name] = var_name.value
    node.enhancements[:var_val] = enhance(var_val)
    node
  end

  def enhance_funcdef(node)
    args = node.children
    _, func_name, params, body = args
    assert_funcdef(args, 4, func_name)

    node.enhancements[:name] = func_name.value
    enhance_func(node, params, body)
  end

  def enhance_lambda(node)
    children = node.children
    assert_args(children.length < 2, 'Invalid lamdba definition')

    _, params, body = children
    enhance_func(node, params, body)
  end

  def enhance_let(node)
    children = node.children
    assert_args(children.length < 3, 'Incomplete let statement')

    _, arg_exp, body = children
    node.enhancements[:vars] = arg_exp.children.map do |sexp|
      args = sexp.children
      var_name, var_val = args
      assert_vardef(args, 2, var_name)

      { name: var_name, value: enhance(var_val) }
    end

    node.enhancements[:body] = enhance(body)
    node
  end

  def enhance_flet(node)
    children = node.children
    assert_args(children.length < 3, 'Incomplete flet statement')

    _, arg_exp, body = children
    node.enhancements[:funcs] = arg_exp.children.map do |sexp|
      args = sexp.children
      func_name, params, func_body = args
      assert_funcdef(args, 3, func_name)

      exp = Expression.new(Expression::TYPES[:lambda])
      exp.enhancements[:name] = func_name
      enhance_func(exp, params, func_body)
    end

    node.enhancements[:body] = enhance(body)
    node
  end

  def enhance_func(node, params, body)
    node.enhancements[:params] =
      if params.is_a?(Atom) && params.type == :nil
        []
      else
        params.children || []
      end

    node.enhancements[:body] = enhance(body)
    node
  end

  def enhance_eval(node)
    children = node.children
    assert_args(children.length < 2, 'No arguments for expression')

    exp = children[1]
    node.enhancements[:expression] =
      if exp.is_a?(Expression) && exp.type == Expression::TYPES[:quote]
        enhance(exp.children[1])
      else
        enhance(exp)
      end

    node
  end

  def builtin?(symbol)
    OPERATORS[symbol] || FUNCTIONS[symbol]
  end

  def assert_vardef(args, assert_len, var_name)
    assert_args(args.length != assert_len, "Variable definition \"#{var_name.value}\" has no value")
    assert_args(var_name.is_a?(Atom), 'Invalid variable name')
  end

  def assert_funcdef(args, assert_len, func_name)
    assert_args(args.length != assert_len, "Function definition \"#{func_name.value}\" has no value")
    assert_args(func_name.is_a?(Atom), 'Invalid function name')
  end

  def assert_args(condition, msg)
    raise LispError.new(msg) if condition
  end
end
