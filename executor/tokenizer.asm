; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

section "tokenizer_data" writable

  НАЧАЛО_СТРОКА    rq 1
  НАЧАЛО_СТОЛБЕЦ   rq 1
  КОНЕЦ_СТРОКА     rq 1
  КОНЕЦ_СТОЛБЕЦ    rq 1
  ТЕКУЩИЙ_ФАЙЛ     rq 1
  ПРОЙДЕННЫЕ_ФАЙЛЫ rq 1

section "tokenizer_code" executable

; @function tokenizer
; @description Основная функция токенизатора, разбивает код на токены
; @param code - исходный код для токенизации
; @param filename - имя файла с кодом
; @return Список токенов
; @example
;   tokenizer source_code, "main.ksk"
_function tokenizer, rbx, rcx, rdx, r8, r9, r10, r11, r12, r13, r14
  ; символы = Список(код)
  get_arg 0
  string_to_list rax
  mov r10, rax

  cmp [ПРОЙДЕННЫЕ_ФАЙЛЫ], 0
  jne @f
    list
    mov [ПРОЙДЕННЫЕ_ФАЙЛЫ], rax
  @@:

  get_arg 1
  mov [ТЕКУЩИЙ_ФАЙЛ], rax

  string 10
  list_append_link r10, rax

  ; токен = ""
  string ""
  mov r11, rax

  ; токены = ()
  list
  mov r12, rax

  ; индекс = 0
  integer 0
  mov r13, rax

  integer 1
  mov [НАЧАЛО_СТРОКА], rax
  integer_copy rax
  mov [НАЧАЛО_СТОЛБЕЦ], rax
  integer_copy rax
  mov [КОНЕЦ_СТРОКА], rax
  integer_copy rax
  mov [КОНЕЦ_СТОЛБЕЦ], rax

  .while:
    ; токен += символы.индекс
    list_get_link r10, r13
    string_extend_links r11, rax

    integer_copy [КОНЕЦ_СТРОКА]
    mov [НАЧАЛО_СТРОКА], rax
    integer_copy [КОНЕЦ_СТОЛБЕЦ]
    mov [НАЧАЛО_СТОЛБЕЦ], rax

    string " "
    is_equal r11, rax
    boolean_value rax
    cmp rax, 1
    jne .not_space

    integer_inc [НАЧАЛО_СТОЛБЕЦ]
    integer_inc [КОНЕЦ_СТОЛБЕЦ]

    .space:

      integer_inc r13

      list_length r10
      integer rax
      is_lower_or_equal rax, r13
      boolean_value rax
      cmp rax, 1
      je .continue

      list_get_link r10, r13
      mov r11, rax

      integer_inc [НАЧАЛО_СТОЛБЕЦ]
      integer_inc [КОНЕЦ_СТОЛБЕЦ]

      string " "
      is_equal rax, r11
      boolean_value rax
      cmp rax, 1
      je .space

      integer_dec [НАЧАЛО_СТОЛБЕЦ]
      integer_dec [КОНЕЦ_СТОЛБЕЦ]

    .not_space:

    string 10
    is_equal r11, rax
    boolean_value rax
    cmp rax, 1
    jne .not_newline

    integer_inc [КОНЕЦ_СТРОКА]
    integer 0
    mov [КОНЕЦ_СТОЛБЕЦ], rax

    mem_mov [тип_токена], [ТИП_ПЕРЕНОС_СТРОКИ]

    .newline:
      integer_inc r13

      list_length r10
      integer rax
      is_lower_or_equal rax, r13
      boolean_value rax
      cmp rax, 1
      je @f

      list_get_link r10, r13
      mov r11, rax

      integer_inc [КОНЕЦ_СТРОКА]

      string 10
      is_equal r11, rax
      boolean_value rax
      cmp rax, 1
      je .newline

      @@:

      integer_dec [КОНЕЦ_СТРОКА]
      integer_dec r13

      list_length r12
      cmp rax, 0
      je @f

      integer -1
      list_get_link r12, rax
      mov rbx, rax

      token_check_type rbx, [ТИП_ПЕРЕНОС_СТРОКИ]
      cmp rax, 1
      jne @f

        dictionary_get_link rbx, [конец]
        mov rbx, rax

        integer 0
        list_set rbx, rax, [КОНЕЦ_СТРОКА]

        jmp .continue

      @@:

      string 10
      mov r11, rax

      jmp .write_token

    .not_newline:

    string ","
    is_equal r11, rax
    boolean_value rax
    cmp rax, 1
    jne .not_comma
      get_arg 0
      dump_currect_position [ТЕКУЩИЙ_ФАЙЛ], rax, \
                            [НАЧАЛО_СТРОКА], [НАЧАЛО_СТОЛБЕЦ], \
                            [КОНЕЦ_СТРОКА], [КОНЕЦ_СТОЛБЕЦ]
      list_append_link [ПРОЙДЕННЫЕ_ФАЙЛЫ], rax

      string "Символ `,` может быть использован только в вещественных числах"
      syntax_error [ПРОЙДЕННЫЕ_ФАЙЛЫ], rax

      exit -1
    .not_comma:

    is_digit r11
    cmp rax, 1
    jne .not_digit

      mem_mov [тип_токена], [ТИП_ЦЕЛОЕ_ЧИСЛО]

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
          integer_inc [КОНЕЦ_СТОЛБЕЦ]
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
            integer_inc [КОНЕЦ_СТОЛБЕЦ]

            get_arg 0
            dump_currect_position [ТЕКУЩИЙ_ФАЙЛ], rax, \
                                  [НАЧАЛО_СТРОКА], [НАЧАЛО_СТОЛБЕЦ], \
                                  [КОНЕЦ_СТРОКА], [КОНЕЦ_СТОЛБЕЦ]
            list_append_link [ПРОЙДЕННЫЕ_ФАЙЛЫ], rax

            string "Вторая запятая в вещественном числе"
            syntax_error [ПРОЙДЕННЫЕ_ФАЙЛЫ], rax

            exit -1
          .correct_float_divider:

          mem_mov [тип_токена], [ТИП_ВЕЩЕСТВЕННОЕ_ЧИСЛО]

          mov rcx, 1
          jmp .next_token

        .not_float:

        is_digit rbx
        cmp rax, 1
        jne .end_while_number

        mov rdx, rcx

        .next_token:

        string_extend_links r11, rbx
        integer_inc [КОНЕЦ_СТОЛБЕЦ]
        integer_inc r13
        jmp .while_number

      .end_while_number:

      cmp rdx, rcx
      je .correct_value
        get_arg 0
        dump_currect_position [ТЕКУЩИЙ_ФАЙЛ], rax, \
                              [НАЧАЛО_СТРОКА], [НАЧАЛО_СТОЛБЕЦ], \
                              [КОНЕЦ_СТРОКА], [КОНЕЦ_СТОЛБЕЦ]
        list_append_link [ПРОЙДЕННЫЕ_ФАЙЛЫ], rax

        string "Незавершённое вещественное число"
        syntax_error [ПРОЙДЕННЫЕ_ФАЙЛЫ], rax

        exit -1
      .correct_value:

      is_alpha rbx
      cmp rax, 1
      jne @f
        string_extend_links r11, rbx
        jmp .unkown_token
      @@:

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
        integer_inc [КОНЕЦ_СТОЛБЕЦ]
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

          integer_inc [КОНЕЦ_СТОЛБЕЦ]
          integer_inc r13
          list_get_link r10, rax

          is_equal rax, rbx
          boolean_value rax
          cmp rax, 1
          je .correct_space
            integer_copy [КОНЕЦ_СТОЛБЕЦ]
            integer_dec rax
            mov rbx, rax

            get_arg 0
            dump_currect_position [ТЕКУЩИЙ_ФАЙЛ], rax, \
                                  [НАЧАЛО_СТРОКА], rbx, \
                                  [КОНЕЦ_СТРОКА], [КОНЕЦ_СТОЛБЕЦ]
            list_append_link [ПРОЙДЕННЫЕ_ФАЙЛЫ], rax

            string "Ожидался пробел"
            syntax_error [ПРОЙДЕННЫЕ_ФАЙЛЫ], rax

            exit -1

          .correct_space:

          string '"'
          mov rbx, rax

          integer_inc [КОНЕЦ_СТОЛБЕЦ]
          integer_inc r13
          list_get_link r10, rax

          is_equal rax, rbx
          boolean_value rax
          cmp rax, 1
          je .correct_quotation_mark
            integer_copy [КОНЕЦ_СТОЛБЕЦ]
            integer_dec rax
            mov rbx, rax

            get_arg 0
            dump_currect_position [ТЕКУЩИЙ_ФАЙЛ], rax, \
                                  [НАЧАЛО_СТРОКА], rbx, \
                                  [КОНЕЦ_СТРОКА], [КОНЕЦ_СТОЛБЕЦ]
            list_append_link [ПРОЙДЕННЫЕ_ФАЙЛЫ], rax

            string "Ожидались кавычки"
            syntax_error [ПРОЙДЕННЫЕ_ФАЙЛЫ], rax

            exit -1

          .correct_quotation_mark:

          find_string r10, r13
          mov r11, rax

          integer_inc r13
          integer_inc [КОНЕЦ_СТОЛБЕЦ]

          list_pop_link r11
          mov r14, rax

          integer 0
          is_equal rax, r14
          boolean_value rax
          cmp rax, 1
          jne @f

            integer_copy [КОНЕЦ_СТОЛБЕЦ]
            integer_dec rax
            mov rbx, rax

            get_arg 0
            dump_currect_position [ТЕКУЩИЙ_ФАЙЛ], rax, \
                                  [НАЧАЛО_СТРОКА], rbx, \
                                  [КОНЕЦ_СТРОКА], [КОНЕЦ_СТОЛБЕЦ]
            list_append_link [ПРОЙДЕННЫЕ_ФАЙЛЫ], rax

            string "Ожидалась не пустая строка"
            syntax_error [ПРОЙДЕННЫЕ_ФАЙЛЫ], rax

            exit -1
          @@:

          integer_add r13, r14
          mov r13, rax

          integer_add [КОНЕЦ_СТОЛБЕЦ], r14
          mov [КОНЕЦ_СТОЛБЕЦ], rax

          integer_inc [КОНЕЦ_СТОЛБЕЦ]
          integer_inc r13

          list_pop_link r11
          mov r11, rax

          list_length r11
          cmp rax, 1
          jne @f

          list_pop_link r11
          mov r11, rax

          mov rax, [r11]
          cmp rax, STRING
          jne @f

          jmp .correct_module_name

          @@:
            string_length [ВКЛЮЧИТЬ]
            inc rax
            integer rax
            integer_add [НАЧАЛО_СТОЛБЕЦ], rax
            mov [НАЧАЛО_СТОЛБЕЦ], rax

            get_arg 0
            dump_currect_position [ТЕКУЩИЙ_ФАЙЛ], rax, \
                                  [НАЧАЛО_СТРОКА], [НАЧАЛО_СТОЛБЕЦ], \
                                  [КОНЕЦ_СТРОКА], [КОНЕЦ_СТОЛБЕЦ]
            list_append_link [ПРОЙДЕННЫЕ_ФАЙЛЫ], rax

            string "Ожидалась прямая строка"
            syntax_error [ПРОЙДЕННЫЕ_ФАЙЛЫ], rax

            exit -1

          .correct_module_name:

          getcwd
          mov rcx, rax

          list
          mov rbx, rax

          list_append_link rbx, rcx
          list_append_link rbx, r11

          string "/"
          join rbx, rax

          get_absolute_path rax
          mov r14, rax

          list_include [модули], r14
          boolean_value rax
          cmp rax, 1
          je .included

            list_append [модули], r14

            string "/"
            mov rbx, rax
            integer 1
            split_from_right_links r14, rbx, rax
            mov rbx, rax

            list_pop_link rbx

            list_pop_link rbx
            chdir rax

            string ".корс"
            string_extend_links r14, rax

            open_file r14
            mov rbx, rax

            read_file rbx
            mov r11, rax

            close_file rbx

            get_arg 0
            dump_currect_position [ТЕКУЩИЙ_ФАЙЛ], rax, \
                                  [НАЧАЛО_СТРОКА], [НАЧАЛО_СТОЛБЕЦ], \
                                  [КОНЕЦ_СТРОКА], [КОНЕЦ_СТОЛБЕЦ]
            list_append_link [ПРОЙДЕННЫЕ_ФАЙЛЫ], rax

            tokenizer r11, r14
            list_extend_links r12, rax

            list_pop_link r12 ; Удаление токена окончания файла
            list_pop_link r12 ; Удаление переноса строки

            chdir rcx

            list_pop_link [ПРОЙДЕННЫЕ_ФАЙЛЫ]
            mov rbx, rax

            list_pop_link rbx
            mov [КОНЕЦ_СТОЛБЕЦ], rax
            list_pop_link rbx
            mov [КОНЕЦ_СТРОКА], rax
            list_pop_link rbx
            mov [НАЧАЛО_СТОЛБЕЦ], rax
            list_pop_link rbx
            mov [НАЧАЛО_СТРОКА], rax
            list_pop_link rbx
            ; Код не нуждается в сохранении
            list_pop_link rbx
            mov [ТЕКУЩИЙ_ФАЙЛ], rax

          .included:

          string ""
          mov r11, rax

          jmp .while

        .not_include:

        mem_mov [тип_токена], [ТИП_КЛЮЧЕВОЕ_СЛОВО]
        jmp .write_token

      .not_keyword:

      mem_mov [тип_токена], [ТИП_ИДЕНТИФИКАТОР]
      jmp .write_token

    .not_identifier:

    string '"'
    is_equal r11, rax
    boolean_value rax
    cmp rax, 1
    jne .not_string

      find_string r10, r13
      mov r11, rax

      list_pop_link r11
      mov rbx, rax

      integer_add r13, rbx
      mov r13, rax

      integer_add [КОНЕЦ_СТОЛБЕЦ], rbx
      mov [КОНЕЦ_СТОЛБЕЦ], rax

      integer_inc r13
      integer_inc [КОНЕЦ_СТОЛБЕЦ]

      list_pop_link r11
      mov r11, rax

      mem_mov [тип_токена], [ТИП_СТРОКА]

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

        string ""
        mov r11, rax

        jmp .while

      .not_oneline_comment:

      string "!*"
      is_equal r11, rax
      boolean_value rax
      cmp rax, 1
      jne .not_multiline_comment

        string 10
        mov rbx, rax

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

          integer_inc [КОНЕЦ_СТОЛБЕЦ]
          integer_inc r13
          list_get_link r10, rax
          mov rcx, rax

          is_equal rcx, rbx
          boolean_value rax
          cmp rax, 1
          jne @f

            integer_inc [КОНЕЦ_СТРОКА]

            integer 0
            mov [КОНЕЦ_СТОЛБЕЦ], rax

          @@:

          is_equal r8, rcx
          boolean_value rax
          cmp rax, 1
          jne .while_multiline_comment

          integer_copy r13
          integer_inc rax
          list_get_link r10, rax

          is_equal r9, rax
          boolean_value rax
          cmp rax, 1
          jne .while_multiline_comment

          integer_inc [КОНЕЦ_СТОЛБЕЦ]
          integer_inc r13

        jmp .continue

        .incorrect_multiline_comment:

        integer_copy [НАЧАЛО_СТОЛБЕЦ]
        integer_inc rax
        mov rbx, rax

        get_arg 0
        dump_currect_position [ТЕКУЩИЙ_ФАЙЛ], rax, \
                              [НАЧАЛО_СТРОКА], [НАЧАЛО_СТОЛБЕЦ], \
                              [НАЧАЛО_СТРОКА], rbx
        list_append_link [ПРОЙДЕННЫЕ_ФАЙЛЫ], rax

        string "Ожидалось `*!` в конце комментария"
        syntax_error [ПРОЙДЕННЫЕ_ФАЙЛЫ], rax

        exit -1

      .not_multiline_comment:

      string "!="
      is_equal r11, rax
      boolean_value rax
      cmp rax, 1
      jne .not_not_equal

        integer_inc [КОНЕЦ_СТОЛБЕЦ]
        integer_inc r13

        mem_mov [тип_токена], [ТИП_НЕ_РАВНО]

        jmp .write_token

      .not_not_equal:

      jmp .unkown_token

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

        integer_inc [КОНЕЦ_СТОЛБЕЦ]
        integer_inc r13

        mem_mov [тип_токена], [ТИП_ОТКРЫВАЮЩАЯ_СКОБКА_СПИСКА]

        jmp .write_token

      .not_open_list_paren:

      jmp .unkown_token

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

        integer_inc [КОНЕЦ_СТОЛБЕЦ]
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

          integer_inc [КОНЕЦ_СТОЛБЕЦ]
          integer_inc r13

          mem_mov [тип_токена], [ТИП_МЕНЬШЕ_ИЛИ_РАВНО]
          jmp .write_token

        .not_lower_or_equal:

        string_pop_link r11

        mem_mov [тип_токена], [ТИП_МЕНЬШЕ]
        jmp .write_token

      .not_lower:

      jmp .unkown_token

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

        integer_inc [КОНЕЦ_СТОЛБЕЦ]
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

          integer_inc [КОНЕЦ_СТОЛБЕЦ]
          integer_inc r13

          mem_mov [тип_токена], [ТИП_БОЛЬШЕ_ИЛИ_РАВНО]
          jmp .write_token

        .not_greater_or_equal:

        string_pop_link r11

        mem_mov [тип_токена], [ТИП_БОЛЬШЕ]
        jmp .write_token

      .not_greater:

      string "//"
      is_equal r11, rax
      boolean_value rax
      cmp rax, 1
      jne .not_integer_divison

        integer_inc [КОНЕЦ_СТОЛБЕЦ]
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

          integer_inc [КОНЕЦ_СТОЛБЕЦ]
          integer_inc r13

          mem_mov [тип_токена], [ТИП_ИЗВЛЕЧЕНИЕ_КОРНЯ]
          jmp .write_token

        .not_rooting:

        string_pop_link r11

        mem_mov [тип_токена], [ТИП_ЦЕЛОЧИСЛЕННОЕ_ДЕЛЕНИЕ]
        jmp .write_token

      .not_integer_divison:

      string_pop_link r11

      mem_mov [тип_токена], [ТИП_ДЕЛЕНИЕ]
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

        integer_inc [КОНЕЦ_СТОЛБЕЦ]
        integer_inc r13

        mem_mov [тип_токена], [ТИП_ВОЗВЕДЕНИЕ_В_СТЕПЕНЬ]
        jmp .write_token

      .not_exponentiation:

      string_pop_link r11

      mem_mov [тип_токена], [ТИП_УМНОЖЕНИЕ]
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

        integer_inc [КОНЕЦ_СТОЛБЕЦ]
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
        format_token [ТИП_ИНКРЕМЕНТАЦИЯ], rdx, \
                     [НАЧАЛО_СТРОКА], [НАЧАЛО_СТОЛБЕЦ], \
                     [КОНЕЦ_СТРОКА], [КОНЕЦ_СТОЛБЕЦ]
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

      mem_mov [тип_токена], [ТИП_СЛОЖЕНИЕ]
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

        integer_inc [КОНЕЦ_СТОЛБЕЦ]
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

          integer_inc [КОНЕЦ_СТОЛБЕЦ]
          integer_inc r13

          mem_mov [тип_токена], [ТИП_КОНЕЦ_КОНСТРУКЦИИ]
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

        format_token [ТИП_ДЕКРЕМЕНТАЦИЯ], rdx, \
                     [НАЧАЛО_СТРОКА], [НАЧАЛО_СТОЛБЕЦ], \
                     [КОНЕЦ_СТРОКА], [КОНЕЦ_СТОЛБЕЦ]
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

      mem_mov [тип_токена], [ТИП_ВЫЧИТАНИЕ]
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

        integer_inc [КОНЕЦ_СТОЛБЕЦ]
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

          integer_inc [КОНЕЦ_СТОЛБЕЦ]
          integer_inc r13

          mem_mov [тип_токена], [ТИП_КОНЕЦ_КОНСТРУКЦИИ]
          jmp .write_token

        .not_end_of_construction_2:

        string_pop_link r11

        mem_mov [тип_токена], [ТИП_РАВНО]
        jmp .write_token

      .not_equal:

      string_pop_link r11

      mem_mov [тип_токена], [ТИП_ПРИСВАИВАНИЕ]
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

    .unkown_token:

    get_arg 0
    dump_currect_position [ТЕКУЩИЙ_ФАЙЛ], rax, \
                          [НАЧАЛО_СТРОКА], [НАЧАЛО_СТОЛБЕЦ], \
                          [КОНЕЦ_СТРОКА], [КОНЕЦ_СТОЛБЕЦ]
    list_append_link [ПРОЙДЕННЫЕ_ФАЙЛЫ], rax

    string "Неизвестный токен "
    mov rbx, rax
    to_string r11
    string_extend_links rbx, rax
    syntax_error [ПРОЙДЕННЫЕ_ФАЙЛЫ], rbx

    exit -1

    .write_token:

    format_token [тип_токена], r11, \
                 [НАЧАЛО_СТРОКА], [НАЧАЛО_СТОЛБЕЦ], \
                 [КОНЕЦ_СТРОКА], [КОНЕЦ_СТОЛБЕЦ]
    list_append_link r12, rax

    .continue:

    string ""
    mov r11, rax

    ; индекс++
    integer_inc [КОНЕЦ_СТОЛБЕЦ]
    integer_inc r13

    list_length r10
    integer rax
    is_lower_or_equal rax, r13
    boolean_value rax
    cmp rax, 1
    jne .while

  string ""
  format_token [ТИП_КОНЕЦ_ФАЙЛА], rax, \
               [КОНЕЦ_СТРОКА], [КОНЕЦ_СТОЛБЕЦ], \
               [КОНЕЦ_СТРОКА], [КОНЕЦ_СТОЛБЕЦ]
  list_append_link r12, rax

  mov rax, r12
  ret

