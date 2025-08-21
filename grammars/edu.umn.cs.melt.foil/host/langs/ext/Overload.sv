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

dispatch UnaryOpImpl = core:Expr ::= e::core:Expr;
synthesized attribute negOpImpl::UnaryOpImpl occurs on Type;
aspect default production
top::Type ::=
{ top.negOpImpl = defaultNegOpImpl; }
production defaultNegOpImpl implements UnaryOpImpl
top::core:Expr ::= e::core:Expr
{
  forwards to core:negOp(@e);
}
production bindNegOpImpl implements UnaryOpImpl
top::core:Expr ::= e::core:Expr impl::(core:Expr ::= Name)
{
  nondecorated local tmp::Name = freshName();
  forwards to core:let_(core:autoVarDecl(tmp, @e), impl(tmp));
}
aspect production negOp
top::Expr ::= e::Expr
{
  top.toCore = e.type.negOpImpl(@e.toCore);
}

dispatch BinOpImpl = core:Expr ::= l::core:Expr r::core:Expr;
synthesized attribute addOpImpl::BinOpImpl occurs on Type;
synthesized attribute subOpImpl::BinOpImpl occurs on Type;
synthesized attribute mulOpImpl::BinOpImpl occurs on Type;
synthesized attribute divOpImpl::BinOpImpl occurs on Type;
synthesized attribute eqOpImpl::BinOpImpl occurs on Type;
synthesized attribute neqOpImpl::BinOpImpl occurs on Type;
synthesized attribute gtOpImpl::BinOpImpl occurs on Type;
synthesized attribute ltOpImpl::BinOpImpl occurs on Type;
synthesized attribute gteOpImpl::BinOpImpl occurs on Type;
synthesized attribute lteOpImpl::BinOpImpl occurs on Type;
aspect default production
top::Type ::=
{
  top.addOpImpl = defaultAddOpImpl;
  top.subOpImpl = defaultSubOpImpl;
  top.mulOpImpl = defaultMulOpImpl;
  top.divOpImpl = defaultDivOpImpl;
  top.eqOpImpl = defaultEqOpImpl;
  top.neqOpImpl = defaultNeqOpImpl;
  top.gtOpImpl = defaultGtOpImpl;
  top.ltOpImpl = defaultLtOpImpl;
  top.gteOpImpl = defaultGteOpImpl;
  top.lteOpImpl = defaultLteOpImpl;
}
production defaultAddOpImpl implements BinOpImpl
top::core:Expr ::= l::core:Expr r::core:Expr
{
  forwards to core:addOp(@l, @r);
}
production defaultSubOpImpl implements BinOpImpl
top::core:Expr ::= l::core:Expr r::core:Expr
{
  forwards to core:subOp(@l, @r);
}
production defaultMulOpImpl implements BinOpImpl
top::core:Expr ::= l::core:Expr r::core:Expr
{
  forwards to core:mulOp(@l, @r);
}
production defaultDivOpImpl implements BinOpImpl
top::core:Expr ::= l::core:Expr r::core:Expr
{
  forwards to core:divOp(@l, @r);
}
production defaultEqOpImpl implements BinOpImpl
top::core:Expr ::= l::core:Expr r::core:Expr
{
  forwards to core:eqOp(@l, @r);
}
production defaultNeqOpImpl implements BinOpImpl
top::core:Expr ::= l::core:Expr r::core:Expr
{
  forwards to core:neqOp(@l, @r);
}
production defaultGtOpImpl implements BinOpImpl
top::core:Expr ::= l::core:Expr r::core:Expr
{
  forwards to core:gtOp(@l, @r);
}
production defaultLtOpImpl implements BinOpImpl
top::core:Expr ::= l::core:Expr r::core:Expr
{
  forwards to core:ltOp(@l, @r);
}
production defaultGteOpImpl implements BinOpImpl
top::core:Expr ::= l::core:Expr r::core:Expr
{
  forwards to core:gteOp(@l, @r);
}
production defaultLteOpImpl implements BinOpImpl
top::core:Expr ::= l::core:Expr r::core:Expr
{
  forwards to core:lteOp(@l, @r);
}
production bindBinOpImpl implements BinOpImpl
top::core:Expr ::= l::core:Expr r::core:Expr impl::(core:Expr ::= Name Name)
{
  nondecorated local tmp1::Name = freshName();
  nondecorated local tmp2::Name = freshName();
  forwards to core:let_(
    core:autoVarDecl(tmp1, @l),
    core:let_(
      core:autoVarDecl(tmp2, @r),
      impl(tmp1, tmp2)));
}
aspect toCore on Expr of
| addOp(l, r) -> l.type.addOpImpl(@l.toCore, @r.toCore)
| subOp(l, r) -> l.type.subOpImpl(@l.toCore, @r.toCore)
| mulOp(l, r) -> l.type.mulOpImpl(@l.toCore, @r.toCore)
| divOp(l, r) -> l.type.divOpImpl(@l.toCore, @r.toCore)
| eqOp(l, r) -> l.type.eqOpImpl(@l.toCore, @r.toCore)
| neqOp(l, r) -> l.type.neqOpImpl(@l.toCore, @r.toCore)
| gtOp(l, r) -> l.type.gtOpImpl(@l.toCore, @r.toCore)
| ltOp(l, r) -> l.type.ltOpImpl(@l.toCore, @r.toCore)
| gteOp(l, r) -> l.type.gteOpImpl(@l.toCore, @r.toCore)
| lteOp(l, r) -> l.type.lteOpImpl(@l.toCore, @r.toCore)
end;

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
