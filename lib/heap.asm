; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

f_allocate_heap:
  sys_mmap 0,\                                  ; Адрес (если 0, находится автоматически)
           PAGE_SIZE,\                          ; Количество памяти для аллокации
           PROT_READ + PROT_WRITE + PROT_EXEC,\ ; Права (PROT_READ | PROT_WRITE)
           MAP_SHARED + MAP_ANONYMOUS,\         ; MAP_ANONYMOUS | MAP_PRIVATE
           0,\                                  ; Файл дескриптор (ввод)
           0                                    ; Смещение относительно начала файла (с начала файла)

  ; Проверка корректности выделения памяти
  test rax, rax
  check_error js, "Ошибка аллокации"

  mov rbx, PAGE_SIZE                      ; Запись размера кучи
  sub rbx, HEAP_BLOCK_HEADER*4            ; Учёт размера заголовка блока

  mov ecx, HEAP_BLOCK
  mov [rax + 4*0], ecx ; Идентификатор

  mov rcx, 0
  mov [rax + 4*1], ecx ; Размер предыдущего блока (0 — крайний блок, другое — размер)
  mov [rax + 4*2], ebx ; Размер текущего блока
  mov [rax + 4*3], ecx ; Ссылка на предыдущий свободный блок (0 — крайний блок, 1 — занят, другое — указатель)
  mov [rax + 4*4], ecx ; Ссылка на следующий свободный блок (0 — крайний блок, 1 — занят, другое — указатель)

  cmp [HEAP_START], 0
  jne .allocated

    ; Если куча аллоцирована впервые
    mov rbx, rax
    add rbx, PAGE_SIZE  ; Смещение на размер страницы памяти
    mov [HEAP_END], rbx ; Сохранение указателя на конец кучи

    jmp @f

  .allocated:

    mov rbx, rax
    add rbx, HEAP_BLOCK_HEADER*4
    delete_block rbx

  @@:

  mov [HEAP_START], rax            ; Сохранение указателя на начало кучи

  mov rbx, [HEAP_END]
  sub rbx, rax
  mov [FIRST_FREE_HEAP_BLOCK], rbx ; Сохранение указателя на первый свободный блок

  ret

f_free_block:
  get_arg 0

  mov r8d, [rax]
  cmp r8d, HEAP_BLOCK
  je .correct_block

    raw_string "free_block: Ожидался блок кучи"
    error_raw rax
    exit -1

  .correct_block:

  mov r8, [HEAP_END]
  sub r8, rax

  cmp [FIRST_FREE_HEAP_BLOCK], r8
  jne @f
    ret
  @@:

  mov ebx, [rax + 4*3]
  cmp rbx, 1
  je .not_empty

    ; Перезапись ссылок в свободных блоках, на которые указывают ссылки
    mov ecx, [rax + 4*3]
    mov edx, [rax + 4*4]

    cmp rcx, 0
    je @f
      mov r9, [HEAP_END]
      sub r9, rcx
      mov [r9 + 4*4], edx
    @@:

    cmp rdx, 0
    je @f
      mov r9, [HEAP_END]
      sub r9, rdx
      mov [r9 + 4*3], ecx
    @@:

  .not_empty:

  ; Обновление указателя на первый свободный блок
  mov rbx, [FIRST_FREE_HEAP_BLOCK]
  mov [FIRST_FREE_HEAP_BLOCK], r8

  ; Обновление нового первого свободного блока
  mov rcx, 0
  mov [rax + 4*3], ecx   ; Установка указателя на предыдущий свободный блок (0 — крайний блок)
  mov [rax + 4*4], ebx ; Установка указателя на следущий свободный блок

  ; Обновление предыдущего первого свободного блока
  cmp rbx, 0
  je @f
    mov r9, [HEAP_END]
    sub r9, rbx
    mov [r9 + 4*3], r8d ; Установка указателя на предыдущий свободный блок
  @@:

  ret

f_merge_blocks:
  get_arg 1
  mov rbx, rax
  get_arg 0

  ; Проверка, что указатели ссылаются на заголовки блоков кучи
  mov r8d, [rax]
  cmp r8d, HEAP_BLOCK
  je .correct_first_block

    raw_string "merge_blocks: Ожидался блок кучи"
    error_raw rax
    exit -1

  .correct_first_block:

  mov r8d, [rbx]
  cmp r8d, HEAP_BLOCK
  je .correct_second_block

    raw_string "merge_blocks: Ожидался блок кучи"
    error_raw rax
    exit -1

  .correct_second_block:

  ; Вычисление размера нового блока
  mov ecx, [rax + 4*2]
  mov edx, [rbx + 4*2]

  add rcx, rdx
  add rcx, HEAP_BLOCK_HEADER*4

  mov [rax + 4*2], ecx

  ; Перезапись ссылок в свободных блоках, на которые указывают ссылки
  mov ecx, [rbx + 4*3]
  mov edx, [rbx + 4*4]

  cmp rcx, 0
  je @f
    mov r8, [HEAP_END]
    sub r8, rcx
    mov [r8 + 4*4], edx
  @@:

  cmp rdx, 0
  je @f
    mov r8, [HEAP_END]
    sub r8, rdx
    mov [r8 + 4*3], ecx
  @@:

  mov r8, [HEAP_END]
  sub r8, rbx

  cmp r8, [FIRST_FREE_HEAP_BLOCK]
  jne @f
    mov [FIRST_FREE_HEAP_BLOCK], rdx
  @@:

  ; Удаление заголовка текущего блока
  mov ecx, 0
  mov [rbx + 4*0], ecx
  mov [rbx + 4*1], ecx
  mov [rbx + 4*2], ecx
  mov [rbx + 4*3], ecx
  mov [rbx + 4*4], ecx

  ret

