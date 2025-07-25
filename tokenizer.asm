; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

macro tokenizer filename* {
  enter filename

  call f_tokenizer

  return
}

macro find_first_string list* {
  enter list

  call f_find_first_string

  return
}

f_tokenizer:
  ; символы = Список(код)
  get_arg 0
  string_to_list rax
  mov r10, rax

  string 10
  list_append_link r10, rax

  ; токен = ""
  string ""
  mem_mov r11, rax

  ; токены = ()
  list
  mov r12, rax

  ; индекс = 0
  integer 0
  mov r13, rax

  .while:
    ; токен += символы.индекс
    list_get_link r10, r13
    string_extend_links r11, rax

    mov rbx, 0
    .new_token_while:

      string " "
      is_equal r11, rax
      boolean_value rax
      cmp rax, 1
      je .find_new_token

      string 10
      is_equal r11, rax
      boolean_value rax
      cmp rax, 1
      jne .new_token_while_end

      mov rbx, 1

      .find_new_token:

      integer_inc r13

      list_length r10
      integer rax
      is_equal r13, rax
      boolean_value rax
      cmp rax, 1
      je .new_token_while_end

      list_get_link r10, r13
      mov r11, rax

      jmp .new_token_while

    .new_token_while_end:

    cmp rbx, 1
    jne .not_newline

      integer_dec r13

      list_length r12
      cmp rax, 0
      je .continue_newline_check

      integer -1
      list_get_link r12, rax
      mov rbx, rax
      string "тип"
      dictionary_get_link rbx, rax

      is_equal rax, [ТИП_ПЕРЕНОС_СТРОКИ]
      boolean_value rax
      cmp rax, 1
      je .continue

      .continue_newline_check:

      string 10
      mov r11, rax
      integer_copy [ТИП_ПЕРЕНОС_СТРОКИ]
      mov [тип_токена], rax

      jmp .write_token

    .not_newline:

    string ","
    is_equal r11, rax
    boolean_value rax
    cmp rax, 1
    jne .not_comma
      raw_string "Символ `,` может быть использован только в вещественных числах"
      error_raw rax
      exit -1
    .not_comma:

    is_digit r11
    cmp rax, 1
    jne .not_digit

      integer_copy [ТИП_ЦЕЛОЕ_ЧИСЛО]
      mov [тип_токена], rax

      mov rcx, 0
      mov rdx, 0

      .while_number:
        integer 1
        integer_add r13, rax

        list_get_link r10, rax
        mov rbx, rax

        string "_"
        is_equal rbx, rax
        boolean_value rax
        cmp rax, 1
        jne .not_divider
          integer_inc r13
          jmp .while_number
        .not_divider:

        string ","
        is_equal rbx, rax
        boolean_value rax
        cmp rax, 1
        jne .not_float

          cmp rcx, 0
          je .correct_float_divider
            raw_string "Некорректное выражение: вторая запятая в вещественном числе"
            error_raw rax
            exit -1
          .correct_float_divider:

          integer_copy [ТИП_ВЕЩЕСТВЕННОЕ_ЧИСЛО]
          mov [тип_токена], rax

          mov rcx, 1
          jmp .next_token

        .not_float:

        is_digit rbx
        cmp rax, 1
        jne .end_while_number

        mov rdx, rcx

        .next_token:

        string_extend_links r11, rbx
        integer_inc r13
        jmp .while_number

      .end_while_number:

      cmp rdx, rcx
      je .correct_value
        raw_string "Незавершённое вещественное число"
        error_raw rax
        exit -1
      .correct_value:

      jmp .write_token

    .not_digit:

    is_alpha r11
    cmp rax, 1
    je .while_identifier
    string "_"
    is_equal r11, rax
    boolean_value rax
    cmp rax, 1
    jne .not_identifier

      .while_identifier:
        integer 1
        integer_add r13, rax

        list_get_link r10, rax
        mov rbx, rax

        is_alpha rbx
        cmp rax, 1
        je .continue_identifier

        is_digit rbx
        cmp rax, 1
        je .continue_identifier

        string "_"
        is_equal rbx, rax
        boolean_value rax
        cmp rax, 1
        jne .end_while_identifier

        .continue_identifier:

        string_extend_links r11, rbx
        integer_inc r13
        jmp .while_identifier

      .end_while_identifier:

      list_include [ключевые_слова], r11
      boolean_value rax
      cmp rax, 1
      jne .not_keyword

        is_equal r11, [ВКЛЮЧИТЬ]
        boolean_value rax
        cmp rax, 1
        jne .not_include

          string " "
          mov rbx, rax

          integer_inc r13
          list_get_link r10, rax

          is_equal rax, rbx
          boolean_value rax
          cmp rax, 1
          je .correct_space

            raw_string "Ожидался пробел"
            error_raw rax
            exit -1

          .correct_space:

          string '"'
          mov rbx, rax

          integer_inc r13
          list_get_link r10, rax

          is_equal rax, rbx
          boolean_value rax
          cmp rax, 1
          je .correct_quotation_mark

            raw_string "Ожидались кавычки"
            error_raw rax
            exit -1

          .correct_quotation_mark:

          list_slice_links r10, r13
          find_first_string rax
          mov r11, rax

          list_pop_link r11
          integer_add r13, rax
          mov r13, rax

          list_pop_link r11
          mov r11, rax

          list_length r11
          cmp rax, 1
          jne @f

          list_pop_link r11
          mov r11, rax

          mov rax, r11
          mov rax, [rax]
          cmp rax, STRING
          jne @f

          jmp .correct_module_name

          @@:

            string "Ожидалась одна чистая строка"
            error_raw rax
            exit -1

          .correct_module_name:

          string 10
          mov rbx, rax

          integer_inc r13
          list_get_link r10, rax
          mov rbx, rax

          is_equal rax, rbx
          boolean_value rax
          cmp rax, 1
          je .correct_newline

            raw_string "Ожидался перенос строки"
            error_raw rax
            exit -1

          .correct_newline:

          getcwd
          mov rcx, rax

          list
          mov rbx, rax

          list_append_link rbx, rcx
          list_append_link rbx, r11

          string "/"
          join rbx, rax

          get_absolute_path rax
          mov r11, rax

          list_include [модули], r11
          boolean_value rax
          cmp rax, 1
          je .included

            list_append [модули], r11

            string "/"
            mov rbx, rax
            integer 1
            split_from_right_links r11, rbx, rax
            mov rbx, rax

            list_pop_link rbx
            list_pop_link rbx

            chdir rax

            string ".корс"
            string_extend_links r11, rax

            open_file r11
            mov rbx, rax

            read_file rbx
            mov r11, rax

            close_file rbx

            tokenizer r11

            list_extend_links r12, rax
            list_pop_link r12

            chdir rcx

          .included:

          string ""
          mov r11, rax

          jmp .while

        .not_include:

        integer_copy [ТИП_КЛЮЧЕВОЕ_СЛОВО]
        mov [тип_токена], rax
        jmp .write_token

      .not_keyword:

      integer_copy [ТИП_ИДЕНТИФИКАТОР]
      mov [тип_токена], rax
      jmp .write_token

    .not_identifier:

    string '"'
    is_equal r11, rax
    boolean_value rax
    cmp rax, 1
    jne .not_string

      list_slice_links r10, r13
      find_first_string rax
      mov r11, rax

      list_pop_link r11
      integer_add r13, rax
      mov r13, rax

      list_pop_link r11
      mov r11, rax

      integer_copy [ТИП_СТРОКА]
      mov [тип_токена], rax

      jmp .write_token

    .not_string:

    string "!"
    is_equal r11, rax
    boolean_value rax
    cmp rax, 1
    jne .not_exclamation_mark

      integer_copy r13
      integer_inc rax
      list_get_link r10, rax
      string_extend_links r11, rax

      string "!!"
      is_equal r11, rax
      boolean_value rax
      cmp rax, 1
      jne .not_oneline_comment

        string 10
        mov rbx, rax

        .while_oneline_comment:

          list_length r10
          integer rax
          is_equal r13, rax
          boolean_value rax
          cmp rax, 1
          je .end_while_oneline_comment

          integer_inc r13
          list_get_link r10, rax
          is_equal rbx, rax
          boolean_value rax
          cmp rax, 1
          jne .while_oneline_comment

        .end_while_oneline_comment:

        integer_dec r13

        jmp .continue

      .not_oneline_comment:

      string "!*"
      is_equal r11, rax
      boolean_value rax
      cmp rax, 1
      jne .not_multiline_comment

        string "*"
        mov r8, rax

        string "!"
        mov r9, rax

        .while_multiline_comment:

          list_length r10
          dec rax
          integer rax
          is_equal r13, rax
          boolean_value rax
          cmp rax, 1
          je .incorrect_multiline_comment

          integer_inc r13
          list_get_link r10, rax

          is_equal r8, rax
          boolean_value rax
          cmp rax, 1
          jne .while_multiline_comment

          integer_inc r13
          list_get_link r10, rax

          is_equal r9, rax
          boolean_value rax
          cmp rax, 1
          jne .while_multiline_comment

        jmp .continue

        .incorrect_multiline_comment:

        raw_string "Ожидалось *! в конце комментария", 10
        error_raw rax
        exit -1

      .not_multiline_comment:

      string "!="
      is_equal r11, rax
      boolean_value rax
      cmp rax, 1
      jne .not_not_equal

        integer_inc r13

        integer_copy [ТИП_НЕ_РАВНО]
        mov [тип_токена], rax

        jmp .write_token

      .not_not_equal:

      list
      mov rbx, rax

      string "Неизвестный токен:"
      list_append_link rbx, rax
      list_append_link rbx, r11

      error rax
      exit -1

    .not_exclamation_mark:

    string "%"
    is_equal r11, rax
    boolean_value rax
    cmp rax, 1
    jne .not_percent

      integer_copy r13
      integer_inc rax
      list_get_link r10, rax
      string_extend_links r11, rax

      string "%("
      is_equal r11, rax
      boolean_value rax
      cmp rax, 1
      jne .not_open_list_paren

        integer_inc r13

        integer_copy [ТИП_ОТКРЫВАЮЩАЯ_СКОБКА_СПИСКА]
        mov [тип_токена], rax

        jmp .write_token

      .not_open_list_paren:

      list
      mov rbx, rax

      string "Неизвестный токен:"
      list_append_link rbx, rax
      list_append_link rbx, r11

      error rax
      exit -1

    .not_percent:

    string '\'
    is_equal r11, rax
    boolean_value rax
    cmp rax, 1
    jne .not_backslash

      integer_copy r13
      integer_inc rax
      list_get_link r10, rax
      string_extend_links r11, rax

      string "\/"
      is_equal r11, rax
      boolean_value rax
      cmp rax, 1
      jne .not_lower

        integer_inc r13

        integer_copy r13
        integer_inc rax
        list_get_link r10, rax
        string_extend_links r11, rax

        string "\/="
        is_equal r11, rax
        boolean_value rax
        cmp rax, 1
        jne .not_lower_or_equal

          integer_inc r13

          integer_copy [ТИП_МЕНЬШЕ_ИЛИ_РАВНО]
          mov [тип_токена], rax
          jmp .write_token

        .not_lower_or_equal:

        string_pop_link r11

        integer_copy [ТИП_МЕНЬШЕ]
        mov [тип_токена], rax
        jmp .write_token

      .not_lower:

      list
      mov rbx, rax

      string "Неизвестный токен:"
      list_append_link rbx, rax
      list_append_link rbx, r11

      error rax
      exit -1

    .not_backslash:

    string "/"
    is_equal r11, rax
    boolean_value rax
    cmp rax, 1
    jne .not_slash

      integer_copy r13
      integer_inc rax
      list_get_link r10, rax
      string_extend_links r11, rax

      string '/\'
      is_equal r11, rax
      boolean_value rax
      cmp rax, 1
      jne .not_greater

        integer_inc r13

        integer_copy r13
        integer_inc rax
        list_get_link r10, rax
        string_extend_links r11, rax

        string "/\="
        is_equal r11, rax
        boolean_value rax
        cmp rax, 1
        jne .not_greater_or_equal

          integer_inc r13

          integer_copy [ТИП_БОЛЬШЕ_ИЛИ_РАВНО]
          mov [тип_токена], rax
          jmp .write_token

        .not_greater_or_equal:

        string_pop_link r11

        integer_copy [ТИП_БОЛЬШЕ]
        mov [тип_токена], rax
        jmp .write_token

      .not_greater:

      string "//"
      is_equal r11, rax
      boolean_value rax
      cmp rax, 1
      jne .not_integer_divison

        integer_inc r13

        integer_copy r13
        integer_inc rax
        list_get_link r10, rax
        string_extend_links r11, rax

        string "///"
        is_equal r11, rax
        boolean_value rax
        cmp rax, 1
        jne .not_rooting

          integer_inc r13

          integer_copy [ТИП_ИЗВЛЕЧЕНИЕ_КОРНЯ]
          mov [тип_токена], rax
          jmp .write_token

        .not_rooting:

        string_pop_link r11

        integer_copy [ТИП_ЦЕЛОЧИСЛЕННОЕ_ДЕЛЕНИЕ]
        mov [тип_токена], rax
        jmp .write_token

      .not_integer_divison:

      string_pop_link r11

      integer_copy [ТИП_ДЕЛЕНИЕ]
      mov [тип_токена], rax
      jmp .write_token

    .not_slash:

    string "*"
    is_equal r11, rax
    boolean_value rax
    cmp rax, 1
    jne .not_star

      integer_copy r13
      integer_inc rax
      list_get_link r10, rax
      string_extend_links r11, rax

      string "**"
      is_equal r11, rax
      boolean_value rax
      cmp rax, 1
      jne .not_exponentiation

        integer_inc r13

        integer_copy [ТИП_ВОЗВЕДЕНИЕ_В_СТЕПЕНЬ]
        mov [тип_токена], rax
        jmp .write_token

      .not_exponentiation:

      string_pop_link r11

      integer_copy [ТИП_УМНОЖЕНИЕ]
      mov [тип_токена], rax
      jmp .write_token

    .not_star:

    string "+"
    is_equal r11, rax
    boolean_value rax
    cmp rax, 1
    jne .not_plus

      integer_copy r13
      integer_inc rax
      list_get_link r10, rax
      string_extend_links r11, rax

      string "++"
      is_equal r11, rax
      boolean_value rax
      cmp rax, 1
      jne .not_increment

        integer_inc r13

        null
        mov rcx, rax
        boolean 0
        mov rdx, rax

        list_length r12
        cmp rax, 0
        je .not_pre_increment

        integer -1
        list_get_link r12, rax
        token_check_type rax, [ТИП_ИДЕНТИФИКАТОР]
        cmp rax, 1
        jne .not_pre_increment

          list_pop_link r12
          mov rcx, rax
          boolean 1
          mov rdx, rax

        .not_pre_increment:

        ; Значение истинно, когда операция имеет низший приоритет

        dictionary
        mov rbx, rax
        integer_copy [ТИП_ИНКРЕМЕНТАЦИЯ]
        dictionary_set rbx, [тип], rax
        dictionary_set rbx, [значение], rdx

        list_append_link r12, rax

        null
        is_equal rcx, rax
        boolean_value rax
        cmp rax, 1
        je .continue

        list_append_link r12, rcx
        jmp .continue

      .not_increment:

      string_pop_link r11

      integer_copy [ТИП_СЛОЖЕНИЕ]
      mov [тип_токена], rax
      jmp .write_token

    .not_plus:

    string "-"
    is_equal r11, rax
    boolean_value rax
    cmp rax, 1
    jne .not_minus

      integer_copy r13
      integer_inc rax
      list_get_link r10, rax
      string_extend_links r11, rax

      string "--"
      is_equal r11, rax
      boolean_value rax
      cmp rax, 1
      jne .not_decrement

        integer_inc r13

        integer_copy r13
        integer_inc rax
        list_get_link r10, rax
        string_extend_links r11, rax

        string "---"
        is_equal r11, rax
        boolean_value rax
        cmp rax, 1
        jne .not_end_of_construction_1

          integer_inc r13

          integer_copy [ТИП_КОНЕЦ_КОНСТРУКЦИИ]
          mov [тип_токена], rax
          jmp .write_token

        .not_end_of_construction_1:

        null
        mov rcx, rax
        boolean 0
        mov rdx, rax

        list_length r12
        cmp rax, 0
        je .not_pre_decrement

        integer -1
        list_get_link r12, rax
        token_check_type rax, [ТИП_ИДЕНТИФИКАТОР]
        cmp rax, 1
        jne .not_pre_decrement

          list_pop_link r12
          mov rcx, rax
          boolean 1
          mov rdx, rax

        .not_pre_decrement:

        ; Значение истинно, когда операция имеет низший приоритет

        dictionary
        mov rbx, rax
        integer_copy [ТИП_ДЕКРЕМЕНТАЦИЯ]
        dictionary_set rbx, [тип], rax
        dictionary_set rbx, [значение], rdx

        list_append_link r12, rax

        null
        is_equal rcx, rax
        boolean_value rax
        cmp rax, 1
        je .continue

        list_append_link r12, rcx
        jmp .continue

      .not_decrement:

      string_pop_link r11

      integer_copy [ТИП_ВЫЧИТАНИЕ]
      mov [тип_токена], rax
      jmp .write_token

    .not_minus:

    string "="
    is_equal r11, rax
    boolean_value rax
    cmp rax, 1
    jne .not_assign

      integer_copy r13
      integer_inc rax
      list_get_link r10, rax
      string_extend_links r11, rax

      string "=="
      is_equal r11, rax
      boolean_value rax
      cmp rax, 1
      jne .not_equal

        integer_inc r13

        integer_copy r13
        integer_inc rax
        list_get_link r10, rax
        string_extend_links r11, rax

        string "==="
        is_equal r11, rax
        boolean_value rax
        cmp rax, 1
        jne .not_end_of_construction_2

          integer_inc r13

          integer_copy [ТИП_КОНЕЦ_КОНСТРУКЦИИ]
          mov [тип_токена], rax
          jmp .write_token

        .not_end_of_construction_2:

        string_pop_link r11

        integer_copy [ТИП_РАВНО]
        mov [тип_токена], rax
        jmp .write_token

      .not_equal:

      string_pop_link r11

      integer_copy [ТИП_ПРИСВАИВАНИЕ]
      mov [тип_токена], rax
      jmp .write_token

    .not_assign:

    integer -1
    dictionary_get_link [типы], r11, rax
    mov [тип_токена], rax

    integer -1
    is_equal rax, [тип_токена]
    boolean_value rax
    cmp rax, 1
    jne .write_token

    list
    mov rbx, rax

    string "Неизвестный токен:"
    list_append_link rbx, rax
    to_string r11
    list_append_link rbx, rax

    error rax
    exit -1

    .write_token:

    dictionary
    dictionary_set_link rax, [тип], [тип_токена]
    dictionary_set_link rax, [значение], r11
    list_append_link r12, rax

    .continue:

    string ""
    mov r11, rax

    ; индекс++
    integer_inc r13

    list_length r10
    integer rax
    is_equal rax, r13
    boolean_value rax
    cmp rax, 1
    jne .while

  dictionary
  mov rbx, rax
  integer_copy [ТИП_КОНЕЦ_ФАЙЛА]
  dictionary_set_link rbx, [тип], rax
  string ""
  dictionary_set_link rbx, [значение], rax
  list_append_link r12, rax

  ret

