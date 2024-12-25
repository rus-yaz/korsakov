section "buffer" writable
  buffer rq 0

section "push" executable

macro push [arg] {
  push arg
}

section "pop" executable

macro pop [arg] {
  pop arg
}

section "enter" executable

macro enter arg_1 = 0, arg_2 = 0, arg_3 = 0, arg_4 = 0, arg_5 = 0, arg_6 = 0, arg_7 = 0, arg_8 = 0, arg_9 = 0, arg_10 = 0, arg_11 = 0, arg_12 = 0 {
  push rax, rbx, rcx, rdx, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15

  macro pushq [arg] \{
    mov [rsp - 8*2], rax
    mov rax, arg
    mov [rsp - 8*1], rax
    mov rax, [rsp - 8*2]
    sub rsp, 8
  \}

  pushq arg_12, arg_11, arg_10, arg_9, arg_8, arg_7, arg_6, arg_5, arg_4, arg_3, arg_2, arg_1
  pop   rax,    rbx,    rcx,    rdx,   r8,    r9,    r10,   r11,   r12,   r13,   r14,   r15
}

section "leave" executable

macro leave {
  pop r15, r14, r13, r12, r11, r10, r9, r8, rdi, rsi, rdx, rcx, rbx, rax
}

section "return" executable

macro return {
  push rax
  add rsp, 8

  leave

  mov rax, [rsp - 8*15]
}

section "mem_mov" executable

macro mem_mov dst, src {
  push r15
  mov r15, src
  mov dst, r15
  pop r15
}

section "buffer_length" executable

macro buffer_length buffer_ptr {
  enter buffer_ptr

  call f_buffer_length

  return
}

f_buffer_length:
  mov rcx, 0 ; Счётчик

  .loop:
    ; Сравниваем текущий байт с нулём
    mov bl, [rax + rcx]

    cmp bl, 0
    je .done

    inc rcx
    jmp .loop

  .done:
  mov rax, rcx

  ret

section "sys_print" executable

macro sys_print ptr, size {
  enter ptr, size

  call f_sys_print

  leave
}

f_sys_print:
  sys_write STDOUT,\
            rax,\       ; Указатель на данные для вывода
            rbx         ; Длина данных для вывода

  ret

section "print_buffer" executable

macro print_buffer [buffer] {
  enter buffer

  call f_print_buffer

  leave
}

f_print_buffer:
  mov rsi, rax
  buffer_length rsi
  mov rbx, rax

  sys_print rsi,\      ; Указатель на буфер
            rbx        ; Размер буфера

  ret


section "exit" executable

macro exit code, buffer = 0 {
  if buffer eq 0
  else
    push rax

    print_buffer buffer

    push 10
    mov rax, rsp
    sys_print rax, 8
    pop rax

    pop rax
  end if

  sys_exit code
}

section "check_error" executable

macro check_error operation, message {
  push rax

  mov rax, message
  operation f_check_error

  pop rax
}

f_check_error:
  exit -1, rax

section "check_type" executable

macro check_type variable_ptr, type {
  enter variable_ptr, type

  call f_check_type

  leave
}

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

macro mem_copy source, destination, size {
  enter source, destination, size

  call f_mem_copy

  leave
}

f_mem_copy:
  mov rsi, rax ; Источник
  mov rdi, rbx ; Место назначения
  ; RCX — количество блоков

  rep movsq

  ret
