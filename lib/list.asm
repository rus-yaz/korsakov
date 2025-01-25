f_list:
  create_block LIST_HEADER*8

  mem_mov [rax + 8*0], LIST ; Тип
  mem_mov [rax + 8*1], 0    ; Указатель на первый элемент
  mem_mov [rax + 8*2], 0    ; Длина

  ret

f_list_length:
  get_arg 0
  check_type rax, LIST

  mov rax, [rax + 8*2]

  ret

f_list_get:
  get_arg 1
  mov rbx, rax
  get_arg 0

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

  copy rax

  ret

f_list_copy:
  get_arg 0
  check_type rax, LIST

  push rax

  list_length rax
  mov rbx, rax

  integer 0
  mov rcx, rax

  list
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
  get_arg 1
  mov rbx, rax
  get_arg 0

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

  copy rbx
  mov rbx, rax

  type_full_size [rbx]
  mov r8, rax

  ; RBX — item
  ; RCX — list
  ; RDX — last_item_link
  ; R8  — item_size

  list_length rcx
  inc rax
  mem_mov [rcx + 8*2], rax

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
  get_arg 0
  check_type rax, STRING

  mov rbx, rax
  integer 0
  xchg rbx, rax

  mov rcx, rax
  string_length rax
  xchg rcx, rax

  mov rdx, rax
  list
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
  get_arg 1
  mov rbx, rax
  get_arg 0
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
  get_arg 1
  mov rbx, rax
  get_arg 0
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
  get_arg 2
  mov rcx, rax
  get_arg 1
  mov rbx, rax
  get_arg 0

  check_type rax, LIST
  check_type rbx, INTEGER

  mov rdx, rax

  ; RBX — index
  ; RCX — item
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

  copy rbx
  mov rbx, rax

  type_full_size [rbx]
  mov r8, rax

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
  je .last
    mov [r10 + 8*0], rax

  .last:

  add rax, 8*2
  mem_copy rbx, rax, r9

  mov rax, rcx

  ret

f_list_pop:
  get_arg 0
  mov rcx, rax
  get_arg 1
  mov rbx, rax
  ; RBX — index = 0
  ; RCX — list

  cmp rbx, 0
  jne .not_default

    integer -1
    mov rbx, rax

  .not_default:

  check_type rbx, INTEGER
  check_type rcx, LIST

  mov rax, [rbx + INTEGER_HEADER*8]
  cmp rax, 0
  jge .positive_index
    list_length rcx
    integer rax
    integer_add rbx, rax
    mov rbx, rax

  .positive_index:

  mov rax, [rbx + INTEGER_HEADER*8]

  cmp rax, 0
  jge .correct_index
  mov rdx, rax
  list_length rcx
  cmp rdx, rax
  jl .correct_index

    string "Индекс выходит за пределы списка"
    print rax
    exit -1

  .correct_index:

  mov r8, rcx

  integer_inc rbx
  mov rbx, [rbx + INTEGER_HEADER*8]

  .while:
    cmp rbx, 0
    je .end_while

    mov r8, [r8 + 8*1]

    dec rbx
    jmp .while

  .end_while:

  list_length rcx
  dec rax
  mem_mov [rcx + 8*2], rax

  mov rax, [r8 + 8*0]
  mem_mov [rax + 8*1], [r8 + 8*1]

  mem_mov rax, [r8 + 8*1]
  cmp rax, 0
  je .last_item
    mem_mov [rax + 8*0], [r8 + 8*0]

  .last_item:

  add r8, 8*2
  copy r8

  sub r8, 8*2
  delete_block r8

  ret

f_list_insert:
  get_arg 0
  mov rdx, rax
  get_arg 1
  mov rbx, rax
  get_arg 2
  mov rcx, rax
  ; RBX — index
  ; RCX — value
  ; RDX — list

  check_type rbx, INTEGER
  check_type rdx, LIST

  mov rax, [rbx + INTEGER_HEADER*8]
  cmp rax, 0
  jge .positive_index
    list_length rdx
    integer rax
    integer_add rbx, rax
    mov rbx, rax

  .positive_index:

  mov rax, [rbx + INTEGER_HEADER*8]

  cmp rax, 0
  jl .index_out_of_range

  mov r8, rax
  list_length rdx
  cmp r8, rax
  jl .correct_index

  .index_out_of_range:

    string "Индекс выходит за пределы списка"
    print rax
    exit -1

  .correct_index:

  list_length rdx
  inc rax
  mem_mov [rdx + 8*2], rax

  mov rbx, [rbx + INTEGER_HEADER*8]
  inc rbx

  mov r8, rdx

  .while:
    cmp rbx, 0
    je .end_while

    mov r8, [r8 + 8*1]

    dec rbx
    jmp .while

  .end_while:

  mov r10, r8

  type_full_size [rcx]
  mov r9, rax

  add rax, 2
  imul rax, 8
  create_block rax

  mem_mov r8, [r10 + 8*0]
  mem_mov [rax + 8*0], r8

  mem_mov [r10 + 8*0], rax
  mem_mov [r8  + 8*1], rax

  mem_mov [rax + 8*1], r10

  add rax, 8*2
  mem_copy rcx, rax, r9

  mov rax, rdx
  ret
