; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

f_boolean:
  get_arg 0
  mov rbx, rax

  cmp rbx, 1
  je .true

  cmp rbx, 0
  je .false

  mov rax, [rbx]

  cmp rax, NULL
  je .false

  cmp rax, INTEGER
  jne .not_integer
    mov rax, [rbx + INTEGER_HEADER*8]
    cmp rax, 0

    je .false
    jmp .true

  .not_integer:

  cmp rax, FLOAT
  jne .not_float
    movsd xmm0, [rbx + FLOAT_HEADER*8]
    movq rax, xmm0
    cmp rax, 0

    je .false
    jmp .true

  .not_float:

  cmp rax, BOOLEAN
  jne .not_boolean
    mov rax, [rbx + BOOLEAN_HEADER*8]
    cmp rax, 0

    je .false
    jmp .true

  .not_boolean:

  cmp rax, LIST
  jne .not_list
    list_length rbx
    cmp rax, 0

    je .false
    jmp .true

  .not_list:

  cmp rax, STRING
  jne .not_string
    string_length rbx
    cmp rax, 0

    je .false
    jmp .true

  .not_string:

  cmp rax, DICTIONARY
  jne .not_dictionary
    dictionary_length rbx
    cmp rax, 0

    je .false
    jmp .true

  .not_dictionary:

  .true:
    mov rbx, 1
    jmp .continue

  .false:
    mov rbx, 0

  .continue:

  create_block BOOLEAN_SIZE*8
  mem_mov [rax + 8*0], BOOLEAN
  mem_mov [rax + 8*1], rbx

  ret

f_boolean_copy:
  get_arg 0
  check_type rax, BOOLEAN
  mov rbx, rax

  create_block BOOLEAN_SIZE*8
  mem_mov [rax + 8*0], BOOLEAN
  mem_mov [rax + 8*1], [rbx + BOOLEAN_HEADER*8]

  ret

f_boolean_value:
  get_arg 0
  check_type rax, BOOLEAN

  mov rax, [rax + BOOLEAN_HEADER*8]
  ret

f_boolean_not:
  get_arg 0

  boolean rax
  mov rbx, [rax + BOOLEAN_HEADER*8]
  delete rax

  dec rbx
  neg rbx
  boolean rbx

  ret

f_boolean_and:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  boolean rbx
  mov rbx, [rax + BOOLEAN_HEADER*8]
  delete rax
  cmp rbx, 1
  jne .return_false

  boolean rcx
  mov rbx, [rax + BOOLEAN_HEADER*8]
  delete rax
  cmp rbx, 1
  jne .return_false

  boolean 1
  ret

  .return_false:

  boolean 0
  ret

f_boolean_or:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  boolean rbx
  mov rbx, [rax + BOOLEAN_HEADER*8]
  delete rax
  cmp rbx, 1
  je .return_true

  boolean rcx
  mov rbx, [rax + BOOLEAN_HEADER*8]
  delete rax
  cmp rbx, 1
  je .return_true

  boolean 0
  ret

  .return_true:

  boolean 1
  ret
