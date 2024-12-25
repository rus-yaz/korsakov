format ELF64
public _start

include "lib/defines.asm"
include "lib/syscalls_amd64.asm"
include "lib/utils.asm"
include "lib/heap.asm"
include "lib/print.asm"
include "lib/integer.asm"
include "lib/string.asm"
include "lib/list.asm"
include "lib/functions.asm"
include "lib/dictionary.asm"
include "lib/file.asm"
include "lib/exec.asm"
include "lib/errors.asm"

include "tests/const_buffers.asm"

include "tokenizer.asm"

section "data" writable
  файл db "привет, мир.корс", 0

section "_start" executable
_start:
  include "tests/heap.asm"
  include "tests/file.asm"
  include "tests/list.asm"
  include "tests/print.asm"
  include "tests/exec.asm"
  include "tests/string.asm"
  include "tests/integer.asm"
  include "tests/functions.asm"
  include "tests/dictionary.asm"

  tokenizer файл

  exit 0
