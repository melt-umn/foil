grammar edu:umn:cs:melt:foil:host:langs:l1;

imports silver:langutil;
imports silver:langutil:pp;

imports edu:umn:cs:melt:foil:host:common;

include edu:umn:cs:melt:foil:host:langs:core {
  -- Records are lifted and replaced by global structs
  exclude productions recordLit, recordTypeExpr, recordType;

  -- Construction utilities are excluded
  exclude productions appendExprs, appendParams;
}

synthesized attribute nestLevel::Integer occurs on Type, StructDecl, UnionDecl;

aspect nestLevel on Type of
| structType(t) -> t.nestLevel
| unionType(t) -> t.nestLevel
| _ -> 0
end;

aspect nestLevel on StructDecl of
| structDecl(n, fs) -> 1 + foldr(max, 0, map((.nestLevel), map(snd, fs.fields)))
end;

aspect nestLevel on UnionDecl of
| unionDecl(n, fs) -> 1 + foldr(max, 0, map((.nestLevel), map(snd, fs.fields)))
end;
