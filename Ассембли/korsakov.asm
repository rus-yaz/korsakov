format ELF64
public _start

include "lib/syscalls_amd64.asm"
include "lib/defines.asm"
include "lib/utils.asm"
include "lib/heap.asm"
include "lib/exec.asm"

section "data" writable
  fasm      db "/bin/fasm", 0
  fasm_arg1 db "main.asm", 0
  fasm_args dq fasm, fasm_arg1, 0

  ld      db "/bin/ld", 0
  ld_arg1 db "main.o", 0
  ld_arg2 db "-o", 0
  ld_arg3 db "main", 0
  ld_args dq ld, ld_arg1, ld_arg2, ld_arg3, 0

  lang db "LANG=en_US.UTF-8", 0
  envp dq lang, 0

section "_start" executable
_start:
  run fasm, fasm_args, envp

  run ld, ld_args, envp

  exit 0
