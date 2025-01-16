include "core/korsakov.asm"

include "tests/const_buffers.asm"

section "start" executable
start:
  include "tests/arithmetical.asm"
  include "tests/delete.asm"
  include "tests/dictionary.asm"
  include "tests/exec.asm"
  include "tests/file.asm"
  include "tests/functions.asm"
  include "tests/heap.asm"
  include "tests/integer.asm"
  include "tests/list.asm"
  include "tests/print.asm"
  include "tests/string.asm"
  include "tests/to_string.asm"
  include "tests/variables.asm"

  exit 0
