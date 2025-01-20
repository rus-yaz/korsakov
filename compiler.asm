section "compiler" executable

macro string_to_data string* {
  enter string

  call f_string_to_data

  return
}

macro check_node_type node*, type* {
  enter node, type

  call f_check_node_type

  return
}

macro compiler ast*, context* {
  enter ast, context

  call f_compiler

  return
}

macro compile node*, context* {
  enter node, context

  call f_compile

  return
}

f_check_node_type:
  get_arg 1
  mov rbx, rax
  get_arg 0
  mov rcx, rax

  string "узел"
  dictionary_get rcx, rax
  is_equal rax, rbx

  ret

f_compiler:
  get_arg 1
  mov rbx, rax
  get_arg 0
  mov [АСД], rax

  integer 0
  mov [индекс], rax

  string ""
  mov [код], rax

  string ""
  mov [данные], rax

  .while:
    list_length [АСД]
    integer rax
    is_equal rax, [индекс]
    cmp rax, 1
    je .end_while

    list_get [АСД], [индекс]
    compile rax, rbx
    string_append [код], rax
    string 10
    string_append [код], rax

    integer_inc [индекс]
    jmp .while

  .end_while:
  mov rax, [код]

  ret

f_compile:
  get_arg 1
  mov rbx, rax
  get_arg 0
  mov rcx, rax

  string ""
  mov rdx, rax

  check_node_type rcx, [УЗЕЛ_ПРИСВАИВАНИЯ_ПЕРЕМЕННОЙ]
  cmp rax, 1
  jne .not_assign
    string <"push rdx, rcx, rbx", 10>
    string_append rdx, rax

    string "значение"
    dictionary_get rcx, rax
    compile rax, rbx
    string_append rdx, rax
    string <"mov rdx, rax", 10>
    string_append rdx, rax

    string "ключи"
    dictionary_get rcx, rax
    compile rax, rbx
    string_append rdx, rax
    string <"mov rcx, rax", 10>
    string_append rdx, rax

    string "string "
    string_append rdx, rax
    string "переменная"
    dictionary_get rcx, rax
    mov rcx, rax
    string "значение"
    dictionary_get rcx, rax
    to_string rax
    string_append rdx, rax
    string 10
    string_append rdx, rax

    string <"mov rbx, rax", 10>
    string_append rdx, rax

    string <"assign rbx, rcx, rdx", 10>
    string_append rdx, rax

    string <"pop rbx, rcx, rdx", 10>
    string_append rdx, rax

    jmp .continue

  .not_assign:

  check_node_type rcx, [УЗЕЛ_ДОСТУПА_К_ПЕРЕМЕННОЙ]
  cmp rax, 1
  jne .not_access

    string <"push rcx, rbx", 10>
    string_append rdx, rax

    string "ключи"
    dictionary_get rcx, rax
    compile rax, rbx
    string_append rdx, rax
    string <"mov rcx, rax", 10>
    string_append rdx, rax

    string "string "
    string_append rdx, rax
    string "переменная"
    dictionary_get rcx, rax
    mov rcx, rax
    string "значение"
    dictionary_get rcx, rax
    to_string rax
    string_append rdx, rax
    string 10
    string_append rdx, rax
    string <"mov rbx, rax", 10>
    string_append rdx, rax

    string <"access rbx, rcx", 10>
    string_append rdx, rax

    string <"pop rbx, rcx", 10>
    string_append rdx, rax

    jmp .continue

  .not_access:

  check_node_type rcx, [УЗЕЛ_БИНАРНОЙ_ОПЕРАЦИИ]
  cmp rax, 1
  jne .not_binary_operation

    string <"push rbx", 10>
    string_append rdx, rax

    string "левый_узел"
    dictionary_get rcx, rax
    compile rax, rbx
    string_append rdx, rax
    string <"mov rbx, rax", 10>
    string_append rdx, rax

    string "правый_узел"
    dictionary_get rcx, rax
    compile rax, rbx
    string_append rdx, rax

    string "оператор"
    dictionary_get rcx, rax
    mov rcx, rax
    string "тип"
    dictionary_get rcx, rax
    mov rcx, rax

    is_equal rcx, [ТИП_СЛОЖЕНИЕ]
    cmp rax, 1
    jne .not_addition
      string <"addition rbx, rax", 10>
      string_append rdx, rax

      jmp .binary_operation_continue

    .not_addition:

    is_equal rcx, [ТИП_ВЫЧИТАНИЕ]
    cmp rax, 1
    jne .not_subtraction
      string <"subtraction rbx, rax", 10>
      string_append rdx, rax

      jmp .binary_operation_continue

    .not_subtraction:

    is_equal rcx, [ТИП_УМНОЖЕНИЕ]
    cmp rax, 1
    jne .not_multiplication
      string <"multiplication rbx, rax", 10>
      string_append rdx, rax

      jmp .binary_operation_continue

    .not_multiplication:

    is_equal rcx, [ТИП_ДЕЛЕНИЕ]
    cmp rax, 1
    jne .not_division
      string <"division rbx, rax", 10>
      string_append rdx, rax

      jmp .binary_operation_continue

    .not_division:

    string "Неизвестный оператор: "
    mov rbx, rax
    string "оператор"
    dictionary_get rcx, rax
    mov rcx, rax
    string "значение"
    dictionary_get rcx, rax
    print <rbx, rax>
    exit -1

    .binary_operation_continue:

    string <"pop rbx", 10>
    string_append rdx, rax

    jmp .continue

  .not_binary_operation:

  check_node_type rcx, [УЗЕЛ_ЧИСЛА]
  cmp rax, 1
  jne .not_number

    string "значение"
    dictionary_get rcx, rax
    mov rcx, rax

    string "тип"
    dictionary_get rcx, rax
    is_equal rax, [ТИП_ЦЕЛОЕ_ЧИСЛО]
    cmp rax, 1
    je .correct_value
      string "Ожидалось целое число"
      print rax
      exit -1

    .correct_value:

    string "значение"
    dictionary_get rcx, rax
    mov rcx, rax

    string "integer "
    string_append rax, rcx
    string_append rdx, rax
    string 10
    string_append rdx, rax

    jmp .continue

  .not_number:

  check_node_type rcx, [УЗЕЛ_СПИСКА]
  cmp rax, 1
  jne .not_list

    string "элементы"
    dictionary_get rcx, rax
    mov rcx, rax

    string <"list", 10>
    string_append rdx, rax

    list_length rcx
    cmp rax, 0
    je .continue

    string <"push rbx", 10>
    string_append rdx, rax
    string <"mov rbx, rax", 10>
    string_append rdx, rax

    integer 0
    mov r8, rax

    .list_while:
      list_length rcx
      integer rax
      is_equal rax, r8
      cmp rax, 1
      je .list_end_while

      list_get rcx, r8
      compile rax, rbx
      string_append rdx, rax
      string "list_append rbx, rax"
      string_append rdx, rax
      string 10
      string_append rdx, rax

      integer_inc r8
      jmp .list_while

    .list_end_while:

    string <"mov rax, rbx", 10>
    string_append rdx, rax
    string <"pop rbx", 10>
    string_append rdx, rax

    jmp .continue

  .not_list:

  string "Неизвестный узел: "
  print <rax, rcx>
  exit -1

  .continue:

  mov rax, rdx

  ret
