grammar edu:umn:cs:melt:foil:host:langs:core;

synthesized attribute isEqualTo::(Boolean ::= Type);
synthesized attribute isNumeric::Boolean;

tracked data nonterminal Type with pp, isEqualTo, isNumeric;
aspect default production
top::Type ::=
{
  top.isNumeric = false;
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
-- Invariant: fields are in sorted order by name
production objType
top::Type ::= fs::[(String, Type)]
{
  top.pp = pp"{${ppImplode(pp", ", map(\ f::(String, Type) -> pp"${text(f.1)}, ${f.2}", fs))}}";
  top.isEqualTo = \ other::Type ->
    case other of
    | objType(otherFs) -> fs == otherFs
    | errorType() -> true
    | _ -> false
    end;
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
