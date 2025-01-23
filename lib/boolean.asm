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
  mov rbx, rax
  check_type rbx, BOOLEAN

  create_block BOOLEAN_SIZE*8
  mem_mov [rax + 8*0], BOOLEAN
  mem_mov [rax + 8*1], [rbx + BOOLEAN_HEADER*8]

  ret

f_is_true:
  get_arg 0
  check_type rax, BOOLEAN

  mov rax, [rax + BOOLEAN_HEADER*8]
  ret
