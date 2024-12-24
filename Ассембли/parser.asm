section "keywords" writable
  ПОКАЗАТЬ           db "показать", 0
  ОТКРЫВАЮЩАЯ_СКОБКА db "(", 0
  ЗАКРЫВАЮЩАЯ_СКОБКА db ")", 0
  ДВОЙНАЯ_КАВЫЧКА    db '"', 0
  КОД                db 'показать("привет, мир!")', 10, 0
  ПУСТАЯ_СТРОКА      db "", 0

  показать           rq 1
  открывающая_скобка rq 1
  закрывающая_скобка rq 1
  двойная_кавычка    rq 1
  код                rq 1
  символы            rq 1
  токен              rq 1
  индекс             rq 1

section "parser" executable

macro parser filename {
  enter filename

  call f_parser

  leave
}

f_parser:
  ;open_file rax
  ;push rax
  ;
  ;read_file rax
  ;mov [код], rax
  ;
  ;pop rax
  ;close_file rax

  ; код = "показать(\"привет, мир!\")"
  buffer_to_string КОД
  mov [код], rax

  ; символы = Список(код)
  string_to_list [код]
  mov [символы], rax

  ; токен = ""
  buffer_to_string ПУСТАЯ_СТРОКА
  mov [токен], rax

  ; индекс = 0
  integer 0
  mov [индекс], rax

  .while:
    ; токен += символы.индекс
    list_get [символы], [индекс]
    string_add [токен], rax

    delete_block [токен]
    mov [токен], rax

    ; индекс++
    integer_inc [индекс]

    list_length [символы]
    integer rax
    is_equal rax, [индекс]

    cmp rax, 1
    jne .while

  print [токен]

  exit 0
