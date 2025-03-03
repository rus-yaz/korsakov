; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

f_dictionary:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  cmp rcx, 0
  je .not_from_lists
    dictionary_from_lists rbx, rcx
    ret

  .not_from_lists:

  cmp rbx, 0
  je .not_from_items
    dictionary_from_items rbx
    ret

  .not_from_items:

  collection
  mem_mov [rax + 8*0], DICTIONARY

  ret

f_dictionary_from_lists:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, LIST
  check_type rcx, LIST

  list_length rbx
  mov rdx, rax
  list_length rcx
  cmp rdx, rax
  je .continue
    string "dictionary_from_lists: Длина списков должна быть равна"
    mov rbx, rax
    list
    list_append_link rax, rbx
    print rax
    exit -1

  .continue:

  integer rdx
  mov rdx, rax

  integer 0
  mov r8, rax

  dictionary
  mov r9, rax

  .while:

    is_equal rdx, r8
    boolean_value rax
    cmp rax, 1
    je .end_while

    list_get_link rbx, r8
    mov r10, rax
    list_get_link rcx, r8
    dictionary_set r9, r10, rax

    integer_inc r8
    jmp .while

  .end_while:

  mov rax, r9

  ret

f_dictionary_from_items:
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
      string "dictionary_from_lists: Длины внутренних списков должны равняться двум"
      mov rbx, rax
      list
      list_append_link rax, rbx
      print rax
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

  collection_length rax
  ret

f_dictionary_capacity:
  get_arg 0
  check_type rax, DICTIONARY

  collection_capacity rax
  ret

f_dictionary_copy_links:
  get_arg 0
  check_type rax, DICTIONARY

  collection_copy_links rax
  ret

f_dictionary_copy:
  get_arg 0
  check_type rax, DICTIONARY

  mem_mov [rax], LIST
  mov rbx, rax
  list_copy rax

  mem_mov [rbx], DICTIONARY
  mem_mov [rax], DICTIONARY

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
      print rax
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

  list
  list_append_link rax, rcx
  list_append_link rax, rdx

  collection_append_link rbx, rax
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

f_dictionary_add_links:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  dictionary_copy_links rbx
  mov rbx, rax
  dictionary_values_links rcx
  mov rdx, rax
  dictionary_keys_links rcx
  mov rcx, rax

  integer 0
  mov r8, rax

  list_length rdx
  integer rax
  mov r9, rax

  .while:

    is_equal r8, r9
    boolean_value rax
    cmp rax, 1
    je .while_end

    list_get_link rcx, r8
    mov r10, rax
    list_get_link rdx, r8
    mov r11, rax

    dictionary_set_link rbx, r10, r11

    integer_inc r8
    jmp .while

  .while_end:

  mov rax, rbx
  ret

f_dictionary_add:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  dictionary_add_links rbx, rcx
  copy rax

  ret
