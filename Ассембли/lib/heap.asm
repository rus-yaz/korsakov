section "heap" writable
  PAGE_SIZE   dq 0x1000             ; Начальный размер кучи
  HEAP_START  rq 1                  ; Указатель на начало кучи
  HEAP_END    rq 1                  ; Указатель на конец кучи

section "write_header" executable

macro write_header addr, header_sign, size, prev_size, state {
  mem_mov [addr + 8*0], header_sign
  mem_mov [addr + 8*1], size
  mem_mov [addr + 8*2], prev_size
  mem_mov [addr + 8*3], state
}

section "allocate_heap" executable

macro allocate_heap {
  enter

  call f_allocate_heap

  leave
}

f_allocate_heap:
  sys_mmap 0,\                                  ; Адрес (если 0, находится автоматически)
           [PAGE_SIZE],\                        ; Количество памяти для аллокации
           PROT_READ + PROT_WRITE + PROT_EXEC,\ ; Права (PROT_READ | PROT_WRITE)
           MAP_SHARED + MAP_ANONYMOUS,\         ; MAP_ANONYMOUS | MAP_PRIVATE
           0,\                                  ; Файл дескриптор (ввод)
           0                                    ; Смещение относительно начала файла (с начала файла)

  ; Проверка корректности выделения памяти
  test rax, rax
  check_error js, HEAP_ALLOCATION_ERROR

  mov rbx, [PAGE_SIZE]                    ; Запись размера кучи
  sub rbx, HEAP_BLOCK_HEADER*8            ; Учёт размера заголовка блока
  write_header rax, HEAP_BLOCK, rbx, 0, 0 ; Запись заголовка начального блока

  cmp [HEAP_START], 0
  jne .allocated

    push rax
    add rax, [PAGE_SIZE]  ; Смещение на размер страницы памяти

    mov [HEAP_END], rax   ; Сохранение указателя на конец кучи
    pop rax

  .allocated:

  ; Сохранение указателя на начало кучи
  mov [HEAP_START], rax

  ret

section "delete_block" executable

macro delete_block block {
  enter block

  call f_delete_block

  leave
}

f_delete_block:
  sub rax, HEAP_BLOCK_HEADER*8

  ; Если заголовок не найден, выйти с ошибкой
  check_type rax, HEAP_BLOCK

  ; Объединение текущего блока и следующего, если он не используется

  ; Нахождение следующего блока
  mov r8, rax
  add rax, HEAP_BLOCK_HEADER*8
  add rax, [r8 + 8*1]

  ; Если заголовок не найден (блока не существует), пропустить изменение блоков
  mov rbx, [rax]
  mov rcx, HEAP_BLOCK
  cmp rbx, rcx
  jne .skip_current_and_next_blocks_merging

  ; Если следующий блок используется, пропустить изменение блоков
  mov rbx, [rax + 8*3]
  test rbx, 1
  jne .skip_current_and_next_blocks_merging

    ; Увеличение размера текущего блока на размер удаляемого блока
    mov rcx, [r8 + 8*1]
    add rcx, [rax + 8*1]

    add rcx, HEAP_BLOCK_HEADER*8
    mov [r8 + 8*1], rcx

    ; Удаление заголовка удаляемого блока
    write_header rax, 0, 0, 0, 0

  .skip_current_and_next_blocks_merging:

  ; Нахождение предыдущего блока
  mov rax, r8
  sub rax, [r8 + 8*2]
  sub rax, HEAP_BLOCK_HEADER*8

  ; Проверка нахождения блока внутри кучи
  cmp rax, [HEAP_START]
  jl .skip_previous_and_current_blocks_merging

  ; Если заголовок не найден (блока не существует), пропустить изменение блоков
  mov rbx, [rax]
  mov rcx, HEAP_BLOCK
  cmp rbx, rcx
  jne .skip_previous_and_current_blocks_merging

  ; Если следующий блок используется, пропустить изменение блоков
  mov rbx, [rax + 8*3]
  test rbx, 1
  jne .skip_previous_and_current_blocks_merging

    ; Увеличение размера предыдущего блока на размер удаляемого блока
    mov rcx, [r8 + 8*1]
    add rcx, [rax + 8*1]

    add rcx, HEAP_BLOCK_HEADER*8
    mov [rax + 8*1], rcx

    ; Удаление заголовка удаляемого блока
    write_header r8, 0, 0, 0, 0
    mov r8, rax

  .skip_previous_and_current_blocks_merging:

  ; Изменение состояния текущего блока
  mov rax, [r8 + 8*3]
  test rax, 1
  jz .all_is_done
    mem_mov [r8 + 8*3], 0
  .all_is_done:

  ; Нахождение дальше идущего блока
  mov rcx, r8
  add rcx, [r8 + 8*1]
  add rcx, HEAP_BLOCK_HEADER*8

  ; Проверка нахождения блока внутри кучи
  cmp rcx, [HEAP_END]
  jge .skip_next_next_block_modifying

  ; Если заголовок не найден (блока не существует), пропустить изменение блоков
  mov rax, [rcx]
  mov rbx, HEAP_BLOCK
  cmp rax, rbx
  jne .skip_next_next_block_modifying

    ; Изменение PREV_SIZE для дальше идущего блока
    mem_mov [rcx + 8*2], [r8 + 8*1]

  .skip_next_next_block_modifying:

  ret

