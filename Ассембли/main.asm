format ELF64
public _start

include "lib/syscalls_amd64.asm"
include "lib/defines.asm"
include "lib/utils.asm"
include "lib/heap.asm"
include "lib/list.asm"
include "lib/integer.asm"
include "lib/string.asm"
include "lib/file.asm"
include "lib/exec.asm"
include "lib/errors.asm"
include "lib/functions.asm"

include "tests/const_buffers.asm"

section "_start" executable
_start:
  ; Аллокация кучи. Обязательна для любой работы с переменными
  allocate_heap

  include "tests/heap.asm"
  include "tests/file.asm"
  include "tests/string.asm"
  include "tests/list.asm"
  include "tests/print.asm"
  include "tests/exec.asm"
  include "tests/functions.asm"


  exit 0
