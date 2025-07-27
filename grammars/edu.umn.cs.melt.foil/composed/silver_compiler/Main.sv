grammar edu:umn:cs:melt:foil:composed:silver_compiler;

imports silver:compiler:host;

parser svParse::File {
  silver:compiler:host;
  
  edu:umn:cs:melt:foil:host:silverconstruction;
  edu:umn:cs:melt:foil:host:concretesyntax;
}

fun main IO<Integer> ::= args::[String] = cmdLineRun(args, svParse);
