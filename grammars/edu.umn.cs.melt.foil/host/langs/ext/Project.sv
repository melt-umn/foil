grammar edu:umn:cs:melt:foil:host:langs:ext;

imports silver:langutil;
imports silver:langutil:pp;

imports edu:umn:cs:melt:foil:host:common;
imports edu:umn:cs:melt:foil:host:langs:core as core;

include edu:umn:cs:melt:foil:host:langs:core {
  close nonterminals GlobalDecl, Stmt, Expr, TypeExpr, Type;
}

translation pass toCore to edu:umn:cs:melt:foil:host:langs:core;
monoid translation attribute liftedDecls::core:GlobalDecl
  with core:emptyGlobalDecl(), core:mkAppendGlobalDecl;

attribute toCore occurs on Root, GlobalDecl;
attribute toCore, liftedDecls occurs on
  VarDecl, FnDecl, Params, Param,
  StructDecl, UnionDecl, Fields, Field,
  TypeExpr, TypeExprs,
  Stmt, Expr, Exprs, FieldExprs, FieldExpr;
propagate toCore on Root;
propagate toCore, liftedDecls on
  VarDecl, FnDecl, Params, Param,
  StructDecl, UnionDecl, Fields, Field,
  TypeExpr, TypeExprs,
  Stmt, Expr, Exprs, FieldExprs, FieldExpr;

aspect toCore on GlobalDecl of
| appendGlobalDecl(d1, d2) -> core:mkAppendGlobalDecl(@d1.toCore, @d2.toCore)
| emptyGlobalDecl() -> core:emptyGlobalDecl()
| varGlobalDecl(d) -> core:mkAppendGlobalDecl(@d.liftedDecls, core:varGlobalDecl(@d.toCore))
| fnGlobalDecl(d) -> core:mkAppendGlobalDecl(@d.liftedDecls, core:fnGlobalDecl(@d.toCore))
| structGlobalDecl(d) -> core:mkAppendGlobalDecl(@d.liftedDecls, core:structGlobalDecl(@d.toCore))
| unionGlobalDecl(d) -> core:mkAppendGlobalDecl(@d.liftedDecls, core:unionGlobalDecl(@d.toCore))
end;

production fnDeclUnit
top::FnDecl ::= n::Name params::Params body::Stmt
{
  top.pp = pp"fun ${n}(${ppImplode(pp", ", params.pps)}) {${groupnestlines(2, body.pp)}";
  forwards to fnDecl(@n, @params, unitTypeExpr(), @body);
}

production returnUnit
top::Stmt ::= 
{
  top.pp = pp"return;";
  forwards to return_(unitLit());
}
