syn region Comment start="!!" end="$" contains=SpecialComment
syn region Comment start="!\*" end="\*!" contains=SpecialComment
syn keyword SpecialComment TODO NOTE XXX

syn match Number /\d\+\(_\d\+\)*/
syn match Float /\d\+\(_\d\+\)*,\d\+\(_\d\+\)*/

syn region String start="\"" end="\"" contains=SpecialChar
syn match SpecialChar /\\[tnvr"\\]/

syn match Identifier /[A-Za-zА-Яа-яЁё_][A-Za-zА-Яа-яЁё0-9_]*/
syn match Constant /[A-ZА-ЯЁ_][A-ZА-ЯЁ0-9_]*/

syn keyword Conditional if   then else  true   false check     при
syn keyword Conditional если то   иначе истина ложь  проверить on

syn keyword Repeat for of from to after while
syn keyword Repeat для из от   до через пока

syn keyword Keyword class function
syn keyword Keyword класс функция
syn match Function /[A-zА-яЁё_][A-zА-яЁё0-9_]*\((\)\@=/

syn match Delimiter /\(---\|===\|%%%\)/

syn keyword Include include
syn keyword Include включить

syn keyword Keyword and or  not skip       break    return  delete
syn keyword Keyword и   или не  пропустить прервать вернуть удалить
