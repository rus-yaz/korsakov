; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

; @function integer
; @description Создает объект целого числа
; @param value - числовое значение для создания целого числа
; @return Объект целого числа
; @example
;   integer 42  ; создает целое число 42
;   integer -10  ; создает целое число -10
_function integer, rbx
  get_arg 0
  mov rbx, rax

  create_block INTEGER_SIZE*8

  mem_mov [rax + 8*0], INTEGER
  mem_mov [rax + 8*1], rbx

  ret

; @function string_to_integer
; @description Преобразует строку в целое число
; @param integer - строка для преобразования в целое число
; @return Целое число, полученное из строки
; @example
;   string "123"
;   string_to_integer rax  ; возвращает целое число 123
;   string "-456"
;   string_to_integer rax  ; возвращает целое число -456
_function string_to_integer, rbx, rcx, rdx, r8, r9
  get_arg 0
  check_type rax, STRING
  mov rbx, rax

  string_length rbx
  cmp rax, 0
  jne .valid_length

    string "string_to_integer: Длина строки должна быть больше нуля"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .valid_length:

  string_copy rbx
  mov rbx, rax
  mem_mov [rbx + 8*0], LIST

  mov rdx, 0

  integer 0
  mov r8, rax

  list_length rbx
  integer rax
  mov r9, rax

  integer 0
  list_get_link rbx, rax
  mov rcx, rax
  integer "-"
  is_equal rax, rcx
  boolean_value rax
  cmp rax, 1
  jne @f
    integer_inc r8
    mov rcx, 0
  @@:

  .while:
    is_equal r8, r9
    boolean_value rax
    cmp rax, 1
    je .end_while

    imul rdx, 10

    list_get_link rbx, r8
    mov rax, [rax + INTEGER_HEADER*8]
    sub rax, "0"
    add rdx, rax

    integer_inc r8
    jmp .while

  .end_while:

  integer rdx
  mov rdx, rax

  cmp rcx, 0
  jne @f
    integer_neg rdx
  @@:

  ret

; @function integer_copy
; @description Создает копию целого числа
; @param int - целое число для копирования
; @return Копия целого числа
; @example
;   integer 42
;   integer_copy rax  ; создает копию числа 42
_function integer_copy, rbx
  get_arg 0
  check_type rax, INTEGER
  mov rbx, [rax + 8*1]

  create_block INTEGER_SIZE*8
  mem_mov [rax + 8*0], INTEGER
  mem_mov [rax + 8*1], rbx

  ret

; @function integer_neg
; @description Возвращает отрицательное значение целого числа
; @param int - целое число для изменения знака
; @return Целое число с противоположным знаком
; @example
;   integer 42
;   integer_neg rax  ; возвращает -42
_function integer_neg
  get_arg 0
  check_type rax, INTEGER

  mov rax, [rax + INTEGER_HEADER * 8]
  neg rax
  integer rax

  ret

; @function integer_inc
; @description Увеличивает целое число на 1
; @param int - целое число для увеличения
; @return int - Увеличенное число
; @example
;   integer 5
;   integer_inc rax  ; изменяет число на 6
_function integer_inc, rbx
  get_arg 0
  check_type rax, INTEGER

  mov rbx, [rax + INTEGER_HEADER * 8]
  inc rbx
  mov [rax + INTEGER * 8], rbx

  ret

; @function integer_dec
; @description Уменьшает целое число на 1
; @param int - целое число для уменьшения
; @return int - уменьшенное число
; @example
;   integer 5
;   integer_dec rax  ; изменяет число на 4
_function integer_dec, rbx
  get_arg 0
  check_type rax, INTEGER

  mov rbx, [rax + INTEGER_HEADER * 8]
  dec rbx
  mov [rax + INTEGER * 8], rbx

  ret

; @function integer_add
; @description Складывает два целых числа и возвращает новый объект с результатом
; @param int_1 - первое целое число для сложения
; @param int_2 - второе целое число для сложения
; @return Новое целое число, равное сумме аргументов
; @example
;   integer 5
;   mov rbx, rax
;   integer 3
;   integer_add rbx, rax  ; вернет 8
_function integer_add, rbx, rcx
  get_arg 1
  mov rbx, rax
  get_arg 0

  check_type rax, INTEGER
  check_type rbx, INTEGER

  mov rcx, [rax + INTEGER_HEADER*8]
  add rcx, [rbx + INTEGER_HEADER*8]

  integer rcx

  ret

; @function integer_sub
; @description Вычитает второе целое число из первого
; @param int_1 - уменьшаемое целое число
; @param int_2 - вычитаемое целое число
; @return Новое целое число, равное разности аргументов
; @example
;   integer 10
;   mov rbx, rax
;   integer 3
;   integer_sub rbx, rax  ; вернет 7
_function integer_sub, rbx, rcx
  get_arg 1
  mov rbx, rax
  get_arg 0

  check_type rax, INTEGER
  check_type rbx, INTEGER

  mov rcx, [rax + INTEGER_HEADER*8]
  sub rcx, [rbx + INTEGER_HEADER*8]

  integer rcx
  ret

; @function integer_mul
; @description Умножает два целых числа
; @param int_1 - первое целое число для умножения
; @param int_2 - второе целое число для умножения
; @return Новое целое число, равное произведению аргументов
; @example
;   integer 6
;   mov rbx, rax
;   integer 7
;   integer_mul rbx, rax  ; вернет 42
_function integer_mul, rbx, rcx
  get_arg 1
  mov rbx, rax
  get_arg 0

  check_type rax, INTEGER
  check_type rbx, INTEGER

  mov rcx,  [rax + INTEGER_HEADER*8]
  imul rcx, [rbx + INTEGER_HEADER*8]

  integer rcx
  ret

; @function integer_div
; @description Делит первое целое число на второе (возвращает вещественное число)
; @param int_1 - делимое целое число
; @param int_2 - делитель целое число
; @return Вещественное число, равное частному аргументов
; @example
;   integer 10
;   mov rbx, rax
;   integer 3
;   integer_div rbx, rax  ; вернет 3.333...
_function integer_div, rbx, rcx
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, INTEGER
  check_type rcx, INTEGER

  mov rax, [rcx + INTEGER_HEADER*8]
  cmp rax, 0
  jne .correct_argument
    raw_string "integer_div: Нельзя делить на 0"
    error_raw rax
    exit -1
  .correct_argument:

  pushsd 0, 1
  cvtsi2sd xmm0, [rbx + INTEGER_HEADER*8]
  cvtsi2sd xmm1, [rcx + INTEGER_HEADER*8]

  divsd xmm0, xmm1

  float
  movsd [rax + FLOAT_HEADER*8], xmm0

  popsd 1, 0

  ret

; @function float_to_integer
; @description Преобразует вещественное число в целое (отбрасывает дробную часть)
; @param float - вещественное число для преобразования
; @return Целое число, полученное из вещественного
; @example
;   float 3.7
;   float_to_integer rax  ; возвращает 3
_function float_to_integer, rbx
  get_arg 0
  check_type rax, FLOAT

  cvttsd2si rbx, [rax + FLOAT_HEADER*8]

  integer 0
  mov [rax + INTEGER_HEADER*8], rbx

  ret
