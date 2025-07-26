grammar edu:umn:cs:melt:foil:host:langs:l1;

imports silver:langutil;
imports silver:langutil:pp;

imports edu:umn:cs:melt:foil:host:common;

include edu:umn:cs:melt:foil:host:langs:core {
  -- Records are lifted and replaced by global structs
  exclude productions recordLit, recordTypeExpr, recordType;
}
