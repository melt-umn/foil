grammar edu:umn:cs:melt:foil:extensions:datatype;

marking terminal Data_t  'data'  lexer classes cnc:Keyword;
marking terminal Match_t 'match' lexer classes cnc:Keyword;

disambiguate Match_t, cnc:Identifier_t { pluck Match_t; }

terminal Wild_t  '_';
disambiguate Wild_t, cnc:Identifier_t { pluck Wild_t; }

terminal AtSign_t    '@' precedence=10, association=left, lexer classes cnc:Operator;
terminal Ampersand_t '&' precedence=20,                   lexer classes cnc:Operator;

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

concrete productions top::cnc:Stmt
| 'match' '(' s::cnc:Expr ')' '{' cs::MatchCases_c '}'
  { abstract matchStmt; }

tracked nonterminal MatchCases_c with ast<MatchCases>;
concrete productions top::MatchCases_c
| c::MatchCase_c cs::MatchCases_c
  { abstract consMatchCase; }
| 
  { abstract nilMatchCase; }

tracked nonterminal MatchCase_c with ast<MatchCase>;
concrete productions top::MatchCase_c
| p::Pattern_c '->' '{' s::cnc:Stmt '}'
  { abstract matchCase; }

tracked nonterminal Pattern_c with ast<Pattern>;
concrete productions top::Pattern_c
| '_' 
  { abstract wildPattern; }
| id::cnc:Identifier_t
  { top.ast = varPattern(name(id.lexeme)); }
| p1::Pattern_c '@' p2::Pattern_c
  { abstract bothPattern; }
| '&' p::Pattern_c
  { abstract pointerPattern; }
| n::cnc:Name '(' ps::Patterns_c ')'
  { abstract constructorPattern; }
| '{' fs::FieldPatterns_c '}'
  { abstract structPattern; }
| '(' p::Pattern_c ')'
  { top.ast = p.ast; }

tracked nonterminal Patterns_c with ast<Patterns>;
concrete productions top::Patterns_c
| p::Pattern_c ',' ps::Patterns_c
  { abstract consPattern; }
| p::Pattern_c
  { top.ast = consPattern(p.ast, nilPattern()); }
| 
  { abstract nilPattern; }

tracked nonterminal FieldPatterns_c with ast<FieldPatterns>;
concrete productions top::FieldPatterns_c
| f::FieldPattern_c ',' fs::FieldPatterns_c
  { abstract consFieldPattern; }
| f::FieldPattern_c
  { top.ast = consFieldPattern(f.ast, nilFieldPattern()); }
| 
  { abstract nilFieldPattern; }

tracked nonterminal FieldPattern_c with ast<FieldPattern>;
concrete productions top::FieldPattern_c
| n::cnc:Name '=' p::Pattern_c
  { abstract fieldPattern; }
