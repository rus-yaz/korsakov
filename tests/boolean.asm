; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

string "Работа с булевыми значениями"
mov rbx, rax
list
list_append_link rax, rbx
print rax

boolean 1
mov rdx, rax
list
list_append_link rax, rdx
print rax

boolean 0
mov rdx, rax
list
list_append_link rax, rdx
print rax

integer 1
boolean rax
mov rdx, rax
list
list_append_link rax, rdx
print rax

integer 0
boolean rax
mov rdx, rax
list
list_append_link rax, rdx
print rax

integer 0
mov rbx, rax
list
list_append rax, rbx
boolean rax
mov rdx, rax
list
list_append_link rax, rdx
print rax

list
boolean rax
mov rdx, rax
list
list_append_link rax, rdx
print rax

string "Привет"
boolean rax
mov rdx, rax
list
list_append_link rax, rdx
print rax

string ""
boolean rax
mov rdx, rax
list
list_append_link rax, rdx
print rax

integer 0
mov rbx, rax
integer 1
mov rcx, rax
dictionary
boolean rax
mov rdx, rax
list
list_append_link rax, rdx
print rax

dictionary
boolean rax
mov rdx, rax
list
list_append_link rax, rdx
print rax
