grammar edu:umn:cs:melt:foil:host:langs:ext;

imports silver:langutil;
imports silver:langutil:pp;

imports edu:umn:cs:melt:foil:host:env;
--imports edu:umn:cs:melt:foil:host:langs:core as core;

include edu:umn:cs:melt:foil:host:langs:core {
  close nonterminals GlobalDecl, Stmt, Expr, TypeExpr, Type;
}

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
