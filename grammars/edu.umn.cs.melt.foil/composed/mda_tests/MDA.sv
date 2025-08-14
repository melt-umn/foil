grammar edu:umn:cs:melt:foil:composed:mda_tests;

imports edu:umn:cs:melt:foil:host:concretesyntax as cnc;

parser withHost :: cnc:Root {
  edu:umn:cs:melt:foil:host;
}

{- TODO: Fails due to infix +i, need to refactor the grammar
copper_mda testComplex(withHost) {
  edu:umn:cs:melt:foil:extensions:complex;
}
-}

copper_mda testClosure(withHost) {
  edu:umn:cs:melt:foil:extensions:closure;
}

copper_mda testDatatype(withHost) {
  edu:umn:cs:melt:foil:extensions:datatype;
}

copper_mda testIntConst(withHost) {
  edu:umn:cs:melt:foil:extensions:intconst;
}
