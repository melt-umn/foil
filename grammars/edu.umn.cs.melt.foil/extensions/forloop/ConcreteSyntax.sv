grammar edu:umn:cs:melt:foil:extensions:forloop;

marking terminal For_t 'for' lexer classes cnc:Keyword;
disambiguate For_t, cnc:Identifier_t { pluck For_t; }

concrete productions top::cnc:Stmt
| 'for' '(' n::cnc:Name 'in' e::cnc:Expr ':' e2::cnc:Expr ')' body::cnc:Stmt
  { abstract forLoop; }
