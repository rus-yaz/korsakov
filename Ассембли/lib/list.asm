section "list" executable

macro list list_start = 0, length = 0 {
  enter list_start, length

  call f_list

  return
}

f_list:
  mov rcx, rax
  create_block LIST_HEADER*8

  mem_mov [rax + 8*0], LIST
  mem_mov [rax + 8*1], 0

  ; Создание пустого списка
  cmp rbx, 0
  jne .not_empty

    mem_mov [rax + 8*2], 0
    ret

  .not_empty:

  mem_mov [rax + 8*2], rbx  ; Длина
  push rax                  ; Сохранение указателя на заголовок списка

  xchg rax, rcx

  ; RAX — указатель на копируемый элемент
  ; RBX — итератор
  ; RCX — указатель на предыдущий элемент
  ; RDX — размер копируемого элемента

  .loop_start:
    mov rdi, [rax]
    mov rdi, [rdi]

    cmp rdi, INTEGER
    je .integer

    cmp rdi, LIST
    je .list

    cmp rdi, STRING
    je .string

    ; Выход с ошибкой при неизвестном типе
    print EXPECTED_TYPE_ERROR, 0, 0
    print INTEGER_TYPE, 44, 32
    print LIST_TYPE, 0
    exit -1

    .integer:
      mov rdx, INTEGER_SIZE
      jmp .continue       ; Check loop condition

    .list:
      mov rdx, LIST_HEADER
      jmp .continue       ; Check loop condition

    .string:
      mov rdx, STRING_HEADER
      jmp .continue       ; Check loop condition

    .continue:
      push rax
      push rdx

      add rdx, 2        ; Учёт ссылок на предыдущий и следующий блоки
      imul rdx, 8       ; Расчёт размера блока

      create_block rdx

      mem_mov [rax + 8*0], rcx ; Указатель на предыдущий блок
      mem_mov [rax + 8*1], 0   ; Указатель на следующий блок, инициализационное значение

      mem_mov [rcx + 8*1], rax ; Установка указателя на текущий блок для предыдущего (относительно предыдущего блока — указатель на следующий блок)
      mov rcx, rax

      pop rdx
      pop rax

      push rcx
      add rcx, 2*8 ; Учёт ссылок

      ; RAX — источник
      ; RCX — место назначения
      ; RDX — количество блоков копирования
      mem_copy [rax], rcx, rdx
      pop rcx

      dec rbx
      add rax, 8

      cmp rbx, 0            ; Check if loop counter is zero
      jne .loop_start       ; If not, repeat the loop

  pop rax

  ret

section "list_length" executable

macro list_length list {
  enter list

  call f_list_length

  return
}

f_list_length:
  check_type rax, LIST

  mov rax, [rax + 8*2]

  ret

section "list_get" executable

macro list_get list, index {
  enter list, index

  call f_list_get

  return
}

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

section "list_copy" executable

macro list_copy list {
  enter list

  call f_list_copy

  return
}

f_list_copy:
  check_type rax, LIST

  mov rbx, rax
  integer 0
  xchg rbx, rax

  mov rcx, rax
  list_length rax
  xchg rcx, rax

  .while:
    cmp rcx, 0
    je .end_while

    mov rcx, rax
    list_get rax, rbx
    xchg rcx, rax

    ; RAX — указатель на список
    ; RBX — указатель на последний элемент
    ; RCX — указатель на добавляемый элемент

    mov rdx, [rcx]
    cmp rcx, INTEGER
    je .integer

    cmp rdx, LIST
    je .list

    cmp rdx, STRING
    je .string

    ; Выход с ошибкой при неизвестном типе
    print EXPECTED_TYPE_ERROR, "", ""
    print INTEGER_TYPE, ",", " "
    print STRING_TYPE, ",", " "
    print LIST_TYPE, ""
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

    .continue:

    mov rdi, [rax + 8*2]
    inc rdi

    mov [rax + 8*2], rdi
    push rax

    imul rdx, 8
    create_block rdx

    push rax
    push rbx

    mov rax, rdx
    mov rbx, 8

    mov rdx, 0
    idiv rbx

    mov rdx, rax
    pop rbx
    pop rax

    mem_mov [rax + 8*0], rbx
    mem_mov [rbx + 8*1], rax

    mem_mov [rax + 8*1], 0
    mov rbx, rax

    add rax, 8*2
    mem_copy rcx, rax, rdx

    dec rcx
    jmp .while
  .end_while:


section "list_append" executable

macro list_append list, item {
  enter list, item

  call f_list_append

  return
}

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

  ; Выход с ошибкой при неизвестном типе
  print EXPECTED_TYPE_ERROR, "", ""
  print INTEGER_TYPE, ",", " "
  print STRING_TYPE, ",", " "
  print LIST_TYPE, ""
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

section "string_to_list" executable

macro string_to_list string {
  enter string

  call f_string_to_list

  return
}

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

section "join" executable

macro join list, separator = " " {
  enter list, separator

  call f_join

  return
}

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
