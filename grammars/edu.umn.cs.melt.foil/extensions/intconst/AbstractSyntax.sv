grammar edu:umn:cs:melt:foil:extensions:intconst;

production intConstDecl
top::VarDecl ::= n::Name e::Expr
{
  top.pp = pp"intconst ${n} = ${e};";
  top.name = n.name;

  e.env = top.env;
  top.errors <-
    if e.intConstVal.isJust then []
    else [errFromOrigin(e, s"Expected an integer constant expression")];

  forwards to
    varDecl(@n, intTypeExpr(), intLit(fromMaybe(0, e.intConstVal)));
}

synthesized attribute intConstVal::Maybe<Integer> occurs on Expr, VarDecl, ValueItem;

aspect intConstVal on Expr of
| var(n) -> n.lookupValue.intConstVal
| let_(d, b) -> b.intConstVal
| intLit(i) -> just(i)
| negOp(e) -> map(negate, e.intConstVal)
| addOp(e1, e2) -> lift2(add, e1.intConstVal, e2.intConstVal)
| subOp(e1, e2) -> lift2(sub, e1.intConstVal, e2.intConstVal)
| mulOp(e1, e2) -> lift2(mul, e1.intConstVal, e2.intConstVal)
| divOp(e1, e2) -> lift2(div, e1.intConstVal, e2.intConstVal)
| modOp(e1, e2) -> lift2(mod, e1.intConstVal, e2.intConstVal)
| _ -> nothing()
end;

aspect intConstVal on VarDecl of
| varDecl(n, t, e) -> e.intConstVal
| autoVarDecl(n, e) -> e.intConstVal
| intConstDecl(n, e) -> e.intConstVal
| _ -> nothing()
end;

aspect intConstVal on ValueItem of
| varValueItem(d) -> d.intConstVal
| _ -> nothing()
end;
