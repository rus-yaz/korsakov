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
  add rax, BINARY_HEADER*8

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
  check_type rax, BINARY

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
  create_block STRING_HEADER*8
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

    mem_mov [rax + 8*0], rbx ; Указатель на предыдущий элемент в текущем блоке
    mem_mov [rbx + 8*1], rax ; Указатель на текущий элемент в следующем блоке

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

section "string_length" executable

macro string_length string {
  enter string

  call f_string_length

  return
}

f_string_length:
  check_type rax, STRING

  mov rax, [rax + 8*2]

  ret

section "string_copy" executable

macro string_copy string {
  enter string

  call f_string_copy

  return
}

f_string_copy:
  check_type rax, STRING

  mov rbx, rax
  string_length rax
  mov rdx, rax

  create_block STRING_HEADER*8
  push rax

  mem_mov [rax + 8*0], STRING
  mem_mov [rax + 8*1], 0
  mem_mov [rax + 8*2], [rbx + 8*2]

  ; RAX — создаваемая строка
  ; RBX — копируемая строка

  .while:
    cmp rdx, 0
    je .end_while

    dec rdx
    mov rcx, rax

    create_block (2 + INTEGER_SIZE) * 8
    mem_mov rbx, [rbx + 8*1]

    mem_mov [rcx + 8*1], rax
    mem_mov [rax + 8*0], rcx

    mem_mov [rax + 8*1], 0
    mem_mov [rax + 8*2], INTEGER
    mem_mov [rax + 8*3], [rbx + 8*3]

    jmp .while
  .end_while:

  pop rax

  ret

section "string_append" executable

macro string_append string_1, string_2 {
  enter string_1, string_2

  call f_string_append

  return
}

f_string_append:
  check_type rax, STRING
  check_type rbx, STRING

  mov rcx, rax

  string_copy rbx
  mov rbx, rax

  string_length rcx
  xchg rcx, rax

  push rax
  .while:
    cmp rcx, 0
    je .end_while

    mov rax, [rax + 8*1]
    dec rcx

    jmp .while
  .end_while:

  mov rcx, [rbx + 8*1] ; Сохранение указателя на первый элемент добавляемой строки

  mov rdx, rax
  string_length rbx

  xchg rax, rdx ; RDX — длина второй строки, RAX — указатель на конец первой
  delete_block rbx ; Удаление заголовка строки

  mem_mov [rcx + 8*0], rax ; Запись указателя на текущий блок в предыдущий
  mem_mov [rax + 8*1], rcx ; Запись указателя на предыдущий блок в текущий

  pop rax
  mov rcx, rax

  string_length rax
  xchg rcx, rax

  add rcx, rdx
  mem_mov [rax + 8*2], rcx

  ret

section "string_add" executable

macro string_add string_1, string_2 {
  enter string_1, string_2

  call f_string_add

  return
}

f_string_add:
  check_type rax, STRING
  check_type rbx, STRING

  string_copy rax
  string_append rax, rbx

  ret

section "string_get" executable

macro string_get string, index {
  enter string, index

  call f_string_get

  return
}

f_string_get:
  check_type rax, STRING
  check_type rbx, INTEGER

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
  check_error jge, INDEX_OUT_OF_STRING_ERROR
  cmp rbx, 0
  check_error jl, INDEX_OUT_OF_STRING_ERROR

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

  ; Размер блока — места под ссылки на предыдущий и предыдущий элементы + размер типа Целове число
  create_block (2 + INTEGER_SIZE) * 8
  mem_mov [rax + 8*0], rbx

  mem_mov [rbx + 8*1], rax
  mem_mov [rax + 8*1], 0

  mem_mov [rax + 8*2], INTEGER
  mem_mov [rax + 8*3], rcx

  mov rax, rbx

  ret
