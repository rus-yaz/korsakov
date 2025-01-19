section "data" writable
  результат  rq 1

  INVALID_SYNTAX_ERROR db "Неверный синтаксис", 0
  EXPECTED             db "Ожидалось:", 0
  LIST_LENGTH_EXPECTED db "ожидалось", 0
  LIST_LENGTH_RECEIVED db "получено", 0
  SEQUENCE             db "последовательность элементов", 0
  NEWLINE              db "перенос строки", 0
  COMPARISONS          db "операция сравнения", 0
  END_OF_CONTRUCTION   db "конец конструкции", 0
  NAMED_ARGUMENT       db "именованный аргумент", 0
  MODULE_NAME          db "название модуля", 0

  CONTINUE_USAGE_ERROR   db "`продолжить` может использоваться только в цикле", 0
  METHOD_ARGUMENTS_ERROR db "Метод должен иметь хотя бы один аргумент, в который будет помещён сам объект", 0

  IDENTIFIER           db "Идентификатор", 0
  INTEGER_TYPE_NAME    db "Целое число", 0
  FLOAT_TYPE_NAME      db "Вещественное число", 0
  LIST_TYPE_NAME       db "Список", 0
  STRING_TYPE_NAME     db "Строка", 0
  OPEN_PAREN           db "Открывающая скобка", 0
  CLOSED_PAREN         db "Закрывающая скобка", 0
  OPEN_LIST_PAREN      db "Открывающая скобка списка", 0
  CLOSED_LIST_PAREN    db "Закрывающая скобка списка", 0
  KEYWORD              db "Ключевое слово", 0
  SPACE                db "Пробел", 0
  COLON                db "Двоеточие", 0
  CHECK                db "`проверить`", 0
  ON_KEYWORD           db "`при`", 0
  FROM_KEYWORD         db "`от`", 0
  IF_KEYWORD           db "`если`", 0
  FOR                  db "`для`", 0
  WHILE_KEYWORD        db "`пока`", 0
  THEN                 db "`то`", 0
  TO                   db "`до`", 0
  OF                   db "`из`", 0
  FUNCTION             db "`функция`", 0
  DELETE               db "`удалить`", 0
  INCLUDE_KEYWORD      db "`включить`", 0

section "parser" executable

macro parser tokens* {
  enter tokens

  call f_parser

  return
}

macro next {
  enter

  call f_next

  return
}

macro reverse amount = 0 {
  enter amount

  call f_reverse

  return
}

macro update_token {
  enter

  call f_update_token

  leave
}

macro token_check_type token*, types* {
  enter token, types

  call f_token_check_type

  return
}

macro token_check_keyword token*, keywords* {
  enter token, keywords

  call f_token_check_keyword

  return
}

macro expression {
  enter

  call f_expression

  return
}

macro binary_operation operators*, left_function*, right_function = 0 {
  enter operators, left_function, right_function

  call f_binary_operation

  return
}

macro atom {
  enter

  call f_atom

  return
}

macro call_expression {
  enter

  call f_call_expression

  return
}

macro power_root {
  enter

  call f_power_root

  return
}

macro factor {
  enter

  call f_factor

  return
}

macro term {
  enter

  call f_term

  return
}

macro comparison_expression {
  enter

  call f_comparison_expression

  return
}

macro arithmetical_expression {
  enter

  call f_arithmetical_expression

  return
}

macro arithmetical_expression {
  enter

  call f_arithmetical_expression

  return
}

macro list_expression {
  enter

  call f_list_expression

  return
}

macro check_expression {
  enter

  call f_check_expression

  return
}

macro if_expression {
  enter

  call f_if_expression

  return
}

macro else_expression {
  enter

  call f_else_expression

  return
}

macro for_expression {
  enter

  call f_else_expression

  return
}

macro while_expression {
  enter

  call f_while_expression

  return
}

macro function_expression is_method = 0 {
  enter is_method

  call f_function_expression

  return
}

macro class_expression {
  enter

  call f_class_expression

  return
}

macro delete_expression {
  enter

  call f_delete_expression

  return
}

macro include_statement {
  enter

  call f_include_statement

  return
}

macro statements {
  enter

  call f_statements

  return
}

macro statement {
  enter

  call f_statement

  return
}

macro include_statement {
  enter

  call f_include_statement

  return
}

