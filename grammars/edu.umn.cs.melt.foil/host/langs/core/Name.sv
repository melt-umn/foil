grammar edu:umn:cs:melt:foil:host:langs:core;

synthesized attribute lookupValue::ValueItem;
synthesized attribute lookupType::TypeItem;

attribute env, lookupValue, lookupType occurs on Name;

aspect production name
top::Name ::= id::String
{
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
