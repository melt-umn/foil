grammar edu:umn:cs:melt:foil:extensions:datatype;

production dataType
top::Type ::= d::Decorated DataDecl
{
  top.pp = text(d.name);
  top.mangledName = s"data_${d.name}_";
  top.isEqualTo = \ t::Type ->
    case t of
    | dataType(d2) -> d.declId == d2.declId
    | errorType() -> true
    | _ -> false
    end;
  top.typeExpr = nameTypeExpr(name(d.name));
  top.components = flatMap((.paramTypes), d.constructors);
}

synthesized attribute constructors :: [Decorated Constructor] occurs on TypeItem;
aspect default production
top::TypeItem ::=
{
  top.constructors = [];
}
production dataTypeItem
top::TypeItem ::= d::Decorated DataDecl
{
  top.name = d.name;
  top.type = dataType(d);
  top.constructors = d.constructors;
}

production constructorValueItem
top::ValueItem ::= c::Decorated Constructor
{
  top.name = c.name;
  top.type = fnType(c.paramTypes, dataType(c.dataDecl));
  top.isLValue = false;
}

production dataGlobalDecl
top::GlobalDecl ::= d::DataDecl
{
  top.pp = d.pp;
  propagate env, errors;
  top.defs := d.defs;
  top.toCore = @d.liftedDecls;

  top.defs <- valueDefs(map(constructorValueItem, d.constructors));
}

synthesized attribute unionName::Name;

tracked nonterminal DataDecl with pp, env, declId, name, constructors, defs, errors, unionName, liftedDecls;
propagate env, errors on DataDecl;

production dataDecl
top::DataDecl ::= n::Name cs::Constructors
{
  top.pp = pp"data ${n} {${groupnestlines(2, ppImplode(line(), cs.pps))}}";
  top.declId = genInt();
  top.name = n.name;
  top.constructors = cs.constructors;
  top.defs := typeDefs([dataTypeItem(top)]);
  cs.dataDecl = top;
  cs.index = 0;

  top.unionName = name(s"_${n.name}_content");
  top.liftedDecls = Foil_GlobalDecl {
    struct $Name{@n} {
      tag : int, content : $Name{top.unionName}
    }
    $GlobalDecl{core:unionGlobalDecl(core:unionDecl(top.unionName, @cs.ctorFields))}
    $GlobalDecl{@cs.liftedDecls}
  };
}

inherited attribute dataDecl::Decorated DataDecl;
inherited attribute index::Integer;
translation attribute ctorFields::core:Fields;

tracked nonterminal Constructors with pps, env, dataDecl, index, constructors, errors, liftedDecls, ctorFields;
propagate env, dataDecl, errors, liftedDecls on Constructors;

production consConstructor
top::Constructors ::= h::Constructor t::Constructors
{
  top.pps = h.pp :: t.pps;
  top.constructors = h :: t.constructors;
  top.errors <-
    if any(map(\ c::Decorated Constructor -> c.name == h.name, t.constructors))
    then [errFromOrigin(h, s"Duplicate constructor ${h.name}")]
    else [];
  top.ctorFields = core:consField(@h.ctorField, @t.ctorFields);
  h.index = top.index;
  t.index = top.index + 1;
}
production nilConstructor
top::Constructors ::=
{
  top.pps = [];
  top.constructors = [];
  top.ctorFields = core:nilField();
}

translation attribute ctorField::core:Field;

tracked nonterminal Constructor with pp, env, dataDecl, index, name, paramNames, paramTypes, errors, liftedDecls, ctorField;
propagate env, dataDecl, errors on Constructor;

production constructor
top::Constructor ::= n::Name params::Params
{
  top.pp = pp"${n}(${ppImplode(pp", ", params.pps)});";
  top.name = n.name;
  top.paramNames = params.paramNames;
  top.paramTypes = params.paramTypes;
  top.errors <- params.paramInfiniteTypeErrors;
  
  top.liftedDecls = Foil_GlobalDecl {
    $GlobalDecl{@params.liftedDecls}
    fun $Name{@n}($Params{@params.toCore}) -> $Name{name(top.dataDecl.name)} {
      return $Name{name(top.dataDecl.name)} {
        tag = $Expr{core:intLit(top.index)},
        content = $Name{top.dataDecl.unionName} {
          $Name{^n} = $Expr{core:recordLit(params.ctorInitFields)}
        }
      };
    }
  };
  top.ctorField = core:field(^n, core:recordTypeExpr(@params.ctorFields));
}

attribute dataDecl occurs on Params, Param;
propagate dataDecl on Params;

attribute ctorFields occurs on Params;
aspect ctorFields on Params of
| consParam(h, t) -> core:consField(@h.ctorField, @t.ctorFields)
| nilParam() -> core:nilField()
end;

attribute ctorField occurs on Param;
aspect ctorField on Param of
| param(n, t) -> core:field(^n, ^t.toCore)
end;

synthesized attribute ctorInitFields::core:FieldExprs occurs on Params;
aspect ctorInitFields on Params of
| consParam(h, t) -> core:consFieldExpr(h.ctorInitField, t.ctorInitFields)
| nilParam() -> core:nilFieldExpr()
end;

synthesized attribute ctorInitField::core:FieldExpr occurs on Param;
aspect ctorInitField on Param of
| param(n, t) -> core:fieldExpr(^n, core:var(^n))
end;

monoid attribute paramInfiniteTypeErrors::[Message] occurs on Params, Param;
propagate paramInfiniteTypeErrors on Params;
aspect paramInfiniteTypeErrors on top::Param using := of
| param(n, ty) ->
  if contains(dataType(top.dataDecl), nestedComponents([], ty.type))
  then [errFromOrigin(ty, s"Constructor parameter of type ${show(80, ty.type)} contains the type being declared")]
  else []
end;
