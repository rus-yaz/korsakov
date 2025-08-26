; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

section "parser_data" writable
  try dq 0

section "parser_code" executable

; @function parser
; @debug
; @description Основная функция парсера, обрабатывает список токенов и создает AST
; @param tokens - список токенов для парсинга
; @return Абстрактное синтаксическое дерево (AST)
; @example
;   parser token_list
_function parser
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

; @function next
; @description Переходит к следующему токену в потоке
; @return Следующий токен
; @example
;   next
_function next, rbx
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

; @function skip_newline
; @description Пропускает символы новой строки
; @return Нет возвращаемого значения
; @example
;   skip_newline
_function skip_newline
  token_check_type [токен], [ТИП_ПЕРЕНОС_СТРОКИ]
  cmp rax, 1
  jne .no_newline
    next
  .no_newline:

  ret

; @function revert
; @description Возвращается назад на указанное количество токенов
; @param amount=0 - количество токенов для возврата (по умолчанию 0)
; @return Нет возвращаемого значения
; @example
;   revert 2
_function revert
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

; @function update_token
; @description Обновляет текущий токен
; @example
;   update_token
_function update_token, rax, rbx
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

; @function expression
; @description Парсит выражение
; @return Узел выражения
; @example
;   expression
_function expression, rbx, rcx, rdx, r8, r9, r10, r11, r12
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

          raw_string "Ожидался идентификатор"
          error_raw rax
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

; @function binary_operation
; @description Парсит бинарную операцию
; @param operators - список операторов
; @param left_function - функция для парсинга левого операнда
; @param right_function=0 - функция для парсинга правого операнда
; @return Узел бинарной операции
; @example
;   binary_operation ["+", "-"], atom
_function binary_operation, rbx, rcx, rdx, r8, r9, r10, r11, r12
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

; @function atom
; @description Парсит атомарное выражение
; @return Узел атомарного выражения
; @example
;   atom
_function atom, rbx, rcx, rdx, r8, r9
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

  token_check_keyword rbx, [ИСТИНА]
  cmp rax, 1
  je .boolean

  token_check_keyword rbx, [ЛОЖЬ]
  cmp rax, 1
  je .boolean

  jmp .not_boolean

  .boolean:
    next

    boolean_node rbx
    ret

  .not_boolean:

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

    .while:
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

      string "Ожидались: "
      mov rcx, rax

      list
      mov rbx, rax
      list_append_link rbx, rax
      string "идентификатор"
      list_append_link rbx, rax
      type_to_string INTEGER
      list_append_link rbx, rax
      type_to_string STRING
      list_append_link rbx, rax
      string "`(`"
      list_append_link rbx, rax

      string ", "
      join rbx, rax
      string_extend_links rcx, rax

      error rax
      exit -1

      .add_key:

      list_append_link rcx, rax
      jmp .while

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

      raw_string "atom: Ожидалось `)`"
      error_raw rax
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

    string "atom: Ожидались: "
    mov rcx, rax

    list
    mov rbx, rax
    string "ключевое слово"
    list_append_link rbx, rax
    string "идентификатор"
    list_append_link rbx, rax
    type_to_string INTEGER
    list_append_link rbx, rax
    type_to_string FLOAT
    list_append_link rbx, rax
    type_to_string STRING
    list_append_link rbx, rax
    type_to_string LIST
    list_append_link rbx, rax

    string ", "
    join rbx, rax
    string_extend_links rcx, rax

    string ". Получено"
    string_extend_links rcx, rax

    list
    list_append_link rax, rcx
    list_append_link rax, [токен]
    error rax
    exit -1

  .correct_expression:

  mov rax, rbx
  ret

; @function call_expression
; @description Парсит вызов функции
; @return Узел вызова функции
; @example
;   call_expression
_function call_expression, rbx, rcx, rdx, r8, r9, r10, r11
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

    raw_string "Ожидалось `)`"
    error_raw rax
    exit -1

  .correct_token:

  next

  call_node rbx, rcx, rdx
  ret

