grammar edu:umn:cs:melt:foil:host:driver;

imports edu:umn:cs:melt:foil:host:concretesyntax as cnc;
imports edu:umn:cs:melt:foil:host:langs:ext as ext;
imports edu:umn:cs:melt:foil:host:langs:core as core;

imports silver:langutil;
imports silver:langutil:pp;

fun driver IO<Integer> ::= args::[String] parse::(ParseResult<cnc:Root> ::= String String) = do {
  extAst :: Decorated ext:Root <- parseDriver(args, parse);
  when_(!null(extAst.errors), do {
    print(messagesToString(extAst.errors) ++ "\n");
    exit(3);
  });
  return 0;
};

fun parseDriver IO<Decorated ext:Root> ::= args::[String] parse::(ParseResult<cnc:Root> ::= String String) = do {
  when_(length(args) < 1, fail("Usage: foil.jar <file>.foil"));
  let fileName = head(args);
  when_(!endsWith(fileName, ".foil"), fail("File must have .foil extension"));
  text <- readFile(fileName);
  let parseResult = parse(text, fileName);
  when_(!parseResult.parseSuccess, do {
    print(parseResult.parseErrors ++ "\n");
    exit(2);
  });
  let cst = decorate parseResult.parseTree with {};
  return decorate cst.ast with {};
};
