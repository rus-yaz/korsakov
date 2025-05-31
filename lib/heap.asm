; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

f_allocate_heap:
  sys_mmap 0,\                                  ; Адрес (если 0, находится автоматически)
           PAGE_SIZE,\                        ; Количество памяти для аллокации
           PROT_READ + PROT_WRITE + PROT_EXEC,\ ; Права (PROT_READ | PROT_WRITE)
           MAP_SHARED + MAP_ANONYMOUS,\         ; MAP_ANONYMOUS | MAP_PRIVATE
           0,\                                  ; Файл дескриптор (ввод)
           0                                    ; Смещение относительно начала файла (с начала файла)

  ; Проверка корректности выделения памяти
  test rax, rax
  check_error js, "Ошибка аллокации"

  mov rbx, PAGE_SIZE                    ; Запись размера кучи
  sub rbx, HEAP_BLOCK_HEADER*8            ; Учёт размера заголовка блока

  mem_mov [rax + 8*0], HEAP_BLOCK ; Идентификатор
  mem_mov [rax + 8*1], 0          ; Размер предыдущего блока (0 — крайний блок, другое — размер)
  mem_mov [rax + 8*2], rbx        ; Размер текущего блока
  mem_mov [rax + 8*3], 0          ; Ссылка на предыдущий свободный блок (0 — крайний блок, 1 — занят, другое — указатель)
  mem_mov [rax + 8*4], 0          ; Ссылка на следующий свободный блок (0 — крайний блок, 1 — занят, другое — указатель)

  cmp [HEAP_START], 0
  jne .allocated

    ; Если куча аллоцирована впервые
    mov rbx, rax
    add rbx, PAGE_SIZE  ; Смещение на размер страницы памяти
    mov [HEAP_END], rbx ; Сохранение указателя на конец кучи

    jmp @f

  .allocated:

    mov rbx, rax
    add rbx, HEAP_BLOCK_HEADER*8
    delete_block rbx

  @@:

  mov [HEAP_START], rax            ; Сохранение указателя на начало кучи
  mov [FIRST_FREE_HEAP_BLOCK], rax ; Сохранение указателя на первый свободный блок

  ret

f_free_block:
  get_arg 0
  check_type rax, HEAP_BLOCK ; Проверка, что указатель ссылается на заголовок блока кучи

  cmp [FIRST_FREE_HEAP_BLOCK], rax
  jne @f
    ret
  @@:

  mov rbx, [rax + 8*3]
  cmp rbx, 1
  je .not_empty

    ; Перезапись ссылок в свободных блоках, на которые указывают ссылки
    mov rcx, [rax + 8*3]
    mov rdx, [rax + 8*4]

    cmp rcx, 0
    je @f
      mem_mov [rcx + 8*4], rdx
    @@:

    cmp rdx, 0
    je @f
      mem_mov [rdx + 8*3], rcx
    @@:

  .not_empty:

  ; Обновление указателя на первый свободный блок
  mov rbx, [FIRST_FREE_HEAP_BLOCK]
  mov [FIRST_FREE_HEAP_BLOCK], rax

  ; Обновление нового первого свободного блока
  mem_mov [rax + 8*3], 0   ; Установка указателя на предыдущий свободный блок (0 — крайний блок)
  mem_mov [rax + 8*4], rbx ; Установка указателя на следущий свободный блок

  ; Обновление предыдущего первого свободного блока
  cmp rbx, 0
  je @f
    mem_mov [rbx + 8*3], rax ; Установка указателя на предыдущий свободный блок
  @@:

  ret

f_merge_blocks:
  get_arg 1
  mov rbx, rax
  get_arg 0

  ; Проверка, что указатели ссылаются на заголовки блоков кучи
  check_type rax, HEAP_BLOCK
  check_type rbx, HEAP_BLOCK

  ; Вычисление размера нового блока
  mov rcx, [rax + 8*2]
  mov rdx, [rbx + 8*2]

  add rcx, rdx
  add rcx, HEAP_BLOCK_HEADER*8

  mov [rax + 8*2], rcx

  ; Перезапись ссылок в свободных блоках, на которые указывают ссылки
  mov rcx, [rbx + 8*3]
  mov rdx, [rbx + 8*4]

  cmp rcx, 0
  je @f
    mem_mov [rcx + 8*4], rdx
  @@:

  cmp rdx, 0
  je @f
    mem_mov [rdx + 8*3], rcx
  @@:

  cmp rbx, [FIRST_FREE_HEAP_BLOCK]
  jne @f
    mov [FIRST_FREE_HEAP_BLOCK], rdx
  @@:

  ; Удаление заголовка текущего блока
  mem_mov [rbx + 8*0], 0
  mem_mov [rbx + 8*1], 0
  mem_mov [rbx + 8*2], 0
  mem_mov [rbx + 8*3], 0
  mem_mov [rbx + 8*4], 0

  ret

