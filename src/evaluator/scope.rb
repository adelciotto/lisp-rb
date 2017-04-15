require_relative '../common/lisp_error.rb'

class Scope
  def initialize(param_names: [], param_values: [], outer: nil, initial: {})
    with_data(param_names, param_values, initial)
    @outer = outer
  end

  def find(var)
    if data.has_key?(var)
      data
    else
      raise LispError.new("Cannot evaluate #{var}") if outer.nil?
      outer.find(var)
    end
  end

  def with_data(param_names, param_values, initial = nil)
    params = param_names.map { |param| param.value }
    @data = transform_params(params, param_values, initial || data)
    self
  end

  def [](key)
    data[key]
  end

  def []=(key, val)
    data[key] = val
  end

  private 
  attr_accessor :data, :outer

  def transform_params(param_names, param_values, initial)
    initial.merge(Hash[param_names.zip(param_values)])
  end
end
