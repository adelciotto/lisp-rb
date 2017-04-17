# This is an unused module for now. The Readline module used in the REPL
# doesn't really give me the flexibility to edit the current input buffer
# and add things like brace match highlighting, which I think would be really
# useful for Lisp. I may end up implementing my own custom Readline module
# that allows me to do this. For now it's on hold.
module BraceMatcher
  def matching_brace_index(input, current_index)
    current_char = input[current_index]

    if current_char == '('
      # ...
    elsif current_char == ')'
      find_index(input, current_index)
    else
      current_index
    end
  end

  private

  def find_index(input, current_index)
    stack = []
    i = 0
    while i < current_index do
      char = input[i]

      stack << i if char == '('
      stack.pop if char == ')'
      i += 1
    end
  end
end