f_parser:
  check_type rax, LIST

  ; Инициализация
  mov [токены], rax

  integer 0
  mov [индекс], rax

  next

  ; self.parse
  list
  mov [результат], rax

  .while:
    token_check_type [токен], [ТИП_КОНЕЦ_ФАЙЛА]
    cmp rax, 1
    je .end_while

    statement
    list_append [результат], rax

    next

    jmp .while

  .end_while:

  mov rax, [результат]
  ret

f_next:
  mov rbx, [индекс]
  mov rbx, [rbx + INTEGER_HEADER*8]

  list_length [токены]
  cmp rax, rbx
  jl .continue
    list_get [токены], [индекс]
    mov [токен], rax

  .continue:

  integer_inc [индекс]

  mov rax, [индекс]
  ret

f_reverse:
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

    list_get [токены], rax
    mov [токен], rax

  .skip:
  ret

f_token_check_type:
  ; RAX — token
  ; RBX — types

  check_type rax, DICTIONARY

  dictionary_get rax, [тип]
  mov rcx, rax

  mov rdx, [rbx]
  cmp rdx, LIST
  je .list

    list
    list_append rax, rbx
    mov rbx, rax

  .list:

  integer 0
  mov r8, rax

  list_length rbx
  integer rax
  mov r9, rax

  .while:
    is_equal r9, r8
    cmp rax, 1
    je .return_false

    list_get rbx, r8
    is_equal rax, rcx

    cmp rax, 1
    je .end_while

    integer_inc r8
    jmp .while

  .return_false:
  mov rax, 0

  .end_while:
  ret

f_token_check_keyword:
  ; RBX — keywords
  ; RCX — token

  check_type rax, DICTIONARY
  dictionary_get rax, [значение]
  mov rcx, rax

  mov rdx, [rbx]
  cmp rdx, LIST
  je .list
    list
    list_append rax, rbx

    mov rbx, rax

  .list:

  integer 0
  mov r8, rax

  list_length rbx
  integer rax
  mov r9, rax

  .while:

    is_equal r8, r9
    cmp rax, 1
    je .end_while

    list_get rbx, r8
    is_equal rax, rcx
    cmp rax, 1
    jmp .end_while

    integer_inc r9
    jmp .while

  .end_while:
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
    dictionary_copy [токен]
    mov rcx, rax

    list
    mov rdx, rax

    next

    .identifier_while:
      token_check_type [токен], [ТИП_ТОЧКА]
      cmp rax, 1
      jne .identifier_end_while

      next

      term
      list_append rdx, rax

      jmp .identifier_while

    .identifier_end_while:

    list_node rdx
    mov rdx, rax

    mov r8, 0

    token_check_type [токен], [ТИП_СЛОЖЕНИЕ]
    cmp rax, 1
    jne .skip_operator
    token_check_type [токен], [ТИП_ВЫЧИТАНИЕ]
    cmp rax, 1
    jne .skip_operator
    token_check_type [токен], [ТИП_УМНОЖЕНИЕ]
    cmp rax, 1
    jne .skip_operator
    token_check_type [токен], [ТИП_ДЕЛЕНИЕ]
    cmp rax, 1
    jne .skip_operator
    ;token_check_type [токен], [ТИП_ВОЗВЕДЕНИЕ_В_СТЕПЕНЬ]
    ;cmp rax, 1
    ;jne .skip_operator

      dictionary_copy [токен]
      mov r8, rax

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
        print INVALID_SYNTAX_ERROR, "", ": "

        print LIST_LENGTH_EXPECTED, "", " "

        list_length rcx
        integer rax
        print rax, "", ", "

        print LIST_LENGTH_RECEIVED, "", " "
        list_length rdx
        integer rax
        print rax

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
        cmp rax, 1
        je .list_end_while

        list_get rcx, r9
        token_check_type rax, [УЗЕЛ_ДОСТУПА_К_ПЕРЕМЕННОЙ]
        cmp rax, 1
        je .skip_access_error

          print <EXPECTED, IDENTIFIER>
          exit -1

        .skip_access_error:

        dictionary_get rcx, [переменная]
        mov r10, rax

        dictionary_get rcx, [ключи]
        mov r11, rax

        list_get rdx, r9
        mov r12, rax

        assign_node r10, r11, r12
        list_append r8, rax

        jmp .list_while

      .list_end_while:

      list_node r8
      ret

    .skip_list_assign:

    jmp .revert

  .skip_list:

  .revert:

  integer_sub [индекс], rbx
  reverse rax

  list
  list_append rax, [И]
  list_append rax, [ИЛИ]

  binary_operation rax, f_comparison_expression

  ret

