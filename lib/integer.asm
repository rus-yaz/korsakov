; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

f_integer:
  get_arg 0
  mov rbx, rax

  create_block INTEGER_SIZE*8

  mem_mov [rax + 8*0], INTEGER
  mem_mov [rax + 8*1], rbx

  ret

f_string_to_integer:
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

f_integer_copy:
  get_arg 0
  check_type rax, INTEGER
  mov rbx, [rax + 8*1]

  create_block INTEGER_SIZE*8
  mem_mov [rax + 8*0], INTEGER
  mem_mov [rax + 8*1], rbx

  ret

f_integer_neg:
  get_arg 0
  check_type rax, INTEGER

  mov rax, [rax + INTEGER_HEADER * 8]
  neg rax
  integer rax

  ret

f_integer_inc:
  get_arg 0
  check_type rax, INTEGER

  mov rbx, [rax + INTEGER_HEADER * 8]
  inc rbx
  mov [rax + INTEGER * 8], rbx

  ret

f_integer_dec:
  get_arg 0
  check_type rax, INTEGER

  mov rbx, [rax + INTEGER_HEADER * 8]
  dec rbx
  mov [rax + INTEGER * 8], rbx

  ret

f_integer_add:
  get_arg 1
  mov rbx, rax
  get_arg 0

  check_type rax, INTEGER
  check_type rbx, INTEGER

  mov rcx, [rax + INTEGER_HEADER*8]
  add rcx, [rbx + INTEGER_HEADER*8]

  integer rcx

  ret

f_integer_sub:
  get_arg 1
  mov rbx, rax
  get_arg 0

  check_type rax, INTEGER
  check_type rbx, INTEGER

  mov rcx, [rax + INTEGER_HEADER*8]
  sub rcx, [rbx + INTEGER_HEADER*8]

  integer rcx
  ret

f_integer_mul:
  get_arg 1
  mov rbx, rax
  get_arg 0

  check_type rax, INTEGER
  check_type rbx, INTEGER

  mov rcx,  [rax + INTEGER_HEADER*8]
  imul rcx, [rbx + INTEGER_HEADER*8]

  integer rcx
  ret

f_integer_div:
  get_arg 1
  mov rbx, rax
  get_arg 0

  check_type rbx, INTEGER
  check_type rcx, INTEGER

  pushsd 0, 1
  cvtsi2sd xmm0, [rax + INTEGER_HEADER*8]
  cvtsi2sd xmm1, [rbx + INTEGER_HEADER*8]

  divsd xmm1, xmm0

  float
  movsd [rax + FLOAT_HEADER*8], xmm1

  popsd 1, 0

  ret

f_float_to_integer:
  get_arg 0
  check_type rax, FLOAT

  cvttsd2si rbx, [rax + FLOAT_HEADER*8]

  integer 0
  mov [rax + INTEGER_HEADER*8], rbx

  ret
