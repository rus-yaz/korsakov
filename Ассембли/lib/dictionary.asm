section "dictionary" executable

macro dictionary keys = 0, values = 0 {
  enter keys, values

  call f_dictionary

  return
}

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

  pop rax
  push rax

  list_length rax
  mov rdi, rax

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

section "dictionary_length" executable

macro dictionary_length dictionary, key {
  enter dictionary, key

  call f_dictionary_length

  return
}

f_dictionary_length:
  check_type rax, DICTIONARY

  mov rax, [rax + 8*2]
  ret

section "dictionary_keys" executable

macro dictionary_keys dictionary {
  enter dictionary

  call f_dictionary_keys

  return
}

f_dictionary_keys:
  check_type rax, DICTIONARY

  list 0
  mov rdx, rax

  mov rbx, [rax + 8*1]
  .while:
    cmp rbx, 0
    je .end_while

    integer 0
    list_get rbx, rax

    list_append rdx, rax

    mov rbx, [rbx + 8*1]
    jmp .while

  .end_while:

  mov rax, rdx
  ret

section "dictionary_values" executable

macro dictionary_values dictionary {
  enter dictionary

  call f_dictionary_values

  return
}


f_dictionary_values:
  check_type rax, DICTIONARY

  list 0
  mov rdx, rax

  mov rbx, [rax + 8*1]
  .while:
    cmp rbx, 0
    je .end_while

    integer 1
    list_get rbx, rax

    list_append rdx, rax

    mov rbx, [rbx + 8*1]
    jmp .while

  .end_while:

  mov rax, rdx
  ret

section "dictionary_get" executable

macro dictionary_get dictionary, key {
  enter dictionary, key

  call f_dictionary_get

  return
}

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
