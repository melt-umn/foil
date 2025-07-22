# Foil
A simple language for exploration of language extensions in the translation pass style.

## Design
The design of Foil is in many ways a simplified version of C, without some of the rough edges
and annoying complications that are not important for proving out ideas related to language extension development.
Some of the most significant differences include:
* Simplified, easy-to-parse syntax
* Pointers and arrays are automatically garbage collected
* Array and strings sizes are dynamically tracked and checked
* Top level declarations are mutually recursive, no prototype/forward declarations


## Extension ideas
* For loop
* Algebraic data types / pattern matching
* Closures
* String builder
* Complex numbers
* Nullable pointers
