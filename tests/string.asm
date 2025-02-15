; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

string "Работа со строками"
print rax

string "Строка"
mov rbx, rax

; Взятие символа по индексу
integer -2
mov rcx, rax

string_get rbx, rcx
mov rdx, rax

string "Символ по индексу:"
print <rax, rdx>

string_add rbx, rdx
print rax

string_extend rbx, rdx
print rbx

list
list_append rax, rbx
list_append rax, rdx

print rax

split rbx, " "
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
