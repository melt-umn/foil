grammar edu:umn:cs:melt:foil:host:concretesyntax;

lexer class Operator;
lexer class Keyword;
lexer class Type extends Keyword;
lexer class Literal;
lexer class Reserved;

terminal Or_t          '||' lexer classes {Operator}, precedence = 5, association = left;
terminal And_t         '&&' lexer classes {Operator}, precedence = 6, association = left;
terminal Not_t         '!'  lexer classes {Operator}, precedence = 7;
terminal GT_t          '>'  lexer classes {Operator}, precedence = 9, association = left;
terminal LT_t          '<'  lexer classes {Operator}, precedence = 9, association = left;
terminal GTEQ_t        '>=' lexer classes {Operator}, precedence = 9, association = left;
terminal LTEQ_t        '<=' lexer classes {Operator}, precedence = 9, association = left;
terminal EQEQ_t        '==' lexer classes {Operator}, precedence = 9, association = left;
terminal NEQ_t         '!=' lexer classes {Operator}, precedence = 9, association = left;
terminal Plus_t        '+'  lexer classes {Operator}, precedence = 11, association = left;
terminal Minus_t       '-'  lexer classes {Operator}, precedence = 11, association = left;
terminal Multiply_t    '*'  lexer classes {Operator}, precedence = 12, association = left;
terminal Divide_t      '/'  lexer classes {Operator}, precedence = 12, association = left;
terminal Modulus_t     '%'  lexer classes {Operator}, precedence = 12, association = left;

terminal Comma_t       ','  ;
terminal LParen_t      '('  precedence = 24;  -- precedence is needed for function application
terminal RParen_t      ')'  precedence = 1, association = left;  -- precedence/association for dangling-else
terminal LCurly_t      '{'  ;
terminal RCurly_t      '}'  ;
terminal LBracket_t    '['  precedence = 24;  -- precedence is needed for array access
terminal RBracket_t    ']'  precedence = 4;   -- precedence is needed for array instance
terminal Dot_t         '.'  precedence = 25, association = left;
terminal Semi_t        ';'  ;
terminal Colon_t       ':'  precedence = 3, association = left;
terminal UnderScore_t  '_'  ;
terminal Arrow_t       '->' precedence = 4;
terminal Equals_t      '='  ;
terminal Question_t    '?'  precedence = 3, association = left;

terminal Var_t         'var'    lexer classes {Keyword, Reserved};
terminal Fun_t         'fun'    lexer classes {Keyword, Reserved};
terminal If_t          'if'     lexer classes {Keyword, Reserved};
terminal Else_t        'else'   lexer classes {Keyword, Reserved}, precedence = 2, association = left;
terminal While_t       'while'  lexer classes {Keyword, Reserved};
terminal Return_t      'return' lexer classes {Keyword, Reserved};
terminal New_t         'new'    lexer classes {Keyword, Reserved}, precedence = 4;
terminal True_t        'true'   lexer classes {Keyword, Reserved};
terminal False_t       'false'  lexer classes {Keyword, Reserved};
terminal Let_t         'let'    lexer classes {Keyword, Reserved};
terminal In_t          'in'     lexer classes {Keyword, Reserved};
terminal End_t         'end'    lexer classes {Keyword, Reserved};
terminal Struct_t      'struct' lexer classes {Keyword, Reserved};
terminal Union_t       'union'  lexer classes {Keyword, Reserved};
terminal Record_t      'record' lexer classes {Keyword, Reserved};

terminal Int_t          'int'    lexer classes {Type, Reserved};
terminal Float_t        'float'  lexer classes {Type, Reserved};
terminal Bool_t         'bool'   lexer classes {Type, Reserved};
terminal String_t       'string' lexer classes {Type, Reserved};
terminal Unit_t         'unit'   lexer classes {Type, Reserved};

terminal Identifier_t    /[a-zA-Z_][a-zA-Z0-9_]*/ submits to Reserved;

terminal IntLit_t       /[0-9]+/          lexer classes {Literal};
terminal FloatLit_t     /[0-9]+\.[0-9]+/  lexer classes {Literal};
terminal StringLit_t    /"([^"\\]|\\.)*"/ lexer classes {Literal};

ignore terminal Whitespace_t   /[\n\r\t ]+/;
ignore terminal LineComment_t  /\/\/.*/;
ignore terminal BlockComment_t /\/\*([^*]|\*\/)*\*\//;

closed tracked nonterminal Name with ast<com:Name>;
concrete production name
top::Name ::= id::Identifier_t
{ top.ast = com:name(id.lexeme); }
