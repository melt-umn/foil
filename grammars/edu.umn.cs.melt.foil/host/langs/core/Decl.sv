grammar edu:umn:cs:melt:foil:host:langs:core;

synthesized attribute initExpr::Decorated Expr;

tracked nonterminal VarDecl with pp, env, name, type, initExpr, defs, errors;
propagate env, errors on VarDecl;

production varDecl
top::VarDecl ::= n::Name t::TypeExpr i::Expr
{
  top.pp = pp"var ${n} : ${t} = ${groupnest(2, cat(line(), i.pp))}";
  top.name = n.name;
  top.type = t.type;
  top.initExpr = i;
  top.defs := valueDefs([varValueItem(top)]);
  top.errors <-
    if t.type == i.type then []
    else [errFromOrigin(i, s"Initialization expected ${show(80, t.type)}, but got ${show(80, i.type)}")];
}
production autoVarDecl
top::VarDecl ::= n::Name i::Expr
{
  top.pp = pp"var ${n} = ${i}";
  top.name = n.name;
  top.type = i.type;
  top.initExpr = i;
  top.defs := valueDefs([varValueItem(top)]);
}

synthesized attribute paramNames::[String];
synthesized attribute paramTypes::[Type];
synthesized attribute retType::Type;

tracked nonterminal FnDecl with pp, env, defs, name, paramNames, paramTypes, retType, errors;
propagate errors on FnDecl;

production fnDecl
top::FnDecl ::= n::Name params::Params ret::TypeExpr body::Stmt
{
  top.pp = pp"fun ${n}(${ppImplode(pp", ", params.pps)}) -> ${ret} {${groupnestlines(2, body.pp)}}";
  top.name = n.name;
  top.paramNames = params.paramNames;
  top.paramTypes = params.paramTypes;
  top.retType = ret.type;
  top.defs := valueDefs([fnValueItem(top)]);

  body.returnType = just(ret.type);

  params.env = top.env;
  ret.env = top.env;
  body.env = addEnv(params.defs, top.env);

  top.errors <-
    if ret.type == unitType() || body.hasReturn then []
    else [errFromOrigin(body, s"Function ${n.name} must return a value of type ${show(80, ret.type)}")];
}

tracked nonterminal Params with pps, env, paramNames, paramTypes, defs, errors;
propagate env, defs, errors on Params;

production consParam
top::Params ::= p::Param ps::Params
{
  top.pps = p.pp :: ps.pps;
  top.paramNames = p.name :: ps.paramNames;
  top.paramTypes = p.type :: ps.paramTypes;
}
production nilParam
top::Params ::= 
{
  top.pps = [];
  top.paramNames = [];
  top.paramTypes = [];
}
production appendParams
top::Params ::= ps1::Params ps2::Params
{
  forwards to
    case ps1 of
    | consParam(h, t) -> consParam(^h, appendParams(^t, @ps2))
    | nilParam() -> @ps2
    end;
}

tracked nonterminal Param with pp, env, name, type, defs, errors;
propagate env, errors on Param;

production param
top::Param ::= n::Name t::TypeExpr
{
  top.pp = pp"${n} : ${t}";
  top.name = n.name;
  top.type = t.type;
  top.defs := valueDefs([paramValueItem(top)]);
}

synthesized attribute declId::Integer;

tracked nonterminal StructDecl with pp, env, declId, name, fields, defs, errors;
propagate env, errors on StructDecl;

production structDecl
top::StructDecl ::= n::Name fs::Fields
{
  top.pp = pp"struct ${n} {${groupnestlines(2, ppImplode(pp",\n", fs.pps))}}";
  top.declId = genInt();
  top.name = n.name;
  top.fields = fs.fields;
  top.defs := typeDefs([structTypeItem(top)]);
  top.errors <-
    if null(fs.errors) then []
    else fs.errors;

  fs.declType = structType(top);
  top.errors <- fs.infiniteTypeErrors;
}

tracked nonterminal UnionDecl with pp, env, declId, name, fields, defs, errors;
propagate env, errors on UnionDecl;

production unionDecl
top::UnionDecl ::= n::Name fs::Fields
{
  top.pp = pp"union ${n} {${groupnestlines(2, ppImplode(pp",\n", fs.pps))}}";
  top.declId = genInt();
  top.name = n.name;
  top.fields = fs.fields;
  top.defs := typeDefs([unionTypeItem(top)]);
  top.errors <-
    if null(fs.errors) then []
    else fs.errors;

  fs.declType = unionType(top);
  top.errors <- fs.infiniteTypeErrors;
}

synthesized attribute fields::[(String, Type)];

inherited attribute declType::Type;
monoid attribute infiniteTypeErrors::[Message];

tracked nonterminal Fields with pps, env, fields, errors, declType, infiniteTypeErrors;
propagate env, errors, declType, infiniteTypeErrors on Fields;

production nilField
top::Fields ::=
{
  top.pps = [];
  top.fields = [];
}
production consField
top::Fields ::= f::Field fs::Fields
{
  top.pps = f.pp :: fs.pps;
  top.fields = (f.name, f.type) :: fs.fields;
  top.errors <-
    if lookup(f.name, fs.fields).isJust
    then [errFromOrigin(f, s"Duplicate field name '${f.name}'")]
    else [];
}

tracked nonterminal Field with pp, env, name, type, errors, declType, infiniteTypeErrors;
propagate env, errors on Field;

production field
top::Field ::= n::Name ty::TypeExpr
{
  top.pp = pp"${n} : ${ty}";
  top.name = n.name;
  top.type = ty.type;

  top.infiniteTypeErrors :=
    if contains(top.declType, nestedComponents([], top.type))
    then [errFromOrigin(ty, s"Field of type ${show(80, ty.type)} contains the type being declared")]
    else [];
}
