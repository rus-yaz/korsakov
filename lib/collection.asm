; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

f_collection:
  get_arg 0
  mov r8, rax

  cmp rax, 0
  jne .non_default
    mov r8, 2

  .non_default:

  mov rax, r8
  imul rax, 8
  create_block rax ; Аллокация места для элементов

  mov rbx, rax
  mov ecx, HEAP_BLOCK
  mov rdx, 0

  .while:
    cmp [rbx], ecx
    je .end_while

    mov [rbx], edx
    add rbx, 4

    jmp .while

  .end_while:
  mov rbx, rax

  create_block COLLECTION_HEADER*8
  mem_mov [rax + 8*0], COLLECTION ; Тип
  mem_mov [rax + 8*1], 0    ; Длина
  mem_mov [rax + 8*2], r8   ; Вместимость
  mem_mov [rax + 8*3], rbx  ; Указатель на элементы

  mov rbx, rax

  ret

f_is_collection:
  get_arg 0
  mov rcx, rax

  mov rax, [rax]

  mov rbx, COLLECTION
  cmp rax, rbx
  je .correct

  mov rbx, LIST
  cmp rax, rbx
  je .correct

  mov rbx, STRING
  cmp rax, rbx
  je .correct

  mov rbx, DICTIONARY
  cmp rax, rbx
  je .correct

    check_type rcx, COLLECTION

  .correct:

  ret

f_collection_length:
  get_arg 0
  mov rbx, rax

  is_collection rbx
  mov rax, [rbx + 8*1]

  ret

f_collection_capacity:
  get_arg 0
  mov rbx, rax

  is_collection rbx
  mov rax, [rbx + 8*2]

  ret

f_collection_expand_capacity:
  get_arg 0
  mov rbx, rax

  is_collection rbx

  collection_capacity rbx

  imul rax, 2
  mov [rbx + 8*2], rax

  imul rax, 8
  create_block rax
  mov r8, rax

  collection_length rbx
  mem_copy [rbx + 8*3], r8, rax
  mov rax, r8

  delete_block [rbx + 8*3]
  mov [rbx + 8*3], rax

  ret

f_collection_append_link:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  is_collection rbx

  collection_length rbx
  mov rdx, rax

  collection_capacity rbx

  cmp rdx, rax
  jne .no_expand

    collection_expand_capacity rbx

  .no_expand:

  mov r8, rdx

  inc rdx
  mov [rbx + 8*1], rdx

  imul r8, 8

  mov rax, [rbx + 8*3]
  add rax, r8

  mov [rax], rcx

  mov rax, rbx
  ret

f_collection_append:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  is_collection rbx

  copy rcx
  collection_append_link rbx, rax

  ret

f_collection_get_link:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  ; Проверка типа
  is_collection rbx
  check_type rcx, INTEGER

  ; Запись длины списка
  collection_length rbx
  mov rdx, rax

  ; Если индекс меньше нуля, то увеличить его на длину списка
  mov rcx, [rcx + INTEGER_HEADER*8]
  cmp rcx, 0
  jge @f
    add rcx, rdx
  @@:

  ; Проверка, входит ли индекс в список
  cmp rcx, rdx
  check_error jge, "Индекс выходит за пределы списка"
  cmp rcx, 0
  check_error jl, "Индекс выходит за пределы списка"

  imul rcx, 8
  mov rax, [rbx + 8*3]
  add rax, rcx

  mov rax, [rax]

  ret

f_collection_get:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  ; Проверка типа
  is_collection rbx
  check_type rcx, INTEGER

  collection_get_link rbx, rcx
  copy rax

  ret

f_collection_copy_links:
  get_arg 0
  mov rbx, rax

  is_collection rbx

  collection_capacity rbx
  collection rax
  mov rcx, rax

  mem_mov [rcx + 8*0], [rbx + 8*0]
  mem_mov [rcx + 8*1], [rbx + 8*1]
  mem_copy [rbx + 8*3], [rcx + 8*3], [rcx + 8*1]

  mov rax, rcx
  ret

f_collection_copy:
  get_arg 0
  mov rbx, rax

  is_collection rbx

  collection_capacity rbx
  collection rax
  mov rcx, rax

  mem_mov [rcx + 8*0], [rbx + 8*0]
  mem_mov [rcx + 8*1], [rbx + 8*1]

  mov r8, [rbx + 8*3]
  mov r9, [rcx + 8*3]

  mov rdx, [rcx + 8*1]
  .while:
    cmp rdx, 0
    je .end_while

    mov rax, [r8]
    copy rax
    mov [r9], rax

    add r8, 8
    add r9, 8

    dec rdx
    jmp .while

  .end_while:

  mov rax, rcx
  ret

f_collection_set_link:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  is_collection rbx
  check_type rcx, INTEGER

  ; Запись длины списка
  collection_length rbx
  mov r8, rax

  ; Если индекс меньше нуля, то увеличить его на длину списка
  mov rcx, [rcx + 8*1]
  cmp rcx, 0
  jge .positive_index
    add rcx, r8
  .positive_index:

  ; Проверка, входит ли индекс в список
  cmp rcx, r8
  check_error jge, "Индекс выходит за пределы списка"
  cmp rcx, 0
  check_error jl, "Индекс выходит за пределы списка"

  mov rax, rbx
  mov rbx, [rbx + 8*3]

  imul rcx, 8
  add rbx, rcx

  mov [rbx], rdx

  ret

