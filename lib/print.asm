f_print_string:
  get_arg 0

  check_type rax, STRING
  mov rbx, rax

  string_length rbx
  mov rcx, rax

  push 0

  .while:
    cmp rcx, 0
    je .end_while

    mov rbx, [rbx + 8*1]

    mov rax, rbx
    add rax, 8*2

    check_type rax, INTEGER
    mov rdx, [rax + INTEGER_HEADER*8] ; Символ

    bswap rdx

    .byte_while:
      cmp rdx, 0
      je .byte_end_while

      movzx r8, dl
      shr rdx, 8

      cmp r8, 0
      je .byte_while

      mov [rsp], r8
      mov r8, rsp
      sys_print r8,\ ; Указатель на строку
                1    ; Длина строки

      jmp .byte_while
    .byte_end_while:

    dec rcx
    jmp .while

  .end_while:

  pop rax

  ret

f_print:
  mov rbx, 0

  list
  mov rcx, rax

  .while:
    get_arg rbx
    cmp rax, 0
    je .end_while

    mov rdx, [rax]
    cmp rdx, STRING
    je .string
      to_string rax

    .string:

    list_append rcx, rax

    inc rbx
    jmp .while

  .end_while:

  inc rbx
  get_arg rbx

  cmp rax, 0
  jne .not_default_separator

    mov rax, " "

  .not_default_separator:

  join rcx, rax
  delete rcx
  mov rcx, rax

  inc rbx
  get_arg rbx

  cmp rax, 0
  jne .not_default_end_of_string

    string 10

  .not_default_end_of_string:

  string_append rcx, rax
  print_string rcx

  ret
