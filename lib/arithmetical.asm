f_addition:
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

      add rcx, rbx
      integer rcx

      jmp .continue

    .second_not_integer:

  .first_not_integer:

  string "Операция сложения не может быть проведена между типами "
  mov rbx, rax
  string " и "
  print <rbx, rdx, rax, r8>

  .continue:

  ret

f_subtraction:
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

      sub rcx, rbx
      integer rcx

      jmp .continue

    .second_not_integer:

  .first_not_integer:

  string "Операция сложения не может быть проведена между типами "
  mov rbx, rax
  string " и "
  print <rbx, rdx, rax, r8>

  .continue:

  ret

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

      jmp .continue

    .second_not_integer:

    cmp r8, STRING
    jne .second_not_string
      mov r9, [rbx + INTEGER_HEADER*8]

      string ""

      .string_while:
        cmp r9, 0
        je .string_end_while

        string_append rax, rcx

        dec r9
        jmp .string_while

      .string_end_while:

      jmp .continue

    .second_not_string:

  .first_not_integer:

  string "Операция сложения не может быть проведена между типами "
  mov rbx, rax
  type_to_string rdx
  mov rdx, rax
  type_to_string r8
  mov r8, rax

  string " и "
  print <rbx, rdx, rax, r8>

  .continue:

  ret

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

  string "Операция сложения не может быть проведена между типами "
  mov rbx, rax
  string " и "
  print <rbx, rdx, rax, r8>

  .continue:

  ret
