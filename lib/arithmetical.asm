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
    jne .not_integer_to_integer
      integer_addition rbx, rcx
      ret
    .not_integer_to_integer:
  .not_integer:

  cmp rdx, LIST
  jne .not_list
    cmp r8, LIST
    jne .not_list_to_list
      list_addition rbx, rcx
      ret
    .not_list_to_list:
  .not_list:

  cmp rdx, STRING
  jne .not_string
    cmp r8, STRING
    jne .not_string_to_string
      string_addition rbx, rcx
      ret
    .not_string_to_string:
  .not_string:

  string "Операция сложения не может быть проведена между типами"
  mov rbx, rax
  string "и"
  mov rcx, rax
  list
  list_append_link rax, rbx
  list_append_link rax, rdx
  list_append_link rax, rcx
  list_append_link rax, r8
  print rax
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
    jne .not_integer_to_integer
      integer_sub rbx, rcx
      ret
    .not_integer_to_integer:
  .not_integer:

  string "Операция вычитания не может быть проведена между типами"
  mov rbx, rax
  string "и"
  mov rcx, rax
  list
  list_append_link rax, rbx
  list_append_link rax, rdx
  list_append_link rax, rcx
  list_append_link rax, r8
  print rax
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
    jne .not_integer_to_integer
      integer_multiplication rbx, rcx
      ret
    .not_integer_to_integer:

    cmp r8, STRING
    jne .not_integer_to_string
      string_multiplication rcx, rbx
      ret
    .not_integer_to_string:

    cmp r8, LIST
    jne .not_integer_to_list
      list_multiplication rcx, rbx
      ret
    .not_integer_to_list:
  .not_integer:

  cmp rdx, STRING
  jne .not_string
    cmp r8, INTEGER
    jne .not_string_to_integer
      string_multiplication rbx, rcx
      ret
    .not_string_to_integer:
  .not_string:

  cmp rdx, LIST
  jne .not_list
    cmp r8, INTEGER
    jne .not_list_to_integer
      list_multiplication rbx, rcx
      ret
    .not_list_to_integer:
  .not_list:

  string "Операция умножения не может быть проведена между типами"
  mov rbx, rax
  type_to_string rdx
  mov rdx, rax
  type_to_string r8
  mov r8, rax

  string "и"
  mov rcx, rax
  list
  list_append_link rax, rbx
  list_append_link rax, rdx
  list_append_link rax, rcx
  list_append_link rax, r8
  print rax
  exit -1

f_division:
  get_arg 1
  mov rbx, rax
  get_arg 0
  mov rcx, rax

  mov rdx, [rbx]
  mov r8,  [rcx]

  cmp rdx, INTEGER
  jne .not_integer
    cmp r8, INTEGER
    jne .not_integer_to_integer
      integer_division rbx, rcx
      ret
    .not_integer_to_integer:
  .not_integer:

  string "Операция деления не может быть проведена между типами"
  mov rbx, rax
  string "и"
  mov rcx, rax
  list
  list_append_link rax, rbx
  list_append_link rax, rdx
  list_append_link rax, rcx
  list_append_link rax, r8
  print rax
  exit -1

  .continue:

  ret