f_delete_block:
  get_arg 0
  sub rax, HEAP_BLOCK_HEADER*4

  mov r8d, [rax]
  cmp r8d, HEAP_BLOCK
  je .correct_block

    raw_string "delete_block: Ожидался блок кучи"
    error_raw rax
    exit -1

  .correct_block:

  free_block rax ; Освобождение текущего блока

  ; Смещение до заголовка предыдущего блока
  mov rbx, rax
  mov ecx, [rax + 4*1]
  sub rbx, rcx
  sub rbx, HEAP_BLOCK_HEADER*4

  ; Проверка выхода за пределы
  cmp rbx, [HEAP_START]
  jl @f

  ; Проверка состояния предыдущего блока
  mov ecx, [rbx + 4*3]
  cmp rcx, 1
  je @f

    merge_blocks rbx, rax
    mov rax, rbx

  @@:

  ; Смещение до заголовка следующего блока
  mov rbx, rax
  mov ecx, [rax + 4*2]
  add rbx, rcx
  add rbx, HEAP_BLOCK_HEADER*4

  ; Проверка выхода за пределы
  cmp rbx, [HEAP_END]
  jge @f

  ; Проверка состояния следующего блока
  mov ecx, [rbx + 4*3]
  cmp rcx, 1
  je @f

    merge_blocks rax, rbx

  @@:

  ; Смещение до заголовка следующего блока
  mov rbx, rax
  mov ecx, [rax + 4*2]
  add rbx, rcx
  add rbx, HEAP_BLOCK_HEADER*4

  ; Проверка выхода за пределы
  cmp rbx, [HEAP_END]
  jge @f

    ; Обновление поля «Размер предыдущего блока» для следующего блока
    mov ecx, [rax + 4*2]
    mov [rbx + 4*1], ecx

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

    mov r9, [HEAP_END]
    sub r9, rax

    mov rax, r9

    mov r9d, [rax]
    cmp r9d, HEAP_BLOCK
    je .correct_block

      raw_string "create_block: Ожидался блок кучи"
      error_raw rax
      exit -1

    .correct_block:

    mov ebx, [rax + 4*2]         ; Взятие размера текущего блока
    cmp rbx, r8
    jne .not_enough

      ; Перезапись ссылок в свободных блоках, на которые указывают ссылки
      mov ecx, [rax + 4*3]
      mov edx, [rax + 4*4]

      cmp rcx, 0
      je @f
        mov r9, [HEAP_END]
        sub r9, rcx
        mov [r9 + 4*4], edx
      @@:

      cmp rdx, 0
      je @f
        mov r9, [HEAP_END]
        sub r9, rdx
        mov [r9 + 4*3], ecx
      @@:

      ; Установка статуса созданного блока на «занят»
      mov r9, 1
      mov [rax + 4*3], r9d
      mov [rax + 4*4], r9d

      ; Проверка, что обработанный блок был первым свободным
      cmp rcx, 0
      jne @f
        mov [FIRST_FREE_HEAP_BLOCK], rdx
      @@:

      jmp .continue

    .not_enough:

    sub rbx, HEAP_BLOCK_HEADER*4 ; Учёт заголовка создаваемого блока

    ; Сравнение размеров проверяемого и создаваемого блоков
    cmp rbx, r8
    jl .too_little_size

      ; Если размер подходит, то занять текущий

      mov rcx, rax
      add rcx, HEAP_BLOCK_HEADER*4
      add rcx, r8

      ; Вычисление размера остающегося блока
      sub rbx, r8

      ; Запись нового размера созданного блока
      mov [rax + 4*2], r8d

      mov r9d, HEAP_BLOCK
      mov [rcx + 4*0], r9d ; Идентификатор
      mov r9d, [rax + 4*2]
      mov [rcx + 4*1], r9d  ; Размер предыдущего блока (0 — крайний блок, другое — размер)
      mov [rcx + 4*2], ebx ; Размер текущего блока
      mov r9d, [rax + 4*3]
      mov [rcx + 4*3], r9d ; Ссылка на предыдущий свободный блок (0 — крайний блок, 1 — занят, другое — указатель)
      mov r9d, [rax + 4*4]
      mov [rcx + 4*4], r9d ; Ссылка на следующий свободный блок (0 — крайний блок, 1 — занят, другое — указатель)

      ; Установка статуса созданного блока на «занят»
      mov r9, 1
      mov [rax + 4*3], r9d
      mov [rax + 4*4], r9d

      mov r10, [HEAP_END]
      sub r10, rcx

      ; Перезапись ссылок в свободных блоках, на которые указывают ссылки
      mov edx, [rcx + 4*3]
      cmp rdx, 0
      je @f
        mov r9, [HEAP_END]
        sub r9, rdx
        mov [r9 + 4*4], r10d
      @@:

      mov edx, [rcx + 4*4]
      cmp rdx, 0
      je @f
        mov r9, [HEAP_END]
        sub r9, rdx
        mov [r9 + 4*3], r10d
      @@:

      mov r9, [HEAP_END]
      sub r9, rax

      cmp [FIRST_FREE_HEAP_BLOCK], r9
      jne @f
        mov [FIRST_FREE_HEAP_BLOCK], r10
      @@:

      jmp .continue

    .too_little_size:

    mov eax, [rax + 4*4]
    jmp .loop

  .continue:

  push rax

  repeat 2
    mov ebx, [rax + 4*2]

    add rax, rbx
    add rax, HEAP_BLOCK_HEADER*4

    cmp rax, [HEAP_END]
    jge .end

    mov [rax + 4*1], ebx
  end repeat

  .end:
  pop rax

  add rax, HEAP_BLOCK_HEADER*4

  ret
