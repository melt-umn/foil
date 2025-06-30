grammar edu:umn:cs:melt:foil:host:abstractsyntax:core;

synthesized attribute name::String;
synthesized attribute lookupValue::ValueItem;

tracked nonterminal Name with pp, name, env, compareTo, isEqual, lookupValue;

production name
top::Name ::= id::String
{
  top.pp = text(id);
  top.name = id;

  top.lookupValue =
    case lookupValue(id, top.env) of
    | [] -> errorValueItem(id)
    | v :: _ -> v
    end;
}
