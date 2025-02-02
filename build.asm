include "./core/korsakov.asm"

section "start" executable
start:
  list
  mov rbx, rax
  string "/bin/fasm"
  list_append_link rbx, rax
  string "korsakov.asm"
  list_append_link rbx, rax
  string "-m"
  list_append_link rbx, rax
  string "131072"
  list_append_link rbx, rax
  run rbx, [ENVIRONMENT_VARIABLES]

  list
  mov rbx, rax
  string "/bin/ld"
  list_append_link rbx, rax
  string "korsakov.o"
  list_append_link rbx, rax
  string "-o"
  list_append_link rbx, rax
  string "korsakov"
  list_append_link rbx, rax
  run rbx, [ENVIRONMENT_VARIABLES]

  exit 0
