grammar edu:umn:cs:melt:foil:host:langs:ext;

production printStmt
top::Stmt ::= e::Expr
{
  top.pp = pp"print ${e.pp};";
  forwards to expr(print_(strOp(@e)));
}
production printlnStmt
top::Stmt ::= e::Expr
{
  top.pp = pp"println ${e.pp};";
  forwards to expr(print_(concatOp(strOp(@e), stringLit("\n"))));
}