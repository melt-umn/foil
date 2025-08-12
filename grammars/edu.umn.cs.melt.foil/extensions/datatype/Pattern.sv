grammar edu:umn:cs:melt:foil:extensions:datatype;

production patVarValueItem
top::ValueItem ::= n::Decorated Name ty::Type
{
  top.name = n.name;
  top.type = ty;
  top.isLValue = false; -- TODO?
}

inherited attribute patternEnv::Env;
inherited attribute scrutineeType::Type;
monoid attribute patternDefs::[ValueItem];

inherited attribute scrutineeTrans::core:Expr;
monoid attribute patternTrans::PatternTrans;

tracked nonterminal Pattern with pp, env, patternEnv, scrutineeType, patternDefs, errors, scrutineeTrans, patternTrans;
propagate env, patternEnv, patternDefs, errors on Pattern;

production wildPattern
top::Pattern ::=
{
  top.pp = pp"_";
  propagate patternTrans;
}
production varPattern
top::Pattern ::= n::Name
{
  top.pp = n.pp;
  top.patternDefs <- [patVarValueItem(n, top.scrutineeType)];
  top.errors <-
    if length(lookupValue(n.name, top.patternEnv)) >= 2
    then [errFromOrigin(n, s"Multiple definitions of pattern variable ${n.name}")]
    else [];

  top.patternTrans := letPatternTrans(^n, top.scrutineeTrans);
}
production bothPattern
top::Pattern ::= p1::Pattern p2::Pattern
{
  top.pp = pp"${p1.pp}@${p2.pp}";
  propagate scrutineeType, scrutineeTrans, patternTrans;
}
production pointerPattern
top::Pattern ::= p::Pattern
{
  top.pp = pp"&${p.pp}";
  p.scrutineeType = 
    case top.scrutineeType of
    | pointerType(t) -> t
    | _ -> errorType()
    end;
  top.errors <-
    case top.scrutineeType of
    | pointerType(_) -> []
    | errorType() -> []
    | _ -> [errFromOrigin(top, s"& expected to match a pointer type, but found ${show(80, top.scrutineeType)}")]
    end;

  nondecorated local derefName::Name = freshName();
  p.scrutineeTrans = core:var(derefName);
  top.patternTrans :=
    letPatternTrans(derefName, core:deref(top.scrutineeTrans)) ++ p.patternTrans;
}
production constructorPattern
top::Pattern ::= n::Name ps::Patterns
{
  top.pp = pp"${n}(${ppImplode(pp", ", ps.pps)})";
  top.errors <-
    case top.scrutineeType, n.lookupValue of
    | dataType(d), constructorValueItem(c)
      when any(map(\ c::Decorated Constructor -> c.name == n.name, d.constructors)) ->
        if ps.count != length(c.paramTypes)
        then [errFromOrigin(ps, s"Constructor ${n.name} expects ${toString(length(c.paramTypes))} patterns, but got ${toString(length(ps.pps))}")]
        else []
    | dataType(d), _ -> [errFromOrigin(n, s"${n.name} is not a constructor for data type ${d.name}")]
    | _, _ -> [errFromOrigin(n, s"Constructor pattern expected to match a data type, but found ${show(80, top.scrutineeType)}")]
    end;

  ps.scrutineeTypes =
    case n.lookupValue of
    | constructorValueItem(c) -> c.paramTypes
    | _ -> []
    end;

  local ctorIndex::Integer =
    case n.lookupValue of
    | constructorValueItem(c) -> c.index
    | _ -> 0
    end;

  ps.scrutineesTrans =
    case n.lookupValue of
    | constructorValueItem(c) ->
      map(\ f -> Foil_Expr { $Expr{top.scrutineeTrans}.content.$Name{^n}.$Name{name(f)} }, c.paramNames)
    | _ -> []
    end;

  top.patternTrans :=
    case n.lookupValue of
    | constructorValueItem(c) -> 
      condPatternTrans(Foil_Expr { $Expr{top.scrutineeTrans}.tag == $Expr{core:intLit(c.index)} })
    | _ -> mempty
    end ++
    ps.patternTrans;
}
production structPattern
top::Pattern ::= fs::FieldPatterns
{
  top.pp = braces(ppImplode(pp", ", fs.pps));
  top.errors <-
    if top.scrutineeType.structFields.isJust then []
    else [errFromOrigin(fs, s"${show(80, top.scrutineeType)} does not have fields")];
  propagate scrutineeType, scrutineeTrans, patternTrans;
}

