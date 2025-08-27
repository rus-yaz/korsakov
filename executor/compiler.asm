; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

macro add_code [code*] {
  string code
  list_append_link rdx, rax
}

; @function compiler
; @debug
; @description Основная функция компилятора, компилирует AST в машинный код
; @param ast - абстрактное синтаксическое дерево
; @param context - контекст компиляции
; @return Скомпилированный машинный код
; @example
;   compiler ast_tree, compilation_context
_function compiler, rbx, rcx, rdx, r8
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
    compile rax, rcx
    list_extend_links r8, rax
    string ""
    list_append_link r8, rax

    integer_inc rdx
    jmp .while

  .end_while:

  string 10
  join_links r8, rax

  ret

; @function compile
; @debug
; @description Компилирует отдельный узел AST
; @param node - узел AST для компиляции
; @param context - контекст компиляции
; @return Скомпилированный код для узла
; @example
;   compile node, context
_function compile, rbx, rcx
  get_arg 1
  mov rbx, rax
  get_arg 0
  mov rcx, rax

  mov rax, [rcx]
  cmp rax, LIST
  jne @f
    compile_body rbx, rcx
    ret
  @@:

  check_node_type rcx, [УЗЕЛ_ПРИСВАИВАНИЯ_ПЕРЕМЕННОЙ]
  cmp rax, 1
  jne @f
    compile_assign rbx, rcx
    ret
  @@:

  check_node_type rcx, [УЗЕЛ_ДОСТУПА_К_ПЕРЕМЕННОЙ]
  cmp rax, 1
  jne @f
    compile_access rbx, rcx
    ret
  @@:

  check_node_type rcx, [УЗЕЛ_УНАРНОЙ_ОПЕРАЦИИ]
  cmp rax, 1
  jne @f
    compile_unary_operation rbx, rcx
    ret
  @@:

  check_node_type rcx, [УЗЕЛ_БИНАРНОЙ_ОПЕРАЦИИ]
  cmp rax, 1
  jne @f
    compile_binary_operation rbx, rcx
    ret
  @@:

  check_node_type rcx, [УЗЕЛ_НУЛЬ]
  cmp rax, 1
  jne @f
    compile_null rbx, rcx
    ret
  @@:

  check_node_type rcx, [УЗЕЛ_ЦЕЛОГО_ЧИСЛА]
  cmp rax, 1
  jne @f
    compile_integer rbx, rcx
    ret
  @@:

  check_node_type rcx, [УЗЕЛ_ВЕЩЕСТВЕННОГО_ЧИСЛА]
  cmp rax, 1
  jne @f
    compile_float rbx, rcx
    ret
  @@:

  check_node_type rcx, [УЗЕЛ_ЛОГИЧЕСКОГО_ЗНАЧЕНИЯ]
  cmp rax, 1
  jne @f
    compile_boolean rbx, rcx
    ret
  @@:

  check_node_type rcx, [УЗЕЛ_СПИСКА]
  cmp rax, 1
  jne @f
    compile_list rbx, rcx
    ret
  @@:

  check_node_type rcx, [УЗЕЛ_СТРОКИ]
  cmp rax, 1
  jne @f
    compile_string rbx, rcx
    ret
  @@:

  check_node_type rcx, [УЗЕЛ_СЛОВАРЯ]
  cmp rax, 1
  jne @f
    compile_dictionary rbx, rcx
    ret
  @@:

  check_node_type rcx, [УЗЕЛ_ЕСЛИ]
  cmp rax, 1
  jne @f
    compile_if rbx, rcx
    ret
  @@:

  check_node_type rcx, [УЗЕЛ_ПОКА]
  cmp rax, 1
  jne @f
    compile_while rbx, rcx
    ret
  @@:

  check_node_type rcx, [УЗЕЛ_ДЛЯ]
  cmp rax, 1
  jne @f
    compile_for rbx, rcx
    ret
  @@:

  check_node_type rcx, [УЗЕЛ_ПРОПУСКА]
  cmp rax, 1
  jne @f
    compile_skip rbx, rcx
    ret
  @@:

  check_node_type rcx, [УЗЕЛ_ПРЕРЫВАНИЯ]
  cmp rax, 1
  jne @f
    compile_break rbx, rcx
    ret
  @@:

  check_node_type rcx, [УЗЕЛ_ФУНКЦИИ]
  cmp rax, 1
  jne @f
    compile_function rbx, rcx
    ret
  @@:

  check_node_type rcx, [УЗЕЛ_ВЫЗОВА]
  cmp rax, 1
  jne @f
    compile_call rbx, rcx
    ret
  @@:

  check_node_type rcx, [УЗЕЛ_ВОЗВРАЩЕНИЯ]
  cmp rax, 1
  jne @f
    compile_return rbx, rcx
    ret
  @@:

  string "Неизвестный узел:"
  mov rbx, rax
  list
  list_append_link rax, rbx
  list_append_link rax, rcx
  error rax
  exit -1

