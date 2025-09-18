; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

; @function parse_cli_arguments
; @description
;   Дистрозависимая функция для парсинга аргументов командной строки
;
;   Отработает только один раз
;
;   Результат работы функции будет помещён в глобальные переменные:
;   - [CLI_ARGUMENTS] — список аргументов
;   - [CLI_ARGUMENTS_COUNT] — количество аргументов
; @example
;   parse_cli_arguments
_function parse_cli_arguments, rax, rbx, rcx, rdx, r8, r9, r10, r11, r12
  cmp [CLI_ARGUMENTS], 0
  je @f
    ret
  @@:

  invoke GetCommandLineW
  utf16_to_utf8 rax

  buffer_to_string rax
  mov rbx, rax

  string '"'
  mov r10, rax

  integer 0
  string_get_link rbx, rax

  is_not_equal r10, rax
  boolean_value rax
  mov r10, rax ; 0 — открывающая кавычка, 1 — закрывающая

  string '"'
  split_links rbx, rax
  mov rbx, rax

  integer 0
  mov rcx, rax

  list
  mov rdx, rax

  list_length rbx
  integer rax
  mov r8, rax

  string " "
  mov r11, rax
  string ""
  mov r12, rax

  .while:

    is_equal rcx, r8
    boolean_value rax
    cmp rax, 1
    je .end_while

    list_get_link rbx, rcx
    mov r9, rax

    is_equal r9, r12
    boolean_value rax
    cmp rax, 1
    je .quote

    cmp r10, 0
    jne .non_quote

    list_append_link rdx, r9
    jmp .next

    .quote:
      dec r10 ; 0 -> -1; 1 -> 0
      neg r10 ; 0 -> 0; -1 -> 1
      jmp .next
    .non_quote:

    split_links r9
    list_extend_links rdx, rax

    .next:

    integer_inc rcx
    jmp .while

  .end_while:

  integer 0
  mov rbx, rax

  list_length rdx
  integer rax
  mov rcx, rax

  list
  mov r9, rax

  .clean_while:
    is_equal rbx, rcx
    boolean_value rax
    cmp rax, 1
    je .end_clean_while

    list_get_link rdx, rbx
    mov r8, rax

    is_equal r8, r12
    boolean_value rax
    cmp rax, 1
    je @f
      list_append_link r9, r8
    @@:

    integer_inc rbx
    jmp .clean_while

  .end_clean_while:

  mov [CLI_ARGUMENTS], r9

  list_length r9
  integer rax
  mov [CLI_ARGUMENTS_COUNT], rax

  ret

; @function parse_environment_variables
; @description
;   Дистрозависимая функция для парсинга переменных среды
;
;   Отработает только один раз
;
;   Результат работы функции будет помещён в глобальные переменные:
;   - [ENVIRONMENT_VARIABLES] — список переменных среды
; @example
;   parse_environment_variables
_function parse_environment_variables, rax, rbx, rdx, r8
  cmp [ENVIRONMENT_VARIABLES], 0
  je @f
    ret
  @@:

  invoke GetEnvironmentStringsA
  mov rbx, rax

  list
  mov rdx, rax

  .env_while:

    buffer_to_string rbx
    mov r8, rax

    list_append_link rdx, r8

    string_length r8
    add rbx, rax
    inc rbx

    cmp byte [rbx], 0
    jne .env_while

  mov [ENVIRONMENT_VARIABLES], rdx

  ret
