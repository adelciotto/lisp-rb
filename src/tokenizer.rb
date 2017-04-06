module Tokenizer
  def tokenize(exp)
    exp
      .gsub(/\(/, ' ( ')
      .gsub(/\)/, ' ) ')
      .split
  end

  # TODO: Use more sophisticated tokenising in order to support strings.
end
