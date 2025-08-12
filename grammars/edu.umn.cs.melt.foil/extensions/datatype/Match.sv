grammar edu:umn:cs:melt:foil:extensions:datatype;

production matchStmt
top::Stmt ::= s::Expr cs::MatchCases
{
  top.pp = pp"match (${s}) {${groupnestlines(2, ppImplode(line(), cs.pps))}}";
  propagate env, returnType, errors;
  top.defs := mempty;

  cs.scrutineeType = s.type;

  nondecorated local scrutName::Name = freshName();
  cs.successName = freshName();
  cs.scrutineeTrans = core:var(scrutName);
  propagate liftedDecls;
  top.toCore = Foil_Stmt {
    {
      var $Name{scrutName} = $Expr{@s.toCore};
      var $Name{cs.successName} = false;
      $Stmt{@cs.matchTrans}
    }
  };
}

inherited attribute successName::Name;
translation attribute matchTrans::core:Stmt;

tracked nonterminal MatchCases with pps, env, returnType, scrutineeType, errors, liftedDecls, scrutineeTrans, successName, matchTrans;
propagate env, returnType, scrutineeType, errors, liftedDecls, scrutineeTrans, successName on MatchCases;

production consMatchCase
top::MatchCases ::= c::MatchCase cs::MatchCases
{
  top.pps = c.pp :: cs.pps;
  top.matchTrans = core:seq(@c.matchTrans, @cs.matchTrans);
}
production nilMatchCase
top::MatchCases ::= 
{
  top.pps = [];
  top.matchTrans = core:emptyStmt();
}

tracked nonterminal MatchCase with pp, env, returnType, scrutineeType, errors, liftedDecls, scrutineeTrans, successName, matchTrans;
propagate returnType, scrutineeType, errors, liftedDecls, scrutineeTrans on MatchCase;

production matchCase
top::MatchCase ::= p::Pattern s::Stmt
{
  top.pp = pp"${p.pp} -> {${groupnestlines(2, s.pp)}}";
  p.env = top.env;
  p.patternEnv = addEnv(valueDefs(p.patternDefs), emptyEnv());
  s.env = addEnv(valueDefs(p.patternDefs), top.env);

  top.matchTrans = Foil_Stmt {
    if (!$Name{top.successName}) {
      $Stmt{p.patternTrans(Foil_Stmt { $Name{top.successName} = true; $Stmt{@s.toCore} })}
    }
  };
}
