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
  ATOM_TYPES = {
    integer: 'Integer',
    float: 'Float',
    boolean: 'Boolean',
    nil: 'Nil',
    symbol: 'Symbol'
  }
  SEXP_TYPES = {
    default: 'Exp',
    predicate: 'Predicate',
    var_def: 'Vardef',
    var_set: 'Setf',
    func_def: 'Funcdef',
    lambda: 'Lambda',
    var_let: 'Let',
    func_let: 'Flet',
    builtin: 'Builtin'
  }
end