f_binary_operation:
  ; RBX — left_function
  ; RCX — right_function = 0
  ; RDX — operators
  ; R8  — left
  ; R9  — left_operator
  ; R10 — middle
  ; R11 — right_operator
  ; R12 — right

  mov rdx, rax ; Сохранение операторов

  cmp rcx, 0
  jne .not_default
    mov rcx, rbx

  .not_default:

  enter rbx
  call rax
  return
  mov r8, rax

  .while:
    token_check_type [токен], rdx
    cmp rax, 1
    je .condition_true

    token_check_keyword [токен], rdx
    cmp rax, 1
    jne .end_while

    .condition_true:

    dictionary_copy [токен]
    mov r9, rax

    next

    enter rcx
    call rax
    return
    mov r10, rax

    binary_operation_node r8, r9, r10
    mov r8, rax

    cmp rdx, [СРАВНЕНИЯ]
    jne .skip_comparison

    token_check_type [токен], [СРАВНЕНИЯ]
    cmp rax, 1
    jne .skip_comparison

      dictionary_copy [токен]
      mov r11, rax

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

  list
  list_append rax, [ТИП_ЦЕЛОЕ_ЧИСЛО]
  list_append rax, [ТИП_ВЕЩЕСТВЕННОЕ_ЧИСЛО]
  token_check_type rbx, rax
  cmp rax, 1
  jne .not_number
    next

    number_node rbx
    ret

  .not_number:

  token_check_type rbx, [ТИП_СТРОКА]
  cmp rax, 1
  jne .not_string
    next

    string_node rbx
    ret

  .not_string:

  token_check_type rbx, [ТИП_ИДЕНТИФИКАТОР]
  cmp rax, 1
  jne .not_identifier

    integer 2
    integer_sub [индекс], rax
    list_get [токены], rax
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
      list_append rax, [ТИП_ИДЕНТИФИКАТОР]
      list_append rax, [ТИП_СТРОКА]
      list_append rax, [ТИП_ЦЕЛОЕ_ЧИСЛО]
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

      print <EXPECTED>, "", " "
      print <IDENTIFIER, INTEGER_TYPE_NAME, STRING_TYPE_NAME, OPEN_PAREN>, ", "
      exit -1

      .add_key:

      list_append rcx, rax

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

    token_check_type rbx, [ТИП_ОТКРЫВАЮЩАЯ_СКОБКА_СПИСКА]
    cmp rax, 1
    jne .correct_token

      print <EXPECTED, CLOSED_PAREN>
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
    print EXPECTED, "", " "
    print <KEYWORD, INTEGER_TYPE_NAME, FLOAT_TYPE_NAME, STRING_TYPE_NAME, IDENTIFIER, LIST_TYPE_NAME>, ", "
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

  ; RCX — argument_nodes
  list
  mov rcx, rax

  token_check_type [токен], [ТИП_ПЕРЕНОС_СТРОКИ]
  cmp rax, 1
  jne .skip_newline_1
    next

  .skip_newline_1:

  token_check_type [токен], [ТИП_ЗАКРЫВАЮЩАЯ_СКОБКА]
  cmp rax, 1
  jne .parse_arguments
    next

    call_node rbx, rcx
    ret

  .parse_arguments:

  expression
  list_append rcx, rax

  .while:
    token_check_type [токен], [ТИП_ПРОБЕЛ]
    cmp rax, 1
    jne .end_while

    next

    token_check_type [токен], [ТИП_ПЕРЕНОС_СТРОКИ]
    cmp rax, 1
    jne .skip_newline_2
      next

    .skip_newline_2:

    expression
    list_append rcx, rax

    jmp .while

  .end_while:

  token_check_type [токен], [ТИП_ПЕРЕНОС_СТРОКИ]
  cmp rax, 1
  jne .skip_newline_3
    next

  .skip_newline_3:

  token_check_type [токен], [ТИП_ЗАКРЫВАЮЩАЯ_СКОБКА]
  cmp rax, 1
  je .correct_token
    print EXPECTED, "", " "
    print <SEQUENCE, CLOSED_PAREN>, ", "
    exit -1

  .correct_token:

  next

  call_node rbx, rcx
  ret

f_power_root:
  list
  list_append rax, [ТИП_ВОЗВЕДЕНИЕ_В_СТЕПЕНЬ]
  list_append rax, [ТИП_ИЗЪЯТИЕ_КОРНЯ]

  binary_operation rax, f_call_expression, f_factor

  ret

