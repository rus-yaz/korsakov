" quit when a syntax file was already loaded.
if exists("b:current_syntax")
  finish
endif

" We need nocompatible mode in order to continue lines with backslashes.
" Original setting will be restored.
let s:cpo_save = &cpo
set cpo&vim

if exists("korsakov_no_doctest_highlight")
  let korsakov_no_doctest_code_highlight = 1
endif

if exists("korsakov_highlight_all")
  if exists("korsakov_no_builtin_highlight")
    unlet korsakov_no_builtin_highlight
  endif
  if exists("korsakov_no_doctest_code_highlight")
    unlet korsakov_no_doctest_code_highlight
  endif
  if exists("korsakov_no_doctest_highlight")
    unlet korsakov_no_doctest_highlight
  endif
  if exists("korsakov_no_exception_highlight")
    unlet korsakov_no_exception_highlight
  endif
  if exists("korsakov_no_number_highlight")
    unlet korsakov_no_number_highlight
  endif
  let korsakov_space_error_highlight = 1
endif

" Keep Python keywords in alphabetical order inside groups for easy
" comparison with the table in the 'Python Language Reference'
" https://docs.korsakov.org/reference/lexical_analysis.html#keywords.
" Groups are in the order presented in NAMING CONVENTIONS in syntax.txt.
" Exceptions come last at the end of each group (class and def below).
"
" The list can be checked using:
"
" korsakov3 -c 'import keyword, pprint; pprint.pprint(keyword.kwlist + keyword.softkwlist, compact=True)'
"
syn keyword korsakovStatement	false ложь none нуль true истина
syn keyword korsakovStatement	break прервать continue продолжить
syn keyword korsakovStatement	return вернуть
syn keyword korsakovStatement	class класс function функция nextgroup=korsakovFunction skipwhite
syn keyword korsakovConditional	else иначе if если
syn keyword korsakovRepeat	for для while пока
syn keyword korsakovOperator	and и in в not не or или
syn keyword korsakovInclude	include включить

" Soft keywords
" These keywords do not mean anything unless used in the right context.
" See https://docs.korsakov.org/3/reference/lexical_analysis.html#soft-keywords
" for more on this.
syn match   korsakovConditional   "^\s*\zscase\%(\s\+.*:.*$\)\@="
syn match   korsakovConditional   "^\s*\zsmatch\%(\s\+.*:\s*\%(#.*\)\=$\)\@="

" Decorators
" A dot must be allowed because of @MyClass.myfunc decorators.
syn match   korsakovDecorator	"@" display contained
syn match   korsakovDecoratorName	"@\s*\h\%(\w\|\.\)*" display contains=korsakovDecorator

" Python 3.5 introduced the use of the same symbol for matrix multiplication:
" https://www.korsakov.org/dev/peps/pep-0465/.  We now have to exclude the
" symbol from highlighting when used in that context.
" Single line multiplication.
syn match   korsakovMatrixMultiply
      \ "\%(\w\|[])]\)\s*@"
      \ contains=ALLBUT,korsakovDecoratorName,korsakovDecorator,korsakovFunction,korsakovDoctestValue
      \ transparent
" Multiplication continued on the next line after backslash.
syn match   korsakovMatrixMultiply
      \ "[^\\]\\\s*\n\%(\s*\.\.\.\s\)\=\s\+@"
      \ contains=ALLBUT,korsakovDecoratorName,korsakovDecorator,korsakovFunction,korsakovDoctestValue
      \ transparent
" Multiplication in a parenthesized expression over multiple lines with @ at
" the start of each continued line; very similar to decorators and complex.
syn match   korsakovMatrixMultiply
      \ "^\s*\%(\%(>>>\|\.\.\.\)\s\+\)\=\zs\%(\h\|\%(\h\|[[(]\).\{-}\%(\w\|[])]\)\)\s*\n\%(\s*\.\.\.\s\)\=\s\+@\%(.\{-}\n\%(\s*\.\.\.\s\)\=\s\+@\)*"
      \ contains=ALLBUT,korsakovDecoratorName,korsakovDecorator,korsakovFunction,korsakovDoctestValue
      \ transparent

syn match   korsakovFunction	"\h\w*" display contained

syn match   korsakovComment	"!!.*$" contains=korsakovTodo,@Spell
syn keyword korsakovTodo		FIXME NOTE NOTES TODO XXX contained

