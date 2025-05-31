; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

section "data" writable
  try dq 0

  CLOSED_PAREN         db "`)`", 0
  COLON                db "`:`", 0
  OPEN_PAREN           db "`(`", 0
  SPACE                db "` `", 0
  FROM_KEYWORD         db "`от`", 0
  OF                   db "`из`", 0
  OPEN_LIST_PAREN      db "`%(`", 0
  THEN                 db "`то`", 0
  TO                   db "`до`", 0
  FOR                  db "`для`", 0
  ON_KEYWORD           db "`при`", 0
  IF_KEYWORD           db "`если`", 0
  LIST_TYPE_NAME       db "список", 0
  STRING_TYPE_NAME     db "строка", 0
  WHILE_KEYWORD        db "`пока`", 0
  DELETE               db "`удалить`", 0
  FUNCTION_KEYWORD     db "`функция`", 0
  INCLUDE_KEYWORD      db "`включить`", 0
  CHECK                db "`проверить`", 0
  INTEGER_TYPE_NAME    db "целое число", 0
  IDENTIFIER           db "идентификатор", 0
  KEYWORD              db "ключевое слово", 0
  NEWLINE              db "перенос строки", 0
  COMPARISON_OPERATOR  db "оператор сравнения", 0
  FLOAT_TYPE_NAME      db "вещественное число", 0

section "parser" executable

macro parser tokens* {
  debug_start "parser"
  enter tokens

  call f_parser

  return
  debug_end "parser"
}

macro next {
  debug_start "next"
  enter

  call f_next

  return
  debug_end "next"
}

macro skip_newline {
  debug_start "skip_newline"
  enter

  call f_skip_newline

  return
  debug_end "skip_newline"
}

macro revert amount = 0 {
  debug_start "revert"
  enter amount

  call f_revert

  return
  debug_end "revert"
}

macro update_token {
  debug_start "update_token"
  enter

  call f_update_token

  leave
  debug_end "update_token"
}

macro expression {
  debug_start "expression"
  enter

  call f_expression

  return
  debug_end "expression"
}

macro binary_operation operators*, left_function*, right_function = 0 {
  debug_start "binary_operation"
  enter operators, left_function, right_function

  call f_binary_operation

  return
  debug_end "binary_operation"
}

macro atom {
  debug_start "atom"
  enter

  call f_atom

  return
  debug_end "atom"
}

macro call_expression {
  debug_start "call_expression"
  enter

  call f_call_expression

  return
  debug_end "call_expression"
}

macro power_root {
  debug_start "power_root"
  enter

  call f_power_root

  return
  debug_end "power_root"
}

macro factor {
  debug_start "factor"
  enter

  call f_factor

  return
  debug_end "factor"
}

macro term {
  debug_start "term"
  enter

  call f_term

  return
  debug_end "term"
}

macro comparison_expression {
  debug_start "comparison_expression"
  enter

  call f_comparison_expression

  return
  debug_end "comparison_expression"
}

macro arithmetical_expression {
  debug_start "arithmetical_expression"
  enter

  call f_arithmetical_expression

  return
  debug_end "arithmetical_expression"
}

macro list_expression {
  debug_start "list_expression"
  enter

  call f_list_expression

  return
  debug_end "list_expression"
}

macro check_expression {
  debug_start "check_expression"
  enter

  call f_check_expression

  return
  debug_end "check_expression"
}

macro if_expression {
  debug_start "if_expression"
  enter

  call f_if_expression

  return
  debug_end "if_expression"
}

macro else_expression {
  debug_start "else_expression"
  enter

  call f_else_expression

  return
  debug_end "else_expression"
}

macro for_expression {
  debug_start "for_expression"
  enter

  call f_for_expression

  return
  debug_end "for_expression"
}

macro while_expression {
  debug_start "while_expression"
  enter

  call f_while_expression

  return
  debug_end "while_expression"
}

macro function_expression is_method = 0 {
  debug_start "function_expression"
  enter is_method

  call f_function_expression

  return
  debug_end "function_expression"
}

macro class_expression {
  debug_start "class_expression"
  enter

  call f_class_expression

  return
  debug_end "class_expression"
}

macro delete_expression {
  debug_start "delete_expression"
  enter

  call f_delete_expression

  return
  debug_end "delete_expression"
}

macro include_statement {
  debug_start "include_statement"
  enter

  call f_include_statement

  return
  debug_end "include_statement"
}

macro statement {
  debug_start "statement"
  enter

  call f_statement

  return
  debug_end "statement"
}

f_parser:
  get_arg 0
  check_type rax, LIST

  ; Инициализация
  mov [токены], rax

  integer 0
  mov [индекс], rax

  next
  skip_newline

  ; self.parse
  list
  mov rbx, rax

  .while:
    token_check_type [токен], [ТИП_КОНЕЦ_ФАЙЛА]
    cmp rax, 1
    je .end_while

    statement
    list_append_link rbx, rax

    next

    jmp .while

  .end_while:

  mov rax, rbx
  ret

f_next:
  mov rbx, [индекс]
  mov rbx, [rbx + INTEGER_HEADER*8]

  list_length [токены]
  cmp rax, rbx
  jl .continue
    list_get_link [токены], [индекс]
    mov [токен], rax

  .continue:

  integer_inc [индекс]

  mov rax, [индекс]
  ret

f_skip_newline:
  token_check_type [токен], [ТИП_ПЕРЕНОС_СТРОКИ]
  cmp rax, 1
  jne .no_newline
    next
  .no_newline:

  ret

f_revert:
  get_arg 0
  ; RAX — amount = 0

  cmp rax, 0
  jne .not_default
    integer 1

  .not_default:

  integer_sub [индекс], rax
  mov [индекс], rax

  update_token

  mov rax, [токен]
  ret

f_update_token:
  mov rbx, [индекс]
  mov rbx, [rbx + INTEGER_HEADER*8]

  list_length [токены]
  cmp rax, rbx
  jle .skip

  mov rax, 0
  cmp rax, rbx
  jg .skip

    integer_copy [индекс]
    integer_dec rax

    list_get_link [токены], rax
    mov [токен], rax

  .skip:
  ret

