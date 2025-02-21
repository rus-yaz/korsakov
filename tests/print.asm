; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

string "Тест отображения"
mov r9, rax
list
list_append rax, r9
print rax

; Проверка строк
string "Привет, мир!"
mov r8, rax
list
list_append rax, r8
print rax

; Проверка чисел
integer 1024
mov r9, rax
list
list_append rax, r9
print rax

list
mov r9, rax
list
list_append rax, r9
print rax

list
mov rbx, rax

integer 0
list_append rbx, rax
integer 1
list_append rbx, rax
integer 2
list_append rbx, rax

mov r9, rax
list
list_append rax, r9
print rax

list
mov rbx, rax

integer 0
list_append rbx, rax
list_append rbx, r8

list
mov rcx, rax

integer 99
list_append rcx, rax

list
mov rdx, rax

integer 0
list_append rdx, rax
integer 1
list_append rdx, rax
integer 2
list_append rdx, rax

list_append rcx, rdx

dictionary rbx, rcx
mov r9, rax
list
list_append rax, r9
print rax

; Проверка множественного отображения
integer 1024
mov rbx, rax
string "Содержимое строки:"
mov r9, rax
list
list_append rax, rbx
list_append rax, r9
list_append rax, r8
print rax

; Проверка замены разделителя и конца стрки

integer 1024
mov rbx, rax
mov rcx, rax
mov rdx, rax

string <"*", 10>
mov r8, rax

list
list_append rax, rbx
list_append rax, rcx
list_append rax, rdx

print rax, "?"
print rax, "_", r8
