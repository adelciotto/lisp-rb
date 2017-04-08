class Function
  attr_accessor :name, :params, :body, :scope

  def initialize(name, params, body, scope)
    @name = name
    @params = params
    @body = body
    @scope = scope
  end

  def to_s
    "Function: #{name}"
  end
end
