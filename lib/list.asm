f_list:
  push rax
  create_block LIST_HEADER*8

  mem_mov [rax + 8*0], LIST ; Тип
  mem_mov [rax + 8*1], 0    ; Место для ссылки на первый элемент
  mem_mov [rax + 8*2], 0    ; Начальная длина

  pop rcx
  mov rdx, 0

  ; RAX — указатель на новый список
  ; RBX — длина
  ; RCX — указатель на последовательность указателей на добавляемые элементы
  ; RDX — итератор

  .while:
    cmp rbx, rdx
    je .end_while

    list_append rax, [rcx]
    add rcx, 8

    inc rdx
    jmp .while

  .end_while:

  ret

f_list_length:
  check_type rax, LIST

  mov rax, [rax + 8*2]

  ret

f_list_get:
  ; Проверка типа
  check_type rax, LIST
  check_type rbx, INTEGER

  ; Запись длины списка
  mov rcx, rax
  list_length rax
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

  add rax, 8*2

  ret

f_list_copy:
  check_type rax, LIST

  push rax

  list_length rax
  mov rbx, rax

  integer 0
  mov rcx, rax

  list 0
  mov rdx, rax

  pop rax

  .while:
    cmp rbx, 0
    je .end_while

    push rax
    list_get rax, rcx
    list_append rdx, rax

    dec rbx
    integer_inc rcx
    pop rax

    jmp .while

  .end_while:

  mov rax, rdx

  ret


f_list_append:
  check_type rax, LIST

  mov rcx, rax

  ; RBX — item
  ; RCX — list

  mov rdx, rcx
  .while:
    mov r8, rdx
    mov rdx, [rdx + 8*1]

    cmp rdx, 0
    jne .while

  ; RBX — item
  ; RCX — list
  ; RDX — last_item_link
  mov rdx, r8

  mov rax, [rbx]

  cmp rax, INTEGER
  je .integer

  cmp rax, LIST
  je .list

  cmp rax, STRING
  je .string

  cmp rax, DICTIONARY
  je .dictionary

  ; Выход с ошибкой при неизвестном типе
  print EXPECTED_TYPE_ERROR, "", ""

  list 0
  mov rbx, rax

  buffer_to_string INTEGER_TYPE
  list_append rbx, rax
  buffer_to_string STRING_TYPE
  list_append rbx, rax
  buffer_to_string LIST_TYPE
  list_append rbx, rax
  buffer_to_string DICTIONARY_TYPE
  list_append rbx, rax

  join rbx, ", "
  print rax

  exit -1

  .integer:
    integer_copy rbx
    mov r8, INTEGER_SIZE
    jmp .continue

  .list:
    list_copy rbx
    mov r8, LIST_HEADER
    jmp .continue

  .string:
    string_copy rbx
    mov r8, STRING_HEADER
    jmp .continue

  .dictionary:
    dictionary_copy rbx
    mov r8, DICTIONARY_HEADER
    jmp .continue

  .continue:

  mov rbx, rax

  ; RBX — item
  ; RCX — list
  ; RDX — last_item_link
  ; R8  — item_size

  mem_mov rax, [rcx + 2*8]
  inc rax
  mem_mov [rcx + 2*8], rax

  mov r9, r8

  add r8, 2
  imul r8, 8
  create_block r8

  mem_mov [rax + 8*0], rdx
  mem_mov [rdx + 8*1], rax

  mem_mov [rax + 8*1], 0

  add rax, 8*2
  mem_copy rbx, rax, r9

  mov rax, rcx

  ret

f_string_to_list:
  check_type rax, STRING

  mov rbx, rax
  integer 0
  xchg rbx, rax

  mov rcx, rax
  string_length rax
  xchg rcx, rax

  mov rdx, rax
  list 0
  xchg rdx, rax

  ; RAX — строка (Целое число)
  ; RBX — индекс (Целое число)
  ; RCX — длина  (число)
  ; RDX — список (Список)
  .while:
    cmp rcx, 0
    je .end_while

    dec rcx
    push rax

    string_get rax, rbx
    list_append rdx, rax

    integer_inc rbx
    pop rax

    jmp .while
  .end_while:

  mov rax, rdx
  ret

f_list_index:
  check_type rax, LIST

  mov rcx, rax

  integer 0
  mov rdx, rax

  .while:
    list_length rcx
    integer rax
    is_equal rdx, rax
    cmp rax, 1
    je .end_while

    list_get rcx, rdx
    is_equal rax, rbx
    cmp rax, 1
    je .return_index

    integer_inc rdx
    jmp .while

  .end_while:

  integer -1
  ret

  .return_index:
  mov rax, rdx

  ret

f_list_include:
  check_type rax, LIST

  list_index rax, rbx
  mov rbx, rax

  integer -1
  is_equal rbx, rax
  cmp rax, 1
  je .does_not_include
    mov rax, 1
    ret

  .does_not_include:
  mov rax, -1
  ret

f_list_set:
  check_type rax, LIST
  check_type rbx, INTEGER

  mov rdx, rax

  ; RCX — item
  ; RBX — index
  ; RDX — list

  mov r8, rdx
  mov rbx, [rbx + INTEGER_HEADER*8]
  inc rbx
  .while:
    mov r8, [r8 + 8*1]
    dec rbx

    cmp rbx, 0
    jne .while

  mov rbx, rcx
  mov rcx, rdx
  mov rdx, r8

  ; RBX — item
  ; RCX — list
  ; RDX — index_item_link

  mov rax, [rbx]

  cmp rax, INTEGER
  je .integer

  cmp rax, LIST
  je .list

  cmp rax, STRING
  je .string

  cmp rax, DICTIONARY
  je .dictionary

  ; Выход с ошибкой при неизвестном типе
  print EXPECTED_TYPE_ERROR, "", ""

  list 0
  mov rbx, rax

  buffer_to_string INTEGER_TYPE
  list_append rbx, rax
  buffer_to_string STRING_TYPE
  list_append rbx, rax
  buffer_to_string LIST_TYPE
  list_append rbx, rax
  buffer_to_string DICTIONARY_TYPE
  list_append rbx, rax

  join rbx, ", "
  print rax

  exit -1

  .integer:
    integer_copy rbx
    mov r8, INTEGER_SIZE
    jmp .continue

  .list:
    list_copy rbx
    mov r8, LIST_HEADER
    jmp .continue

  .string:
    string_copy rbx
    mov r8, STRING_HEADER
    jmp .continue

  .dictionary:
    dictionary_copy rbx
    mov r8, DICTIONARY_HEADER
    jmp .continue

  .continue:

  mov rbx, rax

  ; RBX — item
  ; RCX — list
  ; RDX — index_item_link
  ; R8  — item_size

  mov r9, r8

  add r8, 2
  imul r8, 8
  create_block r8

  mem_mov [rax + 8*0], [rdx + 8*0]
  mem_mov [rax + 8*1], [rdx + 8*1]

  add rdx, 8*2
  delete rdx

  mov r10, [rax + 8*0]
  mov [r10 + 8*1], rax

  mov r10, [rax + 8*1]
  cmp r10, 0
  je .not_last
    mov [r10 + 8*0], rax

  .not_last:

  add rax, 8*2
  mem_copy rbx, rax, r9

  mov rax, rcx

  ret
