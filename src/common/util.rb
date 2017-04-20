module Util
  def self.strip_extra_whitespace(string)
    string.gsub(/\s\s+/, " ")
  end
end
