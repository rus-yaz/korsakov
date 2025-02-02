string "Работа со строками"
print rax

buffer_to_string string.буфер
mov [string.строка], rax

; Взятие символа по индексу
integer -2
mov [string.индекс], rax

string_get [string.строка], [string.индекс]
mov [string.символ], rax

string "Символ по индексу:"
print <rax, [string.символ]>

string_add [string.строка], [string.символ]
print rax

string_extend [string.строка], [string.символ]
print [string.строка]

list
list_append rax, [string.строка]
list_append rax, [string.символ]

print rax

split [string.строка], " "
print rax

join rax, " "
print rax

string "Привет, мир!"
mov rcx, rax
print rcx

integer 6
mov rbx, rax
string "!"
string_set rcx, rbx, rax
integer 8
mov rbx, rax
string "М"
string_set rcx, rbx, rax
print rcx
