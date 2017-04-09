module Constants
  OPERATORS = {
    '+'   => :+, 
    '-'   => :-, 
    '*'   => :*, 
    '/'   => :/, 
    '>='  => :>=, 
    '<='  => :<=, 
    '>'   => :>, 
    '<'   => :< ,
    '=='  => :==, 
    '%'   => :%,
    '**'  => :**
  }

  FUNCTIONS = {
    'exit' => -> (args) { raise Interrupt.new },
    'and' => -> (args) { args.all? },
    'or' => -> (args) { args.any? }
  }
end