; @function compile_body
; @debug
; @description Компилирует тело программы (список узлов)
; @param node - узел, содержащий тело программы
; @param context - контекст компиляции
; @return Скомпилированный код тела программы
; @example
;   compile_body body_node, context
_function compile_body, rbx, rcx, rdx, r8, r9
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
    compile rax, rbx
    list_extend_links rdx, rax

    integer_inc r8
    jmp .body_while

  .body_end_while:

  mov rax, rdx
  ret

; @function compile_assign
; @debug
; @description Компилирует присваивание переменной
; @param node - узел присваивания
; @param context - контекст компиляции
; @return Скомпилированный код присваивания
; @example
;   compile_assign assign_node, context
_function compile_assign, rbx, rcx, rdx, r8
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  list
  mov rdx, rax

  add_code "push rdx, rcx, rbx"

  string "значение"
  dictionary_get_link rcx, rax
  mov r8, rax

  null
  is_equal rax, r8
  boolean_value rax
  cmp rax, 1
  je .use_exists_value
    compile r8, rbx
    list_extend_links rdx, rax

  .use_exists_value:

  add_code "mov rdx, rax"

  string "ключи"
  dictionary_get_link rcx, rax
  compile rax, rbx
  list_extend_links rdx, rax
  add_code "mov rcx, rax"

  string "string "
  mov r8, rax
  string "переменная"
  dictionary_get_link rcx, rax
  mov rcx, rax
  string "значение"
  dictionary_get_link rcx, rax
  to_string rax
  string_extend_links r8, rax
  list_append_link rdx, rax

  add_code "mov rbx, rax",\
           "assign rbx, rcx, rdx",\
           "pop rbx, rcx, rdx"

  mov rax, rdx
  ret

; @function compile_access
; @debug
; @description Компилирует доступ к переменной
; @param node - узел доступа к переменной
; @param context - контекст компиляции
; @return Скомпилированный код доступа к переменной
; @example
;   compile_access access_node, context
_function compile_access, rbx, rcx, rdx, r8
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  list
  mov rdx, rax

  add_code "push rcx, rbx"

  string "ключи"
  dictionary_get_link rcx, rax
  compile rax, rbx
  list_extend_links rdx, rax
  add_code "mov rcx, rax"

  string "string "
  mov r8, rax
  string "переменная"
  dictionary_get_link rcx, rax
  mov rcx, rax
  string "значение"
  dictionary_get_link rcx, rax
  to_string rax
  string_extend_links r8, rax
  list_append_link rdx, rax

  add_code "mov rbx, rax",\
           "access rbx, rcx",\
           "pop rbx, rcx"

  mov rax, rdx
  ret

