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

; TODO: Реализовать через `join`

section "print" executable

macro показать arguments*, separator = " ", end_of_string = 10 {
  print arguments, separator, end_of_string
}

macro print arguments*, separator = " ", end_of_string = 10 {
  push rax

  macro print_argument [argument*] \{
    enter argument

    call f_print

    push separator
    mov rax, rsp
    sys_print rax, 8
    pop rax

    leave
  \}

  print_argument arguments

  push 0, end_of_string
  mov rax, rsp

  sys_print rax, 8*2
  pop rax, rax

  pop rax
}

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
