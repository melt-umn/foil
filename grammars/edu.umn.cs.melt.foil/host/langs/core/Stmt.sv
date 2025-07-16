grammar edu:umn:cs:melt:foil:host:langs:core;

inherited attribute returnType::Maybe<Type>;

tracked nonterminal Stmt with pp, returnType, env, defs, errors;
propagate returnType, defs, errors on Stmt;

production emptyStmt
top::Stmt ::=
{
  top.pp = pp"";
}
production seq
top::Stmt ::= s1::Stmt s2::Stmt
{
  top.pp = pp"${s1}\n${s2}";
  s1.env = top.env;
  s2.env = addEnv(s1.defs, s1.env);
}
production block
top::Stmt ::= s::Stmt
{
  top.pp = braces(groupnestlines(2, s.pp));
  s.env = openScopeEnv(top.env);
}
production declStmt
top::Stmt ::= d::VarDecl
{
  top.pp = pp"${d};";
  d.env = top.env;
}
production assign
top::Stmt ::= n::Name e::Expr
{
  top.pp = pp"${n} = ${box(e.pp)};";
  propagate env;
  top.errors <- n.lookupValue.lookupErrors;
  top.errors <-
    if n.lookupValue.isAssignable then []
    else [errFromOrigin(n, s"${n.name} cannot be assigned to")];
  top.errors <-
    if n.lookupValue.type == e.type then []
    else [errFromOrigin(e, s"${n.name} has type ${show(80, n.lookupValue.type)}, but the assigned expression has type ${show(80, e.type)}")];
}
production if_
top::Stmt ::= c::Expr t::Stmt e::Stmt
{
  top.pp = pp"if (${box(c.pp)}) {${groupnestlines(2, t.pp)}}${
    case e of
    | emptyStmt() -> pp""
    | _ -> braces(groupnestlines(2, e.pp))
    end}";
  propagate env;
  top.errors <-
    if c.type == boolType() then []
    else [errFromOrigin(c, s"If condition expected a Boolean")];
}
production while
top::Stmt ::= c::Expr b::Stmt
{
  top.pp = pp"while (${box(c.pp)}) {${groupnestlines(2, b.pp)}}";
  propagate env;
  top.errors <-
    if c.type == boolType() then []
    else [errFromOrigin(c, s"While condition expected a Boolean")];
}
production return_
top::Stmt ::= e::Expr
{
  top.pp = pp"return ${box(e.pp)};";
  propagate env;
  top.errors <-
    case top.returnType of
    | nothing() -> [errFromOrigin(top, "Unexpected return")]
    | just(t) when t != e.type -> [errFromOrigin(e, s"Return expected ${show(80, t)}, but got ${show(80, e.type)}")]
    | _ -> []
    end;
}


instance Semigroup Stmt {
  append = seq;
}
instance Monoid Stmt {
  mempty = emptyStmt();
}