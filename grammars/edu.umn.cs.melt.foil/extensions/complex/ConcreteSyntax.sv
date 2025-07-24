grammar edu:umn:cs:melt:foil:extensions:complex;

marking terminal Complex_t 'complex' lexer classes cnc:Keyword;
marking terminal Real_t    'real'    precedence=10, lexer classes cnc:Keyword;
marking terminal Imag_t    'imag'    precedence=10, lexer classes cnc:Keyword;

disambiguate Complex_t, cnc:Identifier_t { pluck Complex_t; }
disambiguate Real_t, cnc:Identifier_t { pluck Real_t; }
disambiguate Imag_t, cnc:Identifier_t { pluck Imag_t; }

-- TODO: refactor grammar for MDA
terminal ComplexOp_t '+i' precedence=11, association=left, lexer classes cnc:Operator;

marking terminal ComplexConj_t '~' precedence=11, association = left, lexer classes cnc:Operator;

concrete productions top::cnc:TypeExpr
| 'complex'
  { abstract complexTypeExpr; }

concrete productions top::cnc:Expr
| e::cnc:Expr '+i' e2::cnc:Expr
  { abstract complexLit; }
| 'real' e::cnc:Expr
  { abstract realPart; }
| 'imag' e::cnc:Expr
  { abstract imagPart; }
| '~' e::cnc:Expr
  { abstract complexConj; }
