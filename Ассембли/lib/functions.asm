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
  exit -1, EXPECTED_LIST_INTEGER_STRING_ERROR

  .is_integer:
    mov rcx, [rax + INTEGER_HEADER*8]
    mov rdx, [rbx + INTEGER_HEADER*8]

    cmp rcx, rdx
    jne .return_false

    jmp .return_true


  .is_string:
    ; Сохранение длин строк
    mov rcx, [rax + 8*1]
    mov rdx, [rbx + 8*1]

    ; Сравнение длин строк
    cmp rcx, rdx
    jne .return_false

    add rax, (STRING_HEADER + INTEGER_HEADER) * 8
    add rbx, (STRING_HEADER + INTEGER_HEADER) * 8

    mov rdi, rcx
    .string_check:

      cmp rdi, 0
      je .return_true

      mov rcx, [rax]
      mov rdx, [rbx]

      cmp rcx, rdx
      jne .return_false

      add rax, (INTEGER_HEADER + 1) * 8
      add rbx, (INTEGER_HEADER + 1) * 8

      dec rdi
      jmp .string_check


  .is_list:
    ; Сохранение длин строк
    mov rcx, [rax + 8*1]
    mov rdx, [rbx + 8*1]

    ; Сравнение длин строк
    cmp rcx, rdx
    jne .return_false

    ; Сохранение длин строк
    mov rcx, [rax + 8*2]
    mov rdx, [rbx + 8*2]

    ; Сравнение длин строк
    cmp rcx, rdx
    jne .return_false

    add rax, LIST_HEADER * 8
    add rbx, LIST_HEADER * 8

    mov rdi, rcx
    .list_check:

      cmp rdi, 0
      je .return_true

      mov rcx, [rax]
      mov rdx, [rbx]

      cmp rcx, rdx
      jne .return_false

      add rax, 8
      add rbx, 8

      dec rdi
      jmp .list_check


  .return_true:
    mov rax, 1
    ret

  .return_false:
    mov rax, 0
    ret
