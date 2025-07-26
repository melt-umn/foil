grammar edu:umn:cs:melt:foil:host:langs:core;

tracked nonterminal Root with pp, errors;
propagate errors on Root;

production root
top::Root ::= d::GlobalDecl
{
  top.pp = d.pp;
  d.env = addEnv(d.defs, emptyEnv());
  d.declaredEnv = emptyEnv();
}

inherited attribute declaredEnv::Env;  -- Env defs declared so far
synthesized attribute isEmptyGlobalDecl::Boolean;

tracked nonterminal GlobalDecl with pp, isEmptyGlobalDecl, env, declaredEnv, defs, errors;
propagate env, defs, errors on GlobalDecl;

aspect default production
top::GlobalDecl ::=
{
  top.isEmptyGlobalDecl = false;
}
production appendGlobalDecl
top::GlobalDecl ::= d1::GlobalDecl d2::GlobalDecl
{
  top.pp = pp"${d1}\n${d2}";
  top.isEmptyGlobalDecl = d1.isEmptyGlobalDecl && d2.isEmptyGlobalDecl;
  d1.declaredEnv = top.declaredEnv;
  d2.declaredEnv = addEnv(d1.defs, d1.declaredEnv);
}
production emptyGlobalDecl
top::GlobalDecl ::=
{
  top.pp = pp"";
  top.isEmptyGlobalDecl = true;
}
production varGlobalDecl
top::GlobalDecl ::= d::VarDecl
{
  top.pp = d.pp;
  top.errors <-
    if d.initExpr.isConstant then []
    else [errFromOrigin(d.initExpr, s"Global var ${d.name} must be initialized with a constant expression")];
}
production fnGlobalDecl
top::GlobalDecl ::= d::FnDecl
{
  top.pp = d.pp;
}
production structGlobalDecl
top::GlobalDecl ::= d::StructDecl
{
  top.pp = d.pp;
}
production unionGlobalDecl
top::GlobalDecl ::= d::UnionDecl
{
  top.pp = d.pp;
}

instance Semigroup GlobalDecl {
  append = mkAppendGlobalDecl;
}
instance Monoid GlobalDecl {
  mempty = mkEmptyGlobalDecl;
}

global mkAppendGlobalDecl::(GlobalDecl ::= GlobalDecl GlobalDecl) = appendGlobalDecl;
global mkEmptyGlobalDecl::GlobalDecl = emptyGlobalDecl();
