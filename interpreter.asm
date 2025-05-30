; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

section "interpreter" executable

macro interpreter ast*, context* {
  debug_start "interpreter"
  enter ast, context

  call f_interpreter

  return
  debug_end "interpreter"
}

macro interpret node*, context* {
  debug_start "interpret"
  enter node, context

  call f_interpret

  return
  debug_end "interpret"
}

macro interpret_body node*, context* {
  debug_start "interpret_body"
  enter node, context

  call f_interpret_body

  return
  debug_end "interpret_body"
}

macro interpret_assign_link node*, context* {
  debug_start "interpret_assign_link"
  enter node, context

  call f_interpret_assign_link

  return
  debug_end "interpret_assign_link"
}

macro interpret_assign node*, context* {
  debug_start "interpret_assign"
  enter node, context

  call f_interpret_assign

  return
  debug_end "interpret_assign"
}

macro interpret_access_link node*, context* {
  debug_start "interpret_access_link"
  enter node, context

  call f_interpret_access_link

  return
  debug_end "interpret_access_link"
}

macro interpret_access node*, context* {
  debug_start "interpret_access"
  enter node, context

  call f_interpret_access

  return
  debug_end "interpret_access"
}

macro interpret_unary_operation node*, context* {
  debug_start "interpret_unary_operation"
  enter node, context

  call f_interpret_unary_operation

  return
  debug_end "interpret_unary_operation"
}

macro interpret_binary_operation node*, context* {
  debug_start "interpret_binary_operation"
  enter node, context

  call f_interpret_binary_operation

  return
  debug_end "interpret_binary_operation"
}

macro interpret_null node*, context* {
  debug_start "interpret_null"
  enter node, context

  call f_interpret_null

  return
  debug_end "interpret_null"
}

macro interpret_number node*, context* {
  debug_start "interpret_number"
  enter node, context

  call f_interpret_number

  return
  debug_end "interpret_number"
}

macro interpret_list node*, context* {
  debug_start "interpret_list"
  enter node, context

  call f_interpret_list

  return
  debug_end "interpret_list"
}

macro interpret_string node*, context* {
  debug_start "interpret_string"
  enter node, context

  call f_interpret_string

  return
  debug_end "interpret_string"
}

macro interpret_dictionary node*, context* {
  debug_start "interpret_dictionary"
  enter node, context

  call f_interpret_dictionary

  return
  debug_end "interpret_dictionary"
}

macro interpret_if node*, context* {
  debug_start "interpret_if"
  enter node, context

  call f_interpret_if

  return
  debug_end "interpret_if"
}

macro interpret_while node*, context* {
  debug_start "interpret_while"
  enter node, context

  call f_interpret_while

  return
  debug_end "interpret_while"
}

macro interpret_for node*, context* {
  debug_start "interpret_for"
  enter node, context

  call f_interpret_for

  return
  debug_end "interpret_for"
}

macro interpret_skip node*, context* {
  debug_start "interpret_skip"
  enter node, context

  call f_interpret_skip

  return
  debug_end "interpret_skip"
}

macro interpret_break node*, context* {
  debug_start "interpret_break"
  enter node, context

  call f_interpret_break

  return
  debug_end "interpret_break"
}

macro interpret_function node*, context* {
  debug_start "interpret_function"
  enter node, context

  call f_interpret_function

  return
  debug_end "interpret_function"
}

macro interpret_call node*, context* {
  debug_start "interpret_call"
  enter node, context

  call f_interpret_call

  return
  debug_end "interpret_call"
}

macro add_code [code*] {
  string code
  list_append_link rdx, rax
}

f_interpreter:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  integer 0
  mov rdx, rax

  list
  mov r8, rax

  .while:
    list_length rbx
    integer rax
    is_equal rax, rdx
    boolean_value rax
    cmp rax, 1
    je .end_while

    list_get_link rbx, rdx
    interpret rax, rcx
    list_append_link r8, rax

    integer_inc rdx
    jmp .while

  .end_while:

  mov rax, r8
  ret

