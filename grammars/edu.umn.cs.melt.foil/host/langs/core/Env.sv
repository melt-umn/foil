grammar edu:umn:cs:melt:foil:host:langs:core;

monoid attribute defs::Defs;
inherited attribute env::Env;

monoid attribute valueContribs::Contribs<ValueItem>;
synthesized attribute values::Scopes<ValueItem>;

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
top::Defs ::= i::ValueItem
{
  top.valueContribs <- [(i.name, i)];
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

synthesized attribute lookupErrors::[Message];
synthesized attribute isAssignable::Boolean;
data nonterminal ValueItem with name, type, lookupErrors, isAssignable;
aspect default production
top::ValueItem ::=
{
  top.lookupErrors = [];
}
production varValueItem
top::ValueItem ::= d::Decorated VarDecl
{
  top.name = d.name;
  top.type = d.type;
  top.isAssignable = true;
}
production fnValueItem
top::ValueItem ::= d::Decorated FnDecl
{
  top.name = d.name;
  top.type = fnType(d.paramTypes, d.retType);
  top.isAssignable = false;
}
production paramValueItem
top::ValueItem ::= d::Decorated Param
{
  top.name = d.name;
  top.type = d.type;
  top.isAssignable = true;
}
production errorValueItem
top::ValueItem ::= name::String
{
  top.name = name;
  top.type = errorType();
  top.lookupErrors = [errFromOrigin(top, s"Undefined value ${name}")];
  top.isAssignable = true;
}

fun lookupValue [ValueItem] ::= n::String e::Env = lookupScope(n, e.values);
