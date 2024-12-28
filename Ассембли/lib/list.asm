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

  ret


f_list_append:
  check_type rax, LIST

  push rax
  mov rcx, rbx
  mov rbx, rax
  list_length rax

  .while:
    cmp rax, 0
    je .end_while

    mov rbx, [rbx + 8*1]
    dec rax

    jmp .while
  .end_while:

  ; RAX — указатель на список
  ; RBX — указатель на последний элемент
  ; RCX — указатель на добавляемый элемент

  mov rdx, [rcx]

  cmp rdx, INTEGER
  je .integer

  cmp rdx, LIST
  je .list

  cmp rdx, STRING
  je .string

  cmp rdx, DICTIONARY
  je .dictionary

  ; Выход с ошибкой при неизвестном типе
  print EXPECTED_TYPE_ERROR, "", ""
  print <INTEGER_TYPE, STRING_TYPE, LIST_TYPE, DICTIONARY_TYPE>, ","
  exit -1

  .integer:
    integer_copy rcx
    mov rdx, INTEGER_SIZE
    jmp .continue

  .list:
    list_copy rcx
    mov rdx, LIST_HEADER
    jmp .continue

  .string:
    string_copy rcx
    mov rdx, STRING_HEADER
    jmp .continue

  .dictionary:
    dictionary_copy rcx
    mov rdx, DICTIONARY_HEADER
    jmp .continue

  .continue:

  mov rcx, rax
  pop rax

  mov rdi, [rax + 8*2]
  inc rdi

  mov [rax + 8*2], rdi
  push rax

  mov rsi, rdx
  add rsi, 2

  imul rsi, 8
  create_block rsi

  mem_mov [rax + 8*0], rbx
  mem_mov [rbx + 8*1], rax

  mem_mov [rax + 8*1], 0
  add rax, 8*2

  mem_copy rcx, rax, rdx
  pop rax

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

f_join:
  check_type rax, LIST

  mov r15, rsp

  mov rcx, rax
  push 0, rbx
  mov rax, rsp
  buffer_to_string rax
  mov rbx, rax
  mov rax, rcx

  mov rcx, rax
  push 0, ""
  mov rax, rsp
  buffer_to_string rax
  xchg rcx, rax

  mov rdx, rax
  list_length rax
  xchg rdx, rax

  cmp rdx, 0
  je .end_while

  mov rsi, rdx
  inc rsi
  .while:
    push rax
    push rbx

    mov rbx, rax
    mov rax, rsi
    sub rax, rdx

    integer rax
    integer_dec rax

    list_get rbx, rax
    check_type rax, STRING

    string_append rcx, rax

    pop rbx
    pop rax

    dec rdx

    cmp rdx, 0
    je .end_while

    push rax
    string_append rcx, rbx
    pop rax

    jmp .while
  .end_while:

  mov rsp, r15
  mov rax, rcx

  ret