f_interpret:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  mov rax, [rbx]
  cmp rax, LIST
  jne .not_body
    interpret_body rcx, rbx
    ret
  .not_body:

  check_node_type rbx, [УЗЕЛ_ПРИСВАИВАНИЯ_ПЕРЕМЕННОЙ]
  cmp rax, 1
  jne .not_assign
    interpret_assign rcx, rbx
    ret
  .not_assign:

  check_node_type rbx, [УЗЕЛ_ПРИСВАИВАНИЯ_ССЫЛКИ_ПЕРЕМЕННОЙ]
  cmp rax, 1
  jne .not_assign_link
    interpret_assign_link rcx, rbx
    ret
  .not_assign_link:

  check_node_type rbx, [УЗЕЛ_ДОСТУПА_К_ПЕРЕМЕННОЙ]
  cmp rax, 1
  jne .not_access
    interpret_access rcx, rbx
    ret
  .not_access:

  check_node_type rbx, [УЗЕЛ_ДОСТУПА_К_ССЫЛКЕ_ПЕРЕМЕННОЙ]
  cmp rax, 1
  jne .not_access_link
    interpret_access_link rcx, rbx
    ret
  .not_access_link:

  check_node_type rbx, [УЗЕЛ_УНАРНОЙ_ОПЕРАЦИИ]
  cmp rax, 1
  jne .not_unary_operation
    interpret_unary_operation rcx, rbx
    ret
  .not_unary_operation:

  check_node_type rbx, [УЗЕЛ_БИНАРНОЙ_ОПЕРАЦИИ]
  cmp rax, 1
  jne .not_binary_operation
    interpret_binary_operation rcx, rbx
    ret
  .not_binary_operation:

  check_node_type rbx, [УЗЕЛ_НУЛЬ]
  cmp rax, 1
  jne .not_null
    interpret_null rcx, rbx
    ret
  .not_null:

  check_node_type rbx, [УЗЕЛ_ЧИСЛА]
  cmp rax, 1
  jne .not_number
    interpret_number rcx, rbx
    ret
  .not_number:

  check_node_type rbx, [УЗЕЛ_СПИСКА]
  cmp rax, 1
  jne .not_list
    interpret_list rcx, rbx
    ret
  .not_list:

  check_node_type rbx, [УЗЕЛ_СТРОКИ]
  cmp rax, 1
  jne .not_string
    interpret_string rcx, rbx
    ret
  .not_string:

  check_node_type rbx, [УЗЕЛ_СЛОВАРЯ]
  cmp rax, 1
  jne .not_dictionary
    interpret_dictionary rcx, rbx
    ret
  .not_dictionary:

  check_node_type rbx, [УЗЕЛ_ЕСЛИ]
  cmp rax, 1
  jne .not_if
    interpret_if rcx, rbx
    ret
  .not_if:

  check_node_type rbx, [УЗЕЛ_ПОКА]
  cmp rax, 1
  jne .not_while
    interpret_while rcx, rbx
    ret
  .not_while:

  check_node_type rbx, [УЗЕЛ_ДЛЯ]
  cmp rax, 1
  jne .not_for
    interpret_for rcx, rbx
    ret
  .not_for:

  check_node_type rbx, [УЗЕЛ_ПРОПУСКА]
  cmp rax, 1
  jne .not_skip
    interpret_skip rcx, rbx
    ret
  .not_skip:

  check_node_type rbx, [УЗЕЛ_ПРЕРЫВАНИЯ]
  cmp rax, 1
  jne .not_break
    interpret_break rcx, rbx
    ret
  .not_break:

  check_node_type rbx, [УЗЕЛ_ФУНКЦИИ]
  cmp rax, 1
  jne .not_function
    interpret_function rcx, rbx
    ret
  .not_function:

  check_node_type rbx, [УЗЕЛ_ВЫЗОВА]
  cmp rax, 1
  jne .not_call
    interpret_call rcx, rbx
    ret
  .not_call:

  string "Неизвестный узел:"
  mov rbx, rax
  list
  list_append_link rax, rbx
  list_append_link rax, rcx
  error rax
  exit -1

f_interpret_body:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  list
  mov rdx, rax

  integer 0
  mov r8, rax

  list_length rcx
  integer rax
  mov r9, rax

  .body_while:
    is_equal r9, r8
    boolean_value rax
    cmp rax, 1
    je .body_end_while

    list_get_link rcx, r8
    interpret rax, rbx
    mov r10, rax

    string "СИГНАЛ"
    mov r11, rax
    list
    access r11, rax
    mov r11, rax
    null
    is_equal r11, rax
    boolean_value rax
    cmp rax, 1
    je .no_signal

      is_equal r11, [СИГНАЛ_ПРОПУСКА]
      boolean_value rax
      cmp rax, 1
      je .clear_signal

      jmp .body_end_while

      .clear_signal:

      push r10
      string "СИГНАЛ"
      mov r10, rax
      null
      mov r11, rax
      list
      assign r10, rax, r11
      pop r10

      jmp .body_end_while

    .no_signal:

    list_append_link rdx, r10

    integer_inc r8
    jmp .body_while

  .body_end_while:

  mov rax, rdx
  ret

