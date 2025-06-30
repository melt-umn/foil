grammar edu:umn:cs:melt:foil:host:abstractsyntax:core;

synthesized attribute name::String;

synthesized attribute lookupValue::ValueLookup;

tracked nonterminal Name with pp, name, env, compareTo, isEqual, lookupValue;

production name
top::Name ::= id::String
{
  top.pp = text(id);
  top.name = id;

  top.lookupValue =
    case lookupValue(id, top.env) of
    | [] -> missingValueLookup(id)
    | d :: _ -> foundValueLookup(d)
    end;
}

synthesized attribute decl::Decorated Decl;
tracked data nonterminal ValueLookup with errors, type, decl;
production foundValueLookup
top::ValueLookup ::= d::Decorated Decl
{
  top.errors := [];
  top.type = d.type;
  top.decl = d;
}
production missingValueLookup
top::ValueLookup ::= name::String
{
  top.errors := [errFromOrigin(top, s"Undefined value ${name}")];
  top.type = errorType();
  top.decl = error("Demanded decl when lookup failed!");
}
