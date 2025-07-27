grammar edu:umn:cs:melt:foil:host:passes:ctrans;

attribute translation occurs on Root, GlobalDecl;

aspect translation on Root of
| root(d) -> cat(d.protoDecls, d.translation)
end;

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
