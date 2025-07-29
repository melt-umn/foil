grammar edu:umn:cs:melt:foil:host:silverconstruction;

-- Silver-to-Foil bridge productions
production quoteGlobalDecl
top::silver:Expr ::= ast::ext:GlobalDecl
{
  top.unparse = s"Foil_GlobalDecl {${concat(explode("\n", show(80, ast.pp)))}}";
  ast.ext:env = ext:emptyEnv();
  ast.ext:declaredEnv = ext:emptyEnv();
  forwards to translate(reflect(^ast.directToCore));
}

production quoteTypeExpr
top::silver:Expr ::= ast::ext:TypeExpr
{
  top.unparse = s"Foil_TypeExpr {${concat(explode("\n", show(80, ast.pp)))}}";
  ast.ext:env = ext:emptyEnv();
  forwards to translate(reflect(^ast.directToCore));
}

production quoteStmt
top::silver:Expr ::= ast::ext:Stmt
{
  top.unparse = s"Foil_Stmt {${concat(explode("\n", show(80, ast.pp)))}}";
  ast.ext:env = ext:emptyEnv();
  ast.ext:returnType = nothing();
  forwards to translate(reflect(^ast.directToCore));
}

production quoteExpr
top::silver:Expr ::= ast::ext:Expr
{
  top.unparse = s"Foil_Expr {${concat(explode("\n", show(80, ast.pp)))}}";
  ast.ext:env = ext:emptyEnv();
  forwards to translate(reflect(^ast.directToCore));
}

-- Foil-to-Silver bridge productions
production antiquoteExtGlobalDecl
top::ext:GlobalDecl ::= e::silver:Expr
{
  top.pp = pp"$$GlobalDecl{${text(e.unparse)}}";
  top.directToCore = antiquoteGlobalDecl(^e);
  top.ext:toCore = error("Should not be demanded");
  top.ext:defs := error("Should not be demanded");
  top.errors := error("Should not be demanded");
}
production antiquoteGlobalDecl
top::core:GlobalDecl ::= e::silver:Expr
{
  top.pp = pp"$$GlobalDecl{${text(e.unparse)}}";
  forwards to error("Should not be demanded");
}

production antiquoteExtTypeExpr
top::ext:TypeExpr ::= e::silver:Expr
{
  top.pp = pp"$$TypeExpr{${text(e.unparse)}}";
  top.directToCore = antiquoteTypeExpr(^e);
  top.ext:toCore = error("Should not be demanded");
  top.ext:liftedDecls = error("Should not be demanded");
  top.errors := error("Should not be demanded");
  top.ext:type = error("Should not be demanded");
}
production antiquoteTypeExpr
top::core:TypeExpr ::= e::silver:Expr
{
  top.pp = pp"$$TypeExpr{${text(e.unparse)}}";
  forwards to error("Should not be demanded");
}

production antiquoteExtParams
top::ext:Param ::= e::silver:Expr
{
  top.pp = pp"$$Params{${text(e.unparse)}}";
  top.directToCore = antiquoteParams(^e);
  top.ext:toCore = error("Should not be demanded");
  top.ext:liftedDecls = error("Should not be demanded");
  top.com:name = error("Should not be demanded");
  top.ext:type = error("Should not be demanded");
  top.errors := error("Should not be demanded");
  top.ext:defs := error("Should not be demanded");
}
production antiquoteParams
top::core:Param ::= e::silver:Expr
{
  top.pp = pp"$$Params{${text(e.unparse)}}";
  forwards to error("Should not be demanded");
}

production antiquoteExtStmt
top::ext:Stmt ::= e::silver:Expr
{
  top.pp = pp"$$Stmt{${text(e.unparse)}}";
  top.directToCore = antiquoteStmt(^e);
  top.ext:toCore = error("Should not be demanded");
  top.ext:liftedDecls = error("Should not be demanded");
  top.ext:defs := error("Should not be demanded");
  top.errors := error("Should not be demanded");
}
production antiquoteStmt
top::core:Stmt ::= e::silver:Expr
{
  top.pp = pp"$$Stmt{${text(e.unparse)}}";
  forwards to error("Should not be demanded");
}

production antiquoteExtExpr
top::ext:Expr ::= e::silver:Expr
{
  top.pp = pp"$$Expr{${text(e.unparse)}}";
  top.directToCore = antiquoteExpr(^e);
  top.ext:toCore = error("Should not be demanded");
  top.ext:liftedDecls = error("Should not be demanded");
  top.errors := error("Should not be demanded");
  top.ext:type = error("Should not be demanded");
}
production antiquoteExpr
top::core:Expr ::= e::silver:Expr
{
  top.pp = pp"$$Expr{${text(e.unparse)}}";
  forwards to error("Should not be demanded");
}

production antiquoteExtExprs
top::ext:Expr ::= e::silver:Expr
{
  top.pp = pp"$$Exprs{${text(e.unparse)}}";
  top.directToCore = antiquoteExprs(^e);
  top.ext:toCore = error("Should not be demanded");
  top.ext:liftedDecls = error("Should not be demanded");
  top.errors := error("Should not be demanded");
  top.ext:type = error("Should not be demanded");
}
production antiquoteExprs
top::core:Expr ::= e::silver:Expr
{
  top.pp = pp"$$Exprs{${text(e.unparse)}}";
  forwards to error("Should not be demanded");
}

production antiquoteName
top::com:Name ::= e::silver:Expr
{
  top.pp = pp"$$Name{${text(e.unparse)}}";
  forwards to error("Should not be demanded");
}
