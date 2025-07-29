grammar edu:umn:cs:melt:foil:host:langs:ext;

dispatch CallImpl = core:Expr ::= f::core:Expr a::core:Exprs;
synthesized attribute callImpl::CallImpl occurs on Type;
aspect default production
top::Type ::=
{ top.callImpl = defaultCallImpl; }

production defaultCallImpl implements CallImpl
top::core:Expr ::= f::core:Expr a::core:Exprs
{
  forwards to core:call(@f, @a);
}
production bindCallImpl implements CallImpl
top::core:Expr ::= f::core:Expr a::core:Exprs fnImpl::(core:Expr ::= Name) extraArgs::(core:Exprs ::= Name)
{
  nondecorated local tmp::Name = freshName();
  forwards to core:let_(
    core:autoVarDecl(tmp, @f),
    core:call(fnImpl(tmp), core:appendExprs(extraArgs(tmp), @a)));
}

aspect production call
top::Expr ::= f::Expr a::Exprs
{
  top.toCore = f.type.callImpl(@f.toCore, @a.toCore);
}


dispatch StrImpl = core:Expr ::= e::core:Expr;
synthesized attribute strImpl::StrImpl occurs on Type;
aspect default production
top::Type ::=
{ top.strImpl = defaultStrImpl; }

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

aspect production strOp
top::Expr ::= e::Expr
{
  top.toCore = e.type.strImpl(@e.toCore);
}
