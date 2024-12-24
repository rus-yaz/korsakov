section "integer" executable

macro integer value {
  enter value

  call f_integer

  return
}

f_integer:
  mov rbx, rax

  create_block INTEGER_SIZE*8

  mem_mov [rax + 8*0], INTEGER
  mem_mov [rax + 8*1], rbx

  ret

macro integer_copy int {
  enter int

  call f_integer_copy

  return
}

f_integer_copy:
  check_type rax, INTEGER
  mov rbx, [rax + 8*1]

  create_block INTEGER_SIZE*8
  mem_mov [rax + 8*0], INTEGER
  mem_mov [rax + 8*1], rbx

  ret

macro integer_inc int {
  enter int

  call f_integer_inc

  return
}

f_integer_inc:
  check_type rax, INTEGER

  mov rbx, [rax + INTEGER_HEADER * 8]
  inc rbx
  mov [rax + INTEGER * 8], rbx

  ret

macro integer_dec int {
  enter int

  call f_integer_dec

  return
}

f_integer_dec:
  check_type rax, INTEGER

  mov rbx, [rax + INTEGER_HEADER * 8]
  dec rbx
  mov [rax + INTEGER * 8], rbx

  ret

macro integer_add int_1, int_2 {
  enter int_1, int_2

  call f_integer_add

  return
}

macro integer_add int_1, int_2 {
  enter int_1, int_2

  call f_integer_add

  return
}

f_integer_add:
  check_type rax, INTEGER
  check_type rbx, INTEGER

  mov rcx, [rax + INTEGER_HEADER*8]
  add rcx, [rbx + INTEGER_HEADER*8]

  create_block INTEGER_SIZE*8

  mem_mov [rax + 8*0], INTEGER
  mem_mov [rax + 8*1], rcx

  ret
