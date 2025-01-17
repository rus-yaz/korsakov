f_dictionary:
  cmp rax, 0
  jne .not_empty
  cmp rbx, 0
  jne .not_empty
    create_block DICTIONARY_HEADER*8

    mem_mov [rax + 8*0], DICTIONARY
    mem_mov [rax + 8*1], 0
    mem_mov [rax + 8*2], 0

    ret

  .not_empty:

  mov rdx, [rax]
  cmp rdx, LIST
  jne .invalid_arguments
  mov rdx, [rbx]
  cmp rdx, LIST
  jne .invalid_arguments

  jmp .correct_arguments

  .invalid_arguments:
    print EXPECTED_TYPE_ERROR, "", ""
    print LIST_TYPE, ""
    exit -1

  .correct_arguments:
  mov rcx, rbx
  mov rbx, rax

  create_block DICTIONARY_HEADER*8

  mem_mov [rax + 8*0], DICTIONARY
  mem_mov [rax + 8*1], 0
  push rax

  list_length rbx
  mov rdx, rax

  list_length rcx

  cmp rdx, rax
  je .correct_length
    exit -1, DIFFERENT_LISTS_LENGTH_ERROR

  .correct_length:

  pop rdx
  mem_mov [rdx + 8*2], 0
  mov r8, rdx

  integer rax
  mov rdx, rax

  integer 0
  mov r10, rax

  .while:
    is_equal rdx, r10
    cmp rax, 1
    je .end_while

    list_get rbx, r10
    mov r9, rax
    list_get rcx, r10

    dictionary_set r8, r9, rax

    integer_inc r10
    jmp .while

  .end_while:

  mov rax, r8

  ret

f_dictionary_length:
  check_type rax, DICTIONARY

  mov rax, [rax + 8*2]
  ret

f_dictionary_keys:
  check_type rax, DICTIONARY

  mov rbx, [rax + 8*1]

  list
  mov rdx, rax

  .while:
    cmp rbx, 0
    je .end_while

    integer 0
    mov rcx, rbx
    add rcx, 8*2
    list_get rcx, rax
    list_append rdx, rax

    mov rbx, [rbx + 8*1]
    jmp .while

  .end_while:

  mov rax, rdx
  ret

f_dictionary_values:
  check_type rax, DICTIONARY

  mov rbx, [rax + 8*1]

  list
  mov rdx, rax

  .while:
    cmp rbx, 0
    je .end_while

    integer 1
    mov rcx, rbx
    add rcx, 8*2
    list_get rcx, rax
    list_append rdx, rax

    mov rbx, [rbx + 8*1]
    jmp .while

  .end_while:

  mov rax, rdx
  ret

f_dictionary_get:
  check_type rax, DICTIONARY
  mov rdx, rbx

  ; Получение адреса на перый элемент
  mov rbx, [rax + 8*1]
  .while:
    cmp rbx, 0
    je .end_while

    add rbx, 2*8 ; Сдвиг к телу списка (элементы словаря — списки)

    ; Взятие первого значения списка — ключа
    integer 0
    list_get rbx, rax

    ; Сравнение текущего и искомого ключа
    is_equal rax, rdx
    cmp rax, 1
    je .return

    ; Взятие следующего элемента
    mov rbx, [rbx - 8*1]
    jmp .while

  .end_while:
  mov rax, rcx
  ret

  .return:
  integer 1
  list_get rbx, rax

  ret

f_dictionary_copy:
  check_type rax, DICTIONARY

  push rax
  dictionary_values rax
  mov rbx, rax

  pop rax
  dictionary_keys rax

  dictionary rax, rbx

  ret

f_dictionary_items:
  check_type rax, DICTIONARY

  push rax
  dictionary_keys rax
  mov rbx, rax

  pop rax
  dictionary_values rax
  mov rcx, rax

  list_length rcx
  mov rdx, rax

  integer 0
  mov r8, rax

  list

  .while:
    cmp rdx, 0
    je .end_while

    push rdx, rax

    list
    mov rdx, rax

    list_get rbx, r8
    list_append rdx, rax
    list_get rcx, r8
    list_append rdx, rax

    pop rdx
    list_append rdx, rax

    pop rdx

    push rax
    integer_inc r8
    dec rdx
    pop rax

    jmp .while

  .end_while:

  ret

f_dictionary_set:
  check_type rax, DICTIONARY
  mov rdx, rax

  dictionary_keys rdx
  list_index rax, rbx
  mov rax, [rax + INTEGER_HEADER*8]
  cmp rax, -1
  je .new_key

    inc rax
    mov r8, rdx
    .key_while:
      mov r8, [r8 + 8*1]
      dec rax

      cmp rax, 0
      jne .key_while

    mov r9, r8
    add r8, 8*2
    integer 1
    list_set r8, rax, rcx

    mov rax, rdx
    ret

  .new_key:

  mov rax, rdx
  push rdx, rdx

  dictionary_length rdx
  xchg rdx, rax

  inc rdx
  mem_mov [rax + 8*2], rdx
  pop rdx

  .while:
    cmp rdx, 0
    je .end_while

    mov rax, rdx
    mov rdx, [rax + 8*1]

    jmp .while

  .end_while:
  mov rdx, rax

  create_block (2 + LIST_HEADER) * 8

  mem_mov [rdx + 8*1], rax
  mem_mov [rax + 8*0], rdx

  mem_mov [rax + 8*1], 0
  mov rdx, rax

  list
  list_append rax, rbx
  list_append rax, rcx

  add rdx, 8*2
  mem_copy rax, rdx, LIST_HEADER
  delete_block rax

  pop rax
  ret
