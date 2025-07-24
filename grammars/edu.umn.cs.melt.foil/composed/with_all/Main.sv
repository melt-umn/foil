grammar edu:umn:cs:melt:foil:composed:with_all;

imports edu:umn:cs:melt:foil:host:concretesyntax as cnc;
imports edu:umn:cs:melt:foil:host:langs:ext as ext;
imports edu:umn:cs:melt:foil:host:driver;

parser foilParser :: cnc:Root {
  edu:umn:cs:melt:foil:host;
  edu:umn:cs:melt:foil:extensions:complex;
}

fun main IO<Integer> ::= args::[String] = driver(args, foilParser);
fun codeProberParse IO<Decorated ext:Root> ::= args::[String] = parseDriver(args, foilParser);
