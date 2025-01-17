string "Работа со строками"
print rax

buffer_to_string string.буфер
mov [string.строка], rax

; Взятие символа по индексу
integer -2
mov [string.индекс], rax

string_get [string.строка], [string.индекс]
mov [string.символ], rax

print <CHAR_BY_INDEX_TEXT, [string.символ]>

string_add [string.строка], [string.символ]
print rax

string_append [string.строка], [string.символ]
print [string.строка]

list
list_append rax, [string.строка]
list_append rax, [string.символ]

print rax

split [string.строка], " "
print rax

join rax, " "
print rax
