section "tokenizer" executable

macro tokenizer filename {
  enter filename

  call f_tokenizer

  return
}

f_tokenizer:
  open_file rax
  mov rbx, rax

  read_file rax
  mov [код], rax

  close_file rbx

  ; символы = Список(код)
  string_to_list [код]
  mov [символы], rax

  ; токен = ""
  string_copy [пустая_строка]
  mem_mov [токен], rax

  ; токены = ()
  list 0
  mov [токены], rax

  ; индекс = 0
  integer 0
  mov [индекс], rax

  .while:
    ; токен += символы.индекс
    list_get [символы], [индекс]
    string_append [токен], rax

    is_equal [токен], [двойная_кавычка]
    cmp rax, 1
    jne .skip_string
      .while_string:
        integer_inc [индекс]
        list_get [символы], [индекс]

        push rax
        string_append [токен], rax
        pop rax

        is_equal rax, [двойная_кавычка]
        cmp rax, 1
        jne .while_string

      mov [тип_токена], ТИП_СТРОКА
      jmp .add_token

    .skip_string:

    is_equal [токен], [имя]
    mov [тип_токена], ТИП_ФУНКЦИЯ
    cmp rax, 1
    je .add_token

    is_equal [токен], [открывающая_скобка]
    mov [тип_токена], ТИП_ОТКРЫВАЮЩАЯ_СКОБКА
    cmp rax, 1
    je .add_token

    is_equal [токен], [закрывающая_скобка]
    mov [тип_токена], ТИП_ЗАКРЫВАЮЩАЯ_СКОБКА
    cmp rax, 1
    je .add_token

    jmp .continue

    .add_token:
      list 0
      list_append rax, [тип]
      list_append rax, [значение]
      mov rbx, rax

      list 0
      mov rcx, rax
      mov rax, [тип_токена]
      integer [rax]
      list_append rcx, rax
      list_append rax, [токен]

      dictionary rbx, rax
      list_append [токены], rax

      string_copy [пустая_строка]
      mov [токен], rax

    .continue:

    ; индекс++
    integer_inc [индекс]

    list_length [символы]
    integer rax
    is_equal rax, [индекс]

    cmp rax, 1
    jne .while

  list 0
  list_append rax, [тип]
  list_append rax, [значение]
  mov rbx, rax

  list 0
  mov rcx, rax
  integer [ТИП_КОНЕЦ_ФАЙЛА]
  list_append rcx, rax
  list_append rax, [пустая_строка]

  dictionary rbx, rax
  list_append [токены], rax

  ret
