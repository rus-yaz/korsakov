; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

string "Работа с целыми числами"
mov rdx, rax
list
list_append_link rax, rdx
print rax

integer 1
mov rbx, rax
mov rdx, rax
list
list_append_link rax, rdx
print rax

integer 2
mov rcx, rax
mov rdx, rax
list
list_append_link rax, rdx
print rax

integer_add rcx, rbx
mov rdx, rax
list
list_append_link rax, rdx
print rax
