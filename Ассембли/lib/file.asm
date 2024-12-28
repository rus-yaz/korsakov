f_get_file_size:
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
  ; Сохранение указателя на имя файла
  push rax

  ; Открытие файла
  sys_open rax,\      ; Указатель на имя файла
           rbx,\      ; Тип доступа файла
           rcx        ; Первоначальное разрешение на доступ к файлу

  pop rbx

  ; Проверка открытия файла
  cmp rax, 0
  check_error jle, OPENING_FILE_ERROR

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
  ; Проверка типа
  check_type rax, FILE

  mov rbx, rax

  ; Закрытие файла
  sys_close [rax + 8*2] ; Дескриптор файла

  delete_block rbx

  ret

f_read_file:
  ; Проверка типа
  check_type rax, FILE

  ; Сохранение указателя на файловый дескриптор
  mov rbx, rax

  ; Получение размера файла
  mov rax, [rax + 8*3]

  ; Сохранение длины строки
  mov rcx, rax

  add rax, BINARY_HEADER*8 ; Учёт заголовка бинарной последовательности
  create_block rax

  ; Сохранение указателя на блок
  push rax

  mem_mov [rax + 8*0], BINARY ; Тип
  mem_mov [rax + 8*1], rcx    ; Длина

  add rax, BINARY_HEADER*8 ; Сдвиг указателя до тела строки

  ; RAX — указатель на созданный блок
  ; RBX — указатель на блок файлового дескриптора

  ; Чтение файла
  sys_read [rbx + 8*2],\ ; Файловый дескриптор
           rax,\         ; Блок для хранения данных
           [rbx + 8*3]   ; Размер читаемого файла

  ; Проверка, что файл успешно прочитан
  cmp rax, 0
  jge .read
    close_file rbx
    exit -1, FILE_WAS_NOT_READ_ERROR

  .read:

  pop rax
  binary_to_string rax

  ret

f_write_file:
  check_type rax, FILE

  ; Сохранение файлового дескриптора
  mov rax, [rax + 8*2]
  mov r15, rax

  check_type rbx, STRING
  mov rsi, rbx

  ; Нахождение длины строки (RDI)
  mov rdi, rax
  string_length rbx

  xchg rdi, rax
  dec rdi

  mov rdx, 0 ; Счётчик считанных байт
  .while1:

    cmp rdi, 0
    jl .end1

    integer rdi
    string_get rsi, rax

    mov rax, [rax + 8*1]
    mov rbx, [rax + (2 + INTEGER_HEADER) * 8]
    mov rcx, 0

    .while2:

      cmp rcx, 4
      je .end2

      cmp rbx, 0
      je .end2

      dec rsp
      mov [rsp], bl
      shr rbx, 8

      inc rcx
      jmp .while2

    .end2:

    add rdx, rcx

    dec rdi
    jmp .while1

  .end1:

  mov rcx, rsp
  mov rbx, rdx

  sys_write r15, rcx, rbx

  add rsp, rbx

  ret