f_factor:
  ; RBX — token
  dictionary_copy [токен]
  mov rbx, rax

  list
  list_append rax, [ТИП_ВЫЧИТАНИЕ]
  list_append rax, [ТИП_ИЗЪЯТИЕ_КОРНЯ]
  list_append rax, [ТИП_ИНКРЕМЕНТАЦИЯ]
  list_append rax, [ТИП_ДЕКРЕМЕНТАЦИЯ]

  token_check_type rbx, rax
  cmp rax, 1
  je .pre_unary_operation
    power_root
    ret

  .pre_unary_operation:

  next

  ; RCX — factor

  factor
  unary_operation_node rbx, rax

  ret

f_term:
  list
  list_append rax, [ТИП_УМНОЖЕНИЕ]
  list_append rax, [ТИП_ДЕЛЕНИЕ]

  binary_operation rax, f_factor
  ret

f_comparison_expression:
  token_check_type [токен], [НЕ]
  cmp rax, 1
  jne .not_unary
    dictionary_copy [токен]
    mov rbx, rax

    next

    comparison_expression
    unary_operation_node rbx, rax

    ret

  .not_unary:

  binary_operation [СРАВНЕНИЯ], f_arithmetical_expression

  ret

f_arithmetical_expression:
  list
  list_append rax, [ТИП_СЛОЖЕНИЕ]
  list_append rax, [ТИП_ВЫЧИТАНИЕ]

  binary_operation rax, f_term

  ret

f_list_expression:
  ; RBX — value
  ; RCX — is_dictionary

  dictionary
  mov rbx, rax

  mov rcx, 0

  token_check_type [токен], [ТИП_ОТКРЫВАЮЩАЯ_СКОБКА_СПИСКА]
  cmp rax, 1
  je .correct_token
    string "%("
    print <EXPECTED, rax>
    exit -1

  .correct_token:

  next

  token_check_type [токен], [ТИП_ПЕРЕНОС_СТРОКИ]
  cmp rax, 1
  jne .skip_newline_1
    next

  .skip_newline_1:

  token_check_type [токен], [ТИП_ЗАКРЫВАЮЩАЯ_СКОБКА]
  cmp rax, 1
  jne .not_empty

    next

    list
    list_node rax

    ret

  .not_empty:

  ; RDX — key_node

  expression
  mov rdx, rax

  null
  mov r8, rax

  token_check_type [токен], [ТИП_ДВОЕТОЧИЕ]
  cmp rax, 1
  jne .not_dictionary
    mov rcx, 1

    ; R8  — value_node

    expression
    mov r8, rax

  .not_dictionary:

  ; R9 — value

  dictionary
  dictionary_set rax, rdx, r8
  mov r9, rax

  .while:
    token_check_type [токен], [ТИП_ЗАКРЫВАЮЩАЯ_СКОБКА]
    cmp rax, 1
    je .end_while

    token_check_type [токен], [ТИП_ПЕРЕНОС_СТРОКИ]
    cmp rax, 1
    jne .skip_newline_2
      next

    .skip_newline_2:

    expression
    mov rdx, rax

    null
    mov r8, rax

    cmp rcx, 1
    je .skip_dictionary_append_error

    token_check_type [токен], [ТИП_ДВОЕТОЧИЕ]
    cmp rax, 1
    jne .skip_dictionary_append_error

      print <EXPECTED, SPACE>
      exit -1

    .skip_dictionary_append_error:

    cmp rcx, 1
    jne .skip_dictionary_append

      token_check_type [токен], [ТИП_ДВОЕТОЧИЕ]
      cmp rax, 1
      je .skip_colon_error
        print <EXPECTED, COLON>
        exit -1

      .skip_colon_error:

      next

      expression
      mov r8, rax

    .skip_dictionary_append:

    dictionary_set r9, rdx, r8

    jmp .while

  .end_while:

  token_check_type [токен], [ТИП_ПЕРЕНОС_СТРОКИ]
  cmp rax, 1
  jne .skip_newline_3
    next

  .skip_newline_3:

  token_check_type [токен], [ТИП_ЗАКРЫВАЮЩАЯ_СКОБКА]
  cmp rax, 1
  je .skip_closed_paren_error
    print <EXPECTED>, "", " "
    print <SPACE, CLOSED_LIST_PAREN>, ", "
    exit -1

  .skip_closed_paren_error:

  next

  cmp rcx, 1
  jne .skip_dictionary_return
    dictionary_items r9
    dictionary_node rax

    ret

  .skip_dictionary_return:

  dictionary_keys r9
  list_node rax

  ret

