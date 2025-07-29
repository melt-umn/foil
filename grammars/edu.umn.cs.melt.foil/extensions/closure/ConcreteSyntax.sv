grammar edu:umn:cs:melt:foil:extensions:closure;

marking terminal Closure_t 'closure' lexer classes cnc:Keyword;
marking terminal Lambda_t 'lambda' lexer classes cnc:Keyword;

disambiguate Closure_t, cnc:Identifier_t { pluck Closure_t; }
disambiguate Lambda_t, cnc:Identifier_t { pluck Lambda_t; }

terminal ThickArrow_t '=>' precedence=2;

concrete productions top::cnc:TypeExpr
| 'closure' '(' params::cnc:TypeExprs ')' '->' ret::cnc:TypeExpr
{ abstract closureTypeExpr; }

concrete productions top::cnc:Expr
| 'lambda' '(' params::cnc:Params ')' '->' ret::cnc:TypeExpr '{' body::cnc:Stmt '}'
{ abstract lambda; }
| 'lambda' '(' params::cnc:Params ')' '=>' body::cnc:Expr
{ abstract lambdaExpr; }
