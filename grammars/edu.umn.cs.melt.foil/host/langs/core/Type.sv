grammar edu:umn:cs:melt:foil:host:langs:core;

synthesized attribute isEqualTo::(Boolean ::= Type);
synthesized attribute isNumeric::Boolean;
synthesized attribute structFields::Maybe<[(String, Type)]>;

tracked data nonterminal Type with pp, isEqualTo, isNumeric, structFields;
aspect default production
top::Type ::=
{
  top.isNumeric = false;
  top.structFields = nothing();
}
production intType
top::Type ::=
{
  top.pp = pp"int";
  top.isEqualTo = \ other::Type ->
    case other of
    | intType() -> true
    | errorType() -> true
    | _ -> false
    end;
  top.isNumeric = true;
}
production floatType
top::Type ::=
{
  top.pp = pp"float";
  top.isEqualTo = \ other::Type ->
    case other of
    | floatType() -> true
    | errorType() -> true
    | _ -> false
    end;
  top.isNumeric = true;
}
production boolType
top::Type ::=
{
  top.pp = pp"bool";
  top.isEqualTo = \ other::Type ->
    case other of
    | boolType() -> true
    | errorType() -> true
    | _ -> false
    end;
}
production stringType
top::Type ::=
{
  top.pp = pp"string";
  top.isEqualTo = \ other::Type ->
    case other of
    | stringType() -> true
    | errorType() -> true
    | _ -> false
    end;
}
production structType
top::Type ::= d::Decorated StructDecl
{
  top.pp = pp"struct ${text(d.name)}";
  top.isEqualTo = \ other::Type ->
    case other of
    | structType(d2) -> d.name == d2.name
    | errorType() -> true
    | _ -> false
    end;
  top.structFields = just(d.fields);
}
-- Invariant: fields are in sorted order by name
production recordType
top::Type ::= fs::[(String, Type)]
{
  top.pp = pp"{${ppImplode(pp", ", map(\ f::(String, Type) -> pp"${text(f.1)}, ${f.2}", fs))}}";
  top.isEqualTo = \ other::Type ->
    case other of
    | recordType(otherFs) -> fs == otherFs
    | errorType() -> true
    | _ -> false
    end;
  top.structFields = just(fs);
}
production fnType
top::Type ::= args::[Type] ret::Type
{
  top.pp = pp"(${ppImplode(pp", ", map((.pp), args))}) -> ${ret}";
  top.isEqualTo = \ other::Type ->
    case other of
    | fnType(otherArgs, otherRet) ->
        args == otherArgs && ret == otherRet
    | errorType() -> true
    | _ -> false
    end;
}
production unitType
top::Type ::=
{
  top.pp = pp"unit";
  top.isEqualTo = \ other::Type ->
    case other of
    | unitType() -> true
    | errorType() -> true
    | _ -> false
    end;
}
production errorType
top::Type ::=
{
  top.pp = pp"err";
  top.isEqualTo = \ _ -> true;
  top.isNumeric = true;
}

instance Eq Type {
  eq = uncurry((.isEqualTo), _, _);
}
