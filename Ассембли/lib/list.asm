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

section "list_append" executable

macro list_append list, item {
  enter list, item

  call f_list_append

  return
}

f_list_append:
  check_type rax, LIST

  push rax
  mov rcx, rax

  list_length rax
  xchg rcx, rax

  .while:
    mov rax, [rax + 8*1]
    dec rcx

    cmp rcx, 0
    jne .while

  mov rdx, rax
  mov rcx, [rbx + 8*0]

  cmp rcx, INTEGER
  je .integer

  cmp rcx, LIST
  je .list

  ; Выход с ошибкой при неизвестном типе
  print EXPECTED_TYPE_ERROR, 0, 0
  print INTEGER_TYPE, 44, 32
  print LIST_TYPE, 0
  exit -1

  .integer:
    mov rcx, INTEGER_SIZE
    jmp .continue

  .list:
    mov rcx, LIST_HEADER
    jmp .continue

  .continue:

  push rcx

  add rcx, 2  ; Учёт места для ссылок
  imul rcx, 8

  create_block rcx
  pop rcx

  mem_mov [rax + 8*0], rdx
  mem_mov [rdx + 8*1], rax

  mem_mov [rax + 8*1], 0
  add rax, 8*2

  mem_copy rbx, rax, rcx

  pop rax
  mem_mov rbx, [rax + 8*2]

  inc rbx
  mem_mov [rax + 8*2], rbx

  ret
