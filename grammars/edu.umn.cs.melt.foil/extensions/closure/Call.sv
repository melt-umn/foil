grammar edu:umn:cs:melt:foil:extensions:closure;

production closureCallImpl implements CallImpl
top::core:Expr ::= f::core:Expr a::core:Exprs
{
  forwards to bindCallImpl(@f, @a,
    \ fn::Name -> Foil_Expr { $Name{fn}.fn },
    \ fn::Name -> core:consExpr(Foil_Expr { $Name{fn}.env }, core:nilExpr()));
}
