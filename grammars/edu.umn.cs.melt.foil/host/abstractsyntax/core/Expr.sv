grammar edu:umn:cs:melt:foil:host:abstractsyntax:core;

tracked nonterminal Expr with pp, env, type, errors;
propagate env on Expr excluding let_;
propagate errors on Expr;

production var
top::Expr ::= n::Name
{
  top.pp = n.pp;
  top.type = n.lookupValue.type;
  top.errors <- n.lookupValue.lookupErrors;
}
production let_
top::Expr ::= d::VarDecl b::Expr
{
  top.pp = pp"let${groupnestlines(2, d.pp)}in${groupnestlines(2, b.pp)}end";
  top.type = b.type;
  d.env = top.env;
  b.env = addEnv(d.defs, top.env);
}

-- Literals
production intLit
top::Expr ::= i::Integer
{
  top.pp = pp"${i}";
  top.type = intType();
}
production floatLit
top::Expr ::= f::Float
{
  top.pp = pp"${f}";
  top.type = floatType();
}
production trueLit
top::Expr ::=
{
  top.pp = pp"true";
  top.type = boolType();
}
production falseLit
top::Expr ::=
{
  top.pp = pp"false";
  top.type = boolType();
}
production stringLit
top::Expr ::= s::String
{
  top.pp = pp"${s}";
  top.type = stringType();
}

-- Operators
production addOp
top::Expr ::= e1::Expr e2::Expr
{
  top.pp = pp"(${e1}) + (${e2})";
  
}
