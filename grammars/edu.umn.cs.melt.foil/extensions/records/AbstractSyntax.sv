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
  local structName::String = "_" ++ top.type.mangledName;
  top.liftedDecls = core:mkAppendGlobalDecl(
    coreCondTypeDecl(structName,
      core:structGlobalDecl(core:structDecl(core:name(structName), @fs.toCore))),
    @fs.liftedDecls);
  top.toCore = core:nameTypeExpr(core:name(structName));
}

production recordLit
top::Expr ::= fs::FieldExprs
{
  top.pp = pp"record {${ppImplode(pp", ", fs.pps)}}";
  top.wrapPP = top.pp;
  propagate env, errors;
  top.type = recordType(sortByKey(fst, fs.fields));
  local structName::String = "_" ++ top.type.mangledName;
  top.liftedDecls = core:mkAppendGlobalDecl(
    coreCondTypeDecl(structName,
      core:structGlobalDecl(core:structDecl(
        core:name(structName),
        foldr(core:consField, core:nilField(),
          map(\ f::(String, Type) -> core:field(core:name(f.1), coreTypeExpr(f.2.typeExpr)),
            fs.fields))))),
    @fs.liftedDecls);
  top.toCore = core:structLit(core:name(structName), @fs.toCore);
}

production coreCondTypeDecl
top::core:GlobalDecl ::= n::String d::core:GlobalDecl
{
  propagate env;
  forwards to
    case core:lookupType(n, top.core:declaredEnv) of
    | [] -> @d
    | t :: _ -> core:emptyGlobalDecl()
    end;
}

production coreTypeExpr
top::core:TypeExpr ::= t::TypeExpr
{
  forwards to @t.toCore;
}
