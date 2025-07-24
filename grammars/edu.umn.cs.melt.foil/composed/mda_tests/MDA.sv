grammar edu:umn:cs:melt:foil:composed:mda_tests;

imports edu:umn:cs:melt:foil:host:concretesyntax as cnc;

parser withHost :: cnc:Root {
  edu:umn:cs:melt:foil:host;
}

copper_mda testComplex(withHost) {
  edu:umn:cs:melt:foil:extensions:complex;
}
