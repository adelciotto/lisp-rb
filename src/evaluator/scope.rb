require_relative '../common/lisp_error.rb'

class Scope
  def initialize(params: [], args: [], outer: nil, initial: {})
    param_values = params.map { |param| param[:value] }
    @data = initial.merge(Hash[param_values.zip(args)])
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

  def [](key)
    data[key]
  end

  def []=(key, val)
    data[key] = val
  end

  private 
  attr_accessor :data, :outer
end
