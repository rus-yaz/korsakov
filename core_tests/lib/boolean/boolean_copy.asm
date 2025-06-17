; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

raw_string "Копирование булевых значений", 10
print_raw rax

arguments "значение"
mov rdx, rax

dictionary
mov rcx, rax

string "копировать_булево_значение"
mov rbx, rax
function rbx, f_boolean_copy, rdx, rcx, 0, 1
mov rcx, rax
list
assign rbx, rax, rcx
mov rcx, rax

list
mov r15, rax

list
mov r14, rax
boolean 0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
boolean 1
list_append_link r14, rax
list_append_link r15, rax

test rcx, r15
