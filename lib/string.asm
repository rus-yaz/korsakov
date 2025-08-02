; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

; Методы бинарных последовательностей и буферов
;   Буфер к бинарной последовательности
;   Бинарная последовательность к строке
;   Буфер к строке
;   Строка к бинарной последовательности
;   Длина бинарной последовательности
;
; Методы коллекций
;   Конструктор
;   Длина
;   Вместимость
;   Расширить вместимость
;   Установить ссылку на символ по индексу
;   Установить копию символа по индексу
;   Получить ссылку на символ по индексу
;   Получить копию символа по индексу
;   Копировать ссылки
;   Копировать элементы
;
; Методы строки
;   Изъять ссылку на символ по индексу
;   Изъять копии символа по индексу
;   Получить индекс символа
;   Проверить, входит ли подстрока в строку
;   Расширить строку ссылками на символами строки
;   Расширить строку копиями символов строки
;   ! Получить развёрнутую строку из ссылок на символы
;   ! Получить развёрнутую строку из копий символов
;   Получить срез ссылок на символы
;   Получить срез копий символы
;   Сложить строки из ссылок на символы
;   Сложить строки из копий символов
;   Повторить строки из ссылок на символы
;   Повторить строки из копий симоволов

f_string_from_capacity:
  get_arg 0
  mov rbx, rax

  cmp rbx, 0
  jne @f
    mov rbx, 2
  @@:

  mov rcx, rbx
  imul rcx, 8

  create_block rcx ; Аллокация места для элементов

  mov      rdi, rax ; Источник копирования
  mov byte [rdi], 0 ; Значение, которое будет раскопировано

  mov rsi, rdi ; Место назначения
  inc rsi      ; Смещение от уже назначенного

  rep movsb ; Побайтовое копирование
  mov rcx, rax

  create_block STRING_HEADER*8
  mem_mov [rax + 8*0], STRING ; Тип
  mem_mov [rax + 8*1], 0      ; Длина
  mem_mov [rax + 8*2], rbx    ; Вместимость
  mem_mov [rax + 8*3], rcx    ; Указатель на элементы

  ret

f_string_length:
  get_arg 0
  check_type rax, STRING

  mov rax, [rax + 8*1]
  ret

f_string_capacity:
  get_arg 0
  check_type rax, STRING

  mov rax, [rax + 8*2]
  ret

f_string_expand_capacity:
  get_arg 0
  mov rbx, rax

  check_type rbx, STRING

  string_capacity rbx

  imul rax, 2
  mov [rbx + 8*2], rax

  imul rax, 8
  create_block rax
  mov rcx, rax

  string_length rbx
  mem_copy [rbx + 8*3], rcx, rax

  delete_block [rbx + 8*3]
  mov [rbx + 8*3], rcx

  ret

f_string_set_link:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  check_type rbx, STRING
  check_type rcx, INTEGER
  check_type rdx, STRING

  string_length rdx
  cmp rax, 1
  je .correct_length
    raw_string "string_set: Ожидалась строка с длиной 1"
    error_raw rax
    exit -1
  .correct_length:

  ; Запись длины строки
  string_length rbx
  mov r8, rax

  ; Если индекс меньше нуля, то увеличить его на длину строки
  mov rcx, [rcx + 8*1]
  cmp rcx, 0
  jge @f
    add rcx, r8
  @@:

  ; Проверка, входит ли индекс в строке
  cmp rcx, r8
  check_error jge, "string_set: Индекс выходит за пределы строки"
  cmp rcx, 0
  check_error jl, "string_set: Индекс выходит за пределы строки"

  mov rax, rbx
  mov rbx, [rbx + 8*3]

  imul rcx, 8
  add rbx, rcx

  mov [rbx], rdx
  ret

f_string_set:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  string_copy rdx
  string_set_link rbx, rcx, rax

  ret

f_string_get_link:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, STRING
  check_type rcx, INTEGER

  ; Запись длины строки
  string_length rbx
  mov r8, rax

  ; Если индекс меньше нуля, то увеличить его на длину строки
  mov rcx, [rcx + 8*1]
  cmp rcx, 0
  jge @f
    add rcx, r8
  @@:

  ; Проверка, входит ли индекс в строке
  cmp rcx, r8
  check_error jge, "string_get: Индекс выходит за пределы строки"
  cmp rcx, 0
  check_error jl, "string_get: Индекс выходит за пределы строки"

  mov rax, rbx
  mov rbx, [rbx + 8*3]

  imul rcx, 8
  add rbx, rcx

  mov rbx, [rbx]

  string_from_capacity 1
  mov r8, rax

  mov rax, [r8 + 8*3]
  mov [rax], rbx

  mov qword [r8 + 8*1], 1

  mov rax, r8
  ret

f_string_get:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  string_get_link rbx, rcx
  string_copy rax

  ret