f_expression:
  ; RBX — index
  integer_copy [индекс]
  mov rbx, rax

  ; RCX — variable
  ; RDX — keys
  ; R8  — operator
  ; R9  — expression

  token_check_type [токен], [ТИП_ИДЕНТИФИКАТОР]
  cmp rax, 1
  jne .skip_identifier
    mov rcx, [токен]

    list
    mov rdx, rax

    next

    .identifier_while:
      token_check_type [токен], [ТИП_ТОЧКА]
      cmp rax, 1
      jne .identifier_end_while

      next

      term
      list_append_link rdx, rax

      jmp .identifier_while

    .identifier_end_while:

    list_node rdx
    mov rdx, rax

    mov r8, 0

    token_check_type [токен], [ТИП_СЛОЖЕНИЕ]
    cmp rax, 1
    je .assig_with_operation
    token_check_type [токен], [ТИП_ВЫЧИТАНИЕ]
    cmp rax, 1
    je .assig_with_operation
    token_check_type [токен], [ТИП_УМНОЖЕНИЕ]
    cmp rax, 1
    je .assig_with_operation
    token_check_type [токен], [ТИП_ДЕЛЕНИЕ]
    cmp rax, 1
    je .assig_with_operation

    jmp .skip_operator

    .assig_with_operation:

      mov r8, [токен]

      next

    .skip_operator:

    token_check_type [токен], [ТИП_ПРИСВАИВАНИЕ]
    cmp rax, 1
    jne .skip_assign

      next

      expression
      mov r9, rax

      cmp r8, 0
      je .skip_operator_assign

        access_node rcx, rdx
        binary_operation_node rax, r8, r9
        mov r9, rax

      .skip_operator_assign:

      assign_node rcx, rdx, r9

      ret

    .skip_assign:

    jmp .revert

  .skip_identifier:

  ; RCX — list_expression
  ; RDX — expression
  ; R8  — variables
  ; R9  — index

  token_check_type [токен], [ТИП_ОТКРЫВАЮЩАЯ_СКОБКА_СПИСКА]
  cmp rax, 1
  jne .skip_list

    list_expression
    mov rcx, rax

    token_check_type [токен], [ТИП_ПРИСВАИВАНИЕ]
    cmp rax, 1
    jne .skip_list_assign

      next

      list_expression
      mov rdx, rax

      list_length rcx
      mov rbx, rax
      list_length rdx

      cmp rbx, rax
      je .skip_length_error
        cmp [try], 1
        jne @f
          null
          ret

        @@:

        list
        mov rbx, rax

        string "Неверный синтаксис: ожидаемая длина Списка — "
        list_append_link rbx, rax

        list_length rcx
        integer rax
        to_string rax
        mov rcx, rax

        string ", но получен Список с длиной "
        string_extend_links rcx, rax
        list_append_link rbx, rax

        list_length rdx
        integer rax
        to_string rax
        list_append_link rbx, rax

        error rax
        exit -1

      .skip_length_error:

      list
      mov r8, rax

      integer 0
      mov r9, rax

      .list_while:
        list_length rcx
        integer rax

        is_equal rax, r9
        boolean_value rax
        cmp rax, 1
        je .list_end_while

        list_get_link rcx, r9
        token_check_type rax, [УЗЕЛ_ДОСТУПА_К_ПЕРЕМЕННОЙ]
        cmp rax, 1
        je .skip_access_error

          cmp [try], 1
          jne @f
            null
            ret

          @@:

          list
          mov rbx, rax
          string "Ожидался"
          list_append_link rbx, rax
          buffer_to_string IDENTIFIER
          list_append_link rbx, rax
          error rax
          exit -1

        .skip_access_error:

        dictionary_get_link rcx, [переменная]
        mov r10, rax

        dictionary_get_link rcx, [ключи]
        mov r11, rax

        list_get rdx, r9
        mov r12, rax

        assign_node r10, r11, r12
        list_append_link r8, rax

        jmp .list_while

      .list_end_while:

      list_node r8
      ret

    .skip_list_assign:

    jmp .revert

  .skip_list:

  .revert:

  integer_sub [индекс], rbx
  revert rax

  list
  list_append_link rax, [И]
  list_append_link rax, [ИЛИ]

  binary_operation rax, f_comparison_expression

  ret

f_binary_operation:
  get_arg 0
  mov rdx, rax
  get_arg 1
  mov rbx, rax
  get_arg 2
  mov rcx, rax
  ; RBX — left_function
  ; RCX — right_function = 0
  ; RDX — operators
  ; R8  — left
  ; R9  — left_operator
  ; R10 — middle
  ; R11 — right_operator
  ; R12 — right

  cmp rcx, 0
  jne .not_default
    mov rcx, rbx

  .not_default:

  debug_start "binary_inner"

  enter rbx
  get_arg 0
  call rax
  return
  mov r8, rax

  debug_end "binary_inner"

  .while:
    token_check_type [токен], rdx
    cmp rax, 1
    je .condition_true

    token_check_keyword [токен], rdx
    cmp rax, 1
    jne .end_while

    .condition_true:

    mov r9, [токен]

    next

    debug_start "binary_inner"

    enter rcx
    get_arg 0
    call rax
    return
    mov r10, rax

    debug_end "binary_inner"

    binary_operation_node r8, r9, r10
    mov r8, rax

    cmp rdx, [СРАВНЕНИЯ]
    jne .skip_comparison

    token_check_type [токен], [СРАВНЕНИЯ]
    cmp rax, 1
    jne .skip_comparison

      mov r11, [токен]

      next

      arithmetical_expression
      mov r12, rax

      dictionary
      dictionary_set rax, [тип], [ТИП_КЛЮЧЕВОЕ_СЛОВО]
      dictionary_set rax, [значение], [И]

      binary_operation_node r8, rax, r10
      mov r8, rax

    .skip_comparison:

    jmp .while

  .end_while:

  mov rax, r8
  ret

