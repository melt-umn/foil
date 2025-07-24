grammar edu:umn:cs:melt:foil:extensions:complex;

production complexType
top::Type ::=
{
  top.pp = pp"complex";
  top.mangledName = "complex";
  top.isEqualTo = \ t::Type ->
    case t of
    | complexType() -> true
    | errorType() -> true
    | _ -> false
    end;
  top.typeExpr = complexTypeExpr();
  top.isNumeric = true;  -- TODO: overloading translation?
}

production complexTypeExpr
top::TypeExpr ::=
{
  top.pp = pp"complex";
  top.type = complexType();
  top.errors := [];

  forward trans =
    recordTypeExpr(
      consField(field(name("real"), floatTypeExpr()),
        consField(field(name("imag"), floatTypeExpr()),
          nilField())));
  top.liftedDecls = @trans.liftedDecls;
  top.toCore = @trans.toCore;
}

production complexLit
top::Expr ::= real::Expr imag::Expr
{
  top.pp = pp"${real.wrapPP} +i ${imag.wrapPP}";
  top.wrapPP = parens(top.pp);
  propagate env, errors;
  top.type = complexType();
  top.errors <-
    if real.type == floatType() then []
    else [errFromOrigin(real, s"Real part must be of type float, got ${show(80, real.type)}")];
  top.errors <-
    if imag.type == floatType() then []
    else [errFromOrigin(real, s"Imaginary part must be of type float, got ${show(80, real.type)}")];
  
  forward trans =
    recordLit(
      consFieldExpr(fieldExpr(name("real"), @real),
        consFieldExpr(fieldExpr(name("imag"), @imag),
          nilFieldExpr())));
  top.liftedDecls = @trans.liftedDecls;
  top.toCore = @trans.toCore;
}
production realPart
top::Expr ::= e::Expr
{
  top.pp = pp"real ${e.wrapPP}";
  top.wrapPP = parens(top.pp);
  propagate env, errors;
  top.type = floatType();
  top.errors <-
    if e.type == complexType() then []
    else [errFromOrigin(e, s"Operand must be of type complex, got ${show(80, e.type)}")];

  forward trans = fieldAccess(@e, name("real"));
  top.liftedDecls = @trans.liftedDecls;
  top.toCore = @trans.toCore;
}
production imagPart
top::Expr ::= e::Expr
{
  top.pp = pp"imag ${e.wrapPP}";
  top.wrapPP = parens(top.pp);
  propagate env, errors;
  top.type = floatType();
  top.errors <-
    if e.type == complexType() then []
    else [errFromOrigin(e, s"Operand must be of type complex, got ${show(80, e.type)}")];

  forward trans = fieldAccess(@e, name("imag"));
  top.liftedDecls = @trans.liftedDecls;
  top.toCore = @trans.toCore;
}
production complexConj
top::Expr ::= e::Expr
{
  top.pp = pp"~${e.wrapPP}";
  top.wrapPP = parens(top.pp);
  propagate env, errors;
  top.type = complexType();
  top.errors <-
    if e.type == complexType() then []
    else [errFromOrigin(e, s"Operand must be of type complex, got ${show(80, e.type)}")];
  
  forward trans = let_(
    varDecl(name("a"), complexTypeExpr(), @e),
    complexLit(
      fieldAccess(var(name("a")), name("real")),
      negOp(fieldAccess(var(name("a")), name("imag")))));
  top.liftedDecls = @trans.liftedDecls;
  top.toCore = @trans.toCore;
}
