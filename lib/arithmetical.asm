; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

; @function addition
; @description
;   Выполняет сложение двух объектов в зависимости от их типов
;
;   Поддерживаемые пары типов:
;
;   - Целое число: Целое число, Вещественное число
;   - Вещественное число: Целое число, Вещественное число
;   - Список: Список
;   - Строка: Строка
;   - Словарь: Словарь
;
;   Если переданное значение не поддерживается, то произойдёт выход с ошибкой
; @param first - первый операнд для сложения
; @param second - второй операнд для сложения
; @return Результат сложения (тип зависит от операндов)
; @example
;   integer 5
;   mov rbx, rax
;   integer 3
;   addition rbx, rax  ; Вернёт 8
;   string "Hello"
;   mov rbx, rax
;   string "World"
;   addition rbx, rax  ; Вернёт "HelloWorld"
f_addition:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  mov rdx, [rbx]
  mov r8,  [rcx]

  cmp rdx, INTEGER
  jne .not_integer
    cmp r8, INTEGER
    jne @f
      integer_add rbx, rcx
      ret
    @@:

    cmp r8, FLOAT
    jne @f
      integer_to_float rbx
      float_add rax, rcx
      ret
    @@:
  .not_integer:

  cmp rdx, FLOAT
  jne .not_float
    cmp r8, FLOAT
    jne @f
      float_add rbx, rcx
      ret
    @@:

    cmp r8, INTEGER
    jne @f
      integer_to_float rcx
      float_add rbx, rax
      ret
    @@:
  .not_float:

  cmp rdx, LIST
  jne .not_list
    cmp r8, LIST
    jne @f
      list_add rbx, rcx
      ret
    @@:
  .not_list:

  cmp rdx, STRING
  jne .not_string
    cmp r8, STRING
    jne @f
      string_add rbx, rcx
      ret
    @@:
  .not_string:

  cmp rdx, DICTIONARY
  jne .not_dictionary
    cmp r8, DICTIONARY
    jne @f
      dictionary_add rbx, rcx
      ret
    @@:
  .not_dictionary:

  string "Операция сложения не может быть проведена между типами"
  mov rbx, rax
  string "и"
  mov rcx, rax
  type_to_string rdx
  mov rdx, rax
  type_to_string r8
  mov r8, rax

  list
  list_append_link rax, rbx
  list_append_link rax, rdx
  list_append_link rax, rcx
  list_append_link rax, r8
  error rax
  exit -1

; @function subtraction
; @description
;   Выполняет вычитание двух объектов в зависимости от их типов
;
;   Поддерживаемые пары типов:
;
;   - Целое число: Целое число, Вещественное число
;   - Вещественное число: Целое число, Вещественное число
;
;   Если переданное значение не поддерживается, то произойдёт выход с ошибкой
; @param first - уменьшаемое
; @param second - вычитаемое
; @return Результат вычитания (тип зависит от операндов)
; @example
;   integer 10
;   mov rbx, rax
;   integer 3
;   subtraction rbx, rax  ; Вернёт 7
f_subtraction:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  mov rdx, [rbx]
  mov r8,  [rcx]

  cmp rdx, INTEGER
  jne .not_integer
    cmp r8, INTEGER
    jne @f
      integer_sub rbx, rcx
      ret
    @@:

    cmp r8, FLOAT
    jne @f
      integer_to_float rbx
      float_sub rax, rcx
      ret
    @@:
  .not_integer:

  cmp rdx, FLOAT
  jne .not_float
    cmp r8, FLOAT
    jne @f
      float_sub rbx, rcx
      ret
    @@:

    cmp r8, INTEGER
    jne @f
      integer_to_float rcx
      float_sub rbx, rax
      ret
    @@:
  .not_float:

  string "Операция вычитания не может быть проведена между типами"
  mov rbx, rax
  string "и"
  mov rcx, rax
  type_to_string rdx
  mov rdx, rax
  type_to_string r8
  mov r8, rax

  list
  list_append_link rax, rbx
  list_append_link rax, rdx
  list_append_link rax, rcx
  list_append_link rax, r8
  error rax
  exit -1

