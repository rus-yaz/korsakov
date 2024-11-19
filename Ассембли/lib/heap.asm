section "data" writable
  HEAP_SIZE   dq 0x1000             ; Начальный размер кучи
  HEAP_START  rq 1                  ; Указатель на начало кучи
  HEAP_END    rq 1                  ; Указатель на конец кучи

  HEAP_ALLOCATION_ERROR               db "Ошибка аллокации кучи", 10, 0

section "write_header" executable

; Установка заголовка блока
;
; Аргументы:
;   addr        — указатель на заголовок блока
;   header_sign — метка заголовка блока
;   size        — размер тела блока
;   prev_size   — размер тела предыдущего блока
;   state       — состояние использования блока

macro write_header addr, header_sign, size, prev_size, state {
  mem_mov [addr + 8*0], header_sign
  mem_mov [addr + 8*1], size
  mem_mov [addr + 8*2], prev_size
  mem_mov [addr + 8*3], state
}

section "allocate_heap" executable

; Алллокация кучи с сохранением указателей на начало и конец кучи
;
; Аргументы:
;   HEAP_SIZE — размер выделяемой кучи
;
; Результат:
;   HEAP_START — указатель на начало кучи
;   HEAP_END   — указатель на начало кучи

macro allocate_heap {
  enter

  call f_allocate_heap

  leave
}

f_allocate_heap:
  sys_mmap 0,\                                  ; Адрес (если 0, находится автоматически)
           [HEAP_SIZE],\                        ; Количество памяти для аллокации
           PROT_READ + PROT_WRITE + PROT_EXEC,\ ; Права (PROT_READ | PROT_WRITE)
           MAP_SHARED + MAP_ANONYMOUS,\         ; MAP_ANONYMOUS | MAP_PRIVATE
           0,\                                  ; Файл дескриптор (ввод)
           0                                    ; Смещение относительно начала файла (с начала файла)

  ; Проверка корректности выделения памяти
  test rax, rax
  check_error js, HEAP_ALLOCATION_ERROR

  ; Сохранение указателя на начало кучи
  mov [HEAP_START], rax

  mov rbx, [HEAP_SIZE]                       ; Запись размера кучи
  sub rbx, 8*4                               ; Учёт размера заголовка блока
  write_header rax, HEADER_SIGN, rbx, 0, 0 ; Запись заголовка начального блока

  mov rax, [HEAP_START] ; Запись указателя на начало кучи
  add rax, [HEAP_SIZE]  ; Смещение на размер кучи
  mov [HEAP_END], rax   ; Сохранение указателя на конец кучи

  ret

section "expand_heap" executable

; Расширение кучи
;
; Аргументы:
;   size — количество памяти, на которое необходимо расширить кучу
;
; Результат:
;   HEAP_START — указатель на начало кучи
;   HEAP_END   — указатель на начало кучи

macro expand_heap size {
  enter size

  call f_expand_heap

  leave
}

f_expand_heap:
  ; Сохранение количества памяти для расширения
  mov rcx, rax

  ; Получение итогового размера кучи
  add rax, [HEAP_SIZE]
  mov [HEAP_SIZE], rax

  ; Взятие указателя на начало кучи
  mov rax, [HEAP_START]

  ; Аллокация новой кучи
  allocate_heap

  ; RDI — указатель на новую кучу
  ; RSI — указатель на старую кучу
  mov rdi, [HEAP_START]
  mov rsi, rax

  ; Сохранение указателя на старую кучу
  mov r8, rsi

  ; Получение размера старой кучи
  mov rax, [HEAP_SIZE]
  sub rax, rcx

  ; Сохранение размера старой кучи
  mov r9, rax

  ; Расчёт количества операций для копирования
  push rax
  mov rdx, 0
  mov rcx, 8

  idiv rcx
  mov rcx, rax
  pop rax

  ; Копирование данных со старой кучи в новую
  rep movsq

  ; Укзатель на начало новой кучи
  mov rbx, [HEAP_START]

  ; Поиск последнего блока кучи
  .while:
    mov rcx, rbx
    add rbx, [rbx + 8*1]
    add rbx, 8*4

    mov rdx, [rbx]
    mov rbx, HEADER_SIGN
    cmp rdx, rbx
    je .while

  ; Расширение последнего блока до конца кучи
  mov rbx, [rcx + 8*1]
  add rbx, rax
  mov [rcx + 8*1], rbx

  ; Деаллокация старой кучи
  sys_munmap r8,\         ; Указатель на старую кучу
             r9           ; Размер старой кучи

  ret

section "create_block" executable

; Аллоакция места на куче для блока определённого размера
;
; Аргументы:
;   size — количество памяти, выделяемой на тело блока
;
; Результат:
;   rax — указатель на тело блока

macro create_block size {
  enter size

  call f_create_block

  return
}

