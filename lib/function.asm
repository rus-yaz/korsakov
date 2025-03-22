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
  get_arg 4
  mov r9, rax
  get_arg 5
  mov r10, rax

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
  mem_mov [rax + 8*5], r9       ; Наличие аккумуляторов: 0 — нет, 1 — позиционный, 2 — именованный, 3 — оба
  mem_mov [rax + 8*6], r10      ; Является ли функция встроенной

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
  mem_mov [rax + 8*5], [rbx + 8*5]
  mem_mov [rax + 8*6], [rbx + 8*6]

  ret

f_function_call:
  push rax
  mov r15, [GLOBAL_CONTEXT]
  dictionary_copy_links r15
  mov [GLOBAL_CONTEXT], rax

  push rbp, rax, rbx, rcx, rdx, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15

  get_arg 2
  mov r9, rax
  get_arg 1
  mov r8, rax
  get_arg 0

  check_type rax, FUNCTION
  check_type r8,  LIST
  check_type r9,  DICTIONARY

  mov rbx, [rax + 8*6]
  push rbx

  mov rbx, [rax + 8*2]
  mov rcx, [rax + 8*3]
  mov rdx, [rax + 8*4]

  mov rax, [rax + 8*5]
  dec rax
  cmp rax, 0
  jg @f
    inc rax
  @@:

  integer rax
  mov r10, rax

  list_length rcx
  integer rax
  mov r11, rax

  list_length r8
  integer rax
  mov r12, rax

  dictionary_length rdx
  integer rax
  integer_sub r11, rax
  integer_sub rax, r10
  is_lower r12, rax
  boolean_value rax
  cmp rax, 1
  jne .enough_arguments_count

    list
    mov rbx, rax

    string "Аргументов слишком мало:"
    list_append_link rbx, rax
    string "Ожидалось —"
    list_append_link rbx, rax

    integer_sub r11, r10
    to_string rax
    mov rcx, rax

    string ", получено —"
    string_extend_links rcx, rax
    list_append_link rbx, rax

    to_string r12
    list_append_link rbx, rax

    print rax
    exit -1

  .enough_arguments_count:

  integer 0
  is_equal r10, rax
  boolean_value rax
  cmp rax, 1
  jne .correct_arguments_count

  is_lower r11, r12
  boolean_value rax
  cmp rax, 1
  jne .correct_arguments_count

    list
    mov rbx, rax

    string "Аргументов слишком много:"
    list_append_link rbx, rax
    string "Ожидалось —"
    list_append_link rbx, rax

    integer_sub r11, r10
    to_string rax
    mov rcx, rax

    string ", получено —"
    string_extend_links rcx, rax
    list_append_link rbx, rax

    to_string r12
    list_append_link rbx, rax

    print rax
    exit -1

  .correct_arguments_count:

  push rcx
  list_copy_links rcx       ; Позиционные аргументы функции
  mov rcx, rax
  dictionary_copy_links rdx ; Именованные аргументы функции
  mov rdx, rax
  list_copy_links r8        ; Переданные позиционные аргументы
  mov r8, rax
  dictionary_copy_links r9  ; Переданные именованные аргументы
  mov r9, rax

  list
  mov r14, rax

  .positional_while:

    list_length rcx
    cmp rax, 0
    je .positional_while_end

    list_length r8
    cmp rax, 0
    je .positional_while_end

    integer 0
    list_pop_link rcx, rax
    mov r11, rax

    integer -1
    string_get_link r11, rax
    mov r12, rax
    string "*"
    is_equal r12, rax
    boolean_value rax
    cmp rax, 1
    je .positional_accumulator

    integer 0
    list_pop_link r8, rax
    mov r10, rax

    list
    assign r11, rax, r10
    list_append_link r14, r11

    jmp .positional_while

  .positional_while_end:

  list_length rcx
  cmp rax, 0
  je .named

  integer 0
  list_pop_link rcx, rax
  mov r11, rax

  .positional_accumulator:

  integer -1
  string_get_link r11, rax
  mov r12, rax
  string "*"
  is_equal r12, rax
  boolean_value rax
  cmp rax, 1
  jne .not_positional_accumulator

  integer -2
  string_get_link r11, rax
  mov r12, rax
  string "*"
  is_equal r12, rax
  boolean_value rax
  cmp rax, 1
  je .named_accumulator

  list
  mov r10, rax

  .positional_accumulator_while:

    list_length r8
    cmp rax, 0
    je .positional_accumulator_while_end

    integer 0
    list_pop_link r8, rax
    list_append_link r10, rax

    jmp .positional_accumulator_while

  .positional_accumulator_while_end:

  string_pop_link r11
  list
  assign r11, rax, r10
  list_append_link r14, r11

  .not_positional_accumulator:

  .named:

  dictionary_add_links rdx, r9
  mov r10, rax
  dictionary_keys_links r10
  mov r13, rax

  .named_while:

    list_length r13
    cmp rax, 0
    je .continue

    integer 0
    list_pop_link r13, rax
    mov r11, rax

    integer -1
    string_get_link r11, rax
    mov r12, rax
    string "*"
    is_equal r12, rax
    boolean_value rax
    cmp rax, 1
    je .named_while_end

    list_include r14, r11
    boolean_value rax
    cmp rax, 1
    je .already_assigned

      dictionary_get_link r10, r11
      mov r12, rax

      list
      assign r11, rax, r12

    .already_assigned:

    jmp .named_while

  .named_while_end:

  .named_accumulator:
    ; TODO

  .continue:

  pop rcx, rdx

  cmp rdx, 1
  jne .not_internal

    list_length rcx
    mov rdx, rax

    list_copy rcx
    mov rcx, rax

    string "*"
    mov r8, rax

    .while:

      list_length rcx
      cmp rax, 0
      je .end_while

      list_pop_link rcx
      mov r9, rax

      integer -1
      string_get_link r9, rax
      is_equal r8, rax
      boolean_value rax
      cmp rax, 1
      jne .not_accumulator

        string_pop_link r9

        integer -1
        string_get_link r9, rax
        is_equal r8, rax
        boolean_value rax
        cmp rax, 1
        jne .not_accumulator

          string_pop_link r9

      .not_accumulator:

      list
      access r9, rax
      push rax

      jmp .while

    .end_while:

  .not_internal:

  push rdx
  mov rbp, rsp

  call rbx

  mov [GLOBAL_CONTEXT], r15
  return

  mov rbx, rax
  pop rax

  cmp rax, rbx
  jne @f
    null
    ret
  @@:

  mov rax, rbx

  ret
