grammar edu:umn:cs:melt:foil:host:langs:core;

synthesized attribute name::String;
synthesized attribute lookupValue::ValueItem;
synthesized attribute lookupType::TypeItem;

tracked nonterminal Name with pp, name, env, lookupValue, lookupType;

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
  top.lookupType =
    case lookupType(id, top.env) of
    | [] -> errorTypeItem(id)
    | t :: _ -> t
    end;
}

instance Eq Name {
  eq = \ a::Name b::Name ->
    a.name == b.name;
}
