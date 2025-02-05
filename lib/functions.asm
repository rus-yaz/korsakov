; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

f_is_equal:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  mov rdx, [rbx]
  mov rax, [rcx]
  cmp rdx, rax
  jne .return_false

  cmp rdx, NULL
  je .return_true

  mov rdx, INTEGER
  cmp rax, rdx
  jne .not_integer
    mov rbx, [rbx + INTEGER_HEADER*8]
    mov rcx, [rcx + INTEGER_HEADER*8]

    cmp rbx, rcx
    je .return_true

    jmp .return_false

  .not_integer:

  mov rdx, BOOLEAN
  cmp rax, rdx
  jne .not_boolean
    mov rbx, [rbx + BOOLEAN_HEADER*8]
    mov rcx, [rcx + BOOLEAN_HEADER*8]

    cmp rbx, rcx
    je .return_true

    jmp .return_false

  .not_boolean:

  mov rdx, LIST
  cmp rax, rdx
  jne .not_list

    list_length rbx
    mov rdx, rax
    list_length rcx
    cmp rax, rdx
    jne .return_false

    integer rdx
    mov rdx, rax

    integer 0
    mov r8, rax

    .list_while:
      is_equal r8, rdx
      boolean_value rax
      cmp rax, 1
      je .list_end_while

      list_get_link rbx, r8
      mov r9, rax
      list_get_link rcx, r8
      mov r10, rax

      is_equal r9, r10
      boolean_value rax
      cmp rax, 1
      jne .return_false

      integer_inc r8
      jmp .list_while

    .list_end_while:

    jmp .return_true

  .not_list:

  mov rdx, STRING
  cmp rax, rdx
  jne .not_string

    string_length rbx
    mov rdx, rax
    string_length rcx
    cmp rax, rdx
    jne .return_false

    integer rdx
    mov rdx, rax

    integer 0
    mov r8, rax

    .string_while:
      is_equal r8, rdx
      boolean_value rax
      cmp rax, 1
      je .string_end_while

      string_get_link rbx, r8
      mov rax, [rax + 8*3]
      mov r9, [rax]

      string_get_link rcx, r8
      mov rax, [rax + 8*3]
      mov r10, [rax]

      is_equal r9, r10
      boolean_value rax
      cmp rax, 1
      jne .return_false

      integer_inc r8
      jmp .string_while

    .string_end_while:

    jmp .return_true

  .not_string:

  mov rdx, DICTIONARY
  cmp rax, rdx
  jne .not_dictionary

    dictionary_items_links rbx
    mov rdx, rax
    dictionary_items_links rcx
    is_equal rdx, rax
    ret

  .not_dictionary:

  ; Выход с ошибкой при неизвестном типе
  string "is_equal: Ожидался тип"
  mov r8, rax

  list
  mov rdx, rax

  type_to_string INTEGER
  list_append rdx, rax
  type_to_string BOOLEAN
  list_append rdx, rax
  type_to_string STRING
  list_append rdx, rax
  type_to_string LIST
  list_append rdx, rax
  type_to_string DICTIONARY
  list_append rdx, rax
  join rax, ", "

  print <r8, rax, rbx, rcx>
  exit -1

  .return_true:
    boolean 1
    ret

  .return_false:
    boolean 0
    ret

f_is_not_equal:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  is_equal rbx, rcx
  boolean_not rax
  ret

f_is_lower:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  ; Сохранение типов
  mov rdx, [rbx]
  mov r8, [rcx]

  ; Сравнение типов
  cmp rdx, r8
  jne .incorrect_type

  cmp rdx, INTEGER
  jne .not_integer
    mov rbx, [rbx + INTEGER_HEADER*8]
    mov rcx, [rcx + INTEGER_HEADER*8]

    cmp rbx, rcx
    jl .return_true
    jmp .return_false

  .not_integer:

  .incorrect_type:

  string "Ожидался тип"
  mov rbx, rax
  type_to_string INTEGER
  print <rcx, rax>
  exit -1

  ret

  .return_true:
    boolean 1
    ret

  .return_false:
    boolean 0
    ret

f_is_greater:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  ; Сохранение типов
  mov rdx, [rbx]
  mov r8, [rcx]

  ; Сравнение типов
  cmp rdx, r8
  jne .incorrect_type

  cmp rdx, INTEGER
  jne .not_integer
    mov rbx, [rbx + INTEGER_HEADER*8]
    mov rcx, [rcx + INTEGER_HEADER*8]

    cmp rbx, rcx
    jg .return_true
    jmp .return_false

  .not_integer:

  .incorrect_type:

  string "Ожидался тип"
  mov rcx, rax
  type_to_string INTEGER
  print <rcx, rax>
  exit -1

  ret

  .return_true:
    boolean 1
    ret

  .return_false:
    boolean 0
    ret

f_is_lower_or_equal:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  is_greater rbx, rcx
  boolean_not rax
  ret

f_is_greater_or_equal:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  is_lower rbx, rcx
  boolean_not rax
  ret

f_copy:
  get_arg 0
  mov rbx, [rax]

  cmp rbx, NULL
  jne .not_null
    null
    ret
  .not_null:

  cmp rbx, INTEGER
  jne .not_integer
    integer_copy rax
    ret
  .not_integer:

  cmp rbx, BOOLEAN
  jne .not_boolean
    boolean_copy rax
    ret
  .not_boolean:

  cmp rbx, COLLECTION
  jne .not_collection
    collection_copy rax
    ret
  .not_collection:

  cmp rbx, LIST
  jne .not_list
    list_copy rax
    ret
  .not_list:

  cmp rbx, STRING
  jne .not_string
    string_copy rax
    ret
  .not_string:

  cmp rbx, DICTIONARY
  jne .not_dictionary
    dictionary_copy rax
    ret
  .not_dictionary:

  type_to_string rbx
  mov rbx, rax
  string "copy: Нет функции копирования для типа"
  print <rax, rbx>

  exit -1
