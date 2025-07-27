grammar edu:umn:cs:melt:foil:host:silverconstruction;

-- toCore resolves overloading (which requires type checking),
-- however we don't have a complete tree, and just want the equivalent core syntax:
translation pass directToCore
  from edu:umn:cs:melt:foil:host:langs:ext
    to edu:umn:cs:melt:foil:host:langs:core;

aspect directToCore on ext:GlobalDecl of
| _ -> error("Unexpected extension construct in core syntax literal")
end;
aspect directToCore on ext:TypeExpr of
| _ -> error("Unexpected extension construct in core syntax literal")
end;
aspect directToCore on ext:Stmt of
| _ -> error("Unexpected extension construct in core syntax literal")
end;
aspect directToCore on ext:Expr of
| _ -> error("Unexpected extension construct in core syntax literal")
end;

aspect production nonterminalAST
top::AST ::= prodName::String children::ASTs annotations::NamedASTs
{
  -- Here we simply list the names of the antiquote productions that we have introduced,
  -- to be treated specially in the object-language to meta-langauge translation code.
  directAntiquoteProductions <- [
    "edu:umn:cs:melt:foil:host:silverconstruction:antiquoteTypeExpr",
    "edu:umn:cs:melt:foil:host:silverconstruction:antiquoteStmt",
    "edu:umn:cs:melt:foil:host:silverconstruction:antiquoteExpr",
    "edu:umn:cs:melt:foil:host:silverconstruction:antiquoteName"
  ];
}
