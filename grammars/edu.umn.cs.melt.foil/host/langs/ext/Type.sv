grammar edu:umn:cs:melt:foil:host:langs:ext;

synthesized attribute toCoreType :: core:Type occurs on Type;

aspect toCoreType on Type of
| intType() -> core:intType()
| floatType() -> core:floatType()
| boolType() -> core:boolType()
| stringType() -> core:stringType()
| unitType() -> core:unitType()
| objType(fs) -> core:objType(map(\ f::(String, Type) -> (f.1, f.2.toCoreType), fs))
| fnType(args, ret) -> core:fnType(map((.toCoreType), args), ret.toCoreType)
| errorType() -> core:errorType()
end;
