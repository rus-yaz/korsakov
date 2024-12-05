section "buffer_to_binary" executable

macro buffer_to_binary buffer_addr {
  enter buffer_addr

  call f_buffer_to_binary

  return
}

f_buffer_to_binary:
  push rax ; Сохранение указателя на буфер
  buffer_length rax

  push rax          ; Сохранение длины буфера
  add rax, STRING_HEADER * 8

  create_block rax
  pop rcx          ; Количество блоков копирования

  mem_mov [rax + 8*0], BINARY
  mem_mov [rax + 8*1], rcx

  ; Приведение размера к числу, кратному 8
  push rax
  mov rax, rcx

  mov rbx, 8
  mov rdx, 0

  idiv rbx
  mov rcx, rdx

  cmp rcx, 0
  je .skip

    inc rax
  .skip:

  mov rcx, rax
  pop rax

  pop rsi      ; Источник копирования
  push rax

  add rax, BINARY_HEADER * 8
  mov rdi, rax ; Место назначения

  rep movsq    ; Копирование в аллоцированный блок
  pop rax

  ret

section "binary_to_string" executable

macro binary_to_string binary_addr {
  enter binary_addr

  call f_binary_to_string

  return
}

f_binary_to_string:
  check_type rax, BINARY, EXPECTED_BINARY_TYPE_ERROR

  mov rbx, [rax + 8*1]
  cmp rbx, 0
  jne .no_empty

    create_block STRING_HEADER*8
    mem_mov [rax + 8*0], STRING

    mem_mov [rax + 8*1], 0
    mem_mov [rax + 8*2], 0

    ret

  .no_empty:

  ; Взятие и сохранение указателя на блок
  add rax, BINARY_HEADER*8 ; Сдвиг указателя до тела строки
  push rax

  mov rcx, 0   ; Счётчик пройденных бит
  mov rdi, 0   ; Количество символов

  .while_string_length:
    ; Буфер
    mov rdx, [rax + rcx]
    movzx rdx, dl

    cmp rcx, rbx
    je .end_string_length

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

  pop rsi

  ; RDI — количество символов в строке
  ; RSI — Указатель на тело байтовой последовательности

  ; Выделение памяти под строку
  mov rax, rdi                       ; Количество символов в строке
  imul rax, 8 * (INTEGER_HEADER + 1) ; Нахождение необходимой для всех символов памяти
  add rax, STRING_HEADER*8           ; Учёт заголовка строки

  create_block rax
  push rax ; Сохранение указателя на строку

  mem_mov [rax + 8*0], STRING ; Тип строки
  mem_mov [rax + 8*1], 0      ; Место для указателя на первый элемент
  mem_mov [rax + 8*2], rdi    ; Длина строки

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
    inc r8 ; Начало символа, занимающего 4 байта

    ; Маска первого байта 4-х байтового символа — 1110xxxx₂ (248₁₀)
    cmp rdx, 248
    check_error jge, UNEXPECTED_BIT_SEQUENCE_ERROR

  .continue_chars:
    mov rbx, rax
    create_block (2 + INTEGER_SIZE) * 8

    mem_mov [rax + 8*0], rbx
    mem_mov [rbx + 8*1], rax

    mem_mov [rax + 8*1], 0
    mem_mov [rax + 8*2], INTEGER

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

    mem_mov [rax + 8*3], rdx

    inc rsi
    dec rdi

    jmp .while_chars
  .end_chars:

  ; Взятие указателя на блок
  pop rax
  ret

section "buffer_to_string" executable

macro buffer_to_string buffer_addr {
  enter buffer_addr

  call f_buffer_to_string

  return
}

f_buffer_to_string:
  buffer_to_binary rax
  push rax

  binary_to_string rax

  pop rbx
  delete_block rbx

  ret

section "string_add" executable

macro string_add string_1, string_2 {
  enter string_1, string_2

  call f_string_add

  return
}

f_string_add:
  check_type rax, STRING, EXPECTED_STRING_TYPE_ERROR
  check_type rbx, STRING, EXPECTED_STRING_TYPE_ERROR

  ; Сохранение в обратном порядке, потому что первым будет взят последний
  push rbx, rax

  ; Вычисление длины новой строки
  mov rcx, [rax + 8*1]
  add rcx, [rbx + 8*1]

  push rcx

  imul rcx, INTEGER_SIZE * 8
  add rcx, STRING_HEADER * 8

  create_block rcx
  pop rcx

  mem_mov [rax + 8*0], STRING
  mem_mov [rax + 8*1], rcx

  mov rdi, rax               ; Источник копирования
  add rdi, STRING_HEADER * 8

  repeat 2
    pop rsi              ; Место назначения
    mov rcx, [rsi + 8*1] ; Количество блоков для копирования

    imul rcx, 2
    add rsi, STRING_HEADER * 8

    rep movsq
  end repeat

  ret

section "string_length" executable

macro string_length string {
  enter string

  call f_string_length

  return
}

f_string_length:
  check_type rax, STRING, EXPECTED_STRING_TYPE_ERROR

  mov rax, [rax + 8*2]

  ret

section "string_get" executable

macro string_get string, index {
  enter string, index

  call f_string_get

  return
}

f_string_get:
  ; Проверка типа
  check_type rax, STRING, EXPECTED_LIST_TYPE_ERROR

  ; Запись длины списка
  mov rcx, rax
  string_length rax
  xchg rax, rcx

  ; Если индекс меньше нуля, то увеличить его на длину списка
  mov rbx, [rbx + 8*1]
  cmp rbx, 0
  jge .positive_index
    add rbx, rcx
  .positive_index:

  ; Проверка, входит ли индекс в список
  cmp rbx, rcx
  check_error jge, INDEX_OUT_OF_LIST_ERROR
  cmp rbx, 0
  check_error jl, INDEX_OUT_OF_LIST_ERROR

  inc rbx
  .while:
    mov rax, [rax + 8*1]
    dec rbx

    cmp rbx, 0
    jne .while

  mov rcx, [rax + 8*3]
  create_block STRING_HEADER*8

  mem_mov [rax + 8*0], STRING
  mem_mov [rax + 8*1], 0

  mem_mov [rax + 8*2], 1
  mov rbx, rax

  create_block INTEGER_SIZE*8
  mem_mov [rax + 8*0], rbx

  mem_mov [rbx + 8*1], rax
  mem_mov [rax + 8*1], 0

  mem_mov [rax + 8*2], INTEGER
  mem_mov [rax + 8*3], rcx

  mov rax, rbx

  ret

section "string_append" executable

macro string_append string, int {
  enter string, int

  call f_string_append

  return
}

f_string_append:
  check_type rax, STRING, EXPECTED_STRING_TYPE_ERROR

  push rax
  mov rcx, rax

  list_length rax
  xchg rcx, rax

  .while:
    mov rax, [rax + 8*1]
    dec rcx

    cmp rcx, 0
    jne .while

  mov rdx, rax
  check_type rcx, rbx, EXPECTED_INTEGER_TYPE_ERROR

  create_block (2 + INTEGER_SIZE) * 8

  mem_mov [rax + 8*0], rdx
  mem_mov [rdx + 8*1], rax

  mem_mov [rax + 8*1], 0
  add rax, 8*2

  mem_copy rbx, rax, INTEGER_SIZE

  pop rax
  mem_mov rbx, [rax + 8*2]

  inc rbx
  mem_mov [rax + 8*2], rbx

  ret

section "string_to_list" executable

macro string_to_list string {
  enter string

  call f_string_to_list

  return
}

f_string_to_list:
  ret
