grammar edu:umn:cs:melt:foil:host:env;

imports silver:util:treemap as tm;

-- TODO: Maybe these utilities belong in silver:langutil:env or something like that?

type Scopes<a> = [tm:Map<String a>];
type Contribs<a> = [(String, a)];

{-- Create an empty scope -}
fun emptyScope Scopes<a> ::= = [tm:empty()];
{-- Adds contributions to the innermost scope -}
fun addScope Scopes<a> ::= d::Contribs<a>  s::Scopes<a> = tm:add(d, head(s)) :: tail(s);
{-- Create a new innermost scope -}
fun openScope Scopes<a> ::= s::Scopes<a> = tm:empty() :: s;
{-- Looks up an identifier in the closest scope that has a match -}
fun lookupScope [a] ::= n::String  s::Scopes<a> =
  case dropWhile(null, map(tm:lookup(n, _), s)) of
  | h :: _ -> h
  | [] -> []
  end;
{-- Looks up an identifier in the innermost scope -}
fun lookupInLocalScope [a] ::= n::String  s::Scopes<a> = tm:lookup(n, head(s));