f_atom:
  ; RBX — token
  dictionary_copy [токен]
  mov rbx, rax

  token_check_type rbx, [ТИП_ЦЕЛОЕ_ЧИСЛО]
  cmp rax, 1
  jne .not_integer
    next

    integer_node rbx
    ret

  .not_integer:

  token_check_type rbx, [ТИП_ВЕЩЕСТВЕННОЕ_ЧИСЛО]
  cmp rax, 1
  jne .not_float
    next

    float_node rbx
    ret

  .not_float:

  token_check_type rbx, [ТИП_СТРОКА]
  cmp rax, 1
  jne .not_string
    next

    string "значение"
    dictionary_get_link rbx, rax
    mov rbx, rax

    list
    mov rcx, rax

    integer 0
    mov rdx, rax

    list_length rbx
    integer rax
    mov r8, rax

    .while_string:

      is_equal rdx, r8
      boolean_value rax
      cmp rax, 1
      je .while_string_end

      list_get_link rbx, rdx
      mov r9, rax

      mov rax, [r9]
      cmp rax, STRING
      je .string

        push [токен], [токены], [индекс]

        parser r9
        mov r9, rax

        integer 0
        list_pop_link r9, rax
        mov r9, rax

        pop rax
        mov [индекс], rax

        pop rax
        mov [токены], rax

        pop rax
        mov [токен], rax

      .string:

      list_append_link rcx, r9

      integer_inc rdx
      jmp .while_string

    .while_string_end:

    string_node rcx
    ret

  .not_string:

  token_check_type rbx, [ТИП_ИДЕНТИФИКАТОР]
  cmp rax, 1
  jne .not_identifier

    integer 2
    integer_sub [индекс], rax
    list_get_link [токены], rax
    token_check_type rax, [ТИП_ТОЧКА]
    cmp rax, 1
    jne .not_field_access
      next

      list
      list_node rax
      access_node rbx, rax

      ret

    .not_field_access:

    next

    ; RCX — keys

    list
    mov rcx, rax

    token_check_type [токен], [ТИП_ТОЧКА]
    cmp rax, 1
    jne .end_while
      next

      list
      list_append_link rax, [ТИП_ИДЕНТИФИКАТОР]
      list_append_link rax, [ТИП_СТРОКА]
      list_append_link rax, [ТИП_ЦЕЛОЕ_ЧИСЛО]
      token_check_type [токен], rax
      cmp rax, 1
      jne .not_atom
        atom
        jmp .add_key

      .not_atom:

      token_check_type [токен], [ТИП_ОТКРЫВАЮЩАЯ_СКОБКА]
      cmp rax, 1
      jne .not_arithmetical_expression
        arithmetical_expression
        jmp .add_key

      .not_arithmetical_expression:

      token_check_type [токен], [ТИП_ВЫЧИТАНИЕ]
      cmp rax, 1
      jne .not_factor
        factor
        jmp .add_key

      .not_factor:

      cmp [try], 1
      jne @f
        null
        ret

      @@:

      list
      mov rbx, rax
      string "Ожидались "
      list_append_link rbx, rax
      buffer_to_string IDENTIFIER
      list_append_link rbx, rax
      buffer_to_string INTEGER_TYPE_NAME
      list_append_link rbx, rax
      buffer_to_string STRING_TYPE_NAME
      list_append_link rbx, rax
      buffer_to_string OPEN_PAREN
      list_append_link rbx, rax
      error rax
      exit -1

      .add_key:

      list_append_link rcx, rax

    .end_while:

    list_node rcx
    access_node rbx, rax

    ret

  .not_identifier:

  token_check_type rbx, [ТИП_ОТКРЫВАЮЩАЯ_СКОБКА]
  cmp rax, 1
  jne .not_open_paren
    next

    expression
    mov rbx, rax

    token_check_type [токен], [ТИП_ЗАКРЫВАЮЩАЯ_СКОБКА]
    cmp rax, 1
    je .correct_token

      cmp [try], 1
      jne @f
        null
        ret

      @@:

      list
      mov rbx, rax
      string "atom: Ожидалось"
      list_append_link rbx, rax
      buffer_to_string CLOSED_PAREN
      list_append_link rbx, rax
      error rax
      exit -1

    .correct_token:

    next
    mov rax, rbx
    ret

  .not_open_paren:

  mov rbx, 0

  token_check_type [токен], [ТИП_ОТКРЫВАЮЩАЯ_СКОБКА_СПИСКА]
  cmp rax, 1
  jne .not_list
    list_expression
    mov rbx, rax
    jmp .end

  .not_list:

  token_check_keyword [токен], [ПРОВЕРИТЬ]
  cmp rax, 1
  jne .not_check
    check_expression
    mov rbx, rax
    jmp .end

  .not_check:

  token_check_keyword [токен], [ЕСЛИ]
  cmp rax, 1
  jne .not_if
    if_expression
    mov rbx, rax
    jmp .end

  .not_if:

  token_check_keyword [токен], [ДЛЯ]
  cmp rax, 1
  jne .not_for
    for_expression
    mov rbx, rax
    jmp .end

  .not_for:

  token_check_keyword [токен], [ПОКА]
  cmp rax, 1
  jne .not_while
    while_expression
    mov rbx, rax
    jmp .end

  .not_while:

  token_check_keyword [токен], [ФУНКЦИЯ]
  cmp rax, 1
  jne .not_function
    function_expression
    mov rbx, rax
    jmp .end

  .not_function:

  token_check_keyword [токен], [КЛАСС]
  cmp rax, 1
  jne .not_class
    class_expression
    mov rbx, rax
    jmp .end

  .not_class:

  token_check_keyword [токен], [УДАЛИТЬ]
  cmp rax, 1
  jne .not_delete
    delete_expression
    mov rbx, rax
    jmp .end

  .not_delete:

  token_check_keyword [токен], [ВКЛЮЧИТЬ]
  cmp rax, 1
  jne .not_include
    include_statement
    mov rbx, rax
    jmp .end

  .not_include:

  .end:

  cmp rbx, 0
  jne .correct_expression

    cmp [try], 1
    jne @f
      null
      ret

    @@:

    string "atom: Ожидались:"
    mov rcx, rax

    list
    mov rbx, rax
    buffer_to_string KEYWORD
    list_append_link rbx, rax
    buffer_to_string IDENTIFIER
    list_append_link rbx, rax
    buffer_to_string INTEGER_TYPE_NAME
    list_append_link rbx, rax
    buffer_to_string FLOAT_TYPE_NAME
    list_append_link rbx, rax
    buffer_to_string STRING_TYPE_NAME
    list_append_link rbx, rax
    buffer_to_string LIST_TYPE_NAME
    list_append_link rbx, rax

    string ", "
    join rbx, rax
    mov rbx, rax

    string ". Получено"
    string_extend_links rbx, rax
    mov rbx, rax

    list
    list_append_link rax, rcx
    list_append_link rax, rbx
    list_append_link rax, [токен]
    error rax
    exit -1

  .correct_expression:

  mov rax, rbx
  ret

