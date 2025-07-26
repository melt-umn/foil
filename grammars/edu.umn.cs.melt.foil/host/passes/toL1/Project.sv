grammar edu:umn:cs:melt:foil:host:passes:toL1;

imports silver:langutil;
imports silver:langutil:pp;

imports edu:umn:cs:melt:foil:host:common;
imports edu:umn:cs:melt:foil:host:langs:core;
imports edu:umn:cs:melt:foil:host:langs:l1 as l1;

translation pass toL1
  from edu:umn:cs:melt:foil:host:langs:core
    to edu:umn:cs:melt:foil:host:langs:l1
  excluding appendGlobalDecl, varGlobalDecl, fnGlobalDecl, structGlobalDecl, unionGlobalDecl;

monoid translation attribute liftedDecls::l1:GlobalDecl
  with l1:emptyGlobalDecl(), l1:appendGlobalDecl;
attribute liftedDecls occurs on
  VarDecl, FnDecl, Params, Param,
  StructDecl, UnionDecl, Fields, Field,
  TypeExpr, TypeExprs,
  Stmt, Expr, Exprs, FieldExprs, FieldExpr;

flowtype toL1 {decorate, toL1.decorate} on GlobalDecl;
flowtype toL1 {decorate, liftedDecls.decorate} on
  VarDecl, FnDecl, Params, Param,
  StructDecl, UnionDecl, Fields, Field, TypeExpr, TypeExprs,
  Stmt, Expr, Exprs, FieldExprs, FieldExpr;
flowtype liftedDecls {decorate, liftedDecls.decorate} on
  VarDecl, FnDecl, Params, Param,
  StructDecl, UnionDecl, Fields, Field, TypeExpr, TypeExprs,
  Stmt, Expr, Exprs, FieldExprs, FieldExpr;

propagate liftedDecls on
  VarDecl, FnDecl, Params, Param,
  StructDecl, UnionDecl, Fields, Field,
  TypeExpr, TypeExprs,
  Stmt, Expr, Exprs, FieldExprs, FieldExpr
  excluding recordLit, recordTypeExpr;

aspect toL1 on top::GlobalDecl of
| appendGlobalDecl(d1, d2) -> l1:appendGlobalDecl(@d1.toL1, @d2.toL1)
| varGlobalDecl(d) -> l1:appendGlobalDecl(@d.liftedDecls, l1:varGlobalDecl(@d.toL1))
| fnGlobalDecl(d) -> l1:appendGlobalDecl(@d.liftedDecls, l1:fnGlobalDecl(@d.toL1))
| structGlobalDecl(d) -> l1:appendGlobalDecl(@d.liftedDecls, l1:structGlobalDecl(@d.toL1))
| unionGlobalDecl(d) -> l1:appendGlobalDecl(@d.liftedDecls, l1:unionGlobalDecl(@d.toL1))
end;
