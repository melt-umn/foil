grammar edu:umn:cs:melt:foil:extensions:complex;

terminal Complex_t 'complex' lexer classes cnc:Keyword;

concrete productions top::cnc:TypeExpr
| 'complex'
  { abstract complexTypeExpr; }


