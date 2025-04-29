; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

list
mov rdx, rax

dictionary
mov rcx, rax

string "очистить"
mov rbx, rax
function rbx, f_clear, rdx, rcx, 0, 1
mov rcx, rax
list
assign rbx, rax, rcx
