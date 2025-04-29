; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

define TERMINAL

macro clear {
  enter

  call f_clear

  leave
}

f_clear:
  string <27, "[2J", 27, "[H">
  mov rbx, rax
  list
  list_append_link rax, rbx
  print rax
  ret
