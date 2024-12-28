section "data" writable
  ПУСТАЯ_СТРОКА db "", 0
  пустая_строка rq 1

  ПОКАЗАТЬ           db "показать", 0
  показать           rq 1
  ДВОЙНАЯ_КАВЫЧКА    db '"', 0
  двойная_кавычка    rq 1
  ПЕРЕНОС_СТРОКИ     db 10, 0
  перенос_строки     rq 1
  ОТКРЫВАЮЩАЯ_СКОБКА db "(", 0
  открывающая_скобка rq 1
  ЗАКРЫВАЮЩАЯ_СКОБКА db ")", 0
  закрывающая_скобка rq 1

  ТИП      db "тип", 0
  тип      rq 1
  ЗНАЧЕНИЕ db "значение", 0
  значение rq 1

  ТОКЕН_КОНЕЦ_ФАЙЛА        dq 0
  ТОКЕН_ФУНКЦИЯ            dq 1
  ТОКЕН_ОТКРЫВАЮЩАЯ_СКОБКА dq 2
  ТОКЕН_ЗАКРЫВАЮЩАЯ_СКОБКА dq 3
  ТОКЕН_СТРОКА             dq 4
  ТОКЕН_ПЕРЕНОС_СТРОКИ     dq 5

  код                rq 1
  токен              rq 1
  индекс             rq 1
  токены             rq 1
  символы            rq 1
  тип_токена         rq 1

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

  buffer_to_string ПУСТАЯ_СТРОКА
  mov [пустая_строка], rax

  buffer_to_string ПОКАЗАТЬ
  mov [показать], rax
  buffer_to_string ОТКРЫВАЮЩАЯ_СКОБКА
  mov [открывающая_скобка], rax
  buffer_to_string ЗАКРЫВАЮЩАЯ_СКОБКА
  mov [закрывающая_скобка], rax
  buffer_to_string ДВОЙНАЯ_КАВЫЧКА
  mov [двойная_кавычка], rax
  buffer_to_string ПЕРЕНОС_СТРОКИ
  mov [перенос_строки], rax

  buffer_to_string ТИП
  mov [тип], rax
  buffer_to_string ЗНАЧЕНИЕ
  mov [значение], rax

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

      mov [тип_токена], ТОКЕН_СТРОКА
      jmp .add_token

    .skip_string:

    is_equal [токен], [показать]
    mov [тип_токена], ТОКЕН_ФУНКЦИЯ
    cmp rax, 1
    je .add_token

    is_equal [токен], [открывающая_скобка]
    mov [тип_токена], ТОКЕН_ОТКРЫВАЮЩАЯ_СКОБКА
    cmp rax, 1
    je .add_token

    is_equal [токен], [закрывающая_скобка]
    mov [тип_токена], ТОКЕН_ЗАКРЫВАЮЩАЯ_СКОБКА
    cmp rax, 1
    je .add_token

    is_equal [токен], [перенос_строки]
    mov [тип_токена], ТОКЕН_ПЕРЕНОС_СТРОКИ
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
  integer [ТОКЕН_КОНЕЦ_ФАЙЛА]
  list_append rcx, rax
  list_append rax, [пустая_строка]

  dictionary rbx, rax
  list_append [токены], rax

  ret
