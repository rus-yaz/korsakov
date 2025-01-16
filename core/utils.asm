f_buffer_length:
  mov rcx, 0 ; Счётчик

  .while:
    ; Сравниваем текущий байт с нулём
    mov bl, [rax + rcx]

    cmp bl, 0
    je .end_while

    inc rcx
    jmp .while

  .end_while:
  mov rax, rcx

  ret

f_sys_print:
  sys_write STDOUT,\
            rax,\       ; Указатель на данные для вывода
            rbx         ; Длина данных для вывода

  ret

f_print_buffer:
  mov rsi, rax
  buffer_length rsi
  mov rbx, rax

  sys_print rsi,\      ; Указатель на буфер
            rbx        ; Размер буфера

  ret

f_mem_copy:
  mov rsi, rax ; Источник
  mov rdi, rbx ; Место назначения
  ; RCX — количество блоков

  rep movsq

  ret

f_check_error:
  exit -1, rax

f_check_type:
  mov r8, [rax]
  mov r9, rbx

  cmp r8, r9
  jne .continue
    ret

  .continue:

  print_buffer EXPECTED_TYPE_ERROR

  cmp r9, INTEGER
  jne .not_integer
    print_buffer INTEGER_TYPE
    jmp .exit
  .not_integer:

  cmp r9, STRING
  jne .not_string
    print_buffer STRING_TYPE
    jmp .exit
  .not_string:

  cmp r9, LIST
  jne .not_list
    print_buffer LIST_TYPE
    jmp .exit
  .not_list:

  cmp r9, FILE
  jne .not_file
    print_buffer FILE_TYPE
    jmp .exit
  .not_file:

  cmp r9, BINARY
  jne .not_binary
    print_buffer BINARY_TYPE
    jmp .exit
  .not_binary:

  cmp r9, DICTIONARY
  jne .not_dictionary
    print_buffer DICTIONARY_TYPE
    jmp .exit
  .not_dictionary:

  mov r8, HEAP_BLOCK
  cmp r9, r8
  jne .not_heap_block
    print_buffer HEAP_BLOCK_TYPE
    jmp .exit
  .not_heap_block:

  check_error jmp, UNEXPECTED_TYPE_ERROR

  .exit:
    push 10
    mov rax, rsp
    sys_print rax, 8

    exit -1
