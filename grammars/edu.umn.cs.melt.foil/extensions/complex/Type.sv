grammar edu:umn:cs:melt:foil:extensions:complex;

production complexTypeExpr
top::TypeExpr ::=
{
  top.pp = pp"complex";
  top.type = complexType();
}