; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

include "core/korsakov.asm"

define NOSTD

init

list
mov rbx, rax
string "/bin/fasm"
list_append_link rbx, rax
string "korsakov.asm"
list_append_link rbx, rax
string "-m"
list_append_link rbx, rax
string "131072"
list_append_link rbx, rax

string "--debug"
list_include [ARGUMENTS], rax
boolean_value rax
cmp rax, 1
jne .no_debug
  string "-d"
  list_append_link rbx, rax
  string "DEBUG="
  list_append_link rbx, rax
.no_debug:

run rbx, [ENVIRONMENT_VARIABLES]

list
mov rbx, rax
string "/bin/ld"
list_append_link rbx, rax
string "korsakov.o"
list_append_link rbx, rax
string "-o"
list_append_link rbx, rax
string "korsakov"
list_append_link rbx, rax
run rbx, [ENVIRONMENT_VARIABLES]

exit 0
