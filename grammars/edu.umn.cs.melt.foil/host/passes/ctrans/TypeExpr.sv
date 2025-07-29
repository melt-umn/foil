grammar edu:umn:cs:melt:foil:host:passes:ctrans;

attribute translation occurs on TypeExpr;
aspect default production
top::TypeExpr ::=
{
  top.translation = pp"${top.baseTypePP} ${top.typeModifierPP}";
}

attribute translations occurs on TypeExprs;
aspect translations on TypeExprs of
| consTypeExpr(h, t) -> h.translation :: t.translations
| nilTypeExpr() -> []
end;

synthesized attribute baseTypePP::Document occurs on TypeExpr;
synthesized attribute typeModifierPP::Document occurs on TypeExpr;

inherited attribute declName::Name occurs on TypeExpr;
synthesized attribute declaratorPP::Document occurs on TypeExpr;

aspect production nameTypeExpr
top::TypeExpr ::= n::Name
{
  top.baseTypePP = n.pp;
  top.typeModifierPP = pp"";
  top.declaratorPP = top.declName.pp;
}
aspect production intTypeExpr
top::TypeExpr ::=
{
  top.baseTypePP = pp"int";
  top.typeModifierPP = pp"";
  top.declaratorPP = top.declName.pp;
}
aspect production floatTypeExpr
top::TypeExpr ::=
{
  top.baseTypePP = pp"float";
  top.typeModifierPP = pp"";
  top.declaratorPP = top.declName.pp;
}
aspect production boolTypeExpr
top::TypeExpr ::=
{
  top.baseTypePP = pp"_Bool";
  top.typeModifierPP = pp"";
  top.declaratorPP = top.declName.pp;
}
aspect production stringTypeExpr
top::TypeExpr ::=
{
  top.baseTypePP = pp"struct _string";
  top.typeModifierPP = pp"";
  top.declaratorPP = pp"${top.declName}";
}
aspect production unitTypeExpr
top::TypeExpr ::=
{
  top.baseTypePP = pp"int";
  top.typeModifierPP = pp"";
  top.declaratorPP = top.declName.pp;
}
aspect production anyPointerTypeExpr
top::TypeExpr ::=
{
  top.baseTypePP = pp"void";
  top.typeModifierPP = pp"*";
  top.declaratorPP = pp"*${top.declName}";
}
aspect production pointerTypeExpr
top::TypeExpr ::= t::TypeExpr
{
  top.baseTypePP = t.baseTypePP;
  top.typeModifierPP = pp"*${t.typeModifierPP}";
  top.declaratorPP = pp"*${t.declaratorPP}";
  t.declName = top.declName;
}
aspect production arrayTypeExpr
top::TypeExpr ::= t::TypeExpr
{
  top.baseTypePP = error("TODO");
  top.typeModifierPP = error("TODO");
  top.declaratorPP = error("TODO");
}
aspect production fnTypeExpr
top::TypeExpr ::= args::TypeExprs ret::TypeExpr
{
  top.baseTypePP = ret.baseTypePP;
  top.typeModifierPP = pp"(*${ret.typeModifierPP})(${ppImplode(pp", ", args.translations)})";
  top.declaratorPP = pp"(*${ret.declaratorPP})(${ppImplode(pp", ", args.translations)})";
  ret.declName = top.declName;
}
