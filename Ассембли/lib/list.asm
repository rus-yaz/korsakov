section "list" executable

; Запись списка на кучу
;
; Аргументы:
;   list_start — указатель на начало списка
;
; Результат:
;   rax — указатель на созданный блок

macro list list_start, length {
  enter list_start, length

  call f_list

  return
}

f_list:
  push rax             ; Сохранение указателя на начало копируемого списка
  push rbx             ; Сохранение длины списка
  mov rcx, LIST_HEADER ; Начальная длина списка

  .do:
    dec rbx

    mov rdx, [rax]
    cmp rdx, INTEGER
    jne .not_integer

    add rcx, 2
    add rax, 8*2
    jmp .while

  .not_integer:
    cmp rax, LIST
    jne .not_list

    add rcx, LIST_HEADER
    add rcx, [rax + 8*1]
    add rax, [rax + 8*2]

    jmp .while

  .not_list:
    check_error jmp, EXPECTED_INTEGER_LIST_TYPE_ERROR

  .while:
    cmp rbx, 0
    jne .do

  mov rbx, rcx
  imul rbx, 8

  ; Аллокация блока на куче
  create_block rbx

  ; Возвращение длины списка
  pop rbx

  write_header rax, LIST, rbx, rcx, 0

  ; RCX — количество блоков
  mov rbx, LIST_HEADER
  sub rcx, rbx
  imul rbx, 8
  mov rdi, rax ; Место назначения
  add rdi, rbx
  pop rsi      ; Источник копирования
  rep movsq    ; Копирование в аллоцированный блок

  ret

section "list_length" executable

macro list_length list_ptr {
  enter list_ptr

  call f_list_length

  return
}

f_list_length:
  mov rbx, [rax]
  cmp rbx, LIST
  check_error jne, EXPECTED_LIST_TYPE_ERROR

  mov rax, [rax + 8*1]

  ret

section "list_get" executable

; Запись списка на кучу
;
; Аргументы:
;   list_ptr  — указатель на начало списка
;   index_ptr — указатель на целое число, индекс
;
; Результат:
;   rax — указатель на элемент по индексу

macro list_get list_ptr, index_ptr {
  enter list_ptr, index_ptr

  call f_list_get

  return
}

f_list_get:
  ; Проверка типа
  mov rcx, [rax]
  cmp rcx, LIST
  check_error jne, EXPECTED_LIST_TYPE_ERROR

  ; Проверка типа
  mov rcx, [rbx]
  cmp rcx, INTEGER
  check_error jne, EXPECTED_INTEGER_TYPE_ERROR

  ; Запись длины списка
  mov rcx, [rax + 8*1]

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

  ; Получение указателя на тело списка
  mov rcx, rax
  mov rdx, LIST_HEADER
  imul rdx, 8
  add rcx, rdx

  .while:
    dec rbx

    cmp rbx, 0
    jl .while_end

  .do:
    mov rax, [rcx]

    cmp rax, INTEGER
    jne .not_integer

    add rcx, 8*2 ; Смещение на размер заголовка и размер тела
    jmp .while

  .not_integer:
    cmp rax, LIST
    jne .not_list

    mov rax, [rcx + 8*2]
    add rax, LIST_HEADER
    imul rax, 8
    add rcx, rax

    jmp .while

  .not_list:
    check_error jmp, EXPECTED_INTEGER_LIST_TYPE_ERROR

  .while_end:

    mov rax, rcx

  ret
