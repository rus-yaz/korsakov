f_factorial:
  get_arg 0
  check_type rax, INTEGER

  mov rax, [rax + INTEGER_HEADER*8]
  cmp rax, 0
  jge .correct_argument
    string "factorial: Число должно быть не меньше нуля"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1
  .correct_argument:

  cmp rax, 1
  jg @f
    integer 1
    ret
  @@:

  mov rbx, 1
  .while:
    cmp rax, 1
    je .end_while

    imul rbx, rax

    dec rax
    jmp .while
  .end_while:

  integer rbx
  ret

; Реализация через ряд Тейлора
f_euler_power_taylor:
  get_arg 0
  mov rbx, rax

  mov rax, [rbx]
  cmp rax, INTEGER
  jne @f
    integer_to_float rbx
    mov rbx, rax
    jmp .correct_argument
  @@:

  cmp rax, FLOAT
  je .correct_argument
    string "Ожидалось Целое или Вещественное число"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1
  .correct_argument:

  pushsd 0, 1, 2, 3, 4, 5
  mov rcx, 1

  mov r10, 0

  cvttsd2si rax, [rbx + FLOAT_HEADER*8]
  cmp rax, 0
  jge @f
    mov r10, 1
    float 0
    float_sub rax, rbx
    mov rbx, rax
  @@:

  movsd xmm5, [rbx + FLOAT_HEADER*8]
  cvttsd2si rbx, xmm5

  cvtsi2sd xmm1, rbx
  subsd xmm5, xmm1

  raw_float 0.0
  movsd xmm0, [rax]

  mov r8, 0  ; Счётчик
  mov r9, 21 ; Точность

  .while_integer:
    cmp r9, r8
    je .end_while_integer

    integer r8
    factorial rax

    mov rax, [rax + INTEGER_HEADER*8]

    push rax, rcx
    xchg rax, rcx

    mov rdx, 0
    idiv rcx

    cvtsi2sd xmm1, rdx
    cvtsi2sd xmm2, rcx

    cvtsi2sd xmm3, rax
    divsd xmm1, xmm2

    addsd xmm0, xmm1
    addsd xmm0, xmm3

    pop rcx, rax
    imul rcx, rbx

    inc r8
    jmp .while_integer
  .end_while_integer:

  mov r8, 0  ; Счётчик
  movsd xmm2, xmm0

  raw_float 0.0
  movsd xmm0, [rax]

  raw_float 1.0
  movsd xmm1, [rax]

  .while_real:
    cmp r9, r8
    je .end_while_real

    integer r8
    factorial rax

    integer_to_float rax
    movsd xmm3, [rax + FLOAT_HEADER*8]

    movsd xmm4, xmm1
    divsd xmm4, xmm3

    addsd xmm0, xmm4
    mulsd xmm1, xmm5

    inc r8
    jmp .while_real
  .end_while_real:

  mulsd xmm0, xmm2

  cmp r10, 0
  je .positive
    movsd xmm1, xmm0

    raw_float 1.0
    movsd xmm0, [rax]

    divsd xmm0, xmm1
  .positive:

  float
  movsd [rax + FLOAT_HEADER*8], xmm0

  popsd 5, 4, 3, 2, 1, 0

  ret

; Реализация через константу
f_euler_power:
  get_arg 0
  mov rbx, rax

  mov rax, [rbx]
  cmp rax, FLOAT
  jne @f
    euler_power_taylor rbx
    ret
  @@:

  cmp rax, INTEGER
  je .correct_argument
    string "Ожидалось Целое или Вещественное число"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1
  .correct_argument:

  mov rbx, [rbx + INTEGER_HEADER*8]

  cmp rbx, 0
  jne .not_zero
    float 1.0
    ret
  .not_zero:

  mov rdx, 0
  cmp rbx, 0
  jg @f
    mov rdx, 1
    neg rbx
  @@:

  mov rcx, [E]
  float 1.0

  @@:
    cmp rbx, 0
    je @f

    float_mul rax, rcx

    dec rbx
    jmp @b
  @@:

  cmp rdx, 0
  je .not_negative
    mov rbx, rax

    float 1.0
    float_div rax, rbx
  .not_negative:

  ret
