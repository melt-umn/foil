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

tracked nonterminal GlobalDecl with pp, env, declaredEnv, defs, errors;
propagate env, defs, errors on GlobalDecl;

production appendGlobalDecl
top::GlobalDecl ::= d1::GlobalDecl d2::GlobalDecl
{
  top.pp = pp"${d1}\n${d2}";
  d1.declaredEnv = top.declaredEnv;
  d2.declaredEnv = addEnv(d1.defs, d1.declaredEnv);
}
production emptyGlobalDecl
top::GlobalDecl ::=
{
  top.pp = pp"";
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

production mkAppendGlobalDecl
top::GlobalDecl ::= d1::GlobalDecl d2::GlobalDecl
{
  top.pp = pp"${d1}\n${d2}";
  propagate env;
  d1.declaredEnv = top.declaredEnv;
  d2.declaredEnv = addEnv(d1.defs, d1.declaredEnv);
  forwards to
    case d1, d2 of
    | emptyGlobalDecl(), _ -> @d2
    | _, emptyGlobalDecl() -> @d1
    | _, _ -> appendGlobalDecl(@d1, @d2)
    end;
}

instance Semigroup GlobalDecl {
  append = mkAppendGlobalDecl;
}
instance Monoid GlobalDecl {
  mempty = emptyGlobalDecl();
}
