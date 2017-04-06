class LispError < StandardError
  def initialize(msg)
    super("Error : #{msg}")
  end

  # TODO: Look into printing a stack trace and more useful error information.
end
