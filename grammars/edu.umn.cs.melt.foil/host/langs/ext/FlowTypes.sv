grammar edu:umn:cs:melt:foil:host:langs:ext;

flowtype decorate {} on Root;
flowtype decorate {env, declaredEnv} on GlobalDecl;
flowtype decorate {env} on 
  VarDecl, FnDecl, Params, Param,
  StructDecl, UnionDecl, Fields, Field,
  TypeExpr, TypeExprs,
  Expr, Exprs, FieldExprs, FieldExpr;
flowtype decorate {env, returnType} on Stmt;

flowtype forward {decorate} on 
  GlobalDecl, Stmt, Expr, TypeExpr;
flowtype forward {} on 
  Root, VarDecl, FnDecl, Params, Param,
  StructDecl, UnionDecl, Fields, Field, TypeExprs,
  Exprs, FieldExprs, FieldExpr;

flowtype pp {} on 
  Root, GlobalDecl, VarDecl, FnDecl, Param,
  StructDecl, UnionDecl, Field, TypeExpr,
  Stmt, Expr, FieldExpr;
flowtype pps {} on 
  Params, Fields, TypeExprs, Exprs, FieldExprs;
flowtype errors {decorate} on 
  Root, GlobalDecl, VarDecl, FnDecl, Params, Param,
  StructDecl, UnionDecl, Fields, Field, TypeExpr, TypeExprs,
  Stmt, Expr, Exprs, FieldExprs, FieldExpr;
flowtype type {decorate} on Expr, TypeExpr;

flowtype toCore {decorate} on
  Root, GlobalDecl, VarDecl, FnDecl, Params, Param,
  StructDecl, UnionDecl, Fields, Field, TypeExpr, TypeExprs,
  Stmt, Expr, Exprs, FieldExprs, FieldExpr;
flowtype liftedDecls {decorate} on
  VarDecl, FnDecl, Params, Param,
  StructDecl, UnionDecl, Fields, Field, TypeExpr, TypeExprs,
  Stmt, Expr, Exprs, FieldExprs, FieldExpr;
