; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

raw_string "Словарь из списков", 10
print_raw rax

arguments "ключи", "значения"
mov rdx, rax

dictionary
mov rcx, rax

string "словарь_из_списков"
mov rbx, rax
function rbx, f_dictionary_from_lists, rdx, rcx, 0, 1
mov rcx, rax
list
assign rbx, rax, rcx
mov rcx, rax

list
mov r15, rax

; ======================
; =    Целые числа     =
; ======================

list
mov r14, rax

list
mov rbx, rax
integer 0
list_append_link rbx, rax
integer 1
list_append_link rbx, rax
integer -1
list_append_link rbx, rax
list_append_link r14, rax

list
mov rbx, rax
integer 0
list_append_link rbx, rax
integer 0
list_append_link rbx, rax
integer 0
list_append_link rbx, rax
list_append_link r14, rax

list_append_link r15, rax

list
mov r14, rax

list
mov rbx, rax
integer 0
list_append_link rbx, rax
integer 1
list_append_link rbx, rax
integer -1
list_append_link rbx, rax
list_append_link r14, rax

list
mov rbx, rax
integer 1
list_append_link rbx, rax
integer 1
list_append_link rbx, rax
integer 1
list_append_link rbx, rax
list_append_link r14, rax

list_append_link r15, rax

list
mov r14, rax

list
mov rbx, rax
integer 0
list_append_link rbx, rax
integer 1
list_append_link rbx, rax
integer -1
list_append_link rbx, rax
list_append_link r14, rax

list
mov rbx, rax
integer -1
list_append_link rbx, rax
integer -1
list_append_link rbx, rax
integer -1
list_append_link rbx, rax
list_append_link r14, rax

list_append_link r15, rax

test rcx, r15
