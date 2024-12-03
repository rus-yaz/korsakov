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

  mov rax, arg_1
  mov rbx, arg_2
  mov rcx, arg_3
  mov rdx, arg_4
  mov r8,  arg_5
  mov r9,  arg_6
  mov r10, arg_7
  mov r11, arg_8
  mov r12, arg_9
  mov r13, arg_10
  mov r14, arg_11
  mov r15, arg_12
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

section "exit" executable

macro exit code, message = 0 {
  if message eq 0
  else
    push rax

    mov rbx, message
    buffer_length rbx
    mov rsi, rax

    sys_print rbx, rsi

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

macro check_type variable_ptr, type, error_message {
  enter variable_ptr, type, error_message

  call f_check_type

  leave
}

f_check_type:
  mov rdx, [rax]
  cmp rdx, rbx
  check_error jne, rcx

  ret