f_call_expression:
  ; RBX — atom
  atom
  mov rbx, rax

  token_check_type [токен], [ТИП_ОТКРЫВАЮЩАЯ_СКОБКА]
  cmp rax, 1
  je .call
    mov rax, rbx
    ret

  .call:

  next
  skip_newline

  ; RCX — argument_nodes
  list
  mov rcx, rax
  list
  mov rdx, rax

  mov r8, 0

  .while:
    token_check_type [токен], [ТИП_ЗАКРЫВАЮЩАЯ_СКОБКА]
    cmp rax, 1
    je .end_while

    expression
    mov r9, rax

    dictionary_get_link r9, [узел]
    is_equal rax, [УЗЕЛ_ПРИСВАИВАНИЯ_ПЕРЕМЕННОЙ]
    boolean_value rax
    cmp rax, 1
    je .named_argument

      cmp r8, 0
      je .correct_sequence

        string "Ожидался именованный аргумент"
        mov rbx, rax
        list
        list_append_link rax, rbx
        error rax
        exit -1

      .correct_sequence:

      list_append_link rcx, r9
      jmp .next_argument

    .named_argument:

      dictionary_get_link r9, [ключи]
      dictionary_get_link rax, [элементы]
      list_length rax
      cmp rax, 0
      je .not_keys

        string "Именованный аргумент не может иметь ключей"
        mov rbx, rax
        list
        list_append_link rax, rbx
        error rax
        exit -1

      .not_keys:

      dictionary_get_link r9, [переменная]
      dictionary_get_link rax, [значение]
      to_string rax
      mov r10, rax

      list
      list_append_link rax, r10
      mov r10, rax

      dictionary
      dictionary_set_link rax, [тип], [ТИП_СТРОКА]
      dictionary_set_link rax, [значение], r10
      string_node rax
      mov r10, rax

      dictionary_get_link r9, [значение]
      mov r11, rax

      list
      list_append_link rax, r10
      list_append_link rax, r11
      list_node rax
      list_append_link rdx, rax
      mov r8, 1

    .next_argument:

    jmp .while

  .end_while:

  token_check_type [токен], [ТИП_ЗАКРЫВАЮЩАЯ_СКОБКА]
  cmp rax, 1
  je .correct_token

    cmp [try], 1
    jne @f
      null
      ret

    @@:

    list
    mov rbx, rax
    string "Ожидалось"
    list_append_link rbx, rax
    buffer_to_string CLOSED_PAREN
    list_append_link rbx, rax
    error rax
    exit -1

  .correct_token:

  next

  call_node rbx, rcx, rdx
  ret

f_power_root:
  list
  list_append_link rax, [ТИП_ВОЗВЕДЕНИЕ_В_СТЕПЕНЬ]
  list_append_link rax, [ТИП_ИЗВЛЕЧЕНИЕ_КОРНЯ]

  binary_operation rax, f_call_expression, f_factor

  ret

f_factor:
  ; RBX — token
  mov rbx, [токен]

  list
  list_append_link rax, [ТИП_ВЫЧИТАНИЕ]
  list_append_link rax, [ТИП_ИНКРЕМЕНТАЦИЯ]
  list_append_link rax, [ТИП_ДЕКРЕМЕНТАЦИЯ]
  token_check_type rbx, rax
  cmp rax, 1
  je .unary_operation
    power_root
    ret

  .unary_operation:

  next

  ; RCX — factor

  factor
  unary_operation_node rbx, rax

  ret

f_term:
  list
  list_append_link rax, [ТИП_УМНОЖЕНИЕ]
  list_append_link rax, [ТИП_ДЕЛЕНИЕ]

  binary_operation rax, f_factor
  ret

f_comparison_expression:
  token_check_keyword [токен], [НЕ]
  cmp rax, 1
  jne .not_unary
    mov rbx, [токен]

    next

    comparison_expression
    unary_operation_node rbx, rax

    ret

  .not_unary:

  binary_operation [СРАВНЕНИЯ], f_arithmetical_expression

  ret

f_arithmetical_expression:
  list
  list_append_link rax, [ТИП_СЛОЖЕНИЕ]
  list_append_link rax, [ТИП_ВЫЧИТАНИЕ]

  binary_operation rax, f_term

  ret

f_list_expression:
  token_check_type [токен], [ТИП_ОТКРЫВАЮЩАЯ_СКОБКА_СПИСКА]
  cmp rax, 1
  je .correct_start

    cmp [try], 1
    jne @f
      null
      ret

    @@:

    list
    mov rbx, rax
    string "Ожидалось"
    list_append_link rbx, rax
    buffer_to_string OPEN_LIST_PAREN
    list_append_link rbx, rax
    error rax
    exit -1

  .correct_start:

  next
  skip_newline

  token_check_type [токен], [ТИП_ДВОЕТОЧИЕ]
  cmp rax, 1
  jne .not_empty_dictionary

    next
    skip_newline

    token_check_type [токен], [ТИП_ЗАКРЫВАЮЩАЯ_СКОБКА]
    cmp rax, 1
    je .correct_empty_dictionary

      cmp [try], 1
      jne @f
        null
        ret

      @@:

      list
      mov rbx, rax
      string "Ожидалось"
      list_append_link rbx, rax
      buffer_to_string CLOSED_PAREN
      list_append_link rbx, rax
      error rax
      exit -1

    .correct_empty_dictionary:

    next

    list
    dictionary_node rax
    ret

  .not_empty_dictionary:

  token_check_type [токен], [ТИП_ЗАКРЫВАЮЩАЯ_СКОБКА]
  cmp rax, 1
  jne .not_empty_list

    next

    list
    list_node rax
    ret

  .not_empty_list:

  expression
  mov rbx, rax

  skip_newline

  token_check_type [токен], [ТИП_ДВОЕТОЧИЕ]
  cmp rax, 1
  jne .not_dictionary

    next
    skip_newline

    expression
    mov rcx, rax

    list
    mov rdx, rax

    list
    list_append_link rax, rbx
    list_append_link rax, rcx

    list_node rax
    list_append_link rdx, rax

    .while_dictionary:

      token_check_type [токен], [ТИП_ЗАКРЫВАЮЩАЯ_СКОБКА]
      cmp rax, 1
      je .end_while_dictionary

      expression
      mov rbx, rax

      skip_newline

      token_check_type [токен], [ТИП_ДВОЕТОЧИЕ]
      cmp rax, 1
      je .correct_colon

        cmp [try], 1
        jne @f
          null
          ret

        @@:

        list
        mov rbx, rax
        string "Ожидалось"
        list_append_link rbx, rax
        buffer_to_string COLON
        list_append_link rbx, rax
        error rax
        exit -1

      .correct_colon:

      next
      skip_newline

      expression
      mov rcx, rax

      skip_newline

      list
      list_append_link rax, rbx
      list_append_link rax, rcx

      list_node rax
      list_append_link rdx, rax

      jmp .while_dictionary

    .end_while_dictionary:

    next

    list_node rdx
    dictionary_node rax
    ret

  .not_dictionary:

  list
  mov rcx, rax

  list_append_link rcx, rbx

  .while_list:

    token_check_type [токен], [ТИП_ЗАКРЫВАЮЩАЯ_СКОБКА]
    cmp rax, 1
    je .end_while_list

    expression
    list_append_link rcx, rax
    skip_newline

    jmp .while_list

  .end_while_list:

  next

  list_node rcx
  ret

