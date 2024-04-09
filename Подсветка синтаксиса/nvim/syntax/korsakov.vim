syn region Comment start="!!" end="$" contains=SpecialComment
syn keyword SpecialComment TODO NOTE XXX

syn match Number /\d\+\(_\d\+\)*/
syn match Float /\d\+\(_\d\+\)*,\d\+\(_\d\+\)*/

syn region String start="\"" end="\"" contains=SpecialChar
syn match SpecialChar /\\[tnvr"\\]/

syn match Identifier /[A-zА-яЁё_][A-zА-яЁё0-9_]\+/
syn match Constant /[A-ZА-ЯЁ_][A-ZА-ЯЁ0-9_]\+/

syn keyword Conditional check     if   then else  true   false
syn keyword Conditional проверить если то   иначе истина ложь

syn keyword Repeat for of from to after while
syn keyword Repeat для из от   до через пока

syn keyword Keyword class function
syn keyword Keyword класс функция
syn match Function /[A-zА-яЁё_][A-zА-яЁё0-9_]*\((\)\@=/

syn match Delimiter /\(---\|===\|%%%\)/

syn keyword Include include
syn keyword Include включить

syn keyword Keyword and or  not continue   break    return  delete
syn keyword Keyword и   или не  продолжить прервать вернуть удалить