f_delete_block:
  get_arg 0
  sub rax, HEAP_BLOCK_HEADER*8
  check_type rax, HEAP_BLOCK ; Проверка, что указатель ссылается на заголовок блока кучи

  free_block rax ; Освобождение текущего блока

  ; Смещение до заголовка предыдущего блока
  mov rbx, rax
  sub rbx, [rax + 8*1]
  sub rbx, HEAP_BLOCK_HEADER*8

  ; Проверка выхода за пределы
  cmp rbx, [HEAP_START]
  jl @f

  ; Проверка состояния предыдущего блока
  mov rcx, [rbx + 8*3]
  cmp rcx, 1
  je @f

    merge_blocks rbx, rax
    mov rax, rbx

  @@:

  ; Смещение до заголовка следующего блока
  mov rbx, rax
  add rbx, [rax + 8*2]
  add rbx, HEAP_BLOCK_HEADER*8

  ; Проверка выхода за пределы
  cmp rbx, [HEAP_END]
  jge @f

  ; Проверка состояния следующего блока
  mov rcx, [rbx + 8*3]
  cmp rcx, 1
  je @f

    merge_blocks rax, rbx

  @@:

  ; Смещение до заголовка следующего блока
  mov rbx, rax
  add rbx, [rax + 8*2]
  add rbx, HEAP_BLOCK_HEADER*8

  ; Проверка выхода за пределы
  cmp rbx, [HEAP_END]
  jge @f

    ; Обновление поля «Размер предыдущего блока» для следующего блока
    mem_mov [rbx + 8*1], [rax + 8*2]

  @@:

  ret

f_create_block:
  get_arg 0

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

  mov r8, rax                      ; Сохранение размера создаваемого блока
  mov rax, [FIRST_FREE_HEAP_BLOCK] ; Запись указателя на первый свободный блок

  ; Цикл для нахождения подходящего блока
  .loop:
    cmp rax, 0
    jne .next

      ; Если блок является последним свободным блоком
      allocate_heap                    ; Аллокация новой кучи
      mov rax, [FIRST_FREE_HEAP_BLOCK]

    .next:

    check_type rax, HEAP_BLOCK ; Проверка, что проверямый указатель является блоком

    mov rbx, [rax + 8*2]         ; Взятие размера текущего блока
    cmp rbx, r8
    jne .not_enough

      ; Перезапись ссылок в свободных блоках, на которые указывают ссылки
      mov rcx, [rax + 8*3]
      mov rdx, [rax + 8*4]

      cmp rcx, 0
      je @f
        mem_mov [rcx + 8*4], rdx
      @@:

      cmp rdx, 0
      je @f
        mem_mov [rdx + 8*3], rcx
      @@:

      ; Установка статуса созданного блока на «занят»
      mem_mov [rax + 8*3], 1
      mem_mov [rax + 8*4], 1

      ; Проверка, что обработанный блок был первым свободным
      cmp rcx, 0
      jne @f
        mov [FIRST_FREE_HEAP_BLOCK], rdx
      @@:

      jmp .continue

    .not_enough:

    sub rbx, HEAP_BLOCK_HEADER*8 ; Учёт заголовка создаваемого блока

    ; Сравнение размеров проверяемого и создаваемого блоков
    cmp rbx, r8
    jl .too_little_size

      ; Если размер подходит, то занять текущий

      mov rcx, rax
      add rcx, HEAP_BLOCK_HEADER*8
      add rcx, r8

      ; Вычисление размера остающегося блока
      sub rbx, r8

      ; Запись нового размера созданного блока
      mem_mov [rax + 8*2], r8

      mem_mov [rcx + 8*0], HEAP_BLOCK  ; Идентификатор
      mem_mov [rcx + 8*1], [rax + 8*2] ; Размер предыдущего блока (0 — крайний блок, другое — размер)
      mem_mov [rcx + 8*2], rbx         ; Размер текущего блока
      mem_mov [rcx + 8*3], [rax + 8*3] ; Ссылка на предыдущий свободный блок (0 — крайний блок, 1 — занят, другое — указатель)
      mem_mov [rcx + 8*4], [rax + 8*4] ; Ссылка на следующий свободный блок (0 — крайний блок, 1 — занят, другое — указатель)

      ; Установка статуса созданного блока на «занят»
      mem_mov [rax + 8*3], 1
      mem_mov [rax + 8*4], 1

      ; Перезапись ссылок в свободных блоках, на которые указывают ссылки
      mov rdx, [rcx + 8*3]
      cmp rdx, 0
      je @f
        mov [rdx + 8*4], rcx
      @@:
      mov rdx, [rcx + 8*4]
      cmp rdx, 0
      je @f
        mov [rdx + 8*3], rcx
      @@:

      cmp [FIRST_FREE_HEAP_BLOCK], rax
      jne @f
        mov [FIRST_FREE_HEAP_BLOCK], rcx
      @@:

      jmp .continue

    .too_little_size:

    mov rax, [rax + 8*4]
    jmp .loop

  .continue:

  push rax

  repeat 2
    mov rbx, [rax + 8*2]

    add rax, rbx
    add rax, HEAP_BLOCK_HEADER*8

    cmp rax, [HEAP_END]
    jge .end

    mov [rax + 8*1], rbx
  end repeat

  .end:
  pop rax

  add rax, HEAP_BLOCK_HEADER*8

  ret
