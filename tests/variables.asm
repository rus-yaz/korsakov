; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

string "Работа с переменными"
print rax

string "а"
mov rcx, rax

list
mov rbx, rax

assign rcx, rbx, rcx
access rcx, rbx
print rax

integer 0
assign rcx, rbx, rax
access rcx, rbx
print rax

dictionary
assign rcx, rbx, rax
access rcx, rbx
print rax

integer 0
list_append rbx, rax

integer 1
assign rcx, rbx, rax
print rax

list
mov rdx, rax
integer 2
list_append rdx, rax
integer 3
list_append rdx, rax

assign rcx, rbx, rax
print rax

integer 1
list_append rbx, rax

integer 5
assign rcx, rbx, rax
print rax

list
mov rbx, rax

list
mov rdx, rax
integer 0
list_append rdx, rax
integer 1
list_append rdx, rax
assign rcx, rbx, rax
print rax

integer 0
list_append rbx, rax

integer 10
assign rcx, rbx, rax
print rax
