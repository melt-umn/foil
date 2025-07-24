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

  top.toCore =
    core:recordTypeExpr(
      core:consField(core:field(name("real"), core:floatTypeExpr()),
        core:consField(core:field(name("imag"), core:floatTypeExpr()),
          core:nilField())));
  propagate liftedDecls;
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
  
  top.toCore = complexLitImpl(@real.toCore, @imag.toCore);
  propagate liftedDecls;
}
production complexLitImpl
top::core:Expr ::= real::core:Expr imag::core:Expr
{
  forwards to
    core:recordLit(
      core:consFieldExpr(core:fieldExpr(name("real"), @real),
        core:consFieldExpr(core:fieldExpr(name("imag"), @imag),
          core:nilFieldExpr())));
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

  top.toCore = core:fieldAccess(@e.toCore, name("real"));
  propagate liftedDecls;
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

  top.toCore = core:fieldAccess(@e.toCore, name("imag"));
  propagate liftedDecls;
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
  
  top.toCore = core:let_(
    core:autoVarDecl(name("a"), @e.toCore),
    complexLitImpl(
      core:fieldAccess(core:var(name("a")), name("real")),
      core:negOp(core:fieldAccess(core:var(name("a")), name("imag")))));
  propagate liftedDecls;
}
