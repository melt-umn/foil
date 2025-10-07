grammar edu:umn:cs:melt:foil:extensions:halide;

synthesized attribute toStmt::core:Stmt;

tracked nonterminal IterStmt with toStmt;

production stmt
top::IterStmt ::= s::Decorated core:Stmt
{
  top.toStmt = ^s;
}
production loop
top::IterStmt ::= var::Name limit::Decorated core:Expr body::IterStmt
{
  top.toStmt = Foil_Stmt {
    {
      var $Name{^var} : int = 0;
      while ($Name{^var} < $Expr{^limit}) {
        $Stmt{body.toStmt}
        $Name{^var} = $Name{^var} + 1;
      }
    }
  };
}
production unrollLoop
top::IterStmt ::= var::Name limit::Integer body::IterStmt
{
  local bodyI :: (core:Stmt ::= Integer) = \ i -> Foil_Stmt {
    $Name{^var} = $Expr{core:intLit(i)};
    $Stmt{body.toStmt}
  };
  top.toStmt = Foil_Stmt {
    {
      var $Name{^var} : int = 0;
      $Stmt{foldr(core:seq, core:emptyStmt(), map(bodyI, range(0, limit)))}
    }
  };
}

inherited attribute localVars::[Decorated Name] occurs on core:Stmt;
propagate localVars on core:Stmt excluding core:seq;
aspect production core:seq
top::core:Stmt ::= s1::core:Stmt s2::core:Stmt
{
  s1.localVars = top.localVars;
  s2.localVars = s1.defNames ++ s1.localVars;
}

synthesized attribute isIndepLoops::Boolean occurs on core:Stmt;
aspect isIndepLoops on core:Stmt of
| core:seq(s1, s2) ->
  if s2.core:isEmpty
  then s1.isIndepLoops
  else s1.isIndepDecls && s2.isIndepLoops
| core:block(s) -> s.isIndepLoops
| core:while(c, b) ->
  case c, b of
  | core:ltOp(core:var(v1), _),
    core:seq(_,
      core:assign(core:var(v2),
        core:addOp(core:var(v3), core:intLit(1)))) ->
    v1.name == v2.name && v1.name == v3.name
  | _, _ -> false
  end
| _ -> false
end;

synthesized attribute isIndepDecls::Boolean occurs on core:Stmt;
aspect isIndepDecls on top::core:Stmt of
| core:seq(s1, s2) -> s1.isIndepDecls && s2.isIndepDecls
| core:emptyStmt() -> true
| core:decl(d) -> !any(map(containsBy(decNameEq, _, d.freeVars), top.localVars))
| _ -> false
end;

synthesized attribute fromStmt::IterStmt occurs on core:Stmt;
synthesized attribute preDeclStmts::core:Stmt occurs on core:Stmt;

aspect fromStmt on top::core:Stmt of
| core:block(s) -> s.fromStmt
| core:seq(s1, s2) ->
  if s2.core:isEmpty then s1.fromStmt else s2.fromStmt
| core:while(c, b) ->
  case c, b of
  | core:ltOp(core:var(v1), limit),
    core:seq(_,
      core:assign(core:var(v2),
        core:addOp(core:var(v3), core:intLit(1))))
    when v1.name == v2.name && v1.name == v3.name ->
    loop(^v1, limit, if b.isIndepLoops then b.fromStmt else stmt(b))
  | _, _ -> error("Cannot convert ill-formed loop")
  end
| _ -> error("Cannot convert non-loop statement")
end;

aspect preDeclStmts on top::core:Stmt of
| core:block(s) -> s.preDeclStmts
| core:decl(d) -> ^top
| core:seq(s1, s2) -> s1.preDeclStmts ++ s2.preDeclStmts
| core:while(_, b) ->
  if b.isIndepLoops then b.preDeclStmts else core:emptyStmt()
| _ -> core:emptyStmt()
end;

fun decNameEq
Boolean ::= n1::Decorated Name n2::Decorated Name =
  n1.name == n2.name;

monoid attribute freeVars::[Decorated Name] occurs on
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

monoid attribute defNames::[Decorated Name] occurs on core:Stmt, core:VarDecl;
flowtype defNames {core:env} on core:Stmt, core:VarDecl;
propagate defNames on core:Stmt;

aspect defNames on core:VarDecl using := of
| core:varDecl(n, t, i) -> [n]
| core:autoVarDecl(n, t) -> [n]
end;
