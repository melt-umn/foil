grammar edu:umn:cs:melt:foil:host:passes:ctrans;

attribute translation occurs on Expr;
aspect translation on Expr of
| var(n) -> n.pp
| let_(d, e) -> pp"({${box(pp"${d.varDeclTrans}\n${e.translation};")}})"
| call(f, args) -> pp"${f.pp}(${group(box(ppImplode(pp",\n", args.translations)))})"
| deref(e) -> pp"(*${e.translation})"
| arraySubscript(e, idx) -> pp"${e.translation}[${idx.translation}]"
| newPointer(e) ->
  pp"({${group(box(pp"${elemTy.baseTypePP} ${elemTy.declaratorPP} = GC_malloc(sizeof(${elemTy.baseTypePP} ${elemTy.typeModifierPP}));\n*_ptr = ${e.translation};\n_ptr;"))}})"
| newArray(s, i) -> error("TODO: arrays")
| arrayLit(_) -> error("TODO: array literals")
| structLit(n, fs) -> pp"(${n}){${groupnestlines(2, ppImplode(pp",\n", fs.translations))}}"
| fieldAccess(e, f) -> pp"${e.translation}.${f}"
| intLit(i) -> pp(i)
| floatLit(f) -> pp(f)
| trueLit() -> pp"1"
| falseLit() -> pp"0"
| stringLit(s) -> pp"(struct _string){${text(toString(length(s)))}, ${s}}"
| unitLit() -> pp"0"
| cond(c, t, e) -> parens(box(group(pp"${c.translation} ?\n${t.translation} :\n${e.translation}")))
| negOp(e) -> pp"(-${e.translation})"
| addOp(lhs, rhs) -> binOpTrans("+", lhs, rhs)
| subOp(lhs, rhs) -> binOpTrans("-", lhs, rhs)
| mulOp(lhs, rhs) -> binOpTrans("*", lhs, rhs)
| divOp(lhs, rhs) -> binOpTrans("/", lhs, rhs)
| modOp(lhs, rhs) -> binOpTrans("%", lhs, rhs)
| eqOp(lhs, rhs) -> binOpTrans("==", lhs, rhs)
| neqOp(lhs, rhs) -> binOpTrans("!=", lhs, rhs)
| ltOp(lhs, rhs) -> binOpTrans("<", lhs, rhs)
| lteOp(lhs, rhs) -> binOpTrans("<=", lhs, rhs)
| gtOp(lhs, rhs) -> binOpTrans(">", lhs, rhs)
| gteOp(lhs, rhs) -> binOpTrans(">=", lhs, rhs)
| andOp(lhs, rhs) -> binOpTrans("&&", lhs, rhs)
| orOp(lhs, rhs) -> binOpTrans("||", lhs, rhs)
| notOp(e) -> pp"(!${e.translation})"
| concatOp(lhs, rhs) ->
  pp"_concat_string(${group(box(pp"${lhs.translation},\n${rhs.translation}"))})"
| strOp(e) ->
  case e.type of
  | l1:intType() -> pp"_str_int(${e.translation})"
  | l1:floatType() -> pp"_str_float(${e.translation})"
  | l1:boolType() -> pp"_str_bool(${e.translation})"
  | l1:stringType() -> e.translation
  | l1:unitType() -> pp"(struct _string){2, \"()\"}"
  | _ -> error(s"str is not defined for type ${show(80, e.type)}")
  end
| print_(e) -> pp"printf(\"%s\", ${e.translation}.data)"
end;

fun binOpTrans Document ::= op::String lhs::Decorated Expr rhs::Decorated Expr =
  -- TODO: This crashes the pp library:
  -- parens(group(box(pp"${lhs.translation} ${text(op)}\n${rhs.translation}")));
  pp"(${lhs.translation} ${text(op)} ${rhs.translation})";

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