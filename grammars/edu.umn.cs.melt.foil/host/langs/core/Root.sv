grammar edu:umn:cs:melt:foil:host:langs:core;

tracked nonterminal Root with pp, errors;

production root
top::Root ::= d::GlobalDecls
{
  top.pp = ppImplode(line(), d.pps);
  d.env = emptyEnv();
}

tracked nonterminal GlobalDecls with pps, env, errors;
propagate errors on GlobalDecls;

production consGlobalDecl
top::GlobalDecls ::= d::GlobalDecl ds::GlobalDecls
{
  top.pps = d.pp :: ds.pps;
  d.env = top.env;
  ds.env = addEnv(d.defs, ds.env);
}
production nilGlobalDecl
top::GlobalDecls ::=
{
  top.pps = [];
}

tracked nonterminal GlobalDecl with pp, env, defs, errors;
propagate env, defs, errors on GlobalDecl;

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
