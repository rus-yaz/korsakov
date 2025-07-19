; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

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

macro interpret_integer node*, context* {
  debug_start "interpret_integer"
  enter node, context

  call f_interpret_integer

  return
  debug_end "interpret_integer"
}

macro interpret_float node*, context* {
  debug_start "interpret_float"
  enter node, context

  call f_interpret_float

  return
  debug_end "interpret_float"
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

macro interpret_return node*, context* {
  debug_start "interpret_return"
  enter node, context

  call f_interpret_return

  return
  debug_end "interpret_return"
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
  jne @f
    interpret_body rcx, rbx
    ret
  @@:

  check_node_type rbx, [УЗЕЛ_ПРИСВАИВАНИЯ_ПЕРЕМЕННОЙ]
  cmp rax, 1
  jne @f
    interpret_assign rcx, rbx
    ret
  @@:

  check_node_type rbx, [УЗЕЛ_ПРИСВАИВАНИЯ_ССЫЛКИ_ПЕРЕМЕННОЙ]
  cmp rax, 1
  jne @f
    interpret_assign_link rcx, rbx
    ret
  @@:

  check_node_type rbx, [УЗЕЛ_ДОСТУПА_К_ПЕРЕМЕННОЙ]
  cmp rax, 1
  jne @f
    interpret_access rcx, rbx
    ret
  @@:

  check_node_type rbx, [УЗЕЛ_ДОСТУПА_К_ССЫЛКЕ_ПЕРЕМЕННОЙ]
  cmp rax, 1
  jne @f
    interpret_access_link rcx, rbx
    ret
  @@:

  check_node_type rbx, [УЗЕЛ_УНАРНОЙ_ОПЕРАЦИИ]
  cmp rax, 1
  jne @f
    interpret_unary_operation rcx, rbx
    ret
  @@:

  check_node_type rbx, [УЗЕЛ_БИНАРНОЙ_ОПЕРАЦИИ]
  cmp rax, 1
  jne @f
    interpret_binary_operation rcx, rbx
    ret
  @@:

  check_node_type rbx, [УЗЕЛ_НУЛЬ]
  cmp rax, 1
  jne @f
    interpret_null rcx, rbx
    ret
  @@:

  check_node_type rbx, [УЗЕЛ_ЦЕЛОГО_ЧИСЛА]
  cmp rax, 1
  jne @f
    interpret_integer rcx, rbx
    ret
  @@:

  check_node_type rbx, [УЗЕЛ_ВЕЩЕСТВЕННОГО_ЧИСЛА]
  cmp rax, 1
  jne @f
    interpret_float rcx, rbx
    ret
  @@:

  check_node_type rbx, [УЗЕЛ_СПИСКА]
  cmp rax, 1
  jne @f
    interpret_list rcx, rbx
    ret
  @@:

  check_node_type rbx, [УЗЕЛ_СТРОКИ]
  cmp rax, 1
  jne @f
    interpret_string rcx, rbx
    ret
  @@:

  check_node_type rbx, [УЗЕЛ_СЛОВАРЯ]
  cmp rax, 1
  jne @f
    interpret_dictionary rcx, rbx
    ret
  @@:

  check_node_type rbx, [УЗЕЛ_ЕСЛИ]
  cmp rax, 1
  jne @f
    interpret_if rcx, rbx
    ret
  @@:

  check_node_type rbx, [УЗЕЛ_ПОКА]
  cmp rax, 1
  jne @f
    interpret_while rcx, rbx
    ret
  @@:

  check_node_type rbx, [УЗЕЛ_ДЛЯ]
  cmp rax, 1
  jne @f
    interpret_for rcx, rbx
    ret
  @@:

  check_node_type rbx, [УЗЕЛ_ПРОПУСКА]
  cmp rax, 1
  jne @f
    interpret_skip rcx, rbx
    ret
  @@:

  check_node_type rbx, [УЗЕЛ_ПРЕРЫВАНИЯ]
  cmp rax, 1
  jne @f
    interpret_break rcx, rbx
    ret
  @@:

  check_node_type rbx, [УЗЕЛ_ФУНКЦИИ]
  cmp rax, 1
  jne @f
    interpret_function rcx, rbx
    ret
  @@:

  check_node_type rbx, [УЗЕЛ_ВЫЗОВА]
  cmp rax, 1
  jne @f
    interpret_call rcx, rbx
    ret
  @@:

  check_node_type rbx, [УЗЕЛ_ВОЗВРАЩЕНИЯ]
  cmp rax, 1
  jne @f
    interpret_return rcx, rbx
    ret
  @@:

  string "Неизвестный узел:"
  mov rcx, rax
  list
  list_append_link rax, rcx
  list_append_link rax, rbx
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

    mov r11, [СИГНАЛ]
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

      null
      mov [СИГНАЛ], rax

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
    negate rax
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

f_interpret_integer:
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

f_interpret_float:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  string "значение"
  dictionary_get_link rcx, rax
  mov rcx, rax

  string "тип"
  dictionary_get_link rcx, rax
  is_equal rax, [ТИП_ВЕЩЕСТВЕННОЕ_ЧИСЛО]
  boolean_value rax
  cmp rax, 1
  je .correct_value
    string "Ожидалось вещественное число"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .correct_value:

  string "значение"
  dictionary_get_link rcx, rax
  string_to_float rax
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
  dictionary_from_pairs rax

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
    mov r11, rax

    mov r10, 1

  .end_while:

  cmp r10, 0
  jne .skip_else

    string "случай_иначе"
    dictionary_get_link rcx, rax, r10
    interpret rax, rbx
    mov r11, rax

  .skip_else:

  list_length r11
  cmp rax, 0
  jne @f
    null
    ret
  @@:

  integer -1
  list_get_link r11, rax

  ret

f_interpret_while:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  mov rax, [НОМЕР_ТЕКУЩЕГО_ЦИКЛА]
  integer_inc rax

  string "условие"
  dictionary_get_link rcx, rax
  mov rdx, rax

  interpret rdx, rbx
  boolean rax
  boolean_value rax
  cmp rax, 1
  je .loop

    mov rax, [НОМЕР_ТЕКУЩЕГО_ЦИКЛА]
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

    mov r11, [СИГНАЛ]
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

      null
      mov [СИГНАЛ], rax

      jmp .end_while

    .no_signal:

  interpret rdx, rbx
  boolean rax
  boolean_value rax
  cmp rax, 1
  je .while

  .end_while:

  mov rax, [НОМЕР_ТЕКУЩЕГО_ЦИКЛА]
  integer_dec rax

  mov rax, r9
  ret

f_interpret_for:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  mov rax, [НОМЕР_ТЕКУЩЕГО_ЦИКЛА]
  integer_inc rax

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

      mov r14, [СИГНАЛ]
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

        null
        mov [СИГНАЛ], rax

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
    je .is_list
    mov rax, STRING
    cmp [r8], rax
    je .is_string

      string "Ожидался тип Список или Строка"
      mov rbx, rax
      list
      list_append_link rax, rbx
      error rax
      exit -1

    .is_list:
      list_length r8
      jmp @f
    .is_string:
      string_length r8
    @@:

    cmp rax, 0
    je .else

    integer 0
    mov r9, rax

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

      mov r14, [СИГНАЛ]
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

        null
        mov [СИГНАЛ], rax
        jmp .entry_end_while

      .entry_no_signal:

      integer_inc r9
      jmp .entry_while

    .entry_end_while:

    mov rax, r12
    jmp .end

  .else:

    mov rax, [НОМЕР_ТЕКУЩЕГО_ЦИКЛА]
    integer_dec rax

    string "случай_иначе"
    dictionary_get_link rcx, rax
    interpret rax, rbx

  .end:

  mov rbx, rax

  mov rax, [НОМЕР_ТЕКУЩЕГО_ЦИКЛА]
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

  mov r8, [НОМЕР_ТЕКУЩЕГО_ЦИКЛА]
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

  mem_mov [СИГНАЛ], [СИГНАЛ_ПРОПУСКА]

  null
  ret

f_interpret_break:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  list
  mov rdx, rax

  mov r8, [НОМЕР_ТЕКУЩЕГО_ЦИКЛА]
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

  mem_mov [СИГНАЛ], [СИГНАЛ_ПРЕРЫВАНИЯ]

  null
  ret

f_interpret_function:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  string "переменная"
  dictionary_get_link rcx, rax
  mov r8, rax
  string "значение"
  dictionary_get_link r8, rax
  mov r8, rax

  string "тело"
  dictionary_get_link rcx, rax
  mov r9, rax

  list
  mov r10, rax

  dictionary
  mov r11, rax

  string "аргументы"
  dictionary_get_link rcx, rax
  mov r12, rax

  list_length r12
  mov r13, rax

  mov r14, 0 ; Счётчик
  mov rdx, 0 ; Аккумуляторы

  .while:

    cmp r13, r14
    je .end_while

    integer r14
    list_get_link r12, rax
    mov r15, rax

    mov rdi, 0 ; Значение именованного аргумента

    string "узел"
    dictionary_get_link r15, rax
    is_equal rax, [УЗЕЛ_ПРИСВАИВАНИЯ_ПЕРЕМЕННОЙ]
    boolean_value rax
    cmp rax, 1
    jne .not_named

      string "значение"
      dictionary_get_link r15, rax
      mov rdi, rax

    .not_named:

    string "переменная"
    dictionary_get_link r15, rax
    mov r15, rax
    string "значение"
    dictionary_get_link r15, rax
    mov r15, rax

    string "**"
    string_include r15, rax
    boolean_value rax
    cmp rax, 1
    jne .not_named_accumulator
      push rdx
      and rdx, 0x10
      cmp rdx, 0
      jl .too_many_named_accumulators
        raw_string "Неверное количество аккумуляторов именованных аргументов"
        error_raw rax
        exit -1
      .too_many_named_accumulators:
      pop rdx

      add rdx, 2
      jmp .continue
    .not_named_accumulator:

    string "*"
    string_include r15, rax
    boolean_value rax
    cmp rax, 1
    jne .not_positional_accumulator
      push rdx
      and rdx, 0x01
      cmp rdx, 0
      jl .too_many_positional_accumulators
        raw_string "Неверное количество аккумуляторов позиционных аргументов"
        error_raw rax
        exit -1
      .too_many_positional_accumulators:
      pop rdx

      inc rdx
      jmp .continue
    .not_positional_accumulator:

    cmp rdi, 0
    je @f
      interpret rdi, rbx
      dictionary_set_link r11, r15, rax
    @@:

    .continue:

    list_append_link r10, r15

    inc r14
    jmp .while

  .end_while:

  function r8, r9, r10, r11, rdi
  mov r9, rax

  list
  assign r8, rax, r9
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

  string "именованные_аргументы"
  dictionary_get_link rcx, rax
  list_node rax
  dictionary_node rax
  interpret rax, rbx
  mov r10, rax

  check_type r8, FUNCTION
  check_type r9, LIST
  check_type r10, DICTIONARY

  mov rax, [r8 + 8*6]
  cmp rax, 1
  jne .not_internal

    function_call r8, r9, r10

    ret

  .not_internal:

  dictionary_copy_links rbx
  mov r15, rax

  mov rax, r8
  mov r8,  r9
  mov r9,  r10

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

    error rax
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

    error rax
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
  jne .external

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
      access_link r9, rax
      push rax

      jmp .while

    .end_while:

  .external:

  interpret rbx, r15
  mov r8, rax

  is_equal [СИГНАЛ], [СИГНАЛ_ВОЗВРАЩЕНИЯ]
  boolean_value rax
  cmp rax, 1
  jne .return_last

    null
    mov [СИГНАЛ], rax

  .return_last:

  integer -1
  list_get_link r8, rax
  ret

f_interpret_return:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  string "значение"
  dictionary_get_link rcx, rax
  mov r8, rax

  null
  is_equal rax, r8
  boolean_value rax
  cmp rax, 1
  je @f
    interpret r8, rbx
    ret
  @@:

  mem_mov [СИГНАЛ], [СИГНАЛ_ВОЗВРАЩЕНИЯ]
  null
  ret