f_string_copy_links:
  get_arg 0
  mov rbx, rax

  check_type rbx, STRING

  string_capacity rbx
  string_from_capacity rax
  mov rcx, rax

  mem_mov [rcx + 8*0], [rbx + 8*0]
  mem_mov [rcx + 8*1], [rbx + 8*1]
  mem_copy [rbx + 8*3], [rcx + 8*3], [rcx + 8*1]

  mov rax, rcx
  ret

f_string_copy:
  get_arg 0
  mov rbx, rax

  check_type rbx, STRING

  string_capacity rbx
  string_from_capacity rax
  mov rcx, rax

  mem_mov [rcx + 8*0], [rbx + 8*0]
  mem_mov [rcx + 8*1], [rbx + 8*1]

  mov r8, [rbx + 8*3]
  mov r9, [rcx + 8*3]

  mov rdx, [rcx + 8*1]
  @@:
    cmp rdx, 0
    je @f

    copy [r8]
    mov [r9], rax

    add r8, 8
    add r9, 8

    dec rdx
    jmp @b
  @@:

  mov rax, rcx
  ret

f_string_pop_link:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  cmp rcx, 0
  jne @f
    integer -1
    mov rcx, rax
  @@:

  check_type rbx, STRING
  check_type rcx, INTEGER

  string_length rbx
  mov rdx, rax

  mov rcx, [rcx + INTEGER_HEADER*8]
  cmp rcx, 0
  jge @f
    add rcx, rdx
  @@:

  cmp rcx, rdx
  check_error jge, "string_pop: Индекс выходит за пределы строки"
  cmp rcx, 0
  check_error jl, "string_pop: Индекс выходит за пределы строки"

  ; Декрементация длины
  dec rdx
  mov [rbx + 8*1], rdx

  mov r8, rdx
  sub r8, rcx

  ; Смещение до элемента
  imul rcx, 8
  mov rbx, [rbx + 8*3]

  add rbx, rcx
  mov rax, [rbx]

  mov r9, rbx
  add r9, 8

  mem_copy r9, rbx, r8

  ; Затирание последнего элемента
  imul r8, 8
  add rbx, r8
  mem_mov [rbx], 0

  mov rbx, rax

  string_from_capacity 1
  mov rcx, rax

  mov qword [rcx + 8*1], 1

  mov rax, [rcx + 8*3]
  mov [rax], rbx

  mov rax, rcx
  ret

f_string_pop:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  string_pop_link rbx, rcx
  string_copy rax

  ret

f_string_index:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, STRING
  check_type rcx, STRING

  string_length rcx
  cmp rax, 1
  je .correct_length
    raw_string "string_index: Ожидалась строка с длиной 1"
    error_raw rax
    exit -1
  .correct_length:

  integer 0
  mov rdx, rax

  string_length rbx
  mov r8, rax

  @@:
    cmp [rdx + INTEGER_HEADER*8], r8
    je @f

    string_get_link rbx, rdx
    is_equal rax, rcx
    boolean_value rax
    cmp rax, 1
    je .return_index

    integer_inc rdx
    jmp @b
  @@:

  delete rdx
  integer -1
  ret

  .return_index:
  mov rax, rdx
  ret

f_string_include:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, STRING
  check_type rcx, STRING

  mov rdx, 0 ; Итератор
  mov r8,  0 ; Счётчик схождение

  string_length rbx
  mov r9, rax
  string_length rcx
  mov r10, rax

  sub r9, r10
  inc r9

  cmp r9, 0
  jle .return_false

  @@:
    cmp rdx, r9
    je @f

    ; Количество схождений совпало с количеством символом в подстроке
    cmp r8, r10
    je .return_true

    integer rdx
    string_get_link rbx, rax
    mov r11, rax

    integer r8
    string_get_link rcx, rax

    is_equal r11, rax
    boolean_value rax
    cmp rax, 1
    jne .not_equal
      inc r8
      jmp .continue
    .not_equal:
      sub rdx, r8
      mov r8, 0
    .continue:

    inc rdx
    jmp @b
  @@:

  .return_false:
    boolean 0
    ret

  .return_true:
    boolean 1
    ret

f_string_extend_links:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, STRING
  check_type rcx, STRING

  string_length rbx
  mov rdx, rax
  string_length rcx
  add rdx, rax

  @@:
    string_capacity rbx
    cmp rax, rdx
    jge @f

    string_expand_capacity rbx
    jmp @b
  @@:

  mov rdi, [rbx + 8*3]

  string_length rbx
  imul rax, 8
  add rdi, rax

  mov [rbx + 8*1], rdx
  mov rsi, [rcx + 8*3]

  string_length rcx
  mov rcx, rax

  rep movsq
  mov rax, rbx

  ret

