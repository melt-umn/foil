grammar edu:umn:cs:melt:foil:host:silverconstruction;

-- Silver-to-Foil bridge productions
concrete productions top::silver:Expr
| 'Foil_GlobalDecl' '{' cst::foil:GlobalDecls '}'
  layout {edu:umn:cs:melt:foil:host:concretesyntax:Whitespace_t}
  { forwards to quoteGlobalDecl(cst.ast); }
| 'Foil_TypeExpr' '{' cst::foil:TypeExpr '}'
  layout {edu:umn:cs:melt:foil:host:concretesyntax:Whitespace_t}
  { forwards to quoteTypeExpr(cst.ast); }
| 'Foil_Stmt' '{' cst::foil:StmtList '}'
  layout {edu:umn:cs:melt:foil:host:concretesyntax:Whitespace_t}
  { forwards to quoteStmt(cst.ast); }
| 'Foil_Expr' '{' cst::foil:Expr '}'
  layout {edu:umn:cs:melt:foil:host:concretesyntax:Whitespace_t}
  { forwards to quoteExpr(cst.ast); }

-- Foil-to-Silver bridge productions
concrete productions top::foil:GlobalDecl
| '$GlobalDecl' '{' e::silver:Expr '}'
  layout {silver:WhiteSpace}
  { top.ast = antiquoteExtGlobalDecl(^e); }

concrete productions top::foil:TypeExpr
| '$TypeExpr' '{' e::silver:Expr '}'
  layout {silver:WhiteSpace}
  { top.ast = antiquoteExtTypeExpr(^e); }

concrete productions top::foil:Param
| '$Params' '{' e::silver:Expr '}'
  layout {silver:WhiteSpace}
  { top.ast = antiquoteExtParams(^e); }

concrete productions top::foil:Stmt
| '$Stmt' '{' e::silver:Expr '}'
  layout {silver:WhiteSpace}
  { top.ast = antiquoteExtStmt(^e); }

concrete productions top::foil:Expr
| '$Expr' '{' e::silver:Expr '}'
  layout {silver:WhiteSpace}
  { top.ast = antiquoteExtExpr(^e); }
| '$Exprs' '{' e::silver:Expr '}'
  layout {silver:WhiteSpace}
  { top.ast = antiquoteExtExprs(^e); }

concrete productions top::foil:Name
| '$Name' '{' e::silver:Expr '}'
  layout {silver:WhiteSpace}
  { top.ast = antiquoteName(^e); }
