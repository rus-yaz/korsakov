section "data" writable
  FILE_SIZE       db "Размер файла:", 0
  STRING_SIZE     db "Размер строки:", 0
  STRING_CONTENT  db "Содержимое строки:", 0
  CHAR_BY_INDEX   db "Символ по индексу:", 0
  ITEM_BY_INDEX   db "Элемент по индексу:", 0

  имя_файла_для_чтения db "привет.корс", 0
  имя_файла_для_записи db "пока.корс", 0

  ; tests/heap
  тестовый_блок_1 rq 1
  тестовый_блок_2 rq 1
  тестовый_блок_3 rq 1

  ; tests/list
  список rq 1
  индекс rq 1

  ; tests/file
  размер_файла rq 1
  файл_для_чтения rq 1
  файл_для_записи rq 1
  содержимое_файла rq 1

  ; tests/string
  символ rq 1

  ; tests/exec
  ls      db "/bin/ls", 0
  ls_args dq ls, 0

  echo      db "/bin/echo", 0
  echo_arg1 db "Hello", 0
  echo_args dq echo, echo_arg1, 0

  lang db "LANG=en_US.UTF-8", 0
  envp dq lang, 0

  temp_buffer_1 db "Проверка 123", 0
  temp_buffer_2 db "Проверка 321", 0

  ; tests/functions
  число_1 rq 1
  число_2 rq 1

  тестовый_текст_1 rq 1
  тестовый_текст_2 rq 1

  список_1 rq 1
  список_2 rq 1
