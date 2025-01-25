f_to_string:
  get_arg 0
  mov rbx, [rax]

  cmp rbx, NULL
  jne .not_null
    string "Нуль"
    ret

  .not_null:

  cmp rbx, INTEGER
  jne .not_integer
    mov rax, [rax + INTEGER_HEADER*8]

    mov r8, rsp ; Сохранение указателя на конец стека
    mov rcx, 0

    mov r9, 0

    cmp rax, 0
    jge .integer_continue
      mov r9, 1
      neg rax

    .integer_continue:

    mov rbx, 10 ; Мощность системы счисления
    mov rdx, 0  ; Обнуление регистра, хранящего остаток от деления

    .integer_while:
      idiv rbx    ; Деление на мощность системы счисления
      add rdx, 48 ; Приведение числа к значению по ASCII

      push rdx   ; Сохранение числа на стеке
      mov rdx, 0 ; Обнуление регистра, хранящего остаток от деления

      inc rcx
      cmp rax, 0
      jne .integer_while

    cmp r9, 1
    jne .not_negate

      push "-"
      inc rcx

    .not_negate:

    imul rcx, 8
    push rcx, BINARY

    mov rax, rsp
    binary_to_string rax

    mov rsp, r8 ; Восстановление конца стека
    ret

  .not_integer:

  cmp rbx, BOOLEAN
  jne .not_boolean
    mov rax, [rax + BOOLEAN_HEADER*8]

    cmp rax, 1
    jne .false
      string "Истина"
      ret
    .false:

    string "Ложь"
    ret

  .not_boolean:

  cmp rbx, LIST
  jne .not_list
    mov rbx, rax

    mov rcx, rax
    integer 0
    xchg rcx, rax

    mov rdx, rax
    list_length rax
    xchg rdx, rax

    list

    .list_while:
      cmp rdx, 0
      je .list_end_while

      push rbx, rax

      list_get rbx, rcx
      to_string rax

      mov rbx, rax
      pop rax

      list_append rax, rbx
      pop rbx

      push rax
      integer_inc rcx
      dec rdx
      pop rax

      jmp .list_while

    .list_end_while:

    join rax

    mov rbx, rax

    string "%("
    string_add rax, rbx
    mov rbx, rax
    string ")"
    string_add rbx, rax

    ret

  .not_list:

  cmp rbx, STRING
  jne .not_string
    mov rbx, rax

    string '"'
    mov rcx, rax

    string_add rcx, rbx
    string_add rax, rcx

    ret

  .not_string:

  cmp rbx, DICTIONARY
  jne .not_dictionary
    push rax
    dictionary_items rax
    mov rbx, rax

    pop rax
    dictionary_length rax
    mov rcx, rax

    cmp rcx, 0
    jne .not_empty

      string "%(:)"
      ret

    .not_empty:

    integer 0
    mov rdx, rax

    list

    .dictionary_while:
      cmp rcx, 0
      je .end_dictionary_while

      push rbx, rax

      list_get rbx, rdx
      mov rbx, rax

      list
      mov r8, rax
      integer 0
      list_get rbx, rax
      to_string rax
      list_append r8, rax
      integer 1
      list_get rbx, rax
      to_string rax
      list_append r8, rax

      join rax, ": "
      mov rbx, rax

      pop rax
      list_append rax, rbx
      pop rbx

      push rax
      integer_inc rdx
      dec rcx
      pop rax
      jmp .dictionary_while

    .end_dictionary_while:
    join rax
    mov rbx, rax

    string "%("
    string_append rax, rbx
    mov rbx, rax
    string ")"
    string_append rbx, rax

    ret

  .not_dictionary:

  type_to_string rbx
  string "to_string: Не поддерживается тип"
  print <rax, rbx>
  exit -1
