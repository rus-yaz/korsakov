; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

f_integer:
  get_arg 0
  mov rbx, rax

  create_block INTEGER_SIZE*8

  mem_mov [rax + 8*0], INTEGER
  mem_mov [rax + 8*1], rbx

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

  check_type rax, INTEGER
  check_type rbx, INTEGER

  mov rax, [rax + INTEGER_HEADER*8]
  mov rbx, [rbx + INTEGER_HEADER*8]

  mov rdx, 0
  idiv rbx

  integer rax
  ret
