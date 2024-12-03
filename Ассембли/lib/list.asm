section "list" executable

macro list list_start = 0, length = 0 {
  enter list_start, length

  call f_list

  return
}

f_list:
  cmp rax, 0
  jne .continue
  cmp rax, 0
  jne .continue

  create_block LIST_HEADER*8
  mem_mov [rax + 8*0], LIST
  mem_mov [rax + 8*1], 0
  mem_mov [rax + 8*2], LIST_HEADER

  jmp .end

  .continue:

  push rax             ; Сохранение указателя на начало копируемого списка
  push rbx             ; Сохранение длины списка
  mov rcx, LIST_HEADER ; Начальная длина списка

  .loop_start:
    dec rbx                ; Decrement loop counter
    mov rdx, [rax]        ; Load the current element from the list

    cmp rdx, INTEGER      ; Check if it is an integer
    je .handle_integer     ; If yes, handle integer case

    cmp rdx, LIST         ; Check if it is a list
    je .handle_list        ; If yes, handle list case

    ; If neither, handle error
    check_error jmp, EXPECTED_INTEGER_LIST_TYPE_ERROR

  .handle_integer:
    add rcx, 2            ; Increment count for integer
    add rax, 8 * 2        ; Move to the next element (assuming 2 elements per integer)
    jmp .check_loop       ; Check loop condition

  .handle_list:
    add rcx, LIST_HEADER   ; Add list header size
    add rcx, [rax + 8 * 1] ; Add size of the list
    add rax, [rax + 8 * 2] ; Move to the next element in the list
    jmp .check_loop       ; Check loop condition

  .check_loop:
    cmp rbx, 0            ; Check if loop counter is zero
    jne .loop_start       ; If not, repeat the loop

  mov rbx, rcx
  imul rbx, 8

  ; Аллокация блока на куче
  create_block rbx

  ; Возвращение длины списка
  pop rbx

  write_header rax, LIST, rbx, rcx, 0

  ; RCX — количество блоков
  mov rbx, LIST_HEADER
  sub rcx, rbx
  imul rbx, 8

  mov rdi, rax ; Место назначения
  add rdi, rbx
  pop rsi      ; Источник копирования

  rep movsq    ; Копирование в аллоцированный блок

  .end:

  ret

section "list_length" executable

macro list_length list {
  enter list

  call f_list_length

  return
}

f_list_length:
  check_type rax, LIST, EXPECTED_LIST_TYPE_ERROR

  mov rax, [rax + 8*1]

  ret

section "list_get" executable

macro list_get list, index {
  enter list, index

  call f_list_get

  return
}

f_list_get:
  ; Проверка типа
  check_type rax, LIST, EXPECTED_LIST_TYPE_ERROR

  ; Проверка типа
  check_type rbx, INTEGER, EXPECTED_INTEGER_TYPE_ERROR

  ; Запись длины списка
  mov rcx, [rax + 8*1]

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

  ; Получение указателя на тело списка
  mov rcx, rax
  mov rdx, LIST_HEADER
  imul rdx, 8
  add rcx, rdx

  .while:
    dec rbx

    cmp rbx, 0
    jl .while_end

    .do:
      mov rax, [rcx]

      cmp rax, INTEGER
      jne .not_integer

      add rcx, 8*2 ; Смещение на размер заголовка и размер тела
      jmp .while

    .not_integer:
      cmp rax, LIST
      jne .not_list

      mov rax, [rcx + 8*2]
      add rax, LIST_HEADER
      imul rax, 8
      add rcx, rax

      jmp .while

    .not_list:
      check_error jmp, EXPECTED_INTEGER_LIST_TYPE_ERROR

  .while_end:

  mov rax, rcx

  ret

section "list_append" executable

macro list_append list, item {
  enter list, item

  call f_list_append

  return
}

f_list_append:
  check_type rax, LIST, EXPECTED_LIST_TYPE_ERROR

  mov rdx, [rax - HEAP_BLOCK_HEADER*8 + 8*1]

  mov rcx, [rax + 8*2]
  add rcx, [rbx - HEAP_BLOCK_HEADER*8 + 8*1]

  cmp rdx, rcx
  jge .copy_item

    push rax
    create_block rcx

    mov rdi, rax
    pop rsi

    push rax
    mov rdx, 8

    mov rax, rcx
    idiv rdx

    mov rcx, rax
    pop rax

    rep movsq

  .copy_item:

  mov rdi, rax
  add rdi, [rax + 8*2]

  mov rsi, rbx
  mov rcx, [rbx - HEAP_BLOCK_HEADER*8 + 8*1]

  rep movsq

  ret
