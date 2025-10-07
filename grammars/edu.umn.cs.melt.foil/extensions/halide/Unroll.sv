grammar edu:umn:cs:melt:foil:extensions:halide;

production unroll
top::Transform ::= n::Name
{
  top.pp = pp"unroll ${n}";
  
  local s::IterStmt = top.stmtsIn;
  s.unrollVar = ^n;

  top.errors := s.unrollErrors;
  top.stmtsOut = s.unroll;
}

inherited attribute unrollVar::Name occurs on IterStmt;
monoid attribute unrollErrors::[Message] occurs on IterStmt;
functor attribute unroll occurs on IterStmt;
propagate unrollVar on IterStmt;
propagate unrollErrors, unroll on IterStmt excluding loop;

aspect production loop
top::IterStmt ::= var::Name limit::Decorated core:Expr body::IterStmt
{
  top.unrollErrors :=
    if ^var == top.unrollVar
    then if limit.intConstVal.isJust then []
      else [errFromOrigin(limit, s"Unrolled loop ${var.name} must have a constant integer limit")]
    else body.unrollErrors;

  top.unroll =
    if ^var == top.unrollVar
    then unrollLoop(^var, limit.intConstVal.fromJust, body.unroll)
    else body.unroll;
}
aspect production stmt
top::IterStmt ::= s::Decorated core:Stmt
{
  top.unrollErrors <- [errFromOrigin(top.unrollVar, s"${top.unrollVar.name} is not a transformable loop")];
}

synthesized attribute intConstVal::Maybe<Integer> occurs on core:Expr, core:ValueItem, core:VarDecl;
aspect intConstVal on core:Expr of
| core:intLit(i) -> just(i)
| core:var(n) -> n.core:lookupValue.intConstVal
| core:negOp(e) -> map(negate, e.intConstVal)
| core:addOp(e1, e2) -> lift2(add, e1.intConstVal, e2.intConstVal)
| core:subOp(e1, e2) -> lift2(sub, e1.intConstVal, e2.intConstVal)
| core:mulOp(e1, e2) -> lift2(mul, e1.intConstVal, e2.intConstVal)
| core:divOp(e1, e2) ->
    if e1.intConstVal == just(0) then nothing()
    else lift2(div, e1.intConstVal, e2.intConstVal)
| _ -> nothing()
end;
aspect intConstVal on core:ValueItem of
| core:varValueItem(d) -> d.intConstVal
| _ -> nothing()
end;
aspect intConstVal on core:VarDecl of
| core:varDecl(_, _, i) -> i.intConstVal
| core:autoVarDecl(_, i) -> i.intConstVal
end;
