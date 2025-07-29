grammar edu:umn:cs:melt:foil:extensions:closure;

production lambda
top::Expr ::= params::Params ret::TypeExpr body::Stmt
{
  top.pp = box(pp"lambda (${ppImplode(pp", ", params.pps)}) -> ${ret.pp} {${groupnestlines(2, body.pp)}}");
  propagate errors;
  top.type = closureType(params.paramTypes, ret.type);

  params.env = top.env;
  ret.env = top.env;
  body.env = addEnv(params.defs, openScopeEnv(top.env));
  body.returnType = just(ret.type);

  body.toCore.core:env =
    core:addEnv(params.toCore.core:defs, core:openScopeEnv(top.toCore.core:env));

  nondecorated local fnName::Name = freshName();
  local freeVars::[Decorated Name with {core:env}] =
    nubBy(decNameEq, removeAllBy(decNameEq, params.toCore.defNames, body.toCore.freeVars));
  local freeVarsNames :: [String] = map((.name), freeVars);
  local paramsDefNames :: [String] = map((.name), params.toCore.defNames);
  local bodyFreeVarsNames :: [String] = map((.name), body.toCore.freeVars);
  top.toCore = Foil_Expr {
    record {
      fn=$Name{fnName},
      env=cast(new $Expr{
        core:recordLit(
          foldr(core:consFieldExpr, core:nilFieldExpr(),
            map(\ n -> core:fieldExpr(^n, core:var(^n)), freeVars)))
      } : any*)
    }
  };
  top.liftedDecls = Foil_GlobalDecl {
    $GlobalDecl{@params.liftedDecls}
    $GlobalDecl{@ret.liftedDecls}
    $GlobalDecl{@body.liftedDecls}
    fun $Name{fnName}(_env_ptr : any*, $Params{@params.toCore}) -> $TypeExpr{@ret.toCore} {
      var _env = *cast(_env_ptr : $TypeExpr {
        core:recordTypeExpr(
          foldr(core:consField, core:nilField(),
            map(\ n -> core:field(^n, n.core:lookupValue.core:type.core:typeExpr),
              freeVars)))}*);
      $Stmt{flatMap(\ n -> Foil_Stmt { var $Name{^n} = _env.$Name{^n}; }, freeVars)}
      $Stmt{@body.toCore}
    }
  };
}

production lambdaExpr
top::Expr ::= params::Params body::Expr
{
  top.pp = box(pp"lambda (${ppImplode(pp", ", params.pps)}) =>${groupnest(2, cat(line(), body.wrapPP))}");
  top.wrapPP = parens(top.pp);
  top.isConstant = false;
  forwards to lambda(@params, body.type.typeExpr, return_(@body));
}

fun decNameEq
Boolean ::= n1::Decorated Name with {core:env} n2::Decorated Name with {core:env} =
  n1.name == n2.name;

monoid attribute freeVars::[Decorated Name with {core:env}] occurs on
  core:Stmt, core:VarDecl, core:Expr, core:Exprs, core:FieldExprs, core:FieldExpr;
flowtype freeVars {core:env} on
  core:Stmt, core:VarDecl, core:Expr, core:Exprs, core:FieldExprs, core:FieldExpr;
propagate freeVars on
  core:Stmt, core:VarDecl, core:Expr, core:Exprs, core:FieldExprs, core:FieldExpr
excluding core:seq, core:var, core:let_;

aspect freeVars on core:Stmt using := of
| core:seq(s1, s2) -> s1.freeVars ++ removeAllBy(decNameEq, s1.defNames, s2.freeVars)
end;
aspect freeVars on core:Expr using := of
| core:var(n) -> [n]
| core:let_(d, b) -> d.freeVars ++ removeAllBy(decNameEq, d.defNames, b.freeVars)
end;

monoid attribute defNames::[Decorated Name with {core:env}] occurs on
  core:Stmt, core:VarDecl, core:Params, core:Param;
flowtype defNames {core:env} on core:Stmt, core:VarDecl;
propagate defNames on core:Stmt, core:Params;

aspect defNames on core:VarDecl using := of
| core:varDecl(n, t, i) -> [n]
| core:autoVarDecl(n, t) -> [n]
end;

aspect defNames on core:Param using := of
| core:param(n, t) -> [n]
end;