; @function compile_unary_operation
; @debug
; @description Компилирует унарную операцию
; @param node - узел унарной операции
; @param context - контекст компиляции
; @return Скомпилированный код унарной операции
; @example
;   compile_unary_operation unary_node, context
_function compile_unary_operation, rbx, rcx, rdx, r8, r9, r11, r12
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  list
  mov rdx, rax

  string "операнд"
  dictionary_get_link rcx, rax
  compile rax, rbx
  list_extend_links rdx, rax

  null
  mov r8, rax

  string "оператор"
  dictionary_get_link rcx, rax
  mov r9, rax

  token_check_type r9, [ТИП_ИНКРЕМЕНТАЦИЯ]
  cmp rax, 1
  jne .not_increment

    string "операнд"
    dictionary_get_link rcx, rax
    mov r11, rax
    string "переменная"
    dictionary_get_link r11, rax
    mov r12, rax

    token_check_type r12, [ТИП_ИДЕНТИФИКАТОР]
    cmp rax, 1
    je .correct_identifier_increment

      string "Ожидался идентификатор, но получен "
      mov rbx, rax
      list_append_link rax, rbx
      list_append_link rax, r11
      error rax
      exit -1

    .correct_identifier_increment:

    add_code "push rbx, rcx",\
             "mov rcx, rax",\
             "integer_copy rax",\
             "mov rbx, rax",\
             "integer_inc rcx"

    string "ключи"
    dictionary_get_link r11, rax
    assign_node r12, rax, r8
    compile rax, rbx
    list_extend_links rdx, rax

    string "значение"
    dictionary_get_link r9, rax
    boolean_value rax
    cmp rax, 1
    je .not_pre_increment
      add_code "integer_inc rbx"
      jmp .continue_increment

    .not_pre_increment:
      add_code "mov rax, rbx"

    .continue_increment:

    add_code "pop rcx, rbx"
    jmp .continue

  .not_increment:

  token_check_type r9, [ТИП_ДЕКРЕМЕНТАЦИЯ]
  cmp rax, 1
  jne .not_decrement

    string "операнд"
    dictionary_get_link rcx, rax
    mov r11, rax
    string "переменная"
    dictionary_get_link r11, rax
    mov r12, rax

    token_check_type r12, [ТИП_ИДЕНТИФИКАТОР]
    cmp rax, 1
    je .correct_identifier_decrement

      string "Ожидался идентификатор, но получен "
      mov rbx, rax
      list_append_link rax, rbx
      list_append_link rax, r11
      error rax
      exit -1

    .correct_identifier_decrement:

    add_code "push rbx, rcx",\
             "mov rcx, rax",\
             "integer_copy rax",\
             "mov rbx, rax",\
             "integer_dec rcx"

    string "ключи"
    dictionary_get_link r11, rax
    assign_node r12, rax, r8
    compile rax, rbx
    list_extend_links rdx, rax

    string "значение"
    dictionary_get_link r9, rax
    boolean_value rax
    cmp rax, 1
    je .not_pre_decrement
      add_code "integer_dec rbx"
      jmp .continue_decrement

    .not_pre_decrement:
      add_code "mov rax, rbx"

    .continue_decrement:

    add_code "pop rcx, rbx"
    jmp .continue

  .not_decrement:

  string "не"
  token_check_keyword r9, rax
  cmp rax, 1
  jne .not_not

    add_code "boolean_not rax"
    jmp .continue

  .not_not:

  token_check_type r9, [ТИП_ВЫЧИТАНИЕ]
  cmp rax, 1
  jne .not_negate

    add_code "negate rax"
    jmp .continue

  .not_negate:

  string "Неизвестный оператор: "
  mov rbx, rax
  list
  list_append_link rax, rbx
  list_append_link rax, rcx
  error rax
  exit -1

  .continue:

  mov rax, rdx
  ret

