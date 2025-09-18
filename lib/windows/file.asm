; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

; @function _get_file_size
; @description Возвращает размер файла в байтах
; @param handle - файловый дескриптор
; @return Размер файла в байтах
; @example
;   sys_open filename, flags, mode
;   _get_file_size rax  ; возвращает размер файла
_function _get_file_size
  get_arg 0
  invoke GetFileSize, rax, 0

  ret

; @function open_file
; @description Открывает файл с указанными флагами и режимом доступа
; @param filename - имя файла для открытия
; @param flags=O_RDONLY - флаги открытия файла
; @param mode=OPEN_EXISTING - режим доступа к файлу
; @return Объект файла
; @example
;   string "test.txt"
;   open_file rax  ; открывает файл для чтения
_function open_file, rbx, rcx, rdx, r12, r13
  get_arg 2
  mov rcx, rax
  get_arg 1
  mov rbx, rax
  get_arg 0

  check_type rax, STRING

  push rax

  string_to_binary rax
  add rax, BINARY_HEADER*8
  utf8_to_utf16 rax

  mov r12, rbx
  mov r13, rcx
  sys_open rax,\ ; Указатель на имя файла
           r12,\ ; Тип доступа файла
           r13   ; Первоначальное разрешение на доступ к файлу

  pop rbx

  ; Проверка открытия файла
  cmp rax, INVALID_HANDLE_VALUE
  jne @f
    list
    mov rcx, rax
    string "Файл «"
    list_append_link rcx, rax
    list_append_link rcx, rbx
    string "» не был открыт"
    list_append_link rcx, rax

    string ""
    error rcx, rax
    exit -1
  @@:

  mov rcx, rax

  _get_file_size rcx
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
_function close_file, rax, rbx, r11
  get_arg 0

  ; Проверка типа
  check_type rax, FILE

  mov rbx, rax

  ; Закрытие файла
  push r11
  sys_close [rax + 8*2] ; Дескриптор файла
  pop r11

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
_function read_file, rbx, rcx, r11
  get_arg 0
  mov rbx, rax

  check_type rbx, FILE

  ; Учёт нуля-терминатора
  mov r11, rsp

  dec rsp
  mov rax, 0
  mov [rsp], al

  ; Выделение места для записи
  sub rsp, [rbx + 8*3]
  mov rcx, rsp

  ; Чтение файла
  push r11
  sys_read [rbx + 8*2],\ ; Файловый дескриптор
           rcx,\         ; Блок для хранения данных
           [rbx + 8*3]   ; Размер читаемого файла
  pop r11

  ; Проверка, что файл успешно прочитан (проверка количества прочитанных байт)
  cmp rax, 0
  jne .read
    copy [rbx + 8*1]
    mov rcx, rax

    close_file rbx

    string "Файл «"
    mov rbx, rax
    string_extend_links rbx, rcx
    string "» не был прочитан"
    string_extend_links rbx, rax

    list
    list_append_link rax, rbx
    error rax
    exit -1
  .read:

  ; Приведение битовой последовательности к строке
  mov rax, rsp
  buffer_to_string rax

  ; Восстановление указателя на конец стека
  mov rsp, r11

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
_function write_file, rax, rbx, rcx, rdx, r11
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

  mov r11, [rbx + 8*2]
  sys_write r11, rcx, rbx

  ret

; @function get_absolute_path
; @description Преобразует относительный путь в абсолютный
; @param path - путь для преобразования в абсолютный
; @return Абсолютный путь
; @example
;   string "test.txt"
;   get_absolute_path rax  ; возвращает абсолютный путь к файлу
_function get_absolute_path, rbx, rdx, r8
  get_arg 0
  check_type rax, STRING
  mov rdx, rax

  string_to_binary rdx
  add rax, BINARY_HEADER*8
  mov rbx, rax

  mov r8, rsp
  sub rsp, MAX_PATH_LENGTH
  mov rax, rsp

  push rax
  invoke GetFullPathNameA,\
         rbx,\
         MAX_PATH_LENGTH,\
         rax,\
         0
  pop rax

  buffer_to_string rax
  mov rsp, r8

  ret
