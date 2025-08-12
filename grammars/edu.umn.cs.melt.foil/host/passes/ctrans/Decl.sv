grammar edu:umn:cs:melt:foil:host:passes:ctrans;

attribute protoDecls occurs on VarDecl, FnDecl, StructDecl, UnionDecl;
attribute translation occurs on VarDecl, FnDecl, Param, StructDecl, UnionDecl, Field;
attribute translations occurs on Params, Fields;

aspect production varDecl
top::VarDecl ::= n::Name t::TypeExpr i::Expr
{
  top.protoDecls := pp"${t.baseTypePP} ${t.declaratorPP};${line()}";
  top.translation = pp"${t.baseTypePP} ${t.declaratorPP} =${group(nest(2, cat(line(), i.translation)))};";
  t.declName = ^n;
}

aspect production fnDecl
top::FnDecl ::= n::Name ps::Params ret::TypeExpr body::Stmt
{
  top.protoDecls := pp"${ret.baseTypePP} ${ret.declaratorPP}(${ppImplode(pp", ", ps.translations)});${line()}";
  top.translation = pp"""${ret.baseTypePP} ${ret.declaratorPP}(${ppImplode(pp", ", ps.translations)}) {
  ${groupnest(2, body.translation)}
  ${if ret.type == l1:unitType() && !body.hasReturn then pp"return 0;" else pp""}
}
""";
  ret.declName = ^n;
}

aspect translations on Params of
| consParam(p, ps) -> p.translation :: ps.translations
| nilParam -> []
end;

aspect production param
top::Param ::= n::Name t::TypeExpr
{
  top.translation = pp"${t.baseTypePP} ${t.declaratorPP}";
  t.declName = ^n;
}

aspect production structDecl
top::StructDecl ::= n::Name fs::Fields
{
  top.protoDecls := pp"typedef struct ${n} ${n};${line()}";
  top.translation = pp"struct ${n} {${groupnestlines(2, ppImplode(line(), fs.translations))}};${line()}";
}
aspect production unionDecl
top::UnionDecl ::= n::Name fs::Fields
{
  top.protoDecls := pp"typedef union ${n} ${n};${line()}";
  top.translation = pp"union ${n} {${groupnestlines(2, ppImplode(line(), fs.translations))}};${line()}";
}

aspect translations on Fields of
| consField(f, fs) -> f.translation :: fs.translations
| nilField -> []
end;

aspect production field
top::Field ::= n::Name t::TypeExpr
{
  top.translation = pp"${t.baseTypePP} ${t.declaratorPP};";
  t.declName = ^n;
}
