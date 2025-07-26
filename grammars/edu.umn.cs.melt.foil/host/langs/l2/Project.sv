grammar edu:umn:cs:melt:foil:host:langs:l2;

imports silver:langutil;
imports silver:langutil:pp;

imports edu:umn:cs:melt:foil:host:common;
imports edu:umn:cs:melt:foil:host:langs:l1;

include edu:umn:cs:melt:foil:host:langs:l1 {
  annotate attributes env, type, types, fields, expectedFields;
  exclude nonterminals Defs, Env, ValueItem, TypeItem, Type;
  exclude attributes defs, declaredEnv, isNumeric, typeExpr, isEqualTo, structFields;
  exclude productions mkAppendGlobalDecl, mkEmptyGlobalDecl, mkSeq, mkEmptyStmt;

  -- Variable declarations are given an explicit type
  exclude productions autoVarDecl;
}

aspect production nameTypeExpr
top::TypeExpr ::= n::Name
{
  n.env = top.env;
}
aspect production var
top::Expr ::= n::Name
{
  n.env = top.env;
}
aspect production structLit
top::Expr ::= n::Name _
{
  n.env = top.env;
}
aspect production arrayLit
top::Expr ::= es::Exprs
{
  production elemType::Type =
    case es.types of
    | t :: _ -> t
    | [] -> errorType()
    end;
}

fun mkAppendGlobalDecl GlobalDecl ::= d1::GlobalDecl d2::GlobalDecl = appendGlobalDecl(d1, d2, env=d1.env);
global mkEmptyGlobalDecl::GlobalDecl = emptyGlobalDecl(env=emptyEnv());
fun mkSeq Stmt ::= s1::Stmt s2::Stmt = seq(s1, s2, env=s1.env);
global mkEmptyStmt::Stmt = emptyStmt(env=emptyEnv());
