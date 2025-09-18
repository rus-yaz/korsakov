; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

; @function init_heap
; @description Создание кучи
; @example
;   init_heap  ; Создаёт кучу
_function init_heap, rax, rbx
  invoke HeapCreate,\
         0,\
         0,\
         0

  invoke HeapAlloc,\
         rax,\
         HEAP_ZERO_MEMORY,\
         WINDOWS_HEAP_SIZE

  ; Проверка корректности выделения памяти
  cmp rax, 0
  check_error je, "init_heap: Ошибка аллокации"

  mov [HEAP_START], rax

  mov dword [rax + 4*0], HEAP_BLOCK                      ; Идентификатор
  mov dword [rax + 4*1], 0                               ; Размер предыдущего блока (0 — крайний блок, другое — размер)
  mov dword [rax + 4*2], WINDOWS_HEAP_SIZE - HEAP_BLOCK_HEADER*4 ; Размер текущего блока
  mov dword [rax + 4*3], -1                              ; Ссылка на предыдущий свободный блок (-1 — крайний блок, 1 — занят, другое — указатель)
  mov dword [rax + 4*4], -1                              ; Ссылка на следующий свободный блок (-1 — крайний блок, 1 — занят, другое — указатель)

  mov [HEAP_START], rax ; Сохранение указателя на начало кучи
  mov rbx, WINDOWS_HEAP_SIZE    ; Размер страницы памяти

  ; Сохранение относительного указателя на первый свободный блок
  mov [FIRST_FREE_HEAP_BLOCK], 0

  add rbx, [HEAP_START]
  mov [HEAP_END], rbx   ; Сохранение указателя на конец кучи

  ret

; @function expand_heap
; @description
;   Выделяет новую страницу на кучи
;
;   ! В текущей реалзиции для Windows используется однократное выделение большого объёма памяти
; @example
;   expand_heap
_function expand_heap
  raw_string "expand_heap: не реализовано"
  print_raw rax
  sys_exit 200
