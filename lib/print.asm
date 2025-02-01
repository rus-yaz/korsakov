f_print_string:
  get_arg 0
  mov rbx, rax

  check_type rbx, STRING

  string_to_binary rbx
  mov rcx, rax

  binary_length rcx

  mov rbx, rcx
  add rbx, 8*2

  sys_print rbx, rax

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

    list_append_link rcx, rax

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