f_check_expression:
  ; RBX — cases
  ; RCX — else_case

  list
  mov rbx, rax

  mov rcx, 0

  token_check_keyword [токен], [ПРОВЕРИТЬ]
  je .correct_start

    cmp [try], 1
    jne @f
      null
      ret

    @@:

    list
    mov rbx, rax
    string "Ожидалось"
    list_append_link rbx, rax
    buffer_to_string CHECK
    list_append_link rbx, rax
    error rax
    exit -1

  .correct_start:

  next

  ; RDX — left

  arithmetical_expression
  mov rdx, rax

  ; R8 — operator
  dictionary
  dictionary_set_link rax, [тип], [РАВНО]
  mov r8, rax

  list_copy [СРАВНЕНИЯ]
  list_append_link rax, [ТИП_ПЕРЕНОС_СТРОКИ]
  token_check_type [токен], rax
  je .skip_condition_error

    cmp [try], 1
    jne @f
      null
      ret

    @@:

    list
    mov rbx, rax
    string "Ожидались оператор сравнения или перенос строки"
    list_append_link rbx, rax
    buffer_to_string COMPARISON_OPERATOR
    list_append_link rbx, rax
    buffer_to_string NEWLINE
    list_append_link rbx, rax
    error rax
    exit -1

  .skip_condition_error:

  token_check_type [токен], [СРАВНЕНИЯ]
  jne .skip_condition
    mov r8, [токен]

    next

    token_check_type [токен], [ПЕРЕНОС_СТРОКИ]
    cmp rax, 1
    jne .skip_newline_error_1

      cmp [try], 1
      jne @f
        null
        ret

      @@:

      list
      mov rbx, rax
      string "Ожидался"
      list_append_link rbx, rax
      buffer_to_string NEWLINE
      list_append_link rbx, rax
      error rax
      exit -1

    .skip_newline_error_1:

  .skip_condition:

  next

  token_check_keyword [токен], [ПРИ]
  cmp rax, 1
  je .correct_on

    cmp [try], 1
    jne @f
      null
      ret

    @@:

    list
    mov rbx, rax
    string "Ожидалось"
    list_append_link rbx, rax
    buffer_to_string ON_KEYWORD
    list_append_link rbx, rax
    error rax
    exit -1

  .correct_on:

  .while:
    token_check_keyword [токен], [ПРИ]
    cmp rax, 1
    jne .end_while

    ; R9 — case_operator
    dictionary_copy r8
    mov r9, rax

    token_check_type [токен], [СРАВНЕНИЯ]
    cmp rax,1
    jne .no_case_operator_1

      dictionary_copy [токен]
      mov r9, rax
      next

    .no_case_operator_1:

    arithmetical_expression
    binary_operation_node rdx, r9, rax
    mov r11, rax

    .and_or_while:
      list
      list_append_link rax, [И]
      list_append_link rax, [ИЛИ]
      token_check_keyword [токен], rax
      cmp rax, 1
      jne .end_and_or_while

      ; R12 — connector

      token_check_type [токен], [СРАВНЕНИЯ]
      cmp rax, 1
      jne .no_case_operator_2

        dictionary_copy [токен]
        mov r9, rax

        next

      .no_case_operator_2:

      arithmetical_expression
      binary_operation_node rdx, r9, rax
      mov r11, rax

      jmp .and_or_while

    .end_and_or_while:

    token_check_type [токен], [ПЕРЕНОС_СТРОКИ]
    cmp rax, 1
    jne .skip_newline_error_2

      cmp [try], 1
      jne @f
        null
        ret

      @@:

      list
      mov rbx, rax
      string "Ожидался"
      list_append_link rbx, rax
      buffer_to_string NEWLINE
      list_append_link rbx, rax
      error rax
      exit -1

    .skip_newline_error_2:

    next

    ; R13 — body

    list
    mov r13, rax

    .on_else_while:

      list
      list_append_link rax, [ПРИ]
      list_append_link rax, [ИНАЧЕ]
      token_check_keyword [токен], rax
      cmp rax, 1
      je .end_on_else_while

      statement
      list_append_link r13, rax

      integer -1
      list_get_link r13, rax
      dictionary_get_link rax, [тип]
      is_equal rax, [ПРОПУСТИТЬ]
      boolean_value rax
      cmp rax, 1
      jne .skip_continue_error

        cmp [try], 1
        jne @f
          null
          ret

        @@:

        string "Ключевое слово `продолжить` может использоваться только в цикле"
        mov rbx, rax
        list
        list_append_link rax, rbx
        error rax
        exit -1

      .skip_continue_error:

      next

      jmp .on_else_while

    .end_on_else_while:

    list_node r13
    mov r13, rax

    list
    list_append_link rax, r11
    list_append_link rax, r13
    list_append_link rax, 0

    list_append_link rbx, rax

    jmp .while

  .end_while:

  ; R14 — else_case
  mov r14, 0

  token_check_type [токен], [ТИП_КОНЕЦ_КОНСТРУКЦИИ]
  je .skip_else_case

    else_expression
    mov r14, rax

  .skip_else_case:

  check_node rbx, r14
  ret

f_if_expression:
  ; RBX — cases
  ; RCX — else_case

  list
  mov rbx, rax

  null
  mov rcx, rax

  token_check_keyword [токен], [ЕСЛИ]
  cmp rax, 1
  je .while

    cmp [try], 1
    jne @f
      null
      ret

    @@:

    string "Ожидалось ключевое слово `если`"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .while:

    next

    ; RDX — condition

    expression
    mov rdx, rax

    token_check_keyword [токен], [ТО]
    cmp rax, 1
    je .correct_token_then

      cmp [try], 1
      jne @f
        null
        ret

      @@:

      string "Ожидалось ключевое слово `то`"
      mov rbx, rax
      list
      list_append_link rax, rbx
      error rax
      exit -1

    .correct_token_then:

    next

    token_check_type [токен], [ТИП_ПЕРЕНОС_СТРОКИ]
    cmp rax, 1
    je .correct_token_newline

      cmp [try], 1
      jne @f
        null
        ret

      @@:

      string "Ожидался перенос строки"
      mov rbx, rax
      list
      list_append_link rax, rbx
      error rax
      exit -1

    .correct_token_newline:

    next

    ; R8 — statements
    list
    mov r8, rax

    .body_while:
      token_check_keyword [токен], [ИНАЧЕ]
      cmp rax, 1
      je .body_end_while

      token_check_type [токен], [ТИП_КОНЕЦ_КОНСТРУКЦИИ]
      cmp rax, 1
      je .body_end_while

      statement
      list_append_link r8, rax

      next

      jmp .body_while

    .body_end_while:

    dictionary
    mov r9, rax

    string "условие"
    dictionary_set_link r9, rax, rdx
    string "тело"
    dictionary_set_link r9, rax, r8

    list_append_link rbx, r9

    token_check_keyword [токен], [ИНАЧЕ]
    cmp rax, 1
    jne .check_end_of_construction

      next

      token_check_keyword [токен], [ЕСЛИ]
      cmp rax, 1
      je .while

      integer 1
      revert rax

      jmp .else_branch

    .check_end_of_construction:

    token_check_type [токен], [ТИП_КОНЕЦ_КОНСТРУКЦИИ]
    cmp rax, 1
    je .end_while

      cmp [try], 1
      jne @f
        null
        ret

      @@:

      string "Ожидался конец конструкции"
      mov rbx, rax
      list
      list_append_link rax, rbx
      error rax
      exit -1

  .end_while:

    next

    list
    if_node rbx, rax

    ret

  .else_branch:

    else_expression
    if_node rbx, rax

    ret

