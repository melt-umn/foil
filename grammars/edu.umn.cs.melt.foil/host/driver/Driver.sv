grammar edu:umn:cs:melt:foil:host:driver;

imports edu:umn:cs:melt:foil:host:concretesyntax as cnc;
imports edu:umn:cs:melt:foil:host:langs:ext as ext;
imports edu:umn:cs:melt:foil:host:langs:core as core;
imports edu:umn:cs:melt:foil:host:langs:l1 as l1;
imports edu:umn:cs:melt:foil:host:langs:l2 as l2;
imports edu:umn:cs:melt:foil:host:passes:toL1;
imports edu:umn:cs:melt:foil:host:passes:toL2;
imports edu:umn:cs:melt:foil:host:passes:ctrans;

imports silver:langutil;
imports silver:langutil:pp;

fun driver IO<Integer> ::= args::[String] parse::(ParseResult<cnc:Root> ::= String String) = do {
  let fileName = head(args);
  extAst :: Decorated ext:Root <- parseDriver(args, parse);
  when_(!null(extAst.errors), do {
    println(messagesToString(extAst.errors));
    exit(3);
  });
  let coreAst :: Decorated core:Root = extAst.ext:toCore;
  when_(!null(coreAst.errors), do {
    println("Errors in core AST!");
    println(messagesToString(coreAst.errors));
    exit(4);
  });
  let l1Ast :: Decorated l1:Root = coreAst.toL1;
  when_(!null(l1Ast.errors), do {
    println("Errors in L1 AST!");
    println(messagesToString(l1Ast.errors));
    exit(5);
  });
  let l2Ast :: Decorated l2:Root = l1Ast.toL2;
  when_(!null(l2Ast.errors), do {
    println("Errors in L2 AST!");
    println(messagesToString(l2Ast.errors));
    exit(6);
  });
  let ctrans :: String = show(80, l2Ast.translation);
  let outFileName = substitute(".foil", ".c", fileName);
  writeFile(outFileName, ctrans);
  return 0;
};

fun parseDriver IO<Decorated ext:Root> ::= args::[String] parse::(ParseResult<cnc:Root> ::= String String) = do {
  when_(length(args) < 1, fail("Usage: composed_<name>.jar <file>.foil"));
  let fileName = head(args);
  when_(!endsWith(".foil", fileName), fail("File must have .foil extension"));
  text <- readFile(fileName);
  let parseResult = parse(text, fileName);
  when_(!parseResult.parseSuccess, do {
    println(parseResult.parseErrors);
    exit(2);
  });
  let cst = decorate parseResult.parseTree with {};
  return decorate cst.ast with {};
};