; @function compile_binary_operation
; @debug
; @description Компилирует бинарную операцию
; @param node - узел бинарной операции
; @param context - контекст компиляции
; @return Скомпилированный код бинарной операции
; @example
;   compile_binary_operation binary_node, context
_function compile_binary_operation, rbx, rcx, rdx, r8
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  list
  mov rdx, rax

  add_code "push rbx"

  string "правый_узел"
  dictionary_get_link rcx, rax
  compile rax, rbx
  list_extend_links rdx, rax
  add_code "mov rbx, rax"

  string "левый_узел"
  dictionary_get_link rcx, rax
  compile rax, rbx
  list_extend_links rdx, rax

  string "оператор"
  dictionary_get_link rcx, rax
  mov rcx, rax

  string "и"
  token_check_keyword rcx, rax
  cmp rax, 1
  jne .not_and
    string "boolean_and rax, rbx"
    jmp .binary_operation_continue
  .not_and:

  string "или"
  cmp rax, 1
  token_check_keyword rcx, rax
  jne .not_or
    string "boolean_or rax, rbx"
    jmp .binary_operation_continue
  .not_or:

  string "тип"
  dictionary_get_link rcx, rax
  mov r8, rax

  is_equal r8, [ТИП_СЛОЖЕНИЕ]
  boolean_value rax
  cmp rax, 1
  jne .not_addition
    string "addition rax, rbx"
    jmp .binary_operation_continue
  .not_addition:

  is_equal r8, [ТИП_ВЫЧИТАНИЕ]
  boolean_value rax
  cmp rax, 1
  jne .not_subtraction
    string "subtraction rax, rbx"
    jmp .binary_operation_continue
  .not_subtraction:

  is_equal r8, [ТИП_УМНОЖЕНИЕ]
  boolean_value rax
  cmp rax, 1
  jne .not_multiplication
    string "multiplication rax, rbx"
    jmp .binary_operation_continue
  .not_multiplication:

  is_equal r8, [ТИП_ДЕЛЕНИЕ]
  boolean_value rax
  cmp rax, 1
  jne .not_division
    string "division rax, rbx"
    jmp .binary_operation_continue
  .not_division:

  is_equal r8, [ТИП_РАВНО]
  boolean_value rax
  cmp rax, 1
  jne .not_equal
    string "is_equal rax, rbx"
    jmp .binary_operation_continue
  .not_equal:

  is_equal r8, [ТИП_НЕ_РАВНО]
  boolean_value rax
  cmp rax, 1
  jne .not_not_equal
    string "is_not_equal rax, rbx"
    jmp .binary_operation_continue
  .not_not_equal:

  is_equal r8, [ТИП_МЕНЬШЕ]
  boolean_value rax
  cmp rax, 1
  jne .not_lower
    string "is_lower rax, rbx"
    jmp .binary_operation_continue
  .not_lower:

  is_equal r8, [ТИП_БОЛЬШЕ]
  boolean_value rax
  cmp rax, 1
  jne .not_greater
    string "is_greater rax, rbx"
    jmp .binary_operation_continue
  .not_greater:

  is_equal r8, [ТИП_МЕНЬШЕ_ИЛИ_РАВНО]
  boolean_value rax
  cmp rax, 1
  jne .not_lower_or_equal
    string "is_lower_or_equal rax, rbx"
    jmp .binary_operation_continue
  .not_lower_or_equal:

  is_equal r8, [ТИП_БОЛЬШЕ_ИЛИ_РАВНО]
  boolean_value rax
  cmp rax, 1
  jne .not_greater_or_equal
    string "is_greater_or_equal rax, rbx"
    jmp .binary_operation_continue
  .not_greater_or_equal:

  string "Неизвестный оператор: "
  mov rbx, rax
  list
  list_append_link rax, rbx
  list_append_link rax, rcx
  error rax
  exit -1

  .binary_operation_continue:

  list_append_link rdx, rax

  add_code "pop rbx"

  mov rax, rdx
  ret

; @function compile_null
; @debug
; @description Компилирует узел null
; @param node - узел null
; @param context - контекст компиляции
; @return Скомпилированный код для null
; @example
;   compile_null null_node, context
_function compile_null, rbx, rcx, rdx
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  list
  mov rdx, rax

  add_code "null"

  mov rax, rdx
  ret

; @function compile_integer
; @debug
; @description Компилирует целочисленное значение
; @param node - узел целого числа
; @param context - контекст компиляции
; @return Скомпилированный код для целого числа
; @example
;   compile_integer integer_node, context
_function compile_integer, rbx, rcx, rdx
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  list
  mov rdx, rax

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
  mov rcx, rax

  string "integer "
  string_extend_links rax, rcx
  list_append_link rdx, rax

  mov rax, rdx
  ret

; @function compile_float
; @debug
; @description Компилирует вещественное число
; @param node - узел вещественного числа
; @param context - контекст компиляции
; @return Скомпилированный код для вещественного числа
; @example
;   compile_float float_node, context
_function compile_float, rbx, rcx, rdx, r8, r9
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  list
  mov rdx, rax

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
  mov rcx, rax

  string "float "
  mov r8, rax

  string ","
  split_links rcx, rax
  mov r9, rax

  string "."
  join_links r9, rax

  string_extend_links r8, rax
  list_append_link rdx, rax

  mov rax, rdx
  ret

; @function compile_boolean
; @debug
; @description Компилирует логическое значение
; @param node - узел логического значения
; @param context - контекст компиляции
; @return Скомпилированный код для логического значения
; @example
;   compile_boolean boolean_node, context
_function compile_boolean, rbx, rcx, rdx
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  list
  mov rdx, rax

  string "значение"
  dictionary_get_link rcx, rax
  mov rcx, rax

  token_check_keyword rcx, [ИСТИНА]
  cmp rax, 1
  jne .not_true
    add_code "boolean 1"
    mov rax, rdx
    ret
  .not_true:

  token_check_keyword rcx, [ЛОЖЬ]
  cmp rax, 1
  jne .not_false
    add_code "boolean 0"
    mov rax, rdx
    ret
  .not_false:

  string "Ожидалось ключевое слово логического значения: `истина`, `ложь`"
  mov rbx, rax
  list
  list_append_link rax, rbx
  error rax
  exit -1

  ret


