grammar edu:umn:cs:melt:foil:composed:host;

imports edu:umn:cs:melt:foil:host:concretesyntax as cnc;
imports edu:umn:cs:melt:foil:host:langs:ext as ext;
imports edu:umn:cs:melt:foil:host:driver;

parser foilParser :: cnc:Root {
  edu:umn:cs:melt:foil:host;
}

fun main IO<Integer> ::= args::[String] = driver(args, foilParser);
fun codeProberParse IO<Decorated ext:Root> ::= args::[String] = parseDriver(args, foilParser);
