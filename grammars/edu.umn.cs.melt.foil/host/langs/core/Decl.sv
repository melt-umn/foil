grammar edu:umn:cs:melt:foil:host:langs:core;

tracked nonterminal VarDecl with pp, env, name, type, defs, errors;
propagate env, errors on VarDecl;

production varDecl
top::VarDecl ::= n::Name t::TypeExpr i::Expr
{
  top.pp = pp"var ${n} : ${t} = ${i};";
  top.name = n.name;
  top.type = t.type;
  top.defs := valueDef(varValueItem(top));
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
  top.paramTypes = params.paramTypes;
  top.retType = ret.type;
  top.defs := valueDef(fnValueItem(top));

  params.env = top.env;
  ret.env = top.env;
  body.env = addEnv(params.defs, top.env);
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
  top.defs := valueDef(paramValueItem(top));
}
