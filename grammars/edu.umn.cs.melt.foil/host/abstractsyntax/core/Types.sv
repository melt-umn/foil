grammar edu:umn:cs:melt:foil:host:abstractsyntax:core;

synthesized attribute type::Type;

tracked nonterminal Type with pp, errors, compareTo, isEqual;
propagate errors on Type;
propagate compareTo, isEqual on Type excluding errorType;

production intType
top::Type ::=
{
  top.pp = pp"int";
}
production floatType
top::Type ::=
{
  top.pp = pp"float";
}
production boolType
top::Type ::=
{
  top.pp = pp"bool";
}
production stringType
top::Type ::=
{
  top.pp = pp"string";
}
production objType
top::Type ::= fs::Fields
{
  top.pp = pp"{${ppImplode(pp", ", fs.pps)}}";
}
production fnType
top::Type ::= args::Types ret::Type
{
  top.pp = pp"(${ppImplode(pp", ", args.pps)}) -> ${ret.pp}";
}
production errorType
top::Type ::=
{
  top.pp = pp"err";
  top.isEqual = true;
}

tracked nonterminal Types with pps, errors, compareTo, isEqual;
propagate errors, compareTo, isEqual on Types;
production nilType
top::Types ::=
{
  top.pps = [];
}
production consType
top::Types ::= h::Type fs::Types
{
  top.pps = h.pp :: fs.pps;
}

-- Invariant: fields are sorted by name
tracked nonterminal Fields with pps, errors, compareTo, isEqual;
propagate errors, compareTo, isEqual on Fields;

production nilField
top::Fields ::=
{
  top.pps = [];
}
production consField
top::Fields ::= h::Field fs::Fields
{
  top.pps = h.pp :: fs.pps;
}

tracked nonterminal Field with pp, name, type, errors, compareTo, isEqual;
propagate errors, compareTo, isEqual on Field;

production field
top::Field ::= n::Name ty::Type
{
  top.pp = pp"${n} : ${ty}";
  top.name = n.name;
  top.type = ^ty;
}
