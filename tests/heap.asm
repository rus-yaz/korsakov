; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

string "Работа с кучей"
mov rbx, rax
list
list_append_link rax, rbx
print rax

; Расширение кучи
create_block 0x1000
mov rbx, rax

create_block 0x1000
mov rcx, rax

create_block 0x1000
mov rdx, rax

delete_block rbx
delete_block rdx
delete_block rcx
