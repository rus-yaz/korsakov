; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

string "Выполнение команд"
print rax

list
mov rbx, rax
string "/bin/echo"
list_append_link rbx, rax
string "Hello"
list_append_link rbx, rax
run rbx, [ENVIRONMENT_VARIABLES]

list
mov rbx, rax
string "/bin/ls"
list_append_link rbx, rax
run rbx, [ENVIRONMENT_VARIABLES]
