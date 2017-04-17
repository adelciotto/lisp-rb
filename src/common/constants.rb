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
    'exit' => -> (_) { raise Interrupt.new },
    'and' => -> (args) { args.all? },
    'or' => -> (args) { args.any? }
  }
end
