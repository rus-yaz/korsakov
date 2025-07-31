; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

; Методы коллекций
;   Конструктор
;   Длина
;   Вместимость
;   Расширить вместимость
;   Установить ссылку на элемент по индексу
;   Установить копию элемента по индексу
;   Получить ссылку на элемент по индексу
;   Получить копию элемента по индексу
;   Копировать ссылки
;   Копировать элементы

; Методы словарей
;   Получить список из списков из ссылок на ключи и значения
;   Получить список из списков из копий ключей и значений
;   Получить список из ссылок на ключи
;   Получить список из копий ключей
;   Получить список из ссылок на значения
;   Получить список из копий значений
;   Расширить ссылками на пары из другого словаря
;   Расширить копиями пар из другого словаря
;   Сложить ссылки на пары словарей
;   Сложить копии пар словарей

f_dictionary:
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

  create_block DICTIONARY_HEADER*8
  mem_mov [rax + 8*0], DICTIONARY ; Тип
  mem_mov [rax + 8*1], 0          ; Длина
  mem_mov [rax + 8*2], rbx        ; Вместимость
  mem_mov [rax + 8*3], rcx        ; Указатель на элементы

  ret

f_dictionary_from_list:
  get_arg 0
  mov rbx, rax

  check_type rbx, LIST

  list_length rbx
  integer rax
  mov rcx, rax

  integer 0
  mov rdx, rax

  dictionary
  mov r8, rax

  .while:

    is_equal rcx, rdx
    boolean_value rax
    cmp rax, 1
    je .end_while

    list_get_link rbx, rdx
    mov r9, rax

    check_type rax, LIST

    list_length r9
    cmp rax, 2
    je .correct_length
      string "dictionary_from_list: Длины внутренних списков должны равняться двум"
      mov rbx, rax
      list
      list_append_link rax, rbx
      error rax
      exit -1
    .correct_length:

    integer 0
    list_get_link r9, rax
    mov r10, rax
    integer 1
    list_get_link r9, rax

    dictionary_set r8, r10, rax

    integer_inc rdx
    jmp .while

  .end_while:

  mov rax, r8

  ret

f_dictionary_length:
  get_arg 0
  check_type rax, DICTIONARY

  mov rax, [rax + 8*1]
  ret

f_dictionary_capacity:
  get_arg 0
  check_type rax, DICTIONARY

  mov rax, [rax + 8*2]
  ret

f_dictionary_expand_capacity:
  get_arg 0
  mov rbx, rax

  check_type rbx, DICTIONARY
  dictionary_capacity rbx

  imul rax, 2
  mov [rbx + 8*2], rax

  imul rax, 8
  create_block rax
  mov rcx, rax

  dictionary_length rbx
  mem_copy [rbx + 8*3], rcx, rax

  delete_block [rbx + 8*3]
  mov [rbx + 8*3], rcx

  ret

f_dictionary_set_link:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  check_type rbx, DICTIONARY

  ; RBX — key
  ; RCX — value
  ; RDX — dictionary

  dictionary_keys_links rbx
  list_index rax, rcx

  mov r8, [rax + INTEGER_HEADER*8]
  cmp r8, -1
  je .new_key

    imul r8, 8

    mov rcx, [rbx + 8*3]
    add rcx, r8

    integer 1
    list_set [rcx], rax, rdx

    mov rax, rbx
    ret

  .new_key:

  dictionary_length rbx
  mov r9, rax

  dictionary_capacity rbx
  cmp r9, rax
  jne @f
    dictionary_expand_capacity rbx
  @@:

  list
  list_append_link rax, rcx
  list_append_link rax, rdx
  mov rcx, rax

  mov r8, r9
  imul r8, 8  ; Отступ до элемента

  inc r9
  mov [rbx + 8*1], r9 ; Запись новой длины

  mov rax, [rbx + 8*3] ; Взятие указателя на последовательность элементов
  add rax, r8          ; Смещение до места для нового элемента

  mov [rax], rcx
  mov rax, rbx

  repeat 1000
    nop
  end repeat

  ret

f_dictionary_set:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  check_type rbx, DICTIONARY

  copy rcx
  mov rcx, rax
  copy rdx
  dictionary_set_link rbx, rcx, rax

  ret

