; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

include "core/korsakov.asm"

section "start" executable
start:
  string ""
  mov rbx, rax
  list
  list_append_link rax, rbx
  mov r15, rax
  include "tests/arithmetical.asm"
  print r15
  include "tests/delete.asm"
  print r15
  include "tests/dictionary.asm"
  print r15
  include "tests/exec.asm"
  print r15
  include "tests/file.asm"
  print r15
  include "tests/functions.asm"
  print r15
  include "tests/heap.asm"
  print r15
  include "tests/integer.asm"
  print r15
  include "tests/list.asm"
  print r15
  include "tests/print.asm"
  print r15
  include "tests/string.asm"
  print r15
  include "tests/to_string.asm"
  print r15
  include "tests/variables.asm"
  print r15

  exit 0
