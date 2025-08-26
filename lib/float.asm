; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

; @function buffer_to_float
; @description Преобразует буфер в вещественное число
; @param buffer - буфер для преобразования в вещественное число
; @return Вещественное число, полученное из буфера
; @example
;   raw_float 3.14
;   buffer_to_float rax  ; возвращает вещественное число 3.14
_function buffer_to_float, rbx
  get_arg 0
  mov rbx, rax

  create_block FLOAT_SIZE*8

  mem_mov   [rax + 8*0], FLOAT
  mem_movsd [rax + 8*1], [rbx]

  ret

; @function float_copy
; @description Создает копию вещественного числа
; @param float - вещественное число для копирования
; @return Копия вещественного числа
; @example
;   float 3.14
;   float_copy rax  ; создает копию числа 3.14
_function float_copy, rbx
  get_arg 0
  mov rbx, rax

  check_type rbx, FLOAT

  float
  mem_movsd [rax + 8*1], [rbx + 8*1]

  ret

; @function float_add
; @description Складывает два вещественных числа
; @param float_1 - первое вещественное число для сложения
; @param float_2 - второе вещественное число для сложения
; @return Новое вещественное число, равное сумме аргументов
; @example
;   float 3.14
;   mov rbx, rax
;   float 2.86
;   float_add rbx, rax  ; вернет 6.0
_function float_add, rbx, rcx
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, FLOAT
  check_type rcx, FLOAT

  pushsd 0, 1

  movsd xmm0, [rbx + FLOAT_HEADER*8]
  movsd xmm1, [rcx + FLOAT_HEADER*8]
  addsd xmm0, xmm1

  float
  movsd [rax + FLOAT_HEADER*8], xmm0

  popsd 1, 0

  ret

; @function float_sub
; @description Вычитает второе вещественное число из первого
; @param float_1 - уменьшаемое вещественное число
; @param float_2 - вычитаемое вещественное число
; @return Новое вещественное число, равное разности аргументов
; @example
;   float 5.5
;   mov rbx, rax
;   float 2.3
;   float_sub rbx, rax  ; вернет 3.2
_function float_sub, rbx, rcx
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, FLOAT
  check_type rcx, FLOAT

  pushsd 0, 1

  movsd xmm0, [rbx + FLOAT_HEADER*8]
  movsd xmm1, [rcx + FLOAT_HEADER*8]
  subsd xmm0, xmm1

  float
  movsd [rax + FLOAT_HEADER*8], xmm0

  popsd 1, 0

  ret

; @function float_mul
; @description Умножает два вещественных числа
; @param float_1 - первое вещественное число для умножения
; @param float_2 - второе вещественное число для умножения
; @return Новое вещественное число, равное произведению аргументов
; @example
;   float 3.0
;   mov rbx, rax
;   float 2.5
;   float_mul rbx, rax  ; вернет 7.5
_function float_mul, rbx, rcx
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, FLOAT
  check_type rcx, FLOAT

  pushsd 0, 1

  movsd xmm0, [rbx + FLOAT_HEADER*8]
  movsd xmm1, [rcx + FLOAT_HEADER*8]
  mulsd xmm0, xmm1

  float
  movsd [rax + FLOAT_HEADER*8], xmm0

  popsd 1, 0

  ret

; @function float_div
; @description Делит первое вещественное число на второе
; @param float_1 - делимое вещественное число
; @param float_2 - делитель вещественное число
; @return Новое вещественное число, равное частному аргументов
; @example
;   float 10.0
;   mov rbx, rax
;   float 3.0
;   float_div rbx, rax  ; вернет 3.333...
_function float_div, rbx, rcx
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, FLOAT
  check_type rcx, FLOAT

  pushsd 0, 1

  movsd xmm0, [rbx + FLOAT_HEADER*8]
  movsd xmm1, [rcx + FLOAT_HEADER*8]

  raw_float 0
  comisd xmm1, [rax]
  jne .correct_argument
    raw_string "float_div: Нельзя делить на 0"
    error_raw rax
    exit -1
  .correct_argument:

  divsd xmm0, xmm1

  float
  movsd [rax + FLOAT_HEADER*8], xmm0

  popsd 1, 0

  ret

