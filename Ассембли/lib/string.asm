section "get_string_length" executable

macro get_string_length string_addr {
  enter string_addr

  call f_get_string_length

  return
}

f_get_string_length:
  ; Проверка типа
  mov rbx, [rax]
  cmp rbx, STRING
  check_error jne, EXPECTED_STRING_TYPE_ERROR

  mov rax, [rax + 8*1]
  ret

section "get_string" executable

macro get_string string_addr, index {
  enter string_addr, index

  call f_get_string

  return
}

f_get_string:
  ; Проверка типа
  mov rcx, [rax]
  cmp rcx, STRING
  check_error jne, EXPECTED_STRING_TYPE_ERROR

  ; Проверка типа
  mov rcx, [rbx]
  cmp rcx, INTEGER
  check_error jne, EXPECTED_INTEGER_TYPE_ERROR

  mov rcx, [rax + 8*1] ; Запись длины строки
  mov rbx, [rbx + 8*1] ; Запись индекса

  ; Если индекс меньше нуля, то увеличить его на длину строки
  cmp rbx, 0
  jge .positive_index
  add rbx, rcx

  .positive_index:

  ; Проверка, входит ли индекс в строку
  cmp rbx, rcx
  check_error jge, INDEX_OUT_OF_LIST_ERROR
  cmp rbx, 0
  check_error jl, INDEX_OUT_OF_LIST_ERROR

  ; Получение указателя на тело строки
  mov rcx, rax
  add rcx, STRING_HEADER*8

  ; Получение элемента по индексу
  imul rbx, (INTEGER_HEADER + 1) * 8
  add rbx, INTEGER_HEADER*8
  mov rcx, [rcx + rbx]

  create_block (1 + INTEGER_HEADER + STRING_HEADER) * 8

  mem_mov [rax + 8*0], STRING
  mem_mov [rax + 8*1], 1
  mem_mov [rax + 8*2], INTEGER
  mem_mov [rax + 8*3], rcx

  ret