f_dictionary_get_link:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  check_type rbx, DICTIONARY

  dictionary_keys_links rbx
  list_index rax, rcx
  mov r8, rax

  integer -1
  is_equal rax, r8
  boolean_value rax
  cmp rax, 1
  jne .no_key

    cmp rdx, 0
    jne .return_default

      string "Ключ не найден:"
      mov rdx, rax
      to_string rcx
      mov rcx, rax
      list
      list_append_link rax, rdx
      list_append_link rax, rcx
      list_append_link rax, rbx
      error rax
      exit -1

    .return_default:

    mov rax, rdx
    ret

  .no_key:

  dictionary_values_links rbx
  list_get_link rax, r8

  ret

f_dictionary_get:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  check_type rbx, DICTIONARY
  dictionary_get_link rbx, rcx, rdx
  copy rax

  ret

f_dictionary_copy_links:
  get_arg 0
  mov rbx, rax

  check_type rbx, DICTIONARY

  dictionary_capacity rbx
  dictionary rax
  mov rcx, rax

  mem_mov [rcx + 8*0], [rbx + 8*0]
  mem_mov [rcx + 8*1], [rbx + 8*1]
  mem_copy [rbx + 8*3], [rcx + 8*3], [rcx + 8*1]

  mov rax, rcx
  ret

f_dictionary_copy:
  get_arg 0
  mov rbx, rax

  check_type rbx, DICTIONARY

  dictionary_capacity rbx
  dictionary rax
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

f_dictionary_items_links:
  get_arg 0
  check_type rax, DICTIONARY

  dictionary_copy_links rax
  mem_mov [rax + 8*0], LIST
  ret

f_dictionary_items:
  get_arg 0
  check_type rax, DICTIONARY

  dictionary_items_links rax
  copy rax

  ret

f_dictionary_keys_links:
  get_arg 0
  mov rbx, rax

  check_type rbx, DICTIONARY

  dictionary_items_links rbx
  mov rbx, rax

  list_length rbx
  integer rax
  mov rcx, rax

  integer 0
  mov rdx, rax

  integer 0
  mov r8, rax

  list
  mov r9, rax

  .while:
    is_equal rcx, rdx
    boolean_value rax
    cmp rax, 1
    je .end_while

    list_get_link rbx, rdx
    list_get_link rax, r8
    list_append_link r9, rax

    integer_inc rdx
    jmp .while

  .end_while:

  mov rax, r9

  ret

f_dictionary_keys:
  get_arg 0
  check_type rax, DICTIONARY

  dictionary_keys_links rax
  copy rax

  ret

f_dictionary_values_links:
  get_arg 0
  mov rbx, rax

  check_type rbx, DICTIONARY

  dictionary_items_links rbx
  mov rbx, rax

  list_length rbx
  integer rax
  mov rcx, rax

  integer 0
  mov rdx, rax

  integer 1
  mov r8, rax

  list
  mov r9, rax

  .while:
    is_equal rcx, rdx
    boolean_value rax
    cmp rax, 1
    je .end_while

    list_get_link rbx, rdx
    list_get_link rax, r8
    list_append_link r9, rax

    integer_inc rdx
    jmp .while

  .end_while:

  mov rax, r9

  ret

f_dictionary_values:
  get_arg 0
  check_type rax, DICTIONARY

  dictionary_values_links rax
  copy rax

  ret

f_dictionary_extend_links:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, DICTIONARY
  check_type rcx, DICTIONARY

  dictionary_length rcx
  mov rdx, rax

  integer 0
  mov r8, rax

  dictionary_keys_links rcx
  mov r9, rax
  dictionary_values_links rcx
  mov r10, rax

  @@:
    cmp rdx, 0
    je @f

    list_get_link r9,  r8
    mov r11, rax
    list_get_link r10, r8
    dictionary_set_link rbx, r11, r10

    integer_inc r8
    dec rdx
    jmp @b
  @@:

  delete r8

  mov rax, rbx
  ret

f_dictionary_extend:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  copy rcx
  mov rcx, rax

  dictionary_extend_links rbx, rcx
  delete_block rcx

  ret

f_dictionary_add_links:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  dictionary_copy_links rbx
  dictionary_extend_links rax, rcx

  ret

f_dictionary_add:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  dictionary_add_links rbx, rcx
  copy rax

  ret