f_interpret_assign_link:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  string "значение"
  dictionary_get_link rcx, rax
  mov rdx, rax

  null
  is_equal rax, rdx
  boolean_value rax
  cmp rax, 1
  jne .use_exists_value

    string "Не передано значение в узел присваивания переменной"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .use_exists_value:

  interpret rdx, rbx
  mov r8, rax

  string "ключи"
  dictionary_get_link rcx, rax
  mov r9, rax
  string "элементы"
  dictionary_get_link r9, rax
  interpret rax, rbx
  mov r9, rax

  string "переменная"
  dictionary_get_link rcx, rax
  mov rcx, rax
  string "значение"
  dictionary_get_link rcx, rax

  assign_link rax, r9, r8
  ret

f_interpret_assign:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  string "значение"
  dictionary_get_link rcx, rax
  mov rdx, rax

  null
  is_equal rax, rdx
  boolean_value rax
  cmp rax, 1
  jne .use_exists_value

    string "Не передано значение в узел присваивания переменной"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .use_exists_value:

  interpret rdx, rbx
  mov r8, rax

  string "ключи"
  dictionary_get_link rcx, rax
  mov r9, rax
  string "элементы"
  dictionary_get_link r9, rax
  interpret rax, rbx
  mov r9, rax

  string "переменная"
  dictionary_get_link rcx, rax
  mov rcx, rax
  string "значение"
  dictionary_get_link rcx, rax

  assign rax, r9, r8
  ret

f_interpret_access_link:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  string "ключи"
  dictionary_get_link rcx, rax
  mov rdx, rax
  string "элементы"
  dictionary_get_link rdx, rax
  interpret rax, rbx
  mov rdx, rax

  string "переменная"
  dictionary_get_link rcx, rax
  mov rcx, rax
  string "значение"
  dictionary_get_link rcx, rax

  access_link rax, rdx
  ret

f_interpret_access:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  string "ключи"
  dictionary_get_link rcx, rax
  mov rdx, rax
  string "элементы"
  dictionary_get_link rdx, rax
  interpret rax, rbx
  mov rdx, rax

  string "переменная"
  dictionary_get_link rcx, rax
  mov rcx, rax
  string "значение"
  dictionary_get_link rcx, rax

  access rax, rdx
  ret

f_interpret_unary_operation:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  string "операнд"
  dictionary_get_link rcx, rax
  mov rdx, rax

  string "оператор"
  dictionary_get_link rcx, rax
  mov r8, rax

  string "не"
  token_check_keyword r8, rax
  cmp rax, 1
  jne .not_not
    interpret rdx, rbx
    boolean_not rax
    ret
  .not_not:

  token_check_type r8, [ТИП_ВЫЧИТАНИЕ]
  cmp rax, 1
  jne .not_negate
    interpret rdx, rbx
    integer_neg rax
    ret
  .not_negate:

  mov rcx, 0

  token_check_type r8, [ТИП_ИНКРЕМЕНТАЦИЯ]
  cmp rax, 1
  jne .correct_unary_operator

  mov rcx, 1

  token_check_type r8, [ТИП_ДЕКРЕМЕНТАЦИЯ]
  cmp rax, 1
  jne .correct_unary_operator

    string "Неизвестный оператор: "
    mov rbx, rax
    list
    list_append_link rax, rbx
    list_append_link rax, r8
    error rax
    exit -1

  .correct_unary_operator:

  string "переменная"
  dictionary_get_link rdx, rax
  mov r9, rax

  token_check_type r9, [ТИП_ИДЕНТИФИКАТОР]
  cmp rax, 1
  je .correct_identifier

    string "Ожидался идентификатор, но получен "
    mov rbx, rax
    list_append_link rax, rbx
    list_append_link rax, rdx
    error rax
    exit -1

  .correct_identifier:

  string "значение"
  dictionary_get_link r9, rax
  mov r9, rax

  string "ключи"
  dictionary_get_link rdx, rax
  mov r12, rax
  string "элементы"
  dictionary_get_link r12, rax

  access_link r9, rax
  mov r10, rax

  integer_copy rax
  mov r11, rax

  cmp rcx, 0
  je .not_inc
    integer_inc r10
    jmp .continue
  .not_inc:
    integer_dec r10
  .continue:

  string "ключи"
  dictionary_get_link rdx, rax
  mov r12, rax
  string "элементы"
  dictionary_get_link r12, rax

  assign_link r9, rax, r10

  string "значение"
  dictionary_get_link r8, rax
  boolean_value rax
  cmp rax, 1
  je @f
    cmp rcx, 0
    je .dec
      integer_inc r11
      jmp .continue_pre_operation
    .dec:
      integer_dec r11
    .continue_pre_operation:
  @@:

  mov rax, r11
  ret

