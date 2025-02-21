; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

string "Арифметические операции"
mov rcx, rax
list
list_append_link rax, rcx
print rax

integer 0
mov rbx, rax
integer 0
mov rcx, rax
list
list_append_link rax, rbx
list_append_link rax, rcx
print rax

addition rbx, rcx
mov rcx, rax
list
list_append_link rax, rcx
print rax

integer 2
mov rbx, rax
integer 3
mov rcx, rax
list
list_append_link rax, rbx
list_append_link rax, rcx
print rax

addition rbx, rcx
mov rcx, rax
list
list_append_link rax, rcx
print rax

integer -2
mov rbx, rax
integer 1
mov rcx, rax
list
list_append_link rax, rbx
list_append_link rax, rcx
print rax

addition rbx, rcx
mov rcx, rax
list
list_append_link rax, rcx
print rax

integer 2
mov rbx, rax
integer 1
mov rcx, rax
list
list_append_link rax, rbx
list_append_link rax, rcx
print rax

subtraction rbx, rcx
mov rcx, rax
list
list_append_link rax, rcx
print rax
