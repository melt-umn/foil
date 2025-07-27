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
static inline struct _string _concat_string(struct _string s1, struct _string s2) {
  if (s1.length == 0) return s2;
  if (s2.length == 0) return s1;
  struct _string result;
  result.length = s1.length + s2.length;
  result.data = (char*)GC_MALLOC(result.length + 1);
  memcpy(result.data, s1.data, s1.length);
  memcpy(result.data + s1.length, s2.data, s2.length);
  result.data[result.length] = '\0';
  return result;
}
static inline struct _string _str_int(int i) {
  struct _string result;
  result.data = GC_malloc(snprintf(NULL, 0, "%d", i) + 1);
  result.length = sprintf(result.data, "%d", i);
  return result;
}
static inline struct _string _str_float(float f) {
  struct _string result;
  result.data = GC_malloc(snprintf(NULL, 0, "%g", f) + 1);
  result.length = sprintf(result.data, "%g", f);
  return result;
}
static inline struct _string _str_bool(_Bool b) {
  if (b) {
    return (struct _string){5, "true"};
  } else {
    return (struct _string){6, "false"};
  }
}
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
