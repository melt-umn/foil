grammar edu:umn:cs:melt:foil:host:concretesyntax;

tracked nonterminal StmtList with ast<ext:Stmt>;
concrete productions top::StmtList
| h::Stmt t::StmtList
  { abstract ext:seq; }
|
  { abstract ext:emptyStmt; }

closed tracked nonterminal Stmt with ast<ext:Stmt>;
concrete productions top::Stmt
| '{' sl::StmtList '}'
  { abstract ext:block; }
| ';'
  { abstract ext:emptyStmt; }
| d::VarDecl ';'
  { abstract ext:decl; }
| e::Expr ';'
  { abstract ext:expr; }
| lhs::Expr '=' rhs::Expr ';'
  { abstract ext:assign; }
| 'if' '(' c::Expr ')' t::Stmt
  { top.ast = ext:if_(c.ast, t.ast, ext:emptyStmt()); }
| 'if' '(' c::Expr ')' t::Stmt 'else' e::Stmt
  { abstract ext:if_; }
| 'while' '(' c::Expr ')' s::Stmt
  { abstract ext:while; }
| 'return' e::Expr ';'
  { abstract ext:return_; }
