f_buffer_to_binary:
  get_arg 0

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

f_binary_to_string:
  get_arg 0
  check_type rax, BINARY

  mov rbx, [rax + 8*1]
  cmp rbx, 0
  jne .no_empty

    collection
    mem_mov [rax], STRING

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
  ; RSI — указатель на тело байтовой последовательности

  collection rdi
  mem_mov [rax + 8*0], STRING
  mem_mov [rax + 8*1], rdi
  push rax

  mov rcx, [rax + 8*3]

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

    integer rdx
    mem_mov [rcx], rax
    add rcx, 8

    inc rsi
    dec rdi

    jmp .while_chars
  .end_chars:

  pop rax
  ret

f_buffer_to_string:
  get_arg 0

  buffer_to_binary rax
  mov rbx, rax

  binary_to_string rax
  delete_block rbx

  ret

f_string_to_binary:
  get_arg 0
  mov rbx, rax
  check_type rbx, STRING

  string_length rbx
  integer rax
  mov rcx, rax

  integer 0
  mov r8, rax

  mov r9, 0

  mov r15, rsp
  push 0

  .while:
    is_equal r8, rcx
    cmp rax, 1
    je .end_while

    string_get_link rbx, r8

    mov rax, [rax + 8*3]
    mov rax, [rax]
    mov rax, [rax + INTEGER_HEADER*8]

    bswap rax

    .integer_while:

      cmp rax, 0
      je .integer_end_while

      mov dl, al
      shr rax, 8

      cmp dl, 0
      je .integer_while

      mov [rsp], dl

      dec rsp
      inc r9

      jmp .integer_while

    .integer_end_while:

    integer_inc r8
    jmp .while

  .end_while:

  ; Приведение размера к числу, кратному 8
  mov rax, r9

  mov rbx, 8
  mov rdx, 0

  idiv rbx
  mov rcx, rdx

  cmp rcx, 0
  je .skip

    inc rax
  .skip:

  mov r11, rax
  add rax, BINARY_HEADER
  imul rax, 8

  create_block rax
  mem_mov [rax + 8*0], BINARY
  mem_mov [rax + 8*1], r9

  mov r12, rax
  add rax, BINARY_HEADER*8

  mov rbx, rsp
  add rbx, r9

  .copy_while:
    cmp r9, 0
    je .copy_end_while

    mov rcx, [rbx]
    mov [rax], cl

    dec rbx
    inc rax

    dec r9
    jmp .copy_while

  .copy_end_while:

  mov rax, r12
  mov rsp, r15

  ret

f_binary_length:
  get_arg 0
  check_type rax, BINARY

  mov rax, [rax + 8*1]
  ret

f_string_length:
  get_arg 0
  check_type rax, STRING

  collection_length rax

  ret

f_string_capacity:
  get_arg 0
  check_type rax, STRING

  collection_capacity rax

  ret

f_string_copy_links:
  get_arg 0
  mov rbx, rax

  check_type rbx, STRING
  collection_copy_links rbx

  ret

f_string_copy:
  get_arg 0
  mov rbx, rax

  check_type rbx, STRING
  collection_copy rbx

  ret

f_string_add_links:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, STRING
  check_type rcx, STRING

  collection_add_links rbx, rcx

  ret

f_string_add:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, STRING
  check_type rcx, STRING

  string_copy rbx
  mov rbx, rax
  string_copy rcx
  mov rcx, rax

  string_add_links rbx, rcx

  ret

f_string_append_links:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, STRING
  check_type rcx, STRING

  string_add_links rbx, rcx
  mov rdx, [rax + 8*3]

  mem_mov [rbx + 8*1], [rax + 8*1]
  mem_mov [rbx + 8*2], [rax + 8*2]

  delete_block [rbx + 8*3], rax
  mov [rbx + 8*3], rdx

  mov rax, rbx

  ret

f_string_append:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, STRING

  string_copy rcx
  string_append_links rbx, rax

  ret

