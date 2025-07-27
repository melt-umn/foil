grammar edu:umn:cs:melt:foil:host:langs:ext;

aspect production strOp
top::Expr ::= e::Expr
{
  top.toCore = e.type.strImpl(@e.toCore);
}

dispatch StrImpl = core:Expr ::= e::core:Expr;
synthesized attribute strImpl::StrImpl occurs on Type;
aspect default production
top::Type ::=
{
  top.strImpl = defaultStrImpl;
}

production defaultStrImpl implements StrImpl
top::core:Expr ::= e::core:Expr
{
  forwards to core:strOp(@e);
}

production bindStrImpl implements StrImpl
top::core:Expr ::= e::core:Expr impl::(core:Expr ::= Name)
{
  nondecorated local tmp::Name = freshName();
  forwards to core:let_(core:autoVarDecl(tmp, @e), impl(tmp));
}
