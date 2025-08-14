grammar edu:umn:cs:melt:foil:extensions:intconst;

marking terminal IntConst_t 'intconst' lexer classes cnc:Keyword;
disambiguate IntConst_t, cnc:Identifier_t { pluck IntConst_t; }

concrete productions top::cnc:VarDecl
| 'intconst' n::cnc:Name '=' e::cnc:Expr
  { abstract intConstDecl; }
