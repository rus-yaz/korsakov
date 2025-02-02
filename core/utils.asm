f_buffer_length:
  get_arg 0
  mov rcx, 0 ; Счётчик

  .while:
    ; Сравниваем текущий байт с нулём
    mov bl, [rax + rcx]

    cmp bl, 0
    je .end_while

    inc rcx
    jmp .while

  .end_while:
  mov rax, rcx

  ret

f_sys_print:
  get_arg 1
  mov rbx, rax
  get_arg 0

  sys_write STDOUT,\
            rax,\       ; Указатель на данные для вывода
            rbx         ; Длина данных для вывода

  ret

f_print_buffer:
  get_arg 0
  mov rsi, rax

  buffer_length rsi
  mov rbx, rax

  sys_print rsi,\      ; Указатель на буфер
            rbx        ; Размер буфера

  ret

f_mem_copy:
  get_arg 0
  mov rsi, rax ; Источник
  get_arg 1
  mov rdi, rax ; Место назначения
  get_arg 2
  mov rcx, rax ; Количество блоков

  rep movsq

  ret

f_check_error:
  get_arg 0
  exit -1, rax

f_type_to_string:
  get_arg 0

  mov rbx, HEAP_BLOCK
  cmp rax, rbx
  jne .not_heap_block
    string "Блок кучи"
    ret

  .not_heap_block:

  cmp rax, NULL
  jne .not_null
    string "НУЛЬ"
    ret
  .not_null:

  cmp rax, INTEGER
  jne .not_integer
    string "Целое число"
    ret
  .not_integer:

  cmp rax, FLOAT
  jne .not_float
    string "Вещественное число"
    ret
  .not_float:

  cmp rax, BOOLEAN
  jne .not_boolean
    string "Булево значение"
    ret
  .not_boolean:

  cmp rax, LIST
  jne .not_list
    string "Список"
    ret
  .not_list:

  cmp rax, BINARY
  jne .not_binary
    string "Бинарная последовательность"
    ret
  .not_binary:

  cmp rax, STRING
  jne .not_string
    string "Строка"
    ret
  .not_string:

  cmp rax, DICTIONARY
  jne .not_dictionary
    string "Словарь"
    ret
  .not_dictionary:

  cmp rax, CLASS
  jne .not_class
    string "Класс"
    ret
  .not_class:

  cmp rax, FILE
  jne .not_file
    string "Файл"
    ret
  .not_file:

  integer rax
  to_string rax
  mov rbx, rax
  string "type_to_string: Нет строкового обозначения для типа"
  print <rax, rbx>
  exit -1

f_type_full_size:
  get_arg 0

  cmp rax, NULL
  jne .not_null
    mov rax, NULL_SIZE
    ret
  .not_null:

  cmp rax, INTEGER
  jne .not_integer
    mov rax, INTEGER_SIZE
    ret
  .not_integer:

  cmp rax, BOOLEAN
  jne .not_boolean
    mov rax, BOOLEAN_SIZE
    ret
  .not_boolean:

  cmp rax, LIST
  jne .not_list
    mov rax, LIST_HEADER
    ret
  .not_list:

  cmp rax, STRING
  jne .not_string
    mov rax, STRING_HEADER
    ret
  .not_string:

  cmp rax, DICTIONARY
  jne .not_dictionary
    mov rax, DICTIONARY_HEADER
    ret
  .not_dictionary:

  integer 1
  print rax

  type_to_string rax
  mov rbx, rax
  string "type_full_size: Не определён размер заголовка для типа"
  print <rax, rbx>
  exit -1

f_check_type:
  get_arg 0
  mov r8, [rax]
  get_arg 1
  mov r9, rax

  cmp r8, r9
  jne .continue
    ret

  .continue:

  type_to_string r9
  mov rbx, rax
  string "check_type: Ожидался тип"
  print <rax, rbx>
  exit -1