; @function compile_list
; @debug
; @description Компилирует список
; @param node - узел списка
; @param context - контекст компиляции
; @return Скомпилированный код для списка
; @example
;   compile_list list_node, context
_function compile_list, rbx, rcx, rdx, r8
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  list
  mov rdx, rax

  string "элементы"
  dictionary_get rcx, rax
  mov rcx, rax

  add_code "list"

  list_length rcx
  cmp rax, 0
  jne .not_empty
    mov rax, rdx
    ret
  .not_empty:

  add_code "push rbx",\
           "mov rbx, rax"

  integer 0
  mov r8, rax

  .list_while:
    list_length rcx
    integer rax
    is_equal rax, r8
    boolean_value rax
    cmp rax, 1
    je .list_end_while

    list_get rcx, r8
    compile rax, rbx
    list_extend_links rdx, rax
    add_code "list_append_link rbx, rax"

    integer_inc r8
    jmp .list_while

  .list_end_while:

  add_code "mov rax, rbx",\
           "pop rbx"

  mov rax, rdx
  ret

; @function compile_string
; @debug
; @description Компилирует строку
; @param node - узел строки
; @param context - контекст компиляции
; @return Скомпилированный код для строки
; @example
;   compile_string string_node, context
_function compile_string, rbx, rcx, rdx, r8, r9, r10, r11, r12, r13, r14
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  list
  mov rdx, rax

  string "значение"
  dictionary_get_link rcx, rax
  mov rcx, rax

  integer 0
  mov r8, rax

  list_length rcx
  integer rax
  mov r9, rax

  add_code "push rbx",\
           'string ""',\
           "mov rbx, rax"

  .while_string_elements:

    is_equal r8, r9
    boolean_value rax
    cmp rax, 1
    je .while_string_elements_end

    list_get_link rcx, r8
    mov r10, rax

    mov rax, [r10]
    cmp rax, STRING
    je .string

      compile r10, rbx
      list_extend_links rdx, rax

      add_code "to_string rax"

      jmp .continue

    .string:

      string ""
      mov r11, rax

      integer 0
      mov r12, rax

      string_length r10
      integer rax
      mov r13, rax

      .while_string:

        is_equal r12, r13
        boolean_value rax
        cmp rax, 1
        je .while_string_end

        string_get_link r10, r12
        mov r14, rax

        string '"'
        is_equal r14, rax
        boolean_value rax
        cmp rax, 1
        jne .not_double_quote
          string "', 34, '"
          mov r14, rax
          jmp .next_char
        .not_double_quote:

        string 9
        is_equal r14, rax
        boolean_value rax
        cmp rax, 1
        jne .not_tab
          string "', 9, '"
          mov r14, rax
          jmp .next_char
        .not_tab:

        string 10
        is_equal r14, rax
        boolean_value rax
        cmp rax, 1
        jne .not_newline
          string "', 10, '"
          mov r14, rax
          jmp .next_char
        .not_newline:

        .next_char:

        string_extend_links r11, r14

        integer_inc r12
        jmp .while_string

      .while_string_end:

      string "string '"
      string_extend_links rax, r11
      mov r10, rax

      string "'"
      string_extend_links r10, rax

      list_append_link rdx, r10

    .continue:

    add_code "string_extend_links rbx, rax"

    integer_inc r8
    jmp .while_string_elements

  .while_string_elements_end:

  add_code "mov rax, rbx",\
           "pop rbx"

  mov rax, rdx
  ret

; @function compile_dictionary
; @debug
; @description Компилирует словарь
; @param node - узел словаря
; @param context - контекст компиляции
; @return Скомпилированный код для словаря
; @example
;   compile_dictionary dict_node, context
_function compile_dictionary, rbx, rcx, rdx
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  list
  mov rdx, rax

  string "элементы"
  dictionary_get_link rcx, rax
  compile rax, rbx
  list_extend_links rdx, rax
  add_code "dictionary_from_list rax"

  mov rax, rdx
  ret

