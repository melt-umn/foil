grammar edu:umn:cs:melt:foil:host:abstractsyntax:core;

tracked nonterminal Decl with pp, env, name, type, errors;
propagate env, errors on Decl;

production varDecl
top::Decl ::= n::Name t::Type i::Expr
{
  top.type = ^t;
}