; @function find_string
; @description Находит строку в списке символов, начиная с указанной позиции
; @param list - список символов
; @param start - начальная позиция поиска
; @return Найденная строка
; @example
;   find_string char_list, start_pos
_function find_string, rbx, rcx, rdx, r8, r9, r10, r11, r12, r13, r14
  get_arg 0
  mov r14, rax

  get_arg 1
  list_slice_links r14, rax
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

    string 10
    is_equal rbx, rax
    boolean_value rax
    cmp rax, 1
    je .oneline_string_error

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

            push [НАЧАЛО_СТРОКА], [НАЧАЛО_СТОЛБЕЦ], \
                 [КОНЕЦ_СТРОКА], [КОНЕЦ_СТОЛБЕЦ]

            tokenizer r10, [ТЕКУЩИЙ_ФАЙЛ]
            copy rax
            mov r10, rax

            pop rax
            mov [КОНЕЦ_СТОЛБЕЦ], rax
            pop rax
            mov [КОНЕЦ_СТРОКА], rax
            pop rax
            mov [НАЧАЛО_СТОЛБЕЦ], rax
            pop rax
            mov [НАЧАЛО_СТРОКА], rax

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

      string ""
      join r14, rax
      dump_currect_position [ТЕКУЩИЙ_ФАЙЛ], rax, \
                            [НАЧАЛО_СТРОКА], [НАЧАЛО_СТОЛБЕЦ], \
                            [КОНЕЦ_СТРОКА], [КОНЕЦ_СТОЛБЕЦ]
      list_append_link [ПРОЙДЕННЫЕ_ФАЙЛЫ], rax

      string "Неизвестная управляющая последовательность: `", '\'
      xchg rbx, rax
      string_extend_links rbx, rax
      string "`"
      string_extend_links rbx, rax
      syntax_error [ПРОЙДЕННЫЕ_ФАЙЛЫ], rax

      exit -1

      .end_escape_sequence:

      mov rbx, rax
      string_extend_links r11, rbx
      jmp .while_string

    .check_string_end:

    string_extend_links r11, rbx
    jmp .while_string

  .while_string_end:

  integer_dec r12
  list_append_link rcx, r11

  list
  list_append_link rax, rcx
  list_append_link rax, r12

  ret

  .oneline_string_error:
    string ""
    join r14, rax
    dump_currect_position [ТЕКУЩИЙ_ФАЙЛ], rax, \
                          [НАЧАЛО_СТРОКА], [НАЧАЛО_СТОЛБЕЦ], \
                          [КОНЕЦ_СТРОКА], [КОНЕЦ_СТОЛБЕЦ]
    list_append_link [ПРОЙДЕННЫЕ_ФАЙЛЫ], rax

    string "Ожидался второй символ `", '"', "` на этой же строке"
    syntax_error [ПРОЙДЕННЫЕ_ФАЙЛЫ], rax

    exit -1

