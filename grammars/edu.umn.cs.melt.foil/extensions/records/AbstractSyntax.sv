grammar edu:umn:cs:melt:foil:extensions:records;

-- Invariant: fields are in sorted order by name
production recordType
top::Type ::= fs::[(String, Type)]
{
  top.pp = pp"record {${ppImplode(pp", ", map(\ f::(String, Type) -> pp"${text(f.1)}, ${f.2}", fs))}}";
  top.mangledName = "record_" ++ implode("_", map(\ f::(String, Type) -> f.1 ++ "_" ++ f.2.mangledName, fs)) ++ "_";
  top.typeExpr = nameTypeExpr(name("_" ++ top.mangledName));
  top.isEqualTo = \ other::Type ->
    case other of
    | recordType(otherFs) -> fs == otherFs
    | errorType() -> true
    | _ -> false
    end;
  top.structFields = just(fs);
}

production recordTypeExpr
top::TypeExpr ::= fs::Fields
{
  top.pp = pp"record {${ppImplode(pp", ", fs.pps)}}";
  propagate env, errors;
  top.type = recordType(sortByKey(fst, fs.fields));
  nondecorated local structName::Name = name("_" ++ top.type.mangledName);
  top.liftedDecls = core:mkAppendGlobalDecl(
    coreCondTypeDecl(structName,
      core:structGlobalDecl(core:structDecl(structName, @fs.toCore))),
    @fs.liftedDecls);
  top.toCore = core:nameTypeExpr(structName);
}

production recordLit
top::Expr ::= fs::FieldExprs
{
  top.pp = pp"record {${ppImplode(pp", ", fs.pps)}}";
  top.wrapPP = top.pp;
  propagate env, errors;
  top.type = recordType(sortByKey(fst, fs.fields));
  nondecorated local structName::Name = name("_" ++ top.type.mangledName);
  top.liftedDecls = core:mkAppendGlobalDecl(
    coreCondTypeDecl(structName,
      core:structGlobalDecl(core:structDecl(
        structName,
        foldr(core:consField, core:nilField(),
          map(\ f::(String, Type) -> core:field(name(f.1), coreTypeExpr(top.env, f.2.typeExpr)),
            fs.fields))))),
    @fs.liftedDecls);
  top.toCore = core:structLit(structName, @fs.toCore);
}

production coreCondTypeDecl
top::core:GlobalDecl ::= n::Name d::core:GlobalDecl
{
  top.pp = pp"condTypeDecl ${n} ${d.pp}";
  propagate core:env;
  forwards to
    if n.core:lookupType.found
    then core:emptyGlobalDecl()
    else @d;
}

production coreTypeExpr
top::core:TypeExpr ::= env::Env t::TypeExpr
{
  t.env = env;
  forwards to @t.toCore;
}
