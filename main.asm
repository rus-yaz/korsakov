include "lib/korsakov.asm"

include "tokenizer.asm"
include "parser.asm"
include "compiler.asm"

section "data" writable
  заголовок db 'include "lib/korsakov.asm"', 10, 0

  сегмент_данных db "section 'data' writable", 0

  сегмент_кода db 10, "section 'start' executable", 10, "start:", 0

  конец_кода db "exit 0", 0

  файл_для_чтения db "привет, мир.корс", 0
  файл_для_записи db "привет, мир.asm", 0

  ИМЯ                db "показать", 0
  имя                rq 1
  ДВОЙНАЯ_КАВЫЧКА    db '"', 0
  двойная_кавычка    rq 1
  ПЕРЕНОС_СТРОКИ     db 10, 0
  перенос_строки     rq 1
  ОТКРЫВАЮЩАЯ_СКОБКА db "(", 0
  открывающая_скобка rq 1
  ЗАКРЫВАЮЩАЯ_СКОБКА db ")", 0
  закрывающая_скобка rq 1

  ТИП       db "тип", 0
  тип       rq 1
  ЗНАЧЕНИЕ  db "значение", 0
  значение  rq 1
  АРГУМЕНТЫ db "аргументы", 0
  аргументы rq 1

  код                rq 1
  токен              rq 1
  индекс             rq 1
  токены             rq 1
  символы            rq 1
  тип_токена         rq 1
  данные             rq 1

  ТИП_КОНЕЦ_ФАЙЛА        dq 0
  ТИП_ФУНКЦИЯ            dq 1
  ТИП_ОТКРЫВАЮЩАЯ_СКОБКА dq 2
  ТИП_ЗАКРЫВАЮЩАЯ_СКОБКА dq 3
  ТИП_СТРОКА             dq 4
  ТИП_ПЕРЕНОС_СТРОКИ     dq 5

  АСД              rq 1
  КОЛИЧЕСТВО_СТРОК rq 1
  префикс_строки   db "string_", 0
  суффикс_строки   db " db ", 0
  постфикс_строки  db ", 0", 0

  ПУСТАЯ_СТРОКА db "", 0
  пустая_строка rq 1

  INCORRECT_TOKEN_TYPE_ERROR db "Неверный токен: ", 0

section "start" executable
start:
  integer 0
  mov [КОЛИЧЕСТВО_СТРОК], rax

  buffer_to_string ПУСТАЯ_СТРОКА
  mov [пустая_строка], rax

  buffer_to_string ИМЯ
  mov [имя], rax
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
  buffer_to_string АРГУМЕНТЫ
  mov [аргументы], rax

  tokenizer файл_для_чтения
  parser rax
  compiler rax

  mov rbx, rax

  list 0
  mov rcx, rax

  buffer_to_string заголовок
  list_append rcx, rax

  buffer_to_string сегмент_данных
  list_append rcx, rax

  list_append rcx, [данные]

  buffer_to_string сегмент_кода
  list_append rcx, rax

  list_append rcx, rbx

  buffer_to_string конец_кода
  list_append rcx, rax

  join rcx, 10
  mov [код], rax

  open_file файл_для_записи, O_WRONLY + O_CREAT + O_TRUNC, 644o
  write_file rax, [код]
  close_file rax

  exit 0
