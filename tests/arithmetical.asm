; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

string "Арифметические операции"
mov rcx, rax
list
list_append_link rax, rcx
print rax

integer 2
mov rcx, rax
integer 3
mov rdx, rax

addition rcx, rdx
mov rbx, rax
list
list_append_link rax, rbx
print rax

subtraction rbx, rcx
mov rbx, rax
list
list_append_link rax, rbx
print rax

multiplication rbx, rcx
mov rbx, rax
list
list_append_link rax, rbx
print rax

division rbx, rcx
mov rbx, rax
list
list_append_link rax, rbx
print rax

list
mov rcx, rax
integer 0
list_append_link rcx, rax
string "Привет"
list_append_link rcx, rax
boolean 1
list_append_link rcx, rax
list
list_append_link rcx, rax

list
list_append_link rax, rcx
print rax

integer 3
mov rdx, rax

addition rcx, rcx
mov rbx, rax
list
list_append_link rax, rbx
print rax

multiplication rcx, rdx
mov rbx, rax
list
list_append_link rax, rbx
print rax

multiplication rdx, rcx
mov rbx, rax
list
list_append_link rax, rbx
print rax

string "Привет"
mov rcx, rax

integer 3
mov rdx, rax

addition rcx, rcx
mov rbx, rax
list
list_append_link rax, rbx
print rax

multiplication rcx, rdx
mov rbx, rax
list
list_append_link rax, rbx
print rax

multiplication rdx, rcx
mov rbx, rax
list
list_append_link rax, rbx
print rax
