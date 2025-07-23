grammar edu:umn:cs:melt:foil:host:langs:core;

synthesized attribute wrapPP::Document;
synthesized attribute isLValue::Boolean;

tracked nonterminal Expr with pp, wrapPP, env, isLValue, type, errors;
propagate env on Expr excluding let_;
propagate errors on Expr;

aspect default production
top::Expr ::=
{
  top.wrapPP = parens(top.pp);
  top.isLValue = false;
}

production var
top::Expr ::= n::Name
{
  top.pp = n.pp;
  top.wrapPP = n.pp;
  top.isLValue = n.lookupValue.isLValue;
  top.type = n.lookupValue.type;
  top.errors <- n.lookupValue.lookupErrors;
}
production let_
top::Expr ::= d::VarDecl b::Expr
{
  top.pp = pp"let${groupnestlines(2, d.pp)}in${groupnestlines(2, b.pp)}end";
  top.wrapPP = top.pp;
  top.type = b.type;
  d.env = top.env;
  b.env = addEnv(d.defs, top.env);
}
production call
top::Expr ::= f::Expr a::Exprs
{
  top.pp = pp"${f.wrapPP}(${ppImplode(pp", ", a.pps)})";
  top.type =
    case f.type of
    | fnType(_, ret) -> ret
    | _ -> errorType()
    end;
  a.expectedTypes =
    case f.type of
    | fnType(params, _) -> params
    | _ -> []
    end;
  a.position = 1;
}

inherited attribute expectedTypes::[Type];
inherited attribute position::Integer;

tracked nonterminal Exprs with pps, env, types, expectedTypes, position, errors;
propagate env, errors on Exprs;

production consExpr
top::Exprs ::= e::Expr es::Exprs
{
  top.pps = e.pp :: es.pps;
  top.types = e.type :: es.types;
  es.expectedTypes =
    if null(top.expectedTypes) then [] else tail(top.expectedTypes);
  es.position = top.position + 1;

  top.errors <-
    case top.expectedTypes of
    | [] -> [errFromOrigin(top, "Too many arguments to function")]
    | t :: _ when e.type != t ->
      [errFromOrigin(e, s"Argument ${toString(top.position)} expected ${show(80, t.pp)}, but found ${show(80, e.type)}")]
    | _ -> []
    end;
}
production nilExpr
top::Exprs ::=
{
  top.pps = [];
  top.types = [];

  top.errors <-
    if null(top.expectedTypes) then []
    else [errFromOrigin(top, "Too few arguments to function")];
}