; @function compile_if
; @debug
; @description Компилирует условную конструкцию if
; @param node - узел условной конструкции
; @param context - контекст компиляции
; @return Скомпилированный код условной конструкции
; @example
;   compile_if if_node, context
_function compile_if, rbx, rcx, rdx, r8, r9, r10, r12, r13, r14
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  list
  mov rdx, rax

  mov rax, [СЧЁТЧИК_ЕСЛИ]
  integer_inc rax

  mov r13, [rax + INTEGER_HEADER*8]
  mov r12, 0

  string "случаи"
  dictionary_get_link rcx, rax
  mov r8, rax

  integer 0
  mov r9, rax

  .if_while:
    list_length r8
    integer rax
    is_equal r9, rax
    boolean_value rax
    cmp rax, 1
    je .if_end_while

    inc r12
    integer r12

    list_get r8, r9
    mov r10, rax

    string "условие"
    dictionary_get_link r10, rax
    compile rax, rbx
    list_extend_links rdx, rax

    add_code "boolean rax",\
             "boolean_value rax",\
             "cmp rax, 1"

    string "jne .if_"
    mov r14, rax
    integer r13
    to_string rax
    string_extend_links r14, rax
    string "_branch_"
    string_extend_links r14, rax
    integer r12
    to_string rax
    string_extend_links r14, rax
    list_append_link rdx, rax

    string "тело"
    dictionary_get_link r10, rax
    compile rax, rbx
    list_extend_links rdx, rax

    string "jmp .if_"
    mov r14, rax
    integer r13
    to_string rax
    string_extend_links r14, rax
    string "_end"
    string_extend_links r14, rax
    list_append_link rdx, rax

    string ".if_"
    mov r14, rax
    integer r13
    to_string rax
    string_extend_links r14, rax
    string "_branch_"
    string_extend_links r14, rax
    integer r12
    to_string rax
    string_extend_links r14, rax
    string ":"
    string_extend_links r14, rax
    list_append_link rdx, rax

    integer_inc r9
    jmp .if_while

  .if_end_while:

  string "случай_иначе"
  dictionary_get_link rcx, rax
  compile rax, rbx
  list_extend_links rdx, rax

  string ".if_"
  mov r14, rax
  integer r13
  to_string rax
  string_extend_links r14, rax
  string "_end:"
  string_extend_links r14, rax
  list_append_link rdx, rax

  mov rax, rdx
  ret

; @function compile_while
; @debug
; @description Компилирует цикл while
; @param node - узел цикла while
; @param context - контекст компиляции
; @return Скомпилированный код цикла while
; @example
;   compile_while while_node, context
_function compile_while, rbx, rcx, rdx, r13, r14, r15
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  list
  mov rdx, rax

  mov rax, [СЧЁТЧИК_ВЛОЖЕННОСТИ]
  integer_inc rax

  copy [НОМЕР_ТЕКУЩЕГО_ЦИКЛА]
  mov r15, rax

  mov rax, [СЧЁТЧИК_ЦИКЛОВ]
  integer_inc rax

  mov [НОМЕР_ТЕКУЩЕГО_ЦИКЛА], rax

  mov r13, [rax + INTEGER_HEADER*8]

  add_code "push rbx",\
           "mov rbx, 0"

  string ".loop_start_"
  mov r14, rax
  integer r13
  to_string rax
  string_extend_links r14, rax
  string ":"
  string_extend_links r14, rax
  list_append_link rdx, rax

  string "условие"
  dictionary_get_link rcx, rax
  compile rax, rbx
  list_extend_links rdx, rax

  add_code "boolean rax",\
           "boolean_value rax",\
           "cmp rax, 1"

  string "jne .loop_end_"
  mov r14, rax
  integer r13
  to_string rax
  string_extend_links r14, rax
  list_append_link rdx, rax

  add_code "mov rbx, 1"

  string "тело"
  dictionary_get_link rcx, rax
  compile rax, rbx
  list_extend_links rdx, rax

  string "jmp .loop_start_"
  mov r14, rax
  integer r13
  to_string rax
  string_extend_links r14, rax
  list_append_link rdx, rax

  string ".loop_end_"
  mov r14, rax
  integer r13
  to_string rax
  string_extend_links r14, rax
  string ":"
  string_extend_links r14, rax
  list_append_link rdx, rax

  string "cmp rbx, 1"
  string "je .loop_else_skip_"
  mov r14, rax
  integer r13
  to_string rax
  string_extend_links r14, rax
  list_append_link rdx, rax

  string "случай_иначе"
  dictionary_get_link rcx, rax
  compile rax, rbx
  list_extend_links rdx, rax

  string ".loop_else_skip_"
  mov r14, rax
  integer r13
  to_string rax
  string_extend_links r14, rax
  string ":"
  string_extend_links r14, rax
  list_append_link rdx, rax

  add_code "pop rbx"

  mov [НОМЕР_ТЕКУЩЕГО_ЦИКЛА], r15
  mov rax, [СЧЁТЧИК_ВЛОЖЕННОСТИ]

  integer_dec rax
  mov rax, rdx

  ret

