; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

; @function print_raw
; @description Выводит сырой буфер в стандартный вывод
; @param raw_string_link - указатель на сырой буфер для вывода
; @example
;   raw_string "Hello"
;   print_raw rax  ; выводит "Hello"
f_print_raw:
  get_arg 0
  mov rsi, rax

  buffer_length rsi
  mov rbx, rax

  sys_print rsi,\      ; Указатель на буфер
            rbx        ; Размер буфера

  ret

; @function print_binary
; @description Выводит бинарную строку в стандартный вывод
; @param binary_string_link - указатель на бинарную строку для вывода
; @example
;   binary_string "Hello"
;   print_binary rax  ; выводит "Hello"
f_print_binary:
  get_arg 0
  add rax, BINARY_HEADER*8

  print_raw rax
  ret

; @function print
; @description Выводит список объектов в стандартный вывод с разделителями
; @param arguments - список объектов для вывода
; @param separator=0 - разделитель между элементами
; @param end_of_string=0 - символ в конце вывода
; @example
;   list
;   list_append rax, "Hello"
;   list_append rax, "World"
;   print rax  ; выводит "Hello World\n"
f_print:
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
  print_binary rax

  null
  ret
