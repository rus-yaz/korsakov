; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

; @function copy
; @description Создаёт копию объекта в зависимости от его типа
; @param value - объект для копирования
; @return Копия объекта
; @example
;   integer 42
;   copy rax  ; создаёт копию Целого числа
;   string "Hello"
;   copy rax  ; создаёт копию Строки
f_copy:
  get_arg 0
  mov rbx, [rax]

  cmp rbx, NULL
  jne @f
    null
    ret
  @@:

  cmp rbx, INTEGER
  jne @f
    integer_copy rax
    ret
  @@:

  cmp rbx, FLOAT
  jne @f
    float_copy rax
    ret
  @@:

  cmp rbx, BOOLEAN
  jne @f
    boolean_copy rax
    ret
  @@:

  cmp rbx, LIST
  jne @f
    list_copy rax
    ret
  @@:

  cmp rbx, STRING
  jne @f
    string_copy rax
    ret
  @@:

  cmp rbx, DICTIONARY
  jne @f
    dictionary_copy rax
    ret
  @@:

  cmp rbx, FUNCTION
  jne @f
    function_copy rax
    ret
  @@:

  type_to_string rbx
  mov rbx, rax
  string "copy: Нет функции копирования для типа"
  mov rcx, rax

  list
  list_append_link rax, rcx
  list_append_link rax, rbx
  error rax
  exit -1
