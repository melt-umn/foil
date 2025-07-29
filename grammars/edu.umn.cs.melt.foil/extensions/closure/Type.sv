grammar edu:umn:cs:melt:foil:extensions:closure;

production closureType
top::Type ::= params::[Type] ret::Type
{
  top.pp = pp"closure (${ppImplode(pp", ", map((.pp), params))}) -> ${ret}";
  top.mangledName = s"closure_${implode("_", map((.mangledName), params))})_${ret.mangledName}_";
  top.isEqualTo = \ t::Type ->
    case t of
    | closureType(params2, ret2) -> params == params2 && ret == ret2
    | errorType() -> true
    | _ -> false
    end;
  top.typeExpr = closureTypeExpr(
    foldr(consTypeExpr, nilTypeExpr(), map((.typeExpr), params)),
    ret.typeExpr);
  top.isCallable = true;
  top.paramTypes = params;
  top.retType = ret;
  top.callImpl = closureCallImpl;
}

production closureTypeExpr
top::TypeExpr ::= params::TypeExprs ret::TypeExpr
{
  top.pp = pp"closure (${ppImplode(pp", ", params.pps)}) -> ${ret}";
  propagate env, errors;
  top.type = closureType(params.types, ret.type);

  top.toCore = Foil_TypeExpr {
    { fn : $TypeExpr{core:fnTypeExpr(
        core:consTypeExpr(core:anyPointerTypeExpr(), @params.toCore),
        @ret.toCore)},
      env : any* }
  };
  propagate liftedDecls;
}
