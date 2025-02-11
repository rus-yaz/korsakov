; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

include "core/korsakov.asm"

include "core/tests/const_buffers.asm"

section "start" executable
start:
  string ""
  mov r15, rax
  include "core/tests/arithmetical.asm"
  print r15
  include "core/tests/delete.asm"
  print r15
  include "core/tests/dictionary.asm"
  print r15
  include "core/tests/exec.asm"
  print r15
  include "core/tests/file.asm"
  print r15
  include "core/tests/functions.asm"
  print r15
  include "core/tests/heap.asm"
  print r15
  include "core/tests/integer.asm"
  print r15
  include "core/tests/list.asm"
  print r15
  include "core/tests/print.asm"
  print r15
  include "core/tests/string.asm"
  print r15
  include "core/tests/to_string.asm"
  print r15
  include "core/tests/variables.asm"
  print r15

  exit 0
