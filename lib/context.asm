; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

f_set_program_start_pointer:
  get_arg 0
  mov [PROGRAM_START_POINTER], rax
  ret

f_get_program_start_pointer:
  mov rax, [PROGRAM_START_POINTER]
  ret

f_get_cli_arguments_count:
  get_program_start_pointer
  integer [rax]
  ret

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