f_create_block:
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

  mov r8, rax ; Сохранение размера создаваемого блока
  mov rax, [HEAP_START] ; Запись указателя на начало кучи в RAX

  ; Цикл для нахождения подходящего блока
  .do:
    ; Проверка типа заголовка
    check_type rax, HEADER_SIGN, EXPECTED_HEAP_BLOCK_ERROR

    ; Получение информации о блоке
    mov rdx, [rax + 8*3]          ; Получение статуса использования блока
    cmp rdx, 0
    jne .find_new_block           ; Если блок используется, искать новый блок

    ; Сравнение выделенного размера и размера блока
    mov rdx, [rax + 8*1]          ; Получение размера блока
    cmp rdx, r8                   ; Сравнение с требуемым размером
    jge .found_block              ; Если блок достаточно большой, перейти к .found_block

    .find_new_block:
      ; Смещение адреса на размер блока и заголовка
      add rax, [rax + 8*1]          ; Смещение на размер блока
      add rax, HEAP_BLOCK_HEADER * 8 ; Смещение на размер заголовка
      jmp .do                       ; Переход к началу цикла

    .found_block:
      ; Вычисление адреса нового блока
      mov rbx, rax
      add rbx, HEAP_BLOCK_HEADER * 8 ; Смещение на заголовок
      add rbx, r8                   ; Смещение на размер нового блока

      ; Проверка состояния блока
      mov rcx, [rbx + 8*3]          ; Получение статуса нового блока
      test rcx, 1                    ; Проверка, используется ли блок
      jnz .find_new_block           ; Если блок используется, искать новый блок

  mem_mov [rax + 8*3], 1 ; Изменение состояния текущего блока на используемое

  mov rcx, [rax + 8*1]    ; Сохранение размера текущего блока в RCX
  sub rcx, r8             ; Вычисление размера текущего блока в RCX
  sub rcx, 8*4            ; Учёт размера заголовка
  mem_mov [rax + 8*1], r8 ; Изменение SIZE у предыдущего блока

  ; KEY
  ; SIZE
  ; PREV_SIZE
  ; STATE
  write_header rbx, HEADER_SIGN, rcx, r8, 0

  add rax, 8*4

  ret

section "delete_block" executable

; Удаление блока по указателю
;
; Аргументы:
;   block_addr — указатель на блок
macro delete_block block_addr {
  enter block_addr

  call f_delete_block

  leave
}

f_delete_block:
  sub rax, 8*4

  ; Если заголовок не найден, выйти с ошибкой
  check_type rax, HEADER_SIGN, EXPECTED_HEAP_BLOCK_ERROR

  ; Объединение текущего блока и следующего, если он не используется

  ; Нахождение следующего блока
  mov r8, rax
  add rax, 8*4
  add rax, [r8 + 8*1]

  ; Если заголовок не найден (блока не существует), пропустить изменение блоков
  mov rbx, [rax]
  mov rcx, HEADER_SIGN
  cmp rbx, rcx
  jne .skip_current_and_next_blocks_merging

  ; Если следующий блок используется, пропустить изменение блоков
  mov rbx, [rax + 8*3]
  test rbx, 1
  jne .skip_current_and_next_blocks_merging

    ; Увеличение размера текущего блока на размер удаляемого блока
    mov rcx, [r8 + 8*1]
    add rcx, [rax + 8*1]
    add rcx, 8*4
    mov [r8 + 8*1], rcx

    ; Удаление заголовка удаляемого блока
    write_header rax, 0, 0, 0, 0

  .skip_current_and_next_blocks_merging:

  ; Нахождение предыдущего блока
  mov rax, r8
  sub rax, [r8 + 8*2]
  sub rax, 8*4

  ; Проверка нахождения блока внутри кучи
  cmp rax, [HEAP_START]
  jl .skip_previous_and_current_blocks_merging

  ; Если заголовок не найден (блока не существует), пропустить изменение блоков
  mov rbx, [rax]
  mov rcx, HEADER_SIGN
  cmp rbx, rcx
  jne .skip_previous_and_current_blocks_merging

  ; Если следующий блок используется, пропустить изменение блоков
  mov rbx, [rax + 8*3]
  test rbx, 1
  jne .skip_previous_and_current_blocks_merging

    ; Увеличение размера предыдущего блока на размер удаляемого блока
    mov rcx, [r8 + 8*1]
    add rcx, [rax + 8*1]
    add rcx, 8*4
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
  add rcx, 8*4

  ; Проверка нахождения блока внутри кучи
  cmp rcx, [HEAP_END]
  jge .skip_next_next_block_modifying

  ; Если заголовок не найден (блока не существует), пропустить изменение блоков
  mov rax, [rcx]
  mov rbx, HEADER_SIGN
  cmp rax, rbx
  jne .skip_next_next_block_modifying

    ; Изменение PREV_SIZE для дальше идущего блока
    mem_mov [rcx + 8*2], [r8 + 8*1]

  .skip_next_next_block_modifying:

  ret
