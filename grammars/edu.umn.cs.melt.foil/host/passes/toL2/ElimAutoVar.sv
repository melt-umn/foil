grammar edu:umn:cs:melt:foil:host:passes:toL2;

aspect production autoVarDecl
top::VarDecl ::= n::Name i::Expr
{
  local ty::TypeExpr = i.type.typeExpr;
  ty.env = top.env;
  top.toL2 = l2:varDecl(^n, @ty.toL2, @i.toL2, env=top.env, type=top.type);
}