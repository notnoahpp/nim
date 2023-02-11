## yolo wurl: basic nim syntax
## ===========================
## :Authors:
##  noah for @nirvai
## :Org:
##  nirvai
##
## - only uses the implicitly imported system, threads and channel built_int module (and their imports)
## - dont import any of them directly, theres some compiler magic to makem work
##

#[
  @see
    - https://nim-lang.org/docs/system.html
    - ../deepdives dir to dive deep
    - ../nimscript for nim scripting
    - ../backends for compilation (todo currently its in compiler_blah_blah too)

  review:
    go through modules @see links and ensure you have captured relevant info in each file
      - likely need to do a bunchy of recategorization
      - focus on os related stuff first so we can get back to nirv
      - open the source code https://github.com/nim-lang/Nim/blob/version-1-6/lib/system.nim and ctrl-f keywords
    ensure deepdives dir does not contain any system/basic info, and truly dives deep
      - like need to do a bunch of recategorization
      - focus on os related stuff so we can get back to nirv
    somehow we've skipped a bunch of stuff (maybe there in deepdives as links?)
      - effect tracking system
      - testing
      - tasks
      - didnt appreciate the semicolons usefulness in grouping statements, search the docs
      - cant get too far in nim without readin through the nimble github readme
      - rework all of these weird comments to use docgen
    finally 3: https://nim-lang.org/docs/backends.html
      - you need to have some code ready so your not just copypasting documentation
    nim package directory: get familiar with what exists https://nimble.directory/
    nim in action
      - reading: finished this like a year ago, it was super old then away
      - copying pg40 custom array ranges
      - have to finish copying this book as it provides real world examples and guidance

  eventually: rather start coding and swing back to these later
    then here: https://nim-lang.org/docs/manual_experimental.html
    then here: https://nim-lang.org/docs/mm.html
    then here: https://nim-lang.org/blog/2017/10/02/documenting-profiling-and-debugging-nim-code.html
    and finally: https://nim-lang.org/docs/manual.html
    https://nim-lang.org/docs/tut3.html
    https://nim-lang.org/docs/destructors.html

  other stuff
    https://peterme.net/asynchronous-programming-in-nim.html
    https://peterme.net/handling-files-in-nim.html
    https://peterme.net/multitasking-in-nim.html
    https://peterme.net/optional-value-handling-in-nim.html
    https://peterme.net/tips-and-tricks-with-implicit-return-in-nim.html
    https://peterme.net/using-nimscript-as-a-configuration-language-embedding-nimscript-pt-1.html
    https://peterme.net/how-to-embed-nimscript-into-a-nim-program-embedding-nimscript-pt-2.html
    https://peterme.net/creating-condensed-shared-libraries-embedding-nimscript-pt-3.html

]#

#[
  # std library

  - pure libraries: do not depend on external *.dll/lib*.so binary
  - impure libraries: !pure libraries
  - wrapper libraries: impure low level interfaces to a C library
]#

