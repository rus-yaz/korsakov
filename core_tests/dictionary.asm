; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

string "Работа со словорями"
mov rdx, rax
list
list_append_link rax, rdx
print rax

dictionary
mov rcx, rax
mov rdx, rax
list
list_append_link rax, rdx
print rax

dictionary_length rcx
integer rax
mov rdx, rax
list
list_append_link rax, rdx
print rax

integer 0
mov rbx, rax
integer 1
dictionary_set rcx, rax, rbx
mov rdx, rax
list
list_append_link rax, rdx
print rax

list
mov rbx, rax
integer 0
list_append_link rbx, rax
integer 1
list_append_link rbx, rax
integer 2
list_append_link rbx, rax

list
mov rcx, rax
integer 3
list_append_link rcx, rax
integer 4
list_append_link rcx, rax
integer 5
list_append_link rcx, rax

dictionary rbx, rcx
mov rbx, rax
mov rdx, rax
list
list_append_link rax, rdx
print rax

integer 1
dictionary_get_link rbx, rax
mov rdx, rax
list
list_append_link rax, rdx
print rax

integer 99
mov rcx, rax
integer -1
dictionary_get_link rbx, rcx, rax
mov rdx, rax
list
list_append_link rax, rdx
print rax

dictionary_keys rbx
mov rdx, rax
list
list_append_link rax, rdx
print rax

dictionary_values rbx
mov rdx, rax
list
list_append_link rax, rdx
print rax

dictionary_items rbx
mov rdx, rax
list
list_append_link rax, rdx
print rax

dictionary_copy rbx
mov rdx, rax
list
list_append_link rax, rdx
print rax

dictionary
mov rbx, rax

integer 0
mov rcx, rax
dictionary_set_link rbx, rcx, rcx

mov rdx, rax
list
list_append_link rax, rdx
print rax

string "Привет"
dictionary_set_link rbx, rcx, rax

mov rdx, rax
list
list_append_link rax, rdx
print rax