f_check_expression:
  ; RBX — cases
  ; RCX — else_case

  list
  mov rbx, rax

  mov rcx, 0

  token_check_keyword [токен], [ПРОВЕРИТЬ]
  je .correct_start
    print <EXPECTED, CHECK>
    exit -1

  .correct_start:

  next

  ; RDX — left

  arithmetical_expression
  mov rdx, rax

  ; R8 — operator
  dictionary
  dictionary_set rax, [тип], [РАВНО]
  mov r8, rax

  list_copy [СРАВНЕНИЯ]
  list_append rax, [ПЕРЕНОС_СТРОКИ]
  token_check_type [токен], rax
  je .skip_condition_error
    print EXPECTED, "", " "
    print <COMPARISONS, NEWLINE>, ", "
    exit -1

  .skip_condition_error:

  token_check_type [токен], [СРАВНЕНИЯ]
  jne .skip_condition
    dictionary_copy [токен]
    mov r8, rax

    next

    token_check_type [токен], [ПЕРЕНОС_СТРОКИ]
    cmp rax, 1
    jne .skip_newline_error_2
      print <EXPECTED, NEWLINE>
      exit -1

    .skip_newline_error_1:

  .skip_condition:

  next

  token_check_keyword [токен], [ПРИ]
  cmp rax, 1
  je .correct_on
    print <EXPECTED, ON_KEYWORD>
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
      list_append rax, [И]
      list_append rax, [ИЛИ]
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
      print <EXPECTED, NEWLINE>
      exit -1

    .skip_newline_error_2:

    next

    ; R13 — body

    list
    mov r13, rax

    .on_else_while:

      list
      list_append rax, [ПРИ]
      list_append rax, [ИНАЧЕ]
      token_check_keyword [токен], rax
      cmp rax, 1
      je .end_on_else_while

      statement
      list_append r13, rax

      integer -1
      list_get r13, rax
      dictionary_get rax, [тип]
      is_equal rax, [ПРОПУСТИТЬ]
      cmp rax, 1
      jne .skip_continue_error
        print CONTINUE_USAGE_ERROR
        exit -1

      .skip_continue_error:

      next

      jmp .on_else_while

    .end_on_else_while:

    list_node r13
    mov r13, rax

    list
    list_append rax, r11
    list_append rax, r13
    list_append rax, 0

    list_append rbx, rax

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

  mov rcx, 0

  token_check_keyword [токен], [ЕСЛИ]
  cmp rax, 1
  je .correct_token_if
    print <EXPECTED, IF_KEYWORD>
    exit -1

  .correct_token_if:

  next

  ; RDX — condition

  expression
  mov rdx, rax

  token_check_keyword [токен], [ТО]
  cmp rax, 1
  je .correct_token_then
    print <EXPECTED, THEN>
    exit -1

  .correct_token_then:

  next

  token_check_type [токен], [ПЕРЕНОС_СТРОКИ]
  cmp rax, 1
  jne .make_oneline
    next

    ; R8 — statements

    statements
    mov r8, rax

    list
    list_append rax, rdx
    list_append rax, r8
    list_append rax, 1

    list_append rbx, rax

    token_check_type [токен], [ТИП_КОНЕЦ_КОНСТРУКЦИИ]
    cmp rax, 1
    jne .parse_other_branches
      next

      if_node rbx, rcx
      ret

    .parse_other_branches:

    jmp .continue

  .make_oneline:

    ; R9 — expression

    statement
    mov r9, rax

    list
    list_append rax, rdx
    list_append rax, r9
    list_append rax, 0

    list_append rbx, rax

  .continue:

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

  token_check_keyword [токен], [ИНАЧЕ]
  cmp rax, 1
  je .make_multiline
    statement
    mov rbx, rax

    list
    list_append rax, rbx
    list_append rax, 0

    ret

  .make_multiline:

  next

  ; RCX — statements

  statements
  mov rcx, rax

  token_check_type [токен], [ТИП_КОНЕЦ_КОНСТРУКЦИИ]
  cmp rax, 1
  je .correct_token
    print <EXPECTED, END_OF_CONTRUCTION>
    exit -1

  .correct_token:

  next

  list
  list_append rax, rcx
  list_append rax, 1

  ret

