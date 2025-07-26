grammar edu:umn:cs:melt:foil:host:langs:l2;

flowtype decorate {} on 
  Root, GlobalDecl, VarDecl, FnDecl, Params, Param,
  StructDecl, UnionDecl, Fields, Field,
  TypeExpr, TypeExprs,
  Expr, Exprs, FieldExprs, FieldExpr;
flowtype decorate {returnType} on Stmt;
flowtype forward {} on 
  Root, VarDecl, FnDecl, Params, Param,
  StructDecl, UnionDecl, Fields, Field, TypeExprs,
  Exprs, FieldExprs, FieldExpr,
  GlobalDecl, Stmt, Expr, TypeExpr;

flowtype pp {} on
  Root, GlobalDecl, VarDecl, FnDecl, Param,
  StructDecl, UnionDecl, Field, TypeExpr,
  Stmt, Expr, FieldExpr;
flowtype pps {} on 
  Params, Fields, TypeExprs, Exprs, FieldExprs;
flowtype isEmptyGlobalDecl {} on GlobalDecl;
flowtype errors {decorate} on 
  Root, GlobalDecl, VarDecl, FnDecl, Params, Param,
  StructDecl, UnionDecl, Fields, Field, TypeExpr, TypeExprs,
  Stmt, Expr, Exprs, FieldExprs, FieldExpr;
