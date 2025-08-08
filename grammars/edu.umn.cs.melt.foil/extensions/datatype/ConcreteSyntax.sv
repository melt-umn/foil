grammar edu:umn:cs:melt:foil:extensions:datatype;

marking terminal Data_t 'data' lexer classes cnc:Keyword;

concrete productions top::cnc:GlobalDecl
| 'data' n::cnc:Name '{' cs::Constructors_c '}'
  { top.ast = dataGlobalDecl(dataDecl(n.ast, cs.ast)); }

tracked nonterminal Constructors_c with ast<Constructors>;
concrete productions top::Constructors_c
| c::Constructor_c cs::Constructors_c
  { abstract consConstructor; }
| 
  { abstract nilConstructor; }

tracked nonterminal Constructor_c with ast<Constructor>;
concrete productions top::Constructor_c
| n::cnc:Name '(' ps::cnc:Params ')' ';'
  { abstract constructor; }

