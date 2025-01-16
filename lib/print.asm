f_print_string:
  ; Проверка типа
  check_type rax, STRING

  mov rcx, [rax + 8*2]       ; Длина строки
  cmp rcx, 0
  jne .not_empty
    ret

  .not_empty:

  .while:
    dec rcx
    mov rax, [rax + 8*1]

    push rax
    add rax, 8*2

    check_type rax, INTEGER
    mov rdx, [rax + INTEGER_HEADER*8] ; Символ

    bswap rdx
    pop rax

    push rdx
    mov rdx, rsp

    sys_print rdx,\ ; Указатель на строку
              8     ; Длина строки

    add rsp, 8

    cmp rcx, 0
    jg .while

  ret

f_print:
  mov rbx, [rax]

  cmp rbx, INTEGER
  je .not_string

  cmp rbx, LIST
  je .not_string

  cmp rbx, DICTIONARY
  je .not_string

  cmp rbx, STRING
  je .string

  jmp .buffer

  .string:
    print_string rax
    jmp .end

  .not_string:
    to_string rax
    print_string rax
    jmp .end

  .buffer:
    print_buffer rax
    jmp .end

  .end:

  ret
