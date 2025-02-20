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
  jne .first_not_integer
    cmp r8, INTEGER
    jne .second_not_integer
      integer_add rbx, rcx
      ret
    .second_not_integer:
  .first_not_integer:

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
  jne .first_not_integer
    cmp r8, INTEGER
    jne .second_not_integer
      integer_sub rbx, rcx
      ret
    .second_not_integer:
  .first_not_integer:

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
  jne .first_not_integer
    cmp r8, INTEGER
    jne .second_not_integer
      mov rbx, [rbx + INTEGER_HEADER*8]
      mov rcx, [rcx + INTEGER_HEADER*8]

      mov rax, rcx
      imul rbx
      integer rax

      ret
    .second_not_integer:

    cmp r8, STRING
    jne .second_not_string
      mov r9, [rbx + INTEGER_HEADER*8]

      string ""
      .string_while:
        cmp r9, 0
        je .string_end_while

        string_extend_links rax, rcx

        dec r9
        jmp .string_while
      .string_end_while:

      copy rax
      ret

    .second_not_string:
  .first_not_integer:

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
  jne .first_not_integer
    cmp r8, INTEGER
    jne .second_not_integer
      mov rbx, [rbx + INTEGER_HEADER*8]
      mov rcx, [rcx + INTEGER_HEADER*8]

      mov rdx, 0
      mov rax, rcx
      idiv rbx
      integer rax

      jmp .continue

    .second_not_integer:

  .first_not_integer:

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
