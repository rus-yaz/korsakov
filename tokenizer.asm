; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

section "tokenizer" executable

macro tokenizer filename* {
  enter filename

  call f_tokenizer

  return
}

f_tokenizer:
  ; символы = Список(код)
  get_arg 0
  string_to_list rax
  mov [символы], rax

  ; токен = ""
  string ""
  mem_mov [токен], rax

  ; токены = ()
  list
  mov [токены], rax

  ; индекс = 0
  integer 0
  mov [индекс], rax

  .while:
    ; токен += символы.индекс
    list_get_link [символы], [индекс]
    string_extend_links [токен], rax

    mov rbx, 0
    .new_token_while:

      string " "
      is_equal [токен], rax
      boolean_value rax
      cmp rax, 1
      je .find_new_token

      string 10
      is_equal [токен], rax
      boolean_value rax
      cmp rax, 1
      jne .new_token_while_end

      mov rbx, 1

      .find_new_token:

      integer_inc [индекс]

      list_length [символы]
      integer rax
      is_equal [индекс], rax
      boolean_value rax
      cmp rax, 1
      je .new_token_while_end

      list_get_link [символы], [индекс]
      mov [токен], rax

      jmp .new_token_while

    .new_token_while_end:

    cmp rbx, 1
    jne .not_newline

      integer_dec [индекс]

      list_length [токены]
      cmp rax, 0
      je .continue_newline_check

      integer -1
      list_get_link [токены], rax
      mov rbx, rax
      string "тип"
      dictionary_get_link rbx, rax

      is_equal rax, [ТИП_ПЕРЕНОС_СТРОКИ]
      boolean_value rax
      cmp rax, 1
      je .continue

      .continue_newline_check:

      string 10
      mov [токен], rax
      integer_copy [ТИП_ПЕРЕНОС_СТРОКИ]
      mov [тип_токена], rax

      jmp .write_token

    .not_newline:

    is_digit [токен]
    cmp rax, 1
    jne .not_digit

      .while_digit:
        integer 1
        integer_add [индекс], rax

        list_get_link [символы], rax
        mov rbx, rax

        string "_"
        is_equal rbx, rax
        boolean_value rax
        cmp rax, 1
        jne .not_divider
          integer_inc [индекс]
          jmp .while_digit
        .not_divider:

        is_digit rbx
        cmp rax, 1
        jne .end_while_digit

        string_extend_links [токен], rbx
        integer_inc [индекс]
        jmp .while_digit

      .end_while_digit:

      integer_copy [ТИП_ЦЕЛОЕ_ЧИСЛО]
      mov [тип_токена], rax

      jmp .write_token

    .not_digit:

    is_alpha [токен]
    cmp rax, 1
    je .while_identifier
    string "_"
    is_equal [токен], rax
    boolean_value rax
    cmp rax, 1
    jne .not_identifier

      .while_identifier:
        integer 1
        integer_add [индекс], rax

        list_get_link [символы], rax
        mov rbx, rax

        is_alpha rbx
        cmp rax, 1
        je .continue_identifier

        string "_"
        is_equal rbx, rax
        boolean_value rax
        cmp rax, 1
        jne .end_while_identifier

        .continue_identifier:

        string_extend_links [токен], rbx
        integer_inc [индекс]
        jmp .while_identifier

      .end_while_identifier:

      list_include [ключевые_слова], [токен]
      boolean_value rax
      cmp rax, 1
      jne .not_keyword

        integer_copy [ТИП_КЛЮЧЕВОЕ_СЛОВО]
        mov [тип_токена], rax
        jmp .write_token

      .not_keyword:

      integer_copy [ТИП_ИДЕНТИФИКАТОР]
      mov [тип_токена], rax
      jmp .write_token

    .not_identifier:

    string '"'
    is_equal [токен], rax
    boolean_value rax
    cmp rax, 1
    jne .not_string
      .while_string:
        integer_inc [индекс]
        list_get_link [символы], rax
        mov rbx, rax
        string_extend_links [токен], rax

        string '"'
        is_equal rbx, rax
        boolean_value rax
        cmp rax, 1
        jne .while_string

      integer_copy [ТИП_СТРОКА]
      mov [тип_токена], rax

      jmp .write_token

    .not_string:

    string "!"
    is_equal [токен], rax
    boolean_value rax
    cmp rax, 1
    jne .not_exclamation_mark

      integer_copy [индекс]
      integer_inc rax
      list_get_link [символы], rax
      string_extend_links [токен], rax

      string "!!"
      is_equal [токен], rax
      boolean_value rax
      cmp rax, 1
      jne .not_oneline_comment

        string 10
        mov rbx, rax

        .while_oneline_comment:

          integer_inc [индекс]
          list_get_link [символы], rax
          is_equal rbx, rax
          boolean_value rax
          cmp rax, 1
          jne .while_oneline_comment

        jmp .continue

      .not_oneline_comment:

      string "!*"
      is_equal [токен], rax
      boolean_value rax
      cmp rax, 1
      jne .not_multiline_comment

        string "*"
        mov r8, rax

        string "!"
        mov r9, rax

        .while_multiline_comment:
          integer_inc [индекс]
          list_get_link [символы], rax

          is_equal r8, rax
          boolean_value rax
          cmp rax, 1
          jne .while_multiline_comment

          integer_inc [индекс]
          list_get_link [символы], rax

          is_equal r9, rax
          boolean_value rax
          cmp rax, 1
          jne .while_multiline_comment

        jmp .continue

      .not_multiline_comment:

      string "!="
      is_equal [токен], rax
      boolean_value rax
      cmp rax, 1
      jne .not_not_equal

        integer_inc [индекс]

        integer_copy [ТИП_НЕ_РАВНО]
        mov [тип_токена], rax

        jmp .write_token

      .not_not_equal:

      buffer_to_string UNEXPECTED_TOKEN_ERROR
      mov rbx, rax

      list
      list_append_link rax, rbx
      list_append_link rax, [токен]
      print rax
      exit -1

    .not_exclamation_mark:

    string "%"
    is_equal [токен], rax
    boolean_value rax
    cmp rax, 1
    jne .not_percent

      integer_copy [индекс]
      integer_inc rax
      list_get_link [символы], rax
      string_extend_links [токен], rax

      string "%("
      is_equal [токен], rax
      boolean_value rax
      cmp rax, 1
      jne .not_open_list_paren

        integer_inc [индекс]

        integer_copy [ТИП_ОТКРЫВАЮЩАЯ_СКОБКА_СПИСКА]
        mov [тип_токена], rax

        jmp .write_token

      .not_open_list_paren:

      buffer_to_string UNEXPECTED_TOKEN_ERROR
      mov rbx, rax

      list
      list_append_link rax, rbx
      list_append_link rax, [токен]
      print rax
      exit -1

    .not_percent:

    string "\"
    is_equal [токен], rax
    boolean_value rax
    cmp rax, 1
    jne .not_backslash

      integer_copy [индекс]
      integer_inc rax
      list_get_link [символы], rax
      string_extend_links [токен], rax

      string "\/"
      is_equal [токен], rax
      boolean_value rax
      cmp rax, 1
      jne .not_lower

        integer_inc [индекс]

        integer_copy [индекс]
        integer_inc rax
        list_get_link [символы], rax
        string_extend_links [токен], rax

        string "\/="
        is_equal [токен], rax
        boolean_value rax
        cmp rax, 1
        jne .not_lower_or_equal

          integer_inc [индекс]

          integer_copy [ТИП_МЕНЬШЕ_ИЛИ_РАВНО]
          mov [тип_токена], rax
          jmp .write_token

        .not_lower_or_equal:

        string_pop_link [токен]

        integer_copy [ТИП_МЕНЬШЕ]
        mov [тип_токена], rax
        jmp .write_token

      .not_lower:

      buffer_to_string UNEXPECTED_TOKEN_ERROR
      mov rbx, rax

      list
      list_append_link rax, rbx
      list_append_link rax, [токен]
      print rax
      exit -1

    .not_backslash:

    string "/"
    is_equal [токен], rax
    boolean_value rax
    cmp rax, 1
    jne .not_slash

      integer_copy [индекс]
      integer_inc rax
      list_get_link [символы], rax
      string_extend_links [токен], rax

      string "/\"
      is_equal [токен], rax
      boolean_value rax
      cmp rax, 1
      jne .not_greater

        integer_inc [индекс]

        integer_copy [индекс]
        integer_inc rax
        list_get_link [символы], rax
        string_extend_links [токен], rax

        string "/\="
        is_equal [токен], rax
        boolean_value rax
        cmp rax, 1
        jne .not_greater_or_equal

          integer_inc [индекс]

          integer_copy [ТИП_БОЛЬШЕ_ИЛИ_РАВНО]
          mov [тип_токена], rax
          jmp .write_token

        .not_greater_or_equal:

        string_pop_link [токен]

        integer_copy [ТИП_БОЛЬШЕ]
        mov [тип_токена], rax
        jmp .write_token

      .not_greater:

      string "//"
      is_equal [токен], rax
      boolean_value rax
      cmp rax, 1
      jne .not_integer_divison

        integer_inc [индекс]

        integer_copy [индекс]
        integer_inc rax
        list_get_link [символы], rax
        string_extend_links [токен], rax

        string "///"
        is_equal [токен], rax
        boolean_value rax
        cmp rax, 1
        jne .not_rooting

          integer_inc [индекс]

          integer_copy [ТИП_ИЗВЛЕЧЕНИЕ_КОРНЯ]
          mov [тип_токена], rax
          jmp .write_token

        .not_rooting:

        string_pop_link [токен]

        integer_copy [ТИП_ЦЕЛОЧИСЛЕННОЕ_ДЕЛЕНИЕ]
        mov [тип_токена], rax
        jmp .write_token

      .not_integer_divison:

      string_pop_link [токен]

      integer_copy [ТИП_ДЕЛЕНИЕ]
      mov [тип_токена], rax
      jmp .write_token

    .not_slash:

    string "*"
    is_equal [токен], rax
    boolean_value rax
    cmp rax, 1
    jne .not_star

      integer_copy [индекс]
      integer_inc rax
      list_get_link [символы], rax
      string_extend_links [токен], rax

      string "**"
      is_equal [токен], rax
      boolean_value rax
      cmp rax, 1
      jne .not_exponentiation

        integer_inc [индекс]

        integer_copy [ТИП_ВОЗВЕДЕНИЕ_В_СТЕПЕНЬ]
        mov [тип_токена], rax
        jmp .write_token

      .not_exponentiation:

      string_pop_link [токен]

      integer_copy [ТИП_УМНОЖЕНИЕ]
      mov [тип_токена], rax
      jmp .write_token

    .not_star:

    string "+"
    is_equal [токен], rax
    boolean_value rax
    cmp rax, 1
    jne .not_plus

      integer_copy [индекс]
      integer_inc rax
      list_get_link [символы], rax
      string_extend_links [токен], rax

      string "++"
      is_equal [токен], rax
      boolean_value rax
      cmp rax, 1
      jne .not_increment

        integer_inc [индекс]

        null
        mov rcx, rax
        boolean 0
        mov rdx, rax

        list_length [токены]
        cmp rax, 0
        je .not_pre_increment

        integer -1
        list_get_link [токены], rax
        token_check_type rax, [ТИП_ИДЕНТИФИКАТОР]
        cmp rax, 1
        jne .not_pre_increment

          list_pop_link [токены]
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

        list_append_link [токены], rax

        null
        is_equal rcx, rax
        boolean_value rax
        cmp rax, 1
        je .continue

        list_append_link [токены], rcx
        jmp .continue

      .not_increment:

      string_pop_link [токен]

      integer_copy [ТИП_СЛОЖЕНИЕ]
      mov [тип_токена], rax
      jmp .write_token

    .not_plus:

    string "-"
    is_equal [токен], rax
    boolean_value rax
    cmp rax, 1
    jne .not_minus

      integer_copy [индекс]
      integer_inc rax
      list_get_link [символы], rax
      string_extend_links [токен], rax

      string "--"
      is_equal [токен], rax
      boolean_value rax
      cmp rax, 1
      jne .not_decrement

        integer_inc [индекс]

        integer_copy [индекс]
        integer_inc rax
        list_get_link [символы], rax
        string_extend_links [токен], rax

        string "---"
        is_equal [токен], rax
        boolean_value rax
        cmp rax, 1
        jne .not_end_of_construction_1

          integer_inc [индекс]

          integer_copy [ТИП_КОНЕЦ_КОНСТРУКЦИИ]
          mov [тип_токена], rax
          jmp .write_token

        .not_end_of_construction_1:

        null
        mov rcx, rax
        boolean 0
        mov rdx, rax

        list_length [токены]
        cmp rax, 0
        je .not_pre_decrement

        integer -1
        list_get_link [токены], rax
        token_check_type rax, [ТИП_ИДЕНТИФИКАТОР]
        cmp rax, 1
        jne .not_pre_decrement

          list_pop_link [токены]
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

        list_append_link [токены], rax

        null
        is_equal rcx, rax
        boolean_value rax
        cmp rax, 1
        je .continue

        list_append_link [токены], rcx
        jmp .continue

      .not_decrement:

      string_pop_link [токен]

      integer_copy [ТИП_ВЫЧИТАНИЕ]
      mov [тип_токена], rax
      jmp .write_token

    .not_minus:

    string "="
    is_equal [токен], rax
    boolean_value rax
    cmp rax, 1
    jne .not_assign

      integer_copy [индекс]
      integer_inc rax
      list_get_link [символы], rax
      string_extend_links [токен], rax

      string "=="
      is_equal [токен], rax
      boolean_value rax
      cmp rax, 1
      jne .not_equal

        integer_inc [индекс]

        integer_copy [индекс]
        integer_inc rax
        list_get_link [символы], rax
        string_extend_links [токен], rax

        string "==="
        is_equal [токен], rax
        boolean_value rax
        cmp rax, 1
        jne .not_end_of_construction_2

          integer_inc [индекс]

          integer_copy [ТИП_КОНЕЦ_КОНСТРУКЦИИ]
          mov [тип_токена], rax
          jmp .write_token

        .not_end_of_construction_2:

        string_pop_link [токен]

        integer_copy [ТИП_РАВНО]
        mov [тип_токена], rax
        jmp .write_token

      .not_equal:

      string_pop_link [токен]

      integer_copy [ТИП_ПРИСВАИВАНИЕ]
      mov [тип_токена], rax
      jmp .write_token

    .not_assign:

    integer -1
    dictionary_get_link [типы], [токен], rax
    mov [тип_токена], rax

    integer -1
    is_equal rax, [тип_токена]
    boolean_value rax
    cmp rax, 1
    jne .write_token

    buffer_to_string UNEXPECTED_TOKEN_ERROR
    mov rbx, rax

    list
    list_append_link rax, rbx
    list_append_link rax, [токен]
    print rax
    exit -1

    .write_token:

    dictionary
    dictionary_set_link rax, [тип], [тип_токена]
    dictionary_set_link rax, [значение], [токен]
    list_append_link [токены], rax

    .continue:

    string ""
    mov [токен], rax

    ; индекс++
    integer_inc [индекс]

    list_length [символы]
    integer rax
    is_equal rax, [индекс]
    boolean_value rax
    cmp rax, 1
    jne .while

  dictionary
  mov rbx, rax
  integer_copy [ТИП_КОНЕЦ_ФАЙЛА]
  dictionary_set_link rbx, [тип], rax
  string ""
  dictionary_set_link rbx, [значение], rax
  list_append_link [токены], rax

  ret
