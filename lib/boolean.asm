; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

; @function boolean
; @description
;   Преобразует объект в Логическое значение
;
;   | Тип                 |     Истина     |   Ложь    |
;   | ------------------- | :------------: | :-------: |
;   | Сырое число         | -∞..-1; 1..+∞  |     0     |
;   | Нуль                |       -        |     0     |
;   | Целое число         | -∞..-1; 1..+∞  |     0     |
;   | Вещественное число  | -∞..-0; +0..+∞ |     0     |
;   | Логическое значение |     Истина     |   Ложь    |
;   | Список              |  Длина — не 0  | Длина — 0 |
;   | Строка              |  Длина — не 0  | Длина — 0 |
;   | Словарь             |  Длина — не 0  | Длина — 0 |
;
;   > ∞ — максимальное значение для конкретного типа
; @param value - значение для преобразования
; @return Логическое значене
; @example
;   boolean 1  ; Возвращает Истина
;   boolean 0  ; Возвращает Ложь
;   integer 42
;   boolean rax  ; Возвращает Истина
;   list
;   boolean rax  ; Возвращает Ложь
; @todo Вынести перевод в логическое значение в методы типов
f_boolean:
  get_arg 0
  mov rbx, rax

  cmp rbx, 1
  je .true

  cmp rbx, 0
  je .false

  mov rax, [rbx]

  cmp rax, NULL
  je .false

  cmp rax, INTEGER
  jne .not_integer
    mov rax, [rbx + INTEGER_HEADER*8]
    cmp rax, 0

    je .false
    jmp .true

  .not_integer:

  cmp rax, FLOAT
  jne .not_float
    movsd xmm0, [rbx + FLOAT_HEADER*8]
    movq rax, xmm0
    cmp rax, 0

    je .false
    jmp .true

  .not_float:

  cmp rax, BOOLEAN
  jne .not_boolean
    mov rax, [rbx + BOOLEAN_HEADER*8]
    cmp rax, 0

    je .false
    jmp .true

  .not_boolean:

  cmp rax, LIST
  jne .not_list
    list_length rbx
    cmp rax, 0

    je .false
    jmp .true

  .not_list:

  cmp rax, STRING
  jne .not_string
    string_length rbx
    cmp rax, 0

    je .false
    jmp .true

  .not_string:

  cmp rax, DICTIONARY
  jne .not_dictionary
    dictionary_length rbx
    cmp rax, 0

    je .false
    jmp .true

  .not_dictionary:

  .true:
    mov rbx, 1
    jmp .continue

  .false:
    mov rbx, 0

  .continue:

  create_block BOOLEAN_SIZE*8
  mem_mov [rax + 8*0], BOOLEAN
  mem_mov [rax + 8*1], rbx

  ret

; @function boolean_copy
; @description Копирование Логического значения
; @param boolean - Логическое значение значение для копирования
; @return Копия Логического значения
; @example
;   boolean 1
;   boolean_copy rax  ; Копия со значением Истина
f_boolean_copy:
  get_arg 0
  check_type rax, BOOLEAN
  mov rbx, rax

  create_block BOOLEAN_SIZE*8
  mem_mov [rax + 8*0], BOOLEAN
  mem_mov [rax + 8*1], [rbx + BOOLEAN_HEADER*8]

  ret

; @function boolean_value
; @description Возвращает значение булева объекта в виде сырого числа (Ложь — 0, Истина — 1)
; @param boolean - булево значение
; @return 1 для true, 0 для false
; @example
;   boolean 1
;   boolean_value rax  ; Возвращает 1
f_boolean_value:
  get_arg 0
  check_type rax, BOOLEAN

  mov rax, [rax + BOOLEAN_HEADER*8]
  ret

; @function boolean_not
; @description
;   Возвращает логическое «НЕ» (отрицание) от переданного значения
;
;   | Значение | Результат |
;   | :------: | :-------: |
;   |   Ложь   |  Истина   |
;   |  Истина  |   Ложь    |
; @param boolean - значение для отрицания
; @return Инвертированное логическое значение
; @example
;   boolean 1
;   boolean_not rax  ; Возвращает Ложь
; @todo Переименовать в logical_not и написать с нуля boolean_not
f_boolean_not:
  get_arg 0

  boolean rax
  mov rbx, [rax + BOOLEAN_HEADER*8]
  delete rax

  dec rbx
  neg rbx
  boolean rbx

  ret

; @function boolean_and
; @description
;   Выполняет логическое «И» между двумя значениями
;
;   | Первое | Второе | Результат |
;   | :----: | :----: | :-------: |
;   |  Ложь  |  Ложь  |   Ложь    |
;   |  Ложь  | Истина |   Ложь    |
;   | Истина |  Ложь  |   Ложь    |
;   | Истина | Истина |  Истина   |
; @param boolean_1 - первое значение
; @param boolean_2 - второе значение
; @return Истина, если оба аргумента истинны, иначе — Ложь
; @example
;   boolean 1
;   mov rbx, rax
;   boolean 0
;   boolean_and rbx, rax  ; Вернёт Ложь
; @todo Переименовать в logical_and и написать с нуля boolean_and
f_boolean_and:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  boolean rbx
  mov rbx, [rax + BOOLEAN_HEADER*8]
  delete rax
  cmp rbx, 1
  jne .return_false

  boolean rcx
  mov rbx, [rax + BOOLEAN_HEADER*8]
  delete rax
  cmp rbx, 1
  jne .return_false

  boolean 1
  ret

  .return_false:

  boolean 0
  ret

; @function boolean_or
; @description
;   Выполняет логическое «ИЛИ» между двумя значениями
;
;   | Первое | Второе | Результат |
;   | :----: | :----: | :-------: |
;   |  Ложь  |  Ложь  |   Ложь    |
;   |  Ложь  | Истина |  Истина   |
;   | Истина |  Ложь  |  Истина   |
;   | Истина | Истина |  Истина   |
; @param boolean_1 - первое значение
; @param boolean_2 - второе значение
; @return Истина, если хотя бы один аргумент истиннен, иначе — Ложь
; @example
;   boolean 1
;   mov rbx, rax
;   boolean 0
;   boolean_or rbx, rax  ; возвращает true
; @todo Переименовать в logical_or и написать с нуля boolean_or
f_boolean_or:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  boolean rbx
  mov rbx, [rax + BOOLEAN_HEADER*8]
  delete rax
  cmp rbx, 1
  je .return_true

  boolean rcx
  mov rbx, [rax + BOOLEAN_HEADER*8]
  delete rax
  cmp rbx, 1
  je .return_true

  boolean 0
  ret

  .return_true:

  boolean 1
  ret
