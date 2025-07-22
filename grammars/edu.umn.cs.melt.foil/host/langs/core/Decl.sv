grammar edu:umn:cs:melt:foil:host:langs:core;

tracked nonterminal VarDecl with pp, env, name, type, defs, errors;
propagate env, errors on VarDecl;

production varDecl
top::VarDecl ::= n::Name t::TypeExpr i::Expr
{
  top.pp = pp"var ${n} : ${t} = ${i};";
  top.name = n.name;
  top.type = t.type;
  top.defs := valueDefs([varValueItem(top)]);
  top.errors <-
    if t.type == i.type then []
    else [errFromOrigin(i, s"Initialization expected ${show(80, t.type)}, but got ${show(80, i.type)}")];
}

synthesized attribute paramTypes::[Type];
synthesized attribute retType::Type;

tracked nonterminal FnDecl with pp, env, defs, name, paramTypes, retType, errors;
propagate errors on FnDecl;

production fnDecl
top::FnDecl ::= n::Name params::Params ret::TypeExpr body::Stmt
{
  top.pp = pp"fun ${n}(${ppImplode(pp", ", params.pps)}) -> ${ret} {${groupnestlines(2, body.pp)}";
  top.name = n.name;
  top.paramTypes = params.paramTypes;
  top.retType = ret.type;
  top.defs := valueDefs([fnValueItem(top)]);

  body.returnType = just(ret.type);

  params.env = top.env;
  ret.env = top.env;
  body.env = addEnv(params.defs, top.env);

  top.errors <-
    if ret.type == recordType([]) || body.hasReturn then []
    else [errFromOrigin(body, s"Function ${n.name} must return a value of type ${show(80, ret.type)}")];
}

tracked nonterminal Params with pps, env, paramTypes, defs, errors;
propagate env, defs, errors on Params;

production consParam
top::Params ::= p::Param ps::Params
{
  top.pps = p.pp :: ps.pps;
  top.paramTypes = p.type :: ps.paramTypes;
}
production nilParam
top::Params ::= 
{
  top.pps = [];
  top.paramTypes = [];
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

tracked nonterminal StructDecl with pp, env, name, fields, defs, errors;
propagate env, errors on StructDecl;

production structDecl
top::StructDecl ::= n::Name fs::Fields
{
  top.pp = pp"struct ${n} {${groupnestlines(2, ppImplode(pp",\n", fs.pps))}}";
  top.name = n.name;
  top.fields = fs.fields;
  top.defs := typeDefs([structTypeItem(top)]);
  top.errors <-
    if null(fs.errors) then []
    else fs.errors;
}