f_for_expression:
  ; RBX — else_case
  mov rbx, 0

  token_check_keyword [токен], [ДЛЯ]
  cmp rax, 1
  je .correct_for
    print <EXPECTED, FOR>
    exit -1

  .correct_for:

  next

  token_check_type [токен], [ТИП_ИДЕНТИФИКАТОР]
  cmp rax, 1
  je .correct_identifier
    print <EXPECTED, IDENTIFIER>
    exit -1

  .correct_identifier:

  ; RCX — variable_name

  dictionary_copy [токен]
  mov rcx, rax

  next

  token_check_type [токен], [ОТ]
  cmp rax, 1
  jne .loop_with_enter

    next

    ; RDX — start_value

    expression
    mov rdx, rax

    token_check_type [токен], [ДО]
    cmp rax, 1
    je .correct_to
      print <EXPECTED, TO>
      exit -1

    .correct_to:

    next

    ; R8 — end_value

    expression
    mov r8, rax

    token_check_type [токен], [ЧЕРЕЗ]
    cmp rax, 1
    je .loop_without_custom_step
      next

      ; R9 — step_value

      expression
      mov r9, rax

      jmp .continue

    .loop_without_custom_step:

    mov r9, 0

    .continue:

    jmp .if_end

  .loop_with_enter:

  token_check_keyword [токен], [ИЗ]
  cmp rax, 1
  jne .unknown_token

    ; R10 — start_value

    expression
    mov r10, rax

    mov r9, 0
    mov r8, 0

    jmp .if_end

  .unknown_token:
    print <EXPECTED>, "", " "
    print <FROM_KEYWORD, OF>, ", "
    exit -1

  .if_end:

  token_check_type [токен], [ПЕРЕНОС_СТРОКИ]
  cmp rax, 1
  jne .make_oneline

    next

    ; R11 — body

    statements
    mov r11, rax

    token_check_type [токен], [ТИП_КОНЕЦ_КОНСТРУКЦИИ]
    cmp rax, 1
    jne .check_else

      next

      jmp .return

    .check_else:

      else_expression
      mov rbx, rax

    .return:

    for_node rcx, r10, r8, r9, r11, 1, rbx
    ret

  .make_oneline:

  token_check_type [токен], [ДВОЕТОЧИЕ]
  cmp rax, 1
  je .correct_colon
    print <EXPECTED, COLON>
    exit -1

  .correct_colon:

  next

  statement
  for_node rcx, r10, r8, r9, rax, 0, 0

  ret

f_while_expression:
  ; RBX — else_case

  mov rbx, 0

  token_check_keyword [токен], [ПОКА]
  cmp rax, 1
  je .correct_while
    print <EXPECTED, WHILE_KEYWORD>
    exit -1

  .correct_while:

  next

  ; RCX — condition

  expression
  mov rcx, rax

  token_check_type [токен], [ПЕРЕНОС_СТРОКИ]
  cmp rax, 1
  jne .make_multiline

    next

    ; RDX — body

    statements
    mov rdx, rax

    token_check_type [токен], [ТИП_КОНЕЦ_КОНСТРУКЦИИ]
    cmp rax, 1
    jne .parse_else
      next

      jmp .return

    .parse_else:
      else_expression
      mov rbx, rax

    .return:

    while_node rcx, rdx, 1, rbx
    ret

  .make_multiline:

  token_check_type [токен], [ДВОЕТОЧИЕ]
  cmp rax, 1
  je .correct_colon
    print <EXPECTED, COLON>
    exit -1

  .correct_colon:

  next

  statement
  while_node rcx, rax, 0, 0

  ret

