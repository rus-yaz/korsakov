section "keywords" writable
  ПУСТАЯ_СТРОКА      db "", 0

  КОД                db 'показать("привет, мир!")', 10, 0
  ПОКАЗАТЬ           db "показать", 0
  ОТКРЫВАЮЩАЯ_СКОБКА db "(", 0
  ЗАКРЫВАЮЩАЯ_СКОБКА db ")", 0
  ДВОЙНАЯ_КАВЫЧКА    db '"', 0
  код                rq 1
  показать           rq 1
  открывающая_скобка rq 1
  закрывающая_скобка rq 1
  двойная_кавычка    rq 1

  символы            rq 1
  токен              rq 1
  токены             rq 1
  индекс             rq 1

section "tokenizer" executable

macro tokenizer filename {
  enter filename

  call f_tokenizer

  leave
}

f_tokenizer:
  open_file rax
  push rax

  read_file rax
  mov [код], rax

  pop rax
  close_file rax

  ;; код = "показать(\"привет, мир!\")"
  ;buffer_to_string КОД
  ;mov [код], rax

  buffer_to_string ПОКАЗАТЬ
  mov [показать], rax
  buffer_to_string ОТКРЫВАЮЩАЯ_СКОБКА
  mov [открывающая_скобка], rax
  buffer_to_string ЗАКРЫВАЮЩАЯ_СКОБКА
  mov [закрывающая_скобка], rax
  buffer_to_string ДВОЙНАЯ_КАВЫЧКА
  mov [двойная_кавычка], rax

  ; символы = Список(код)
  string_to_list [код]
  mov [символы], rax

  ; токен = ""
  buffer_to_string ПУСТАЯ_СТРОКА
  mov [токен], rax

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

      jmp .add_token

    .skip_string:

    is_equal [токен], [показать]
    cmp rax, 1
    je .add_token

    is_equal [токен], [открывающая_скобка]
    cmp rax, 1
    je .add_token

    is_equal [токен], [закрывающая_скобка]
    cmp rax, 1
    je .add_token

    jmp .continue

    .add_token:
      list_append [токены], [токен]

      buffer_to_string ПУСТАЯ_СТРОКА
      mov [токен], rax

    .continue:

    ; индекс++
    integer_inc [индекс]

    list_length [символы]
    integer rax
    is_equal rax, [индекс]

    cmp rax, 1
    jne .while

  join [токены]
  print rax

  exit 0
