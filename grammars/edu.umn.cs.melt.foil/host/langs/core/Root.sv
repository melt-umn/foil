grammar edu:umn:cs:melt:foil:host:langs:core;

tracked nonterminal Root with pp, errors;
propagate errors on Root;

production root
top::Root ::= d::GlobalDecl
{
  top.pp = d.pp;
  d.env = addEnv(d.defs, emptyEnv());
}

tracked nonterminal GlobalDecl with pp, env, defs, errors;
propagate env, defs, errors on GlobalDecl;

production appendGlobalDecl
top::GlobalDecl ::= d1::GlobalDecl d2::GlobalDecl
{
  top.pp = pp"${d1}\n${d2}";
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

instance Semigroup GlobalDecl {
  append = appendGlobalDecl;
}
instance Monoid GlobalDecl {
  mempty = emptyGlobalDecl();
}
