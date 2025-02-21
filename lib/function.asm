; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

f_function:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax
  get_arg 3
  mov r8, rax

  check_type rdx, LIST
  check_type r8, DICTIONARY

  copy rdx
  mov rdx, rax
  copy r8
  mov r8, rax

  create_block FUNCTION_HEADER*8
  mem_mov [rax + 8*0], FUNCTION ; Тип
  mem_mov [rax + 8*1], rbx      ; Имя
  mem_mov [rax + 8*2], rcx      ; Ссылка на функцию
  mem_mov [rax + 8*3], rdx      ; Аргументы
  mem_mov [rax + 8*4], r8       ; Именованные аргументы

  ret

f_function_copy:
  get_arg 0
  mov rbx, rax

  copy [rbx + 8*1]
  mov rcx, rax
  copy [rbx + 8*3]
  mov rdx, rax
  copy [rbx + 8*4]
  mov r8, rax

  create_block FUNCTION_HEADER*8
  mem_mov [rax + 8*0], FUNCTION
  mem_mov [rax + 8*1], rcx
  mem_mov [rax + 8*2], [rbx + 8*2]
  mem_mov [rax + 8*3], rdx
  mem_mov [rax + 8*4], r8

  ret

f_function_call:
  mov r15, [GLOBAL_CONTEXT]
  dictionary_copy_links r15
  mov [GLOBAL_CONTEXT], rax

  get_arg 1
  mov r8, rax

  get_arg 0

  check_type rax, FUNCTION
  check_type r8, LIST

  mov rbx, [rax + 8*2]
  mov rcx, [rax + 8*3]
  mov rdx, [rax + 8*4]

  list_length rcx
  integer rax
  mov r9, rax

  list_length r8
  integer rax
  mov r10, rax

  is_lower r9, r10
  boolean_value rax
  cmp rax, 1
  je .incorrect_argumenst_count

  dictionary_length rdx
  integer rax
  integer_sub r9, rax
  mov r9, rax

  is_lower_or_equal r9, r10
  boolean_value rax
  cmp rax, 1
  je .correct_argumenst_count

  .incorrect_argumenst_count:

    list
    mov rbx, rax
    string "Ожидаемое количество аргументов —"
    list_append_link rbx, rax
    to_string r9
    mov rcx, rax
    string ", получено —"
    string_extend_links rcx, rax
    list_append_link rbx, rax
    to_string r10
    list_append_link rbx, rax
    print rax
    exit -1

  .correct_argumenst_count:

  integer 0
  mov r9, rax

  list_length rcx
  integer rax
  mov r10, rax

  list_length r8
  integer rax
  mov r11, rax

  .while:

    is_equal r9, r10
    boolean_value rax
    cmp rax, 1
    je .end_while

    list_get_link rcx, r9
    mov r12, rax

    is_greater_or_equal r9, r11
    boolean_value rax
    cmp rax, 1
    je .default_value

      list_get r8, r9
      jmp .arguments_continue

    .default_value:

      list_get_link rcx, r9
      dictionary_get rdx, rax

    .arguments_continue:

    mov r13, rax
    list
    assign r12, rax, r13

    integer_inc r9
    jmp .while

  .end_while:

  call rbx

  mov [GLOBAL_CONTEXT], r15

  ret