f_else_expression:
  ; RBX — else_case

  mov rbx, 0

  token_check_keyword [токен], [ИНАЧЕ]
  cmp rax, 1
  je .exists
    mov rax, rbx
    ret

  .exists:

  next

  token_check_type [токен], [ТИП_ПЕРЕНОС_СТРОКИ]
  cmp rax, 1
  je .make_multiline
    statement
    mov rbx, rax

    list
    list_append_link rax, rbx
    mov rbx, rax
    integer 0
    list_append_link rbx, rax

    ret

  .make_multiline:

  next

  ; RCX — statements

  list
  mov rcx, rax

  .while:
    token_check_type [токен], [ТИП_КОНЕЦ_ФАЙЛА]
    jne .continue

      cmp [try], 1
      jne @f
        null
        ret

      @@:

      string "Ожидался конец конструкции"
      mov rbx, rax
      list
      list_append_link rax, rbx
      error rax
      exit -1

    .continue:

    statement
    list_append_link rcx, rax

    next

    token_check_type [токен], [ТИП_КОНЕЦ_КОНСТРУКЦИИ]
    cmp rax, 1
    jne .while

  next
  mov rax, rcx

  ret

f_for_expression:
  ; RBX — else_case
  mov rbx, 0

  token_check_keyword [токен], [ДЛЯ]
  cmp rax, 1
  je .correct_for

    cmp [try], 1
    jne @f
      null
      ret

    @@:

    string "Ожидалось ключевое слово `для`"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .correct_for:

  next

  token_check_type [токен], [ТИП_ИДЕНТИФИКАТОР]
  cmp rax, 1
  je .correct_identifier

    cmp [try], 1
    jne @f
      null
      ret

    @@:

    string "Ожидался идентификатор"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .correct_identifier:

  ; RCX — variable_name

  mov rcx, [токен]
  next

  token_check_keyword [токен], [ОТ]
  cmp rax, 1
  jne .loop_with_enter

    next

    ; RDX — start_value

    expression
    mov rdx, rax

    token_check_keyword [токен], [ДО]
    cmp rax, 1
    je .correct_to

      cmp [try], 1
      jne @f
        null
        ret

      @@:

      string "Ожидалось ключевое слово `до`"
      mov rbx, rax
      list
      list_append_link rax, rbx
      error rax
      exit -1

    .correct_to:

    next

    expression
    mov r8, rax

    token_check_keyword [токен], [ЧЕРЕЗ]
    cmp rax, 1
    jne .default_step
      next

      expression
      mov r9, rax

      jmp .if_end

    .default_step:

    null
    mov r9, rax

    jmp .if_end

  .loop_with_enter:

  token_check_keyword [токен], [ИЗ]
  cmp rax, 1
  jne .unknown_token

    next

    ; R10 — start_value

    null
    mov r8, rax
    null
    mov r9, rax

    expression
    mov rdx, rax

    jmp .if_end

  .unknown_token:

    cmp [try], 1
    jne @f
      null
      ret

    @@:

    string "Ожидались ключевое слово `от` или `из`"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .if_end:

  token_check_type [токен], [ТИП_ПЕРЕНОС_СТРОКИ]
  cmp rax, 1
  je .correct_token

    string "Ожидался перенос строки"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .correct_token:

  next

  ; R11 — body

  list
  mov r10, rax

  .while:
    token_check_type [токен], [ТИП_КОНЕЦ_КОНСТРУКЦИИ]
    cmp rax, 1
    je .end_while

    token_check_keyword [токен], [ИНАЧЕ]
    cmp rax, 1
    je .else_branch

    token_check_type [токен], [ТИП_КОНЕЦ_ФАЙЛА]
    jne .not_end_of_file

      cmp [try], 1
      jne @f
        null
        ret

      @@:

      string "Ожидался конец конструкции"
      mov rbx, rax
      list
      list_append_link rax, rbx
      error rax
      exit -1

    .not_end_of_file:

    statement
    list_append_link r10, rax

    next
    jmp .while

  .end_while:

  next

  list

  jmp .return

  .else_branch:

    else_expression

  .return:

  mov r11, rax

  for_node rcx, rdx, r8, r9, r10, r11

  ret

f_while_expression:
  ; RBX — else_case

  mov rbx, 0

  token_check_keyword [токен], [ПОКА]
  cmp rax, 1
  je .correct_while

    cmp [try], 1
    jne @f
      null
      ret

    @@:

    string "Ожидалось ключевое слово `пока`"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .correct_while:

  next

  ; RCX — condition

  expression
  mov rcx, rax

  token_check_type [токен], [ТИП_ПЕРЕНОС_СТРОКИ]
  cmp rax, 1
  je .correct_newline

    cmp [try], 1
    jne @f
      null
      ret

    @@:

    string "Ожидался перенос строки"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .correct_newline:

  next

  list
  mov r10, rax

  .while:
    token_check_type [токен], [ТИП_КОНЕЦ_КОНСТРУКЦИИ]
    cmp rax, 1
    je .end_while

    token_check_keyword [токен], [ИНАЧЕ]
    cmp rax, 1
    je .else_branch

    token_check_type [токен], [ТИП_КОНЕЦ_ФАЙЛА]
    jne .not_end_of_file

      cmp [try], 1
      jne @f
        null
        ret

      @@:

      string "Ожидался конец конструкции"
      mov rbx, rax
      list
      list_append_link rax, rbx
      error rax
      exit -1

    .not_end_of_file:

    statement
    list_append_link r10, rax

    next
    jmp .while

  .end_while:

  next

  list

  jmp .return

  .else_branch:

    else_expression

  .return:

  mov r11, rax

  while_node rcx, r10, r11

  ret

