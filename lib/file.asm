; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

f_get_file_size:
  get_arg 0
  push rax

  create_block STAT_BUFFER_SIZE
  mov rbx, rax

  pop rax
  push rbx

  sys_stat rax,\      ; Указатель на имя файла
           rbx        ; Указатель на место хранения данных

  mov rax, [rbx + 8*6] ; Размер файла в байтах

  pop rbx
  delete rbx

  ret

f_open_file:
  get_arg 2
  mov rcx, rax
  get_arg 1
  mov rbx, rax
  get_arg 0

  check_type rax, STRING
  string_to_binary rax
  add rax, BINARY_HEADER*8

  ; Сохранение указателя на имя файла
  push rax

  ; Открытие файла
  sys_open rax,\      ; Указатель на имя файла
           rbx,\      ; Тип доступа файла
           rcx        ; Первоначальное разрешение на доступ к файлу

  pop rbx

  ; Проверка открытия файла
  cmp rax, 0
  check_error jle, "Файл не был прочитан"

  ; Сохранение файлового дескриптора
  mov rcx, rax

  ; Получене размера файла
  get_file_size rbx

  ; Сохранение размера файла
  mov rdx, rax

  create_block FILE_HEADER*8

  mem_mov [rax + 8*0], FILE ; Тип
  mem_mov [rax + 8*1], rbx  ; Имя файла
  mem_mov [rax + 8*2], rcx  ; Дескриптор
  mem_mov [rax + 8*3], rdx  ; Размер файла

  ret

f_close_file:
  get_arg 0

  ; Проверка типа
  check_type rax, FILE

  mov rbx, rax

  ; Закрытие файла
  sys_close [rax + 8*2] ; Дескриптор файла

  delete_block rbx

  ret

f_read_file:
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

f_write_file:
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
