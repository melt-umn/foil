grammar edu:umn:cs:melt:foil:host:passes:ctrans;

attribute translation occurs on Stmt;
aspect translation on Stmt of
| emptyStmt() -> pp""
| seq(s1, s2) -> pp"${s1.translation}${line()}${s2.translation}"
| block(s) -> braces(groupnestlines(2, s.translation))
| decl(d) -> d.translation
| expr(e) -> pp"${e.translation};"
| assign(lhs, rhs) -> pp"${lhs.translation} =${groupnest(2, cat(line(), rhs.translation))};"
| if_(c, t, e) ->
  group(pp"if (${c.translation}) {${nestlines(2, t.translation)}}${if e.isEmpty then pp"" else pp" else {${nestlines(2, e.translation)}}"}")
| while(c, b) ->
  group(pp"while (${c.translation}) {${nestlines(2, b.translation)}}")
| return_(e) -> pp"return ${e.translation};"
end;
