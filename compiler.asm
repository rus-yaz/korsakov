section "compiler" executable

macro check_node_type node*, type* {
  debug_start "check_node_type"
  enter node, type

  call f_check_node_type

  return
  debug_end "check_node_type"
}

macro compiler ast*, context* {
  debug_start "compiler"
  enter ast, context

  call f_compiler

  return
  debug_end "compiler"
}

macro compile node*, context* {
  debug_start "compile"
  enter node, context

  call f_compile

  return
  debug_end "compile"
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

  list
  mov [код], rax

  .while:
    list_length [АСД]
    integer rax
    is_equal rax, [индекс]
    cmp rax, 1
    je .end_while

    list_get_link [АСД], [индекс]
    compile rax, rbx
    list_extend_links [код], rax
    string ""
    list_append_link [код], rax

    integer_inc [индекс]
    jmp .while

  .end_while:

  join_links [код], 10

  ret

f_compile:
  get_arg 1
  mov rbx, rax
  get_arg 0
  mov rcx, rax

  list
  mov rdx, rax

  mov rax, [rcx]
  cmp rax, LIST
  jne .not_body

    integer 0
    mov r8, rax

    list_length rcx
    integer rax
    mov r9, rax

    .body_while:
      is_equal r9, r8
      cmp rax, 1
      je .body_end_while

      list_get_link rcx, r8
      compile rax, rbx
      list_extend_links rdx, rax

      integer_inc r8
      jmp .body_while

    .body_end_while:

    jmp .continue

  .not_body:

  check_node_type rcx, [УЗЕЛ_ПРИСВАИВАНИЯ_ПЕРЕМЕННОЙ]
  cmp rax, 1
  jne .not_assign
    string "push rdx, rcx, rbx"
    list_append_link rdx, rax

    string "значение"
    dictionary_get_link rcx, rax
    mov r8, rax

    null
    is_equal rax, r8
    cmp rax, 1
    je .use_exists_value
      compile r8, rbx
      list_extend_links rdx, rax

    .use_exists_value:

    string "mov rdx, rax"
    list_append_link rdx, rax

    string "ключи"
    dictionary_get_link rcx, rax
    compile rax, rbx
    list_extend_links rdx, rax
    string "mov rcx, rax"
    list_append_link rdx, rax

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

    string "mov rbx, rax"
    list_append_link rdx, rax

    string "assign rbx, rcx, rdx"
    list_append_link rdx, rax

    string "pop rbx, rcx, rdx"
    list_append_link rdx, rax

    jmp .continue

  .not_assign:

  check_node_type rcx, [УЗЕЛ_ДОСТУПА_К_ПЕРЕМЕННОЙ]
  cmp rax, 1
  jne .not_access

    string "push rcx, rbx"
    list_append_link rdx, rax

    string "ключи"
    dictionary_get_link rcx, rax
    compile rax, rbx
    list_extend_links rdx, rax
    string "mov rcx, rax"
    list_append_link rdx, rax

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
    string "mov rbx, rax"
    list_append_link rdx, rax

    string "access rbx, rcx"
    list_append_link rdx, rax

    string "pop rbx, rcx"
    list_append_link rdx, rax

    jmp .continue

  .not_access:

  check_node_type rcx, [УЗЕЛ_БИНАРНОЙ_ОПЕРАЦИИ]
  cmp rax, 1
  jne .not_binary_operation

    string "push rbx"
    list_append_link rdx, rax

    string "левый_узел"
    dictionary_get_link rcx, rax
    compile rax, rbx
    list_extend_links rdx, rax
    string "mov rbx, rax"
    list_append_link rdx, rax

    string "правый_узел"
    dictionary_get_link rcx, rax
    compile rax, rbx
    list_extend_links rdx, rax

    string "оператор"
    dictionary_get_link rcx, rax
    mov rcx, rax
    string "тип"
    dictionary_get_link rcx, rax
    mov rcx, rax

    is_equal rcx, [ТИП_СЛОЖЕНИЕ]
    cmp rax, 1
    jne .not_addition
      string "addition rbx, rax"
      list_append_link rdx, rax

      jmp .binary_operation_continue

    .not_addition:

    is_equal rcx, [ТИП_ВЫЧИТАНИЕ]
    cmp rax, 1
    jne .not_subtraction
      string "subtraction rbx, rax"
      list_append_link rdx, rax

      jmp .binary_operation_continue

    .not_subtraction:

    is_equal rcx, [ТИП_УМНОЖЕНИЕ]
    cmp rax, 1
    jne .not_multiplication
      string "multiplication rbx, rax"
      list_append_link rdx, rax

      jmp .binary_operation_continue

    .not_multiplication:

    is_equal rcx, [ТИП_ДЕЛЕНИЕ]
    cmp rax, 1
    jne .not_division
      string "division rbx, rax"
      list_append_link rdx, rax

      jmp .binary_operation_continue

    .not_division:

    string "Неизвестный оператор: "
    mov rbx, rax
    string "оператор"
    dictionary_get_link rcx, rax
    mov rcx, rax
    string "значение"
    dictionary_get_link rcx, rax
    print <rbx, rax>
    exit -1

    .binary_operation_continue:

    string "pop rbx"
    list_append_link rdx, rax

    jmp .continue

  .not_binary_operation:

  check_node_type rcx, [УЗЕЛ_ЧИСЛА]
  cmp rax, 1
  jne .not_number

    string "значение"
    dictionary_get_link rcx, rax
    mov rcx, rax

    string "тип"
    dictionary_get_link rcx, rax
    is_equal rax, [ТИП_ЦЕЛОЕ_ЧИСЛО]
    cmp rax, 1
    je .correct_value
      string "Ожидалось целое число"
      print rax
      exit -1

    .correct_value:

    string "значение"
    dictionary_get_link rcx, rax
    mov rcx, rax

    string "integer "
    string_extend_links rax, rcx
    list_append_link rdx, rax

    jmp .continue

  .not_number:

  check_node_type rcx, [УЗЕЛ_СПИСКА]
  cmp rax, 1
  jne .not_list

    string "элементы"
    dictionary_get rcx, rax
    mov rcx, rax

    string "list"
    list_append_link rdx, rax

    list_length rcx
    cmp rax, 0
    je .continue

    string "push rbx"
    list_append_link rdx, rax
    string "mov rbx, rax"
    list_append_link rdx, rax

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
      list_extend_links rdx, rax
      string "list_append rbx, rax"
      list_append_link rdx, rax

      integer_inc r8
      jmp .list_while

    .list_end_while:

    string "mov rax, rbx"
    list_append_link rdx, rax
    string "pop rbx"
    list_append_link rdx, rax

    jmp .continue

  .not_list:

  check_node_type rcx, [УЗЕЛ_СТРОКИ]
  cmp rax, 1
  jne .not_string

    string "string "
    mov r8, rax
    string "значение"
    dictionary_get_link rcx, rax
    mov rcx, rax
    string "значение"
    dictionary_get_link rcx, rax
    string_extend_links r8, rax
    list_append_link rdx, rax

    jmp .continue

  .not_string:

  check_node_type rcx, [УЗЕЛ_СЛОВАРЯ]
  cmp rax, 1
  jne .not_dictionary

    string "push rbx"
    list_append_link rdx, rax

    string "элементы"
    dictionary_get_link rcx, rax
    compile rax, rbx
    list_extend_links rdx, rax
    string "dictionary rax"
    list_append_link rdx, rax

    jmp .continue

  .not_dictionary:

  check_node_type rcx, [УЗЕЛ_ЕСЛИ]
  cmp rax, 1
  jne .not_if

    string "СЧЁТЧИК_ЕСЛИ"
    mov r8, rax
    list
    mov r9, rax
    access r8, r9
    integer_inc rax

    assign r8, r9, rax
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

      string "boolean rax"
      list_append_link rdx, rax
      string "mov rax, [rax + BOOLEAN_HEADER*8]"
      list_append_link rdx, rax
      string "cmp rax, 1"
      list_append_link rdx, rax

      string "jne .if_"
      mov r14, rax
      list_append_link rdx, rax
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

    jmp .continue

  .not_if:

  check_node_type rcx, [УЗЕЛ_ПОКА]
  cmp rax, 1
  jne .not_while

    string "СЧЁТЧИК_ВЛОЖЕННОСТИ"
    mov r8, rax
    list
    mov r9, rax
    access r8, r9
    integer_inc rax
    assign r8, r9, rax

    string "СЧЁТЧИК_ЦИКЛОВ"
    mov r8, rax
    list
    mov r9, rax
    access r8, r9
    integer_inc rax
    assign r8, r9, rax

    mov r13, [rax + INTEGER_HEADER*8]

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

    string "boolean rax"
    list_append_link rdx, rax
    string "mov rax, [rax + BOOLEAN_HEADER*8]"
    list_append_link rdx, rax
    string "cmp rax, 1"
    list_append_link rdx, rax

    string "jne .loop_end_"
    mov r14, rax
    integer r13
    to_string rax
    string_extend_links r14, rax
    list_append_link rdx, rax

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

    string "СЧЁТЧИК_ВЛОЖЕННОСТИ"
    mov r8, rax
    list
    mov r9, rax
    access r8, r9
    integer_dec rax
    assign r8, r9, rax

    jmp .continue

  .not_while:

  check_node_type rcx, [УЗЕЛ_ДЛЯ]
  cmp rax, 1
  jne .not_for

    string "СЧЁТЧИК_ВЛОЖЕННОСТИ"
    mov r8, rax
    list
    mov r9, rax
    access r8, r9
    integer_inc rax
    assign r8, r9, rax

    string "СЧЁТЧИК_ЦИКЛОВ"
    mov r8, rax
    list
    mov r9, rax
    access r8, r9
    integer_inc rax
    assign r8, r9, rax

    mov r8, [rax + INTEGER_HEADER*8]

    string "push rbx, rcx, rdx"
    list_append_link rdx, rax

    string "переменная"
    dictionary_get_link rcx, rax
    mov r9, rax

    string "конец"
    dictionary_get_link rcx, rax
    mov r10, rax

    null
    is_equal r10, rax
    cmp rax, 1
    je .loop_with_enter

      compile r10, rbx
      list_extend_links rdx, rax
      string "mov rbx, rax"
      list_append_link rdx, rax

      string "шаг"
      dictionary_get_link rcx, rax
      mov r11, rax
      null
      is_equal r11, rax
      cmp rax, 1
      je .default_step
        compile r11, rbx
        list_extend_links rdx, rax
        string "mov rcx, rax"
        list_append_link rdx, rax

        jmp .after_step

      .default_step:

        string "integer 1"
        list_append_link rdx, rax
        string "mov rcx, rax"
        list_append_link rdx, rax

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

      string "mov rdx, rax"
      list_append_link rdx, rax

      string "is_greater_or_equal rdx, rbx"
      list_append_link rdx, rax
      string "cmp rax, 1"
      list_append_link rdx, rax

      string "je .loop_end_"
      mov r14, rax
      integer r8
      to_string rax
      string_extend_links r14, rax
      list_append_link rdx, rax

      string "mov rax, rdx"
      list_append_link rdx, rax
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

      string "integer_add rdx, rcx"
      list_append_link rdx, rax

      jmp .for_end

    .loop_with_enter:

      string "начало"
      dictionary_get_link rcx, rax
      compile rax, rbx
      list_extend_links rdx, rax
      string "mov rbx, rax"
      list_append_link rdx, rax

      string "integer 0"
      list_append_link rdx, rax

      string ".loop_start_"
      mov r14, rax
      integer r8
      to_string rax
      string_extend_links r14, rax
      string ":"
      string_extend_links r14, rax
      list_append_link rdx, rax

      string "mov rdx, rax"
      list_append_link rdx, rax

      string "list_length rbx"
      list_append_link rdx, rax
      string "integer rax"
      list_append_link rdx, rax

      string "is_equal rdx, rax"
      list_append_link rdx, rax
      string "cmp rax, 1"
      list_append_link rdx, rax

      string "je .loop_end_"
      mov r14, rax
      integer r8
      to_string rax
      string_extend_links r14, rax
      list_append_link rdx, rax

      string "list_get rbx, rdx"
      list_append_link rdx, rax
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

      string <"integer_inc rdx", 10>
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

    string <"pop rdx, rcx, rbx", 10>
    list_append_link rdx, rax

    string "СЧЁТЧИК_ВЛОЖЕННОСТИ"
    mov r8, rax
    list
    mov r9, rax
    access r8, r9
    integer_dec rax
    assign r8, r9, rax

    jmp .continue

  .not_for:

  check_node_type rcx, [УЗЕЛ_ПРОПУСКА]
  cmp rax, 1
  jne .not_skip

    string "СЧЁТЧИК_ЦИКЛОВ"
    mov r8, rax
    list
    access r8, rax
    mov r8, rax

    string "jmp .loop_iteration_"
    mov r9, rax
    to_string r8
    string_extend_links r9, rax
    list_append_link rdx, rax

    jmp .continue

  .not_skip:

  check_node_type rcx, [УЗЕЛ_ПРЕРЫВАНИЯ]
  cmp rax, 1
  jne .not_break

    string "СЧЁТЧИК_ЦИКЛОВ"
    mov r8, rax
    list
    access r8, rax
    mov r8, rax

    string "jmp .loop_end_"
    mov r9, rax
    to_string r8
    string_extend_links r9, rax
    list_append_link rdx, rax

    jmp .continue

  .not_break:

  string "Неизвестный узел: "
  print <rax, rcx>
  exit -1

  .continue:

  mov rax, rdx

  ret
