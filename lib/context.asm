; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

; @function set_program_start_pointer
; @description Устанавливает указатель на начало программы
; @param pointer - указатель на начало программы
; @example
;   set_program_start_pointer rbp  ; Устанавливает указатель на начало программы
_function set_program_start_pointer, rax
  get_arg 0
  mov [PROGRAM_START_POINTER], rax
  ret

; @function get_program_start_pointer
; @description Возвращает указатель на начало программы
; @return Указатель на начало программы
; @example
;   get_program_start_pointer  ; Возвращает указатель на начало программы
_function get_program_start_pointer
  mov rax, [PROGRAM_START_POINTER]
  ret

; @function get_cli_arguments_count
; @description Возвращает количество аргументов, переданных программе
; @return Количество аргументов, переданных программе
; @example
;   get_cli_arguments_count  ; Возвращает количество аргументов, переданных программе
_function get_cli_arguments_count
  parse_cli_arguments
  mov rax, [CLI_ARGUMENTS_COUNT]
  ret

; @function get_cli_arguments
; @description Возвращает список аргументов, переданных программе
; @return Список аргументов, переданных программе
; @example
;   get_cli_arguments  ; Возвращает список аргументов, переданных программе
_function get_cli_arguments
  parse_cli_arguments
  mov rax, [CLI_ARGUMENTS]
  ret

; @function get_environment_variables
; @description Возвращает Список переменных окружения (Список из Строк) в формате "переменная=значение"
; @return Список переменных окружения
; @example
;   get_environment_variables
_function get_environment_variables
  parse_environment_variables

  mov rax, [ENVIRONMENT_VARIABLES]
  ret
