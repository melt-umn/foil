grammar edu:umn:cs:melt:foil:host:langs:core;

synthesized attribute type::Type;

tracked nonterminal TypeExpr with pp, env, type, errors;
propagate env, errors on TypeExpr;

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
production objTypeExpr
top::TypeExpr ::= fs::Fields
{
  top.pp = pp"{${ppImplode(pp", ", fs.pps)}}";
  top.type = objType(sortByKey(fst, fs.fields));
}
production fnTypeExpr
top::TypeExpr ::= args::TypeExprs ret::TypeExpr
{
  top.pp = pp"(${ppImplode(pp", ", args.pps)}) -> ${ret.pp}";
  top.type = fnType(args.types, ret.type);
}

synthesized attribute types::[Type];

tracked nonterminal TypeExprs with pps, env, types, errors;
propagate errors on TypeExprs;
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

synthesized attribute fields::[(String, Type)];

tracked nonterminal Fields with pps, env, fields, errors;
propagate errors on Fields;

production nilField
top::Fields ::=
{
  top.pps = [];
  top.fields = [];
}
production consField
top::Fields ::= f::Field fs::Fields
{
  top.pps = f.pp :: fs.pps;
  top.fields = (f.name, f.type) :: fs.fields;
  top.errors <-
    if lookup(f.name, fs.fields).isJust
    then [errFromOrigin(f, s"Duplicate field name '${f.name}' in object literal")]
    else [];
}

tracked nonterminal Field with pp, env, name, type, errors;
propagate errors on Field;

production field
top::Field ::= n::Name ty::TypeExpr
{
  top.pp = pp"${n} : ${ty}";
  top.name = n.name;
  top.type = ty.type;
}
