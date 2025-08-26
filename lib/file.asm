; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

; @function get_file_stat_buffer
; @description Получает информацию о файле и возвращает буфер со статистикой
; @param filename - имя файла для получения информации
; @return Буфер со статистикой файла
; @example
;   string "test.txt"
;   get_file_stat_buffer rax  ; получает информацию о файле test.txt
_function get_file_stat_buffer, rbx, rcx
  get_arg 0
  mov rbx, rax

  check_type rbx, STRING

  string_to_binary rbx
  add rax, BINARY_HEADER*8
  mov rbx, rax

  create_block STAT_BUFFER_SIZE
  mov rcx, rax

  push rcx

  sys_stat rbx,\      ; Указатель на имя файла
           rcx        ; Указатель на место хранения данных

  pop rax

  ret

; @function get_file_size
; @description Возвращает размер файла в байтах
; @param filename - имя файла для получения размера
; @return Размер файла в байтах
; @example
;   string "test.txt"
;   get_file_size rax  ; возвращает размер файла test.txt
_function get_file_size, rbx
  get_arg 0
  mov rbx, rax

  check_type rbx, STRING

  get_file_stat_buffer rbx

  mov rax, [rax + 8*6] ; Размер файла в байтах

  ret

; @function open_file
; @description Открывает файл с указанными флагами и режимом доступа
; @param filename - имя файла для открытия
; @param flags=O_RDONLY - флаги открытия файла
; @param mode=444o - режим доступа к файлу
; @return Объект файла
; @example
;   string "test.txt"
;   open_file rax  ; открывает файл для чтения
_function open_file, rbx, rcx, rdx
  get_arg 2
  mov rcx, rax
  get_arg 1
  mov rbx, rax
  get_arg 0

  check_type rax, STRING

  push rax

  string_to_binary rax
  add rax, BINARY_HEADER*8

  sys_open rax,\      ; Указатель на имя файла
           rbx,\      ; Тип доступа файла
           rcx        ; Первоначальное разрешение на доступ к файлу

  pop rbx

  ; Проверка открытия файла
  cmp rax, 0
  jg .correct
    list
    mov rcx, rax
    string "Файл «"
    list_append_link rcx, rax
    list_append_link rcx, rbx
    string "» не был прочитан"
    list_append_link rcx, rax

    string ""
    error rcx, rax
    exit -1
  .correct:

  mov rcx, rax

  get_file_size rbx
  mov rdx, rax

  get_absolute_path rbx
  mov rbx, rax

  create_block FILE_HEADER*8

  mem_mov [rax + 8*0], FILE ; Тип
  mem_mov [rax + 8*1], rbx  ; Имя файла
  mem_mov [rax + 8*2], rcx  ; Дескриптор
  mem_mov [rax + 8*3], rdx  ; Размер файла

  ret

; @function close_file
; @description Закрывает файл и освобождает ресурсы
; @param file - объект файла для закрытия
; @example
;   string "test.txt"
;   open_file rax
;   close_file rax  ; закрывает файл
_function close_file, rax, rbx
  get_arg 0

  ; Проверка типа
  check_type rax, FILE

  mov rbx, rax

  ; Закрытие файла
  sys_close [rax + 8*2] ; Дескриптор файла

  delete_block rbx

  ret

; @function read_file
; @description Читает содержимое файла и возвращает его как строку
; @param file - объект файла для чтения
; @return Содержимое файла как строка
; @example
;   string "test.txt"
;   open_file rax
;   read_file rax  ; читает содержимое файла
_function read_file, rbx, rcx
  get_arg 0
  mov rbx, rax

  check_type rbx, FILE

  ; Учёт нуля-терминатора
  dec rsp
  mov rax, 0
  mov [rsp], al

  ; Выделение места для записи
  sub rsp, [rbx + 8*3]
  mov rcx, rsp

  ; Чтение файла
  sys_read [rbx + 8*2],\ ; Файловый дескриптор
           rcx,\         ; Блок для хранения данных
           [rbx + 8*3]   ; Размер читаемого файла

  ; Проверка, что файл успешно прочитан (проверка количества прочитанных байт)
  cmp rax, 0
  jge .read
    close_file rbx
    raw_string "Файл не был прочитан"
    error_raw rax
    exit -1

  .read:

  ; Приведение битовой последовательности к строке
  mov rax, rsp
  buffer_to_string rax

  ; Восстановление указателя на конец стека
  add rsp, [rbx + 8*3]
  inc rsp

  ret

; @function write_file
; @description Записывает строку в файл
; @param file - объект файла для записи
; @param string - строка для записи в файл
; @example
;   string "test.txt"
;   open_file rax
;   string "Hello, World!"
;   write_file rbx, rax  ; записывает строку в файл
_function write_file, rax, rbx, rcx, rdx
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, FILE
  check_type rcx, STRING

  string_to_binary rcx
  mov rdx, rax

  binary_length rdx
  dec rax

  mov rcx, rdx
  add rcx, 8*2

  sys_write [rbx + 8*2], rcx, rax

  ret

; @function get_absolute_path
; @description Преобразует относительный путь в абсолютный
; @param path - путь для преобразования в абсолютный
; @return Абсолютный путь
; @example
;   string "test.txt"
;   get_absolute_path rax  ; возвращает абсолютный путь к файлу
_function get_absolute_path, rbx, rcx, rdx, r8, r9
  get_arg 0
  copy rax
  mov rbx, rax

  check_type rbx, STRING

  getcwd
  mov rcx, rax

  integer 0
  string_get_link rbx, rax
  mov rdx, rax

  string "/"
  is_equal rax, rdx
  boolean_value rax
  cmp rax, 1
  jne .not_absolute

    integer 0
    string_pop_link rbx, rax

    string ""
    mov rcx, rax

  .not_absolute:

  string "/"
  split_links rcx, rax
  mov rcx, rax

  integer 0
  list_pop_link rcx, rax

  string "/"
  split_links rbx, rax
  mov rbx, rax

  mov rdx, 0

  list_length rbx
  mov r8, rax

  .while:
    cmp rdx, r8
    je .end_while

    integer rdx
    list_get_link rbx, rax
    mov r9, rax

    string_length r9
    cmp rax, 0
    je .next

    string "."
    is_equal rax, r9
    boolean_value rax
    cmp rax, 1
    je .next

    string ".."
    is_equal rax, r9
    boolean_value rax
    cmp rax, 1
    jne .add

      list_length rcx
      cmp rax, 0
      je @f
        list_pop_link rcx
      @@:

      jmp .next

    .add:

    list_append_link rcx, r9

    .next:

    inc rdx
    jmp .while
  .end_while:

  string "/"
  join_links rcx, rax
  mov rcx, rax

  string "/"
  string_extend_links rax, rcx

  ret
