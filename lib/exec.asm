; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

section "" executable
f_run:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  list_length rbx
  cmp rax, 1
  jge .correct
    string "run: Должна быть передана хотя бы одна строка"
    print rax
    exit -1

  .correct:

  enter
  sys_fork
  return

  cmp rax, 0
  jne .main_process

    integer 0
    list_get_link rbx, rax
    string_to_binary rax
    add rax, BINARY_HEADER*8
    mov r11, rax

    list_length rbx
    dec rax
    integer rax
    mov rdx, rax

    push 0
    .command_while:
      mov rax, [rdx + INTEGER_HEADER*8]
      cmp rax, -1
      je .command_end_while

      list_get_link rbx, rdx
      string_to_binary rax
      add rax, BINARY_HEADER*8
      push rax

      integer_dec rdx
      jmp .command_while

    .command_end_while:
    mov r9, rsp

    list_length rcx
    dec rax
    integer rax
    mov rdx, rax

    push 0
    .environment_while:
      mov rax, [rdx + INTEGER_HEADER*8]
      cmp rax, -1
      je .environment_end_while

      list_get_link rcx, rdx
      string_to_binary rax
      add rax, BINARY_HEADER*8
      push rax

      integer_dec rdx
      jmp .environment_while

    .environment_end_while:
    mov r10, rsp

    mov rax, r9
    mov rbx, r10

    sys_execve r11, rax, r10
    exit -1, EXECVE_WAS_NOT_EXECUTED

  .main_process:

  cmp rcx, 0
  je .dont_wait
    sys_wait4 rax

  .dont_wait:

  ret