section "create_block" executable

macro create_block size {
  enter size

  call f_create_block

  return
}

f_create_block:
  cmp [HEAP_START], 0
  jne .allocated
    allocate_heap
  .allocated:

  ; Приведение размера к числу, кратному 8
  mov rbx, 8
  mov rdx, 0
  idiv rbx

  mov rcx, rdx
  mov rdx, 0
  imul rbx

  cmp rcx, 0
  je .skip
    add rax, 8
  .skip:

  mov r8, rax           ; Сохранение размера создаваемого блока
  mov rax, [HEAP_START] ; Запись указателя на начало кучи в RAX

  ; Цикл для нахождения подходящего блока
  .do:
    mov rdx, [HEAP_END]
    cmp rax, rdx
    jl .continue

      allocate_heap
      mov rax, [HEAP_START]

      add rax, HEAP_BLOCK_HEADER * 8
      delete_block rax

      mov rax, [HEAP_START]
    .continue:

    check_type rax, HEAP_BLOCK

    ; Получение информации о блоке
    mov rdx, [rax + 8*3]          ; Получение статуса использования блока
    cmp rdx, 0
    jne .find_new_block           ; Если блок используется, искать новый блок

    ; Сравнение выделенного размера и размера блока
    mov rdx, [rax + 8*1]           ; Получение размера блока
    sub rdx, HEAP_BLOCK_HEADER * 8 ; Учёт следующего блока, который будет создан

    cmp rdx, r8                    ; Сравнение с требуемым размером
    jg .found_block                ; Если блок достаточно большой, перейти к .found_block

    .find_new_block:
      ; Смещение адреса на размер блока и заголовка
      add rax, [rax + 8*1]           ; Смещение на размер блока
      add rax, HEAP_BLOCK_HEADER * 8 ; Смещение на размер заголовка
      jmp .do                        ; Переход к началу цикла

    .found_block:
      ; Вычисление адреса нового блока
      mov rbx, rax
      add rbx, HEAP_BLOCK_HEADER * 8 ; Смещение на заголовок
      add rbx, r8                    ; Смещение на размер нового блока

      ; Проверка состояния блока
      mov rcx, [rbx + 8*3]          ; Получение статуса нового блока
      test rcx, 1                   ; Проверка, используется ли блок
      jnz .find_new_block           ; Если блок используется, искать новый блок

  mem_mov [rax + 8*3], 1 ; Изменение состояния текущего блока на используемое

  mov rcx, [rax + 8*1]    ; Сохранение размера текущего блока в RCX
  sub rcx, r8             ; Вычисление размера текущего блока в RCX

  sub rcx, HEAP_BLOCK_HEADER*8            ; Учёт размера заголовка
  mem_mov [rax + 8*1], r8 ; Изменение SIZE у предыдущего блока

  ; KEY
  ; SIZE
  ; PREV_SIZE
  ; STATE
  write_header rbx, HEAP_BLOCK, rcx, r8, 0

  add rbx, rcx
  add rbx, HEAP_BLOCK_HEADER*8
  mov r8, HEAP_BLOCK
  cmp [rbx], r8
  jne .end
    mov [rbx + 8*2], rcx
  .end:

  add rax, HEAP_BLOCK_HEADER*8

  ret