production deref
top::Expr ::= e::Expr
{
  top.pp = pp"*${e.wrapPP}";
  top.wrapPP = parens(top.pp);
  top.isLValue = true;
  top.type =
    case e.type of
    | pointerType(t) -> t
    | _ -> errorType()
    end;
  top.errors <-
    case e.type of
    | pointerType(_) -> []
    | errorType() -> []
    | _ -> [errFromOrigin(e, s"Dereference expected a pointer type, but got ${show(80, e.type)}")]
    end;
}
production arraySubscript
top::Expr ::= e::Expr i::Expr
{
  top.pp = pp"${e.wrapPP}[${i.wrapPP}]";
  top.wrapPP = parens(top.pp);
  top.isLValue = true;
  top.type =
    case e.type of
    | arrayType(t) -> t
    | _ -> errorType()
    end;
  top.errors <-
    case e.type of
    | arrayType(_) -> []
    | errorType() -> []
    | _ -> [errFromOrigin(e, s"Array subscript expected an array type, but got ${show(80, e.type)}")]
    end;
  top.errors <-
    if i.type == intType() then []
    else [errFromOrigin(i, s"Array subscript expected an int, but got ${show(80, i.type)}")];
}
production newPointer
top::Expr ::= init::Expr
{
  top.pp = pp"new ${init.wrapPP}";
  top.wrapPP = parens(top.pp);
  top.type = pointerType(init.type);
}
production newArray
top::Expr ::= size::Expr init::Expr
{
  top.pp = pp"new[${size}] ${init.wrapPP}";
  top.wrapPP = parens(top.pp);
  top.type = arrayType(init.type);
  top.errors <-
    if size.type == intType() then []
    else [errFromOrigin(size, s"Array size expected an int, but got ${show(80, size.type)}")];
}
-- TODO: Could be an extension?
production arrayLit
top::Expr ::= es::Exprs
{
  top.pp = pp"new[] {${ppImplode(pp", ", es.pps)}}";
  top.wrapPP = parens(top.pp);
  local elemType::Type =
    case es.types of
    | t :: _ -> t
    | [] -> errorType()
    end;
  top.type = arrayType(elemType);
  top.errors <-
    if !null(es.types) then []
    else [errFromOrigin(es, "Array literal expected at least one element")];
  top.errors <-
    if all(map(\ t::Type -> t == elemType, es.types)) then []
    else [errFromOrigin(es, s"Array literal expected elements of type ${show(80, elemType)}, but got ${show(80, es.types)}")];
}
production recordLit
top::Expr ::= fs::FieldExprs
{
  top.pp = pp"{${ppImplode(pp", ", fs.pps)}}";
  top.wrapPP = top.pp;
  top.type = recordType(sortByKey(fst, fs.fields));
}
production structLit
top::Expr ::= n::Name fs::FieldExprs
{
  top.pp = pp"${n} {${ppImplode(pp", ", fs.pps)}}";
  top.wrapPP = top.pp;
  top.type = n.lookupType.type;
  top.errors <- n.lookupType.lookupErrors;
  top.errors <-
    case n.lookupType.type of
    | structType(dcl) -> fs.structFieldErrors
    | errorType() -> []
    | t -> [errFromOrigin(n, s"Expected struct type, but got ${show(80, t)}")]
    end;
  fs.expectedFields = n.lookupType.type.structFields.fromJust;
}

inherited attribute expectedFields::[(String, Type)];
synthesized attribute structFieldErrors::[Message];

tracked nonterminal FieldExprs with pps, env, fields, errors, expectedFields, structFieldErrors;
propagate env, errors on FieldExprs;

production consFieldExpr
top::FieldExprs ::= f::FieldExpr fs::FieldExprs
{
  top.pps = f.pp :: fs.pps;
  top.fields = (f.name, f.type) :: fs.fields;

  top.errors <-
    if lookup(f.name, fs.fields).isJust
    then [errFromOrigin(f, s"Duplicate field '${f.name}' in struct literal")]
    else [];
  
  fs.expectedFields = filter(\ x::(String, Type) -> x.1 != f.name, fs.expectedFields);
  top.structFieldErrors =
    case lookup(f.name, fs.expectedFields) of
    | just(ty) ->
      if f.type == ty then []
      else [errFromOrigin(f, s"Field '${f.name}' expected type ${show(80, ty)}, but got ${show(80, f.type)}")]
    | nothing() -> [errFromOrigin(f, s"Unexpected field '${f.name}' in struct literal")]
    end ++ fs.structFieldErrors;
}
production nilFieldExpr
top::FieldExprs ::=
{
  top.pps = [];
  top.fields = [];
  top.structFieldErrors =
    if null(top.expectedFields) then []
    else [errFromOrigin(top, s"Struct literal missing fields ${implode(", ", map(\ f::(String, Type) -> s"'${f.1}'", top.expectedFields))}")];
}

tracked nonterminal FieldExpr with pp, env, name, type, errors;
propagate env, errors on FieldExpr;

production fieldExpr
top::FieldExpr ::= n::Name e::Expr
{
  top.pp = pp"${n} = ${e.wrapPP}";
  top.name = n.name;
  top.type = e.type;
}