f_find_first_string:
  get_arg 0
  mov r13, rax

  string ''
  mov r11, rax

  integer 0
  mov r12, rax

  list
  mov rcx, rax

  .while_string:
    integer_inc r12
    list_get_link r13, rax
    mov rbx, rax

    string '"'
    is_equal rbx, rax
    boolean_value rax
    cmp rax, 1
    je .while_string_end

    string '\'
    is_equal rbx, rax
    boolean_value rax
    cmp rax, 1
    jne .check_string_end

      integer_inc r12
      list_get_link r13, rax
      mov rbx, rax

      string "("
      is_equal rbx, rax
      boolean_value rax
      cmp rax, 1
      jne .not_expression

        mov rdx, 1
        integer_inc r12

        list_append_link rcx, r11

        string ")"
        mov r8, rax

        string "("
        mov r9, rax

        string ""
        mov r10, rax

        .parse_expression:

          list_get_link r13, r12
          mov rbx, rax

          is_equal rbx, r9
          boolean_value rax
          cmp rax, 1
          jne .not_open_paren
            inc rdx
            jmp .parse_expression_continue
          .not_open_paren:

          is_equal rbx, r8
          boolean_value rax
          cmp rax, 1
          jne .not_close_paren

            dec rdx

            cmp rdx, 0
            jne .parse_expression_continue

            push r12, r13

            string 10
            string_extend_links r10, rax

            tokenizer r10
            copy rax
            mov r10, rax

            pop rax
            mov r13, rax

            pop rax
            mov r12, rax

            string ""
            mov r11, rax

            list_append_link rcx, r10
            jmp .while_string

          .not_close_paren:

          .parse_expression_continue:

          string_extend_links r10, rbx
          integer_inc r12

          jmp .parse_expression

      .not_expression:

      string '"'
      is_equal rbx, rax
      boolean_value rax
      cmp rax, 1
      jne .not_double_quote
        string '"'
        jmp .end_escape_sequence
      .not_double_quote:

      string '\'
      is_equal rbx, rax
      boolean_value rax
      cmp rax, 1
      jne .not_backslash
        string '\'
        jmp .end_escape_sequence
      .not_backslash:

      string "т"
      is_equal rbx, rax
      boolean_value rax
      cmp rax, 1
      jne .not_tab_sequence
        string 9
        jmp .end_escape_sequence
      .not_tab_sequence:

      string "н"
      is_equal rbx, rax
      boolean_value rax
      cmp rax, 1
      jne .not_newline_sequence
        string 10
        jmp .end_escape_sequence
      .not_newline_sequence:

      raw_string 'Неизвестная управляющая последовательность: \'
      error_raw rax
      exit -1

      .end_escape_sequence:

      mov rbx, rax
      string_extend_links r11, rbx
      jmp .while_string

    .check_string_end:

    string_extend_links r11, rbx
    jmp .while_string

  .while_string_end:

  list_append_link rcx, r11

  list
  list_append_link rax, rcx
  list_append_link rax, r12

  ret
