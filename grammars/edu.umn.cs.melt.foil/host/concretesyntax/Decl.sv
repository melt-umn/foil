grammar edu:umn:cs:melt:foil:host:concretesyntax;

tracked nonterminal Root with ast<ext:Root>;
concrete productions top::Root
| ds::GlobalDecls
  { abstract ext:root; }

tracked nonterminal GlobalDecls with ast<ext:GlobalDecl>;
concrete productions top::GlobalDecls
| d::GlobalDecl ds::GlobalDecls
  { abstract ext:appendGlobalDecl; }
|
  { abstract ext:emptyGlobalDecl; }

closed tracked nonterminal GlobalDecl with ast<ext:GlobalDecl>;
concrete productions top::GlobalDecl
| d::VarDecl ';'
  { abstract ext:varGlobalDecl; }
| d::FnDecl
  { abstract ext:fnGlobalDecl; }
| d::StructDecl
  { abstract ext:structGlobalDecl; }
| d::UnionDecl
  { abstract ext:unionGlobalDecl; }

closed tracked nonterminal VarDecl with ast<ext:VarDecl>;
concrete productions top::VarDecl
| 'var' n::Name ':' t::TypeExpr '=' e::Expr
  { abstract ext:varDecl; }
| 'var' n::Name '=' e::Expr
  { abstract ext:autoVarDecl; }

closed tracked nonterminal FnDecl with ast<ext:FnDecl>;
concrete productions top::FnDecl
| 'fun' n::Name '(' ps::Params ')' '->' t::TypeExpr '{' body::StmtList '}'
  { abstract ext:fnDecl; }
| 'fun' n::Name '(' ps::Params ')' '{' body::StmtList '}'
  { abstract ext:fnDeclUnit; }

tracked nonterminal Params with ast<ext:Params>;
concrete productions top::Params
| p::Param ',' ps::Params
  { abstract ext:consParam; }
| p::Param
  { top.ast = ext:consParam(p.ast, ext:nilParam()); }
| 
  { abstract ext:nilParam; }

closed tracked nonterminal Param with ast<ext:Param>;
concrete productions top::Param
| n::Name ':' t::TypeExpr
  { abstract ext:param; }

closed tracked nonterminal StructDecl with ast<ext:StructDecl>;
concrete productions top::StructDecl
| 'struct' n::Name '{' fs::Fields '}'
  { abstract ext:structDecl; }

closed tracked nonterminal UnionDecl with ast<ext:UnionDecl>;
concrete productions top::UnionDecl
| 'union' n::Name '{' fs::Fields '}'
  { abstract ext:unionDecl; }
