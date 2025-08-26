; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

; @function set_program_start_pointer
; @description Устанавливает указатель на начало программы
; @param pointer - указатель на начало программы
; @example
;   set_program_start_pointer rbp  ; Устанавливает указатель на начало программы
f_set_program_start_pointer:
  get_arg 0
  mov [PROGRAM_START_POINTER], rax
  ret

; @function get_program_start_pointer
; @description Возвращает указатель на начало программы
; @return Указатель на начало программы
; @example
;   get_program_start_pointer  ; Возвращает указатель на начало программы
f_get_program_start_pointer:
  mov rax, [PROGRAM_START_POINTER]
  ret

; @function get_cli_arguments_count
; @description Возвращает количество аргументов, переданных программе
; @return Количество аргументов, переданных программе
; @example
;   get_cli_arguments_count  ; Возвращает количество аргументов, переданных программе
f_get_cli_arguments_count:
  get_program_start_pointer
  integer [rax]
  ret

; @function get_cli_arguments
; @description Возвращает список аргументов, переданных программе
; @return Список аргументов, переданных программе
; @example
;   get_cli_arguments  ; Возвращает список аргументов, переданных программе
f_get_cli_arguments:
  push rbp
  get_program_start_pointer
  mov rbp, rax

  list
  mov rbx, rax

  get_cli_arguments_count
  mov rdx, [rax + INTEGER_HEADER*8]

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

  pop rbp
  mov rax, rbx
  ret

; @function get_environment_variables
; @description Возвращает Список переменных окружения (Список из Строк) в формате "переменная=значение"
; @return Список переменных окружения
; @example
;   get_environment_variables  ; Возвращает список переменных окружения
f_get_environment_variables:
  push rbp
  mov rbp, [PROGRAM_START_POINTER]

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
  mov rax, rbx
  ret