#[
  # style guide & best practices

  idiomatic nim (from docs/styleguide),
    - keep lines <= 80  with 2 spaces for indentation (styleguide)
    - dont align the = across subsequent lines like you see java apps
    - cast > type conversion to force the compiler to reinterpret the bit pattern (docs)
    - composition > inheritance is often the better design (docs)
    - declare as var > proc var params when modifying global vars (docs)
    - module names are generally long to be descriptive (docs)
    - MyCustomError should follow the hierarchy defiend in system.Exception (docs)
    - never raise an exception without a msg, and never for control flow (docs maybe?)
    - object variants > inheritance for simple types; no type conversion required (docs)
    - run initialization logic as toplevel module statements, e.g. init data (docs)
    - shadowing proc params > declaring them as var enables the most efficient parameter passing (docs)
    - use a..b unless a .. ^b has an operator (docs, styleguide)
    - type > cast operator cuz type preserves the bit pattern (docs)
    - use include to split large modules into distinct files (docs)
    - use Natural range to guard against negative numbers (e.g. in loops) (docs)
    - use result(its optimized) > return (for control flow) > last statement expression (stylguide) (status prefers last statement)
    - use sets (e.g. as flags) > integers that have to be or'ed (docs)
    - use status push > raises convention to help track unfound errs (docs + status)
    - X.y > x[].y for accessing ref/ptr objects (docs: x[].y highly discouraged)
    - type identifiers/consts/pure enums use PascalCase, all other (including pure enums) use camelCase
    - the main type idenfier shouldn not have a Obj|Ref|Ptr suffix (styleguide)
    - secondary flavors of type identifiers should have suffix Obj|Ref|Ptr (styleguide)
    - exceptions/defects types should always have an Error|Defect suffix (styleguide)
    - impure enum members should always have a prefix (e.g. abbr of the enum name) (styleguide)
    - in general stay away from MACRO_CASE naming conventions, no matter what it is (styleguide)
    - procs that mutate data should be prefixed with 'm' (styleguide)
    - procs that return a transformed copy of soemthing should be in past particle (e.g. pooped) (styleguide)
    - identifiers should use subjectVerb not verbSubject (lol this ones gonna hurt) (styleguide)
    - check the styleguide for naming conventions (theres bunches), the idea is to make it easy to `guess the procedure`
    - use procs > (macros/templates/iterators/convertors) unless necessary (styleguide)
    - prefer let > var for runtime vars that dont change
    - any tuple/proc/type signature longer than 1 line should have their parameters aligned with the one above it
    - multi-line invocations should continue on the same column as the open paranthesis
    - always qualify the imports from std, e.g. std/os and std/[os, posix]
    - prefer """string literals""" that start with new line, i.e. the """ first should be on its own line
    - dont prefix getters/setters with `get/setBlah` unless the it has side effects, or the cost is not O(1)

  borrowed from somewhere else (e.g. status auditor docs)
    - MACRO_CASE for external constants (status) (permitted in styleguide but not preferred)

  my preferences thus far
    - strive for parantheseless code, probly a dumb idea, i'm fumbling everywhere to achieve this
    - keep it as sugary as possible
    - prefer fn x,y over x.fn y over fn(x, y) unless it conflicts with the context
      - e.g. pref x.fn y,z when working with objects
      - e.g. pref fn x,y when working with procs
      - e.g. pref fn(x, ...) when chaining/closures (calling syntax impacts type compatibility (docs))
    - -- > - cmd line switches so you can sort nim compiler options
    - object vs tuple
      - tuple: inheritance / private fields / reference equality arent required
      - object: inheritance / private fields / reference equality are required
    - refrain from using blah% operators they tend to be legacy, see https://github.com/nirv-ai/docs/issues/50
]#

#[
  # modules
    - generally 1 file == 1 module
    - include can split 1 module == 1..X files
    - top level statements are exected at start of program
    - isMainModule: returns true if current module compiled as the main file (see testing.nim)

  ambiguity
    - when module A imports symbol B that exists in C and D
    - procs/iterators are overloaded, so no ambiguity
    - everything else must be qualified (c.b | d.b) if signatures are ambiguous

  import: top-level symbols marked * from another module
  looks in the current dir relative to the imported file and uses the first match
  else traverses up the nim PATH for the first match
  @see https://nim-lang.org/docs/nimc.html#compiler-usage-search-path-handling
    import math # imports everything
    import std/math # qualified import everything
    import mySubdir/thirdFile
    import myOtherSubdir / [fourthFile, fifthFile]
    import thisTHing except thiz,thaz,thoz
    from thisThing import this, thaz, thoz # can invoke this,that,thot without qualifying
    from thisThing import nil # must qualify symbols to invoke, e.g. thisThing.blah()
    from thisThing as tt import nil # define an alias

  include: a file as part of this module
  becareful with too many includes, its difficult to debug
  line numbers dont point to specific included files, but to the composite file
    include xA,xB,xC

  # exporting
    export something
]#

#[
  # operators
    - precedence determined by its first character
    - are just overloaded procs, e.g. proc `+`(....) and can be invoked just like procs
    - infix: a + b must receive 2 args
    - prefix: + a must receive 1 arg
    - postfix: dont exist in nim

  + - * \ / < > @ $ ~ & % ! ? ^ . |

  in place mutations
    add (appends y to x for any seq like container)
    blah= (generally left operand mutated in place)

  bool
    not, and, or, xor, <, <=, >, >=, !=, ==

  short circuit
    and or

  char
    ==, <, <=, >, >=

  integer bitwise
    and or xor not shl shr

  integer division
    div

  modulo
    mod

  assignment
    =
      - value semantics: copied on assignment, all types have value semantics
      - ref semantics: referenced on assignment, anything with ref keyword

]#

#[
    return
      - without an expression is shorthand for return result
    result
      - implicit return variable
      - initialized with procs default value, for ref types it will be nil (may require manual init)
      - its idiomatic nim to mutate it
    discard
      - use a proc for its side effects but ignore its return value

]#

#[
  # statements

  simple statements
    - cant contain other statements
    - e.g. assignment, invocations, and using return
  complex statements
    - can contain other statements
    - must always be indented except for single complex statements
    - e.g. if, when, for, while
]#

#[
  # expressions
    - result in a value
    - indentation can occur after operators, open parantheiss and commas
    - paranthesis and semicolins allow you to embed statements where expressions are expected

]#

#[
  # visibility

  var: local or global var
  *: this thing is visible outside the module
  scopes: all blocks (ifs, loops, procs, etc) introduce a closure EXCEPT when statements
]#


include modules/[
  variableGlobals,
  typeSimple,
  ifWhenCase,
  exceptionHandlingTestingDocs,
  loops,
  blockDo,
  arraySequenceOrdinalRange,
  sets,
  procedures,
  typeComplex,
  tuples,
  osIoFiles,
  pragmas
]