f_interpret_binary_operation:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  string "левый_узел"
  dictionary_get_link rcx, rax
  interpret rax, rbx
  mov r8, rax

  string "правый_узел"
  dictionary_get_link rcx, rax
  interpret rax, rbx
  mov r9, rax

  string "оператор"
  dictionary_get_link rcx, rax
  mov rdx, rax

  string "и"
  token_check_keyword rdx, rax
  cmp rax, 1
  jne .not_and
    boolean_and r8, r9
    ret
  .not_and:

  string "или"
  cmp rax, 1
  token_check_keyword rdx, rax
  jne .not_or
    boolean_or r8, r9
    ret
  .not_or:

  string "тип"
  dictionary_get_link rdx, rax
  mov rdx, rax

  is_equal rdx, [ТИП_СЛОЖЕНИЕ]
  boolean_value rax
  cmp rax, 1
  jne .not_addition
    addition r8, r9
    ret
  .not_addition:

  is_equal rdx, [ТИП_ВЫЧИТАНИЕ]
  boolean_value rax
  cmp rax, 1
  jne .not_subtraction
    subtraction r8, r9
    ret
  .not_subtraction:

  is_equal rdx, [ТИП_УМНОЖЕНИЕ]
  boolean_value rax
  cmp rax, 1
  jne .not_multiplication
    multiplication r8, r9
    ret
  .not_multiplication:

  is_equal rdx, [ТИП_ДЕЛЕНИЕ]
  boolean_value rax
  cmp rax, 1
  jne .not_division
    division r8, r9
    ret
  .not_division:

  is_equal rdx, [ТИП_РАВНО]
  boolean_value rax
  cmp rax, 1
  jne .not_equal
    is_equal r8, r9
    ret
  .not_equal:

  is_equal rdx, [ТИП_НЕ_РАВНО]
  boolean_value rax
  cmp rax, 1
  jne .not_not_equal
    is_not_equal r8, r9
    ret
  .not_not_equal:

  is_equal rdx, [ТИП_МЕНЬШЕ]
  boolean_value rax
  cmp rax, 1
  jne .not_lower
    is_lower r8, r9
    ret
  .not_lower:

  is_equal rdx, [ТИП_БОЛЬШЕ]
  boolean_value rax
  cmp rax, 1
  jne .not_greater
    is_greater r8, r9
    ret
  .not_greater:

  is_equal rdx, [ТИП_МЕНЬШЕ_ИЛИ_РАВНО]
  boolean_value rax
  cmp rax, 1
  jne .not_lower_or_equal
    is_lower_or_equal r8, r9
    ret
  .not_lower_or_equal:

  is_equal rdx, [ТИП_БОЛЬШЕ_ИЛИ_РАВНО]
  boolean_value rax
  cmp rax, 1
  jne .not_greater_or_equal
    is_greater_or_equal r8, r9
    ret
  .not_greater_or_equal:

  string "Неизвестный оператор: "
  mov rbx, rax
  list
  list_append_link rax, rbx
  list_append_link rax, rcx
  error rax
  exit -1

f_interpret_null:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  null
  ret

f_interpret_number:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  string "значение"
  dictionary_get_link rcx, rax
  mov rcx, rax

  string "тип"
  dictionary_get_link rcx, rax
  is_equal rax, [ТИП_ЦЕЛОЕ_ЧИСЛО]
  boolean_value rax
  cmp rax, 1
  je .correct_value
    string "Ожидалось целое число"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .correct_value:

  string "значение"
  dictionary_get_link rcx, rax
  string_to_integer rax
  ret

f_interpret_list:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  string "элементы"
  dictionary_get_link rcx, rax
  mov rcx, rax

  list_length rcx
  integer rax
  mov rdx, rax

  integer 0
  mov r8, rax

  list
  mov r9, rax

  .while:

    is_equal rdx, r8
    boolean_value rax
    cmp rax, 1
    je .end_while

    list_get_link rcx, r8
    interpret rax, rbx
    list_append_link r9, rax

    integer_inc r8
    jmp .while

  .end_while:

  mov rax, r9
  ret