; @function syntax_error
; @description Выводит сообщение об ошибке синтаксиса
; @param file_stack - стек файлов
; @param message - сообщение об ошибке
; @return Нет возвращаемого значения
; @example
;   syntax_error file_stack, "Ожидался символ ';'"
_function syntax_error, rbx, rcx, rdx, r8, r9, r10, r11, r12, r13, r14, r15
  list
  mov rbx, rax

  integer 0
  mov rcx, rax

  @@:
    list_length [ПРОЙДЕННЫЕ_ФАЙЛЫ]
    integer rax
    is_equal rax, rcx
    boolean_value rax
    cmp rax, 1
    je @f

    list_get_link [ПРОЙДЕННЫЕ_ФАЙЛЫ], rcx
    mov rdx, rax

    string 0x1b, "[38;5;9m"
    list_append_link rbx, rax

    integer 0
    list_get_link rdx, rax
    list_append_link rbx, rax

    string ":", 0x1b, "[0m", 10
    list_append_link rbx, rax

    integer 1
    list_get_link rdx, rax
    mov r11, rax

    integer 2
    list_get_link rdx, rax
    integer_dec rax
    mov r12, rax

    integer 4
    list_get_link rdx, rax
    integer_sub rax, r12
    mov r9, rax

    integer 0
    mov r8, rax

    mov r15, 0

    .while:
      is_greater_or_equal r8, r9
      boolean_value rax
      cmp rax, 1
      je .while_end

      ; Серый цвет
      string 0x1b, "[38;5;8m"
      mov r10, rax

      string "  "
      string_extend_links r10, rax
      integer_copy r8
      integer_inc rax
      integer_add r12, rax
      to_string rax
      string_extend_links r10, rax
      string " │ "
      string_extend_links r10, rax

      ; Сброс цвета
      string 0x1b, "[0m"
      string_extend_links r10, rax

      list_get_link r11, r8
      string_extend_links r10, rax
      list_append_link rbx, rax

      string 10
      list_append_link rbx, rax

      integer_inc r8
      jmp .while

    .while_end:

    integer_inc rcx
    jmp @b
  @@:

  integer 3
  list_get_link rdx, rax
  integer_dec rax
  mov r13, rax

  integer 5
  list_get_link rdx, rax
  integer_sub rax, r13
  mov r14, rax

  ; Серый цвет
  string 0x1b, "[38;5;8m"
  mov r10, rax

  string " "
  mov r11, rax

  integer_copy r8
  integer_add r12, rax
  to_string rax
  string_length rax
  integer rax

  string_mul r11, rax
  string_extend_links r10, rax

  string "   │ "
  string_extend_links r10, rax

  ; Сброс цвета
  string 0x1b, "[0m"
  string_extend_links r10, rax

  string " "
  string_mul rax, r13
  string_extend_links r10, rax

  ; Пурпурный цвет
  string 0x1b, "[38;5;5m"
  string_extend_links r10, rax

  string "^"
  string_mul rax, r14
  string_extend_links r10, rax

  ; Сброс цвета
  string 0x1b, "[0m"
  string_extend_links r10, rax

  string 10
  string_extend_links r10, rax

  list_append_link rbx, rax

  string "Синтаксическая ошибка: "
  mov rcx, rax
  get_arg 1
  string_extend_links rcx, rax
  list_append_link rbx, rax

  string ""
  error rbx, rax

  ret

