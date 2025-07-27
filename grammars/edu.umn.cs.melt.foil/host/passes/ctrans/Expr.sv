grammar edu:umn:cs:melt:foil:host:passes:ctrans;

attribute translation occurs on Expr;
aspect translation on Expr of
| var(n) -> n.pp
| let_(d, e) -> pp"({${d.translation} ${e.translation};})"
| call(f, args) -> pp"${f.pp}(${ppImplode(pp", ", args.translations)})"
| deref(e) -> pp"(*${e.translation})"
| arraySubscript(e, idx) -> pp"${e.translation}[${idx.translation}]"
| newPointer(e) ->
  pp"({${elemTy.baseTypePP} ${elemTy.declaratorPP} = GC_malloc(sizeof(${elemTy.baseTypePP} ${elemTy.typeModifierPP}; *_ptr = ${e.translation}; _ptr;})"
| newArray(s, i) -> error("TODO: arrays")
| arrayLit(_) -> error("TODO: array literals")
| structLit(n, fs) -> pp"(${n}){${ppImplode(pp", ", fs.translations)}}"
| fieldAccess(e, f) -> pp"${e.translation}.${f}"
| intLit(i) -> pp(i)
| floatLit(f) -> pp(f)
| trueLit() -> pp"1"
| falseLit() -> pp"0"
| stringLit(s) -> pp"\"${escapeString(s)}\""
| unitLit() -> pp"0"
| cond(c, t, e) -> pp"(${c.translation} ? ${t.translation} : ${e.translation})"
| negOp(e) -> pp"(-${e.translation})"
| addOp(lhs, rhs) -> pp"(${lhs.translation} + ${rhs.translation})"
| subOp(lhs, rhs) -> pp"(${lhs.translation} - ${rhs.translation})"
| mulOp(lhs, rhs) -> pp"(${lhs.translation} * ${rhs.translation})"
| divOp(lhs, rhs) -> pp"(${lhs.translation} / ${rhs.translation})"
| modOp(lhs, rhs) -> pp"(${lhs.translation} % ${rhs.translation})"
| eqOp(lhs, rhs) -> pp"(${lhs.translation} == ${rhs.translation})"
| neqOp(lhs, rhs) -> pp"(${lhs.translation} != ${rhs.translation})"
| ltOp(lhs, rhs) -> pp"(${lhs.translation} < ${rhs.translation})"
| lteOp(lhs, rhs) -> pp"(${lhs.translation} <= ${rhs.translation})"
| gtOp(lhs, rhs) -> pp"(${lhs.translation} > ${rhs.translation})"
| gteOp(lhs, rhs) -> pp"(${lhs.translation} >= ${rhs.translation})"
| andOp(lhs, rhs) -> pp"(${lhs.translation} && ${rhs.translation})"
| orOp(lhs, rhs) -> pp"(${lhs.translation} || ${rhs.translation})"
| notOp(e) -> pp"(!${e.translation})"
end;

aspect production newPointer
top::Expr ::= i::Expr
{
  production elemTy1::l1:TypeExpr = i.type.l1:elemType.l1:typeExpr;
  elemTy1.l1:env = top.env;
  production elemTy::TypeExpr = @elemTy1.toL2;
  elemTy.declName = name("_ptr");
}

attribute translations occurs on Exprs;
aspect translations on Exprs of
| consExpr(e, es) -> e.translation :: es.translations
| nilExpr() -> []
end;

attribute translations occurs on FieldExprs;
aspect translations on FieldExprs of
| consFieldExpr(f, fs) -> f.translation :: fs.translations
| nilFieldExpr() -> []
end;

attribute translation occurs on FieldExpr;
aspect translation on FieldExpr of
| fieldExpr(n, e) -> pp".${n} = ${e.translation}"
end;