f_string_extend:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  string_copy rcx
  string_extend_links rbx, rax

  ret

f_split_links:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  cmp rcx, 0
  jne .not_default_separator
    string " "
    mov rcx, rax
  .not_default_separator:

  cmp rdx, 0
  jne .not_default_parts_count
    integer -1
    mov rdx, rax
  .not_default_parts_count:

  check_type rbx, STRING
  check_type rcx, STRING
  check_type rdx, INTEGER

  list
  mov r8, rax

  integer 0
  mov r9, rax

  string_length rbx
  integer rax
  mov r10, rax

  string ""
  mov r11, rax

  .while:
    is_equal r9, r10
    boolean_value rax
    cmp rax, 1
    je .end_while

    string_get_link rbx, r9
    mov r12, rax

    list_length r8
    integer rax
    is_equal rax, rdx
    boolean_value rax
    cmp rax, 1
    je .join

    is_equal r12, rcx
    boolean_value rax
    cmp rax, 1
    je .split

    .join:

      string_extend_links r11, r12

      jmp .continue

    .split:
      list_append_link r8, r11

      string ""
      mov r11, rax

    .continue:

    integer_inc r9
    jmp .while

  .end_while:
  list_append_link r8, r11

  mov rax, r8
  ret

f_split:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  split_links rbx, rcx, rdx
  copy rax
  ret

f_split_from_right_links:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  cmp rcx, 0
  jne .not_default_separator
    string " "
    mov rcx, rax
  .not_default_separator:

  cmp rdx, 0
  jne .not_default_parts_count
    integer -1
    mov rdx, rax
  .not_default_parts_count:

  check_type rbx, STRING
  check_type rcx, STRING
  check_type rdx, INTEGER

  integer_inc rdx

  list
  mov r8, rax
  null
  list_append_link r8, rax

  integer 1
  mov r9, rax

  string_length rbx
  inc rax
  integer rax
  mov r10, rax

  string ""
  mov r11, rax

  .while:
    is_equal r9, r10
    boolean_value rax
    cmp rax, 1
    je .end_while

    negate r9
    string_get_link rbx, rax
    mov r12, rax

    list_length r8
    integer rax
    is_equal rax, rdx
    boolean_value rax
    cmp rax, 1
    je .join

    is_equal r12, rcx
    boolean_value rax
    cmp rax, 1
    je .split

    .join:

      string_add_links r12, r11
      mov r11, rax

      jmp .continue

    .split:
      integer 0
      list_insert_link r8, rax, r11

      string ""
      mov r11, rax

    .continue:

    integer_inc r9
    jmp .while

  .end_while:
  integer 0
  list_insert_link r8, rax, r11

  list_pop_link r8

  mov rax, r8
  ret

f_split_from_right:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  split_from_right_links rbx, rcx, rdx
  copy rax
  ret

f_join_links:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  cmp rcx, 0
  jne .not_default_separator
    string " "
    mov rcx, rax
  .not_default_separator:

  check_type rbx, LIST
  check_type rcx, STRING

  string ""
  mov rdx, rax

  integer 0
  mov r8, rax

  list_length rbx
  integer rax
  mov r9, rax

  .while:

    is_equal r8, r9
    boolean_value rax
    cmp rax, 1
    je .end_while

    list_get rbx, r8
    check_type rax, STRING
    string_extend_links rdx, rax

    integer_inc r8

    is_equal r8, r9
    boolean_value rax
    cmp rax, 1
    je .end_while

    string_extend_links rdx, rcx

    jmp .while

  .end_while:

  mov rax, rdx

  ret

f_join:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  join_links rbx, rcx
  string_copy rax

  ret

f_is_alpha:
  get_arg 0
  check_type rax, STRING
  mov rbx, rax

  string_length rax
  integer rax
  mov rcx, rax

  integer 0
  mov rdx, rax

  .while:
    is_equal rcx, rdx
    boolean_value rax
    cmp rax, 1
    je .end_while

    string_get rbx, rdx

    mov rax, [rbx + 8*3]
    mov rax, [rax]
    mov rax, [rax + INTEGER_HEADER*8]

    cmp rax, 65
    jl .check_lowercase
    cmp rax, 90
    jle .continue

    .check_lowercase:

    cmp rax, 97
    jl .check_cyrillic
    cmp rax, 122
    jle .continue

    .check_cyrillic:

    cmp rax, 53377
    jl .return_false
    cmp rax, 53649
    jg .return_false

    .continue:

    integer_inc rdx
    jmp .while

  .end_while:

  mov rax, 1
  ret

  .return_false:

  mov rax, 0
  ret

