f_print_int:
  check_type rax, INTEGER
  mov rax, [rax + 8]

  mov r8, rsp ; Сохранение указателя на конец стека
  mov rbx, 10 ; Мощность системы счисления

  mov rcx, 0  ; Счётчик пройденных разрядов
  mov rdx, 0  ; Обнуление регистра, хранящего остаток от деления

  .while:
    inc rcx ; Инкрементация счётчика пройденных разрядов

    idiv rbx    ; Деление на мощность системы счисления
    add rdx, 48 ; Приведение числа к значению по ASCII

    push rdx   ; Сохранение числа на стеке
    mov rdx, 0 ; Обнуление регистра, хранящего остаток от деления

    cmp rax, 0
    jne .while

  mov rax, rsp
  imul rcx, 8

  sys_print rax, rcx
  mov rsp, r8 ; Восстановление конца стека

  ret

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

  macro print arguments, separator = " ", end_of_string = 10 {
  push rax

  macro print_argument [argument] \{
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
  je .print_int

  cmp rbx, STRING
  je .print_string

  jmp .print_buffer

  .print_int:
    print_int rax
    jmp .end

  .print_string:
    print_string rax
    jmp .end

  .print_buffer:
    print_buffer rax
    jmp .end

  .end:

  ret
