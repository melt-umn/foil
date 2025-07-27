grammar edu:umn:cs:melt:foil:host:passes:ctrans;

attribute translation occurs on Root, GlobalDecl;

aspect production root
top::Root ::= d::GlobalDecl
{
  production attribute preDecls::Document with cat;
  preDecls := pp"";

  top.translation = pp"${preDecls}\n${d.protoDecls}\n${d.translation}";

  preDecls <- pp"""
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <gc.h>

struct _string { size_t length; char* data; };
""";
}


aspect translation on GlobalDecl of
| appendGlobalDecl(d1, d2) -> cat(d1.translation, d2.translation)
| emptyGlobalDecl() -> pp""
| varGlobalDecl(d) -> pp""
| fnGlobalDecl(d) -> d.translation
| structGlobalDecl(d) -> d.translation
| unionGlobalDecl(d) -> d.translation
end;

monoid attribute protoDecls::Document occurs on GlobalDecl;
propagate protoDecls on GlobalDecl;
