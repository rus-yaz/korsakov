section "is_equal" executable

macro is_equal val_1, val_2 {
  enter val_1, val_2

  call f_is_equal

  return
}

f_is_equal:
  ; Сохранение типов
  mov rcx, [rax]
  mov rdx, [rbx]

  ; Сравнение типов
  cmp rcx, rdx
  jne .return_false

  cmp rcx, INTEGER
  je .is_integer

  cmp rcx, STRING
  je .is_string

  cmp rcx, LIST
  je .is_list

  ; Выход с ошибкой при неизвестном типе
  print EXPECTED_TYPE_ERROR, 0, 0
  print INTEGER_TYPE, 44, 32
  print STRING_TYPE, 44, 32
  print LIST_TYPE, 0
  exit -1

  .is_integer:
    mov rcx, [rax + INTEGER_HEADER*8]
    mov rdx, [rbx + INTEGER_HEADER*8]

    cmp rcx, rdx
    jne .return_false

    jmp .return_true

  .is_string:
    push rax

    ; Сравнение длин строк
    string_length rax
    mov rcx, rax

    string_length rbx
    mov rdx, rax

    pop rax

    cmp rcx, rdx
    jne .return_false

    mov rsi, rax
    integer 0
    xchg rsi, rax

    mov rdi, rcx
    .string_check:

      cmp rdi, 0
      je .return_true

      push rax

      string_get rax, rsi
      mov rax, [rax + 8*1]
      mov rcx, [rax + (2 + INTEGER_HEADER) * 8]

      string_get rbx, rsi
      mov rax, [rax + 8*1]
      mov rdx, [rax + (2 + INTEGER_HEADER) * 8]

      integer_inc rsi
      pop rax

      cmp rcx, rdx
      jne .return_false

      dec rdi
      jmp .string_check

  .is_list:

    push rax

    list_length rax
    mov rcx, rax

    list_length rbx
    mov rdx, rax

    pop rax

    ; Сравнение длин списков
    cmp rcx, rdx
    jne .return_false

    mov rsi, rax
    integer 0
    xchg rsi, rax

    mov rdi, rcx
    .list_check:

      cmp rdi, 0
      je .return_true

      push rax

      list_get rax, rsi
      mov rcx, rax

      list_get rbx, rsi
      mov rdx, rax

      is_equal rcx, rdx
      mov rcx, rax

      pop rax

      cmp rcx, 1
      jne .return_false

      push rax
      integer_inc rsi
      pop rax

      dec rdi
      jmp .list_check

  .return_true:
    mov rax, 1
    ret

  .return_false:
    mov rax, 0
    ret
