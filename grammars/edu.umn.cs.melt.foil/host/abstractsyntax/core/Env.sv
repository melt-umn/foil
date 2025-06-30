grammar edu:umn:cs:melt:foil:host:abstractsyntax:core;

monoid attribute defs::Defs;
inherited attribute env::Env;

monoid attribute valueContribs::Contribs<Decorated Decl>;
synthesized attribute values::Scopes<Decorated Decl>;

closed data nonterminal Defs with valueContribs;
propagate valueContribs on Defs;

aspect default production
top::Defs ::=
{
  top.valueContribs := [];
}
production appendDefs
top::Defs ::= d1::Defs d2::Defs
{}
production emptyDefs
top::Defs ::=
{}
production valueDef
top::Defs ::= d::Decorated Decl
{
  top.valueContribs <- [(d.name, d)];
}

instance Semigroup Defs {
  append = appendDefs;
}
instance Monoid Defs {
  mempty = emptyDefs();
}

data nonterminal Env with values;

production emptyEnv
top::Env ::=
{
  top.values = emptyScope();
}
production addEnv
top::Env ::= d::Defs e::Env
{
  top.values = addScope(d.valueContribs, e.values);
}
production openScopeEnv
top::Env ::= e::Env
{
  top.values = openScope(e.values);
}

fun lookupValue [Decorated Decl] ::= n::String e::Env = lookupScope(n, e.values);