f_interpret_string:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  string "значение"
  dictionary_get_link rcx, rax
  mov rcx, rax

  string ""
  mov rdx, rax

  integer 0
  mov r8, rax

  list_length rcx
  integer rax
  mov r9, rax

  @@:

    is_equal r8, r9
    boolean_value rax
    cmp rax, 1
    je @f

    list_get_link rcx, r8
    mov r10, rax

    mov rax, [r10]
    cmp rax, STRING
    je .continue

      push [индекс], [АСД]
      interpret r10, rbx
      mov r10, rax

      mov rax, [r10]
      cmp rax, STRING
      je .string

        to_string r10
        mov r10, rax

      .string:

      pop rax
      mov [АСД], rax

      pop rax
      mov [индекс], rax

    .continue:

    string_extend_links rdx, r10

    integer_inc r8
    jmp @b

  @@:

  mov rax, rdx
  ret

f_interpret_dictionary:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  string "элементы"
  dictionary_get_link rcx, rax

  interpret rax, rbx
  dictionary_from_items rax

  ret

f_interpret_if:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  string "случаи"
  dictionary_get_link rcx, rax
  mov rdx, rax

  list_length rdx
  integer rax
  mov r8, rax

  integer 0
  mov r9, rax

  mov r10, 0

  .while:

    is_equal r8, r9
    boolean_value rax
    cmp rax, 1
    je .end_while

    list_get_link rdx, r9
    mov r11, rax

    integer_inc r9

    string "условие"
    dictionary_get_link r11, rax
    interpret rax, rbx

    boolean rax
    boolean_value rax

    cmp rax, 1
    jne .while

    string "тело"
    dictionary_get_link r11, rax

    interpret rax, rbx
    mov r10, 1

  .end_while:

  cmp r10, 0
  jne .skip_else

    string "случай_иначе"
    dictionary_get_link rcx, rax, r10
    interpret rax, rbx

  .skip_else:

  ret

f_interpret_while:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  push rcx
  string "НОМЕР_ТЕКУЩЕГО_ЦИКЛА"
  mov rcx, rax
  list
  access_link rcx, rax
  integer_inc rax
  pop rcx

  string "условие"
  dictionary_get_link rcx, rax
  mov rdx, rax

  interpret rdx, rbx
  boolean rax
  boolean_value rax
  cmp rax, 1
  je .loop

    string "НОМЕР_ТЕКУЩЕГО_ЦИКЛА"
    mov rdx, rax
    list
    access_link rdx, rax
    integer_dec rax

    string "случай_иначе"
    dictionary_get_link rcx, rax
    interpret rax, rbx

    ret

  .loop:

  string "тело"
  dictionary_get_link rcx, rax
  mov r8, rax

  list
  mov r9, rax

  .while:
    interpret r8, rbx
    list_append_link r9, rax

    string "СИГНАЛ"
    mov r11, rax
    list
    access r11, rax
    mov r11, rax
    null
    is_equal r11, rax
    boolean_value rax
    cmp rax, 1
    je .no_signal

      is_equal r11, [СИГНАЛ_ПРЕРЫВАНИЯ]
      boolean_value rax
      cmp rax, 1
      je .clear_signal

      mov rax, LIST
      cmp [r11], rax
      je .clear_signal

      jmp .end_while

      .clear_signal:

      push r10
      string "СИГНАЛ"
      mov r10, rax
      null
      mov r11, rax
      list
      assign r10, rax, r11
      pop r10

      jmp .end_while

    .no_signal:

  interpret rdx, rbx
  boolean rax
  boolean_value rax
  cmp rax, 1
  je .while

  .end_while:

  string "НОМЕР_ТЕКУЩЕГО_ЦИКЛА"
  mov rcx, rax
  list
  access_link rcx, rax
  integer_dec rax

  mov rax, r9
  ret

