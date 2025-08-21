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
  top.isStrable = true;
  top.negOpImpl = complexNegOpImpl;
  top.addOpImpl = complexAddOpImpl;
  top.subOpImpl = complexSubOpImpl;
  top.mulOpImpl = complexMulOpImpl;
  top.divOpImpl = complexDivOpImpl;
  top.strImpl = complexStrImpl;
}

production complexTypeExpr
top::TypeExpr ::=
{
  top.pp = pp"complex";
  top.type = complexType();
  top.errors := [];

  top.toCore = Foil_TypeExpr { {real : float, imag : float} };
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
  
  top.toCore = Foil_Expr {
    record { real=$Expr{@real.toCore}, imag=$Expr{@imag.toCore} }
  };
  propagate liftedDecls;
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

  top.toCore = Foil_Expr { $Expr{@e.toCore}.real };
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

  top.toCore = Foil_Expr { $Expr{@e.toCore}.imag };
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

  top.toCore = Foil_Expr {
    let var a = $Expr{@e.toCore}
    in record { real = a.real, imag = -a.imag }
    end
  };
  propagate liftedDecls;
}

production complexNegOpImpl implements UnaryOpImpl
top::core:Expr ::= e::core:Expr
{
  forwards to bindNegOpImpl(@e, \ a::Name -> Foil_Expr {
    record { real = -$Name{a}.real, imag = -$Name{a}.imag }
  });
}
production complexAddOpImpl implements BinOpImpl
top::core:Expr ::= l::core:Expr r::core:Expr
{
  forwards to bindBinOpImpl(@l, @r, \ a::Name b::Name -> Foil_Expr {
    record { real = $Name{a}.real + $Name{b}.real, imag = $Name{a}.imag + $Name{b}.imag }
  });
}
production complexSubOpImpl implements BinOpImpl
top::core:Expr ::= l::core:Expr r::core:Expr
{
  forwards to bindBinOpImpl(@l, @r, \ a::Name b::Name -> Foil_Expr {
    record { real = $Name{a}.real - $Name{b}.real, imag = $Name{a}.imag - $Name{b}.imag }
  });
}
production complexMulOpImpl implements BinOpImpl
top::core:Expr ::= l::core:Expr r::core:Expr
{
  forwards to bindBinOpImpl(@l, @r, \ a::Name b::Name -> Foil_Expr {
    record {
      real = $Name{a}.real * $Name{b}.real - $Name{a}.imag * $Name{b}.imag,
      imag = $Name{a}.real * $Name{b}.imag + $Name{a}.imag * $Name{b}.real
    }
  });
}
production complexDivOpImpl implements BinOpImpl
top::core:Expr ::= l::core:Expr r::core:Expr
{
  forwards to bindBinOpImpl(@l, @r, \ a::Name b::Name -> Foil_Expr {
    let var denom = $Name{b}.real * $Name{b}.real + $Name{b}.imag * $Name{b}.imag
    in record {
      real = ($Name{a}.real * $Name{b}.real + $Name{a}.imag * $Name{b}.imag) / denom,
      imag = ($Name{a}.imag * $Name{b}.real - $Name{a}.real * $Name{b}.imag) / denom
    }
    end
  });
}
production complexStrImpl implements StrImpl
top::core:Expr ::= e::core:Expr
{
  forwards to bindStrImpl(@e, \ a::Name -> Foil_Expr {
    str($Name{a}.real) ++
    ($Name{a}.imag >= 0.0? " + " ++ str($Name{a}.imag) : " - " ++ str(-$Name{a}.imag)) ++ "i"
  });
}