; @function compile_for
; @debug
; @description Компилирует цикл for
; @param node - узел цикла for
; @param context - контекст компиляции
; @return Скомпилированный код цикла for
; @example
;   compile_for for_node, context
_function compile_for, rbx, rcx, rdx, r8, r9, r10, r11, r14, r15
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  list
  mov rdx, rax

  mov rax, [СЧЁТЧИК_ВЛОЖЕННОСТИ]
  integer_inc rax

  copy [НОМЕР_ТЕКУЩЕГО_ЦИКЛА]
  mov r15, rax

  mov rax, [СЧЁТЧИК_ЦИКЛОВ]
  integer_inc rax
  mov [НОМЕР_ТЕКУЩЕГО_ЦИКЛА], rax

  mov r8, [rax + INTEGER_HEADER*8]
  add_code "push rbx, rcx, rdx"

  string "переменная"
  dictionary_get_link rcx, rax
  mov r9, rax

  string "конец"
  dictionary_get_link rcx, rax
  mov r10, rax

  null
  is_equal r10, rax
  boolean_value rax
  cmp rax, 1
  je .loop_with_enter

    compile r10, rbx
    list_extend_links rdx, rax
    add_code "mov rbx, rax"

    string "шаг"
    dictionary_get_link rcx, rax
    mov r11, rax
    null
    is_equal r11, rax
    boolean_value rax
    cmp rax, 1
    je .default_step
      compile r11, rbx
      list_extend_links rdx, rax
      add_code "mov rcx, rax"

      jmp .after_step

    .default_step:

      add_code "integer 1",\
               "mov rcx, rax"

    .after_step:

    string "начало"
    dictionary_get_link rcx, rax
    compile rax, rbx
    list_extend_links rdx, rax

    string ".loop_start_"
    mov r14, rax
    integer r8
    to_string rax
    string_extend_links r14, rax
    string ":"
    string_extend_links r14, rax
    list_append_link rdx, rax

    add_code "mov rdx, rax",\
             "is_greater_or_equal rdx, rbx",\
             "boolean_value rax",\
             "cmp rax, 1"

    string "je .loop_end_"
    mov r14, rax
    integer r8
    to_string rax
    string_extend_links r14, rax
    list_append_link rdx, rax

    add_code "mov rax, rdx"
    null
    mov r10, rax
    list
    list_node rax
    assign_node r9, rax, r10
    compile rax, rbx
    list_extend_links rdx, rax

    string "тело"
    dictionary_get_link rcx, rax
    compile rax, rbx
    list_extend_links rdx, rax

    string ".loop_iteration_"
    mov r14, rax
    integer r8
    to_string rax
    string_extend_links r14, rax
    string ":"
    string_extend_links r14, rax
    list_append_link rdx, rax

    add_code "integer_add rdx, rcx"

    jmp .for_end

  .loop_with_enter:

    string "начало"
    dictionary_get_link rcx, rax
    compile rax, rbx
    list_extend_links rdx, rax

    add_code "mov rbx, rax",\
             "integer 0"

    string ".loop_start_"
    mov r14, rax
    integer r8
    to_string rax
    string_extend_links r14, rax
    string ":"
    string_extend_links r14, rax
    list_append_link rdx, rax

    add_code "mov rdx, rax",\
             "list_length rbx",\
             "integer rax",\
             "is_equal rdx, rax",\
             "boolean_value rax",\
             "cmp rax, 1"

    string "je .loop_end_"
    mov r14, rax
    integer r8
    to_string rax
    string_extend_links r14, rax
    list_append_link rdx, rax

    add_code "list_get_link rbx, rdx"
    null
    mov r10, rax
    list
    list_node rax
    assign_node r9, rax, r10
    compile rax, rbx
    list_extend_links rdx, rax

    string "тело"
    dictionary_get_link rcx, rax
    compile rax, rbx
    list_extend_links rdx, rax

    string ".loop_iteration_"
    mov r14, rax
    integer r8
    to_string rax
    string_extend_links r14, rax
    string ":"
    string_extend_links r14, rax
    list_append_link rdx, rax

    string "integer_inc rdx", 10
    list_append_link rdx, rax

  .for_end:

  string "jmp .loop_start_"
  mov r14, rax
  integer r8
  to_string rax
  string_extend_links r14, rax
  list_append_link rdx, rax

  string ".loop_end_"
  mov r14, rax
  integer r8
  to_string rax
  string_extend_links r14, rax
  string ":"
  string_extend_links r14, rax
  list_append_link rdx, rax

  string "pop rdx, rcx, rbx", 10
  list_append_link rdx, rax

  mov [НОМЕР_ТЕКУЩЕГО_ЦИКЛА], r15
  mov rax, [СЧЁТЧИК_ВЛОЖЕННОСТИ]

  integer_dec rax
  mov rax, rdx

  ret

