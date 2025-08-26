; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

; @function run
; @description Запускает внешнюю команду с указанными аргументами и переменными окружения
; @param command - список команд и аргументов для выполнения
; @param env - список переменных окружения
; @param wait=1 - флаг ожидания завершения процесса
; @example
;   list
;   list_append rax, "ls"
;   list_append rax, "-la"
;   mov rbx, rax
;
;   list
;   run rbx, rax  ; запускает команду ls -la без переменных среды
f_run:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  copy rbx
  mov rbx, rax
  copy rcx
  mov rcx, rax

  list_length rbx
  cmp rax, 1
  jge .correct
    string "run: Должна быть передана хотя бы одна строка"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .correct:

  mov r12, rsp

  integer 0
  list_get_link rbx, rax
  string_to_binary rax
  add rax, BINARY_HEADER*8
  mov r11, rax

  list_length rbx
  dec rax
  integer rax
  mov r8, rax

  push 0
  @@:
    mov rax, [r8 + INTEGER_HEADER*8]
    cmp rax, -1
    je @f

    list_get_link rbx, r8
    string_to_binary rax
    add rax, BINARY_HEADER*8
    push rax

    integer_dec r8
    jmp @b

  @@:
  mov r9, rsp

  list_length rcx
  dec rax
  integer rax
  mov r8, rax

  push 0
  @@:
    mov rax, [r8 + INTEGER_HEADER*8]
    cmp rax, -1
    je @f

    list_get_link rcx, r8
    string_to_binary rax
    add rax, BINARY_HEADER*8
    push rax

    integer_dec r8
    jmp @b

  @@:
  mov r10, rsp

  enter
  sys_fork
  return

  cmp rax, 0
  jge .fork_success

    string "run: Не удалось создать процесс"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .fork_success:

  cmp rax, 0
  jne .main_process

    ; Системный вызов использует регистры rax и rbx
    mov rax, r9
    mov rbx, r10

    sys_execve r11, rax, rbx

    raw_string "Не удалось выполнить системный вызов `execve`"
    error_raw rax
    exit -1

  .main_process:

  mov rsp, r12

  cmp rdx, 0
  je .dont_wait
    sys_wait4 rax

  .dont_wait:

  ret
