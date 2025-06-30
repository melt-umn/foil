grammar edu:umn:cs:melt:foil:host:abstractsyntax:core;

synthesized attribute wrapPP::Document;

tracked nonterminal Expr with pp, wrapPP, env, type, errors;
propagate env on Expr excluding let_;
propagate errors on Expr;

aspect default production
top::Expr ::=
{
  top.wrapPP = parens(top.pp);
}

production var
top::Expr ::= n::Name
{
  top.pp = n.pp;
  top.wrapPP = n.pp;
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
production fnCall
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

-- Operators
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
production eqOp
top::Expr ::= e1::Expr e2::Expr
{
  top.pp = pp"${e1.wrapPP} == ${e2.wrapPP}";
  top.type = e1.type;
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
