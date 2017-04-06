class Function
  attr_accessor :params, :body, :scope

  def initialize(params, body, scope)
    @params = params
    @body = body
    @scope = scope
  end

  # TODO: to_string overload
end