; @function compile_skip
; @debug
; @description Компилирует оператор skip
; @param node - узел оператора skip
; @param context - контекст компиляции
; @return Скомпилированный код оператора skip
; @example
;   compile_skip skip_node, context
_function compile_skip, rbx, rcx, rdx, r8, r9
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

  string "jmp .loop_iteration_"
  mov r9, rax
  to_string r8
  string_extend_links r9, rax
  list_append_link rdx, rax

  mov rax, rdx
  ret

; @function compile_break
; @debug
; @description Компилирует оператор break
; @param node - узел оператора break
; @param context - контекст компиляции
; @return Скомпилированный код оператора break
; @example
;   compile_break break_node, context
_function compile_break, rbx, rcx, rdx, r8, r9
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

  string "jmp .loop_end_"
  mov r9, rax
  to_string r8
  string_extend_links r9, rax
  list_append_link rdx, rax

  mov rax, rdx
  ret

; @function compile_function
; @debug
; @description Компилирует определение функции
; @param node - узел определения функции
; @param context - контекст компиляции
; @return Скомпилированный код функции
; @example
;   compile_function function_node, context
_function compile_function, rbx, rcx, rdx, r8, r9, r10, r11, r12, r13, r14
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  list
  mov rdx, rax

  mov rax, [СЧЁТЧИК_ФУНКЦИЙ]
  integer_inc rax

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
  compile rax, rbx
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
      compile rax, rbx
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

; @function compile_call
; @debug
; @description Компилирует вызов функции
; @param node - узел вызова функции
; @param context - контекст компиляции
; @return Скомпилированный код вызова функции
; @example
;   compile_call call_node, context
_function compile_call, rbx, rcx, rdx
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  list
  mov rdx, rax

  add_code "push rbx, rcx"

  string "переменная"
  dictionary_get_link rcx, rax
  compile rax, rbx
  list_extend_links rdx, rax
  add_code "mov rcx, rax"

  string "аргументы"
  dictionary_get_link rcx, rax
  list_node rax
  compile rax, rbx
  list_extend_links rdx, rax
  add_code "mov rbx, rax"

  string "именованные_аргументы"
  dictionary_get_link rcx, rax
  list_node rax
  dictionary_node rax
  compile rax, rbx
  list_extend_links rdx, rax

  add_code "function_call rcx, rbx, rax",\
           "pop rcx, rbx"

  mov rax, rdx
  ret

; @function compile_return
; @debug
; @debug
; @description Компилирует оператор return
; @param node - узел оператора return
; @param context - контекст компиляции
; @return Скомпилированный код оператора return
; @example
;   compile_return return_node, context
_function compile_return, rbx, rcx, rdx, r8
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  list
  mov rdx, rax

  string "значение"
  dictionary_get_link rcx, rax
  mov r8, rax

  null
  is_equal rax, r8
  boolean_value rax
  cmp rax, 1
  je @f

    compile r8, rbx
    list_extend_links rdx, rax

  @@:

  add_code "ret"

  mov rax, rdx
  ret