f_is_digit:
  get_arg 0
  check_type rax, STRING
  mov rbx, rax

  string_length rax
  integer rax
  mov rcx, rax

  integer 0
  mov rdx, rax

  .while:
    is_equal rcx, rdx
    boolean_value rax
    cmp rax, 1
    je .end_while

    string_get rbx, rdx
    mov rax, [rbx + 8*3]
    mov rax, [rax]
    mov rax, [rax + INTEGER_HEADER*8]

    cmp rax, 48
    jl .return_false
    cmp rax, 57
    jg .return_false

    .continue:

    integer_inc rdx
    jmp .while

  .end_while:

  mov rax, 1
  ret

  .return_false:

  mov rax, 0
  ret

f_string_to_list:
  get_arg 0
  mov rbx, rax

  check_type rbx, STRING

  list
  mov rcx, rax

  string_length rbx
  integer rax
  mov rdx, rax

  integer 0
  mov r8, rax

  .while:
    is_equal rdx, r8
    boolean_value rax
    cmp rax, 1
    je .end_while

    string_get rbx, r8
    list_append rcx, rax

    integer_inc r8
    jmp .while

  .end_while:

  mov rax, rcx
  ret

f_string_reverse_links:
  get_arg 0
  mov rbx, rax

  check_type rbx, STRING

  string_capacity rbx
  string_from_capacity rax
  mov r9, rax

  mem_mov [r9 + 8*0], [rbx + 8*0]
  mem_mov [r9 + 8*1], [rbx + 8*1]

  string_length rbx
  mov rdx, rax

  mov rbx, [rbx + 8*3]
  mov rcx, [r9  + 8*3]

  mov r8, rdx
  dec r8
  imul r8, 8
  add rbx, r8

  mov r8, 0
  @@:
    cmp rdx, r8
    je @f

    mem_mov [rcx], [rbx]

    sub rbx, 8
    add rcx, 8

    inc r8
    jmp @b
  @@:

  mov rax, r9
  ret

f_string_reverse:
  get_arg 0
  mov rbx, rax

  string_reverse_links rbx
  copy rax

  ret

f_string_slice_links:
  get_arg 0    ; Коллекция
  mov rbx, rax
  get_arg 1    ; Начало
  mov rcx, rax
  get_arg 2    ; Конец
  mov rdx, rax
  get_arg 3    ; Шаг
  mov r8, rax

  cmp rcx, 0
  jne @f
    integer 0
    mov rcx, rax
  @@:

  cmp rdx, 0
  jne @f
    integer -1
    mov rdx, rax
  @@:

  cmp r8, 0
  jne @f
    integer 1
    mov r8, rax
  @@:

  check_type rbx, STRING
  check_type rcx, INTEGER
  check_type rdx, INTEGER
  check_type r8,  INTEGER

  string_length rbx
  integer rax
  mov r15, rax
  is_lower rax, rdx
  boolean_value rax
  delete r15
  cmp rax, 1
  je @f

  integer 0
  mov r15, rax
  is_lower rdx, rax
  boolean_value rax
  delete r15
  cmp rax, 1
  je @f

  jmp .correct_stop

  @@:
    string_length rbx
    integer rax
    mov rdx, rax

  .correct_stop:

  mov r10, 0 ; 0 — прямое направление, 1 — обратное

  integer 0
  mov r15, rax
  is_lower r8, rax
  boolean_value rax
  delete r15
  cmp rax, 1
  jne @f
    negate r8
    mov r8, rax

    mov r10, 1
  @@:

  string ""
  mov r9, rax

  @@:
    is_equal rcx, rdx
    boolean_value rax
    cmp rax, 1
    je @f

    string_get_link rbx, rcx
    string_extend_links r9, rax

    integer_add rcx, r8
    mov rcx, rax
    jmp @b
  @@:

  mov rax, r9
  cmp r10, 0
  je @f
    string_reverse_links rax
  @@:

  ret

f_string_slice:
  get_arg 0    ; Коллекция
  mov rbx, rax
  get_arg 1    ; Начало
  mov rcx, rax
  get_arg 2    ; Конец
  mov rdx, rax
  get_arg 3    ; Шаг
  mov r8, rax

  string_slice_links rbx, rcx, rdx, r8
  copy rax

  ret

f_string_add_links:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, STRING
  check_type rcx, STRING

  string_copy_links rbx
  string_extend_links rax, rcx

  ret

f_string_add:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  string_add_links rbx, rcx
  string_copy rax

  ret

f_string_mul_links:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, STRING
  check_type rcx, INTEGER

  mov rcx, [rcx + INTEGER_HEADER*8]
  cmp rcx, 0
  jge @f
    string_reverse_links rbx
    mov rbx, rax
  @@:

  string ""
  mov rdx, rax

  @@:
    cmp rcx, 0
    je @f

    string_extend_links rdx, rbx

    dec rcx
    jmp @b
  @@:

  ret

f_string_mul:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  string_mul_links rbx, rcx
  copy rax

  ret
