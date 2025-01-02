f_dictionary:
  mov rcx, rax
  create_block DICTIONARY_HEADER*8
  xchg rcx, rax

  mem_mov [rcx + 8*0], DICTIONARY
  mem_mov [rcx + 8*1], 0

  cmp rax, 0
  jne .not_empty
  cmp rbx, 0
  jne .not_empty
    mem_mov [rcx + 8*2], 0
    mov rax, rcx
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

  push rax
  list_length rax

  mov rdx, rax
  list_length rbx

  cmp rdx, rax
  je .correct_length
    exit -1, DIFFERENT_LISTS_LENGTH_ERROR

  .correct_length:

  pop rdi
  xchg rdi, rax
  push rax

  mem_mov [rcx + 8*2], rdi

  integer 0
  mov rsi, rax
  pop rax

  ; RAX — список ключей
  ; RBX — список значений
  ; RCX — текущий ключ
  ; RDX — текущее значение
  ; RDI — длина словаря
  ; RSI — индекс
  ; R8  — указатель на предыдущий элемент

  push rcx
  mov r8, rcx

  .while:
    cmp rdi, 0
    je .end_while

    mov rcx, rax
    list_get rax, rsi
    xchg rcx, rax

    mov rdx, rax
    list_get rbx, rsi
    xchg rdx, rax

    push rax, rbx
    list 0

    list_append rax, rcx
    list_append rax, rdx
    mov rbx, rax

    create_block (2 + LIST_HEADER) * 8
    mem_mov [r8  + 8*1], rax

    mem_mov [rax + 8*0], r8
    mem_mov [rax + 8*1], 0

    mov r8, rax
    add rax, 8*2

    mem_copy rbx, rax, LIST_HEADER
    integer_inc rsi

    pop rbx, rax

    dec rdi
    jmp .while

  .end_while:
  pop rax

  ret

f_dictionary_length:
  check_type rax, DICTIONARY

  mov rax, [rax + 8*2]
  ret

f_dictionary_keys:
  check_type rax, DICTIONARY

  mov rbx, [rax + 8*1]

  list 0
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

  list 0
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
  mov rcx, rbx

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
    is_equal rax, rcx
    cmp rax, 1
    je .return

    ; Взятие следующего элемента
    mov rbx, [rbx - 8*1]
    jmp .while

  .end_while:
  exit -1, KEY_DOESNT_EXISTS

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

  list 0

  .while:
    cmp rdx, 0
    je .end_while

    push rdx, rax

    list 0
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
