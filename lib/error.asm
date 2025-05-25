; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

f_error_raw:
  get_arg 0
  mov rsi, rax

  buffer_length rsi
  mov rbx, rax

  sys_error rsi,\      ; Указатель на буфер
            rbx        ; Размер буфера

  ret

f_error_binary:
  get_arg 0
  add rax, BINARY_HEADER*8

  error_raw rax
  ret

f_error:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  cmp rcx, 0
  jne .not_default_separator
    string " "
    mov rcx, rax
  .not_default_separator:

  cmp rdx, 0
  jne .not_default_end_of_string
    string 10
    mov rdx, rax
  .not_default_end_of_string:

  check_type rbx, LIST
  check_type rcx, STRING
  check_type rdx, STRING

  list
  mov r8, rax

  integer 0
  mov r9, rax

  list_length rbx
  integer rax
  mov r10, rax

  .while:

    is_equal r9, r10
    boolean_value rax
    cmp rax, 1
    je .end_while

    list_get_link rbx, r9
    mov r11, [rax]
    cmp r11, STRING
    je .string
      to_string rax
    .string:

    list_append_link r8, rax

    integer_inc r9
    jmp .while

  .end_while:

  join_links r8, rcx
  string_extend_links rax, rdx

  string_to_binary rax
  error_binary rax

  null
  ret

  ret

f_exit_with_error:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax
  get_arg 2
  mov r8, rax

  error rcx, rdx, r8

  mov rax, [rbx + INTEGER_HEADER*8]
  exit rax
