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

macro open_file filename, flags = O_RDONLY, mode = 644 {
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
  mov rbx, [rax]
  cmp rbx, FILE_DESCRIPTOR
  check_error jne, EXPECTED_FILE_DESCRIPTOR_TYPE_ERROR

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
  mov rbx, [rax]
  cmp rbx, FILE_DESCRIPTOR
  check_error jne, EXPECTED_FILE_DESCRIPTOR_TYPE_ERROR

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

  mem_mov [rax + 8*0], BINARY
  mem_mov [rax + 8*1], rcx

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

  mov rbx, rax ; Количество байт в строке

  ; Взятие и сохранение указателя на блок
  pop rax
  push rax
  add rax, STRING_HEADER*8 ; Сдвиг указателя до тела строки

  mov rcx, 0   ; Счётчик пройденных бит
  mov rdi, 0   ; Количество символов

  .while_string_length:
    cmp rcx, rbx
    jge .end_string_length

    ; Буфер
    mov rdx, [rax + rcx]
    movzx rdx, dl

    cmp rdx, 248
    check_error jge, UNEXPECTED_BIT_SEQUENCE_ERROR

    cmp rdx, 128
    jl .continue_string_length
    cmp rdx, 192
    jge .continue_string_length

    jmp .do_string_length

  .continue_string_length:
    inc rdi

  .do_string_length:
    inc rcx
    jmp .while_string_length

  .end_string_length:

	;dec rdi

  pop rsi
  add rsi, BINARY_HEADER*8 ; Сдвиг указателя до тела байтовой последовательности

  ; RDI — количество символов в строке
  ; RSI — Указатель на тело байтовой последовательности

  ; Выделение памяти под строку
  mov rax, rdi                       ; Количество символов в строке
  imul rax, 8 * (INTEGER_HEADER + 1) ; Нахождение необходимой для всех символов памяти
  add rax, STRING_HEADER*8           ; Учёт заголовка строки

  create_block rax
  push rax ; Сохранение указателя на строку

  mem_mov [rax + 8*0], STRING ; Тип строки
  mem_mov [rax + 8*1], rdi    ; Длина строки

  add rax, STRING_HEADER*8 ; Сдвиг указателя до тела строки

  .while_chars:
    cmp rdi, 0
    je .end_chars

    mov r8, 0 ; Размер символа

    ; Буфер
    mov rdx, [rsi]
    movzx rdx, dl

    ; Нахождение символов

    ; Символ, занимающий 1 байт (ASCII)
    inc r8
    cmp rdx, 128
    jl .continue_chars

    ; Часть другого символа, которого не должно быть в этом месте
    cmp rdx, 192
    check_error jl, UNEXPECTED_BIT_SEQUENCE_ERROR

    ; Начало символа, занимающего 2 байта
    inc r8
    cmp rdx, 224
    jl .continue_chars

    ; Начало символа, занимающего 3 байта
    inc r8
    cmp rdx, 240
    jl .continue_chars

    ; Начало символа, занимающего 4 байта
    inc r8

    ; Маска первого байта 4-х байтового символа — 1110xxxx₂ (248₁₀)
    cmp rdx, 248
    check_error jge, UNEXPECTED_BIT_SEQUENCE_ERROR

  .continue_chars:
    ; Запись символов
    mem_mov [rax + 8*0], INTEGER ; Тип

    ; Сдвиг последовательности до состояния символа
    .while:
      dec r8

      cmp r8, 0
      je .end

      shl rdx, 8
      inc rsi
      mov rbx, [rsi]
      mov dl, bl
      jmp .while

    .end:

    mem_mov [rax + 8*1], rdx
    add rax, (INTEGER_HEADER + 1) * 8
    inc rsi

    dec rdi
    jmp .while_chars

  .end_chars:

  ; Взятие указателя на блок
  pop rax

  ret

section "write_file" executable

macro write_file file_descriptor, string_addr {
  enter file_descriptor, string_addr

  call f_write_file

	leave
}

f_write_file:
	mov rcx, [rax]
	cmp rcx, FILE_DESCRIPTOR
	check_error jne, EXPECTED_FILE_DESCRIPTOR_TYPE_ERROR

	mov rax, [rax + 8*2]

	mov rcx, [rbx]
	cmp rcx, STRING
	check_error jne, EXPECTED_STRING_TYPE_ERROR

	mov rsi, rbx
	mov rdi, [rsi + 8*1] ; Длина

	mov rdx, rdi
	imul rdx, 2*8
	add rsi, rdx

	mov rdx, 0 ; Общее количество записанных символов
	.while1:

		cmp rdi, 0
		je .end1

		mov rbx, [rsi]
		cmp rbx, INTEGER
		check_error jne, EXPECTED_INTEGER_TYPE_ERROR

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
