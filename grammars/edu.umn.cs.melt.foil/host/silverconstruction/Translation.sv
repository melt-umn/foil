grammar edu:umn:cs:melt:foil:host:silverconstruction;

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
