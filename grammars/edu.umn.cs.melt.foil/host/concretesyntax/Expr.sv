grammar edu:umn:cs:melt:foil:host:concretesyntax;

closed tracked nonterminal Expr with ast<ext:Expr>;
concrete productions top::Expr
| n::Name
  { abstract ext:var; }
| '(' e::Expr ')'
  { top.ast = e.ast; }
| 'let' d::VarDecl 'in' e::Expr 'end'
  { abstract ext:let_; }
| f::Expr '(' a::Exprs ')'
  { abstract ext:call; }
| 'record' '{' fs::FieldExprs '}'
  { abstract ext:recordLit; }
| n::Name '{' fs::FieldExprs '}'
  { abstract ext:structLit; }
| e1::Expr '.' n::Name
  { abstract ext:fieldAccess; }

| i::IntLit_t
  { top.ast = ext:intLit(toInteger(i.lexeme)); }
| f::FloatLit_t
  { top.ast = ext:floatLit(toFloat(f.lexeme)); }
| 'true'
  { abstract ext:trueLit; }
| 'false'
  { abstract ext:falseLit; }
| s::StringLit_t
  { top.ast = ext:stringLit(unescapeString(substring(1, length(s.lexeme) - 1, s.lexeme))); }
| '(' ')'
  { abstract ext:unitLit; }

| c::Expr '?' t::Expr ':' e::Expr
  { abstract ext:cond; }

-- TODO: Refactor the grammar to allow for extension operators
| '-' e::Expr
  { abstract ext:negOp; }
| e1::Expr '+' e2::Expr
  { abstract ext:addOp; }
| e1::Expr '-' e2::Expr
  { abstract ext:subOp; }
| e1::Expr '*' e2::Expr
  { abstract ext:mulOp; }
| e1::Expr '/' e2::Expr
  { abstract ext:divOp; }
| e1::Expr '%' e2::Expr
  { abstract ext:modOp; }
| e1::Expr '==' e2::Expr
  { abstract ext:eqOp; }
| e1::Expr '!=' e2::Expr
  { abstract ext:neqOp; }
| e1::Expr '<' e2::Expr
  { abstract ext:ltOp; }
| e1::Expr '<=' e2::Expr
  { abstract ext:lteOp; }
| e1::Expr '>' e2::Expr
  { abstract ext:gtOp; }
| e1::Expr '>=' e2::Expr
  { abstract ext:gteOp; }
| e1::Expr '&&' e2::Expr
  { abstract ext:andOp; }
| e1::Expr '||' e2::Expr
  { abstract ext:orOp; }
| '!' e::Expr
  { abstract ext:notOp; }

tracked nonterminal Exprs with ast<ext:Exprs>;
concrete productions top::Exprs
| e::Expr ',' es::Exprs
  { abstract ext:consExpr; }
| e::Expr
  { top.ast = ext:consExpr(e.ast, ext:nilExpr()); }
| 
  { abstract ext:nilExpr; }

tracked nonterminal FieldExprs with ast<ext:FieldExprs>;
concrete productions top::FieldExprs
| e::FieldExpr ',' es::FieldExprs
  { abstract ext:consFieldExpr; }
| e::FieldExpr
  { top.ast = ext:consFieldExpr(e.ast, ext:nilFieldExpr()); }
| 
  { abstract ext:nilFieldExpr; }

closed tracked nonterminal FieldExpr with ast<ext:FieldExpr>;
concrete productions top::FieldExpr
| n::Name '=' e::Expr
  { abstract ext:fieldExpr; }
