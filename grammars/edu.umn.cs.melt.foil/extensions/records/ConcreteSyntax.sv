grammar edu:umn:cs:melt:foil:extensions:records;

marking terminal Record_t 'record' lexer classes cnc:Keyword;

disambiguate Record_t, cnc:Identifier_t { pluck Record_t; }

concrete productions top::cnc:TypeExpr
| 'record' '{' fields::cnc:Fields '}'
  { abstract recordTypeExpr; }

concrete productions top::cnc:Expr
| 'record' '{' fields::cnc:FieldExprs '}'
  { abstract recordLit; }
