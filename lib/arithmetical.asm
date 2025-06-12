; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

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
