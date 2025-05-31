f_buffer_to_float:
  get_arg 0
  mov rbx, rax

  create_block FLOAT_SIZE*8

  mem_mov   [rax + 8*0], FLOAT
  mem_movsd [rax + 8*1], [rbx]

  ret

f_float_copy:
  get_arg 0
  mov rbx, rax

  check_type rbx, FLOAT

  float
  mem_movsd [rax + 8*1], [rbx + 8*1]

  ret

f_float_add:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, FLOAT
  check_type rcx, FLOAT

  pushsd 0, 1

  movsd xmm0, [rbx + FLOAT_HEADER*8]
  movsd xmm1, [rcx + FLOAT_HEADER*8]
  addsd xmm0, xmm1

  float
  movsd [rax + FLOAT_HEADER*8], xmm0

  popsd 1, 0

  ret

f_float_sub:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, FLOAT
  check_type rcx, FLOAT

  pushsd 0, 1

  movsd xmm0, [rbx + FLOAT_HEADER*8]
  movsd xmm1, [rcx + FLOAT_HEADER*8]
  subsd xmm0, xmm1

  float
  movsd [rax + FLOAT_HEADER*8], xmm0

  popsd 1, 0

  ret

f_float_mul:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, FLOAT
  check_type rcx, FLOAT

  pushsd 0, 1

  movsd xmm0, [rbx + FLOAT_HEADER*8]
  movsd xmm1, [rcx + FLOAT_HEADER*8]
  mulsd xmm0, xmm1

  float
  movsd [rax + FLOAT_HEADER*8], xmm0

  popsd 1, 0

  ret

f_float_div:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, FLOAT
  check_type rcx, FLOAT

  pushsd 0, 1

  movsd xmm0, [rbx + FLOAT_HEADER*8]
  movsd xmm1, [rcx + FLOAT_HEADER*8]
  divsd xmm0, xmm1

  float
  movsd [rax + FLOAT_HEADER*8], xmm0

  popsd 1, 0

  ret

f_integer_to_float:
  get_arg 0
  check_type rax, INTEGER

  pushsd 0
  cvtsi2sd xmm0, [rax + INTEGER_HEADER*8]

  float
  movsd [rax + FLOAT_HEADER*8], xmm0

  popsd 0

  ret

f_string_to_float:
  get_arg 0
  mov rbx, rax

  check_type rbx, STRING

  string ""
  mov rcx, rax

  mov rdx, 0

  string ","
  mov r8, rax

  .while:
    string_length rbx
    cmp rax, rdx
    jne .correct_length
      string "Не найден разделитель целой и вещественной частей (`,`)"
      mov rbx, rax
      list
      list_append_link rax, rbx
      error rax
      exit -1
    .correct_length:

    integer rdx
    string_get_link rbx, rax
    mov r9, rax

    is_equal r8, r9
    boolean_value rax
    cmp rax, 1
    je .end_while

    is_digit r9
    cmp rax, 1
    je .correct_number
      string "Некорректный символ: ожидалась цифра, получено — `"
      string_extend_links rax, r9
      mov rbx, rax
      string "`"
      string_extend_links rbx, rax
      list
      list_append_link rax, rbx
      error rax
      exit -1
    .correct_number:

    string_extend_links rcx, r9
    inc rdx
    jmp .while
  .end_while:

  inc rdx
  integer rdx

  string ""
  mov r8, rax

  .while_real:
    string_length rbx
    cmp rdx, rax
    je .end_while_real

    integer rdx
    string_get_link rbx, rax
    mov r9, rax

    is_digit r9
    cmp rax, 1
    je .continue
      string "Некорректный символ: ожидалась цифра, получено — `"
      string_extend_links rax, r9
      mov rbx, rax
      string "`"
      string_extend_links rbx, rax
      list
      list_append_link rax, rbx
      error rax
      exit -1
    .continue:

    string_extend_links r8, r9
    inc rdx
    jmp .while_real
  .end_while_real:

  string_length r8
  mov r9, rax

  integer 10
  mov r10, rax

  integer 1
  @@:
    cmp r9, 0
    je @f

    integer_mul rax, r10

    dec r9
    jmp @b
  @@:

  integer_to_float rax
  mov r9, rax

  string_length rcx
  cmp rax, 0
  jne .correct_first_part
    string "Перед разделителем целой и вещественной части ничего нет"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1
  .correct_first_part:

  string_length r8
  cmp rax, 0
  jne .correct_last_part
    string "После разделителя целой и вещественной части ничего нет"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1
  .correct_last_part:

  string_to_integer rcx
  integer_to_float rax
  mov rcx, rax

  string_to_integer r8
  integer_to_float rax
  mov r8, rax

  float_div r8, r9
  float_add rcx, rax

  ret
