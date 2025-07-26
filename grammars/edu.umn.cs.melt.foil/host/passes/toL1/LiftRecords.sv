grammar edu:umn:cs:melt:foil:host:passes:toL1;

aspect production recordTypeExpr
top::TypeExpr ::= fs::Fields
{
  local structName::String = "_" ++ top.type.mangledName;
  top.toL1 = l1:nameTypeExpr(name(structName));
  top.liftedDecls = l1:appendGlobalDecl(@fs.liftedDecls,
    if null(l1:lookupType(structName, top.liftedDecls.l1:declaredEnv))
    then l1:structGlobalDecl(l1:structDecl(name(structName), @fs.toL1))
    else l1:emptyGlobalDecl());
}
aspect production recordLit
top::Expr ::= fs::FieldExprs
{
  local structName::String = "_" ++ top.type.mangledName;
  top.toL1 = l1:structLit(name(structName), @fs.toL1);
  top.liftedDecls = l1:appendGlobalDecl(@fs.liftedDecls,
    l1:appendGlobalDecl(@fs.recordLiftedDecls,
      if null(l1:lookupType(structName, top.liftedDecls.l1:declaredEnv))
      then l1:structGlobalDecl(l1:structDecl(name(structName), @fs.recordStructFields))
      else l1:emptyGlobalDecl()));
}

translation attribute recordStructFields::l1:Fields occurs on FieldExprs;
translation attribute recordStructField::l1:Field occurs on FieldExpr;
translation attribute recordLiftedDecls::l1:GlobalDecl occurs on FieldExprs, FieldExpr;

aspect production consFieldExpr
top::FieldExprs ::= f::FieldExpr fs::FieldExprs
{
  top.recordStructFields = l1:consField(@f.recordStructField, @fs.recordStructFields);
  top.recordLiftedDecls = l1:appendGlobalDecl(@f.recordLiftedDecls, @fs.recordLiftedDecls);
}
aspect production nilFieldExpr
top::FieldExprs ::=
{
  top.recordStructFields = l1:nilField();
  top.recordLiftedDecls = l1:emptyGlobalDecl();
}
aspect production fieldExpr
top::FieldExpr ::= n::Name e::Expr
{
  production ty::TypeExpr = e.type.typeExpr;
  ty.env = top.env;

  top.recordStructField = l1:field(name(n.name), @ty.toL1);
  top.recordLiftedDecls = @ty.liftedDecls;
}
