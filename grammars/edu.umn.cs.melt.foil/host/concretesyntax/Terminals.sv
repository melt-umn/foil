grammar edu:umn:cs:melt:foil:host:concretesyntax;

lexer class Operator;
lexer class Keyword;
lexer class Type extends Keyword;
lexer class Literal;

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
terminal RParen_t      ')'  ;
terminal LCurly_t      '{'  ;
terminal RCurly_t      '}'  ;
terminal Dot_t         '.'  precedence = 25, association = left;
terminal Semi_t        ';'  ;
terminal Colon_t       ':'  ;
terminal UnderScore_t  '_'  ;
terminal Arrow_t       '->' ;
terminal Equals_t      '='  ;
terminal Question_t    '?'  precedence = 3;

terminal Var_t         'var'    lexer classes {Keyword};
terminal Fun_t         'fun'    lexer classes {Keyword};
terminal If_t          'if'     lexer classes {Keyword};
terminal Else_t        'else'   lexer classes {Keyword};
terminal While_t       'while'  lexer classes {Keyword};
terminal Return_t      'return' lexer classes {Keyword};
terminal True_t        'true'   lexer classes {Keyword};
terminal False_t       'false'  lexer classes {Keyword};
terminal Let_t         'let'    lexer classes {Keyword};
terminal In_t          'in'     lexer classes {Keyword};
terminal End_t         'end'    lexer classes {Keyword};

terminal Int_t          'int'    lexer classes {Type};
terminal Float_t        'float'  lexer classes {Type};
terminal Bool_t         'bool'   lexer classes {Type};
terminal String_t       'string' lexer classes {Type};

terminal Identifier_t    /[a-zA-Z_][a-zA-Z0-9_]*/ submits to Keyword;

terminal IntLit_t       /[0-9]+/          lexer classes {Literal};
terminal FloatLit_t     /[0-9]+\.[0-9]+/  lexer classes {Literal};
terminal StringLit_t    /"([^"\\]|\\.)*"/ lexer classes {Literal};

ignore terminal Whitespace_t   /[\n\r\t ]+/;
ignore terminal LineComment_t  /\/\/.*/;
ignore terminal BlockComment_t /\/\*([^*]|\*\/)*\*\//;

closed tracked nonterminal Name with ast<ext:Name>;
concrete production name
top::Name ::= id::Identifier_t
{ top.ast = ext:name(id.lexeme); }
