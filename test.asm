include "lib/korsakov.asm"

include "tests/const_buffers.asm"

section "start" executable
start:
  include "tests/heap.asm"
  include "tests/delete.asm"
  include "tests/file.asm"
  include "tests/functions.asm"
  include "tests/integer.asm"
  include "tests/list.asm"
  include "tests/string.asm"
  include "tests/dictionary.asm"
  include "tests/exec.asm"
  include "tests/print.asm"
  include "tests/variables.asm"
  include "tests/arithmetical.asm"

  exit 0