; @function dump_currect_position
; @description Выводит текущую позицию в коде для отладки
; @param file_name - имя файла
; @param code - исходный код
; @param start_line - начальная строка
; @param start_column - начальный столбец
; @param stop_line - конечная строка
; @param stop_column - конечный столбец
; @return Нет возвращаемого значения
; @example
;   dump_currect_position "main.ksk", code, 10, 5, 10, 15
_function dump_currect_position, rbx, rcx, rdx, r8
  list
  mov rbx, rax

  get_arg 0 ; Путь к файлу
  list_append rbx, rax

  get_arg 2 ; Начало:строка
  mov rdx, rax
  get_arg 4 ; Конец:строка
  mov r8, rax

  get_arg 1 ; Содержимое файла
  mov rcx, rax
  string 10
  split_links rcx, rax
  mov rcx, rax
  integer_copy rdx
  integer_dec rax
  list_slice_links rcx, rax, r8
  list_append rbx, rax

  list_append rbx, rdx
  get_arg 3 ; Начало:столбец
  list_append rbx, rax
  list_append rbx, r8
  get_arg 5 ; Конец:столбец
  list_append rbx, rax

  ret

; @function format_token
; @description Форматирует токен с информацией о позиции
; @param type - тип токена
; @param value - значение токена
; @param start_line - начальная строка
; @param start_column - начальный столбец
; @param stop_line - конечная строка
; @param stop_column - конечный столбец
; @return Отформатированный токен
; @example
;   format_token ЧИСЛО, "42", 1, 1, 1, 2
_function format_token, rbx, rcx
  dictionary
  mov rbx, rax

  get_arg 0
  dictionary_set rbx, [тип], rax
  get_arg 1
  dictionary_set rbx, [значение], rax

  list
  mov rcx, rax
  get_arg 2
  list_append_link rcx, rax
  get_arg 3
  list_append_link rcx, rax
  dictionary_set rbx, [начало], rcx

  list
  mov rcx, rax
  get_arg 4
  list_append_link rcx, rax
  get_arg 5
  list_append_link rcx, rax
  dictionary_set rbx, [конец], rax

  ret