f_string_get_link:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, STRING
  check_type rcx, INTEGER

  collection_get_link rbx, rcx
  mov rbx, rax

  collection
  mem_mov [rax + 8*0], STRING

  mem_mov rcx, [rax + 8*1]
  inc rcx
  mem_mov [rax + 8*1], rcx

  mem_mov rcx, [rax + 8*3]
  mem_mov [rcx], rbx

  ret

f_string_get:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, STRING
  check_type rcx, INTEGER

  string_get_link rbx, rcx
  string_copy rax

  ret

f_string_set_link:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  check_type rbx, STRING
  mov rdx, [rdx + 8*3]
  mov rdx, [rdx]
  collection_set_link rbx, rcx, rdx

  ret

f_string_set:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  check_type rbx, STRING
  string_set_link rbx, rcx, rdx

  ret

f_split:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  push 0, rcx
  mov rax, rsp
  buffer_to_string rax
  mov rcx, rax
  pop rax, rax

  list
  mov rdx, rax

  integer 0
  mov r8, rax

  string_length rbx
  integer rax
  mov r9, rax

  string ""
  mov r10, rax

  .while:
    is_equal r8, r9
    cmp rax, 1
    je .end_while

    string_get rbx, r8
    mov r11, rax

    is_equal r11, rcx
    cmp rax, 1
    je .split

      string_append r10, r11

      jmp .continue

    .split:
      list_append rdx, r10

      string ""
      mov r10, rax

    .continue:

    integer_inc r8
    jmp .while

  .end_while:
  list_append rdx, r10

  mov rax, rdx

  ret

f_join:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  push 0, rcx
  mov rax, rsp
  buffer_to_string rax
  mov rcx, rax
  pop rax, rax

  string ""
  mov rdx, rax

  integer 0
  mov r8, rax

  list_length rbx
  integer rax
  mov r9, rax

  .while:

    is_equal r8, r9
    cmp rax, 1
    je .end_while

    list_get rbx, r8
    check_type rax, STRING
    string_append rdx, rax

    integer_inc r8

    is_equal r8, r9
    cmp rax, 1
    je .end_while

    string_append rdx, rcx

    jmp .while

  .end_while:

  mov rax, rdx

  ret

f_is_alpha:
  get_arg 0
  check_type rax, STRING
  mov rbx, rax

  string_length rax
  integer rax
  mov rcx, rax

  integer 0
  mov rdx, rax

  .while:
    is_equal rcx, rdx
    cmp rax, 1
    je .end_while

    string_get rbx, rdx

    mov rax, [rbx + 8*3]
    mov rax, [rax]
    mov rax, [rax + INTEGER_HEADER*8]

    cmp rax, 65
    jl .check_lowercase
    cmp rax, 90
    jle .continue

    .check_lowercase:

    cmp rax, 97
    jl .check_cyrillic
    cmp rax, 122
    jle .continue

    .check_cyrillic:

    cmp rax, 53392
    jl .return_false
    cmp rax, 53647
    jg .return_false

    .continue:

    integer_inc rdx
    jmp .while

  .end_while:

  mov rax, 1
  ret

  .return_false:

  mov rax, 0
  ret

f_is_digit:
  get_arg 0
  check_type rax, STRING
  mov rbx, rax

  string_length rax
  integer rax
  mov rcx, rax

  integer 0
  mov rdx, rax

  .while:
    is_equal rcx, rdx
    cmp rax, 1
    je .end_while

    string_get rbx, rdx
    mov rax, [rbx + 8*3]
    mov rax, [rax]
    mov rax, [rax + INTEGER_HEADER*8]

    cmp rax, 48
    jl .return_false
    cmp rax, 57
    jg .return_false

    .continue:

    integer_inc rdx
    jmp .while

  .end_while:

  mov rax, 1
  ret

  .return_false:

  mov rax, 0
  ret

f_string_to_list:
  get_arg 0
  mov rbx, rax

  check_type rbx, STRING

  list
  mov rcx, rax

  string_length rbx
  integer rax
  mov rdx, rax

  integer 0
  mov r8, rax

  .while:
    is_equal rdx, r8
    cmp rax, 1
    je .end_while

    string_get rbx, r8
    list_append rcx, rax

    integer_inc r8
    jmp .while

  .end_while:

  mov rax, rcx
  ret
