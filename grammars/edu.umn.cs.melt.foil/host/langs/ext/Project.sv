grammar edu:umn:cs:melt:foil:host:langs:ext;

imports silver:langutil;
imports silver:langutil:pp;

imports edu:umn:cs:melt:foil:host:common;
imports edu:umn:cs:melt:foil:host:langs:core as core;

include edu:umn:cs:melt:foil:host:langs:core {
  close nonterminals GlobalDecl, Stmt, Expr, TypeExpr, Type, ValueItem, TypeItem;
}

translation pass toCore
  from edu:umn:cs:melt:foil:host:langs:ext
    to edu:umn:cs:melt:foil:host:langs:core
  excluding
    varGlobalDecl, fnGlobalDecl, structGlobalDecl, unionGlobalDecl,
    call, strOp;

monoid translation attribute liftedDecls::core:GlobalDecl
  with core:emptyGlobalDecl(), core:appendGlobalDecl;
attribute liftedDecls occurs on
  VarDecl, FnDecl, Params, Param,
  StructDecl, UnionDecl, Fields, Field,
  TypeExpr, TypeExprs,
  Stmt, Expr, Exprs, FieldExprs, FieldExpr;
propagate liftedDecls on
  VarDecl, FnDecl, Params, Param,
  StructDecl, UnionDecl, Fields, Field,
  TypeExpr, TypeExprs,
  Stmt, Expr, Exprs, FieldExprs, FieldExpr;

aspect toCore on GlobalDecl of
| varGlobalDecl(d) -> core:appendGlobalDecl(@d.liftedDecls, core:varGlobalDecl(@d.toCore))
| fnGlobalDecl(d) -> core:appendGlobalDecl(@d.liftedDecls, core:fnGlobalDecl(@d.toCore))
| structGlobalDecl(d) -> core:appendGlobalDecl(@d.liftedDecls, core:structGlobalDecl(@d.toCore))
| unionGlobalDecl(d) -> core:appendGlobalDecl(@d.liftedDecls, core:unionGlobalDecl(@d.toCore))
end;
