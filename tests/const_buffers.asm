section "const_buffers" writable


  ; tests/print
  print.буфер  db "Привет, мир!", 0
  print.строка rq 1

  ; tests/list
  list.список rq 1
  list.индекс rq 1

  ; tests/file
  file.имя_файла_для_чтения db "привет.корс", 0
  file.имя_файла_для_записи db "пока.корс", 0

  ; tests/string
  string.буфер  db "Строка 123", 0

  string.строка rq 1
  string.индекс rq 1
  string.символ rq 1

  ; tests/exec
  exec.команда_1   db "/bin/ls", 0
  exec.аргументы_1 dq exec.команда_1, 0

  exec.команда_2   db "/bin/echo", 0
  exec.аргумент_2  db "Hello", 0
  exec.аргументы_2 dq exec.команда_2, exec.аргумент_2, 0

  exec.язык             db "LANG=en_US.UTF-8", 0
  exec.переменные_среды dq exec.язык, 0

  ; tests/functions
  functions.буфер_1 db "Проверка 123", 0
  functions.буфер_2 db "321 акреворП", 0

  functions.число_1 rq 1
  functions.число_2 rq 1

  functions.тестовый_текст_1 rq 1
  functions.тестовый_текст_2 rq 1

  functions.список_1 rq 1
  functions.список_2 rq 1