f_collection_set:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  is_collection rbx
  check_type rcx, INTEGER

  copy rdx
  collection_set_link rbx, rcx, rax

  ret

f_collection_pop_link:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  cmp rcx, 0
  jne .non_default
    integer -1
    mov rcx, rax

  .non_default:

  is_collection rbx
  check_type rcx, INTEGER

  ; Запись длины списка
  collection_length rbx
  mov rdx, rax

  ; Если индекс меньше нуля, то увеличить его на длину списка
  mov rcx, [rcx + INTEGER_HEADER*8]
  cmp rcx, 0
  jge .positive_index
    add rcx, rdx
  .positive_index:

  ; Проверка, входит ли индекс в список
  cmp rcx, rdx
  check_error jge, "Индекс выходит за пределы списка"
  cmp rcx, 0
  check_error jl, "Индекс выходит за пределы списка"

  dec rdx
  mov [rbx + 8*1], rdx

  mov r8, rdx
  sub r8, rcx

  imul rcx, 8
  mov rbx, [rbx + 8*3]

  add rbx, rcx
  mov rax, [rbx]

  mov r9, rbx
  add r9, 8

  mem_copy r9, rbx, r8

  imul r8, 8
  add rbx, r8
  mem_mov [rbx], 0

  ret

f_collection_pop:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  cmp rcx, 0
  jne .non_default
    integer -1
    mov rcx, rax

  .non_default:

  is_collection rbx
  check_type rcx, INTEGER

  collection_pop_link rbx, rcx
  mov rbx, rax

  copy rax
  delete rbx

  ret

f_collection_insert_link:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  is_collection rbx
  check_type rcx, INTEGER

  collection_length rbx
  mov r8, rax

  collection_capacity rbx

  cmp r8, rax
  jne .no_expand

    collection_expand_capacity rbx

  .no_expand:

  ; Если индекс меньше нуля, то увеличить его на длину списка
  mov rcx, [rcx + 8*1]
  cmp rcx, 0
  jge .positive_index
    add rcx, r8
  .positive_index:

  ; Проверка, входит ли индекс в список
  cmp rcx, r8
  check_error jge, "Индекс выходит за пределы списка"
  cmp rcx, 0
  check_error jl, "Индекс выходит за пределы списка"

  inc r8
  mov [rbx + 8*1], r8

  dec r8
  sub r8, rcx
  mov r10, r8
  imul r8, 8

  mov rax, [rbx + 8*3]
  add rax, r8

  mov r9, rax
  sub r9, 8

  .while:

    cmp r10, 0
    je .end_while

    mem_mov [rax], [r9]

    sub r9, 8
    sub rax, 8

    dec r10
    jmp .while

  .end_while:

  mov [rax], rdx

  mov rax, rbx
  ret

f_collection_insert:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  is_collection rbx
  check_type rcx, INTEGER

  copy rdx
  collection_insert_link rbx, rcx, rax

  ret

f_collection_index:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  is_collection rbx

  integer 0
  mov rdx, rax

  collection_length rbx
  integer rax
  mov r8, rax

  .while:
    is_equal rdx, r8
    mov r9, rax
    boolean_value rax
    delete r9
    cmp rax, 1
    je .end_while

    collection_get_link rbx, rdx
    is_equal rax, rcx
    boolean_value rax
    cmp rax, 1
    je .return_index

    integer_inc rdx
    jmp .while

  .end_while:

  delete r8, rdx
  integer -1
  ret

  .return_index:
  delete r8
  mov rax, rdx

  ret

f_collection_include:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  is_collection rbx

  collection_index rbx, rcx
  mov rbx, [rax + INTEGER_HEADER*8]
  delete rax

  inc rbx ; -1 -> 0, index -> >0
  boolean rbx

  ret

f_collection_add_links:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  is_collection rbx
  is_collection rcx

  mov rax, [rbx]
  check_type rcx, rax

  collection_copy_links rbx
  mov rbx, rax

  integer 0
  mov rdx, rax

  collection_length rcx
  mov r8, rax

  .while:
    cmp r8, 0
    je .end_while

    collection_get_link rcx, rdx
    collection_append_link rbx, rax

    integer_inc rdx
    dec r8
    jmp .while

  .end_while:

  delete rdx
  mov rax, rbx

  ret

f_collection_add:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  is_collection rbx
  is_collection rcx

  mov rax, [rbx]
  check_type rcx, rax

  copy rbx
  mov rbx, rax
  copy rcx
  mov rcx, rax

  collection_add_links rbx, rcx
  delete_block [rcx + 8*3], rcx

  ret

f_collection_expand_links:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  is_collection rbx
  is_collection rcx

  list_length rcx
  integer rax
  mov rdx, rax

  integer 0
  mov r8, rax

  .while:

    is_equal rdx, r8
    boolean_value rax
    cmp rax, 1
    je .end_while

    list_get_link rcx, r8
    list_append_link rbx, rax

    integer_inc r8
    jmp .while

  .end_while:

  delete r8

  mov rax, rbx
  ret

f_collection_expand:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  is_collection rbx
  is_collection rcx

  copy rcx
  collection_expand_links rbx, rax

  ret