" Triple-quoted strings can contain doctests.
syn region  korsakovString matchgroup=korsakovQuotes
      \ start=+[uU]\=\z("\)+ end="\z1" skip="\\\\\|\\\z1"
      \ contains=korsakovEscape,@Spell
syn region  korsakovString matchgroup=korsakovTripleQuotes
      \ start=+[uU]\=\z("""\)+ end="\z1" keepend
      \ contains=korsakovEscape,korsakovSpaceError,korsakovDoctest,@Spell
syn region  korsakovRawString matchgroup=korsakovQuotes
      \ start=+[uU]\=[rR]\z("\)+ end="\z1" skip="\\\\\|\\\z1"
      \ contains=@Spell
syn region  korsakovRawString matchgroup=korsakovTripleQuotes
      \ start=+[uU]\=[rR]\z("""\)+ end="\z1" keepend
      \ contains=korsakovSpaceError,korsakovDoctest,@Spell

syn match   korsakovEscape	+\\[abfnrtv"\\]+ contained
syn match   korsakovEscape	"\\\o\{1,3}" contained
syn match   korsakovEscape	"\\x\x\{2}" contained
syn match   korsakovEscape	"\%(\\u\x\{4}\|\\U\x\{8}\)" contained
" Python allows case-insensitive Unicode IDs: http://www.unicode.org/charts/
syn match   korsakovEscape	"\\N{\a\+\%(\s\a\+\)*}" contained
syn match   korsakovEscape	"\\$"

" It is very important to understand all details before changing the
" regular expressions below or their order.
" The word boundaries are *not* the floating-point number boundaries
" because of a possible leading or trailing decimal point.
" The expressions below ensure that all valid number literals are
" highlighted, and invalid number literals are not.  For example,
"
" - a decimal point in '4.' at the end of a line is highlighted,
" - a second dot in 1.0.0 is not highlighted,
" - 08 is not highlighted,
" - 08e0 or 08j are highlighted,
"
" and so on, as specified in the 'Python Language Reference'.
" https://docs.korsakov.org/reference/lexical_analysis.html#numeric-literals
if !exists("korsakov_no_number_highlight")
  " numbers (including complex)
  syn match   korsakovNumber	"\<0[oO]\%(_\=\o\)\+\>"
  syn match   korsakovNumber	"\<0[xX]\%(_\=\x\)\+\>"
  syn match   korsakovNumber	"\<0[bB]\%(_\=[01]\)\+\>"
  syn match   korsakovNumber	"\<\%([1-9]\%(_\=\d\)*\|0\+\%(_\=0\)*\)\>"
  syn match   korsakovNumber	"\<\d\%(_\=\d\)*[jJ]\>"
  syn match   korsakovNumber	"\<\d\%(_\=\d\)*[eE][+-]\=\d\%(_\=\d\)*[jJ]\=\>"
  syn match   korsakovNumber
        \ "\<\d\%(_\=\d\)*\.\%([eE][+-]\=\d\%(_\=\d\)*\)\=[jJ]\=\%(\W\|$\)\@="
  syn match   korsakovNumber
        \ "\%(^\|\W\)\zs\%(\d\%(_\=\d\)*\)\=\.\d\%(_\=\d\)*\%([eE][+-]\=\d\%(_\=\d\)*\)\=[jJ]\=\>"
endif

" Group the built-ins in the order in the 'Python Library Reference' for
" easier comparison.
" https://docs.korsakov.org/library/constants.html
" http://docs.korsakov.org/library/functions.html
" Python built-in functions are in alphabetical order.
"
" The list can be checked using:
"
" korsakov3 -c 'import builtins, pprint; pprint.pprint(dir(builtins), compact=True)'
"
" The constants added by the `site` module are not listed below because they
" should not be used in programs, only in interactive interpreter.
" Similarly for some other attributes and functions `__`-enclosed from the
" output of the above command.
"
if !exists("korsakov_no_builtin_highlight")
  " built-in constants
  " 'False', 'True', and 'None' are also reserved words in Python 3
  syn keyword korsakovBuiltin	False True None
  syn keyword korsakovBuiltin	NotImplemented Ellipsis __debug__
  " built-in functions
  syn keyword korsakovBuiltin	input ввести input_integer ввести_целоеis_string является_строкой
  syn keyword korsakovBuiltin	is_integer является_целым is_function является_функцией is_list является_списком
  syn keyword korsakovBuiltin	len длина map карта применить_ко_всем max максимальное наибольшее
  syn keyword korsakovBuiltin	min минимальное наименьшее
  syn keyword korsakovBuiltin	print показать range диапазон reverse развернуть
  syn keyword korsakovBuiltin	slice срез sort сортировать sum сумма 
  syn keyword korsakovBuiltin	type тип
  " avoid highlighting attributes as builtins
  syn match   korsakovAttribute	/\.\h\w*/hs=s+1
	\ contains=ALLBUT,korsakovBuiltin,korsakovFunction,korsakovAsync
	\ transparent
endif

" From the 'Python Library Reference' class hierarchy at the bottom.
" http://docs.korsakov.org/library/exceptions.html
if !exists("korsakov_no_exception_highlight")
  " builtin base exceptions (used mostly as base classes for other exceptions)
  syn keyword korsakovExceptions	BaseException Exception
  syn keyword korsakovExceptions	ArithmeticError BufferError LookupError
  " builtin exceptions (actually raised)
  syn keyword korsakovExceptions	AssertionError AttributeError EOFError
  syn keyword korsakovExceptions	FloatingPointError GeneratorExit ImportError
  syn keyword korsakovExceptions	IndentationError IndexError KeyError
  syn keyword korsakovExceptions	KeyboardInterrupt MemoryError
  syn keyword korsakovExceptions	ModuleNotFoundError NameError
  syn keyword korsakovExceptions	NotImplementedError OSError OverflowError
  syn keyword korsakovExceptions	RecursionError ReferenceError RuntimeError
  syn keyword korsakovExceptions	StopAsyncIteration StopIteration SyntaxError
  syn keyword korsakovExceptions	SystemError SystemExit TabError TypeError
  syn keyword korsakovExceptions	UnboundLocalError UnicodeDecodeError
  syn keyword korsakovExceptions	UnicodeEncodeError UnicodeError
  syn keyword korsakovExceptions	UnicodeTranslateError ValueError
  syn keyword korsakovExceptions	ZeroDivisionError
  " builtin exception aliases for OSError
  syn keyword korsakovExceptions	EnvironmentError IOError WindowsError
  " builtin OS exceptions in Python 3
  syn keyword korsakovExceptions	BlockingIOError BrokenPipeError
  syn keyword korsakovExceptions	ChildProcessError ConnectionAbortedError
  syn keyword korsakovExceptions	ConnectionError ConnectionRefusedError
  syn keyword korsakovExceptions	ConnectionResetError FileExistsError
  syn keyword korsakovExceptions	FileNotFoundError InterruptedError
  syn keyword korsakovExceptions	IsADirectoryError NotADirectoryError
  syn keyword korsakovExceptions	PermissionError ProcessLookupError TimeoutError
  " builtin warnings
  syn keyword korsakovExceptions	BytesWarning DeprecationWarning FutureWarning
  syn keyword korsakovExceptions	ImportWarning PendingDeprecationWarning
  syn keyword korsakovExceptions	ResourceWarning RuntimeWarning
  syn keyword korsakovExceptions	SyntaxWarning UnicodeWarning
  syn keyword korsakovExceptions	UserWarning Warning
endif

if exists("korsakov_space_error_highlight")
  " trailing whitespace
  syn match   korsakovSpaceError	display excludenl "\s\+$"
  " mixed tabs and spaces
  syn match   korsakovSpaceError	display " \+\t"
  syn match   korsakovSpaceError	display "\t\+ "
endif

" Do not spell doctests inside strings.
" Notice that the end of a string, either ''', or """, will end the contained
" doctest too.  Thus, we do *not* need to have it as an end pattern.
if !exists("korsakov_no_doctest_highlight")
  if !exists("korsakov_no_doctest_code_highlight")
    syn region korsakovDoctest
	  \ start="^\s*>>>\s" end="^\s*$"
	  \ contained contains=ALLBUT,korsakovDoctest,korsakovFunction,@Spell
    syn region korsakovDoctestValue
	  \ start=+^\s*\%(>>>\s\|\.\.\.\s\|"""\|'''\)\@!\S\++ end="$"
	  \ contained
  else
    syn region korsakovDoctest
	  \ start="^\s*>>>" end="^\s*$"
	  \ contained contains=@NoSpell
  endif
endif

" Sync at the beginning of class, function, or method definition.
syn sync match korsakovSync grouphere NONE "^\%(функция\|function\|класс\|class\)\s\+\h\w*\s*[(:]"

" The default highlight links.  Can be overridden later.
hi def link korsakovStatement		Statement
hi def link korsakovConditional		Conditional
hi def link korsakovRepeat		Repeat
hi def link korsakovOperator		Operator
hi def link korsakovException		Exception
hi def link korsakovInclude		Include
hi def link korsakovAsync			Statement
hi def link korsakovDecorator		Define
hi def link korsakovDecoratorName		Function
hi def link korsakovFunction		Function
hi def link korsakovComment		Comment
hi def link korsakovTodo			Todo
hi def link korsakovString		String
hi def link korsakovRawString		String
hi def link korsakovQuotes		String
hi def link korsakovTripleQuotes		korsakovQuotes
hi def link korsakovEscape		Special
if !exists("korsakov_no_number_highlight")
  hi def link korsakovNumber		Number
endif
if !exists("korsakov_no_builtin_highlight")
  hi def link korsakovBuiltin		Function
endif
if !exists("korsakov_no_exception_highlight")
  hi def link korsakovExceptions		Structure
endif
if exists("korsakov_space_error_highlight")
  hi def link korsakovSpaceError		Error
endif
if !exists("korsakov_no_doctest_highlight")
  hi def link korsakovDoctest		Special
  hi def link korsakovDoctestValue	Define
endif

let b:current_syntax = "korsakov"

let &cpo = s:cpo_save
unlet s:cpo_save

" vim:set sw=2 sts=2 ts=8 noet:
