; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

f_is_equal:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  mov rdx, [rbx]
  mov r8,  [rcx]

  cmp rdx, FLOAT
  jne @f
  cmp r8, INTEGER
  jne @f
    integer_to_float rcx
    mov rcx, rax
    mov r8,  [rcx]
  @@:

  cmp rdx, INTEGER
  jne @f
  cmp r8, FLOAT
  jne @f
    integer_to_float rbx
    mov rbx, rax
    mov rdx, [rbx]
  @@:

  cmp rdx, r8
  jne .return_false

  cmp rdx, NULL
  je .return_true

  cmp rdx, INTEGER
  jne .not_integer

    mov rbx, [rbx + INTEGER_HEADER*8]
    mov rcx, [rcx + INTEGER_HEADER*8]

    cmp rbx, rcx
    je .return_true
    jmp .return_false

  .not_integer:

  cmp rdx, FLOAT
  jne .not_float

    movsd xmm0, [rbx + FLOAT_HEADER*8]
    movsd xmm1, [rcx + FLOAT_HEADER*8]

    comisd xmm0, xmm1
    je .return_true
    jmp .return_false

  .not_float:

  cmp rdx, BOOLEAN
  jne .not_boolean

    mov rbx, [rbx + BOOLEAN_HEADER*8]
    mov rcx, [rcx + BOOLEAN_HEADER*8]

    cmp rbx, rcx
    je .return_true
    jmp .return_false

  .not_boolean:

  cmp rdx, LIST
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

  cmp rdx, STRING
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

  cmp rdx, DICTIONARY
  jne .not_dictionary

    dictionary_items_links rbx
    mov rdx, rax
    dictionary_items_links rcx
    is_equal rdx, rax
    ret

  .not_dictionary:

  string "is_equal: Ожидался тип"
  mov r8, rax

  list
  mov rdx, rax

  type_to_string INTEGER
  list_append rdx, rax
  type_to_string FLOAT
  list_append rdx, rax
  type_to_string BOOLEAN
  list_append rdx, rax
  type_to_string STRING
  list_append rdx, rax
  type_to_string LIST
  list_append rdx, rax
  type_to_string DICTIONARY
  list_append rdx, rax

  string ", "
  join rdx, rax
  mov rdx, rax

  list
  list_append_link rax, r8
  list_append_link rax, rdx
  list_append_link rax, rbx
  list_append_link rax, rcx
  error rax
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

  mov rdx, [rbx]
  mov r8,  [rcx]

  cmp rdx, FLOAT
  jne @f
  cmp r8, INTEGER
  jne @f
    float_to_integer rbx
    mov rbx, rax
    mov rdx, [rax]
  @@:

  cmp r8, FLOAT
  jne @f
  cmp rdx, INTEGER
  jne @f
    float_to_integer rcx
    mov rcx, rax
    mov r8, [rax]
  @@:

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

  cmp rdx, FLOAT
  jne .not_float
    movsd xmm0, [rbx + FLOAT_HEADER*8]
    movsd xmm1, [rcx + FLOAT_HEADER*8]

    comisd xmm0, xmm1
    jb .return_true
    jmp .return_false

  .not_float:

  .incorrect_type:

  list
  mov rbx, rax

  string "is_lower: Ожидался тип"
  list_append_link rbx, rax

  list
  mov rcx, rax

  type_to_string INTEGER
  list_append_link rcx, rax
  type_to_string FLOAT
  list_append_link rcx, rax

  string ", "
  join rcx, rax
  list_append_link rbx, rax

  error rbx
  exit -1

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

  mov rdx, [rbx]
  mov r8, [rcx]

  cmp rdx, FLOAT
  jne @f
  cmp r8, INTEGER
  jne @f
    float_to_integer rbx
    mov rbx, rax
    mov rdx, [rax]
  @@:

  cmp r8, FLOAT
  jne @f
  cmp rdx, INTEGER
  jne @f
    float_to_integer rcx
    mov rcx, rax
    mov r8, [rax]
  @@:

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

  cmp rdx, FLOAT
  jne .not_float
    movsd xmm0, [rbx + FLOAT_HEADER*8]
    movsd xmm1, [rcx + FLOAT_HEADER*8]

    comisd xmm0, xmm1
    ja .return_true
    jmp .return_false

  .not_float:

  .incorrect_type:

  list
  mov rbx, rax

  string "is_greater: Ожидался тип"
  list_append_link rbx, rax

  list
  mov rcx, rax

  type_to_string INTEGER
  list_append_link rcx, rax
  type_to_string FLOAT
  list_append_link rcx, rax

  string ", "
  join rcx, rax
  list_append_link rbx, rax

  error rbx
  exit -1

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
