f_is_equal:
  get_arg 1
  mov rbx, rax
  get_arg 0

  ; Сохранение типов
  mov rcx, [rax]
  mov rdx, [rbx]

  ; Сравнение типов
  cmp rcx, rdx
  jne .return_false

  cmp rcx, NULL
  je .return_true

  cmp rcx, INTEGER
  jne .not_integer
    mov rax, [rax + INTEGER_HEADER*8]
    mov rbx, [rbx + INTEGER_HEADER*8]

    cmp rax, rbx
    jne .return_false

    jmp .return_true

  .not_integer:

  cmp rcx, BOOLEAN
  jne .not_boolean
    mov rax, [rax + BOOLEAN_HEADER*8]
    mov rbx, [rbx + BOOLEAN_HEADER*8]

    cmp rax, rbx
    jne .return_false

    jmp .return_true

  .not_boolean:

  cmp rcx, LIST
  jne .not_list

    push rax

    list_length rax
    mov rcx, rax

    list_length rbx
    mov rdx, rax

    pop rax

    ; Сравнение длин списков
    cmp rcx, rdx
    jne .return_false

    mov rdi, rcx
    .list_while:
      cmp rdi, 0
      je .return_true

      mov rax, [rax + 8*1]
      mov rbx, [rbx + 8*1]

      mov rcx, rax
      mov rdx, rbx

      add rcx, 8*2
      add rdx, 8*2

      mov r8, rax
      is_equal rcx, rdx
      xchg r8, rax
      cmp rax, 1
      jne .return_false

      dec rdi
      jmp .list_while

  .not_list:

  cmp rcx, STRING
  jne .not_string
    push rax

    ; Сравнение длин строк
    string_length rax
    mov rcx, rax

    string_length rbx
    mov rdx, rax

    pop rax

    cmp rcx, rdx
    jne .return_false

    mov rdi, rcx
    .string_while:

      cmp rdi, 0
      je .return_true

      mov rax, [rax + 8*1]
      mov rcx, [rax + (2 + INTEGER_HEADER) * 8]

      mov rbx, [rbx + 8*1]
      mov rdx, [rbx + (2 + INTEGER_HEADER) * 8]

      cmp rcx, rdx
      jne .return_false

      dec rdi
      jmp .string_while

  .not_string:

  cmp rcx, DICTIONARY
  jne .not_dictionary
    mov rcx, rax

    dictionary_items rbx
    mov rdx, rax
    dictionary_items rcx


    mov r8, rax
    is_equal rax, rdx
    xchg r8, rax
    cmp rax, 0

    je .return_false
    jmp .return_true

  .not_dictionary:

  ; Выход с ошибкой при неизвестном типе

  string "Ожидался тип"
  mov rcx, rax

  list
  mov rbx, rax

  type_to_string INTEGER
  list_append rbx, rax
  type_to_string STRING
  list_append rbx, rax
  type_to_string LIST
  list_append rbx, rax
  type_to_string DICTIONARY
  list_append rbx, rax
  join rax, ", "

  print <rcx, rax>
  exit -1

  .return_true:
    mov rax, 1
    ret

  .return_false:
    mov rax, 0
    ret

f_copy:
  get_arg 0
  mov rbx, [rax]

  cmp rbx, NULL
  jne .not_null
    null
    ret
  .not_null:

  cmp rbx, INTEGER
  jne .not_integer
    integer_copy rax
    ret
  .not_integer:

  cmp rbx, BOOLEAN
  jne .not_boolean
    boolean_copy rax
    ret
  .not_boolean:

  cmp rbx, LIST
  jne .not_list
    list_copy rax
    ret
  .not_list:

  cmp rbx, STRING
  jne .not_string
    string_copy rax
    ret
  .not_string:

  cmp rbx, DICTIONARY
  jne .not_dictionary
    dictionary_copy rax
    ret
  .not_dictionary:

  type_to_string rbx
  mov rbx, rax
  string "copy: Нет функции копирования для типа"
  print <rax, rbx>

  exit -1
