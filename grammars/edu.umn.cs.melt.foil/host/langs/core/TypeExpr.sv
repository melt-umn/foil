grammar edu:umn:cs:melt:foil:host:langs:core;

synthesized attribute type::Type;

tracked nonterminal TypeExpr with pp, env, type, errors;
propagate env, errors on TypeExpr;

production nameTypeExpr
top::TypeExpr ::= n::Name
{
  top.pp = n.pp;
  top.type = n.lookupType.type;
  top.errors <- n.lookupType.lookupErrors;
}
production intTypeExpr
top::TypeExpr ::=
{
  top.pp = pp"int";
  top.type = intType();
}
production floatTypeExpr
top::TypeExpr ::=
{
  top.pp = pp"float";
  top.type = floatType();
}
production boolTypeExpr
top::TypeExpr ::=
{
  top.pp = pp"bool";
  top.type = boolType();
}
production stringTypeExpr
top::TypeExpr ::=
{
  top.pp = pp"string";
  top.type = stringType();
}
production unitTypeExpr
top::TypeExpr ::=
{
  top.pp = pp"unit";
  top.type = unitType();
}
production anyPointerTypeExpr
top::TypeExpr ::=
{
  top.pp = pp"any *";
  top.type = anyPointerType();
}
production pointerTypeExpr
top::TypeExpr ::= t::TypeExpr
{
  top.pp = pp"${t.pp} *";
  top.type = pointerType(t.type);
}
production arrayTypeExpr
top::TypeExpr ::= t::TypeExpr
{
  top.pp = pp"${t.pp}[]";
  top.type = arrayType(t.type);
}
production recordTypeExpr
top::TypeExpr ::= fs::Fields
{
  top.pp = pp"record {${ppImplode(pp", ", fs.pps)}}";
  top.type = recordType(sortByKey(fst, fs.fields));
}
production fnTypeExpr
top::TypeExpr ::= args::TypeExprs ret::TypeExpr
{
  top.pp = pp"(${ppImplode(pp", ", args.pps)}) -> ${ret.pp}";
  top.type = fnType(args.types, ret.type);
}
production errorTypeExpr
top::TypeExpr ::=
{
  top.pp = pp"error";
  top.type = errorType();
  top.errors <- [errFromOrigin(top, "Internal error: encountered errorTypeExpr")];
}

synthesized attribute types::[Type];

tracked nonterminal TypeExprs with pps, env, types, errors;
propagate env, errors on TypeExprs;
production nilTypeExpr
top::TypeExprs ::=
{
  top.pps = [];
  top.types = [];
}
production consTypeExpr
top::TypeExprs ::= h::TypeExpr fs::TypeExprs
{
  top.pps = h.pp :: fs.pps;
  top.types = h.type :: fs.types;
}
