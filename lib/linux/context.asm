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
_function parse_cli_arguments, rax, rbx, rcx, rdx
  cmp [CLI_ARGUMENTS], 0
  je @f
    ret
  @@:

  push rbp
  get_program_start_pointer
  mov rbp, rax

  mov rdx, [rbp]
  integer rdx
  mov [CLI_ARGUMENTS_COUNT], rax

  list
  mov rbx, rax

  mov rcx, 0
  @@:
    cmp rdx, rcx
    je @f

    get_arg rcx
    buffer_to_string rax
    list_append_link rbx, rax

    inc rcx
    jmp @b
  @@:

  mov [CLI_ARGUMENTS], rbx
  pop rbp

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
_function parse_environment_variables, rax, rbx, rcx
  cmp [ENVIRONMENT_VARIABLES], 0
  je @f
    ret
  @@:

  push rbp
  get_program_start_pointer
  mov rbp, rax

  get_cli_arguments_count
  mov rax, [rax + INTEGER_HEADER*8]

  inc rax ; Учёт числа, равного количеству аргументов
  inc rax ; Разграничитель между аргументами и переменными среды

  imul rax, 8
  add rbp, rax

  list
  mov rbx, rax

  mov rcx, 0
  @@:
    get_arg rcx
    cmp rax, 0
    je @f

    buffer_to_string rax
    list_append_link rbx, rax

    inc rcx
    jmp @b
  @@:

  pop rbp
  mov [ENVIRONMENT_VARIABLES], rbx

  ret
