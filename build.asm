; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

include "core/korsakov.asm"

define NOSTD

init

list
mov rbx, rax
string "/bin/fasm"
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

string "korsakov"

mov rcx, rax
list_include [ARGUMENTS], rcx
boolean_value rax
cmp rax, 1
je .correct_target

string "tests"
mov rcx, rax
list_include [ARGUMENTS], rcx
boolean_value rax
cmp rax, 1
je .correct_target

  raw_string "Некорректная цель"
  error_raw rax
  exit -1

.correct_target:

string ".asm"
string_add_links rcx, rax
list_append_link rbx, rax

run rbx, [ENVIRONMENT_VARIABLES]

list
mov rbx, rax
string "/bin/ld"
list_append_link rbx, rax
string ".o"
string_add_links rcx, rax
list_append_link rbx, rax
string "-o"
list_append_link rbx, rax
list_append_link rbx, rcx
run rbx, [ENVIRONMENT_VARIABLES]

exit 0
