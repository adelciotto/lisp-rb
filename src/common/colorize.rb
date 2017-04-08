class String
  RED_CODE = 31
  GREEN_CODE = 32
  YELLOW_CODE = 33
  private_constant :RED_CODE, :GREEN_CODE, :YELLOW_CODE

  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(RED_CODE)
  end

  def green
    colorize(GREEN_CODE)
  end

  def yellow
    colorize(YELLOW_CODE)
  end
end
