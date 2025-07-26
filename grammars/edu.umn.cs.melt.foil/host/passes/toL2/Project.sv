grammar edu:umn:cs:melt:foil:host:passes:toL2;

imports silver:langutil;
imports silver:langutil:pp;

imports edu:umn:cs:melt:foil:host:common;
imports edu:umn:cs:melt:foil:host:langs:l1;
imports edu:umn:cs:melt:foil:host:langs:l2 as l2;

translation pass toL2
  from edu:umn:cs:melt:foil:host:langs:l1
    to edu:umn:cs:melt:foil:host:langs:l2
  excluding appendGlobalDecl;

flowtype toL2 {decorate} on
  GlobalDecl,
  VarDecl, FnDecl, Params, Param,
  StructDecl, UnionDecl, Fields, Field, TypeExpr, TypeExprs,
  Stmt, Expr, Exprs, FieldExprs, FieldExpr;

-- Flatten extra/empty appendGlobalDecl prods
aspect production appendGlobalDecl
top::GlobalDecl ::= d1::GlobalDecl d2::GlobalDecl
{
  top.toL2 =
    if d1.isEmptyGlobalDecl then @d2.toL2
    else if d2.isEmptyGlobalDecl then @d1.toL2
    else l2:appendGlobalDecl(@d1.toL2, @d2.toL2, env=top.env);
}
