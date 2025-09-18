; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

; @function init_heap
; @description Создание кучи
; @example
;   init_heap  ; Создаёт кучу
_function init_heap, rax, rbx, r11
  push r11
  sys_mmap 0,\                                  ; Адрес (если 0, находится автоматически)
           PAGE_SIZE,\                          ; Количество памяти для аллокации
           PROT_READ + PROT_WRITE + PROT_EXEC,\ ; Права (PROT_READ | PROT_WRITE)
           MAP_SHARED + MAP_ANONYMOUS,\         ; MAP_ANONYMOUS | MAP_PRIVATE
           0,\                                  ; Файл дескриптор (ввод)
           0                                    ; Смещение относительно начала файла (с начала файла)
  pop r11

  ; Проверка корректности выделения памяти
  cmp rax, 0
  check_error je, "init_heap: Ошибка аллокации"

  mov dword [rax + 4*0], HEAP_BLOCK                      ; Идентификатор
  mov dword [rax + 4*1], 0                               ; Размер предыдущего блока (0 — крайний блок, другое — размер)
  mov dword [rax + 4*2], PAGE_SIZE - HEAP_BLOCK_HEADER*4 ; Размер текущего блока
  mov dword [rax + 4*3], -1                              ; Ссылка на предыдущий свободный блок (-1 — крайний блок, 1 — занят, другое — указатель)
  mov dword [rax + 4*4], -1                              ; Ссылка на следующий свободный блок (-1 — крайний блок, 1 — занят, другое — указатель)

  mov [HEAP_START], rax ; Сохранение указателя на начало кучи
  mov rbx, PAGE_SIZE    ; Размер страницы памяти

  ; Сохранение относительного указателя на первый свободный блок
  mov [FIRST_FREE_HEAP_BLOCK], rbx

  add rbx, [HEAP_START]
  mov [HEAP_END], rbx   ; Сохранение указателя на конец кучи

  ret

; @function expand_heap
; @description Выделяет новую страницу на кучи
; @example
;   expand_heap
_function expand_heap, rax, rbx, r11
  push r11
  sys_mmap 0,\                                  ; Адрес (если 0, находится автоматически)
           PAGE_SIZE,\                          ; Количество памяти для аллокации
           PROT_READ + PROT_WRITE + PROT_EXEC,\ ; Права (PROT_READ | PROT_WRITE)
           MAP_SHARED + MAP_ANONYMOUS,\         ; MAP_ANONYMOUS | MAP_PRIVATE
           0,\                                  ; Файл дескриптор (ввод)
           0                                    ; Смещение относительно начала файла (с начала файла)
  pop r11

  ; Проверка корректности выделения памяти
  cmp rax, 0
  check_error je, "expand_heap: Ошибка аллокации"

  mov dword [rax + 4*0], HEAP_BLOCK                        ; Идентификатор
  mov dword [rax + 4*1], 0                                 ; Размер предыдущего блока (0 — крайний блок, другое — размер)
  mov dword [rax + 4*2], PAGE_SIZE - HEAP_BLOCK_HEADER * 4 ; Размер текущего блока
  mov dword [rax + 4*3], -1                                ; Ссылка на предыдущий свободный блок (-1 — крайний блок, 1 — занят, другое — указатель)
  mov dword [rax + 4*4], -1                                ; Ссылка на следующий свободный блок (-1 — крайний блок, 1 — занят, другое — указатель)
  mov rbx, rax

  ; Сохранение указателя на новый край кучи
  mov [HEAP_START], rax

  add rbx, HEAP_BLOCK_HEADER*4
  delete_block rbx

  ret
