f_to_string:
  mov rbx, [rax]

  cmp rbx, NULL
  je .null

  cmp rbx, INTEGER
  je .integer

  cmp rbx, LIST
  je .list

  cmp rbx, STRING
  je .string

  cmp rbx, DICTIONARY
  je .dictionary

  print EXPECTED_TYPE_ERROR, "", ""

  list
  mov rbx, rax

  buffer_to_string INTEGER_TYPE
  list_append rbx, rax
  buffer_to_string LIST_TYPE
  list_append rbx, rax
  buffer_to_string STRING_TYPE
  list_append rbx, rax
  buffer_to_string DICTIONARY_TYPE
  list_append rbx, rax

  join rax, ", "
  print rax

  exit -1

  .null:
    string "НУЛЬ"
    ret

  .integer:
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

    .integet_while:
      idiv rbx    ; Деление на мощность системы счисления
      add rdx, 48 ; Приведение числа к значению по ASCII

      push rdx   ; Сохранение числа на стеке
      mov rdx, 0 ; Обнуление регистра, хранящего остаток от деления

      inc rcx
      cmp rax, 0
      jne .integet_while

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

  .list:
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

  .string:
    mov rbx, rax

    mov rdx, rsp
    push 0, '"'
    mov rax, rsp
    buffer_to_string rax
    mov rcx, rax

    string_add rcx, rbx
    string_add rax, rcx

    mov rsp, rdx

    ret

  .dictionary:
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

f_type_to_string:
  mov rdx, rax

  dictionary
  mov rcx, rax

  integer HEAP_BLOCK
  mov rbx, rax
  string "Блок кучи"
  dictionary_set rcx, rbx, rax

  integer NULL
  mov rbx, rax
  string "НУЛЬ"
  dictionary_set rcx, rbx, rax

  integer INTEGER
  mov rbx, rax
  string "Целое число"
  dictionary_set rcx, rbx, rax

  integer FLOAT
  mov rbx, rax
  string "Вещественное число"
  dictionary_set rcx, rbx, rax

  integer LIST
  mov rbx, rax
  string "Список"
  dictionary_set rcx, rbx, rax

  integer BINARY
  mov rbx, rax
  string "Бинарная последовательность"
  dictionary_set rcx, rbx, rax

  integer STRING
  mov rbx, rax
  string "Строка"
  dictionary_set rcx, rbx, rax

  integer DICTIONARY
  mov rbx, rax
  string "Словарь"
  dictionary_set rcx, rbx, rax

  integer CLASS
  mov rbx, rax
  string "Класс"
  dictionary_set rcx, rbx, rax

  integer FILE
  mov rbx, rax
  string "Файл"
  dictionary_set rcx, rbx, rax

  integer rdx
  mov rdx, rax

  null
  dictionary_get rcx, rdx
  mov rbx, rax

  null
  is_equal rbx, rax
  cmp rax, 1
  jne .correct_type

    string "Неизвестный тип: "
    mov rbx, rax
    to_string rdx
    string_append rbx, rax
    print rax

    exit -1

  .correct_type:

  mov rax, rbx

  ret