; @function multiplication
; @description
;   Выполняет умножение двух объектов в зависимости от их типов
;
;   Поддерживаемые пары типов:
;
;   - Целое число: Целое число, Вещественное число, Список, Строка
;   - Вещественное число: Целое число, Вещественное число
;   - Строка: Целое число
;   - Список: Целое число
;
;   Если переданное значение не поддерживается, то произойдёт выход с ошибкой
; @param first - первый множитель
; @param second - второй множитель
; @return Результат умножения (тип зависит от операндов)
; @example
;   integer 6
;   mov rbx, rax
;   integer 7
;   multiplication rbx, rax  ; Вернёт 42
f_multiplication:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  mov rdx, [rbx]
  mov r8,  [rcx]

  cmp rdx, INTEGER
  jne .not_integer
    cmp r8, INTEGER
    jne @f
      integer_mul rbx, rcx
      ret
    @@:

    cmp r8, FLOAT
    jne @f
      integer_to_float rbx
      float_mul rax, rcx
      ret
    @@:

    cmp r8, STRING
    jne @f
      string_mul rcx, rbx
      ret
    @@:

    cmp r8, LIST
    jne @f
      list_mul rcx, rbx
      ret
    @@:
  .not_integer:

  cmp rdx, FLOAT
  jne .not_float
    cmp r8, FLOAT
    jne @f
      float_mul rbx, rcx
      ret
    @@:

    cmp r8, INTEGER
    jne @f
      integer_to_float rcx
      float_mul rbx, rax
      ret
    @@:
  .not_float:

  cmp rdx, STRING
  jne .not_string
    cmp r8, INTEGER
    jne @f
      string_mul rbx, rcx
      ret
    @@:
  .not_string:

  cmp rdx, LIST
  jne .not_list
    cmp r8, INTEGER
    jne @f
      list_mul rbx, rcx
      ret
    @@:
  .not_list:

  string "Операция умножения не может быть проведена между типами"
  mov rbx, rax
  string "и"
  mov rcx, rax
  type_to_string rdx
  mov rdx, rax
  type_to_string r8
  mov r8, rax

  list
  list_append_link rax, rbx
  list_append_link rax, rdx
  list_append_link rax, rcx
  list_append_link rax, r8
  error rax
  exit -1

; @function division
; @description
;   Выполняет деление двух объектов в зависимости от их типов
;
;   Поддерживаемые пары типов:
;
;   - Целое число: Целое число, Вещественное число
;   - Вещественное число: Целое число, Вещественное число
;
;   Если переданное значение не поддерживается, то произойдёт выход с ошибкой
; @param first - делимое
; @param second - делитель
; @return Результат деления (тип зависит от операндов)
; @example
;   integer 10
;   mov rbx, rax
;   integer 3
;   division rbx, rax  ; Вернёт 3.333...
f_division:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  mov rdx, [rbx]
  mov r8,  [rcx]

  cmp rdx, INTEGER
  jne .not_integer
    cmp r8, INTEGER
    jne @f
      integer_div rbx, rcx
      ret
    @@:

    cmp r8, FLOAT
    jne @f
      integer_to_float rbx
      float_div rax, rcx
      ret
    @@:
  .not_integer:

  cmp rdx, FLOAT
  jne .not_float
    cmp r8, FLOAT
    jne @f
      float_div rbx, rcx
      ret
    @@:

    cmp r8, INTEGER
    jne @f
      integer_to_float rcx
      float_div rbx, rax
      ret
    @@:
  .not_float:

  string "Операция деления не может быть проведена между типами"
  mov rbx, rax
  string "и"
  mov rcx, rax
  type_to_string rdx
  mov rdx, rax
  type_to_string r8
  mov r8, rax

  list
  list_append_link rax, rbx
  list_append_link rax, rdx
  list_append_link rax, rcx
  list_append_link rax, r8
  error rax
  exit -1

; @function negate
; @description
;   Возвращает отрицательное значение объекта. Если переданное значение не поддерживается, то произойдёт выход с ошибкой
; @param value - объект для изменения знака
; @return Объект с противоположным знаком
; @example
;   integer 42
;   negate rax  ; Возвращает -42
f_negate:
  get_arg 0

  mov rbx, [rax]
  cmp rbx, INTEGER
  jne @f
    integer_neg rax
    ret
  @@:

  mov rbx, [rax]
  cmp rbx, FLOAT
  jne @f
    float_neg rax
    ret
  @@:

  string "Операция негативизации не может быть проведена над типом "
  mov rbx, rax
  type_to_string rdx
  mov rcx, rax

  list
  list_append_link rax, rbx
  list_append_link rax, rcx
  error rax
  exit -1