production fieldAccess
top::Expr ::= e::Expr f::Name
{
  top.pp = pp"${e.wrapPP}.${f.pp}";
  top.wrapPP = top.pp;
  top.isLValue = e.isLValue;
  top.type =
    case e.type.structFields of
    | just(fs) when lookup(f.name, fs) matches just(ty) -> ty
    | _ -> errorType()
    end;
  top.errors <-
    case e.type, e.type.structFields of
    | errorType(), _ -> []
    | _, just(fs) ->
      case lookup(f.name, fs) of
      | just(_) -> []
      | nothing() ->
        [errFromOrigin(e, s"Expression has type ${show(80, e.type)}, lacking field '${f.name}'")]
      end
    | t, _ -> [errFromOrigin(e, s"Value of type ${show(80, t)} does not have fields")]
    end;
}

-- Literals
production intLit
top::Expr ::= i::Integer
{
  top.pp = pp"${i}";
  top.wrapPP = top.pp;
  top.type = intType();
}
production floatLit
top::Expr ::= f::Float
{
  top.pp = pp"${f}";
  top.wrapPP = top.pp;
  top.type = floatType();
}
production trueLit
top::Expr ::=
{
  top.pp = pp"true";
  top.wrapPP = top.pp;
  top.type = boolType();
}
production falseLit
top::Expr ::=
{
  top.pp = pp"false";
  top.wrapPP = top.pp;
  top.type = boolType();
}
production stringLit
top::Expr ::= s::String
{
  top.pp = pp"${s}";
  top.wrapPP = top.pp;
  top.type = stringType();
}
production unitLit
top::Expr ::=
{
  top.pp = pp"()";
  top.wrapPP = top.pp;
  top.type = unitType();
}