f_function_expression:
  get_arg 0
  mov rbx, rax
  ; RBX — is_method

  token_check_keyword [токен], [ФУНКЦИЯ]
  cmp rax, 1
  je .correct_function

    cmp [try], 1
    jne @f
      null
      ret

    @@:

    string "Ожидалось ключевое слово `функция`"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .correct_function:

  next

  ; RCX — variable_name

  mov rcx, 0
  token_check_type [токен], [ТИП_ИДЕНТИФИКАТОР]
  cmp rax, 1
  jne .unnamed_function

    mov rcx, [токен]
    next

  .unnamed_function:

  token_check_type [токен], [ТИП_ОТКРЫВАЮЩАЯ_СКОБКА]
  cmp rax, 1
  je .correct_open_paren

    cmp [try], 1
    jne @f
      null
      ret

    @@:

    string "Ожидалось `(`"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .correct_open_paren:

  next

  ; RDX — arguments

  list
  mov rdx, rax

  mov r8, 0

  .while:
    token_check_type [токен], [ТИП_ИДЕНТИФИКАТОР]
    cmp rax, 1
    jne .end_while

    integer_copy [индекс]
    mov r10, rax

    mov rax, [try]
    push rax
    mov [try], 1

    ; R9 — argument
    expression
    mov r9, rax

    pop rax
    mov [try], rax

    null
    cmp r9, rax
    jne .continue_check

      token_check_type [токен], [ТИП_УМНОЖЕНИЕ]
      cmp rax, 1
      je .correct_argument
      token_check_type [токен], [ТИП_ВОЗВЕДЕНИЕ_В_СТЕПЕНЬ]
      cmp rax, 1
      je .correct_argument

      jmp .incorrect_argument

    .continue_check:

    dictionary_get_link r9, [узел]
    is_equal rax, [УЗЕЛ_ПРИСВАИВАНИЯ_ПЕРЕМЕННОЙ]
    boolean_value rax
    cmp rax, 1
    je .correct_argument

    dictionary_get_link r9, [узел]
    is_equal rax, [УЗЕЛ_ДОСТУПА_К_ПЕРЕМЕННОЙ]
    boolean_value rax
    cmp rax, 1
    je .correct_argument

    integer_sub [индекс], r10
    revert rax

    atom
    mov r9, rax

    dictionary_get_link r9, [узел]
    is_equal rax, [УЗЕЛ_ДОСТУПА_К_ПЕРЕМЕННОЙ]
    boolean_value rax
    cmp rax, 1
    je .correct_argument

    .incorrect_argument:

      cmp [try], 1
      jne @f
        null
        ret

      @@:

      string "Ожидался позиционный или именованный аргумент"
      mov rbx, rax
      list
      list_append_link rax, rbx
      error rax
      exit -1

    .correct_argument:

    token_check_type [токен], [ТИП_УМНОЖЕНИЕ]
    cmp rax, 1
    jne .not_positional

      mov r8, 1
      next
      jmp .not_named

    .not_positional:

    token_check_type [токен], [ТИП_ВОЗВЕДЕНИЕ_В_СТЕПЕНЬ]
    cmp rax, 1
    jne .not_named

      mov r8, 2
      next

    .not_named:

    cmp r8, 0
    je .not_accumulator

      integer r8
      mov r8, rax
      string "*"
      string_mul rax, r8
      mov r8, rax

      dictionary_get_link r9, [переменная]
      dictionary_get_link rax, [значение]
      string_extend_links rax, r8

      mov r8, 0

    .not_accumulator:

    list_append_link rdx, r9

    jmp .while

  .end_while:

  token_check_type [токен], [ТИП_ЗАКРЫВАЮЩАЯ_СКОБКА]
  cmp rax, 1
  je .correct_closed_paren

    cmp [try], 1
    jne @f
      null
      ret

    @@:

    string "Ожидались Идентификатор или `)`"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .correct_closed_paren:

  next

  token_check_type [токен], [ТИП_ПЕРЕНОС_СТРОКИ]
  cmp rax, 1
  jne .make_oneline
    next

    ; R9 — body

    list
    mov r9, rax

    .while_body:
      token_check_type [токен], [ТИП_КОНЕЦ_КОНСТРУКЦИИ]
      cmp rax, 1
      je .end_while_body

      token_check_type [токен], [ТИП_КОНЕЦ_ФАЙЛА]
      jne .not_end_of_file

        cmp [try], 1
        jne @f
          null
          ret

        @@:

        string "Ожидался конец конструкции"
        mov rbx, rax
        list
        list_append_link rax, rbx
        error rax
        exit -1

      .not_end_of_file:

      statement
      list_append_link r9, rax

      next
      jmp .while_body

    .end_while_body:

    next

    cmp rbx, 0
    je .return_function
      method_node rcx, rdx, r9, 0
      ret

    .return_function:

    function_node rcx, rdx, r9, 0
    ret

  .make_oneline:

  token_check_type [токен], [ТИП_ДВОЕТОЧИЕ]
  cmp rax, 1
  je .correct_colon

    cmp [try], 1
    jne @f
      null
      ret

    @@:

    string "Ожидалось `:`"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .correct_colon:

  next

  ; R10 — return_node

  expression
  mov r10, rax

  cmp rbx, 0
  je .return_function_with_return
    method_node rcx, rdx, r10, 1
    ret

  .return_function_with_return:

  function_node rcx, rdx, r10, 1
  ret

