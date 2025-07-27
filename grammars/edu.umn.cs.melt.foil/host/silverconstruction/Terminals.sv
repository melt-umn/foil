grammar edu:umn:cs:melt:foil:host:silverconstruction;

-- Terminal definitions for quote productions
marking terminal FoilGlobalDecl_t 'Foil_GlobalDecl'  lexer classes {silver:KEYWORD, silver:RESERVED};
marking terminal FoilTypeExpr_t 'Foil_TypeExpr'  lexer classes {silver:KEYWORD, silver:RESERVED};
marking terminal FoilStmt_t 'Foil_Stmt'  lexer classes {silver:KEYWORD, silver:RESERVED};
marking terminal FoilExpr_t 'Foil_Expr'  lexer classes {silver:KEYWORD, silver:RESERVED};

-- Terminal definitions for antiquote productions
terminal EscapeTypeExpr_t '$TypeExpr'  lexer classes {foil:Keyword};
terminal EscapeStmt_t '$Stmt'  lexer classes {foil:Keyword};
terminal EscapeExpr_t '$Expr'  lexer classes {foil:Keyword};
terminal EscapeName_t '$Name'  lexer classes {foil:Keyword};

terminal LBracket_t '{';
terminal RBracket_t '}';