; @function power_root
; @description Парсит возведение в степень и извлечение корня
; @return Узел операции возведения в степень или извлечения корня
; @example
;   power_root
_function power_root
  list
  list_append_link rax, [ТИП_ВОЗВЕДЕНИЕ_В_СТЕПЕНЬ]
  list_append_link rax, [ТИП_ИЗВЛЕЧЕНИЕ_КОРНЯ]

  binary_operation rax, f_call_expression, f_factor

  ret

; @function factor
; @description Парсит множитель (фактор)
; @return Узел множителя
; @example
;   factor
_function factor, rbx
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

; @function term
; @description Парсит терм (слагаемое)
; @return Узел терма
; @example
;   term
_function term
  list
  list_append_link rax, [ТИП_УМНОЖЕНИЕ]
  list_append_link rax, [ТИП_ДЕЛЕНИЕ]

  binary_operation rax, f_factor
  ret

; @function comparison_expression
; @description Парсит выражение сравнения
; @return Узел выражения сравнения
; @example
;   comparison_expression
_function comparison_expression, rbx
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

; @function arithmetical_expression
; @description Парсит арифметическое выражение
; @return Узел арифметического выражения
; @example
;   arithmetical_expression
_function arithmetical_expression
  list
  list_append_link rax, [ТИП_СЛОЖЕНИЕ]
  list_append_link rax, [ТИП_ВЫЧИТАНИЕ]

  binary_operation rax, f_term

  ret

; @function list_expression
; @description Парсит выражение списка
; @return Узел списка
; @example
;   list_expression
_function list_expression, rbx, rcx, rdx
  token_check_type [токен], [ТИП_ОТКРЫВАЮЩАЯ_СКОБКА_СПИСКА]
  cmp rax, 1
  je .correct_start

    cmp [try], 1
    jne @f
      null
      ret

    @@:

    raw_string "Ожидалось `%(`"
    error_raw rax
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

      raw_string "Ожидалось `)`"
      error_raw rax
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

        raw_string "Ожидалось `:`"
        error_raw rax
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

; @function check_expression
; @description Парсит условную конструкцию check
; @return Узел условной конструкции check
; @example
;   check_expression
_function check_expression, rbx, rcx, rdx, r8, r9, r11, r13, r14
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

    raw_string "Ожидалось `проверить`"
    error_raw rax
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

    raw_string "Ожидались оператор сравнения или перенос строки"
    error_raw rax
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

      raw_string "Ожидался перенос строки"
      error_raw rax
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

    raw_string "Ожидалось `при`"
    error_raw rax
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

      raw_string "Ожидался перенос строки"
      error_raw rax
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

; @function if_expression
; @description Парсит условную конструкцию if
; @return Узел условной конструкции if
; @example
;   if_expression
_function if_expression, rbx, rcx, rdx, r8, r9
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

; @function else_expression
; @description Парсит блок else
; @return Узел блока else
; @example
;   else_expression
_function else_expression, rbx, rcx
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

; @function for_expression
; @description Парсит цикл for
; @return Узел цикла for
; @example
;   for_expression
_function for_expression, rbx, rcx, rdx, r8, r9, r10, r11
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

; @function while_expression
; @description Парсит цикл while
; @return Узел цикла while
; @example
;   while_expression
_function while_expression, rbx, rcx, r8, r9, r10, r11
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

; @function function_expression
; @description Парсит определение функции или метода
; @param is_method=0 - флаг, указывающий что это метод
; @return Узел функции или метода
; @example
;   function_expression 1  ; для метода
;   function_expression    ; для функции
_function function_expression, r10, r8, r9, rbx, rcx, rdx
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

; @function class_expression
; @description Парсит определение класса
; @return Узел класса
; @example
;   class_expression
_function class_expression, rbx, rcx, rdx, r8, r9
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

; @function delete_expression
; @description Парсит оператор delete
; @return Узел оператора delete
; @example
;   delete_expression
_function delete_expression, rbx
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

; @function include_statement
; @description Парсит оператор include
; @return Узел оператора include
; @example
;   include_statement
_function include_statement, rbx, rcx
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

; @function statement
; @description Парсит оператор (statement)
; @return Узел оператора
; @example
;   statement
_function statement, rbx, rcx
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

      integer_sub [индекс], rbx
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