inherited attribute scrutineeTypes::[Type];
synthesized attribute count::Integer;

inherited attribute scrutineesTrans::[core:Expr];

tracked nonterminal Patterns with pps, env, patternEnv, scrutineeTypes, count, patternDefs, errors, scrutineesTrans, patternTrans;
propagate env, patternEnv, patternDefs, errors, patternTrans on Patterns;

production consPattern
top::Patterns ::= h::Pattern t::Patterns
{
  top.pps = h.pp :: t.pps;
  top.count = t.count + 1;
  h.scrutineeType = 
    case top.scrutineeTypes of
    | ht :: _ -> ht
    | [] -> errorType()
    end;
  t.scrutineeTypes = 
    case top.scrutineeTypes of
    | _ :: tt -> tt
    | [] -> []
    end;

  h.scrutineeTrans = head(top.scrutineesTrans);
  t.scrutineesTrans = tail(top.scrutineesTrans);
}
production nilPattern
top::Patterns ::= 
{
  top.pps = [];
  top.count = 0;
}

tracked nonterminal FieldPatterns with pps, env, patternEnv, scrutineeType, patternDefs, errors, scrutineeTrans, patternTrans;
propagate env, patternEnv, scrutineeType, patternDefs, errors, scrutineeTrans, patternTrans on FieldPatterns;

production consFieldPattern
top::FieldPatterns ::= h::FieldPattern t::FieldPatterns
{
  top.pps = h.pp :: t.pps;
}
production nilFieldPattern
top::FieldPatterns ::= 
{
  top.pps = [];
}

tracked nonterminal FieldPattern with pp, env, patternEnv, scrutineeType, patternDefs, errors, scrutineeTrans, patternTrans;
propagate env, patternEnv, patternDefs, errors, patternTrans on FieldPattern;

production fieldPattern
top::FieldPattern ::= n::Name p::Pattern
{
  top.pp = pp"${n.name} = ${p.pp}";

  local lookupFieldType::Maybe<Type> =
    lookup(n.name, fromMaybe([], top.scrutineeType.structFields));
  top.errors <-
    if lookupFieldType.isJust then []
    else [errFromOrigin(n, s"No field named ${n.name} in ${show(80, top.scrutineeType)}")];
  p.scrutineeType = fromMaybe(errorType(), lookupFieldType);
  p.scrutineeTrans = core:fieldAccess(top.scrutineeTrans, ^n);
}

dispatch PatternTrans = core:Stmt ::= k::core:Stmt;

production successPatternTrans implements PatternTrans
top::core:Stmt ::= k::core:Stmt
{
  forwards to @k;
}
production composePatternTrans implements PatternTrans
top::core:Stmt ::= k::core:Stmt pt1::PatternTrans pt2::PatternTrans
{
  forwards to pt1(pt2(@k));
}
production letPatternTrans implements PatternTrans
top::core:Stmt ::= k::core:Stmt n::Name e::core:Expr
{
  forwards to core:seq(core:decl(core:autoVarDecl(@n, @e)), @k);
}
production condPatternTrans implements PatternTrans
top::core:Stmt ::= k::core:Stmt c::core:Expr
{
  forwards to core:if_(@c, @k, core:emptyStmt());
}

instance Semigroup PatternTrans {
  append = composePatternTrans;
}
instance Monoid PatternTrans {
  mempty = successPatternTrans;
}
