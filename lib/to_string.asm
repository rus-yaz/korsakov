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

    list_length rbx
    integer rax
    mov rcx, rax

    integer 0
    mov rdx, rax

    list
    mov r8, rax

    .list_while:
      is_equal rdx, rcx
      cmp rax, 1
      je .list_end_while

      list_get_link rbx, rdx
      to_string rax
      list_append_link r8, rax

      integer_inc rdx
      jmp .list_while

    .list_end_while:

    join r8
    mov rbx, rax

    string "%("
    string_append_links rax, rbx
    mov rbx, rax

    string ")"
    string_append_links rbx, rax

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
    dictionary_items rax
    mov rbx, rax

    list_length rbx
    cmp rax, 0
    jne .not_empty
      string "%(:)"
      ret

    .not_empty:

    integer rax
    mov rcx, rax

    integer 0
    mov rdx, rax

    list
    mov r10, rax

    .dictionary_while:

      is_equal rdx, rcx
      cmp rax, 1
      je .dictionary_end_while

      string ""
      mov r8, rax

      list_get_link rbx, rdx
      mov r9, rax

      integer 0
      list_get_link r9, rax
      to_string rax
      string_append_links r8, rax

      string ": "
      string_append_links r8, rax

      integer 1
      list_get_link r9, rax
      to_string rax
      string_append_links r8, rax

      list_append_link r10, r8

      integer_inc rdx
      jmp .dictionary_while

    .dictionary_end_while:

    join r10
    mov rbx, rax

    string "%("
    string_append_links rax, rbx
    mov rbx, rax

    string ")"
    string_append_links rbx, rax

    ret

  .not_dictionary:

  type_to_string rbx
  string "to_string: Не поддерживается тип"
  print <rax, rbx>
  exit -1