; @function float_neg
; @description Возвращает отрицательное значение вещественного числа
; @param float - вещественное число для изменения знака
; @return Вещественное число с противоположным знаком
; @example
;   float 3.14
;   float_neg rax  ; возвращает -3.14
_function float_neg
  get_arg 0
  check_type rax, FLOAT

  pushsd 0

  movsd xmm0, [rax + FLOAT_HEADER * 8]
  raw_float -1.0

  movsd xmm1, [rax]
  mulsd xmm0, xmm1

  float
  movsd [rax + FLOAT_HEADER*8], xmm0

  popsd 0

  ret

; @function integer_to_float
; @description Преобразует целое число в вещественное
; @param integer - целое число для преобразования
; @return Вещественное число, полученное из целого
; @example
;   integer 42
;   integer_to_float rax  ; возвращает 42.0
_function integer_to_float
  get_arg 0
  check_type rax, INTEGER

  pushsd 0
  cvtsi2sd xmm0, [rax + INTEGER_HEADER*8]

  float
  movsd [rax + FLOAT_HEADER*8], xmm0

  popsd 0

  ret

; @function string_to_float
; @description Преобразует строку в вещественное число
; @param string - строка для преобразования в вещественное число
; @return Вещественное число, полученное из строки
; @example
;   string "3,14"
;   string_to_float rax  ; возвращает вещественное число 3.14
_function string_to_float, rbx, rcx, rdx, r8, r9, r10
  get_arg 0
  mov rbx, rax

  check_type rbx, STRING

  string ""
  mov rcx, rax

  mov rdx, 0

  string ","
  mov r8, rax

  .while:
    string_length rbx
    cmp rax, rdx
    jne .correct_length
      string "Не найден разделитель целой и вещественной частей (`,`)"
      mov rbx, rax
      list
      list_append_link rax, rbx
      error rax
      exit -1
    .correct_length:

    integer rdx
    string_get_link rbx, rax
    mov r9, rax

    is_equal r8, r9
    boolean_value rax
    cmp rax, 1
    je .end_while

    is_digit r9
    cmp rax, 1
    je .correct_number
      string "Некорректный символ: ожидалась цифра, получено — `"
      string_extend_links rax, r9
      mov rbx, rax
      string "`"
      string_extend_links rbx, rax
      list
      list_append_link rax, rbx
      error rax
      exit -1
    .correct_number:

    string_extend_links rcx, r9
    inc rdx
    jmp .while
  .end_while:

  inc rdx
  integer rdx

  string ""
  mov r8, rax

  .while_real:
    string_length rbx
    cmp rdx, rax
    je .end_while_real

    integer rdx
    string_get_link rbx, rax
    mov r9, rax

    is_digit r9
    cmp rax, 1
    je .continue
      string "Некорректный символ: ожидалась цифра, получено — `"
      string_extend_links rax, r9
      mov rbx, rax
      string "`"
      string_extend_links rbx, rax
      list
      list_append_link rax, rbx
      error rax
      exit -1
    .continue:

    string_extend_links r8, r9
    inc rdx
    jmp .while_real
  .end_while_real:

  string_length r8
  mov r9, rax

  integer 10
  mov r10, rax

  integer 1
  @@:
    cmp r9, 0
    je @f

    integer_mul rax, r10

    dec r9
    jmp @b
  @@:

  integer_to_float rax
  mov r9, rax

  string_length rcx
  cmp rax, 0
  jne .correct_first_part
    string "Перед разделителем целой и вещественной части ничего нет"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1
  .correct_first_part:

  string_length r8
  cmp rax, 0
  jne .correct_last_part
    string "После разделителя целой и вещественной части ничего нет"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1
  .correct_last_part:

  string_to_integer rcx
  integer_to_float rax
  mov rcx, rax

  string_to_integer r8
  integer_to_float rax
  mov r8, rax

  float_div r8, r9
  float_add rcx, rax

  ret
