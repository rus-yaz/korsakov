section "get_file_size" executable

macro get_file_size filename {
  enter filename

  call f_get_file_size

  return
}

f_get_file_size:
  mov rbx, rsp
  add rbx, STAT_BUFFER_SIZE

  sys_stat rax,\      ; Указатель на имя файла
           rbx        ; Указатель на место хранения данных

  mov rax, [rbx + 8*6] ; Размер файла в байтах

  ret

section "open_file" executable

macro open_file filename, flags = O_RDONLY, mode = 444o {
  enter filename, flags, mode

  call f_open_file

  return
}

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

  create_block 8*4

  mem_mov [rax + 8*0], FILE_DESCRIPTOR ; Тип
  mem_mov [rax + 8*1], rbx             ; Имя файла
  mem_mov [rax + 8*2], rcx             ; Дескриптор
  mem_mov [rax + 8*3], rdx             ; Размер файла

  ret

section "close_file" executable

macro close_file file_descriptor {
  enter file_descriptor

  call f_close_file

  return
}

f_close_file:
  ; Проверка типа
  check_type rax, FILE_DESCRIPTOR, EXPECTED_FILE_DESCRIPTOR_TYPE_ERROR

  mov rbx, rax

  ; Закрытие файла
  sys_close [rax + 8*2] ; Дескриптор файла

  delete_block rbx

  ret

section "read_file" executable

macro read_file file_descriptor {
  enter file_descriptor

  call f_read_file

  return
}

f_read_file:
  ; Проверка типа
  check_type rax, FILE_DESCRIPTOR, EXPECTED_FILE_DESCRIPTOR_TYPE_ERROR

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

section "write_file" executable

macro write_file file_descriptor, string_addr {
  enter file_descriptor, string_addr

  call f_write_file

	leave
}

f_write_file:
  check_type rax, FILE_DESCRIPTOR, EXPECTED_FILE_DESCRIPTOR_TYPE_ERROR

	mov rax, [rax + 8*2]

  check_type rbx, STRING, EXPECTED_STRING_TYPE_ERROR

	mov rsi, rbx
	mov rdi, [rsi + 8*1] ; Длина

	mov rdx, rdi
	imul rdx, 2*8
	add rsi, rdx

	mov rdx, 0 ; Общее количество записанных символов
	.while1:
		cmp rdi, 0
		je .end1

    check_type rsi, INTEGER, EXPECTED_INTEGER_TYPE_ERROR

		add rsi, 8
		mov rbx, [rsi]

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

		sub rsi, 8*3
		add rdx, rcx

		dec rdi
		jmp .while1

	.end1:

	mov rcx, rsp
	mov rbx, rdx

	sys_write rax, rcx, rbx

	add rsp, rbx

	ret