f_interpret_for:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  push rcx
  string "НОМЕР_ТЕКУЩЕГО_ЦИКЛА"
  mov rcx, rax
  list
  access_link rcx, rax
  integer_inc rax
  pop rcx

  string "переменная"
  dictionary_get_link rcx, rax
  mov rdx, rax
  string "значение"
  dictionary_get_link rdx, rax
  mov rdx, rax

  string "начало"
  dictionary_get_link rcx, rax
  interpret rax, rbx
  mov r8, rax

  string "конец"
  dictionary_get_link rcx, rax
  mov r9, rax

  null
  is_equal r9, rax
  boolean_value rax
  cmp rax, 1
  je .entry_loop

    interpret r9, rbx
    mov r9, rax

    string "шаг"
    dictionary_get_link rcx, rax
    mov r10, rax

    null
    is_equal r10, rax
    boolean_value rax
    cmp rax, 1
    jne .not_default_step
      integer 1
      jmp .continue
    .not_default_step:
      interpret r10, rbx
    .continue:

    mov r10, rax

    is_equal r8, r9
    boolean_value rax
    cmp rax, 1
    je .else

    is_lower r8, r9
    boolean_value rax
    mov r13, rax
    cmp rax, 1
    jne @f

      integer 0
      is_greater rax, r10
      boolean_value rax
      cmp rax, 1
      je .else

      jmp .all_is_fine

    @@:

      integer 0
      is_lower rax, r10
      boolean_value rax
      cmp rax, 1
      je .else

    .all_is_fine:

    list
    mov r11, rax

    list
    assign rdx, rax, r8

    string "тело"
    dictionary_get_link rcx, rax
    mov r12, rax

    .generator_while:

      interpret r12, rbx
      list_append_link r11, rax

      string "СИГНАЛ"
      mov r14, rax
      list
      access r14, rax
      mov r14, rax
      null
      is_equal r14, rax
      boolean_value rax
      cmp rax, 1
      je .generator_no_signal

        is_equal r14, [СИГНАЛ_ПРЕРЫВАНИЯ]
        boolean_value rax
        cmp rax, 1
        je .generator_clear_signal

        mov rax, LIST
        cmp [r14], rax
        je .generator_clear_signal

        jmp .generator_end_while

        .generator_clear_signal:

        push r10
        string "СИГНАЛ"
        mov r10, rax
        null
        mov r14, rax
        list
        assign r10, rax, r14
        pop r10

        jmp .generator_end_while

      .generator_no_signal:

      list
      access rdx, rax
      addition r8, r10
      mov r8, rax

      cmp r13, 1
      jne @f
        is_lower r8, r9
        jmp .next
      @@:
        is_greater r8, r9
      .next:
      boolean_value rax
      cmp rax, 1
      jne .generator_end_while

      list
      assign rdx, rax, r8

      jmp .generator_while

    .generator_end_while:

    mov rax, r11
    jmp .end

  .entry_loop:

    mov rax, LIST
    cmp [r8], rax
    je .correct_type
    mov rax, STRING
    cmp [r8], rax
    je .correct_type

      string "Ожидался тип Список или Строка"
      mov rbx, rax
      list
      list_append_link rax, rbx
      error rax
      exit -1

    .correct_type:

    integer 0
    mov r9, rax

    collection_length r8
    cmp rax, 0
    je .else

    integer rax
    mov r10, rax

    string "тело"
    dictionary_get_link rcx, rax
    mov r11, rax

    list
    mov r12, rax

    .entry_while:

      is_equal r9, r10
      boolean_value rax
      cmp rax, 1
      je .entry_end_while

      mov rax, LIST
      cmp [r8], rax
      jne @f
        list_get_link r8, r9
        jmp .item_gotten
      @@:
      mov rax, STRING
      cmp [r8], rax
      jne @f
        string_get_link r8, r9
        jmp .item_gotten
      @@:

      .item_gotten:
      mov r13, rax

      list
      assign rdx, rax, r13

      interpret r11, rbx
      list_append_link r12, rax

      string "СИГНАЛ"
      mov r14, rax
      list
      access r14, rax
      mov r14, rax
      null
      is_equal r14, rax
      boolean_value rax
      cmp rax, 1
      je .entry_no_signal

        is_equal r14, [СИГНАЛ_ПРЕРЫВАНИЯ]
        boolean_value rax
        cmp rax, 1
        je .entry_clear_signal

        mov rax, LIST
        cmp [r14], rax
        je .entry_clear_signal

        jmp .entry_end_while

        .entry_clear_signal:

        push r10
        string "СИГНАЛ"
        mov r10, rax
        null
        mov r14, rax
        list
        assign r10, rax, r14
        pop r10

        jmp .entry_end_while

      .entry_no_signal:

      integer_inc r9
      jmp .entry_while

    .entry_end_while:

    mov rax, r12
    jmp .end

  .else:

    string "НОМЕР_ТЕКУЩЕГО_ЦИКЛА"
    mov rcx, rax
    list
    access_link rcx, rax
    integer_dec rax

    string "случай_иначе"
    dictionary_get_link rcx, rax
    interpret rax, rbx

  .end:

  mov rbx, rax

  string "НОМЕР_ТЕКУЩЕГО_ЦИКЛА"
  mov rcx, rax
  list
  access_link rcx, rax
  integer_dec rax

  mov rax, rbx
  ret

f_interpret_skip:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  list
  mov rdx, rax

  string "НОМЕР_ТЕКУЩЕГО_ЦИКЛА"
  mov r8, rax
  list
  access r8, rax
  mov r8, rax

  integer 0
  is_equal r8, rax
  boolean_value rax
  cmp rax, 1
  jne .in_loop

    string "`пропустить` может использоваться только внутри операторов"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .in_loop:

  string "СИГНАЛ"
  mov r8, rax
  list
  assign r8, rax, [СИГНАЛ_ПРОПУСКА]

  null
  ret

