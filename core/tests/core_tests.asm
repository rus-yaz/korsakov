; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

include "../korsakov.asm"

include "const_buffers.asm"

section "start" executable
start:
  string ""
  mov r15, rax
  include "arithmetical.asm"
  print r15
  include "delete.asm"
  print r15
  include "dictionary.asm"
  print r15
  include "exec.asm"
  print r15
  include "file.asm"
  print r15
  include "functions.asm"
  print r15
  include "heap.asm"
  print r15
  include "integer.asm"
  print r15
  include "list.asm"
  print r15
  include "print.asm"
  print r15
  include "string.asm"
  print r15
  include "to_string.asm"
  print r15
  include "variables.asm"
  print r15

  exit 0
