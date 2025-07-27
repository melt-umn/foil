grammar edu:umn:cs:melt:foil:host:common;

synthesized attribute name::String;

tracked nonterminal Name with pp, name;
flowtype Name = decorate {}, forward {}, pp {}, name {};

derive Eq on Name;

production name
top::Name ::= id::String
{
  top.pp = text(id);
  top.name = id;
}

fun freshName Name ::= = name("_a" ++ toString(genInt()));
