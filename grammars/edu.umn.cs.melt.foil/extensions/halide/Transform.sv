grammar edu:umn:cs:melt:foil:extensions:halide;

production transform
top::Stmt ::= body::Stmt ts::Transforms
{
  top.pp = pp"transform {${nestlines(2, body.pp)}} by {${nestlines(2, ppImplode(line(), ts.pps))}}";
  propagate errors;
  top.defs := mempty;

  body.env = top.env;
  body.returnType = top.returnType;
  
  body.toCore.core:env = top.toCore.core:env;
  body.toCore.core:returnType = top.toCore.core:returnType;

  ts.stmtsIn =
    if body.toCore.isIndepLoops
    then body.toCore.fromStmt
    else stmt(body.toCore);

  top.toCore = core:block(core:seq(body.toCore.preDeclStmts, ts.stmtsOut.toStmt));
  top.liftedDecls = @body.liftedDecls;
}

threaded attribute stmtsIn, stmtsOut :: IterStmt;

tracked nonterminal Transforms with pps, errors, stmtsIn, stmtsOut;
propagate stmtsIn, stmtsOut on Transforms;

production consTransform
top::Transforms ::= t::Transform ts::Transforms
{
  top.pps = t.pp :: ts.pps;
  top.errors := if null(t.errors) then ts.errors else t.errors;
}
production nilTransform
top::Transforms ::=
{
  top.pps = [];
  top.errors := [];
}

tracked nonterminal Transform with pp, errors, stmtsIn, stmtsOut;
