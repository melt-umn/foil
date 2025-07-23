grammar edu:umn:cs:melt:foil:host:langs:core;

inherited attribute returnType::Maybe<Type>;

synthesized attribute hasReturn::Boolean;

tracked nonterminal Stmt with pp, returnType, env, defs, hasReturn, errors;
propagate returnType, defs, errors on Stmt;

aspect default production
top::Stmt ::=
{
  top.hasReturn = false;
}
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

  top.hasReturn = s1.hasReturn || s2.hasReturn;
}
production block
top::Stmt ::= s::Stmt
{
  top.pp = braces(groupnestlines(2, s.pp));
  s.env = openScopeEnv(top.env);
  top.hasReturn = s.hasReturn;
}
production decl
top::Stmt ::= d::VarDecl
{
  top.pp = pp"${d};";
  d.env = top.env;
}
production expr
top::Stmt ::= e::Expr
{
  top.pp = pp"${e.pp};";
  propagate env;
}
production assign
top::Stmt ::= lhs::Expr rhs::Expr
{
  top.pp = pp"${lhs} = ${box(rhs.pp)};";
  propagate env;
  top.errors <-
    if lhs.isLValue then []
    else [errFromOrigin(lhs, s"This value cannot be assigned to")];
  top.errors <-
    if lhs.type == rhs.type then []
    else [errFromOrigin(rhs, s"Assignment expected ${show(80, lhs.type)}, but got ${show(80, rhs.type)}")];
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
  top.hasReturn = t.hasReturn && e.hasReturn;
  top.errors <-
    if c.type == boolType() then []
    else [errFromOrigin(c, s"If condition expected a Boolean")];
}
production while
top::Stmt ::= c::Expr b::Stmt
{
  top.pp = pp"while (${box(c.pp)}) {${groupnestlines(2, b.pp)}}";
  propagate env;
  top.hasReturn = b.hasReturn;
  top.errors <-
    if c.type == boolType() then []
    else [errFromOrigin(c, s"While condition expected a Boolean")];
}
production return_
top::Stmt ::= e::Expr
{
  top.pp = pp"return ${box(e.pp)};";
  propagate env;
  top.hasReturn = true;
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
