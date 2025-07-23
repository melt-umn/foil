grammar edu:umn:cs:melt:foil:host:concretesyntax;

closed tracked nonterminal TypeExpr with ast<ext:TypeExpr>;
concrete productions top::TypeExpr
| 'int'
  { abstract ext:intTypeExpr; }
| 'float'
  { abstract ext:floatTypeExpr; }
| 'bool'
  { abstract ext:boolTypeExpr; }
| 'string'
  { abstract ext:stringTypeExpr; }
| 'unit'
  { abstract ext:unitTypeExpr; }
| t::TypeExpr '*'
  { abstract ext:pointerTypeExpr; }
| t::TypeExpr '[' ']'
  { abstract ext:arrayTypeExpr; }
| '{' fs::Fields '}'
  { abstract ext:recordTypeExpr; }
| '(' args::TypeExprs ')' '->' ret::TypeExpr
  { abstract ext:fnTypeExpr; }

tracked nonterminal TypeExprs with ast<ext:TypeExprs>;
concrete productions top::TypeExprs
| h::TypeExpr ',' fs::TypeExprs
  { abstract ext:consTypeExpr; }
| h::TypeExpr
  { top.ast = ext:consTypeExpr(h.ast, ext:nilTypeExpr()); }
| 
  { abstract ext:nilTypeExpr; }

tracked nonterminal Fields with ast<ext:Fields>;
concrete productions top::Fields
| h::Field ',' fs::Fields
  { abstract ext:consField; }
| h::Field
  { top.ast = ext:consField(h.ast, ext:nilField()); }
| 
  { abstract ext:nilField; }

closed tracked nonterminal Field with ast<ext:Field>;
concrete productions top::Field
| n::Name ':' t::TypeExpr
  { abstract ext:field; }