f_class_expression:
  token_check_keyword [токен], [КЛАСС]
  cmp rax, 1
  je .correct_class

    cmp [try], 1
    jne @f
      null
      ret

    @@:

    string "Ожидалось ключевое слово `класс`"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .correct_class:

  next

  token_check_type [токен], [ТИП_ИДЕНТИФИКАТОР]
  cmp rax, 1
  je .correct_identifier

    cmp [try], 1
    jne @f
      null
      ret

    @@:

    string "Ожидался Идентификатор"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .correct_identifier:

  ; RBX — variable_name
  mov rbx, [токен]
  next

  token_check_type [токен], [ТИП_ОТКРЫВАЮЩАЯ_СКОБКА]
  cmp rax, 1
  je .correct_open_paren

    cmp [try], 1
    jne @f
      null
      ret

    @@:

    string "Ожидалось `(`"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .correct_open_paren:

  ; RCX — parents
  list
  mov rcx, rax

  token_check_type [токен], [ТИП_ОТКРЫВАЮЩАЯ_СКОБКА]
  cmp rax, 1
  jne .no_parents
    next

    list
    list_append_link rax, [ТИП_ИДЕНТИФИКАТОР]
    list_append_link rax, [ТИП_ЗАКРЫВАЮЩАЯ_СКОБКА]
    token_check_type [токен], rax
    je .correct_identifier_closed_paren_1

      cmp [try], 1
      jne @f
        null
        ret

      @@:

      string "Ожидались Идентификатор или `)`"
      mov rbx, rax
      list
      list_append_link rax, rbx
      error rax
      exit -1

    .correct_identifier_closed_paren_1:

    .while_1:
      token_check_type [токен], [ТИП_ИДЕНТИФИКАТОР]
      cmp rax, 1
      jne .end_while_1

      dictionary_get_link [токен], [значение]
      list_append_link rcx, rax

      next
      skip_newline

      token_check_type [токен], [ТИП_ЗАКРЫВАЮЩАЯ_СКОБКА]
      cmp rax, 1
      je .correct_space_closed_paren_2

        cmp [try], 1
        jne @f
          null
          ret

        @@:

        string "Ожидались ` ` или `)`"
        mov rbx, rax
        list
        list_append_link rax, rbx
        error rax
        exit -1

      .correct_space_closed_paren_2:

      token_check_type [токен], [ТИП_ПЕРЕНОС_СТРОКИ]
      cmp rax, 1
      jne .no_space
        next

      .no_space:

      jmp .while_1

    .end_while_1:

    list
    list_append_link rax, [ТИП_ИДЕНТИФИКАТОР]
    list_append_link rax, [ТИП_ЗАКРЫВАЮЩАЯ_СКОБКА]
    token_check_type [токен], rax
    cmp rax, 1
    je .correct_identifier_closed_paren_3

      cmp [try], 1
      jne @f
        null
        ret

      @@:

      string "Ожидались Идентификатор или `)`"
      mov rbx, rax
      list
      list_append_link rax, rbx
      error rax
      exit -1

    .correct_identifier_closed_paren_3:

    next

    token_check_type [токен], [ТИП_ПЕРЕНОС_СТРОКИ]
    cmp rax, 1
    jne .no_newline_2

      cmp [try], 1
      jne @f
        null
        ret

      @@:

      string "Ожидался перенос строки"
      mov rbx, rax
      list
      list_append_link rax, rbx
      error rax
      exit -1

    .no_newline_2:

  .no_parents:

  next

  token_check_keyword [токен], [ФУНКЦИЯ]
  cmp rax, 1
  je .correct_function_end_of_construction

  token_check_type [токен], [ТИП_КОНЕЦ_КОНСТРУКЦИИ]
  cmp rax, 1
  je .correct_function_end_of_construction

    cmp [try], 1
    jne @f
      null
      ret

    @@:

    string "Ожидались ключевое слово `функция` или конец конструкции"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .correct_function_end_of_construction:

  ; RDX — methods
  list
  mov rdx, rax

  .while_2:
    token_check_keyword [токен], [ФУНКЦИЯ]
    cmp rax, 1
    jne .end_while_2

    ; R8 — method
    function_expression 1
    mov r8, rax

    list_get_link r8, [аргументы]
    list_length rax
    cmp rax, 1
    jge .correct_arguments

      cmp [try], 1
      jne @f
        null
        ret

      @@:

      string "Метод должен иметь хотя бы один аргумент, в который будет помещён сам объект"
      mov rbx, rax
      list
      list_append_link rax, rbx
      error rax
      exit -1

    .correct_arguments:

    ; R9 — method_name
    list_get_link r8, [имя_переменной]
    mov r9, rax

    list
    list_append_link rax, r9
    string_node rax
    mov r9, rax

    list
    list_append_link rax, r9
    list_append_link rax, r8

    list_append_link rdx, rax

    next

    jmp .while_2

  .end_while_2:

  token_check_type [токен], [ТИП_КОНЕЦ_КОНСТРУКЦИИ]
  cmp rax, 1
  je .correct_end_construction

    cmp [try], 1
    jne @f
      null
      ret

    @@:

    string "Ожидался конец конструкции"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .correct_end_construction:

  ; TODO: проверка существования магического метода инициализации

  next

  list_node rdx
  dictionary_node rax
  class_node rbx, rax, rcx

  ret

f_delete_expression:
  token_check_keyword [токен], [УДАЛИТЬ]
  cmp rax, 1
  je .correct_delete

    cmp [try], 1
    jne @f
      null
      ret

    @@:

    string "Ожидалось ключевое слово `удалить`"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .correct_delete:

  next

  token_check_type [токен], [ТИП_ИДЕНТИФИКАТОР]
  cmp rax, 1
  je .correct_identifier

    cmp [try], 1
    jne @f
      null
      ret

    @@:

    string "Ожидался Идентфикатор"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .correct_identifier:

  ; RBX — variable
  mov rbx, [токен]

  next

  delete_node rbx

  ret

f_include_statement:
  token_check_keyword [токен], [ВКЛЮЧИТЬ]
  cmp rax, 1
  je .correct_include

    cmp [try], 1
    jne @f
      null
      ret

    @@:

    string "Ожидалось ключевое слово `включить`"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .correct_include:

  next

  token_check_type [токен], [ТИП_СТРОКА]
  cmp rax, 1
  je .correct_module

    cmp [try], 1
    jne @f
      null
      ret

    @@:

    string "Ожидалось имя модуля (строка)"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .correct_module:

  string "значение"
  dictionary_get_link [токен], rax
  mov rcx, rax

  list_length rcx
  cmp rax, 1
  jne .incorrect_module

  integer 0
  list_get_link rcx, rax
  mov rbx, rax

  mov rax, [rbx]
  cmp rax, STRING
  jne .incorrect_module

  next

  include_node rbx

  ret

  .incorrect_module:
    list
    mov rbx, rax

    string "Должна быть передана обычная строка"
    list_append_link rbx, rax

    error rax
    exit -1

f_statement:
  token_check_keyword [токен], [ВЕРНУТЬ]
  cmp rax, 1
  jne .not_return
    ; RBX — index
    mov rbx, [индекс]
    next

    mov rax, [try]
    push rax
    mov [try], 1

    ; RCX — expression
    expression
    mov rcx, rax

    pop rax
    mov [try], rax

    null
    is_equal rcx, rax
    boolean_value rax
    cmp rax, 1
    jne .return_value

      integer_sub [токен], rbx
      revert rax

    .return_value:

    return_node rcx

    ret

  .not_return:

  token_check_keyword [токен], [ПРОПУСТИТЬ]
  cmp rax, 1
  jne .not_skip

    next

    skip_node
    ret

  .not_skip:

  token_check_keyword [токен], [ПРЕРВАТЬ]
  cmp rax, 1
  jne .not_break

    next

    break_node
    ret

  .not_break:

  expression

  ret