f_function_expression:
  ; RBX — is_method

  token_check_keyword [токен], [ФУНКЦИЯ]
  cmp rax, 1
  je .correct_function
    print <EXPECTED, FUNCTION>
    exit -1

  .correct_function:

  next

  ; RCX — variable_name

  mov rcx, 0
  token_check_type [токен], [ТИП_ИДЕНТИФИКАТОР]
  cmp rax, 1
  jne .unnamed_function

    dictionary_copy [токен]
    mov rcx, rax

    next

  .unnamed_function:

  token_check_type [токен], [ОТКРЫВАЮЩАЯ_СКОБКА]
  cmp rax, 1
  je .correct_open_paren
    print <EXPECTED, OPEN_PAREN>
    exit -1

  .correct_open_paren:

  next

  ; RDX — arguments

  list
  mov rdx, rax

  .while:
    token_check_type [токен], [ТИП_ИДЕНТИФИКАТОР]
    cmp rax, 1
    jne .end_while

    ; R8 — argument
    expression
    mov r8, rax

    cmp r8, 0
    jne .correct_argument

    integer -1
    list_get rdx, rax
    dictionary_get rax, [узел]
    is_equal rax, [УЗЕЛ_ПРИСВАИВАНИЯ_ПЕРЕМЕННОЙ]
    cmp rax, 1

    jne .correct_argument

    dictionary_get r8, [узел]
    is_equal rax, [УЗЕЛ_ПРИСВАИВАНИЯ_ПЕРЕМЕННОЙ]
    cmp rax, 1

    jne .correct_argument
      print <EXPECTED, NAMED_ARGUMENT>
      exit -1

    .correct_argument:

    list_append rdx, r8

    token_check_type [токен], [ТИП_ПРОБЕЛ]
    cmp rax, 1
    jne .correct_space
      next

    .correct_space:

    jmp .while

  .end_while:

  token_check_type [токен], [ЗАКРЫВАЮЩАЯ_СКОБКА]
  cmp rax, 1
  je .correct_closed_paren
    print <EXPECTED>, "", " "
    print <IDENTIFIER, CLOSED_PAREN>, ", "
    exit -1

  .correct_closed_paren:

  next

  token_check_type [токен], [ПЕРЕНОС_СТРОКИ]
  cmp rax, 1
  jne .make_oneline
    next

    ; R9 — body

    statements
    mov r9, rax

    token_check_type [токен], [ТИП_КОНЕЦ_КОНСТРУКЦИИ]
    cmp rax, 1
    je .correct_end_construction
      print <EXPECTED, END_OF_CONTRUCTION>
      exit -1

    .correct_end_construction:

    next

    cmp rbx, 0
    je .return_function
      method_node rcx, rdx, r9, 0
      ret

    .return_function:

    function_node rcx, rdx, r9, 0
    ret

  .make_oneline:

  token_check_type [токен], [ДВОЕТОЧИЕ]
  cmp rax, 1
  je .correct_colon
    print <EXPECTED, COLON>
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
    print <EXPECTED, CLASS>
    exit -1

  .correct_class:

  next

  token_check_keyword [токен], [ТИП_ИДЕНТИФИКАТОР]
  cmp rax, 1
  je .correct_identifier
    print <EXPECTED, IDENTIFIER>
    exit -1

  .correct_identifier:

  ; RBX — variable_name
  dictionary_copy [токен]
  mov rbx, rax

  next

  token_check_keyword [токен], [ОТКРЫВАЮЩАЯ_СКОБКА]
  cmp rax, 1
  je .correct_open_paren
    print <EXPECTED, OPEN_PAREN>
    exit -1

  .correct_open_paren:

  ; RCX — parents
  list
  mov rcx, rax

  token_check_type [токен], [ОТКРЫВАЮЩАЯ_СКОБКА]
  cmp rax, 1
  jne .no_parents
    next

    list
    list_append rax, [ТИП_ИДЕНТИФИКАТОР]
    list_append rax, [ЗАКРЫВАЮЩАЯ_СКОБКА]
    token_check_type [токен], rax
    je .correct_identifier_closed_paren_1
      print <EXPECTED>, "", " "
      print <IDENTIFIER, CLOSED_PAREN>, ", "
      exit -1

    .correct_identifier_closed_paren_1:

    .while_1:
      token_check_type [токен], [ТИП_ИДЕНТИФИКАТОР]
      cmp rax, 1
      jne .end_while_1

      dictionary_get [токен], [значение]
      list_append rcx, rax

      next

      token_check_type [токен], [ПЕРЕНОС_СТРОКИ]
      cmp rax, 1
      jne .no_newline_1
        next

      .no_newline_1:

      list
      list_append rax, [ТИП_ПРОБЕЛ]
      list_append rax, [ЗАКРЫВАЮЩАЯ_СКОБКА]
      token_check_type [токен], rax
      cmp rax, 1
      je .correct_space_closed_paren_2
        print <EXPECTED>, "", " "
        print <SPACE, CLOSED_PAREN>, ", "
        exit -1

      .correct_space_closed_paren_2:

      token_check_type [токен], [ПЕРЕНОС_СТРОКИ]
      cmp rax, 1
      jne .no_space
        next

      .no_space:

      jmp .while_1

    .end_while_1:

    list
    list_append rax, [ТИП_ИДЕНТИФИКАТОР]
    list_append rax, [ЗАКРЫВАЮЩАЯ_СКОБКА]
    token_check_type [токен], rax
    cmp rax, 1
    je .correct_identifier_closed_paren_3
      print <EXPECTED>, "", " "
      print <IDENTIFIER, CLOSED_PAREN>, ", "
      exit -1

    .correct_identifier_closed_paren_3:

    next

    token_check_type [токен], [ПЕРЕНОС_СТРОКИ]
    cmp rax, 1
    jne .no_newline_2
      print <EXPECTED, NEWLINE>
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
    print <EXPECTED>
    print <FUNCTION, END_OF_CONTRUCTION>
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

    list_get r8, [аргументы]
    list_length rax
    cmp rax, 1
    jge .correct_arguments
      print METHOD_ARGUMENTS_ERROR
      exit -1

    .correct_arguments:

    ; R9 — method_name
    list_get r8, [имя_переменной]
    string_node rax
    mov r9, rax

    list
    list_append rax, r9
    list_append rax, r8

    list_append rdx, rax

    next

    jmp .while_2

  .end_while_2:

  token_check_type [токен], [ТИП_КОНЕЦ_КОНСТРУКЦИИ]
  cmp rax, 1
  je .correct_end_construction
    print <EXPECTED, END_OF_CONTRUCTION>
    exit -1

  .correct_end_construction:

  ; TODO: проверка существования магического метода инициализации

  next

  dictionary_node rdx
  class_node rbx, rax, rcx

  ret