-- Operators
production cond
top::Expr ::= c::Expr t::Expr e::Expr
{
  top.pp = pp"${c}? ${t} : ${e}";
  top.wrapPP = parens(top.pp);
  top.type =
    if t.type == e.type then t.type
    else errorType();
  top.errors <-
    if c.type == boolType() then []
    else [errFromOrigin(c, s"Condition expected a bool, but got ${show(80, c.type)}")];
}
production negOp
top::Expr ::= e::Expr
{
  top.pp = pp"-${e.wrapPP}";
  top.type = e.type;
  top.errors <-
    if e.type.isNumeric then []
    else [errFromOrigin(e, s"+ expected a numeric type, but got ${show(80, e.type)}")];
}
production addOp
top::Expr ::= e1::Expr e2::Expr
{
  top.pp = pp"${e1.wrapPP} + ${e2.wrapPP}";
  top.type = e1.type;
  top.errors <-
    if e1.type.isNumeric then []
    else [errFromOrigin(e1, s"+ expected a numeric type, but got ${show(80, e1.type)}")];
  top.errors <-
    if e2.type == e1.type then []
    else [errFromOrigin(e2, s"+ expected ${show(80, e1.type)} but got ${show(80, e2.type)}")];
}
production subOp
top::Expr ::= e1::Expr e2::Expr
{
  top.pp = pp"${e1.wrapPP} - ${e2.wrapPP}";
  top.type = e1.type;
  top.errors <-
    if e1.type.isNumeric then []
    else [errFromOrigin(e1, s"- expected a numeric type, but got ${show(80, e1.type)}")];
  top.errors <-
    if e2.type == e1.type then []
    else [errFromOrigin(e2, s"- expected ${show(80, e1.type)} but got ${show(80, e2.type)}")];
}
production mulOp
top::Expr ::= e1::Expr e2::Expr
{
  top.pp = pp"${e1.wrapPP} * ${e2.wrapPP}";
  top.type = e1.type;
  top.errors <-
    if e1.type.isNumeric then []
    else [errFromOrigin(e1, s"* expected a numeric type, but got ${show(80, e1.type)}")];
  top.errors <-
    if e2.type == e1.type then []
    else [errFromOrigin(e2, s"* expected ${show(80, e1.type)} but got ${show(80, e2.type)}")];
}
production divOp
top::Expr ::= e1::Expr e2::Expr
{
  top.pp = pp"${e1.wrapPP} / ${e2.wrapPP}";

  top.type = e1.type;
  top.errors <-
    if e1.type.isNumeric then []
    else [errFromOrigin(e1, s"/ expected a numeric type, but got ${show(80, e1.type)}")];
  top.errors <-
    if e2.type == e1.type then []
    else [errFromOrigin(e2, s"/ expected ${show(80, e1.type)} but got ${show(80, e2.type)}")];
}
production modOp
top::Expr ::= e1::Expr e2::Expr
{
  top.pp = pp"${e1.wrapPP} % ${e2.wrapPP}";

  top.type = e1.type;
  top.errors <-
    if e1.type == intType() then []
    else [errFromOrigin(e1, s"/ expected an int but got ${show(80, e1.type)}")];
  top.errors <-
    if e2.type == intType() then []
    else [errFromOrigin(e2, s"/ expected an int but got ${show(80, e2.type)}")];
}
production eqOp
top::Expr ::= e1::Expr e2::Expr
{
  top.pp = pp"${e1.wrapPP} == ${e2.wrapPP}";
  top.type = boolType();
  top.errors <-
    if e2.type == e1.type then []
    else [errFromOrigin(e2, s"== expected ${show(80, e1.type)} but got ${show(80, e2.type)}")];
}
production neqOp
top::Expr ::= e1::Expr e2::Expr
{
  top.pp = pp"${e1.wrapPP} != ${e2.wrapPP}";
  top.type = boolType();
  top.errors <-
    if e2.type == e1.type then []
    else [errFromOrigin(e2, s"!= expected ${show(80, e1.type)} but got ${show(80, e2.type)}")];
}
production gtOp
top::Expr ::= e1::Expr e2::Expr
{
  top.pp = pp"${e1.wrapPP} > ${e2.wrapPP}";
  top.type = boolType();
  top.errors <-
    if e2.type == e1.type then []
    else [errFromOrigin(e2, s">= expected ${show(80, e1.type)} but got ${show(80, e2.type)}")];
}
production ltOp
top::Expr ::= e1::Expr e2::Expr
{
  top.pp = pp"${e1.wrapPP} < ${e2.wrapPP}";
  top.type = boolType();
  top.errors <-
    if e2.type == e1.type then []
    else [errFromOrigin(e2, s"< expected ${show(80, e1.type)} but got ${show(80, e2.type)}")];
}
production gteOp
top::Expr ::= e1::Expr e2::Expr
{
  top.pp = pp"${e1.wrapPP} >= ${e2.wrapPP}";
  top.type = boolType();
  top.errors <-
    if e2.type == e1.type then []
    else [errFromOrigin(e2, s">= expected ${show(80, e1.type)} but got ${show(80, e2.type)}")];
}
production lteOp
top::Expr ::= e1::Expr e2::Expr
{
  top.pp = pp"${e1.wrapPP} <= ${e2.wrapPP}";
  top.type = boolType();
  top.errors <-
    if e2.type == e1.type then []
    else [errFromOrigin(e2, s"/ expected ${show(80, e1.type)} but got ${show(80, e2.type)}")];
}
production andOp
top::Expr ::= e1::Expr e2::Expr
{
  top.pp = pp"${e1.wrapPP} && ${e2.wrapPP}";
  top.type = boolType();
  top.errors <-
    if e1.type == boolType() then []
    else [errFromOrigin(e1, s"&& expected a bool, but got ${show(80, e1.type)}")];
  top.errors <-
    if e2.type == boolType() then []
    else [errFromOrigin(e2, s"&& expected a bool, but got ${show(80, e2.type)}")];
}
production orOp
top::Expr ::= e1::Expr e2::Expr
{
  top.pp = pp"${e1.wrapPP} || ${e2.wrapPP}";
  top.type = boolType();
  top.errors <-
    if e1.type == boolType() then []
    else [errFromOrigin(e1, s"|| expected a bool, but got ${show(80, e1.type)}")];
  top.errors <-
    if e2.type == boolType() then []
    else [errFromOrigin(e2, s"|| expected a bool, but got ${show(80, e2.type)}")];
}
production notOp
top::Expr ::= e::Expr
{
  top.pp = pp"!${e.wrapPP}";
  top.type = boolType();
  top.errors <-
    if e.type == boolType() then []
    else [errFromOrigin(e, s"! expected a bool, but got ${show(80, e.type)}")];
}
