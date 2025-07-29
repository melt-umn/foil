grammar edu:umn:cs:melt:foil:host:langs:core;

monoid attribute defs::Defs;
inherited attribute env::Env;

monoid attribute valueContribs::Contribs<ValueItem>;
synthesized attribute valueScopes::Scopes<ValueItem>;

monoid attribute typeContribs::Contribs<TypeItem>;
synthesized attribute typeScopes::Scopes<TypeItem>;

closed data nonterminal Defs with valueContribs, typeContribs;
propagate valueContribs, typeContribs on Defs;

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
production valueDefs
top::Defs ::= is::[ValueItem]
{
  top.valueContribs <- map(\ i::ValueItem -> (i.name, i), is);
}
production typeDefs
top::Defs ::= is::[TypeItem]
{
  top.typeContribs <- map(\ i::TypeItem -> (i.name, i), is);
}

instance Semigroup Defs {
  append = appendDefs;
}
instance Monoid Defs {
  mempty = emptyDefs();
}

data nonterminal Env with valueScopes, typeScopes;

production emptyEnv
top::Env ::=
{
  top.valueScopes = emptyScope();
  top.typeScopes = emptyScope();
}
production addEnv
top::Env ::= d::Defs e::Env
{
  top.valueScopes = addScope(d.valueContribs, e.valueScopes);
  top.typeScopes = addScope(d.typeContribs, e.typeScopes);
}
production openScopeEnv
top::Env ::= e::Env
{
  top.valueScopes = openScope(e.valueScopes);
  top.typeScopes = openScope(e.typeScopes);
}

tracked data nonterminal ValueItem with name, type, found, lookupErrors, isLValue;
aspect default production
top::ValueItem ::=
{
  top.found = true;
  top.lookupErrors = [];
}
production varValueItem
top::ValueItem ::= d::Decorated VarDecl
{
  top.name = d.name;
  top.type = d.type;
  top.isLValue = true;
}
production fnValueItem
top::ValueItem ::= d::Decorated FnDecl
{
  top.name = d.name;
  top.type = fnType(d.paramTypes, d.retType);
  top.isLValue = false;
}
production paramValueItem
top::ValueItem ::= d::Decorated Param
{
  top.name = d.name;
  top.type = d.type;
  top.isLValue = true;
}
production errorValueItem
top::ValueItem ::= name::String
{
  top.name = name;
  top.type = errorType();
  top.found = false;
  top.lookupErrors = [errFromOrigin(top, s"Undefined value ${name}")];
  top.isLValue = true;
}

tracked data nonterminal TypeItem with name, type, found, lookupErrors;
aspect default production
top::TypeItem ::=
{
  top.found = true;
  top.lookupErrors = [];
}
production structTypeItem
top::TypeItem ::= d::Decorated StructDecl
{
  top.name = d.name;
  top.type = structType(d);
}
production unionTypeItem
top::TypeItem ::= d::Decorated UnionDecl
{
  top.name = d.name;
  top.type = unionType(d);
}
production errorTypeItem
top::TypeItem ::= name::String
{
  top.name = name;
  top.type = errorType();
  top.found = false;
  top.lookupErrors = [errFromOrigin(top, s"Undefined type ${name}")];
}

fun lookupValue [ValueItem] ::= n::String e::Env = lookupScope(n, e.valueScopes);
fun lookupType [TypeItem] ::= n::String e::Env = lookupScope(n, e.typeScopes);
