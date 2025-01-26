section "tokenizer" executable

macro tokenizer filename* {
  enter filename

  call f_tokenizer

  return
}

f_tokenizer:
  get_arg 0
  open_file rax
  mov rbx, rax

  read_file rax
  mov [код], rax

  close_file rbx

  ; символы = Список(код)
  string_to_list [код]
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
    list_get [символы], [индекс]
    string_append [токен], rax

    is_digit [токен]
    cmp rax, 1
    jne .not_digit

      .while_digit:
        integer 1
        integer_add [индекс], rax

        list_get [символы], rax
        mov rbx, rax

        is_digit rbx
        cmp rax, 1
        jne .end_while_digit

        string_append [токен], rbx
        integer_inc [индекс]
        jmp .while_digit

      .end_while_digit:

      integer_copy [ТИП_ЦЕЛОЕ_ЧИСЛО]
      mov [тип_токена], rax

      jmp .add_token

    .not_digit:

    is_alpha [токен]
    cmp rax, 1
    je .while_identifier
    string "_"
    is_equal [токен], rax
    cmp rax, 1
    jne .not_identifier

      .while_identifier:
        integer 1
        integer_add [индекс], rax

        list_get [символы], rax
        mov rbx, rax

        is_alpha rbx
        cmp rax, 1
        je .continue_identifier

        string "_"
        is_equal [токен], rax
        cmp rax, 1
        jne .end_while_identifier

        .continue_identifier:

        string_append [токен], rbx
        integer_inc [индекс]
        jmp .while_identifier

      .end_while_identifier:

      list_include [ключевые_слова], [токен]
      cmp rax, 1
      je .keyword
        integer_copy [ТИП_ИДЕНТИФИКАТОР]
        mov [тип_токена], rax

        jmp .add_token
      .keyword:

      integer_copy [ТИП_КЛЮЧЕВОЕ_СЛОВО]
      mov [тип_токена], rax

      jmp .add_token

    .not_identifier:

    is_equal [токен], [ДВОЙНАЯ_КАВЫЧКА]
    cmp rax, 1
    jne .not_string
      .while_string:
        integer_inc [индекс]
        list_get [символы], [индекс]

        push rax
        string_append [токен], rax
        pop rax

        is_equal rax, [ДВОЙНАЯ_КАВЫЧКА]
        cmp rax, 1
        jne .while_string

      integer_copy [ТИП_СТРОКА]
      mov [тип_токена], rax

      jmp .add_token

    .not_string:

    string "%"
    is_equal [токен], rax
    cmp rax, 1
    jne .not_list_paren

      integer_inc [индекс]
      list_get [символы], [индекс]
      string_append [токен], rax

      integer_copy [ТИП_ОТКРЫВАЮЩАЯ_СКОБКА_СПИСКА]
      mov [тип_токена], rax

      string "%("
      is_equal [токен], rax
      cmp rax, 1
      je .add_token

      buffer_to_string UNEXPECTED_TOKEN_ERROR
      print <rax, [токен]>
      exit -1

    .not_list_paren:

    string "+"
    is_equal [токен], rax
    cmp rax, 1
    jne .not_plus

      integer_copy [ТИП_СЛОЖЕНИЕ]
      mov [тип_токена], rax

      integer_copy [индекс]
      integer_inc rax
      list_get [символы], rax
      mov rcx, rax

      string "+"
      is_equal rcx, rax
      cmp rax, 1
      jne .add_token

      null
      mov rcx, rax
      boolean 0
      mov rdx, rax

      list_length [токены]
      cmp rax, 1
      jne .non_pre_increment

      integer -1
      list_get [токены], rax
      token_check_type rax, [ТИП_ИДЕНТИФИКАТОР]
      cmp rax, 1
      jne .non_pre_increment

        list_pop [токены]
        mov rcx, rax
        boolean 1
        mov rdx, rax

      .non_pre_increment:

      dictionary
      mov rbx, rax
      integer_copy [ТИП_ИНКРЕМЕНТАЦИЯ]
      dictionary_set rbx, [тип], rax
      dictionary_set rbx, [значение], rdx

      list_append [токены], rax

      null
      is_equal rcx, rax
      cmp rax, 1
      je .continue

      list_append [токены], rcx
      jmp .continue

    .not_plus:

    string "-"
    is_equal [токен], rax
    cmp rax, 1
    jne .not_minus

      integer_copy [ТИП_ВЫЧИТАНИЕ]
      mov [тип_токена], rax

      integer_copy [индекс]
      integer_inc rax
      list_get [символы], rax
      mov rcx, rax

      string "-"
      is_equal rcx, rax
      cmp rax, 1
      jne .add_token

      integer_inc [индекс]
      list_get [символы], rax
      string_append [токен], rax

      integer_copy [индекс]
      integer_inc rax
      list_get [символы], rax
      string_append rax, [токен]
      mov rbx, rax

      string "---"
      is_equal rbx, rax
      cmp rax, 1
      jne .non_construction_end

        integer_inc [индекс]
        list_get [символы], [индекс]
        string_append [токен], rax

        integer_copy [ТИП_КОНЕЦ_КОНСТРУКЦИИ]
        mov [тип_токена], rax
        jmp .add_token

      .non_construction_end:

      list_length [токены]
      cmp rax, 1
      jne .non_pre_decrement

      mov rcx, 0
      mov rdx, 0

      integer -1
      list_get [токены], rax
      token_check_type rax, [ТИП_ИДЕНТИФИКАТОР]
      cmp rax, 1
      jne .non_pre_decrement

        list_pop [токены]
        mov rcx, rax
        mov rdx, 1

      .non_pre_decrement:

      dictionary
      mov rbx, rax
      integer_copy [ТИП_ДЕКРЕМЕНТАЦИЯ]
      dictionary_set rbx, [тип], rax
      dictionary_set rbx, [значение], rdx

      list_append [токены], rax

      cmp rcx, 0
      je .continue

      list_append [токены], rcx
      jmp .continue

    .not_minus:

    integer -1
    dictionary_get [типы], [токен], rax
    mov [тип_токена], rax

    integer -1
    is_equal rax, [тип_токена]
    cmp rax, 1
    jne .add_token

    buffer_to_string UNEXPECTED_TOKEN_ERROR
    print <rax, [токен]>
    exit -1

    .add_token:
      .space_while:
        is_equal [токен], [ПРОБЕЛ]
        cmp rax, 1
        jne .space_end_while

        integer 1
        integer_add [индекс], rax
        mov rbx, rax

        list_length [символы]
        integer rax
        is_equal rbx, rax
        cmp rax, 1
        je .write_token

        list_get [символы], rbx
        is_equal rax, [ПРОБЕЛ]
        cmp rax, 1
        jne .continue

        integer_inc [индекс]
        jmp .space_while

      .space_end_while:

      .newline_while:
        is_equal [токен], [ПЕРЕНОС_СТРОКИ]
        cmp rax, 1
        jne .newline_end_while

        integer 1
        integer_add [индекс], rax
        mov rbx, rax

        list_length [символы]
        integer rax
        is_equal rbx, rax
        cmp rax, 1
        je .write_token

        list_get [символы], rbx
        is_equal rax, [ПЕРЕНОС_СТРОКИ]
        cmp rax, 1
        jne .newline_end_while

        integer_inc [индекс]
        jmp .newline_while

      .newline_end_while:

      .write_token:

      dictionary
      dictionary_set rax, [тип], [тип_токена]
      dictionary_set rax, [значение], [токен]
      list_append [токены], rax

    .continue:

    string ""
    mov [токен], rax

    ; индекс++
    integer_inc [индекс]

    list_length [символы]
    integer rax
    is_equal rax, [индекс]

    cmp rax, 1
    jne .while

  dictionary
  mov rbx, rax
  integer_copy [ТИП_КОНЕЦ_ФАЙЛА]
  dictionary_set rbx, [тип], rax
  string ""
  dictionary_set rbx, [значение], rax
  list_append [токены], rax

  ret
