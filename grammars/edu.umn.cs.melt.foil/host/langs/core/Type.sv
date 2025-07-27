grammar edu:umn:cs:melt:foil:host:langs:core;

synthesized attribute mangledName::String;
synthesized attribute typeExpr::TypeExpr;
synthesized attribute isEqualTo::(Boolean ::= Type);
synthesized attribute isNumeric::Boolean;
synthesized attribute isStrable::Boolean;
synthesized attribute structFields::Maybe<[(String, Type)]>;
synthesized attribute elemType::Type;

tracked data nonterminal Type with pp, mangledName, typeExpr, isEqualTo, isNumeric, isStrable, structFields, elemType;
aspect default production
top::Type ::=
{
  top.isNumeric = false;
  top.isStrable = false;
  top.structFields = nothing();
  top.elemType = errorType();
}
production intType
top::Type ::=
{
  top.pp = pp"int";
  top.mangledName = "int";
  top.typeExpr = intTypeExpr();
  top.isEqualTo = \ other::Type ->
    case other of
    | intType() -> true
    | errorType() -> true
    | _ -> false
    end;
  top.isNumeric = true;
  top.isStrable = true;
}
production floatType
top::Type ::=
{
  top.pp = pp"float";
  top.mangledName = "float";
  top.typeExpr = floatTypeExpr();
  top.isEqualTo = \ other::Type ->
    case other of
    | floatType() -> true
    | errorType() -> true
    | _ -> false
    end;
  top.isNumeric = true;
  top.isStrable = true;
}
production boolType
top::Type ::=
{
  top.pp = pp"bool";
  top.mangledName = "bool";
  top.typeExpr = boolTypeExpr();
  top.isEqualTo = \ other::Type ->
    case other of
    | boolType() -> true
    | errorType() -> true
    | _ -> false
    end;
  top.isStrable = true;
}
production stringType
top::Type ::=
{
  top.pp = pp"string";
  top.mangledName = "string";
  top.typeExpr = stringTypeExpr();
  top.isEqualTo = \ other::Type ->
    case other of
    | stringType() -> true
    | errorType() -> true
    | _ -> false
    end;
  top.isStrable = true;
}
production unitType
top::Type ::=
{
  top.pp = pp"unit";
  top.mangledName = "unit";
  top.typeExpr = unitTypeExpr();
  top.isEqualTo = \ other::Type ->
    case other of
    | unitType() -> true
    | errorType() -> true
    | _ -> false
    end;
  top.isStrable = true;
}
production pointerType
top::Type ::= t::Type
{
  top.pp = pp"${t.pp}*";
  top.mangledName = s"ptr_${t.mangledName}_";
  top.typeExpr = pointerTypeExpr(t.typeExpr);
  top.isEqualTo = \ other::Type ->
    case other of
    | pointerType(otherT) -> t == otherT
    | errorType() -> true
    | _ -> false
    end;
  top.elemType = t;
  top.isStrable = true;
}
production arrayType
top::Type ::= t::Type
{
  top.pp = pp"${t.pp}[]";
  top.mangledName = s"arr_${t.mangledName}_";
  top.typeExpr = arrayTypeExpr(t.typeExpr);
  top.isEqualTo = \ other::Type ->
    case other of
    | arrayType(otherT) -> t == otherT
    | errorType() -> true
    | _ -> false
    end;
  top.elemType = t;
}
production structType
top::Type ::= d::Decorated StructDecl
{
  top.pp = text(d.name);
  top.mangledName = s"struct_${d.name}_";
  top.typeExpr = nameTypeExpr(name(d.name));
  top.isEqualTo = \ other::Type ->
    case other of
    | structType(d2) -> d.name == d2.name
    | errorType() -> true
    | _ -> false
    end;
  top.structFields = just(d.fields);
}
production unionType
top::Type ::= d::Decorated UnionDecl
{
  top.pp = text(d.name);
  top.mangledName = s"union_${d.name}_";
  top.typeExpr = nameTypeExpr(name(d.name));
  top.isEqualTo = \ other::Type ->
    case other of
    | unionType(d2) -> d.name == d2.name
    | errorType() -> true
    | _ -> false
    end;
  top.structFields = just(d.fields);
}
-- Invariant: fields are in sorted order by name
production recordType
top::Type ::= fs::[(String, Type)]
{
  top.pp = pp"{${ppImplode(pp", ", map(\ f::(String, Type) -> pp"${text(f.1)} : ${f.2}", fs))}}";
  top.mangledName = "record_" ++ implode("_", map(\ f::(String, Type) -> f.1 ++ "_" ++ f.2.mangledName, fs)) ++ "_";
  top.typeExpr = nameTypeExpr(name("_" ++ top.mangledName));
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
  top.mangledName = s"fn_${implode("_", map((.mangledName), args))}_${ret.mangledName}_";
  top.typeExpr = fnTypeExpr(foldr(consTypeExpr, nilTypeExpr(), map((.typeExpr), args)), ret.typeExpr);
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
  top.mangledName = "err";
  top.typeExpr = error("type expression shouldn't be used?");
  top.isEqualTo = \ _ -> true;
  top.isNumeric = true;
  top.isStrable = true;
}

instance Eq Type {
  eq = uncurry((.isEqualTo), _, _);
}