f_interpret_break:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  list
  mov rdx, rax

  string "НОМЕР_ТЕКУЩЕГО_ЦИКЛА"
  mov r8, rax
  list
  access r8, rax
  mov r8, rax

  integer 0
  is_equal r8, rax
  boolean_value rax
  cmp rax, 1
  jne .in_loop

    string "`прервать` может использоваться только внутри операторов"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .in_loop:

  string "СИГНАЛ"
  mov r8, rax
  list
  assign r8, rax, [СИГНАЛ_ПРЕРЫВАНИЯ]

  null
  ret

f_interpret_function:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  exit 21

  list
  mov rdx, rax

  string "СЧЁТЧИК_ФУНКЦИЙ"
  mov r8, rax
  list
  mov r9, rax
  access r8, r9
  integer_inc rax
  assign r8, r9, rax
  to_string rax
  mov r8, rax

  string "jmp .skip_function_"
  string_extend_links rax, r8
  list_append_link rdx, rax

  string ".function_"
  string_extend rax, r8
  mov r9, rax
  string ":"
  string_extend_links r9, rax
  list_append_link rdx, rax

  string "тело"
  dictionary_get_link rcx, rax
  interpret rax, rbx
  list_extend_links rdx, rax

  add_code "ret"

  string ".skip_function_"
  string_extend_links rax, r8
  mov r9, rax
  string ":"
  string_extend_links r9, rax
  list_append_link rdx, rax

  add_code "push r9, r8, rdx, rcx, rbx"

  string "string "
  mov r9, rax

  dictionary_get_link rcx, [переменная]
  dictionary_get_link rax, [значение]
  to_string rax
  string_extend_links r9, rax

  list_append_link rdx, rax
  add_code "mov rbx, rax"

  string "mov rcx, "
  mov r9, rax
  string ".function_"
  string_extend_links r9, rax
  string_extend_links rax, r8
  list_append_link rdx, rax

  add_code "list",\
           "mov rdx, rax",\
           "dictionary",\
           "mov r8, rax"

  ; Был ли встречен именованный аргумент
  mov r8, 0

  string "аргументы"
  dictionary_get_link rcx, rax
  mov r9, rax

  integer 0
  mov r10, rax

  list_length r9
  integer rax
  mov r11, rax

  ; Порог типа
  mov r12, 0
  push 0

  .while:
    is_equal r10, r11
    boolean_value rax
    cmp rax, 1
    je .end_while

    list_get_link r9, r10
    mov r13, rax

    check_node_type r13, [УЗЕЛ_ДОСТУПА_К_ПЕРЕМЕННОЙ]
    cmp rax, 1
    je .correct_argument

    check_node_type r13, [УЗЕЛ_ПРИСВАИВАНИЯ_ПЕРЕМЕННОЙ]
    cmp rax, 1
    je .positional_argument

      string "Ожидался позиционный или именованный аргумент"
      mov rbx, rax
      list
      list_append_link rax, rbx
      error rax
      exit -1

    .positional_argument:
      mov r8, 2

    .correct_argument:

    dictionary_get_link r13, [ключи]
    dictionary_get_link rax, [элементы]
    list_length rax
    cmp rax, 0
    je .no_keys

      string "У объявляемого аргумента не должно быть ключей"
      mov rbx, rax
      list
      list_append_link rax, rbx
      error rax
      exit -1

    .no_keys:

    dictionary_get_link r13, [переменная]
    dictionary_get_link rax, [значение]
    mov r14, rax
    integer -1
    string_get_link r14, rax
    mov r14, rax

    string "*"
    is_equal r14, rax
    boolean_value rax
    cmp rax, 1
    jne .not_accumulator

      pop rax
      inc rax
      push rax

      mov r8, 1

      dictionary_get_link r13, [переменная]
      dictionary_get_link rax, [значение]
      mov r14, rax
      integer -2
      string_get_link r14, rax
      mov r14, rax

      string "*"
      is_equal r14, rax
      boolean_value rax
      cmp rax, 1
      jne .not_accumulator

      pop rax
      inc rax
      push rax

      mov r8, 3

    .not_accumulator:

    cmp r8, r12
    jge .correct_sequence

      string "Нарушена очерёдность типов аргументов"
      mov rbx, rax
      list
      list_append_link rax, rbx
      error rax
      exit -1

    .correct_sequence:

    cmp r8, 0
    jne .not_positional_argument

      string "string "
      mov r14, rax

      dictionary_get_link r13, [переменная]
      dictionary_get_link rax, [значение]
      to_string rax
      string_extend_links r14, rax
      list_append_link rdx, rax

      string "list_append_link rdx, rax"
      list_append_link rdx, rax

      jmp .continue

    .not_positional_argument:

    cmp r8, 1
    jne .not_positional_accumulator

      cmp r12, r8
      jne .not_positional_accumulator_doublicate

        string "Аккумулятор позиционных аргументов уже был объявлен"
        mov rbx, rax
        list
        list_append_link rax, rbx
        error rax
        exit -1

      .not_positional_accumulator_doublicate:

      check_node_type r13, [УЗЕЛ_ПРИСВАИВАНИЯ_ПЕРЕМЕННОЙ]
      cmp rax, 1
      jne .correct_positional_accumulator

        string "Аккумулятор позиционных аргументов не может иметь значения по умолчанию"
        mov rbx, rax
        list
        list_append_link rax, rbx
        error rax
        exit -1

      .correct_positional_accumulator:

      string "string "
      mov r14, rax

      dictionary_get_link r13, [переменная]
      dictionary_get_link rax, [значение]
      to_string rax
      string_extend_links r14, rax
      list_append_link rdx, rax

      string "list_append_link rdx, rax"
      list_append_link rdx, rax

      jmp .continue

    .not_positional_accumulator:

    cmp r8, 2
    jne .not_named_argument

      check_node_type r13, [УЗЕЛ_ПРИСВАИВАНИЯ_ПЕРЕМЕННОЙ]
      cmp rax, 1
      je .correct_named_argument

        string "Ожидался именованный аргумент"
        mov rbx, rax
        list
        list_append_link rax, rbx
        error rax
        exit -1

      .correct_named_argument:

      string "string "
      mov r14, rax

      dictionary_get_link r13, [переменная]
      dictionary_get_link rax, [значение]
      to_string rax
      string_extend_links r14, rax
      list_append_link rdx, rax

      add_code "mov r9, rax",\
               "list_append_link rdx, r9"

      dictionary_get_link r13, [значение]
      interpret rax, rbx
      list_extend_links rdx, rax

      add_code "dictionary_set_link r8, r9, rax"

      jmp .continue

    .not_named_argument:

    cmp r8, 3
    jne .not_named_accumulator

      cmp r12, r8
      jne .not_named_accumulator_doublicate

        string "Аккумулятор именованных аргументов уже был объявлен"
        mov rbx, rax
        list
        list_append_link rax, rbx
        error rax
        exit -1

      .not_named_accumulator_doublicate:

      check_node_type r13, [УЗЕЛ_ПРИСВАИВАНИЯ_ПЕРЕМЕННОЙ]
      cmp rax, 1
      jne .correct_named_accumulator

        string "Аккумулятор именованных аргументов не может иметь значения по умолчанию"
        mov rbx, rax
        list
        list_append_link rax, rbx
        error rax
        exit -1

      .correct_named_accumulator:

      string "string "
      mov r14, rax

      dictionary_get_link r13, [переменная]
      dictionary_get_link rax, [значение]
      to_string rax
      string_extend_links r14, rax
      list_append_link rdx, rax

      add_code "list_append_link rdx, rax"

      jmp .continue

    .not_named_accumulator:

    ; а *а а=0 **а
    ; а *а а=0
    ; а *а     **а
    ; а *а
    ; а    а=0 **а
    ; а    а=0
    ; а        **а
    ; а
    ;   *а а=0 **а
    ;   *а а=0
    ;   *а     **а
    ;   *а
    ;      а=0 **а
    ;      а=0
    ;          **а
    ;

    string "Что-то пошло не так. Аргументы считаны некорректно"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

    .continue:

    mov r12, r8
    integer_inc r10

    jmp .while

  .end_while:

  string "function rbx, rcx, rdx, r8, "
  mov r8, rax

  pop rax
  integer rax
  to_string rax
  string_extend_links r8, rax
  list_append_link rdx, rax

  add_code "mov rcx, rax",\
           "list",\
           "assign rbx, rax, rcx",\
           "pop rbx, rcx, rdx, r8, r9"

  mov rax, rdx
  ret

f_interpret_call:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  string "переменная"
  dictionary_get_link rcx, rax
  interpret rax, rbx
  mov r8, rax

  string "аргументы"
  dictionary_get_link rcx, rax
  list_node rax
  interpret rax, rbx
  mov r9, rax

  dictionary_get_link rcx, [именованные_аргументы]
  list_node rax
  dictionary_node rax
  interpret rax, rbx
  mov r10, rax

  function_call r8, r9, r10

  ret
