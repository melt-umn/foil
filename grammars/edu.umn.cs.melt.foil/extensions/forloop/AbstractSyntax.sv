grammar edu:umn:cs:melt:foil:extensions:forloop;

production forLoop
top::Stmt ::= n::Name e1::Expr e2::Expr body::Stmt
{
  top.pp = pp"for (${n} in ${e1} : ${e2}) {${groupnestlines(2, body.pp)}}";

  nondecorated local upperVar::Name = freshName();
  forwards to block(seq(
    decl(autoVarDecl(@n, @e1)),
    seq(
      decl(autoVarDecl(upperVar, @e2)),
      while(ltOp(var(^n), var(upperVar)),
        seq(
          @body,
          assign(var(^n), addOp(var(^n), intLit(1)))
        )
      )
    )
  ));
}
