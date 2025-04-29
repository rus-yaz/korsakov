; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

string "Работа со строками"
mov rbx, rax
list
list_append_link rax, rbx
print rax

string "Строка"
mov rbx, rax

; Взятие символа по индексу
integer -2
mov rcx, rax

string_get rbx, rcx
mov rdx, rax

string "Символ по индексу:"
mov r8, rax
list
list_append_link rax, r8
list_append_link rax, rdx
print rax

string_addition rbx, rdx
mov r8, rax
list
list_append_link rax, r8
print rax

string_extend rbx, rdx
mov r8, rax
list
list_append_link rax, rbx
print rax

list
list_append rax, rbx
list_append rax, rdx

mov r8, rax
list
list_append_link rax, r8
print rax

string " "
split rbx, rax
mov r8, rax
list
list_append_link rax, r8
print rax

string " "
join r8, rax
mov r8, rax
list
list_append_link rax, r8
print rax

string "Привет, мир!"
mov rcx, rax
mov r8, rax
list
list_append_link rax, rcx
print rax

integer 6
mov rbx, rax
string "!"
string_set rcx, rbx, rax
integer 8
mov rbx, rax
string "М"
string_set rcx, rbx, rax
mov r8, rax
list
list_append_link rax, rcx
print rax
