; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

; @function get_heap_address_by_offset
; @description Получение адреса на куче по отступу от зафиксированной границы
; @param offset
; @return Абсолютный адрес
; @example
;   get_heap_address
_function get_heap_address_by_offset, rbx
  get_arg 0
  mov rbx, rax

  match =1, HEAP_FORWARD {
    mov rax, [HEAP_END]
    sub rax, rbx
  }
  match =0, HEAP_FORWARD {
    mov rax, rbx
    add rax, [HEAP_START]
  }

  ret

; @function get_heap_offset_by_address
; @description Получение отступа от зафиксированной границы по адресу на куче
; @param address
; @return Относительный адрес (от границы кучи)
; @example
;   get_heap_offset_by_address
_function get_heap_offset_by_address, rbx
  get_arg 0
  mov rbx, rax

  match =1, HEAP_FORWARD {
    mov rax, [HEAP_END]
    sub rax, rbx
  }
  match =0, HEAP_FORWARD {
    mov rax, rbx
    sub rax, [HEAP_START]
  }

  ret

; @function free_block
; @description Освобождает блок памяти в куче
; @param block - блок памяти для освобождения
; @example
;   free_block some_block  ; освобождает блок памяти
_function free_block, rax, rbx, rcx, rdx, r8, r11
  get_arg 0
  mov r11, rax

  mov r8d, [r11]
  cmp r8d, HEAP_BLOCK
  je .correct_block

    raw_string "free_block: Ожидался блок кучи"
    error_raw rax
    exit -1

  .correct_block:

  get_heap_offset_by_address r11
  mov r8, rax

  cmp [FIRST_FREE_HEAP_BLOCK], r8
  jne @f
    ret
  @@:

  mov ebx, [r11 + 4*3]
  cmp rbx, 1
  je .not_empty

    ; Перезапись ссылок в свободных блоках, на которые указывают ссылки
    mov ecx, [r11 + 4*3]
    mov edx, [r11 + 4*4]

    cmp ecx, -1
    je @f
      get_heap_address_by_offset rcx
      mov [rax + 4*4], edx
    @@:

    cmp edx, -1
    je @f
      get_heap_address_by_offset rdx
      mov [rax + 4*3], ecx
    @@:

  .not_empty:

  ; Обновление указателя на первый свободный блок
  mov rbx, [FIRST_FREE_HEAP_BLOCK]
  mov [FIRST_FREE_HEAP_BLOCK], r8

  ; Обновление нового первого свободного блока
  mov dword [r11 + 4*3], -1  ; Установка указателя на предыдущий свободный блок (-1 — крайний блок)
  mov       [r11 + 4*4], ebx ; Установка указателя на следущий свободный блок

  ; Обновление предыдущего первого свободного блока
  cmp ebx, -1
  je @f
    get_heap_address_by_offset rbx
    mov [rax + 4*3], r8d ; Установка указателя на предыдущий свободный блок
  @@:

  ret

; @function merge_blocks
; @description Объединяет два пустых соседних блока памяти в куче
; @param block_1 - указатель на заголовок первого блока
; @param block_2 - указатель на заголовок второго блока
; @example
;   merge_blocks block1, block2  ; объединяет два блока памяти
_function merge_blocks, rax, rbx, rcx, rdx, r8
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

  cmp ecx, -1
  je @f
    get_heap_address_by_offset rcx
    mov [rax + 4*4], edx
  @@:

  cmp edx, -1
  je @f
    get_heap_address_by_offset rdx
    mov [rax + 4*3], ecx
  @@:

  get_heap_offset_by_address rbx
  cmp rax, [FIRST_FREE_HEAP_BLOCK]
  jne @f
    mov [FIRST_FREE_HEAP_BLOCK], rdx
  @@:

  ; Удаление заголовка текущего блока
  mov dword [rbx + 4*0], 0
  mov dword [rbx + 4*1], 0
  mov dword [rbx + 4*2], 0
  mov dword [rbx + 4*3], 0
  mov dword [rbx + 4*4], 0

  ret

; @function delete_block
; @description Удаляет блок памяти из кучи
; @param block - указатель на тело блока памяти для удаления
; @example
;   delete_block some_block  ; удаляет блок памяти
_function delete_block, rax, rbx, rcx, r8
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
  mov ecx, [rax + 4*1]
  mov rbx, rax

  cmp ecx, 0
  je @f

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
  mov ecx, [rax + 4*2]
  mov rbx, rax

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

; @function create_block
; @description Создает блок памяти указанного размера в куче
; @param size - размер блока для создания
; @return Указатель на созданный блок памяти
; @example
;   create_block 1024  ; создает блок памяти размером 1024 байта
_function create_block, rbx, rcx, rdx, r8, r9, r10
  get_arg 0

  ; Приведение размера к числу, кратному 8
  add rax, 7
  and rax, -8

  mov r8, rax                      ; Сохранение размера создаваемого блока
  mov rax, [FIRST_FREE_HEAP_BLOCK] ; Запись указателя на первый свободный блок

  ; Цикл для нахождения подходящего блока
  .loop:
    cmp eax, -1
    jne .next

      ; Если блок является последним свободным блоком
      expand_heap                      ; Аллокация новой страницы
      mov rax, [FIRST_FREE_HEAP_BLOCK]

    .next:

    get_heap_address_by_offset rax
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
      mov rbx, rax

      cmp ecx, -1
      je @f
        get_heap_address_by_offset rcx
        mov [rax + 4*4], edx
      @@:

      cmp edx, -1
      je @f
        get_heap_address_by_offset rdx
        mov [rax + 4*3], ecx
      @@:

      ; Установка статуса созданного блока на «занят»
      mov r9, 1
      mov [rbx + 4*3], r9d
      mov [rbx + 4*4], r9d

      ; Проверка, что обработанный блок был первым свободным
      cmp ecx, -1
      jne @f
        mov [FIRST_FREE_HEAP_BLOCK], rdx
      @@:

      mov rax, rbx
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
      mov [rcx + 4*1], r9d ; Размер предыдущего блока (0 — крайний блок, другое — размер)
      mov [rcx + 4*2], ebx ; Размер текущего блока
      mov r9d, [rax + 4*3]
      mov [rcx + 4*3], r9d ; Ссылка на предыдущий свободный блок (0 — крайний блок, 1 — занят, другое — указатель)
      mov r9d, [rax + 4*4]
      mov [rcx + 4*4], r9d ; Ссылка на следующий свободный блок (0 — крайний блок, 1 — занят, другое — указатель)

      ; Установка статуса созданного блока на «занят»
      mov dword [rax + 4*3], 1
      mov dword [rax + 4*4], 1

      mov rbx, rax

      get_heap_offset_by_address rcx
      mov r10, rax

      ; Перезапись ссылок в свободных блоках, на которые указывают ссылки
      mov edx, [rcx + 4*3]
      cmp edx, -1
      je @f
        get_heap_address_by_offset rdx
        mov [rax + 4*4], r10d
      @@:

      mov edx, [rcx + 4*4]
      cmp edx, -1
      je @f
        get_heap_address_by_offset rdx
        mov [rax + 4*3], r10d
      @@:

      get_heap_offset_by_address rbx
      cmp [FIRST_FREE_HEAP_BLOCK], rax
      jne @f
        mov [FIRST_FREE_HEAP_BLOCK], r10
      @@:

      mov rax, rbx
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
    jge @f

    mov [rax + 4*1], ebx
  end repeat

  @@:
  pop rax

  add rax, HEAP_BLOCK_HEADER*4

  ret
