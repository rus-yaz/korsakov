syn region Comment start="!!" end="$" contains=SpecialComment
syn keyword SpecialComment TODO NOTE XXX

syn match Number /\d/
syn match Float /\d\.\d/

syn region String start="\"" end="\"" contains=SpecialChar
syn match SpecialChar /\\[tnvr"\\]/

syn match Identifier /[A-zА-я_][A-zА-я0-9_]\+/
syn match Constant /[A-ZА-Я_][A-ZА-Я0-9_]\+/

syn keyword Conditional check     if   then else
syn keyword Conditional проверить если то   иначе

syn keyword Repeat for in from to after while
syn keyword Repeat для в  от   до через пока

syn keyword Keyword function
syn keyword Keyword функция
syn match Function /[A-zА-я_][A-zА-я0-9_]\+\((\)\@=/

syn match Delimiter /\(---\|===\|%%%\)/

syn keyword Include include
syn keyword Include включить

syn keyword Keyword and or  not continue   break    return 
syn keyword Keyword и   или не  продолжить прервать вернуть
