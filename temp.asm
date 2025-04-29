include "core/korsakov.asm"
include "modules/terminal.asm"

start:
  string "очистить"
  mov rbx, rax
  list
  access rbx, rax
  mov rbx, rax

  list
  list_append_link rax, rbx
  print rax

  exit 0