f_delete_expression:
  token_check_keyword [токен], [УДАЛИТЬ]
  cmp rax, 1
  je .correct_delete
    print <EXPECTED, DELETE>
    exit -1

  .correct_delete:

  next

  token_check_keyword [токен], [ТИП_ИДЕНТИФИКАТОР]
  cmp rax, 1
  je .correct_identifier
    print <EXPECTED, IDENTIFIER>
    exit -1

  .correct_identifier:

  ; RBX — variable
  dictionary_copy [токен]
  mov rbx, rax

  next

  delete_node rbx

  ret

f_include_statement:
  token_check_keyword [токен], [ВКЛЮЧИТЬ]
  cmp rax, 1
  je .correct_include
    print <EXPECTED, INCLUDE_KEYWORD>
    exit -1

  .correct_include:

  next

  token_check_type [токен], [ТИП_СТРОКА]
  cmp rax, 1
  je .correct_module
    print <EXPECTED, MODULE_NAME>
    exit -1

  .correct_module:

  ; RBX — module
  dictionary_copy [токен]
  mov rbx, rax

  next

  include_node rbx

  ret

f_statements:
  ; RBX — statements
  list
  mov rbx, rax

  token_check_type [токен], [ТИП_ПЕРЕНОС_СТРОКИ]
  cmp rax, 1
  jne .no_newline_1
    next

  .no_newline_1:

  ; RCX — statements
  statement
  mov rcx, rax

  list
  list_append rax, rcx
  mov rcx, rax

  ; RDX — more_statements
  mov rdx, 1

  .while:
    ; R8 — newline_count
    integer 0
    mov r8, rax

    ; R9 — index
    dictionary_copy [индекс]
    mov r9, rax

    token_check_type [токен], [ТИП_ПЕРЕНОС_СТРОКИ]
    cmp rax, 1
    jne .no_newline_2
      next
      integer_inc r8

    .no_newline_2:

    integer 0
    is_equal r8, rax
    cmp rax, 1
    jne .check_more_statements
      mov rdx, 0

    .check_more_statements:

    cmp rdx, 1
    jne .end_while

    ; R10 — statement
    statement
    mov r10, rax

    cmp r10, 1
    je .skip_reverse
      integer_copy [индекс]
      integer_sub rax, r9
      reverse rax
      mov rdx, 0

    .skip_reverse:

    list_append rcx, r10

    jmp .while

  .end_while:

  list_node rcx
  ret

f_statement:
  token_check_keyword [токен], [ВЕРНУТЬ]
  cmp rax, 1
  jne .not_return
    ; RBX — index
    integer_copy [индекс]
    mov rbx, rax

    next

    ; RCX — expression
    expression
    mov rcx, rax

    cmp rcx, 0
    jne .return_value
      integer_copy [индекс]
      integer_sub rax, rbx
      reverse rax

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
